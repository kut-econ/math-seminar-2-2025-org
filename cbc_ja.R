#############################################################################
#
#                     Choice-based conjoint analysis
#
#############################################################################

library(cbcTools)
library(makedummies)
library(mlogit)
library(ggplot2)

########################## SET ENVIRONMENT  ################################

working_dir <- '~/workingdir'
setwd(working_dir)

########################## PARAMETER SETUP  #################################
# In future, parameters here should be manipulated via GUI

# Set random seed
set.seed(123)

# Design method: full, orthogonal, or dopt
method <- "orthogonal"

# Number of alternatives: usually 2
n_alts <- 2

# Number of questions
# For 2-level model, usually 8
# For 3-level model, usually 9
# For other cases, adjust the value carefully
n_q <- 8
#n_q <- 9

# Sample size
N <- 500

# File name of attribute table
attr_tbl_file <- "attribute_table.csv"

# Coefficients for simulation
# length(beta) must be equal to #levels - #attributes 
# E.g., if 3 attributes with 2 levels each, 2*3 - 3 = 3
beta <- c(-1,-1.5,-0.7,-0.3,-0.5)

####################### READ ATTRIBUTE TABLE ################################

# Read attribute table
attr_table <- read.csv(attr_tbl_file,
                       header=TRUE,
                       na.strings="",
                       colClasses="character")

# Transform the table into a list
attribute_names <- names(attr_table)
attrs <- as.list(attr_table)
for (i in names(attrs)) {
  attrs[[i]] <- attrs[[i]][!is.na(attrs[[i]])]
}

########################## PLAN EXPERIMENT ################################

# Profiles
profiles <- do.call(cbc_profiles,attrs)

write.csv(profiles,file='./profiles.csv',row.names=FALSE)

# Design
design <- cbc_design(profiles=profiles, 
                     n_resp=1,
                     n_alts=n_alts,
                     n_q=n_q,
                     n_blocks=1,
                     no_choice=FALSE,
                     method=method
)

write.csv(design,file='./design.csv',row.names=FALSE)

# Level balance and orthogonality
cbc_balance(design)

# Save result to file
sink("cbc_balance.txt")
cbc_balance(design)
sink()

# IMPORTANT: level overlap between alternatives
cbc_overlap(design)

# Save result to file
sink("cbc_overlap.txt")
cbc_overlap(design)
sink()

# Transform categorical variables into dummies

profiles_dummy <- makedummies(profiles, as.is=c("profileID"))

# Actually used profiles
used_profileID <- sort(unique(design$profileID))

# Show orthogonal table used in the design
used_profiles_dummy <- profiles_dummy[profiles_dummy$profileID %in% used_profileID,]
write.csv(used_profiles_dummy,file='used_profiles_dummy.csv',row.names = FALSE)

# Show profiles used in the design
used_profiles <- profiles[profiles$profileID %in% used_profileID,]
write.csv(used_profiles,file='used_profiles.csv',row.names = FALSE)

############################ SIMULATION ####################################
# Function 'cbc_simulation' returns a simulated data set in Qualtrics format

cbc_simulation <- function(profiles_dummy,beta,output) {

  # Utilities of profiles
  u <- as.matrix(profiles_dummy[,-1]) %*% beta

  # Design matrix for simulation
  design_forsim <- design
  design_forsim$utility <- u[design$profileID]
  design_forsim <- transform(design_forsim, exp_utility=exp(utility))
  exp_utility_sum <- aggregate(design_forsim$exp_utility, by=list(design_forsim$qID), FUN=sum)
  design_forsim$prob <- design_forsim$exp_utility / rep(exp_utility_sum$x, each=2)
  prob_mat <- matrix(data=design_forsim$prob, byrow=TRUE, ncol=2)

  ### Simulating the response by respondent i to question j
  # Simulated responses
  simulated_responses <- matrix(nrow=n_q, ncol=N)  # (n_q) x (N) matrix

  for(i in 1:nrow(prob_mat)){
    simulated_responses[i,] <- sample(1:n_alts, size=N, prob=prob_mat[i,], replace=TRUE)
  }
  write.csv(t(simulated_responses),file=output,row.names = FALSE)
  return(t(simulated_responses))
}

#Uncomment the following to simulate data
cbc_simulation(profiles_dummy,beta,"simulated_ql_data.csv")

###################### STATISTICAL ANALYSIS ################################

# If you have a CSV file including actual data, read it instead of the 
# simulated data file!

responses <- t(read.csv('simulated_ql_data.csv',header = TRUE,row.names = NULL))

# Data frame for analysis
mlogit_df <- data.frame(
  respID = rep(1:N, each=n_alts*n_q),
  qID = rep(rep(1:n_q, each=n_alts), N),
  altID = rep(1:n_alts, n_q*N),
  obsID = rep(1:(N*n_q), each=n_alts)
)

mlogit_df$profileID <- rep(design$profileID, N)

for(att in names(attrs)) {
  mlogit_df[,att] <- factor(rep(design[,att],N),levels=attrs[[att]])
}

# Formatting the response data
choice_data <- NULL
for (resp in 1:N) {
  for (q in 1:n_q) {
    choice <- responses[q, resp]
    choice_dummies <- rep(0,n_alts)
    choice_dummies[choice] <- 1
    choice_data <- c(choice_data, choice_dummies)
  }
}

mlogit_df$response <- choice_data

# Here the data frame has been made!

# Transforming the data frame to 'dfidx' format
cbc.mlogit <- dfidx(data=mlogit_df, 
                          choice="response",
                          shape="long",
                          idx = c("obsID","altID"),
                          idnames = c("chid","alt"))

# Fitting the model
fml <- as.formula(paste("response ~ 0 + ",paste(names(attrs),collapse=" + ")))

# Result for contr.treatment
options(contrasts = c("contr.treatment","contr.poly"))
cbc_treatment.ml <- mlogit(fml, data=cbc.mlogit)

# Result for contr.sum
options(contrasts = c("contr.sum","contr.poly"))
cbc_sum.ml <- mlogit(fml, data=cbc.mlogit)

# Print estimated coefficients
print(c(cbc_treatment.ml$coefficients))
print(c(cbc_sum.ml$coefficients))

#################### IMPORTANCE OF ATTRIBUTES ################################

estimated_utils <- c(cbc_sum.ml$coefficients)
eu_full <- NULL

abs_importance <- vector(length=length(attrs))
header <- 1
for(i in 1:length(attrs)) {
  # number of levels in this attribute
  no_levels <- length(attrs[[i]])
  # estimated utilities of levels in this attributes
  eu_this <- estimated_utils[header:(header+no_levels-2)]
  # utility of the final level appended
  eu_this_full <- c(eu_this,-sum(eu_this))
  names(eu_this_full) <- attrs[[i]]
  eu_full <- c(eu_full,eu_this_full)
  abs_importance[i] <- max(eu_this_full) - min(eu_this_full)
  header <- header + no_levels-1
}
importance <- abs_importance/sum(abs_importance)
names(importance) <- names(attrs)


###################### GRAPHICAL ANALYSIS #####################################
# Classical barplot
barplot(importance)
barplot(eu_full)

##################### GGPLOT (OPTIONAL) #######################################
# Importance
importance_df <- data.frame(
  feature = names(importance),
  value = as.numeric(importance)
)

# Sort
importance_df <- importance_df[order(-importance_df$value), ]
ggplot(importance_df, aes(x = feature, y = value)) +
  geom_bar(stat = "identity")+
  labs(
    title = "Feature Importance",
    x = "Feature",
    y = "Importance"
  ) +
  theme_bw()

# Utilities
eu_df <- data.frame(
  level = names(eu_full),
  value = as.numeric(eu_full)
)
eu_df$id <- as.factor(1:nrow(eu_df))
ggplot(eu_df, aes(x = id, y = value)) +
  geom_bar(stat = "identity")+
  labs(
    title = "Estimated utilities",
    x = "Level",
    y = "Utility"
  ) +
  scale_x_discrete(labels=eu_df$level)+
  theme_bw()


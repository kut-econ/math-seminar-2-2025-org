# RStudioセットアップ手引書
## 選択ベースコンジョイント分析セミナー向け

このガイドでは、選択ベースコンジョイント分析を行うためのR環境のセットアップ方法について説明します。お使いのOSに合わせた手順に従ってください。

## 目次
1. [セットアップ前の確認](#セットアップ前の確認)
2. [Windows 10/11ユーザー向けセットアップ](#windows-1011ユーザー向けセットアップ)
3. [Mac OSユーザー向けセットアップ](#mac-osユーザー向けセットアップ)
4. [必要なRパッケージのインストール](#必要なrパッケージのインストール)
5. [セットアップ確認方法](#セットアップ確認方法)
6. [トラブルシューティング](#トラブルシューティング)

## セットアップ前の確認

すでにR、RStudio、Rtools（Windowsのみ）をインストール済みの方は、以下の手順でバージョンを確認し、最新でない場合は更新をお勧めします。

### Rのバージョン確認方法
1. RStudioを起動する
2. コンソールに `R.version.string` と入力して実行
3. R version 4.3.0以上であることを確認（2025年4月現在の安定な最新版は4.4.3）

### RStudioのバージョン確認方法
1. RStudioを起動する
2. メニューの「Help」→「About RStudio」をクリック
3. Version 2023.03.0以上であることを確認(最新版は2024.12.1)

バージョンが古い場合や、まだインストールしていない場合は、以下の手順に従ってセットアップを行ってください。

## Windows 10/11ユーザー向けセットアップ

### 1. Rのインストール
1. [CRANのウェブサイト](https://cran.r-project.org/bin/windows/base/)にアクセス
2. 「Download R-4.4.3 for Windows」（または最新バージョン）をクリック
3. ダウンロードしたインストーラー（R-4.4.3-win.exe）を実行
4. インストールウィザードの指示に従い、デフォルト設定のままインストール

### 2. Rtoolsのインストール
Rtoolsは一部のRパッケージをインストールする際に必要となります。

1. [Rtoolsのダウンロードページ](https://cran.r-project.org/bin/windows/Rtools/)にアクセス
2. 「Rtools44 installer」（またはお使いのRバージョンに対応するもの）をクリック
3. ダウンロードしたインストーラー（rtools44-x86_64.exeなど）を実行
4. インストールウィザードの指示に従い、デフォルト設定のままインストール

### 3. RStudioのインストール
1. [RStudioのダウンロードページ](https://posit.co/download/rstudio-desktop/)にアクセス
2. 「DOWNLOAD RSTUDIO DESKTOP FOR WINDOWS」をクリック
3. ダウンロードしたインストーラーを実行
4. インストールウィザードの指示に従い、デフォルト設定のままインストール

## Mac OSユーザー向けセットアップ

### 1. Rのインストール
1. [CRANのウェブサイト](https://cran.r-project.org/bin/macosx/)にアクセス
2. Intel Macの場合: 「R-4.4.3-x86_64.pkg」（または最新バージョン）をクリック
   Apple Silicon（M1/M2）Macの場合: 「R-4.4.3-arm64.pkg」をクリック
3. ダウンロードしたインストーラーを実行
4. インストールウィザードの指示に従いインストール

Intel MacかApple Siliconか分からない場合はAppleメニューの「このMacについて」で調べてください。

### 2. RStudioのインストール
1. [RStudioのダウンロードページ](https://posit.co/download/rstudio-desktop/)にアクセス
2. 「DOWNLOAD RSTUDIO DESKTOP FOR macOS」をクリック
3. ダウンロードしたインストーラー（.dmg）を開き、RStudioアプリケーションをApplicationsフォルダにドラッグ

### 注意事項（Mac OSのみ）
* macOS 10.15 Catalina以降を使用している場合、インストーラーを実行する際にセキュリティ警告が表示されることがあります。「システム環境設定」→「セキュリティとプライバシー」で「このまま開く」を選択してください。
* Apple Silicon（M1/M2）Macを使用している場合、Rosettaのインストールを求められることがあります。その場合は指示に従ってインストールしてください。

## 必要なRパッケージのインストール

セミナーでは以下のパッケージを使用します。

- cbcTools
- makedummies
- mlogit
- ggplot2

このうち、`cbcTools`は現在CRANから削除されており、`install.packages`ではインストールできない状況となっています(2025/4/27現在)。したがって、それ以外のパッケージをまず`install.packages`でインストールしてください（下記参照）。

RStudioを起動し、以下のコマンドをコンソールに貼り付けて実行してください。

```r
# 必要なパッケージをインストール
install.packages(c("makedummies", "mlogit", "ggplot2"))
```

### 個別インストール方法（上記の一括インストールでエラーが出た場合）

```r
# 個別にインストール
install.packages("makedummies")
install.packages("mlogit")
install.packages("ggplot2")
```

なおパッケージインストールの際に「どのサイトからインストールするか」を聞かれる場合がありますが、日本のサイトを選んでおけば通常間違いありません。

### cbcToolsのgithubからのインストール

cbcToolsはgithubからインストールできます。そのために、まず`remotes`パッケージをインストールしてください。

```r
install.packages("remotes")
```

次に、`remotes`パッケージを使って次のように`cbcTools`をgithubからインストールしてください。

```r
remotes::install_github("jhelvy/cbcTools")
```

## セットアップ確認方法

環境が正しくセットアップされたかを確認するため、以下のコマンドをRStudioのコンソールに入力して実行してください。エラーが表示されなければセットアップ完了です。

```r
# パッケージの読み込み確認
library(cbcTools)
library(makedummies)
library(mlogit)
library(ggplot2)

# バージョン確認
packageVersion("cbcTools")
packageVersion("makedummies")
packageVersion("mlogit")
packageVersion("ggplot2")

# 簡単なプロットで動作確認
ggplot(data.frame(x = 1:10, y = 1:10), aes(x, y)) + geom_point()
```

## トラブルシューティング

### パッケージのインストールエラー

#### Windows環境での一般的な問題と解決策

1. **Rtoolsがインストールされていない場合**
   ```
   エラー: 'tools::.install_package()' に見つからない依存パッケージがあります 
   ```
   解決策: 上記のRtoolsインストール手順に従ってRtoolsをインストールしてください。

2. **管理者権限が必要な場合**
   ```
   エラー: インストールに失敗しました。アクセスが拒否されました
   ```
   解決策: RStudioを右クリックして「管理者として実行」を選択し、再度インストールを試みてください。

#### Mac環境での一般的な問題と解決策

1. **Xcodeコマンドラインツールがない場合**
   ```
   エラー: コンパイラの実行可能ファイルが見つかりません
   ```
   解決策: ターミナルを開き、以下のコマンドを実行してXcodeコマンドラインツールをインストール
   ```
   xcode-select --install
   ```

2. **パーミッションエラー**
   ```
   エラー: パッケージをインストールする権限がありません
   ```
   解決策: RStudioを閉じ、再度開くか、以下のコマンドで個人用ライブラリパスを作成
   ```r
   dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE)
   ```

### その他の問題

セットアップ中に問題が発生した場合は、以下の情報を含めて担当教員に連絡してください：
1. お使いのOS情報とバージョン
2. 表示されたエラーメッセージの全文
3. 実行したコマンド

---

本手引書に関する質問やフィードバックは、セミナー担当教員までお寄せください。

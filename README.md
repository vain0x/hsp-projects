# HsedBackup
## 概要
HSPスクリプトエディタ (hsed3) の作業中のデータを自動でバックアップします。

* 30秒ごとに、未保存のタブに書かれているデータを、バックアップ用ファイルに保存します。
* バックアップは、HsedBackup/_bak フォルダの下に、各ファイルごとのフォルダが作成され、その下にバックアップファイルが作成されます。ファイルの名前は日時となります。
* 最新のバックアップと同じ内容だったら、保存されません。
* バックアップファイルは、1つの編集ファイルごとに30個までです。31個目を作成するたび、古い16個を削除します。

## スタートアップ
スクリプトエディタを開くと同時に、HsedBackup が自動的に起動されるようにできます。

* スクリプトエディタのメニューバーから、「ツール」→「オプション」をクリック。
* 出てきたウィンドウの左側(ツリービュー)の「外部ツール」をクリック。
* 「追加」ボタンを押して次のように入力すればOK。
  * 「ファイルパス」には HsedBackup.exe のパスを入力。

![](doc/startup_registration.jpg)

* スクリプトエディタの終了後、HsedBackup も自動的に終了します。

## リンク
* HSPTV! <http://hsp.tv>
  * HSP3の公式サイト
* HSED3Backup! <http://www.vector.co.jp/soft/dl/winnt/prog/se488981.html>
  * 類似ツール

# autohs
## 概要
HSP3スクリプトを元に、簡単に hs ファイルを作成します。
リファレンスを作る上での機械的作業は、これに任せてしまいましょう！

※当然ですが、説明などは人間が書く必要があります。

## 使い方
### コマンドライン
```
	autohs "input-filename" "output-filename"
```

* input-filename: 入力元のファイル名
* output-filename: 出力先のファイル名
  * 省略時は、input-filename の拡張子を .hs に変えたもの。

#### ドラッグ＆ドロップ
autohs.exe に、hs を作りたいファイルをドロップすると、そのファイルの拡張子が .hs になった名前で出力されます。

### 対応する定義
* #define
* #deffunc, #defcfunc
* #modfunc, #modcfunc
* #func, #cfunc

### 埋め込みドキュメント情報
コメント内部に埋め込まれたファイル自身のデータを自動的に処理する機能を、埋め込みドキュメント情報とよびます。

例:
```hsp
/**+
 * @name   : mod_hogehoge
 * @author : Mr.author man II
 * @date   : 2009 08/29 (Sat) -- 作成
 * @       : 2009 09/02 (Tue) -- 修整
 * @version: 1.02δ
 * @type   : アプリケーション補佐命令
 * @group  : 
 * @note   : #include "mod_hogehoge.as" が必要です。
 * @url    : http://website.hogehoge.net/ (※無効なURL)
 * @port
 * @  Win
 * @  Cli
 * @  Let
 **/
```

埋め込みドキュメント情報は、「/**+」と改行から始まる複数行コメントのなかに書きます。

埋め込みドキュメント情報は各行に1つずつ指定します。省略することも可能です。

* ``@識別子 [:] 情報``

まず、`*` が必要です。その後ろにある「@識別子」で、情報の種類を選択します。

```
@name     : モジュールの名称
@author   : 著作者名
@date     : 日付
@version  : バージョン番号
@type     : ユーザ定義命令・関数
@group    : 命令、関数の種類の既定値
@note     : 備考や注意書き
@url      : 関連するWebページへの url
@port     : 対応環境。
@         : Win := Windows版 HSP
@         : Mac := Macintosh版 HSP
@         : Cli := コンソール版 HSP
@         : Let := HSP Let
@portinfo : プラットホーム間の移植のヒント
```

この後には、いくつかの空白文字をおき (途中に一回だけ : が置けます)、それ以降・行末までの文字列を「情報」として扱います。ただし、「情報」の部分が空になっている場合で、かつ途中に : がない限り、その行は無視されます。

一つのファイル内に、同じ種類のドキュメント情報が複数ある場合は、それらをすべてを複数行にして連結します (順番は、書かれているものと同じ)。
`@` の次の識別子を省略した場合、その直前に指定された種類と同じだと解釈します。

これにより取得された情報は、.hs ファイルのヘッダ( 基本情報 )になります。

## 参照
* プログラ広場
  <http://prograpark.ninja-web.net/>
  最新版の入手はここの「ソフト・モジュールのたまり場」で、
  ご意見、ご要望、バグ報告、質問などは、ここの「掲示板」へお願いします。

* HSP本家サイト
  <http://hsp.tv/>

Copyright(C) 2009 uedai.

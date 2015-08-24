// deflister - header

#ifndef __DEFINED_LISTER_HEADER_AS__
#define __DEFINED_LISTER_HEADER_AS__

#include "Mo/MCLongString.as"
#include "Mo/strutil.as"
#include "Mo/easyhash.as"
#include "Mo/hsedutil.as"
#include "Mo/SearchFileEx.as"
#include "MCDeflist.as"

// Win32 API
#uselib "user32.dll"
#func   global SetWindowLong  "SetWindowLongA" int,int,int
#cfunc  global GetWindowLong  "GetWindowLongA" int,int
#func   global MoveWindow     "MoveWindow"     int,int,int,int,int,int
#func   global PostMessage    "PostMessageA"   int,int,int,sptr
#func   global SetScrollInfo  "SetScrollInfo"  int,int,int,int
#cfunc  global LoadCursor     "LoadCursorA"    nullptr,int
#func   global SetClassLong   "SetClassLongA"  int,int,int
#func   global SetCursor      "SetCursor"      int
#func   global ClipCursor     "ClipCursor"     int
#func   global EnableWindow   "EnableWindow"   int,int
#func   global GetClientRect  "GetClientRect"  int,int

#func   global SetForegroundWindow   "SetForegroundWindow"    int
#cfunc  global RegisterWindowMessage "RegisterWindowMessageA" sptr

#uselib "kernel32.dll"
#func   global GetFullPathNameA "GetFullPathNameA" sptr,int,int,nullptr
#define global GetFullPathName(%1,%2) GetFullPathNameA %1, MAX_PATH, varptr(%2)

//##################################################################################################
//        定数・マクロ
//##################################################################################################
// Window ID
#const IDW_MAIN 0

// Userdefined Window-Message
#const UWM_SPLITTERMOVE 0x0400

// その他
#define global HSED_TEMPFILE (ownpath +"\\"+ HSED_TEMPFILENAME)
#define global HSED_TEMPFILENAME "hsedtmp.hsp"

#define STR_INIPATH (dir_exe2 +"\\deflister.ini")

#undef SetStyle
#undef ChangeVisible
#define global SetStyle(%1,%2=-16,%3=0,%4=0) SetWindowLong (%1),(%2),bit_sub(GetWindowLong((%1),(%2)) | (%3), (%4))
#define global ChangeVisible(%1=hwnd,%2=1) SetStyle (%1), -16, 0x10000000 * (%2), 0x10000000 * ((%2) == 0)// Visible 切り替え

//##################################################################################################
//        モジュール
//##################################################################################################
#module deflister_mod

#include "Mo/ctype.as"

#define true  1
#define false 0

//------------------------------------------------
// 各行の先頭に行番号を埋め込む
//------------------------------------------------
#deffunc SetLinenum var retbuf, str p2, str sform, int start, local text, local tmpbuf, local index, local stmp
	LongStr_new tmpbuf
	text  = p2
	index = 0
	
	sdim stmp, 320
	
	repeat , start
		// 次の一行を取得
		getstr stmp, text, index : index += strsize
		
		if ( strsize == 0 ) { break }
		
		// 書き込む
		LongStr_cat tmpbuf, strf(sform, cnt) + stmp +"\n"
	loop
	
	LongStr_tobuf  tmpbuf, retbuf
	LongStr_delete tmpbuf
	return
	
//------------------------------------------------
// 検索パスを追加する
//------------------------------------------------
#deffunc AppendSearchPath str p1, local path, local c, local len
	sdim path, MAX_PATH
	path = p1
	len  = strlen(path)
	if ( len == 0 ) { return }
	
	c    = peek(path, len - 1)
	if ( c == '/' ) { len -- }
	if ( c != '\\') { wpoke path, len, '\\' : len ++ }
	if ( instr(searchpath, 0, path + ";") < 0 ) {
		searchpath += path + ";"
	}
	return
	
//------------------------------------------------
// 定義リストを再帰的に作成する
//------------------------------------------------
#deffunc CreateDefinitionList array mdeflist, array listIncludeToLoad, int bFirstCall, local listInclude, local filename, local index, local bListed
	
	// 初回の場合、ハッシュ値の配列を削除
	if ( bFirstCall ) {
		dim mdeflist
		dim hashListed, 32
		cntList = 0
	}
	
	foreach listIncludeToLoad
		
		// 次のファイルのフルパスを取得
		if ( peek(listIncludeToLoad(cnt), 1) != ':' ) {		// "x:\\..." なら既にフルパス
			
			SearchFileEx searchpath, listIncludeToLoad(cnt)
			if ( refstr == "" ) { continue }
			listIncludeToLoad(cnt) = refstr
			AppendSearchPath getpath(refstr, 32)	// 逐一検索パスを拡張していく
		}
		
		// ファイル名のみを取得しておく
		filename = getpath(listIncludeToLoad(cnt), 8)
		
;		// 既に開かれているファイルなら無視
;		if ( bFirstCall == false ) {
;			bListed = false
;			foreach mdeflist
;				if ( deflist_GetFileName( mdeflist(cnt) ) == filename ) {
;					bListed = true
;					break
;				}
;			loop
;			if ( bListed ) { continue }
;		}
		
;		exist listIncludeToLoad(cnt)
;		if ( strsize < 0 ) { continue }
		
		// 既に開かれているファイルは無視
		bListed = false
		hash    = EasyHash( listIncludeToLoad(cnt) )		// フルパス
		if ( bFirstCall == false ) {
			repeat cntList
				if ( hashListed(cnt) == hash ) {
					// 念のためファイルパスでも比較する
					if ( deflist_GetFileName( mdeflist(cnt) ) == filename ) {
						bListed = true
						break
					}
				}
			loop
			if ( bListed ) { continue }	// 定義済みなので無視する
		}
		
		// 開いたリストに追加
		if ( bListed == false ) {
			hashListed(cntList) = hash
			cntList ++
		}
		
		// 定義リストを作成する
		deflist_new mdeflist, listIncludeToLoad(cnt)
		index = stat
		
		// 再帰的に結合されたファイルから定義を取り出す
		if ( deflist_getCntInclude( mdeflist(index) ) ) {
			deflist_getIncludeArray mdeflist(index), listInclude		// #iclude 指示されたファイルのリストを得る
			CreateDefinitionList    mdeflist,        listInclude, false
		}
		
	loop
	
	return
	
//------------------------------------------------
// ウィンドウを単一方向にスクロールする
// 
// @ direction = SB_HORZ(=0) or SB_VERT(=1)
//------------------------------------------------
#deffunc ScrollWindow int handle, int direction, int nPos
	dim scrollinfo, 8
	scrollinfo = 32, 0x04, 0, 0, 0, nPos
	SetScrollInfo handle, direction, varptr(scrollinfo), true
	sendmsg       handle, 0x0114 + direction, MAKELONG(4, nPos), handle
	return
	
	
#if 0

//------------------------------------------------
// 周辺の三行を取り出す
//------------------------------------------------
#deffunc TookArline3 var bufArline3, str p2, int linenum, local text, local index, local stmp, local tmpbuf
	newmod tmpbuf, MCLongStr
	text  = p2
	index = 0
	
	sdim stmp, 1200
	sdim bufArline3, 256
	
	if ( linenum == 0 ) { LongStr_cat tmpbuf, "\n" }
	
	repeat
		// 次の一行を取り出す
		getstr stmp, text, index : index += strsize
		
		if ( strsize == 0 ) {
			break
		}
		
		if ( numrg(cnt, linenum - 1, linenum + 1) ) {
			LongStr_cat tmpbuf, stmp +"\n"
			count ++
			if ( count == 3 ) { break }
		}
		
	loop
	
	if ( count < 3 ) {
		repeat 3 - count
			LongStr_cat tmpbuf, "\n"
			count ++
		loop
	}
	
	LongStr_tobuf tmpbuf, bufArline3
	
	return
#endif

#global
sdim searchpath@deflister_mod, MAX_PATH * 3

#endif

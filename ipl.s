; pos
; TAB=4

CYLS	EQU		10
	ORG		0x7c00

; FAT12フォーマット

	JMP		entry
	DB		0x90
	DB		"HELLOIPL"		; ブートセクタ名
	DW		512				; 1セクタの大きさ
	DB		1				; クラスタの大きさ(1セクタ)
	DW		1				; FATの開始位置
	DB		2				; FATの個数
	DW		224				; ルートディレクトリ領域の大きさ
	DW		2880			; ドライブの大きさ(2880セクタ)
	DB		0xf0			; メディアのタイプ
	DW		9				; FAT領域の長さ(9セクタ)
	DW		18				; 1トラックのセクタ数
	DW		2				; ヘッドの数
	DD		0
	DD		2880			; ドライブの大きさを再記述
	DB		0,0,0x29
	DD		0xffffffff
	DB		"POS        "	; ディスクの名前(11bytes)
	DB		"FAT12   "		; フォーマットの名前(8bytes)
	RESB	18

; プログラム本体
entry:
	MOV		AX,0			; レジスタの初期化
	MOV		SS,AX
	MOV		SP,0x7c00
	MOV		DS,AX
	MOV		ES,AX

; ディスク読み込み

	MOV		AX,0x0820
	MOV		ES,AX
	MOV		CH,0			; シリンダ0
	MOV		DH,0			; ヘッド0
	MOV		CL,2			; セクタ2

readloop:
	MOV		SI,0			; 失敗回数カウンタ

retry:
	MOV		AH,0x02			; AH=0x02 : ディスク読み込み
	MOV		AL,1			; 1セクタ
	MOV		BX,0
	MOV		DL,0x00			; Aドライブ
	INT		0x13			; ディスクBIOS呼び出し
	JNC		next			; エラーが起きなければ次
	ADD		SI,1
	CMP		SI,5			; SIと5を比較
	JAE		error
	MOV		AH,0x00
	MOV		DL,0x00
	INT		0x13			; ドライブリセット
	JMP		retry

next
	MOV		AX,ES			; アドレスを0x200進める
	ADD		AX,0x0020
	MOV		ES,AX
	ADD		CL,1
	CMP		CL,18
	JBE		readloop
	MOV		CL,1
	ADD		DH,1
	CMP		DH,2
	JB		readloop
	MOV		DH,0
	ADD		CH,1
	CMP		CH,CYLS
	JB		readloop

fin:
	HLT
	JMP		fin

error:
	MOV		AX,0
	MOV		ES,AX
	MOV		SI,msg

putloop:
	MOV		AL,[SI]
	ADD		SI,1
	CMP		AL,0
	JE		fin
	MOV		AH,0x0e			; 1文字表示
	MOV		BX,15			; カラーコード
	INT		0x10			; ビデオBIOSの呼び出し
	JMP		putloop

msg:
	DB		0x0a, 0x0a		; 改行
	DB		"load error"
	DB		0x0a
	DB		0

	RESB	0x7dfe-$

	DB		0x55, 0xaa

; pos
; TAB=4

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

fin:
	HLT
	JMP		fin

msg:
	DB		0x0a, 0x0a		; 改行
	DB		"hello, world"
	DB		0x0a
	DB		0

	RESB	0x7dfe-$

	DB		0x55, 0xaa

*
*	Input.asm of PCQ Pascal
*
*	This file just defines the Input file variable.
*

	XDEF	_Input

	SECTION	PCQ_DATA,DATA

_Input	dc.l	0	; Handle
	dc.l	0	; Next
	dc.l	InBuff	; Buffer
	dc.l	InBuff	; Current
	dc.l	InBuff	; Last
	dc.l	InBuff+80	; Max
	dc.l	1	; RecSize
	dc.b	0	; Interactive
	dc.b	0	; EOF
	dc.w	1005	; ModeOldFile

	SECTION	PCQ_BSS,BSS

InBuff	ds.b	80

	END


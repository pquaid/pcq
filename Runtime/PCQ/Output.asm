*
*	Output.asm of PCQ Pascal
*
*	This file just defines the Output file variable.
*

	XDEF	_Output

	SECTION	PCQ_DATA,DATA

_Output	dc.l	0	; Handle
	dc.l	0	; Next
	dc.l	OutBuff	; Buffer
	dc.l	OutBuff	; Current
	dc.l	OutBuff	; Last
	dc.l	OutBuff+80	; Max
	dc.l	1	; RecSize
	dc.b	0	; Interactive
	dc.b	0	; EOF
	dc.w	1006	; ModeNewFile

	SECTION	PCQ_BSS,BSS

OutBuff	ds.b	80

	END


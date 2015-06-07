
*	WriteLn.asm (of PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid

*	Just write a line feed to a text file.

*	On Entry, the top of the stack holds the file rec address

	XREF	_p%WriteText
	XREF	_p%IOResult

	SECTION	PCQ_Runtime,CODE

	XDEF	_p%WriteLn
_p%WriteLn

	tst.l	_p%IOResult	; just to be sure....
	bne.s	1$
	move.l	4(sp),a0
	lea	eoln(pc),a1
	moveq.l	#1,d3		; set up for call
	jsr	_p%WriteText	; write it
1$	rts

eoln	dc.b	10,0

	END


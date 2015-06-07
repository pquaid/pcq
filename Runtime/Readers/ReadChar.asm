
*	ReadChar.asm (of PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid

*	This reads one character from a text file.

	INCLUDE	"/FileRec.i"

	SECTION	PCQ_Runtime,CODE

	XREF	_p%ReadOneChar
	XREF	_p%GetThatChar
	XREF	_p%IOResult

*	Upon entry we expect a0 to hold the variable address, and
*	the top of the stack should be the file record address.

	XDEF	_p%ReadChar
_p%ReadChar
	tst.l	_p%IOResult		; is IO OK?
	bne.s	1$
	move.l	a0,-(sp)		; save the variable address
	move.l	8(sp),a0		; get the file record address
	jsr	_p%ReadOneChar		; read a character
	jsr	_p%GetThatChar		; eat it
	move.l	(sp)+,a0		; restore var address
	move.b	d0,(a0)			; save the character
1$	rts

	END


*	ReadLn.asm (of PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid

*	Implements readln....

*	Algorithm:
*
*	repeat
*	    c := the current character
*	    eat that character
*	until c = linefeed or EOF
*

*	Upon entry, the top of the stack has the file rec address

	INCLUDE	"/FileRec.i"

	SECTION	PCQ_Runtime,CODE

	XREF	_p%ReadOneChar
	XREF	_p%GetThatChar
	XREF	_p%IOResult

	XDEF	_p%ReadLn
_p%ReadLn

	tst.l	_p%IOResult		; is IO system intact?
	bne.s	2$
	move.l	4(sp),a0		; get the file record
1$	tst.b	EOF(a0)			; are we at EOF?
	bne.s	2$			; if so, leave
	jsr	_p%ReadOneChar		; get the character
	move.w	d0,-(sp)		; save it
	jsr	_p%GetThatChar		; eat it
	move.w	(sp)+,d0		; get it back
	tst.l	_p%IOResult		; test IO integrity
	bne.s	2$
	cmp.b	#10,d0			; is it a linefeed?
	bne	1$			; if not, loop
2$	rts

	END


*	WritePad.asm (of PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid

*	This routine just puts out spaces to a file.

*	Upon entry, this routine expects the file record in a0 and
*	the number of spaces to write in d0.  a0 is preserved.

	INCLUDE	"/FileRec.i"

	XREF	_p%FlushBuffer
	XREF	_p%IOResult

	XDEF	_p%PadOut
_p%PadOut
	tst.l	_p%IOResult		; is IOResult OK?
	bne	3$			; if not, leave now
	subq.l	#1,d0			; for the loop below
	move.l	CURRENT(a0),a1		; get the current pointer
1$	move.b	#' ',(a1)+		; put a space into the buffer
	cmpa.l	MAX(a0),a1		; are we at end?
	bne.s	2$			; if not, skip this
	move.l	a1,CURRENT(a0)		; save pointer
	move.l	d0,-(sp)		; save count
	jsr	_p%FlushBuffer		; write out the buffer
	move.l	(sp)+,d0		; retreive count
	move.l	CURRENT(a0),a1		; get current pointer back
2$	dbra	d0,1$			; loop
	move.l	a1,CURRENT(a0)		; set pointer
3$	rts

	END

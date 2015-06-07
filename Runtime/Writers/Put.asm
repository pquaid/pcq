
*
*	Put.asm (of the PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid
*
*	This routine just advances the file ptr one record.  Presumably
*	the user has put something into the buffer using FileVar^, and
*	wants to get to the next one.
*
*	On entry, this routine wants a0 to point to the file record
*

	SECTION	PCQ_Runtime,CODE

	INCLUDE	"/FileRec.i"

	XREF	_p%FlushBuffer
	XREF	_p%IOResult

	XDEF	_p%Put
_p%Put
	tst.l	_p%IOResult		; is IO system OK?
	bne.s	1$			; if not, don't do anything
	move.l	CURRENT(a0),a1		; get the current position
	adda.l	RECSIZE(a0),a1		; add one record size
	move.l	a1,CURRENT(a0)		; save new position
	cmpa.l	MAX(a0),a1		; is the buffer full?
	blt.s	1$			; if not, skip
	jsr	_p%FlushBuffer		; write the whole buffer
1$	rts				; return to the program

	END

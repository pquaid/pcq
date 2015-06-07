*
*	FilePtr.asm (of the PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid
*
*	This routine is called whenever a file pointer is used in
*	the main program.  One might expect that we could simply
*	refer to the CURRENT pointer in the file structure, but
*	if the file is INTERACTIVE (which would not be known until
*	runtime), we might have to do a read first.
*
*	On entry, a0 holds the address of the file record
*

	INCLUDE	"/FileRec.i"

	XREF	_p%FillBuffer
	XREF	_p%IOResult

	SECTION	PCQ_Runtime,CODE

	XDEF	_p%FilePtr
_p%FilePtr

	tst.l	_p%IOResult		; is IO system OK?
	bne	1$
	tst.b	INTERACTIVE(a0)		; if not interactive, never mind
	beq.s	1$			; leave now
	move.l	CURRENT(a0),a1		; get the current position
	cmpa.l	LAST(a0),a1		; are we at end?
	blt.s	1$			; if not empty, skip
	jsr	_p%FillBuffer		; otherwise, fill buffer
1$	move.l	CURRENT(a0),a0		; get the current ptr
	rts				; and return

	END

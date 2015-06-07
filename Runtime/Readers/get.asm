*
*	Get.asm (of the PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid
*
*	This routine is much the same as ReadArb, but just moves
*	the file pointer rather than reading anything.
*
*
*	On entry this routine expects a0 to hold the address of the
*	file record
*

	INCLUDE	"/FileRec.i"

	SECTION	PCQ_Runtime,CODE

	XREF	_p%FillBuffer
	XREF	_p%IOResult

	XDEF	_p%Get
_p%Get
	tst.l	_p%IOResult		; is IO system OK?
	bne	1$
	tst.b	EOF(a0)			; are we at EOF?
	bne.s	1$			; if so, leave
	move.l	CURRENT(a0),a1		; get the current ptr
	adda.l	RECSIZE(a0),a1		; add one record
	move.l	a1,CURRENT(a0)		; save the new ptr
	cmpa.l	LAST(a0),a1		; is it past end?
	blt.s	1$			; if not, skip the read
	jsr	_p%FillBuffer		; read a new buffer-full
1$	rts				; return

	END

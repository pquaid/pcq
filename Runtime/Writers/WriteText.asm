*
*	WriteText.asm (of the PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid
*

*	Writes some bytes to a file record's buffer, flushing the
*	buffer if necessary.

*	On entry, a0 holds the address of the file record
*		  a1 holds the address of the bytes to write
*		  d3 holds the number of bytes to write

	INCLUDE	"/FileRec.i"

	XREF	_p%FlushBuffer
	XREF	_p%IOResult

	SECTION	PCQ_Runtime,CODE

	XDEF	_p%WriteText
_p%WriteText

	tst.l	_p%IOResult		; is IO system OK?
	bne	Leave			; if not, go
	tst.l	d3
	beq	Leave			; if nothing to write, leave
	move.l	BUFFER(a0),d0		; check actual buffer
	bne.s	4$			; if allocated, it's OK
	move.l	#56,_p%IOResult		; set Output not open
	rts				; split
4$	subq.l	#1,d3			; for dbra below
	move.l	a2,-(sp)		; save a2
	move.l	CURRENT(a0),a2		; get current position
1$	move.b	(a1)+,d0		; get byte
	move.b	d0,(a2)+		; write into buffer
	cmpa.l	MAX(a0),a2		; are we at MAX ?
	blt.s	2$			; if not, skip
	move.l	a2,CURRENT(a0)		; save new current pointer
	movem.l	a1/d3,-(sp)		; save regs for call
	jsr	_p%FlushBuffer		; write buffer contents
	movem.l	(sp)+,a1/d3		; restore regs
	tst.l	_p%IOResult		; were there errors?
	bne.s	3$			; if so, leave this loop
	move.l	CURRENT(a0),a2		; get new CURRENT ptr
2$	dbra	d3,1$			; loop
	move.l	a2,CURRENT(a0)		; save correct value
	tst.b	INTERACTIVE(a0)		; is it interactive?
	beq.s	3$			; if not, skip
	jsr	_p%FlushBuffer		; if so, flush it immediately
3$	move.l	(sp)+,a2
Leave	rts

	END

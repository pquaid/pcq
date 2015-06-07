
*	ReadArb.asm (of PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid

*	This routine copies memory from the file buffer into the
*	variable's memory space.
*
*	Upon entry, this routine expects a0 to hold the address of
*	the variable.  The top of the stack should be the address
*	of the file record.

*	Alogrithm for ReadArb:
*
*	if IOResult <> 0 then
*	    return
*	if EOF then
*	    set IOResult
*	    return
*	if Interactive then
*	    if Current >= Last then
*		FillBuffer
*		if EOF then
*		    set IOResult
*		    return
*	copy RecSize bytes from Current to VarAddress
*	CURRENT := CURRENT + RECSIZE
*	if not INTERACTIVE then
*	    if CURRENT >= LAST then
*		FillBuffer
*

	INCLUDE	"/FileRec.i"

	SECTION	PCQ_Runtime,CODE

	XREF	_p%FillBuffer
	XREF	_p%IOResult

	XDEF	_p%ReadArb
_p%ReadArb

	tst.l	_p%IOResult		; is IO OK?
	bne	4$			; if not, skip everything
	move.l	4(sp),a1		; get file record
	tst.b	EOF(a1)			; are we at EOF?
	beq.s	1$			; if not, skip
	rts
1$	tst.b	INTERACTIVE(a1)		; is it interactive?
	beq.s	2$			; if not, skip this bit
	move.l	CURRENT(a1),d0		; get current address
	cmp.l	LAST(a1),d0		; are we empty?
	blt.s	2$			; if not, skip
	move.l	a0,-(sp)		; save var address
	move.l	a1,a0			; set up for the call
	jsr	_p%FillBuffer		; fill the buffer
	move.l	(sp)+,a0		; restore the address
	move.l	4(sp),a1		; get file record back
	tst.b	EOF(a1)			; are we at EOF?
	beq.s	2$			; if not, go on
	rts				; return since EOF
2$	move.l	RECSIZE(a1),d0		; number of bytes to copy
	subq.l	#1,d0
	move.l	CURRENT(a1),a1		; get current address
3$	move.b	(a1)+,d1		; get byte
	move.b	d1,(a0)+		; copy byte
	dbra	d0,3$			; loop
	move.l	4(sp),a0		; get file record
	move.l	a1,CURRENT(a0)		; set current to proper value
	cmp.l	LAST(a0),a1		; end of buffer ?
	blt.s	4$			; if not, skip
	jsr	_p%FillBuffer		; otherwise fill the buffer
4$	rts

	END

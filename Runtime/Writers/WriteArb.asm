
*	WriteArb.asm (of PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid

*	This just writes some type to a file of that type

	INCLUDE	"/FileRec.i"

	SECTION	PCQ_Runtime,CODE

	XREF	_p%FlushBuffer
	XREF	_p%IOResult

*	Upon entry to this routine, d3 holds the size of the data to write.
*	If that size is 1, 2 or 4 d0 holds the data itself.  Otherwise d0
*	holds the address of the data.  The file record address is on top
*	of the stack.

	XDEF	_p%WriteArb
_p%WriteArb

	tst.l	_p%IOResult	; is IO in good shape?
	bne	9$		; if not, leave

	subq.w	#4,sp		; make room for buffer

	move.l	d0,a1		; set up as if > 4 or = 3
	cmp.l	#4,d3		; is size > 4 ?
	bgt.s	5$		; if so, go to write

1$	cmp.l	#3,d3		; if its three, do the same
	beq.s	5$		;

2$	move.l	sp,a1		; set up for all the others
	cmp.l	#1,d3		; is it a byte?
	bne.s	3$		; if not 1 then go around
	move.b	d0,(sp)		; move it into outbuffer
	bra.s	5$		; go write

3$	cmp.l	#2,d3		; is it two?
	bne.s	4$		; go around
	move.w	d0,(sp)		; store it
	bra.s	5$

4$	move.l	d0,(sp)		; store it if it's 4

5$	move.l	a2,-(sp)	; save a2 for now
	move.l	12(sp),a0	; get the file record address
	move.l	CURRENT(a0),a2	; get the current position
	subq.l	#1,d3		; set up for dbra loop
6$	move.b	(a1)+,(a2)+	; copy a byte
	cmpa.l	MAX(a0),a2	; are we at end?
	blt.s	7$		; if not, skip this
	move.l	a2,CURRENT(a0)	; save ptr
	movem.l	a1/d3,-(sp)	; save pointers
	jsr	_p%FlushBuffer	; write the buffer
	movem.l	(sp)+,a1/d3	; restore the regs
	tst.l	_p%IOResult	; did it go OK?
	bne	8$
	move.l	CURRENT(a0),a2	; and retrieve the current ptr
7$	dbra	d3,6$
	move.l	a2,CURRENT(a0)	; save final value
	tst.b	INTERACTIVE(a0)	; is the file interactive?
	beq.s	8$		; if not, skip this
	jsr	_p%FlushBuffer	; flush it every time
8$	move.l	(sp)+,a2
	addq.w	#4,sp		; remove buffer area
9$	rts

	END


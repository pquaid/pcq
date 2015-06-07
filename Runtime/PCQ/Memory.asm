
*	Memory.asm (of PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid

*	This file takes care of new() and dispose().  Note that new()
*	uses AllocRemember() so we can keep track of our allocations.
*	Dispose must, therefore, remove the deallocated node from our
*	allocation list.  That's why it's a lot more complex than new()

	SECTION	Memory

	XREF	_p%IntuitionBase
	XREF	_LVOAllocRemember
	XREF	_AbsExecBase
	XREF	_LVOFreeMem
	XREF	_p%ExitWithAddr

	XREF	newkey
	XREF	_HeapError

	XDEF	_p%new
_p%new
	move.l	d0,-(sp)	; save the amount requested
_tryit
	move.l	#$00010001,d1
	lea	newkey,a0
	move.l	_p%IntuitionBase,a6
	jsr	_LVOAllocRemember(a6)
	tst.l	d0
	bne.s	3$		; if we got the mem, return
	move.l	_HeapError,a0	; otherwise, call HeapError
	move.l	a0,d1		; set flags
	beq	1$		; if not heaperror, return
	jsr	(a0)
	tst.l	d0		; test return value
	bne.s	2$		; if it's zero...
1$
	move.l	#54,d0		; we get the runtime error
	add.w	#4,sp		; clear up stack
	jsr	_p%ExitWithAddr
	bra	3$
2$
	subq.l	#1,d0		; if it 1?
	bne.s	4$		; if not, go around
	moveq	#0,d0		; return Nil
3$
	addq.w	#4,sp
	rts
4$
	subq.l	#1,d0		; is it 2? (last valid choice)
	bne.s	1$		; if not, bomb on runtime error
	bra	_tryit		; otherwise, try again


	XDEF	_p%dispose
_p%dispose

	lea	newkey,a1	; trailer
	move.l	newkey,a0	; get first remember key
	cmp.l	#0,a0		; set flags
	beq.s	2$		; if it's zero, leave
1$	cmp.l	8(a0),d0	; is it the right one?
	beq.s	3$		; if so, leave
	move.l	a0,a1		; if not, move current to trailer
	move.l	(a0),a0		; and get next record
	cmp.l	#0,a0		; set flags
	bne	1$		; if it's not zero, keep going
2$	rts			; no such memory exists, so leave
3$	move.l	a0,-(sp)	; free the memory.  First, save pointer
	move.l	(a0),a2		; get next pointer
	move.l	a2,(a1)		; save it in previous (link)

	move.l	8(a0),a1	; get address of block
	move.l	4(a0),d0	; and size
	move.l	_AbsExecBase,a6
	jsr	_LVOFreeMem(a6)	; free the memory block

	move.l	(sp)+,a1	; get the pointer back
	move.l	#12,d0		; it's this long
	move.l	_AbsExecBase,a6
	jsr	_LVOFreeMem(a6)	; free the remember block

	rts			; return

	END

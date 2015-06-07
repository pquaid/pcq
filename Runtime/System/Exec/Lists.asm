*
*	Lists.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	This has the glue routines for the procs and funcs defined in
*	Include/Exec/Lists.i.  This includes NewList, which is not
*	actually an Exec library function.
*

	SECTION	PCQ_Runtime,CODE

	XREF	_AbsExecBase

	XREF	_LVOAddHead
	XDEF	_AddHead
_AddHead
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_AbsExecBase,a6
	jmp	_LVOAddHead(a6)

	XREF	_LVOAddTail
	XDEF	_AddTail
_AddTail
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_AbsExecBase,a6
	jmp	_LVOAddTail(a6)

	XREF	_LVOEnqueue
	XDEF	_Enqueue
_Enqueue
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_AbsExecBase,a6
	jmp	_LVOEnqueue(a6)


	XREF	_LVOFindName
	XDEF	_FindName
_FindName
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_AbsExecBase,a6
	jmp	_LVOFindName(a6)

	XREF	_LVOInsert
	XDEF	_Insert
_Insert
	move.l	4(sp),a2
	move.l	8(sp),a1
	move.l	12(sp),a0
	move.l	_AbsExecBase,a6
	jmp	_LVOInsert(a6)

	XREF	_LVONewList
	XDEF	_NewList
_NewList
	move.l	4(sp),a0
	move.l	a0,(a0)
	addq.l	#4,(a0)
	clr.l	4(a0)
	move.l	a0,8(a0)
	rts

	XREF	_LVORemHead
	XDEF	_RemHead
_RemHead
	move.l	4(sp),a0
	move.l	_AbsExecBase,a6
	jmp	_LVORemHead(a6)

	XREF	_LVORemove
	XDEF	_Remove
_Remove
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVORemove(a6)

	XREF	_LVORemTail
	XDEF	_RemTail
_RemTail
	move.l	4(sp),a0
	move.l	_AbsExecBase,a6
	jmp	_LVORemTail(a6)

	END

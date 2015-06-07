*
*	Tasks.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	These are the glue routines for the Exec library routines defined
*	in Include/Exec/Tasks.i.  CreateTask() and DeleteTask() are
*	defined in Runtime/Extras.
*

	SECTION	PCQ_Runtime,CODE

	XREF	_AbsExecBase

	XREF	_LVOAddTask
	XDEF	_AddTask
_AddTask
	movem.l	a2/a3,-(sp)
	move.l	12(sp),a3
	move.l	16(sp),a2
	move.l	20(sp),a1
	move.l	_AbsExecBase,a6
	jsr	_LVOAddTask(a6)
	movem.l	(sp)+,a2/a3
	rts

	XREF	_LVOAllocSignal
	XDEF	_AllocSignal
_AllocSignal
	move.l	4(sp),d0
	move.l	_AbsExecBase,a6
	jmp	_LVOAllocSignal(a6)

	XREF	_LVOAllocTrap
	XDEF	_AllocTrap
_AllocTrap
	move.l	4(sp),d0
	move.l	_AbsExecBase,a6
	jmp	_LVOAllocTrap(a6)

	XREF	_LVOFindTask
	XDEF	_FindTask
_FindTask
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVOFindTask(a6)

	XREF	_LVOFreeSignal
	XDEF	_FreeSignal
_FreeSignal
	move.l	4(sp),d0
	move.l	_AbsExecBase,a6
	jmp	_LVOFreeSignal(a6)

	XREF	_LVOFreeTrap
	XDEF	_FreeTrap
_FreeTrap
	move.l	4(sp),d0
	move.l	_AbsExecBase,a6
	jmp	_LVOFreeTrap(a6)

	XREF	_LVORemTask
	XDEF	_RemTask
_RemTask
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVORemTask(a6)

	XREF	_LVOSetExcept
	XDEF	_SetExcept
_SetExcept
	move.l	4(sp),d1
	move.l	8(sp),d0
	move.l	_AbsExecBase,a6
	jmp	_LVOSetExcept(a6)

	XREF	_LVOSetSignal
	XDEF	_SetSignal
_SetSignal
	move.l	4(sp),d1
	move.l	8(sp),d0
	move.l	_AbsExecBase,a6
	jmp	_LVOSetSignal(a6)

	XREF	_LVOSetTaskPri
	XDEF	_SetTaskPri
_SetTaskPri
	movem.l	4(sp),d0/a1
	move.l	_AbsExecBase,a6
	jmp	_LVOSetTaskPri(a6)

	XREF	_LVOSignal
	XDEF	_Signal
_Signal
	movem.l	4(sp),d0/a1
	move.l	_AbsExecBase,a6
	jmp	_LVOSignal(a6)

	XREF	_LVOWait
	XDEF	_Wait
_Wait
	move.l	4(sp),d0
	move.l	_AbsExecBase,a6
	jmp	_LVOWait(a6)

	END

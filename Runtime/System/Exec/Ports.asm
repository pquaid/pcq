*
*	Ports.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	These are the glue routines for the Exec library routines in
*	Include/Exec/Ports.i.  The Pascal source for the routines
*	CreatePort() and DeletePort() are in Runtime/Extras.
*

	SECTION	PCQ_Runtime,CODE

	XREF	_AbsExecBase

	XREF	_LVOAddPort
	XDEF	_AddPort
_AddPort
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVOAddPort(a6)

	XREF	_LVOFindPort
	XDEF	_FindPort
_FindPort
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVOFindPort(a6)

	XREF	_LVOGetMsg
	XDEF	_GetMsg
_GetMsg
	move.l	4(sp),a0
	move.l	_AbsExecBase,a6
	jmp	_LVOGetMsg(a6)

	XREF	_LVOPutMsg
	XDEF	_PutMsg
_PutMsg
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_AbsExecBase,a6
	jmp	_LVOPutMsg(a6)

	XREF	_LVORemPort
	XDEF	_RemPort
_RemPort
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVORemPort(a6)

	XREF	_LVOReplyMsg
	XDEF	_ReplyMsg
_ReplyMsg
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVOReplyMsg(a6)

	XREF	_LVOWaitPort
	XDEF	_WaitPort
_WaitPort
	move.l	4(sp),a0
	move.l	_AbsExecBase,a6
	jmp	_LVOWaitPort(a6)

	END

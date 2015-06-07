*
*	Interrupts.asm of PCQ Pascal
*
*	The glue for the routines defined in Include/Exec/Interrupts.i
*	is in this file
*

	SECTION	PCQ_Runtime,CODE

	XREF	_AbsExecBase

	XREF	_LVOAddIntServer
	XDEF	_AddIntServer
_AddIntServer
	move.l	4(sp),a1
	move.l	8(sp),d0
	move.l	_AbsExecBase,a6
	jmp	_LVOAddIntServer(a6)

	XREF	_LVOCause
	XDEF	_Cause
_Cause
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVOCause(a6)

	XREF	_LVODisable
	XDEF	_Disable
_Disable
	move.l	_AbsExecBase,a6
	jmp	_LVODisable(a6)

	XREF	_LVOEnable
	XDEF	_Enable
_Enable
	move.l	_AbsExecBase,a6
	jmp	_LVOEnable(a6)

	XREF	_LVOForbid
	XDEF	_Forbid
_Forbid
	move.l	_AbsExecBase,a6
	jmp	_LVOForbid(a6)

	XREF	_LVOPermit
	XDEF	_Permit
_Permit
	move.l	_AbsExecBase,a6
	jmp	_LVOPermit(a6)

	XREF	_LVORemIntServer
	XDEF	_RemIntServer
_RemIntServer
	move.l	4(sp),a1
	move.l	8(sp),d0
	move.l	_AbsExecBase,a6
	jmp	_LVORemIntServer(a6)

	XREF	_LVOSetIntVector
	XDEF	_SetIntVector
_SetIntVector
	move.l	4(sp),a1
	move.l	8(sp),d0
	move.l	_AbsExecBase,a6
	jmp	_LVOSetIntVector(a6)

	XREF	_LVOSuperState
	XDEF	_SuperState
_SuperState
	move.l	_AbsExecBase,a6
	jmp	_LVOSuperState(a6)

	XREF	_LVOUserState
	XDEF	_UserState
_UserState
	move.l	4(sp),d0
	move.l	_AbsExecBase,a6
	jmp	_LVOUserState(a6)

	END

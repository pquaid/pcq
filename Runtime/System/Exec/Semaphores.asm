*
*	Semaphore.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	These are the glue routines for the functions and procedures
*	defined in Include/Exec/Semaphore.i
*

	SECTION	PCQ_Runtime,CODE

	XREF	_AbsExecBase

	XREF	_LVOAddSemaphore
	XDEF	_AddSemaphore
_AddSemaphore
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVOAddSemaphore(a6)

	XREF	_LVOAttemptSemaphore
	XDEF	_AttemptSemaphore
_AttemptSemaphore
	move.l	4(sp),a0
	move.l	_AbsExecBase,a6
	jmp	_LVOAttemptSemaphore(a6)

	XREF	_LVOFindSemaphore
	XDEF	_FindSemaphore
_FindSemaphore
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVOFindSemaphore(a6)

	XREF	_LVOInitSemaphore
	XDEF	_InitSemaphore
_InitSemaphore
	move.l	4(sp),a0
	move.l	_AbsExecBase,a6
	jmp	_LVOInitSemaphore(a6)

	XREF	_LVOObtainSemaphore
	XDEF	_ObtainSemaphore
_ObtainSemaphore
	move.l	4(sp),a0
	move.l	_AbsExecBase,a6
	jmp	_LVOObtainSemaphore(a6)

	XREF	_LVOObtainSemaphoreList
	XDEF	_ObtainSemaphoreList
_ObtainSemaphoreList
	move.l	4(sp),a0
	move.l	_AbsExecBase,a6
	jmp	_LVOObtainSemaphoreList(a6)

	XREF	_LVOProcure
	XDEF	_Procure
_Procure
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_AbsExecBase,a6
	jmp	_LVOProcure(a6)

	XREF	_LVOReleaseSemaphore
	XDEF	_ReleaseSemaphore
_ReleaseSemaphore
	move.l	4(sp),a0
	move.l	_AbsExecBase,a6
	jmp	_LVOReleaseSemaphore(a6)

	XREF	_LVOReleaseSemaphoreList
	XDEF	_ReleaseSemaphoreList
_ReleaseSemaphoreList
	move.l	4(sp),a0
	move.l	_AbsExecBase,a6
	jmp	_LVOReleaseSemaphoreList(a6)

	XREF	_LVORemSemaphore
	XDEF	_RemSemaphore
_RemSemaphore
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVORemSemaphore(a6)

	XREF	_LVOVacate
	XDEF	_Vacate
_Vacate
	move.l	4(sp),a0
	move.l	_AbsExecBase,a6
	jmp	_LVOVacate(a6)

	END

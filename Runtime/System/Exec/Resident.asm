*
*	Resident.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	These are the glue routines for the procedures and functions
*	defined in Include/Exec/Resident.i
*

	SECTION	PCQ_Runtime,CODE

	XREF	_AbsExecBase

	XREF	_LVOFindResident
	XDEF	_FindResident
_FindResident
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVOFindResident(a6)

	XREF	_LVOInitCode
	XDEF	_InitCode
_InitCode
	move.l	4(sp),d1
	move.l	8(sp),d0
	move.l	_AbsExecBase,a6
	jmp	_LVOInitCode(a6)

	XREF	_LVOInitResident
	XDEF	_InitResident
_InitResident
	movem.l	4(sp),d1/a1
	move.l	_AbsExecBase,a6
	jmp	_LVOInitResident(a6)

	XREF	_LVOSumKickData
	XDEF	_SumKickData
_SumKickData
	move.l	_AbsExecBase,a6
	jmp	_LVOSumKickData(a6)

	END

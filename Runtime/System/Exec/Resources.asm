*
*	Resources.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	These are the glue routines for the procedures and functions
*	defined in Include/Exec/Resources.i
*

	SECTION	PCQ_Runtime,CODE

	XREF	_AbsExecBase

	XREF	_LVOAddResource
	XDEF	_AddResource
_AddResource
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVOAddResource(a6)

	XREF	_LVOOpenResource
	XDEF	_OpenResource
_OpenResource
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVOOpenResource(a6)

	XREF	_LVORemResource
	XDEF	_RemResource
_RemResource
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVORemResource(a6)

	END

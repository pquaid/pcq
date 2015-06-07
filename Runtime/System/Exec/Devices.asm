*
*	Devices.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	This file has the glue routines for the procedures and functions
*	defined in Include/Exec/Devices.i
*

	SECTION	PCQ_Runtime,CODE

	XREF	_AbsExecBase

	XREF	_LVOAddDevice
	XDEF	_AddDevice
_AddDevice
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVOAddDevice(a6)

	XREF	_LVOCloseDevice
	XDEF	_CloseDevice
_CloseDevice
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVOCloseDevice(a6)

	XREF	_LVOOpenDevice
	XDEF	_OpenDevice
_OpenDevice
	movem.l	4(sp),d1/a1
	movem.l	12(sp),d0/a0
	move.l	_AbsExecBase,a6
	jmp	_LVOOpenDevice(a6)

	XREF	_LVORemDevice
	XDEF	_RemDevice
_RemDevice
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVORemDevice(a6)

	END

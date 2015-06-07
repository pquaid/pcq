*
*	DOSExtens.asm for PCQ Pascal
*	Copyright 1990 Patrick Quaid
*
*	These are the glue routines for the procedures and functions
*	defined in Include/Libraries/DOSExtens.i.
*
*

	SECTION	PCQ_Runtime,CODE

	XREF	_p%DOSBase

	XDEF	_CreateProc
	XREF	_LVOCreateProc
_CreateProc
	movem.l	d2/d3/d4,-(sp)
	move.l	16(sp),d4
	move.l	20(sp),d3
	move.l	24(sp),d2
	move.l	28(sp),d1
	move.l	_p%DOSBase,a6
	jsr	_LVOCreateProc(a6)
	movem.l	(sp)+,d2/d3/d4
	rts

	XDEF	_DeviceProc
	XREF	_LVODeviceProc
_DeviceProc
	move.l	4(sp),d1
	move.l	_p%DOSBase,a6
	jmp	_LVODeviceProc(a6)

	XDEF	_LoadSeg
	XREF	_LVOLoadSeg
_LoadSeg
	move.l	4(sp),d1
	move.l	_p%DOSBase,a6
	jmp	_LVOLoadSeg(a6)


	XDEF	_UnLoadSeg
	XREF	_LVOUnLoadSeg
_UnLoadSeg
	move.l	4(sp),d1
	move.l	_p%DOSBase,a6
	jmp	_LVOUnLoadSeg(a6)


	END

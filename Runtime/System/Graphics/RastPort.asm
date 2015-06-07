*
*	RastPort.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	These are the glue routines for the procedures and functions
*	defined in Include/Graphics/RastPort.i
*

	SECTION PCQ_Runtime,CODE

	XREF	_GfxBase

	XREF	_LVOAllocRaster
	XDEF	_AllocRaster
_AllocRaster
	move.w	4(sp),d1
	move.w	6(sp),d0
	move.l	_GfxBase,a6
	jmp	_LVOAllocRaster(a6)


	XREF	_LVOFreeRaster
	XDEF	_FreeRaster
_FreeRaster
	move.w	4(sp),d1
	move.w	6(sp),d0
	move.l	8(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOFreeRaster(a6)


	XREF	_LVOInitRastPort
	XDEF	_InitRastPort
_InitRastPort
	move.l	4(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOInitRastPort(a6)


	XREF	_LVOInitTmpRas
	XDEF	_InitTmpRas
_InitTmpRas
	move.l	4(sp),d0
	move.l	8(sp),a1
	move.l	12(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOInitTmpRas(a6)


	XREF	_LVOScrollRaster
	XDEF	_ScrollRaster
_ScrollRaster
	movem.l	d2/d3/d4/d5,-(sp)
	move.w	20(sp),d5
	move.w	22(sp),d4
	move.w	24(sp),d3
	move.w	26(sp),d2
	move.w	28(sp),d1
	move.w	30(sp),d0
	move.l	32(sp),a1
	move.l	_GfxBase,a6
	jsr	_LVOScrollRaster(a6)
	movem.l	(sp)+,d2/d3/d4/d5
	rts

	XREF	_LVOSetRast
	XDEF	_SetRast
_SetRast
	move.w	4(sp),d0
	move.l	6(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOSetRast(a6)

	END

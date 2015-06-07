*
*	Areas.asm for PCQ Pascal
*	Copyright 1990 Patrick Quaid
*
*	glue routines for the procedures and functions
*	declared in include/graphics/areas.i
*
*

	XREF	_GfxBase

	SECTION	PCQ_Runtime,CODE

	XDEF	_AreaCircle
_AreaCircle
	movem.l	d2/d3,-(sp)
	move.w	12(sp),d2
	move.w	d2,d3
	move.w	14(sp),d1
	move.w	16(sp),d0
	move.l	18(sp),a1
	move.l	_GfxBase,a6
	jsr	_LVOAreaEllipse(a6)
	movem.l	(sp)+,d2/d3
	rts

	XREF	_LVOAreaDraw
	XDEF	_AreaDraw
_AreaDraw
	move.w	4(sp),d1
	move.w	6(sp),d0
	move.l	8(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOAreaDraw(a6)

	XREF	_LVOAreaEllipse
	XDEF	_AreaEllipse
_AreaEllipse
	movem.l	d2/d3,-(sp)
	move.w	12(sp),d3
	move.w	14(sp),d2
	move.w	16(sp),d1
	move.w	18(sp),d0
	move.l	20(sp),a1
	move.l	_GfxBase,a6
	jsr	_LVOAreaEllipse(a6)
	movem.l	(sp)+,d2/d3
	rts

	XREF	_LVOAreaEnd
	XDEF	_AreaEnd
_AreaEnd
	move.l	4(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOAreaEnd(a6)

	XREF	_LVOAreaMove
	XDEF	_AreaMove
_AreaMove
	move.w	4(sp),d1
	move.w	6(sp),d0
	move.l	8(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOAreaMove(a6)

	XREF	_LVOInitArea
	XDEF	_InitArea
_InitArea
	move.w	4(sp),d0
	move.l	6(sp),a1
	move.l	10(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOInitArea(a6)

	END

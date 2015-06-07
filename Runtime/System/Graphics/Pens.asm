*
*	Pens.asm of PCQ Pascal
*	Copyright 1990 Patrick Quaid
*
*	These routines provide an interface between Pascal programs
*	and the Amiga OS routines for the procedures defined in
*	graphics/pens.i
*

	XREF	_GfxBase


	XREF	_LVODraw
	XDEF	_Draw
_Draw
	move.w	4(sp),d1
	move.w	6(sp),d0
	move.l	8(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVODraw(a6)


	XREF	_LVODrawCircle
	XDEF	_DrawCircle
_DrawCircle
	movem.l	d2/d3,-(sp)
	move.w	12(sp),d2
	move.w	d2,d3
	move.w	14(sp),d1
	move.w	16(sp),d0
	move.l	18(sp),a1
	move.l	_GfxBase,a6
	jsr	_LVODrawEllipse(a6)
	movem.l	(sp)+,d2/d3
	rts


	XREF	_LVODrawEllipse
	XDEF	_DrawEllipse
_DrawEllipse
	movem.l	d2/d3,-(sp)
	move.w	12(sp),d3
	move.w	14(sp),d2
	move.w	16(sp),d1
	move.w	18(sp),d0
	move.l	20(sp),a1
	move.l	_GfxBase,a6
	jsr	_LVODrawEllipse(a6)
	movem.l	(sp)+,d2/d3
	rts


	XREF	_LVOFlood
	XDEF	_Flood
_Flood
	move.l	d2,-(sp)
	move.w	8(sp),d1
	move.w	10(sp),d0
	movem.l	12(sp),d2/a1
	move.l	_GfxBase,a6
	jsr	_LVOFlood(a6)
	move.l	(sp)+,d2
	rts


	XREF	_LVOMove
	XDEF	_Move
_Move
	move.w	4(sp),d1
	move.w	6(sp),d0
	move.l	8(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOMove(a6)


	XREF	_LVOPolyDraw
	XDEF	_PolyDraw
_PolyDraw
	move.l	4(sp),a0
	move.w	8(sp),d0
	move.l	10(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOPolyDraw(a6)


	XREF	_LVOReadPixel
	XDEF	_ReadPixel
_ReadPixel
	move.w	4(sp),d1
	move.w	6(sp),d0
	move.l	8(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOReadPixel(a6)


	XREF	_LVORectFill
	XDEF	_RectFill
_RectFill
	movem.l	d2/d3,-(sp)
	move.w	12(sp),d3
	move.w	14(sp),d2
	move.w	16(sp),d1
	move.w	18(sp),d0
	move.l	20(sp),a1
	move.l	_GfxBase,a6
	jsr	_LVORectFill(a6)
	movem.l	(sp)+,d2/d3
	rts


	XREF	_LVOSetAPen
	XDEF	_SetAPen
_SetAPen
	move.w	4(sp),d0
	move.l	6(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOSetAPen(a6)


	XREF	_LVOSetBPen
	XDEF	_SetBPen
_SetBPen
	move.w	4(sp),d0
	move.l	6(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOSetBPen(a6)


	XREF	_LVOSetDrMd
	XDEF	_SetDrMd
_SetDrMd
	move.w	4(sp),d0
	move.l	6(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOSetDrMd(a6)


	XREF	_LVOWritePixel
	XDEF	_WritePixel
_WritePixel
	move.w	4(sp),d1
	move.w	6(sp),d0
	move.l	8(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOWritePixel(a6)

	END

*
*	View.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	These are the glue routines for the procedures and functions
*	defined in Include/Graphics/View.i
*

	SECTION PCQ_Runtime,CODE

	XREF	_GfxBase

	XREF	_LVOFreeColorMap
	XDEF	_FreeColorMap
_FreeColorMap
	move.l	4(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOFreeColorMap(a6)


	XREF	_LVOFreeVPortCopLists
	XDEF	_FreeVPortCopLists
_FreeVPortCopLists
	move.l	4(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOFreeVPortCopLists(a6)


	XREF	_LVOGetColorMap
	XDEF	_GetColorMap
_GetColorMap
	move.l	4(sp),d0
	move.l	_GfxBase,a6
	jmp	_LVOGetColorMap(a6)


	XREF	_LVOGetRGB4
	XDEF	_GetRGB4
_GetRGB4
	movem.l	4(sp),d0/a0
	move.l	_GfxBase,a6
	jmp	_LVOGetRGB4(a6)


	XREF	_LVOInitView
	XDEF	_InitView
_InitView
	move.l	4(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOInitView(a6)


	XREF	_LVOInitVPort
	XDEF	_InitVPort
_InitVPort
	move.l	4(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOInitVPort(a6)


	XREF	_LVOLoadRGB4
	XDEF	_LoadRGB4
_LoadRGB4
	move.w	4(sp),d0
	move.l	6(sp),a1
	move.l	10(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOLoadRGB4(a6)


	XREF	_LVOLoadView
	XDEF	_LoadView
_LoadView
	move.l	4(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOLoadView(a6)


	XREF	_LVOMakeVPort
	XDEF	_MakeVPort
_MakeVPort
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOMakeVPort(a6)


	XREF	_LVOMrgCop
	XDEF	_MrgCop
_MrgCop
	move.l	4(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOMrgCop(a6)


	XREF	_LVOScrollVPort
	XDEF	_ScrollVPort
_ScrollVPort
	move.l	4(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOScrollVPort(a6)


	XREF	_LVOSetRGB4
	XDEF	_SetRGB4
_SetRGB4
	movem.l	d2/d3,-(sp)
	move.w	12(sp),d3
	move.w	14(sp),d2
	move.w	16(sp),d1
	move.w	18(sp),d0
	move.l	20(sp),a0
	move.l	_GfxBase,a6
	jsr	_LVOSetRGB4(a6)
	movem.l	(sp)+,d2/d3
	rts

	XREF	_LVOSetRGB4CM
	XDEF	_SetRGB4CM
_SetRGB4CM
	movem.l	d2/d3,-(sp)
	move.w	12(sp),d3
	move.w	14(sp),d2
	move.w	16(sp),d1
	move.w	18(sp),d0
	move.l	20(sp),a0
	move.l	_GfxBase,a6
	jsr	_LVOSetRGB4(a6)
	movem.l	(sp)+,d2/d3
	rts



	XREF	_LVOVBeamPos
	XDEF	_VBeamPos
_VBeamPos
	move.l	_GfxBase,a6
	jmp	_LVOVBeamPos(a6)


	XREF	_LVOWaitBOVP
	XDEF	_WaitBOVP
_WaitBOVP
	move.l	4(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOWaitBOVP(a6)


	XREF	_LVOWaitTOF
	XDEF	_WaitTOF
_WaitTOF
	move.l	_GfxBase,a6
	jmp	_LVOWaitTOF(a6)

	END

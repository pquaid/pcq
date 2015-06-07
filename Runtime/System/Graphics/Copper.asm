*
*	Copper.asm for PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	These are the glue routines for the procedures and functions
*	defined in Include/Graphics/Copper.i
*

	SECTION	PCQ_Runtime,CODE

	XREF	_GfxBase

	XREF	_LVOCBump
	XDEF	_CBump
_CBump
	move.l	4(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOCBump(a6)


	XREF	_LVOCMove
	XDEF	_CMove
_CMove
	move.w	4(sp),d1
	movem.l	6(sp),d0/a1
	move.l	_GfxBase,a6
	jmp	_LVOCMove(a6)


	XREF	_LVOCWait
	XDEF	_CWait
_CWait
	move.w	4(sp),d1
	move.w	6(sp),d0
	move.l	8(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOCWait(a6)


	XREF	_LVOFreeCopList
	XDEF	_FreeCopList
_FreeCopList
	move.l	4(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOFreeCopList(a6)


	XREF	_LVOFreeCprList
	XDEF	_FreeCprList
_FreeCprList
	move.l	4(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOFreeCprList(a6)


	XREF	_LVOUCopperListInit

	XDEF	__CINIT
	XDEF	_UCopperListInit
__CINIT
_UCopperListInit
	move.w	4(sp),d0
	move.l	6(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOUCopperListInit(a6)


	XDEF	__CEND
__CEND
	move.l	4(sp),a1
	move.w	#10000,d0
	move.w	#255,d1
	move.l	_GfxBase,a6
	jsr	_LVOCWait(a6)
	move.l	4(sp),a1
	jmp	_LVOCBump(a6)


	XDEF	__CMOVE
__CMOVE
	move.w	4(sp),d1
	movem.l	6(sp),d0/a1
	move.l	_GfxBase,a6
	jsr	_LVOCMove(a6)
	move.l	10(sp),a1
	jmp	_LVOCBump(a6)


	XREF	_LVO_CWAIT
	XDEF	__CWAIT
__CWAIT
	move.w	4(sp),d1
	move.w	6(sp),d0
	move.l	8(sp),a1
	move.l	_GfxBase,a6
	jsr	_LVOCWait(a6)
	move.l	8(sp),a1
	jmp	_LVOCBump(a6)

	END

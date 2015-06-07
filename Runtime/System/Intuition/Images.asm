*
*	Images.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	This file has the glue routines for the procedures and functions
*	defined in Include/Intuition/Intuition.i having to do with
*	Intuition images, borders, and IntuiText
*


	SECTION	PCQ_Runtime,CODE

	XREF	_p%IntuitionBase

	XDEF	_DrawBorder
	XREF	_LVODrawBorder
_DrawBorder
	move.w	4(sp),d1
	move.w	6(sp),d0
	move.l	8(sp),a1
	move.l	12(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVODrawBorder(a6)

	XDEF	_DrawImage
	XREF	_LVODrawImage
_DrawImage
	move.w	4(sp),d1
	move.w	6(sp),d0
	move.l	8(sp),a1
	move.l	12(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVODrawImage(a6)

	XDEF	_IntuiTextLength
	XREF	_LVOIntuiTextLength
_IntuiTextLength
	move.l	4(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOIntuiTextLength(a6)

	XDEF	_PrintIText
	XREF	_LVOPrintIText
_PrintIText
	move.w	4(sp),d1
	move.w	6(sp),d0
	move.l	8(sp),a1
	move.l	12(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOPrintIText(a6)

	END

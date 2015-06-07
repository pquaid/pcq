*
*	Menus.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	This file has the glue routines for the procedures and functions
*	defined in Include/Intuition/Intuition.i having to do with
*	Menus
*


	SECTION	PCQ_Runtime,CODE

	XREF	_p%IntuitionBase

	XDEF	_ClearMenuStrip
	XREF	_LVOClearMenuStrip
_ClearMenuStrip
	move.l	4(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOClearMenuStrip(a6)

	XDEF	_ItemAddress
	XREF	_LVOItemAddress
_ItemAddress
	move.w	4(sp),d0
	move.l	6(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOItemAddress(a6)

	XDEF	_OffMenu
	XREF	_LVOOffMenu
_OffMenu
	move.w	4(sp),d0
	move.l	6(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOOffMenu(a6)

	XDEF	_OnMenu
	XREF	_LVOOnMenu
_OnMenu
	move.w	4(sp),d0
	move.l	6(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOOnMenu(a6)

	XDEF	_SetMenuStrip
	XREF	_LVOSetMenuStrip
_SetMenuStrip
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_p%IntuitionBase,a6
	jsr	_LVOSetMenuStrip(a6)
	tst.l	d0
	sne	d0
	rts

	XDEF	_MenuNum
_MenuNum
	move.w	4(sp),d0
	and.l	#$1F,d0
	rts

	XDEF	_ItemNum
_ItemNum
	move.w	4(sp),d0
	lsr.w	#5,d0
	and.l	#$3F,d0
	rts

	XDEF	_SubNum
_SubNum
	move.w	4(sp),d0
	lsr.w	#6,d0
	lsr.w	#5,d0
	and.l	#$1F,d0
	rts

	END

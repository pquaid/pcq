*
*	Gadgets.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	This file has the glue routines for the procedures and functions
*	defined in Include/Intuition/Intuition.i having to do with
*	Gadgets
*


	SECTION	PCQ_Runtime,CODE

	XREF	_p%IntuitionBase

	XDEF	_ActivateGadget
	XREF	_LVOActivateGadget
_ActivateGadget
	move.l	4(sp),a2
	move.l	8(sp),a1
	move.l	12(sp),a0
	move.l	_p%IntuitionBase,a6
	jsr	_LVOActivateGadget(a6)
	tst.l	d0
	sne	d0
	rts

	XDEF	_AddGadget
	XREF	_LVOAddGadget
_AddGadget
	move.w	4(sp),d0
	move.l	6(sp),a1
	move.l	10(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOAddGadget(a6)

	XDEF	_AddGList
	XREF	_LVOAddGList
_AddGList
	move.l	4(sp),a2
	move.w	8(sp),d1
	move.w	10(sp),d0
	move.l	12(sp),a1
	move.l	16(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOAddGList(a6)

	XDEF	_ModifyProp
	XREF	_LVOModifyProp
_ModifyProp
	movem.l	d2/d3/d4/a2,-(sp)
	move.w	20(sp),d4
	move.w	22(sp),d3
	move.w	24(sp),d2
	move.w	26(sp),d1
	move.w	28(sp),d0
	move.l	30(sp),a2
	move.l	34(sp),a1
	move.l	38(sp),a0
	move.l	_p%IntuitionBase,a6
	jsr	_LVOModifyProp(a6)
	movem.l	(sp)+,d2/d3/d4/a2
	rts

	XDEF	_NewModifyProp
	XREF	_LVONewModifyProp
_NewModifyProp
	movem.l	d2/d3/d4/d5/a2,-(sp)
	move.l	24(sp),d5
	move.w	28(sp),d4
	move.w	30(sp),d3
	move.w	32(sp),d2
	move.w	34(sp),d1
	move.w	36(sp),d0
	move.l	38(sp),a2
	move.l	42(sp),a1
	move.l	46(sp),a0
	move.l	_p%IntuitionBase,a6
	jsr	_LVONewModifyProp(a6)
	movem.l	(sp)+,d2/d3/d4/d5/a2
	rts

	XDEF	_OffGadget
	XREF	_LVOOffGadget
_OffGadget
	move.l	4(sp),a2
	move.l	8(sp),a1
	move.l	12(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOOffGadget(a6)

	XDEF	_OnGadget
	XREF	_LVOOnGadget
_OnGadget
	move.l	4(sp),a2
	move.l	8(sp),a1
	move.l	12(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOOnGadget(a6)

	XDEF	_RefreshGadgets
	XREF	_LVORefreshGadgets
_RefreshGadgets
	move.l	4(sp),a2
	move.l	8(sp),a1
	move.l	12(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVORefreshGadgets(a6)

	XDEF	_RefreshGList
	XREF	_LVORefreshGList
_RefreshGList
	move.w	4(sp),d0
	move.l	6(sp),a2
	move.l	10(sp),a1
	move.l	14(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVORefreshGList(a6)	

	XDEF	_RemoveGadget
	XREF	_LVORemoveGadget
_RemoveGadget
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVORemoveGadget(a6)

	XDEF	_RemoveGList
	XREF	_LVORemoveGList
_RemoveGList
	move.w	4(sp),d0
	move.l	6(sp),a1
	move.l	10(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVORemoveGList(a6)

	END

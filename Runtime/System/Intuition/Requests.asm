*
*	Requests.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	This file has the glue routines for the procedures and functions
*	defined in Include/Intuition/Intuition.i having to do with
*	Requesters
*


	SECTION	PCQ_Runtime,CODE

	XREF	_p%IntuitionBase

	XDEF	_AutoRequest
	XREF	_LVOAutoRequest
_AutoRequest
	movem.l	d2/d3/a2/a3,-(sp)
	move.w	20(sp),d3
	move.w	22(sp),d2
	move.l	24(sp),d1
	movem.l	28(sp),d0/a3
	move.l	36(sp),a2
	move.l	40(sp),a1
	move.l	44(sp),a0
	move.l	_p%IntuitionBase,a6
	jsr	_LVOAutoRequest(a6)
	movem.l	(sp)+,d2/d3/a2/a3
	tst.l	d0
	sne	d0
	rts


	XDEF	_BuildSysRequest
	XREF	_LVOBuildSysRequest
_BuildSysRequest
	movem.l	d2/d3/a2/a3,-(sp)
	move.w	20(sp),d3
	move.w	22(sp),d2
	movem.l	24(sp),d0/a3
	move.l	32(sp),a2
	move.l	36(sp),a1
	move.l	40(sp),a0
	move.l	_p%IntuitionBase,a6
	jsr	_LVOBuildSysRequest(a6)
	movem.l	(sp)+,d2/d3/a2/a3
	rts


	XDEF	_ClearDMRequest
	XREF	_LVOClearDMRequest
_ClearDMRequest
	move.l	4(sp),a0
	move.l	_p%IntuitionBase,a6
	jsr	_LVOClearDMRequest(a6)
	tst.l	d0
	sne	d0
	rts

	XDEF	_DisplayAlert
	XREF	_LVODisplayAlert
_DisplayAlert
	move.w	4(sp),d1
	move.l	6(sp),a0
	move.l	10(sp),d0
	move.l	_p%IntuitionBase,a6
	jsr	_LVODisplayAlert(a6)
	tst.l	d0
	sne	d0
	rts

	XDEF	_EndRequest
	XREF	_LVOEndRequest
_EndRequest
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOEndRequest(a6)

	XDEF	_FreeSysRequest
	XREF	_LVOFreeSysRequest
_FreeSysRequest
	move.l	4(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOFreeSysRequest(a6)

	XDEF	_InitRequester
	XREF	_LVOInitRequester
_InitRequester
	move.l	4(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOInitRequester(a6)

	XDEF	_Request
	XREF	_LVORequest
_Request
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVORequest(a6)

	XDEF	_SetDMRequest
	XREF	_LVOSetDMRequest
_SetDMRequest
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOSetDMRequest(a6)

	END

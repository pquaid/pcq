*
*	Windows.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	This file has the glue routines for the procedures and functions
*	defined in Include/Intuition/Intuition.i having to do with
*	Windows
*


	SECTION	PCQ_Runtime,CODE

	XREF	_p%IntuitionBase

	XDEF	_ActivateWindow
	XREF	_LVOActivateWindow
_ActivateWindow
	move.l	4(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOActivateWindow(a6)

	XDEF	_BeginRefresh
	XREF	_LVOBeginRefresh
_BeginRefresh
	move.l	4(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOBeginRefresh(a6)

	XDEF	_ClearPointer
	XREF	_LVOClearPointer
_ClearPointer
	move.l	4(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOClearPointer(a6)

	XDEF	_CloseWindow
	XREF	_LVOCloseWindow
_CloseWindow
	move.l	4(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOCloseWindow(a6)

	XDEF	_EndRefresh
	XREF	_LVOEndRefresh
_EndRefresh
	move.w	4(sp),d0
	and.l	#$F,d0
	move.l	6(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOEndRefresh(a6)

	XDEF	_ModifyIDCMP
	XREF	_LVOModifyIDCMP
_ModifyIDCMP
	movem.l	4(sp),d0/a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOModifyIDCMP(a6)

	XDEF	_MoveWindow
	XREF	_LVOMoveWindow
_MoveWindow
	move.w	4(sp),d1
	move.w	6(sp),d0
	move.l	8(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOMoveWindow(a6)

	XDEF	_OpenWindow
	XREF	_LVOOpenWindow
_OpenWindow
	move.l	4(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOOpenWindow(a6)

	XDEF	_RefreshWindowFrame
	XREF	_LVORefreshWindowFrame
_RefreshWindowFrame
	move.l	4(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVORefreshWindowFrame(a6)

	XDEF	_ReportMouse
	XREF	_LVOReportMouse
_ReportMouse
	move.w	4(sp),d0
	and.l	#$F,d0
	move.l	6(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOReportMouse(a6)

	XDEF	_SetPointer
	XREF	_LVOSetPointer
_SetPointer
	movem.l	d2/d3,-(sp)
	move.w	12(sp),d3
	move.w	14(sp),d2
	move.w	16(sp),d1
	move.w	18(sp),d0
	move.l	20(sp),a1
	move.l	24(sp),a0
	move.l	_p%IntuitionBase,a6
	jsr	_LVOSetPointer(a6)
	movem.l	(sp)+,d2/d3
	rts


	XDEF	_SetWindowTitles
	XREF	_LVOSetWindowTitles
_SetWindowTitles
	move.l	4(sp),a2
	move.l	8(sp),a1
	move.l	12(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOSetWindowTitles(a6)

	XDEF	_ShowTitle
	XREF	_LVOShowTitle
_ShowTitle
	move.w	4(sp),d0
	and.l	#$FF,d0
	move.l	6(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOShowTitle(a6)

	XDEF	_SizeWindow
	XREF	_LVOSizeWindow
_SizeWindow
	move.w	4(sp),d1
	move.w	6(sp),d0
	move.l	8(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOSizeWindow(a6)

	XDEF	_ViewPortAddress
	XREF	_LVOViewPortAddress
_ViewPortAddress
	move.l	4(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOViewPortAddress(a6)

	XDEF	_WindowLimits
	XREF	_LVOWindowLimits
_WindowLimits
	movem.l	d2/d3,-(sp)
	move.w	12(sp),d3
	move.w	14(sp),d2
	move.w	16(sp),d1
	move.w	18(sp),d0
	move.l	20(sp),a0
	move.l	_p%IntuitionBase,a6
	jsr	_LVOWindowLimits(a6)
	movem.l	(sp)+,d2/d3
	tst.l	d0
	sne	d0
	rts

	XDEF	_WindowToBack
	XREF	_LVOWindowToBack
_WindowToBack
	move.l	4(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOWindowToBack(a6)

	XDEF	_WindowToFront
	XREF	_LVOWindowToFront
_WindowToFront
	move.l	4(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOWindowToFront(a6)

	END

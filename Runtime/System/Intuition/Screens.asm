*
*	Screens.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	This file has the glue routines for the procedures and functions
*	defined in Include/Intuition/Intuition.i having to do with
*	Screens
*


	SECTION	PCQ_Runtime,CODE

	XREF	_p%IntuitionBase

	XDEF	_CloseScreen
	XREF	_LVOCloseScreen
_CloseScreen
	move.l	4(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOCloseScreen(a6)

	XDEF	_CloseWorkBench
	XREF	_LVOCloseWorkBench
_CloseWorkBench
	move.l	_p%IntuitionBase,a6
	jsr	_LVOCloseWorkBench(a6)
	tst.l	d0
	sne	d0
	rts

	XDEF	_DisplayBeep
	XREF	_LVODisplayBeep
_DisplayBeep
	move.l	4(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVODisplayBeep(a6)

	XDEF	_GetScreenData
	XREF	_LVOGetScreenData
_GetScreenData
	move.l	4(sp),a1
	move.w	8(sp),d1
	move.w	10(sp),d0
	move.l	12(sp),a0
	move.l	_p%IntuitionBase,a6
	jsr	_LVOGetScreenData(a6)
	tst.l	d0
	sne	d0
	rts

	XDEF	_MakeScreen
	XREF	_LVOMakeScreen
_MakeScreen
	move.l	4(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOMakeScreen(a6)

	XDEF	_MoveScreen
	XREF	_LVOMoveScreen
_MoveScreen
	move.w	4(sp),d1
	move.w	6(sp),d0
	move.l	8(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOMoveScreen(a6)

	XDEF	_OpenScreen
	XREF	_LVOOpenScreen
_OpenScreen
	move.l	4(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOOpenScreen(a6)

	XDEF	_OpenWorkBench
	XREF	_LVOOpenWorkBench
_OpenWorkBench
	move.l	_p%IntuitionBase,a6
	jmp	_LVOOpenWorkBench(a6)

	XDEF	_RemakeDisplay
	XREF	_LVORemakeDisplay
_RemakeDisplay
	move.l	_p%IntuitionBase,a6
	jmp	_LVORemakeDisplay(a6)

	XDEF	_RethinkDisplay
	XREF	_LVORethinkDisplay
_RethinkDisplay
	move.l	_p%IntuitionBase,a6
	jmp	_LVORethinkDisplay(a6)

	XDEF	_ScreenToBack
	XREF	_LVOScreenToBack
_ScreenToBack
	move.l	4(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOScreenToBack(a6)

	XDEF	_ScreenToFront
	XREF	_LVOScreenToFront
_ScreenToFront
	move.l	4(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOScreenToFront(a6)

	XDEF	_WBenchToBack
	XREF	_LVOWBenchToBack
_WBenchToBack
	move.l	_p%IntuitionBase,a6
	jsr	_LVOWBenchToBack(a6)
	tst.l	d0
	sne	d0
	rts

	XDEF	_WBenchToFront
	XREF	_LVOWBenchToFront
_WBenchToFront
	move.l	_p%IntuitionBase,a6
	jsr	_LVOWBenchToFront(a6)
	tst.l	d0
	sne	d0
	rts

	END

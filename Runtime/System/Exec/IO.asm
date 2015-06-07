*
*	IO.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*
*	This file has the glue routines for the procedures and
*	functions defined in Include/Exec/IO.i.  It also has the
*	BeginIO function, which for C is in Amiga.lib (not the
*	Exec library).
*

	SECTION	PCQ_Runtime,CODE

	XREF	_AbsExecBase

	XREF	_LVOAbortIO
	XDEF	_AbortIO
_AbortIO
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVOAbortIO(a6)

	XDEF	_BeginIO
_BeginIO
	move.l	4(sp),a1	; get IO Request
	move.l	$14(a1),a6	; extract Device ptr
	jmp	-$1E(a6)	; call BEGINIO directly

	XREF	_LVOCheckIO
	XDEF	_CheckIO
_CheckIO
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVOCheckIO(a6)

	XREF	_LVODoIO
	XDEF	_DoIO
_DoIO
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVODoIO(a6)

	XREF	_LVOSendIO
	XDEF	_SendIO
_SendIO
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVOSendIO(a6)

	XREF	_LVOWaitIO
	XDEF	_WaitIO
_WaitIO
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVOWaitIO(a6)

	END

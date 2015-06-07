*
*	ExecOther.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	These are the glue routines for the procedures and functions
*	defined in Include/Exec/ExecOther.i
*

	SECTION	PCQ_Runtime,CODE

	XREF	_AbsExecBase

	XREF	_LVODebug
	XDEF	_Debug
_Debug
	move.l	4(sp),d0
	move.l	_AbsExecBase,a6
	jmp	_LVODebug(a6)

	XREF	_LVOGetCC
	XDEF	_GetCC
_GetCC
	move.l	_AbsExecBase,a6
	jmp	_LVOGetCC(a6)

	XREF	_LVORawDoFmt
	XDEF	_RawDoFmt
_RawDoFmt
	movem.l	a2/a3,-(sp)
	move.l	12(sp),a3
	move.l	16(sp),a2
	move.l	20(sp),a1
	move.l	24(sp),a0
	move.l	_AbsExecBase,a6
	jsr	_LVORawDoFmt(a6)
	movem.l	(sp)+,a2/a3
	rts

	XREF	_LVOSetSR
	XDEF	_SetSR
_SetSR
	move.l	4(sp),d1
	move.l	8(sp),d0
	move.l	_AbsExecBase,a6
	jmp	_LVOSetSR(a6)

	END

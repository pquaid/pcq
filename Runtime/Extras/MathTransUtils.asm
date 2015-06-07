*
*	MathTransUtils.asm (of PCQ Pascal runtime library)
*	Copyright (c) 1990 Patrick Quaid
*
*	This file implements the routines found in MathTransUtils.i
*

	SECTION	PCQ_Runtime

	XREF	_AbsExecBase
	XREF	_LVOOpenLibrary
	XREF	_LVOCloseLibrary
	XREF	_LVORemLibrary
	XREF	_MathTransBase

	XDEF	_OpenMathTrans
_OpenMathTrans
	move.l	#mathtransname,a1
	moveq.l	#0,d0
	move.l	_AbsExecBase,a6
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_MathTransBase
	beq.s	1$
	move.b	#-1,d0
1$	rts

	XDEF	_CloseMathTrans
_CloseMathTrans
	move.l	_MathTransBase,a1
	move.l	_AbsExecBase,a6
	jsr	_LVOCloseLibrary(a6)
	move.l	#0,_MathTransBase
	rts

	XDEF	_FlushMathTrans
_FlushMathTrans
	move.l	_MathTransBase,a1
	move.l	a1,d0
	beq.s	1$
	move.l	_AbsExecBase,a6
	jsr	_LVORemLibrary(a6)
	bra	_CloseMathTrans
1$	rts

mathtransname	dc.b	'mathtrans.library',0

	CNOP	0,2

	END

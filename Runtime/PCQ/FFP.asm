*
*  FFP.asm (of PCQ Pascal)
*
* This file defines the stubs used to call the FFP library for
* the sin, cos, tan, etc. routines.
*

	XREF	_p%exit

	XREF	_LVOSPSin
	XREF	_LVOSPCos
	XREF	_LVOSPSqrt
	XREF	_LVOSPTan
	XREF	_LVOSPAtan
	XREF	_LVOSPLog
	XREF	_LVOSPExp

	XREF	_AbsExecBase
	XREF	_LVOCloseLibrary
	XREF	_LVOOpenLibrary

	XREF	_ExitProc
	XREF	_MathTransBase

	XDEF	_p%OpenFFPTrans
_p%OpenFFPTrans
	move.l	#TransName,a1
	moveq	#0,d0
	move.l	_AbsExecBase,a6
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_MathTransBase
	bne	GoAway
	move.l	#61,d0
	jsr	_p%exit
GoAway
	move.l	_ExitProc,_p%PreviousExit
	move.l	#_p%CloseTrans,_ExitProc
	rts

_p%CloseTrans
	move.l	_MathTransBase,d0
	beq	DontClose
	move.l	d0,a1
	move.l	_AbsExecBase,a6
	jsr	_LVOCloseLibrary(a6)
DontClose
	move.l	_p%PreviousExit,_ExitProc
	rts


	XDEF	_p%ffpsin
_p%ffpsin
	move.l	a6,-(sp)
	move.l	8(sp),d0
	move.l	_MathTransBase,a6
	jsr	_LVOSPSin(a6)
	move.l	(sp)+,a6
	rts

	XDEF	_p%ffpcos
_p%ffpcos
	move.l	a6,-(sp)
	move.l	8(sp),d0
	move.l	_MathTransBase,a6
	jsr	_LVOSPCos(a6)
	move.l	(sp)+,a6
	rts

	XDEF	_p%ffpsqrt
_p%ffpsqrt
	move.l	a6,-(sp)
	move.l	8(sp),d0
	move.l	_MathTransBase,a6
	jsr	_LVOSPSqrt(a6)
	move.l	(sp)+,a6
	rts

	XDEF	_p%ffptan
_p%ffptan
	move.l	a6,-(sp)
	move.l	8(sp),d0
	move.l	_MathTransBase,a6
	jsr	_LVOSPTan(a6)
	move.l	(sp)+,a6
	rts

	XDEF	_p%ffpatn
_p%ffpatn
	move.l	a6,-(sp)
	move.l	8(sp),d0
	move.l	_MathTransBase,a6
	jsr	_LVOSPAtan(a6)
	move.l	(sp)+,a6
	rts

	XDEF	_p%ffpln
_p%ffpln
	move.l	a6,-(sp)
	move.l	8(sp),d0
	move.l	_MathTransBase,a6
	jsr	_LVOSPLog(a6)
	move.l	(sp)+,a6
	rts

	XDEF	_p%ffpexp
_p%ffpexp
	move.l	a6,-(sp)
	move.l	8(sp),d0
	move.l	_MathTransBase,a6
	jsr	_LVOSPExp(a6)
	move.l	(sp)+,a6
	rts

	SECTION PCQ_DATA,DATA

TransName	dc.b	'mathtrans.library',0
_p%PreviousExit	dc.l	0

	END

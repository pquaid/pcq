*
*	MathIEEEDPTrans.asm for PCQ Pascal
*	Copyright 1990 Patrick Quaid
*
*	These are the stubs for the routines declared in
*	include/libraries/MathIEEEDP.i having to do with
*	transendental and trigonometric functions.
*

	XREF	_MathIEEEDoubTransBase

	SECTION	PCQ_Runtime,CODE

	XREF	_LVOIEEEDPAcos
	XDEF	_IEEEDPAcos
_IEEEDPAcos
	movem.l	8(sp),d0/d1
	move.l	_MathIEEEDoubTransBase,a6
	jsr	_LVOIEEEDPAcos(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPAsin
	XDEF	_IEEEDPAsin
_IEEEDPAsin
	movem.l	8(sp),d0/d1
	move.l	_MathIEEEDoubTransBase,a6
	jsr	_LVOIEEEDPAsin(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPAtan
	XDEF	_IEEEDPAtan
_IEEEDPAtan
	movem.l	8(sp),d0/d1
	move.l	_MathIEEEDoubTransBase,a6
	jsr	_LVOIEEEDPAtan(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPCos
	XDEF	_IEEEDPCos
_IEEEDPCos
	movem.l	8(sp),d0/d1
	move.l	_MathIEEEDoubTransBase,a6
	jsr	_LVOIEEEDPCos(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPCosh
	XDEF	_IEEEDPCosh
_IEEEDPCosh
	movem.l	8(sp),d0/d1
	move.l	_MathIEEEDoubTransBase,a6
	jsr	_LVOIEEEDPCosh(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPExp
	XDEF	_IEEEDPExp
_IEEEDPExp
	movem.l	8(sp),d0/d1
	move.l	_MathIEEEDoubTransBase,a6
	jsr	_LVOIEEEDPExp(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPFieee
	XDEF	_IEEEDPFieee
_IEEEDPFieee
	move.l	8(sp),d0
	move.l	_MathIEEEDoubTransBase,a6
	jsr	_LVOIEEEDPFieee(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPLog
	XDEF	_IEEEDPLog
_IEEEDPLog
	movem.l	8(sp),d0/d1
	move.l	_MathIEEEDoubTransBase,a6
	jsr	_LVOIEEEDPLog(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPLog10
	XDEF	_IEEEDPLog10
_IEEEDPLog10
	movem.l	8(sp),d0/d1
	move.l	_MathIEEEDoubTransBase,a6
	jsr	_LVOIEEEDPLog10(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPPow
	XDEF	_IEEEDPPow
_IEEEDPPow
	movem.l	8(sp),d0/d1/d2/d3
	move.l	_MathIEEEDoubTransBase,a6
	jsr	_LVOIEEEDPPow(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPSin
	XDEF	_IEEEDPSin
_IEEEDPSin
	movem.l	8(sp),d0/d1
	move.l	_MathIEEEDoubTransBase,a6
	jsr	_LVOIEEEDPSin(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPSinCos
	XDEF	_IEEEDPSinCos
_IEEEDPSinCos
	movem.l	12(sp),d0/d1
	move.l	8(sp),a0
	move.l	_MathIEEEDoubTransBase,a6
	jsr	_LVOIEEEDPSinCos(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPSinh
	XDEF	_IEEEDPSinh
_IEEEDPSinh
	movem.l	8(sp),d0/d1
	move.l	_MathIEEEDoubTransBase,a6
	jsr	_LVOIEEEDPSinh(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPSqrt
	XDEF	_IEEEDPSqrt
_IEEEDPSqrt
	movem.l	8(sp),d0/d1
	move.l	_MathIEEEDoubTransBase,a6
	jsr	_LVOIEEEDPSqrt(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPTan
	XDEF	_IEEEDPTan
_IEEEDPTan
	movem.l	8(sp),d0/d1
	move.l	_MathIEEEDoubTransBase,a6
	jsr	_LVOIEEEDPTan(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPTanh
	XDEF	_IEEEDPTanh
_IEEEDPTanh
	movem.l	8(sp),d0/d1
	move.l	_MathIEEEDoubTransBase,a6
	jsr	_LVOIEEEDPTanh(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPTieee
	XDEF	_IEEEDPTieee
_IEEEDPTieee
	movem.l	4(sp),d0/d1
	move.l	_MathIEEEDoubTransBase,a6
	jmp	_LVOIEEEDPTieee(a6)

	END

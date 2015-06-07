*
*	MathTrans.asm for PCQ Pascal
*	Copyright 1990 Patrick Quaid
*
*	The stub routines for calling mathtrans.library routines.
*

	XREF	_MathTransBase

	SECTION	PCQ_Runtime,CODE

	XREF	_LVOSPAcos
	XDEF	_SPAcos
_SPAcos
	move.l	4(sp),d0
	move.l	_MathTransBase,a6
	jmp	_LVOSPAcos(a6)

	XREF	_LVOSPAsin
	XDEF	_SPAsin
_SPAsin
	move.l	4(sp),d0
	move.l	_MathTransBase,a6
	jmp	_LVOSPAsin(a6)

	XREF	_LVOSPAtan
	XDEF	_SPAtan
_SPAtan
	move.l	4(sp),d0
	move.l	_MathTransBase,a6
	jmp	_LVOSPAtan(a6)

	XREF	_LVOSPCos
	XDEF	_SPCos
_SPCos
	move.l	4(sp),d0
	move.l	_MathTransBase,a6
	jmp	_LVOSPCos(a6)

	XREF	_LVOSPCosh
	XDEF	_SPCosh
_SPCosh
	move.l	4(sp),d0
	move.l	_MathTransBase,a6
	jmp	_LVOSPCosh(a6)

	XREF	_LVOSPExp
	XDEF	_SPExp
_SPExp
	move.l	4(sp),d0
	move.l	_MathTransBase,a6
	jmp	_LVOSPExp(a6)

	XREF	_LVOSPFieee
	XDEF	_SPFieee
_SPFieee
	move.l	4(sp),d0
	move.l	_MathTransBase,a6
	jmp	_LVOSPFieee(a6)

	XREF	_LVOSPLog
	XDEF	_SPLog
_SPLog
	move.l	4(sp),d0
	move.l	_MathTransBase,a6
	jmp	_LVOSPLog(a6)

	XREF	_LVOSPLog10
	XDEF	_SPLog10
_SPLog10
	move.l	4(sp),d0
	move.l	_MathTransBase,a6
	jmp	_LVOSPLog10(a6)

	XREF	_LVOSPPow
	XDEF	_SPPow
_SPPow
	movem.l	4(sp),d0/d1
	move.l	_MathTransBase,a6
	jmp	_LVOSPPow(a6)

	XREF	_LVOSPSin
	XDEF	_SPSin
_SPSin
	move.l	4(sp),d0
	move.l	_MathTransBase,a6
	jmp	_LVOSPSin(a6)

	XREF	_LVOSPSincos
	XDEF	_SPSincos
_SPSincos
	movem.l	4(sp),d0/d1
	move.l	_MathTransBase,a6
	jmp	_LVOSPSincos(a6)

	XREF	_LVOSPSinh
	XDEF	_SPSinh
_SPSinh
	move.l	4(sp),d0
	move.l	_MathTransBase,a6
	jmp	_LVOSPSinh(a6)

	XREF	_LVOSPSqrt
	XDEF	_SPSqrt
_SPSqrt
	move.l	4(sp),d0
	move.l	_MathTransBase,a6
	jmp	_LVOSPSqrt(a6)

	XREF	_LVOSPTan
	XDEF	_SPTan
_SPTan
	move.l	4(sp),d0
	move.l	_MathTransBase,a6
	jmp	_LVOSPTan(a6)

	XREF	_LVOSPTanh
	XDEF	_SPTanh
_SPTanh
	move.l	4(sp),d0
	move.l	_MathTransBase,a6
	jmp	_LVOSPTanh(a6)

	XREF	_LVOSPTieee
	XDEF	_SPTieee
_SPTieee
	move.l	4(sp),d0
	move.l	_MathTransBase,a6
	jmp	_LVOSPTieee(a6)

	END

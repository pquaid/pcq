*
*	MathFFP.asm for PCQ Pascal
*	Copyright 1990 Patrick Quaid
*
*	This implements the stubs for the routines defined in
*	Include/Libraries/MathFFP.i.  These are NOT the stubs
*	used for normal PCQ Pascal floating point math - those
*	calls are handled in-line, and are referenced by a
*	different library pointer (_p%MathBase vs. _MathBase)
*

	XREF	_MathBase

	SECTION	PCQ_Runtime,CODE

	XREF	_LVOSPAbs
	XDEF	_SPAbs
_SPAbs
	move.l	4(sp),d0
	move.l	_MathBase,a6
	jmp	_LVOSPAbs(a6)

	XREF	_LVOSPAdd
	XDEF	_SPAdd
_SPAdd
	movem.l	4(sp),d0/d1
	move.l	_MathBase,a6
	jmp	_LVOSPAdd(a6)

	XREF	_LVOSPCeil
	XDEF	_SPCeil
_SPCeil
	move.l	4(sp),d0
	move.l	_MathBase,a6
	jmp	_LVOSPCeil(a6)

	XREF	_LVOSPCmp
	XDEF	_SPCmp
_SPCmp
	movem.l	4(sp),d0/d1
	move.l	_MathBase,a6
	jmp	_LVOSPCmp(a6)

	XREF	_LVOSPDiv
	XDEF	_SPDiv
_SPDiv
	movem.l	4(sp),d0/d1
	move.l	_MathBase,a6
	jmp	_LVOSPDiv(a6)

	XREF	_LVOSPFix
	XDEF	_SPFix
_SPFix
	move.l	4(sp),d0
	move.l	_MathBase,a6
	jmp	_LVOSPFix(a6)

	XREF	_LVOSPFloor
	XDEF	_SPFloor
_SPFloor
	move.l	4(sp),d0
	move.l	_MathBase,a6
	jmp	_LVOSPFloor(a6)

	XREF	_LVOSPFlt
	XDEF	_SPFlt
_SPFlt
	move.l	4(sp),d0
	move.l	_MathBase,a6
	jmp	_LVOSPFlt(a6)

	XREF	_LVOSPMul
	XDEF	_SPMul
_SPMul
	movem.l	4(sp),d0/d1
	move.l	_MathBase,a6
	jmp	_LVOSPMul(a6)

	XREF	_LVOSPNeg
	XDEF	_SPNeg
_SPNeg
	move.l	4(sp),d0
	move.l	_MathBase,a6
	jmp	_LVOSPNeg(a6)

	XREF	_LVOSPSub
	XDEF	_SPSub
_SPSub
	movem.l	4(sp),d0/d1
	move.l	_MathBase,a6
	jmp	_LVOSPSub(a6)

	XREF	_LVOSPTst
	XDEF	_SPTst
_SPTst
	move.l	4(sp),d1
	move.l	_MathBase,a6
	jmp	_LVOSPTst(a6)

	END

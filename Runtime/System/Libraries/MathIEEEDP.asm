*
*	MathIEEEDP.asm for PCQ Pascal
*	Copyright 1990 Patrick Quaid
*
*	These are the stubs used to call the IEEE basic routines
*

	XREF	_MathIEEEDoubBasBase

	SECTION	PCQ_Runtime,CODE

	XREF	_LVOIEEEDPAbs
	XDEF	_IEEEDPAbs
_IEEEDPAbs
	movem.l	8(sp),d0/d1
	move.l	_MathIEEEDoubBasBase,a6
	jsr	_LVOIEEEDPAbs(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPAdd
	XDEF	_IEEEDPAdd
_IEEEDPAdd
	movem.l	8(sp),d0/d1/d2/d3
	move.l	_MathIEEEDoubBasBase,a6
	jsr	_LVOIEEEDPAdd(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPCeil
	XDEF	_IEEEDPCeil
_IEEEDPCeil
	movem.l	8(sp),d0/d1
	move.l	_MathIEEEDoubBasBase,a6
	jsr	_LVOIEEEDPCeil(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPCmp
	XDEF	_IEEEDPCmp
_IEEEDPCmp
	movem.l	4(sp),d2/d3
	movem.l	12(sp),d0/d1
	move.l	_MathIEEEDoubBasBase,a6
	jmp	_LVOIEEEDPCmp(a6)

	XREF	_LVOIEEEDPDiv
	XDEF	_IEEEDPDiv
_IEEEDPDiv
	movem.l	8(sp),d2/d3
	movem.l	16(sp),d0/d1
	move.l	_MathIEEEDoubBasBase,a6
	jsr	_LVOIEEEDPDiv(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPFix
	XDEF	_IEEEDPFix
_IEEEDPFix
	movem.l	4(sp),d0/d1
	move.l	_MathIEEEDoubBasBase,a6
	jmp	_LVOIEEEDPFix(a6)

	XREF	_LVOIEEEDPFloor
	XDEF	_IEEEDPFloor
_IEEEDPFloor
	movem.l	8(sp),d0/d1
	move.l	_MathIEEEDoubBasBase,a6
	jsr	_LVOIEEEDPFloor(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPFlt
	XDEF	_IEEEDPFlt
_IEEEDPFlt
	move.l	8(sp),d0
	move.l	_MathIEEEDoubBasBase,a6
	jsr	_LVOIEEEDPFlt(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPMul
	XDEF	_IEEEDPMul
_IEEEDPMul
	movem.l	8(sp),d0/d1/d2/d3
	move.l	_MathIEEEDoubBasBase,a6
	jsr	_LVOIEEEDPMul(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPNeg
	XDEF	_IEEEDPNeg
_IEEEDPNeg
	movem.l	8(sp),d0/d1
	move.l	_MathIEEEDoubBasBase,a6
	jsr	_LVOIEEEDPNeg(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPSub
	XDEF	_IEEEDPSub
_IEEEDPSub
	movem.l	8(sp),d2/d3
	movem.l	16(sp),d0/d1
	move.l	_MathIEEEDoubBasBase,a6
	jsr	_LVOIEEEDPSub(a6)
	move.l	4(sp),a0
	movem.l	d0/d1,(a0)
	rts

	XREF	_LVOIEEEDPTst
	XDEF	_IEEEDPTst
_IEEEDPTst
	movem.l	4(sp),d0/d1
	move.l	_MathIEEEDoubBasBase,a6
	jmp	_LVOIEEEDPTst(a6)

	END


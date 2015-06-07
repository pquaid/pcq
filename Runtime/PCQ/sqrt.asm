*
*	Sqrt.asm (of PCQ Pascal)
*	Copyright 1990 Patrick Quaid
*
*	This routine just implements the sqrt function using
*	Newton's method.  As I recall, this routine will in
*	some cases diverge, but it seems to work reasonably
*	well.  It figures the square root to 5 or 6 digits,
*	which in this implementation requires between, say,
*	6 and 12 iterations (for 100 and 200000, respectively).
*

	SECTION	PCQ_Runtime,CODE

	XREF	_p%MathBase

	XREF	_LVOSPDiv
	XREF	_LVOSPMul
	XREF	_LVOSPCmp
	XREF	_LVOSPAdd
	XREF	_LVOSPSub
	XREF	_LVOSPAbs

	XDEF	_p%sqrt
_p%sqrt
	move.l	4(sp),d0		; d0 := x
	move.l	#$80000042,d1		; d1 := 2.0
	move.l	_p%MathBase,a6
	jsr	_LVOSPDiv(a6)		; d0 := x / 2.0
	move.l	d0,-(sp)		; save approx on the stack

	move.l	8(sp),d0		; d0 := x
	move.l	#$C3500051,d1		; d1 := 100000.0
	jsr	_LVOSPDiv(a6)		; d0 := x / 100000.0
	move.l	d0,-(sp)		; save epsilon on the stack

ComputeError:
	move.l	4(sp),d0		; get approx
	move.l	d0,d1			; move to d1
	jsr	_LVOSPMul(a6)		; d0 := Sqr(approx)
	move.l	d0,d1			; d1 := Sqr(approx)
	move.l	12(sp),d1		; d0 := x
	jsr	_LVOSPSub(a6)		; d0 := x - Sqr...
	jsr	_LVOSPAbs(a6)		; d0 := abs(x - sqr())
	move.l	(sp),d1			; d1 := epsilon
	jsr	_LVOSPCmp(a6)
	ble.s	ReturnApprox		; if error <= epsilon, leave

	move.l	12(sp),d0		; d0 := x
	move.l	4(sp),d1		; d1 := approx
	jsr	_LVOSPDiv(a6)		; d0 := x / approx
	move.l	4(sp),d1		; d1 := approx
	jsr	_LVOSPAdd(a6)		; d0 := approx + x / approx
	move.l	#$80000042,d1		; d1 := 2.0
	jsr	_LVOSPDiv(a6)		; d0 := (approx + x/approx)/2
	move.l	d0,4(sp)		; approx := d0
	bra	ComputeError		; iterate
ReturnApprox
	move.l	4(sp),d0		; d0 := approx
	addq.l	#8,sp			; pop stack
	rts

	END

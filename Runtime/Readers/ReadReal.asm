
*	ReadReal.asm
*	of PCQ Pascal runtime library
*	Copyright (c) 1989 Patrick Quaid

*	This routine just reads a real number from the given
*	file in normal decimal form, i.e.
*		{digit}[.{digit}]
*
*       It depends on ReadInt - ReadInt needs to return in d1
*       a C style Boolean (i.e. 0 => false, other => true)
*       that answers the eternal question "Is it minus?"


	XREF	_p%ReadOneChar
	XREF	_p%GetThatChar
	XREF	_p%ReadInt
	XREF	_p%IOResult

	XREF	_p%MathBase
	XREF	_LVOSPAdd
	XREF	_LVOSPMul
	XREF	_LVOSPDiv
	XREF	_LVOSPFlt
	XREF	_LVOSPNeg

	SECTION	PCQ_Runtime,CODE

	XDEF	_p%ReadReal
_p%ReadReal

*	At the outset the address of the real variable is in a0
*	and the file record pointer is on the stack, at 4(sp)

	tst.l	_p%IOResult	; is IO system OK?
	bne	Out

	move.l	a0,-(sp)	; save var address
	move.l	8(sp),d0	; get the file record ptr
	move.l	d0,-(sp)	; set up for next call
	jsr	_p%ReadInt	; get integer part
	addq.l	#4,sp		; pop stack

	tst.l	_p%IOResult	; check again
	bne	5$

	move.w  d1,-(sp)	; save IsMinus
	beq.s	4$		; >= zero, so skip
	neg.l	d0		; take abs
4$
	move.l	_p%MathBase,a6	; get float value of int part
	jsr	_LVOSPFlt(a6)	; d0 = float of int part

	move.l	d0,-(sp)	; save it
	move.l	14(sp),a0	; get file rec

	jsr	_p%ReadOneChar	; read next char into d0
	tst.l	_p%IOResult	; did it go OK?
	bne	1$		; if not, leave
	cmp.b	#'.',d0		; is it a period?
	bne	1$		; if not, we're done already
	jsr	_p%GetThatChar	; if so, eat the decimal point
	move.l	#$A0000044,-(sp) ; store 10.0

2$	jsr	_p%ReadOneChar	; get next char into d0
	tst.l	_p%IOResult	; did IO go OK?
	bne	3$
	cmp.b	#'0',d0		; compare to '0'
	blt	3$		; not numeric
	cmp.b	#'9',d0		; 9
	bgt	3$		; skip
	and.l	#$FF,d0		; get char part
	sub.b	#'0',d0		; get value
	move.l	_p%MathBase,a6
	jsr	_LVOSPFlt(a6)	; d0 := flt(c)
	move.l	(sp),d1		; d1 := divisor
	jsr	_LVOSPDiv(a6)	; d0 := flt(c) / divisor
	move.l	4(sp),d1	; d1 := r
	jsr	_LVOSPAdd(a6)	; d0 := r + (flt(c) / divisor)
	move.l	d0,4(sp)	; save it
	move.l	(sp),d0		; d0 := divisor
	move.l	#$A0000044,d1	; d1 := 10.0
	jsr	_LVOSPMul(a6)	; d0 := divisor * 10
	move.l	d0,(sp)		; save it
	jsr	_p%GetThatChar	; eat the character we just processed
	bra	2$

3$	addq.l	#4,sp		; pop stack
1$	move.l	(sp)+,d0	; pop final value
	move.w	(sp)+,d1	; pop sign
	beq.s	5$		; if positive, skip
	move.l	_p%MathBase,a6
	jsr	_LVOSPNeg(a6)	; get -r
5$	move.l	(sp)+,a0	; retrieve address
	move.l	d0,(a0)		; store final value
Out	rts			; and return

	END

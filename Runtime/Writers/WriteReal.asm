*
*	WriteReal.asm (of the PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid
*

*	Write a real value to the appropriate file.

*	On entry, this routine expects d0 to hold the FFP value.
*	The word on top of the stack should be the number of fractional
*	digits after the decimal point to write.  The word below that
*	is the minimum field width of the integer part.  The longword
*	below that is the address of the file record

	SECTION	PCQ_Runtime,CODE

	XREF	_p%MathBase
	XREF	_LVOSPSub
	XREF	_LVOSPMul
	XREF	_LVOSPAbs
	XREF	_LVOSPFix
	XREF	_LVOSPFlt
	XREF	_LVOSPTst

	XREF	_IntToStr
	XREF	_p%WriteText
	XREF	_p%IOResult
	XREF	_p%PadOut

	XDEF	_p%WriteReal
_p%WriteReal

	tst.l	_p%IOResult	; is IO System in order?
	beq.s	1$		; if so, skip ahead
	rts

1$
	move.l	d3,-(sp)
	link	a5,#-22
	move.l	d0,-6(a5)	; -6(a5) holds the value: r
	move.l	_p%MathBase,a6	; load up the mathffp base
	jsr	_LVOSPFix(a6)	; get the integer value

	bne.s	NotZero		; if fix(x) >= 1, write int part
	move.l	-6(a5),d1	; d1 := r
	jsr	_LVOSPTst(a6)	; test the real value
	sge	d0		; d0 := r >= 0
	lea	-22(a5),a0	; get buffer address
	tst.b	d0		; look at d0
	bne.s	WasGreater	; if True, skip
	move.b	#'-',(a0)+	; pre-pend minus sign
WasGreater
	move.b	#'0',(a0)+	; add zero
	lea	-22(a5),a1	; get original position
	suba.l	a1,a0		; get length
	move.l	a0,d3		; d3 := length
	bra.s	WriteIntPart	; go write the integer part

NotZero
	lea	-22(a5),a0	; get first buffer position address
	move.l	a0,-(sp)	; push it onto stack
	move.l	d0,-(sp)	; push int value
	jsr	_IntToStr	; get character representation
	addq.l	#8,sp		; fix stack
	move.l	d0,d3		; d3 := length

WriteIntPart
	move.l	16(a5),a0	; a0 := file record address
	move.w	14(a5),d0	; d0 := int part length
	ext.l	d0		; convert to longword
	sub.l	d3,d0		; how many spaces ?
	ble.s	NoPadding	; if none, skip this
	jsr	_p%PadOut	; otherwise, write spaces
NoPadding
	lea	-22(a5),a1	; get buffer address
	jsr	_p%WriteText	; write integer part

	tst.w	12(a5)		; test fractional part length
	ble	_p%2		; if <= 0, skip all this

	move.l	-6(a5),d0	; get r
	move.l	_p%MathBase,a6
	jsr	_LVOSPAbs(a6)
	move.l	d0,-6(a5)	; r := abs(r)

	cmp.w	#30,12(a5)	; at most 30 characters, due to |outbuffer|
	ble.s	2$		; < 9 are significant anyway
	move.w	#30,12(a5)	; make it 30, just for kicks
2$	move.l	a4,-(sp)	; save a4
	sub.l	#32,sp		; make room for buffer
	move.l	sp,a4		; set to outbuffer
	move.b	#46,(a4)+	; make decimal point
	move.l	-6(a5),d0	; d0 := r
	jsr	_LVOSPFix(a6)	; d0 := fix(r)
	jsr	_LVOSPFlt(a6)	; d0 := flt(fix(r))
	move.l	d0,d1		;
	move.l	-6(a5),d0	; d0 := r
	jsr	_LVOSPSub(a6)	; d0 := r - flt(fix(r)), i.e just frac part
	move.l	d0,d1		;
	move.l	#$A0000044,d0	; d0 := 10.0
	jsr	_LVOSPMul(a6)	; d0 := (r - flt(fix(r))) * 10.0
	move.l	d0,-6(a5)	; r  := ^
	move.w	#1,-2(a5)	; set up for loop
_p%3
	move.l	-6(a5),d0	; get r
	jsr	_LVOSPFix(a6)	; d0 := fix(r)
	add.b	#'0',d0		; d0 := r + ord('0')
	move.b	d0,(a4)+	; put this char into buffer

	move.l	-6(a5),d0	; get r
	jsr	_LVOSPFix(a6)	; d0 := fix(r)
	jsr	_LVOSPFlt(a6)	; d0 := flt(fix(r))
	move.l	d0,d1
	move.l	-6(a5),d0
	jsr	_LVOSPSub(a6)	; d0 := r - flt(fix(r))
	move.l	#$A0000044,d1	; d1 := 10.0
	jsr	_LVOSPMul(a6)	; d0 := (r - flt(fix(r)) * 10.0
	move.l	d0,-6(a5)	; r := --^

	add.w	#1,-2(a5)	; i := i + 1
	move.w	12(a5),d0	; get frac length
	cmp.w	-2(a5),d0
	bge	_p%3		; if i < frac length, loop

	move.w	12(a5),d3	; get fractional length back
	ext.l	d3		; make it 32 bits
	addq.l	#1,d3		; add one for decimal point
	move.l	sp,a1		; get address of buffer
	move.l	16(a5),a0	; get file record address
	jsr	_p%WriteText	; and copy it into the buffer
	add.w	#32,sp
	move.l	(sp)+,a4	; restore a4
_p%2
	unlk	a5		; restore stack frame
	move.l	(sp)+,d3
	rts			; and get out

	END

*
*
*	IntToStr.asm (of PCQ Pascal)
*	Copyright 1990 Patrick Quaid
*
*	This routine converts an integer to a string.
*

*	On entry, the top longword on the stack contains the return
*	address, the next word contains the integer value, and the
*	word below that has the address of the string.
*

*	This routine creates the string of characters in a
*	temporary work area backwards, then copies the characters
*	into the provided destination string.

	SECTION	PCQ_Runtime,CODE

	XREF	i_ldiv
	XDEF	_IntToStr
_IntToStr
	move.l	4(sp),d0	; get value to convert

	sub.l	#14,sp		; allocate extra work space
	move.l	sp,a1		; use a1 to point at it

	tst.l	d0		; is d7 < 0
	bge.s	1$		; if not, skip
	neg.l	d0		; get abs(d7)
1$
	move.l	#10,d1		; d1 := 10
	jsr	i_ldiv		; d0 := d0 div 10, d1 := d0 mod 10
	add.b	#'0',d1		; make d1.b a character digit
	move.b	d1,(a1)+	; save it, backwards
	tst.l	d0		; is d0 zero yet?
	bgt	1$		; if not, loop

	tst.l	18(sp)		; look at original again
	bge.s	2$		; if > 0, skip this
	move.b	#'-',(a1)+	; attach minus sign
2$
	move.l	22(sp),a0	; get destination address
3$
	move.b	-(a1),d0	; get first char
	move.b	d0,(a0)+	; save it
	cmp.l	a1,sp		; compare to start
	blt.s	3$		; loop if there's more to do

	move.b	#0,(a0)		; null terminate the string
	add.l	#14,sp		; pop stack space

	sub.l	8(sp),a0	; get length current - startpos
	move.l	a0,d0		; into return register
	rts

	END

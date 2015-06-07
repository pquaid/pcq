*
*	WriteCharray.asm (of PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid
*

*	Write a character array to a text file.

	SECTION	PCQ_Runtime,CODE

	XREF	_p%PadOut
	XREF	_p%WriteText
	XREF	_p%IOResult

	XDEF	_p%WriteCharray
_p%WriteCharray

	tst.l	_p%IOResult		; is IO OK?
	bne	2$			; if not, leave
	move.l	6(sp),a0		; get file record address
	move.w	4(sp),d1		; get field width
	ext.l	d1			; make it 32 bit
	sub.l	d3,d1			; subtract actual width
	ble.s	1$			; if less than, skip this
	movem.l	d0/d3,-(sp)		; save address and length
	move.l	d1,d0			; set up for call
	jsr	_p%PadOut		; write the pad characters
	movem.l	(sp)+,d0/d3		; restore address and length
1$	move.l	d0,a1			; set up for call
	jsr	_p%WriteText		; write the array
2$	rts

	END

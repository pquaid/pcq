
*	WriteInt.asm (of PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid

*	Write an integer to a text file.

*	Upon entry, d0 holds the value to write.  The word on top of
*	the stack holds the minumum field width, and the long word
*	below that holds the file record address
*

	SECTION	PCQ_Runtime,CODE

	XREF	_p%PadOut
	XREF	i_ldiv
	XREF	_p%WriteText
	XREF	_p%IOResult
	XREF	_IntToStr

	XDEF	_p%WriteInt
_p%WriteInt

	tst.l	_p%IOResult		; is IO system OK?
	bne	5$			; if not, leave

	sub.l	#16,sp			; allocate work space
	move.l	sp,-(sp)		; push this address
	move.l	d0,-(sp)		; push integer value
	jsr	_IntToStr		; fill buffer with integer
	addq.l	#8,sp			; pop stuff off stack

	move.l	d0,-(sp)		; save length of ascii representation
	move.l	26(sp),a0		; a0 := file record address
	move.w	24(sp),d0		; d0 := the field width
	sub.l	(sp),d0			; how many extras?
	ble	4$			; if none, skip this
	jsr	_p%PadOut		; write d0 spaces to a0 file rec
4$	move.l	(sp)+,d3		; retrieve representation length
	move.l	sp,a1			; point to first char
	jsr	_p%WriteText		; write d3 bytes at a1 to a0
	add.l	#16,sp			; free work space

5$	rts

	END


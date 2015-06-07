
*	WriteChar.asm (of PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid

*	This routine writes a single character to a text file

	SECTION	PCQ_Runtime,CODE

	XREF	_p%PadOut
	XREF	_p%WriteText
	XREF	_p%IOResult

	XDEF	_p%WriteChar
_p%WriteChar:

	tst.l	_p%IOResult	; is everything OK
	bne	2$		; if not, skip
	subq.w	#2,sp		; make buffer area
	move.b	d0,(sp)		; put the character into the buffer
	move.l	8(sp),a0	; load up the file record address
	move.w	6(sp),d0	; get number of pads
	ext.l	d0		; make it 32 bits for safety
	subq.l	#1,d0		; minus one for the character itself
	ble.s	1$		; if it's <= 0 then skip
	jsr	_p%PadOut	; write pad spaces
1$	move.l	sp,a1		; get address of buffer
	moveq.l	#1,d3		; one character long
	jsr	_p%WriteText	; write the character
	addq.w	#2,sp		; kill the buffer
2$	rts

	END

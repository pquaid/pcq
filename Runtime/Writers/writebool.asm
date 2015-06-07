
*	WriteBool.asm (of PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid

*	This writes boolean values.  The write routines are so much
*	simpler than the read routines....

	SECTION	PCQ_Runtime,CODE

	XREF	_p%PadOut
	XREF	_p%WriteText
	XREF	_p%IOResult

*	On Entry, d0.b holds a boolean value.  The top word on the
*	stack has the pad characters, and the longword below that
*	has the address of the file record

	XDEF	_p%WriteBool
_p%WriteBool:

	tst.l	_p%IOResult		; first make sure we're OK
	bne	4$			; if not, leave now
	move.l	6(sp),a0		; get file record
	tst.b	d0			; what is the value to write?
	beq.s	1$			; if it's false, go around
	lea     TrueText(pc),a1		; load up true text
	moveq	#4,d3			; 4 characters long
	bra.s	2$			; and skip this
1$	lea	FalseText(pc),a1	; load FALSE
	moveq	#5,d3			; 5 characters long
2$	move.w	4(sp),d0		; get field width
	ext.l	d0			; make it 32 bits wide
	sub.l	d3,d0			; subtract text length
	ble.s	3$			; if <= 0 then skip padding
	movem.l	a1/d3,-(sp)		; save address and length
	jsr	_p%PadOut		; write pad characters
	movem.l	(sp)+,a1/d3		; restore regs
3$	jsr	_p%WriteText		; copy into buffer
4$	rts

TrueText	dc.b	'TRUE'
FalseText	dc.b	'FALSE'
        EVEN

	END


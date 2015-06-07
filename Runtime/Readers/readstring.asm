
*	ReadString.asm (of PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid

*	This reads a string from a text file.

	INCLUDE	"/FileRec.i"

*	Upon entry, a0 points to the string variable address.  That
*	variable is expected to point to a buffer big enough to hold
*	the string.  The longword on top of the stack holds the file
*	record address

	SECTION	PCQ_Runtime,CODE

	XREF	_p%ReadOneChar
	XREF	_p%GetThatChar
	XREF	_p%IOResult

	XDEF	_p%ReadString
_p%ReadString

	tst.l	_p%IOResult	; is IO safe?
	bne	3$
	move.l	(a0),a1		; get actual buffer address
	move.l	4(sp),a0	; get the file record address
	move.l	#0,d1		; length so far
1$	movem.l	a1/d1,-(sp)	; save buffer address
	jsr	_p%ReadOneChar	; get the next character
	movem.l	(sp)+,a1/d1	; retrieve buffer and length
	tst.l	_p%IOResult	; was there an error?
	bne	3$
	move.b	d0,0(a1,d1.l)	; save the character
	addq.l	#1,d1		; increment the pointer
	cmp.b	#10,d0		; was it a linefeed?
	beq.s	2$		; if so, leave
	tst.b	EOF(a0)		; or if it's at EOF
	bne.s	2$		; leave if true
	movem.l	a1/d1,-(sp)	; if not, save regs
	jsr	_p%GetThatChar	; and eat the current character
	movem.l	(sp)+,a1/d1	; get the regs back
	bra	1$		; and loop
2$	move.b	#0,-1(a1,d1.l)	; null-terminate the string
3$	rts			; and return

	END

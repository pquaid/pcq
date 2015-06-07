
*	ReadCharray.asm (of PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid

*	This reads a character array, one character at a time, from
*	a text file.

*	On entry, a0 holds the address of the variable and d3 holds
*	its maximum length.  Characters are read into the buffer until
*	the buffer is full, or a linefeed is read.  In the latter case,
*	the remaining array space is filled with spaces.

	SECTION	PCQ_Runtime,CODE

	INCLUDE	"/FileRec.i"

	XREF	_p%ReadOneChar
	XREF	_p%GetThatChar
	XREF	_p%IOResult

	XDEF	_p%ReadCharray
_p%ReadCharray

	tst.l	_p%IOResult		; is IO OK?
	bne	3$
	move.l	a0,a1			; move buffer address to a1
	move.l	4(sp),a0		; a0 holds the file record
	move.l	#0,d1			; d1 holds the current length
1$	movem.l	a1/d1/d3,-(sp)		; save buffer, length, max
	jsr	_p%ReadOneChar		; get the first character
	movem.l	(sp)+,a1/d1/d3		; restore the registers
	cmp.b	#10,d0			; was it a linefeed?
	bne	2$			; if not, keep going
	bra.s	rarfill			; fill in the rest of array
2$	move.b	d0,0(a1,d1.l)		; put the character into buffer
	addq.l	#1,d1			; advance buffer ptr
	movem.l	a1/d1/d3,-(sp)		; save regs
	jsr	_p%GetThatChar		; eat the char
	movem.l	(sp)+,a1/d1/d3		; restore the regs
	cmp.l	d1,d3			; are we at max?
	bgt	1$			; if not, loop
3$	rts				; otherwise return
rarfill
	move.b	#' ',0(a1,d1.l)		; write a space into array
	addq.l	#1,d1			; advance ptr
	cmp.l	d1,d3			; are we at the end?
	bgt	rarfill			; if not, loop
	rts				; else return

	END


*	ReadOneChar.asm (of PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid

	XREF	_p%FillBuffer
	XREF	_p%IOResult

*	ReadOneChar returns the current character in d0, without actually
*	'eating' it.  If the file is interactive, this will cause a DOS
*	read.  If we are at EOF, this will generate an error.
*

*	Algorithm:
*
*	if INTERACTIVE then
*	    if CURRENT >= LAST then
*		FillBuffer
*	d0 := (CURRENT)
*

*	On entry, a0 has the address of the file rec
*	The character is returned in d0

	INCLUDE	"/FileRec.i"

	SECTION	PCQ_Runtime,CODE

	XDEF	_p%ReadOneChar
_p%ReadOneChar

	tst.l	_p%IOResult		; is IO OK?
	bne	3$			; if not, leave
	tst.b	EOF(a0)			; are we at eof?
	bne	3$			; if not, skip
	tst.b	INTERACTIVE(a0)		; is it interactive?
	beq.s	2$
	move.l	CURRENT(a0),a1		; get current address
	cmpa.l	LAST(a0),a1		; past end?
	blt.s	2$			; if not, skip
	move.l	a0,-(sp)		; save a0 just in case
	jsr	_p%FillBuffer		; Fill the buffer
	move.l	(sp)+,a0		; restore
2$	move.l	CURRENT(a0),a1		; get address of current char
	move.b	(a1),d0			; get the char
3$	rts

*	GetThatChar
*	If you've checked the current character with ReadOneChar
*	and you want to 'eat' it, you call this routine.  These
*	two routines are used in the Text file input routines.
*
*	Algorithm:
*
*	CURRENT := CURRENT + 1
*	if not INTERACTIVE then
*	    if CURRENT >= LAST then
*		FillBuffer
*

*	On entry this routine expects a0 to hold the address of the
*	file record

	XDEF	_p%GetThatChar
_p%GetThatChar

	tst.l	_p%IOResult		; how's the IO system?
	bne	1$			; not well.  Better leave
	move.l	CURRENT(a0),a1
	adda.l	#1,a1			; advance CURRENT
	move.l	a1,CURRENT(a0)		; save it
	tst.b	INTERACTIVE(a0)		; is it interactive ?
	bne.s	1$			; if so, skip
	cmpa.l	LAST(a0),a1		; past end?
	blt.s	1$			; if not, skip
	movem.l	d0/a0,-(sp)		; save the address & character
	jsr	_p%FillBuffer		; fill the buffer
	movem.l	(sp)+,d0/a0		; get them back
1$	rts

	END

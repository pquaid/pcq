
*	ReadInt.asm (of PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid

*	This routine reads an integer from a text file.

	INCLUDE	"/FileRec.i"

	SECTION	PCQ_Runtime,CODE

	XREF	_p%ReadOneChar
	XREF	_p%GetThatChar
	XREF	_p%IOResult

* Algorithm for ReadInt:
*
*	save variable address
*	repeat
*	    Get the next character
*	    if we are at eof
*		set IOResult
*		fix stack
*		return
*	    if current character is white space
*		eat it
*	until current character is not white space
*	if the character is a linefeed
*	    set IOResult
*	    fix stack
*	    return
*	if the character is '-' then
*	    IsMinus := True
*	    eat that character
*	    get the next one
*	else
*	    IsMinus := False
*	result := 0
*	while the current character is a digit
*	    result := result * 10 + value of current character
*	    eat the character
*	    get the next character
*	correct sign
*	restore variable address
*	return


* Upon entry, a0 has the address of the variable to be updated.  Since
* this routine will be used to read 32-bit integers as well as 16-bit
* 'shorts', we simply pass a0 back to the caller.  On top of the stack
* is the file record.


	XDEF	_p%ReadInt
_p%ReadInt

        move.l  a0,-(sp)        ; save file var address
	tst.l	_p%IOResult	; is IO OK?
	bne	Abort
	move.l	8(sp),a0	; get the file record
1$	tst.b	EOF(a0)		; are we at EOF?
	bne	AbortEOF	; if so, leave
	jsr	_p%ReadOneChar	; get the next character
	tst.l	_p%IOResult	; did it cause an error?
	bne	Abort		; if so, leave
	cmp.b	#' ',d0		; is the character white space?
	bgt	AfterWhiteSpace ; if not, leave
	jsr	_p%GetThatChar	; advance the buffer pointer
	bra	1$
AbortEOF
	move.l	#58,_p%IOResult	; set EOF before first digit
Abort
	move.l	(sp)+,a0	; get variable address
	moveq.l	#0,d0		; return 0
	rts

AfterWhiteSpace
	clr.w   -(sp)		; IsMinus := False
	cmp.b	#'-',d0		; is the character a '-'
	bne.s	3$		; if not, skip this
	jsr	_p%GetThatChar	; eat the character
	jsr	_p%ReadOneChar	; and get the next one
	move.w  #-1,(sp)	; IsMinus := True
3$	cmp.b	#'0',d0		; is first char a digit?
	blt.s	NoNumber	; if < 0 then is isn't
	cmp.b	#'9',d0		; keep checking
	ble.s	DigitOK		; is <= 9, we're OK
NoNumber
	move.l	#59,_p%IOResult	; set No Digits for ReadInt
	addq.w	#2,sp
	bra	Abort
DigitOK
	moveq	#0,d1		; Result := 0
5$	cmp.b	#'0',d0		;
	blt	Leave		; if < '0' leave now
	cmp.b	#'9',d0
	bgt	Leave		; if > '9' leave
	sub.b	#'0',d0		; get digit value

* Multiply d1 * 10

	add.l	d1,d1		; d1 := d1 * 2
	move.l	d1,-(sp)	; save d1 * 2
	add.l	d1,d1		; d1 := d1 * 4
	add.l	d1,d1		; d1 := d1 * 8
	add.l	(sp)+,d1	; d1 := d1 * 10

	and.l	#15,d0		; no funny business...
	add.l	d0,d1		; and add to running total
	move.l	d1,-(sp)	; save the running total
	jsr	_p%GetThatChar	; eat the current char
	jsr	_p%ReadOneChar	; get the next character
	move.l	(sp)+,d1	; get values back
	tst.b	EOF(a0)		; are we at eof?
	beq	5$		; if not, continue
Leave
	move.l	d1,d0		; set up for return
	move.w	(sp)+,d1	; was it minus?
	beq.s	6$		; if not, skip this
	neg.l	d0		; d0 := -d0
6$	move.l	(sp)+,a0	; retrieve variable address
	rts

	END

*
*	CheckRange.asm (of the PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid
*
*	This routine makes sure an array index is within its
*	proper bounds.  This used to be handled in-line, but
*	I wanted to expand the error checking mechanism a bit.
*

*	On entry, the stack looks like:
*	0(sp)	return address
*	4(sp)	the index value
*	8(sp)	the maximum value
*
*	Unlike all other routines, this one pops values off the stack
*	before it returns - thus when it returns no work is necessary
*	on the stack.  Also note that as of version 1.2, this routine
*	can no longer use any registers it doesn't save.


	SECTION	PCQ_Runtime,CODE

	XREF	_p%ExitWithAddr
	XREF	_ExitAddr

	XDEF	_p%CheckRange
_p%CheckRange
	move.l	d0,-(sp)		; save d0
	tst.l	4(sp)			; compare index to 0
	blt.s	BadIndex		; die if less than
	move.l	8(sp),d0		; d0 := index value
	cmp.l	12(sp),d0		; compare it to max value
	bgt.s	BadIndex		; too high
FixStack
	move.l	4(sp),12(sp)		; set new return address
	lea	12(sp),sp		; pop three parameters
	rts
BadIndex
	move.l	#60,d0			; set up for call
	jsr	_p%ExitWithAddr		; blow up
	bra	FixStack		; we might return...

	END

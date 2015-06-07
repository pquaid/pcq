
*	WriteShort.asm (of PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid

*	Write a short integer to a text file.  This just extends the
*	value and writes it with the integer routine.

*	Upon entry, d0 holds the value to write.  The word on top of
*	the stack holds the minumum field width, and the long word
*	below that holds the file record address
*

	SECTION	PCQ_Runtime,CODE

	XREF	_p%WriteInt

	XDEF	_p%WriteShort
_p%WriteShort:

	ext.l	d0
	jmp	_p%WriteInt

	END

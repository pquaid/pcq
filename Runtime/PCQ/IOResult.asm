*
*	IOResult.asm of PCQ Pascal runtime library
*	Copyright (c) 1991 Patrick Quaid
*
*	This file implements the IOResult function
*

	XDEF	_IOResult
	XDEF	_p%IOResult

	SECTION	PCQ_Runtime,CODE

_IOResult
	move.l	_p%IOResult,d0
	move.l	#0,_p%IOResult
	rts

	SECTION	PCQ_DATA,DATA

_p%IOResult	dc.l	0

	END

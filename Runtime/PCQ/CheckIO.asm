*
*	CheckIO.asm (of the PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid
*
*	If IO checking is enabled, this routine is called after each
*	library IO routine.  If there has been an error, this routine
*	will exit the program with an appropriate error.
*
*	This routine expects no particular registers, and if there
*	is no error the registers will all be returned intact.  The
*	PSW will be changed.
*

	SECTION	PCQ_Runtime,CODE

	XREF	_p%exit
	XREF	_ExitAddr
	XREF	_p%IOResult

	XDEF	_p%CheckIO
_p%CheckIO
	tst.l	_p%IOResult		; has there been an IO error?
	beq.s	1$			; no error
	move.l	_p%IOResult,d0		; set up for call
	move.l	(sp),_ExitAddr		; use CALLERS address
	jsr	_p%exit			; it might return....
1$	rts				; return to regularly scheduled program

	END


*	Flush.asm (of the PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid

*	Write the contents of the file buffer to the DOS file.

*	Algorithm for FlushBuffer
*
*	Write CURRENT - BUFFER bytes to HANDLE
*	set CURRENT to BUFFER
*

*	Upon entry, this routine expects the file record in a0.
*	a0 is preserved.

	SECTION PCQ_Runtime,CODE

	XREF	_LVOWrite
	XREF	_LVOIoErr

	XREF	_p%DOSBase
	XREF	_p%IOResult

	INCLUDE	"/FileRec.i"

	XDEF	_p%FlushBuffer
_p%FlushBuffer

*	move.l	HANDLE(a0),d1		; get the file handle
*	bne.s	1$			; are we OK
*	jsr	_p%MayOpenOutput	; it's not open.  Try to get Output

*	We don't do that stuff anymore.

	movem.l	d2/d3,-(sp)		; save non-scratch regs
	move.l	HANDLE(a0),d1		; if we got here, it must be OK
	move.l	BUFFER(a0),d2		; get buffer address
	move.l	CURRENT(a0),d3		; get current address
	sub.l	d2,d3			; get number of bytes to write
	ble.s	3$			; if <= 0, skip the write
	move.l	_p%DOSBase,a6		; get the library base
	movem.l	d3/a0,-(sp)		; save bytes to write,file ptr
	jsr	_LVOWrite(a6)		; and write it
	movem.l	(sp)+,d3/a0		; retrieve them
	cmp.l	d3,d0			; did we write proper number?
	beq.s	2$			; if so, go ahead
	jsr	_LVOIoErr(a6)		; get the error number
	move.l	d0,_p%IOResult		; set IOResult
	bra.s	3$			; do NOT update file rec
2$	move.l	BUFFER(a0),CURRENT(a0)	; reset current ptr to buffer adr
3$	movem.l	(sp)+,d2/d3
	rts

*	MayOpenOutput
*
*	This routine opens a Standard Output window for programs that
*	may have started from the Workbench.  It gets the window spec
*	from _StdOutName, which is defined either in the User program
*	or, by default, in this library.  If the Input file is already
*	open, and it's interactive, that already open file is used.
*
*	Algorithm for MayOpenOutput:
*
*	if a0 <> Output then
*	    generate a runtime error
*	if Input is open and interactive then
*	    Output.Handle := Input.Handle
*	else
*	    Open(StdOutName, Output)
*	    if it did not open OK
*		generate a runtime error
*

*	Upon entry to this routine, a0 holds the address of the
*	File Record, which may or may not be Output.
*
*	XREF	_p%ExitWithAddr
*	XREF	_p%Open
*	XREF	_StdOutName
*	XREF	_Input
*	XREF	_Output

*_p%MayOpenOutput
*	cmpa.l	#_Output,a0	; is it Output?
*	beq.s	1$		; if so, skip this
*	move.l	#56,d0		; runtime error
*	jsr	_p%ExitWithAddr	; generate the error
*1$	move.l	#_Input,a1	; get Input ptr
*	tst.l	HANDLE(a1)	; is it open?
*	beq	2$		; if not, open a new one
*	tst.b	INTERACTIVE(a1)	; is it interactive?
*	bne	2$		; if not, open a new file
*	move.l	HANDLE(a1),HANDLE(a0)  ; move handle over
*	rts			; and try that one
*2$	move.l	#80,MAX(a0)	; set up for Open call
*	move.l	#1,RECSIZE(a0)	; Text file
*	move.w	#1006,ACCESS(a0)	; it's an output file (ModeNewFile)
*	move.l	_StdOutName,-(sp)	; push the file name
*	move.l	a0,-(sp)	; push the file record address
*	jsr	_p%Open		; try to open this file
*	move.l	(sp)+,a0	; get file record ptr back
*	addq.l	#4,sp		; pop other arg
*	tst.b	d0		; did it go OK?
*	bne.s	3$		; if so, go on
*	move.l	#57,d0		; if not, generate an error
*	jsr	_p%ExitWithAddr	; goodbye
*3$	rts			; return to sender

	END

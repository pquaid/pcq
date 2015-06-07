
	SECTION	PCQ_Runtime,CODE

*	PCQStart.asm (of PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid

*	This is the normal startup code for the programs.

	XREF	_AbsExecBase
	XREF	_LVOOpenLibrary
	XREF	_LVOCloseLibrary
	XREF	_LVOFindTask
	XREF	_LVOWaitPort
	XREF	_LVOGetMsg
	XREF	_LVOReplyMsg
	XREF	_LVOForbid

	XREF	_LVOInput
	XREF	_LVOOutput
	XREF	_LVOIsInteractive

	XREF	_LVOFreeRemember

	XREF	newkey
	XREF	_HeapError
	XREF	filekey
	XREF	_StdInName
	XREF	_StdOutName

	XREF	_p%FillBuffer
	XREF	_p%FlushBuffer
	XREF	_p%Close
	XREF	_p%Open
	XREF	_p%exit

	XREF	_ExitProc
	XREF	_ExitCode
	XREF	_ExitAddr

	XREF	_CommandLine
	XREF	_p%DOSBase
	XREF	_p%IntuitionBase
	XREF	_p%MathBase
	XREF	_p%WorkBenchMsg
	XREF	dosname
	XREF	intuitionname
	XREF	mathname
	XREF	StkPtr

	XREF	_Input
	XREF	_Output
	
	INCLUDE	"/FileRec.i"

;	Define entry point

	xdef	_p%initialize
_p%initialize

;	Save stack pointer for exit() routine

	move.l	sp,StkPtr	; save stack pointer
	add.l	#4,StkPtr	; account for this jsr to get to original

;	Save the command line pointer to CommandLine

	move.l	a0,_CommandLine
        beq.s   dont_nullit

	move.b	#0,0(a0,d0.w)	; null terminate it

dont_nullit
;	Check for WB or CLI

	move.l	_AbsExecBase,a6
	suba.l	a1,a1
	jsr	_LVOFindTask(a6)
	move.l	d0,a4

;	are we running from a CLI?

	tst.l	172(a4)			; 172 = pr_CLI
	bne	fromCLI

	lea	92(a4),a0		; 92 = pr_MsgPort
	jsr	_LVOWaitPort(a6)
	lea	92(a4),a0
	jsr	_LVOGetMsg(a6)
	move.l	d0,_p%WorkBenchMsg	; save the WB message

	bra	openLibs		; do the rest of the startup


fromCLI:

;	clear the Workbench message

	move.l	#0,_p%WorkBenchMsg

;	Open libraries

openLibs:
	moveq	#0,d0
	move.l	d0,_p%DOSBase
	move.l	d0,_p%MathBase

	lea	intuitionname,a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_p%IntuitionBase
	beq	_p%exit

	lea	dosname,a1
	moveq	#0,d0
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_p%DOSBase
	beq	_p%exit

	lea	mathname,a1
	moveq	#0,d0
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_p%MathBase
	beq	_p%exit

;	set up standard exit procedure

	move.l	#_p%CloseAndFree,_ExitProc

	clr.l	newkey
	clr.l	_HeapError

;	Find standard file handles

	tst.l	_p%WorkBenchMsg		; run from the Workbench?
	beq	OpenFiles		; if not, open standard stuff

	move.l	_StdInName,d0		; get input name
	beq.s	OpenStdOut		; if Nil, skip this
	move.l	d0,-(sp)		; save the name
	lea	_Input,a0		; get address of file record
	move.l	#80,MAX(a0)		; set buffer size = 80
	move.l	a0,-(sp)		; push the address
	jsr	_p%Open			; open the file
	addq.l	#8,sp			; fix the stack
        tst.b   d0                      ; opened OK?
	bne.s	1$			; if open, skip the following
	move.l	#53,d0			; set runtime error
	jsr	_p%exit			; quit the program
1$	lea	_Input,a0		; retrieve the file record
	tst.b	INTERACTIVE(a0)		; is it interactive
	beq.s	OpenStdOut		; Open a new file
	move.l	_StdInName,d0		; get input name
	cmp.l	_StdOutName,d0		; are the names equal?
	bne.s	OpenStdOut		; if not, skip this
	move.l	HANDLE(a0),d0		; get the file handle
	lea	_Output,a0		; get the output file
	move.l	d0,HANDLE(a0)		; use the same handle for output
	move.b	#-1,INTERACTIVE(a0)	; set interactive to true
	rts				; and get back to main
OpenStdOut
	move.l	_StdOutName,d0		; get output name
	beq	1$			; if nil, leave
	move.l	d0,-(sp)		; push the output file name
	move.l	#_Output,-(sp)		; push the file record
	jsr	_p%Open			; open the file
	addq.l	#8,sp			; fix the stack
        tst.b   d0                      ; opened OK?
	bne.s	1$			; if so, skip the following
	move.l	#57,d0			; set runtime error
	jsr	_p%exit			; and leave
1$	rts				; go back to main program
OpenFiles
	move.l	_p%DOSBase,a6
	jsr	_LVOInput(a6)		; get standard in
	move.l	#_Input,a0		; get input file record
	move.l	d0,HANDLE(a0)		; set handle
	beq	_p%exit			; if zero, quit
	move.l	d0,d1			; set up for next call
	jsr	_LVOIsInteractive(a6)	; is it interactive?
	move.l	#_Input,a0		; get file record again
	move.b	d0,INTERACTIVE(a0)	; set flag
	beq.s	StdInNotInteractive	; skip this if not interactive
	move.l	BUFFER(a0),a1		; get buffer address
	add.l	#1,a1			; make end one byte further on
	move.l	a1,MAX(a0)		; set buffer size
	move.l	a1,CURRENT(a0)		; will need a read
	bra	OpenStdOutput
StdInNotInteractive
	jsr	_p%FillBuffer		; fill the buffer
OpenStdOutput
	jsr	_LVOOutput(a6)		; get ouput file handle
	move.l	#_Output,a0		; get file record
	move.l	d0,HANDLE(a0)		; set value
	beq	_p%exit			; if zero, quit
	move.l	d0,d1			; set up for call
	jsr	_LVOIsInteractive(a6)	; is it interactive?
	move.l	#_Output,a0		; get file record
	move.b	d0,INTERACTIVE(a0)	; set flag

1$	rts

*	Close all the open files

_p%CloseAndFree

	move.l	#_Output,a0	; write any pending output
	jsr	_p%FlushBuffer

1$	move.l	filekey,d0	; get the current file key
	beq.s	2$		; if it's empty, skip ahead
	move.l	d0,a0		; otherwise make the call
	jsr	_p%Close	; to close the file
	bra.s	1$		; and loop 'til file list is empty

2$	rts				; and return to Exit

	END


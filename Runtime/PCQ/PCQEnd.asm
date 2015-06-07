*
*
*   PCQEnd.asm of PCQ Pascal
*   Copyright (c) 1991 Patrick Quaid
*
*   This is the shut-down code for all PCQ programs.  It just
*   calls all the exit procedures, closes DOS and Intuition, and
*   cuts out.  It was seperated from PCQStart because of the new
*   minimal initialization stuff.
*

	SECTION	PCQ_Runtime,CODE

	XREF	_p%IntuitionBase
	XREF	_p%DOSBase
	XREF	_p%MathBase
	XREF	_AbsExecBase
	XREF	_p%WorkBenchMsg
	XREF	StkPtr
	XREF	newkey

	XREF	_LVOForbid
	XREF	_LVOReplyMsg
	XREF	_LVOCloseLibrary
	XREF	_LVOFreeRemember

	XDEF	_ExitProc
	XDEF	_ExitCode
	XDEF	_ExitAddr


	XDEF	_p%ExitWithAddr
_p%ExitWithAddr
	move.l	(sp),_ExitAddr

*	falls through to exit...


	XDEF	_p%exit
_p%exit
	move.l	d0,_ExitCode		; save the exit code
1$	move.l	_ExitProc,a0		; get the first exit proc
	move.l	a0,d0			; set the z flag
	beq.s	2$			; if empty, skip around
	move.l	#0,_ExitProc		; set it to null
	jsr	(a0)			; call the exit proc
	bra.s	1$			; loop for next ExitProc
2$
	lea	newkey,a0		; allocated any memory?
	move.l	a0,d0			; set flags
	beq.s	3$			; if not, skip around
	moveq.l	#-1,d0			; really forget
	move.l	_p%IntuitionBase,a6	; get library base
	jsr	_LVOFreeRemember(a6)	; free it all
3$
	move.l	_AbsExecBase,a6		; get Exec base
	move.l	_p%IntuitionBase,a1	; get Intuition library
	move.l	a1,d0			; to set flags
	beq.s	4$			; if it wasn't open, don't close
	jsr	_LVOCloseLibrary(a6)	; close Intuition
4$
	move.l	_p%DOSBase,a1		; get DOS library base
	move.l	a1,d0			; set flags
	beq.s	5$			; if it wasn't open, skip
	jsr	_LVOCloseLibrary(a6)	; close DOS
5$
	move.l	_p%MathBase,a1		; get Math base
	move.l	a1,d0			; was it open?
	beq.s	6$			; if not, skip
	jsr	_LVOCloseLibrary(a6)	; close it
6$
	tst.l	_p%WorkBenchMsg		; were we run from Workbench?
	beq	7$			; No.  Skip this

	jsr	_LVOForbid(a6)		; so we won't be unloaded too soon
	move.l	_p%WorkBenchMsg,a1	; get our message
	jsr	_LVOReplyMsg(a6)	; return the WB message
7$
	move.l	_ExitCode,d0		; get the DOS return code
	move.l	StkPtr,sp		; get the original stack pos
	rts				; lay down and die...

	SECTION	PCQ_BSS,BSS

_ExitProc ds.l	1
_ExitCode ds.l	1
_ExitAddr ds.l	1

	END

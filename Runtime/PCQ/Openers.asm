
*	Openers.asm (of PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid

*	This file takes care of opening and closing DOS files.  In
*	much the same way as the memory routines, these routines keep a
*	list of the open files around.  Open() puts the files on the list
*	and Close() takes them off.

	SECTION	PCQ_Runtime,CODE

	XREF	_p%DOSBase
	XREF	_LVOOpen
	XREF	_LVOIsInteractive
	XREF	_LVOIoErr
	XREF	_p%new
	XREF	_p%dispose
	XREF	_p%ExitWithAddr
	XREF	_LVORead
	XREF	_LVOClose
	XREF	_p%IOResult
	XREF	_p%FlushBuffer
	XREF	i_lmul
	XREF	i_ldiv

	XDEF	filekey

*	OpenB is the routine called by the open() and reopen() calls.
*	It calls, in turn, Open, then returns true or false depending
*	on whether there was an error.  It always clears IOResult.


*	algorithm for open:
*
*	HANDLE := DOSOpen handle
*	if then handle = nil
*	    set IOResult := IoErr
*	    return
*	INTERACTIVE := IsInteractive
*	if INTERACTIVE and (Access = ModeOldFile) then
*	    MAX := RECSIZE
*	else
*	    MAX := (MAX div RECSIZE) * RECSIZE
*	    if MAX = 0 then
*		MAX := RECSIZE
*	Allocate BUFFER of size MAX
*	if BUFFER = nil then
*	    close HANDLE
*	    set IOResult to 50
*	    return
*	set MAX := BUFFER (First position) + MAX (buffer size)
*	- thus MAX points to first byte AFTER buffer
*	CURRENT := BUFFER
*	LAST := BUFFER
*	EOF := False
*	if (Access = ModeOldFile) and (not INTERACTIVE) then
*	    FillBuffer
*	link into file list
*	return

* Upon entry, the stack looks like:
*
*	4(SP) -> Address of File Record
*	8(SP) -> Address of File Name String
*
*	The File Record is initialized with the following values:
*
*	ACCESS	= either ModeOldFile or ModeNewFile
*	RECSIZE	= the size of a record (1 for Text files)
*	MAX	= the buffer size requested
*

	INCLUDE	"/FileRec.i"

	XDEF	_p%Open
_p%Open
	move.l	4(sp),d0
	move.l	8(sp),d1
	move.l	d1,-(sp)
	move.l	d0,-(sp)
	bsr	_p%OpenB
	tst.l	_p%IOResult
	seq	d0
	clr.l	_p%IOResult
	add.w	#8,sp
	rts

	XDEF	_p%OpenB
_p%OpenB


	move.l	8(sp),d1	; get file name
	move.l	4(sp),a0	; get address of FileRec
	moveq.l	#0,d2		; clear out upper word
	move.w	ACCESS(a0),d2	; get access mode
	move.l	_p%DOSBase,a6
	jsr	_LVOOpen(a6)	; open the file
	move.l	4(sp),a0
	move.l	d0,HANDLE(a0)	; save the file handle
	bne.s	OpenedOK	; no errors
	jsr	_LVOIoErr(a6)	; get the error number
	move.l	d0,_p%IOResult	; set IOResult
	rts			; return
OpenedOK
	move.l	d0,d1		; set up caller
	jsr	_LVOIsInteractive(a6)	; is it interactive ?
	move.l	4(sp),a0	; get file rec
	move.b	d0,INTERACTIVE(a0)	; set interactive
	beq.s	AdjustBuffer	; if not interactive, skip this
	cmp.w	#1005,ACCESS(a0) ; is it an input file ?
	bne.s	AdjustBuffer	; if not, skip
	move.l	RECSIZE(a0),d0	; d0 := RECSIZE
	move.l	d0,MAX(a0)	; save size for later
	bra.s	AllocBuffer	; go to allocate the buffer
AdjustBuffer
	move.l	MAX(a0),d0	; d0 := Buffer Size requested
	move.l	RECSIZE(a0),d1	; d1 := record size
	jsr	i_ldiv		; call 32-bit divide routines. d0/d1 in d0
	tst.l	d0		; is it zero?
	bne.s	1$		; if not, skip
	moveq.l	#1,d0		; at least 1
1$	move.l	4(sp),a0	; get file rec
	move.l	RECSIZE(a0),d1	; d1 := record size again
	jsr	i_lmul		; d0 := (max div recsize) * recsize
	move.l	4(sp),a0	; get file rec address
	move.l	d0,MAX(a0)	; save it for later
AllocBuffer
	jsr	_p%new		; allocate buffer
	move.l	4(sp),a0	; a0 := file record address
	move.l	d0,BUFFER(a0)	; set buffer
	bne.s	InitializeFR	; if OK, initialize record
	move.l	HANDLE(a0),d1	; set up for close
	move.l	_p%DOSBase,a6	; get DOS library base
	jsr	_LVOClose(a6)	; close the file
	move.l	#50,_p%IOResult	; Set IO Result = no memory for buffer
	rts			; return, having failed
InitializeFR
	move.l	MAX(a0),a1	; get buffer size
	adda.l	BUFFER(a0),a1	; add to first address
	move.l	a1,MAX(a0)	; set maximum address: last byte + 1
	move.l	BUFFER(a0),a1	; a1 := first byte
	move.l	a1,CURRENT(a0)	; CURRENT := BUFFER
	move.l	a1,LAST(a0)	; LAST := BUFFER
	move.b	#0,EOF(a0)	; EOF := False
	cmp.w	#1005,ACCESS(a0)	; is input file ?
	bne.s	LinkFile	; if not, skip this
	tst.b	INTERACTIVE(a0)	; is it interactive ?
	bne.s	LinkFile	; if so, skip this
	jsr	_p%FillBuffer	; fill the buffer for input file
LinkFile
	move.l	filekey,NEXT(a0) ; a0.Next := filekey
	move.l	a0,filekey	; filekey := a0 (linked a0 into list)
	rts			; return successful

	XDEF	_p%FillBuffer
_p%FillBuffer

* Read as many bytes as possible into the file's buffer
* on entry, a0 is the address of the file record, which contains
* all the important info.  This routine sets EOF

*	Algorithm:
*
*	if IOResult <> 0 then
*	    return
*	if EOF then
*	    set IOResult and return
*	Read MAX - BUFFER bytes into BUFFER
*	CURRENT := BUFFER
*	LAST := BUFFER + bytes read
*	if LAST = BUFFER then
*	    EOF := True
*

	tst.l	_p%IOResult	; is IO OK?
	bne	3$		; if not, leave now
	tst.b	EOF(a0)		; at EOF?
	beq.s	1$		; if not, skip ahead
	move.l	#51,_p%IOResult	; set IOResult = Access past EOF
	rts
1$	move.l	a0,-(sp)	; save the File Rec
	move.l	HANDLE(a0),d1	; get the file handle
	bne.s	2$		; if it's open, skip
	moveq	#52,d0		; set error
	jsr	_p%ExitWithAddress ; die
	move.l	HANDLE(a0),d1	; if we got here, we must be OK
2$	move.l	BUFFER(a0),d2	; get first address
	move.l	d3,-(sp)	; save d3
	move.l	MAX(a0),d3	; get last address + 1
	sub.l	d2,d3		; number of bytes to read
	move.l	_p%DOSBase,a6	; get dos.library
	jsr	_LVORead(a6)
	move.l	(sp)+,d3	; restore d3
	move.l	(sp)+,a0	; get file record back
	move.l	BUFFER(a0),d1	; get initial position
	move.l	d1,CURRENT(a0)	; set CURRENT := initial
	add.l	d0,d1		; get BUFFER + bytes read
	move.l	d1,LAST(a0)	; LAST := BUFFER + bytes read
	tst.l	d0		; did we actually read anything?
	bne.s	3$		; if so, skip
	move.b	#-1,EOF(a0)	; set EOF := True
3$	rts

*	MayOpenInput
*
*	This routine opens a Standard Input window for programs that
*	may have started from the Workbench.  It gets the window spec
*	from _StdInName, which is defined either in the User program
*	or, by default, in this library.  If the Output file is already
*	open, and it's interactive, that already open file is used.
*
*	Algorithm for MayOpenInput:
*
*	if a0 <> Input then
*	    generate a runtime error
*	if Output is open and interactive then
*	    Output.Handle := Input.Handle
*	else
*	    Open(StdInName, Input)
*	    if it did not open OK
*		generate a runtime error
*

*	Upon entry to this routine, a0 holds the address of the
*	File Record, which may or may not be Input.

*	XREF	_p%exit
*	XREF	_StdInName
*	XREF	_Input
*	XREF	_Output

*_p%MayOpenInput
*	cmpa.l	#_Input,a0	; is it Input?
*	beq.s	1$		; if so, skip this
*	move.l	#52,d0		; runtime error
*	jsr	_p%ExitWithAddr	; generate the error
*1$	move.l	#_Output,a1	; get Input ptr
*	tst.l	HANDLE(a1)	; is it open?
*	beq	2$		; if not, open a new one
*	tst.b	INTERACTIVE(a1)	; is it interactive?
*	bne	2$		; if not, open a new file
*	move.l	HANDLE(a1),a1	; get the file handle
*	move.l	a1,HANDLE(a0)	; and copy it over
*	rts			; and try that one
*2$	move.l	#80,MAX(a0)	; set up for Open call
*	move.l	#1,RECSIZE(a0)	; Text file
*	move.w	#1005,ACCESS(a0)	; it's an input file (ModeOldFile)
*	move.l	_StdInName,-(sp)	; push the file name
*	move.l	a0,-(sp)	; push the file record address
*	jsr	_p%Open		; try to open this file
*	move.l	(sp)+,a0	; retrieve file record
*	addq.l	#4,sp		; and fix stack
*	tst.b	d0		; did it go OK?
*	bne.s	3$		; if so, go on
*	move.l	#53,d0		; if not, generate an error
*	jsr	_p%ExitWithAddr	; goodbye
*3$	rts			; return to sender


*	Close the file
*
*	This routine unlinks the file from the open-file list, then
*	de-allocates the buffer and closes the file.  If the file
*	is for some reason not on the open-file list, the routine
*	attempts to close it and deallocate its buffer anyway.  Thus
*	you can generate several types of errors by closing a file
*	twice.
*
*	Algorithm:
*
*	if filekey <> nil then
*	    if filekey = FileRec then
*		filekey := FileRec.NEXT
*	    else
*		a1 := filekey
*		while a1 <> nil do
*		    if a1.Next = FileRec then
*			a1.Next := FileRec.Next
*			skip ahead to FlushBuffer business
*		    a1 := a1.Next
*	if ACCESS = ModeNewFile then
*	    FlushBuffer
*	DOSClose(HANDLE)
*	Dispose(BUFFER)
*
*	Upon entry, a0 holds the address of the file record
*

	XDEF	_p%Close
_p%Close:
	move.l	filekey,a1		; a1 := filekey
	move.l	a1,d0			; to set flags
	beq	3$			; if Nil, skip all this
	cmpa.l	a1,a0			; is a0 = filekey?
	bne.s	1$			; if not, go to loop
	move.l	NEXT(a1),a1		; unlink the first file
	move.l	a1,filekey		; set filekey := filekey.Next
	bra	3$			; go to flush buffer stuff
1$	cmpa.l	NEXT(a1),a0		; a0 = NEXT(a1)
	bne.s	2$			; if not, skip this
	move.l	a2,-(sp)		; save a2 for now
	move.l	NEXT(a0),a2		; a2 := file after a0
	move.l	a2,NEXT(a1)		; a1.Next := a0.Next (lose a0)
	move.l	(sp)+,a2		; retrieve a2
	bra.s	3$			; and do the rest of close
2$	move.l	NEXT(a1),a1		; advance file record ptr
	move.l	a1,d0			; are we at end of list?
	bne.s	1$			; if not, go on
3$	move.l	a0,-(sp)		; save file record
	cmp.w	#1006,ACCESS(a0)	; was it ModeNewFile ?
	bne.s	4$			; if not, skip
	jsr	_p%FlushBuffer		; otherwise flush the buffer
4$	move.l	HANDLE(a0),d1		; get handle
	move.l	_p%DOSBase,a6		; get DOS address
	jsr	_LVOClose(a6)		; close the file
	move.l	(sp)+,a0		; get file record back
	move.l	BUFFER(a0),d0		; get initial address
	jsr	_p%dispose		; de-allocate it
	rts

	SECTION	FileKey
filekey	dc.l	0
	END

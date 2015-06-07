

*	OpenStandards
*	When a program is run from the Workbench, it does not have
*	standard input and output.  If the program tries a write() or
*	read(), therefore, these files must be created.  This does that.

	SECTION	PCQ_Runtime,CODE
	XREF	_p%DOSBase

	XDEF	_p%OpenStandards

	XREF	_stdin
	XREF	_stdout
	XREF	_p%wrapitup
	XREF	_LVOOpen
	XREF	filekey

_p%OpenStandards

*	This routine should return a file handle in d1, but should
*	preserve all other registers.

	movem.l	d0/d2/d3/a0/a1/a6,-(sp)	; save at least these
	move.l	#StdName,d1
	move.l	#1006,d2	; new file
	move.l	_p%DOSBase,a6
	jsr	_LVOOpen(a6)
	move.l	d0,d1
	bne.s	1$
	jmp	_p%wrapitup	; can't do it.
1$
	lea	FileRec,a0
	move.l	filekey,14(a0)
	move.l	a0,filekey	; attach to file list
	move.l	d0,(a0)
	move.l	d0,_stdin
	move.l	d0,_stdout

	movem.l	(sp)+,d0/d2/d3/a0/a1/a6

	rts

	SECTION	PCQ_DATA,DATA

StdName	dc.b	'CON:0/0/640/200/',0

	SECTION PCQ_BSS,BSS

FileRec	ds.b	18

	END

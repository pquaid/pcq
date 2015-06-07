*
*	DOS.asm for PCQ Pascal
*	Copyright 1990 Patrick Quaid
*
*	These are the glue routines for the most common procedures
*	and functions defined in Include/Libraries/DOS.i.
*
*

	SECTION	PCQ_Runtime,CODE

	XREF	_p%DOSBase

	XDEF	_DOSClose
	XREF	_LVOClose
_DOSClose
	move.l	4(sp),d1
	move.l	_p%DOSBase,a6
	jmp	_LVOClose(a6)

	XDEF	_DateStamp
	XREF	_LVODateStamp
_DateStamp
	move.l	4(sp),d1
	move.l	_p%DOSBase,a6
	jmp	_LVODateStamp(a6)

	XDEF	_Delay
	XREF	_LVODelay
_Delay
	move.l	4(sp),d1
	move.l	_p%DOSBase,a6
	jmp	_LVODelay(a6)

	XDEF	_DeleteFile
	XREF	_LVODeleteFile
_DeleteFile
	move.l	4(sp),d1
	move.l	_p%DOSBase,a6
	jsr	_LVODeleteFile(a6)
	tst.l	d0
	sne	d0
	rts

	XDEF	_DupLock
	XREF	_LVODupLock
_DupLock
	move.l	4(sp),d1
	move.l	_p%DOSBase,a6
	jmp	_LVODupLock(a6)

	XDEF	_Examine
	XREF	_LVOExamine
_Examine
	move.l	d2,-(sp)
	move.l	8(sp),d2
	move.l	12(sp),d1
	move.l	_p%DOSBase,a6
	jsr	_LVOExamine(a6)
	move.l	(sp)+,d2
	tst.l	d0
	sne	d0
	rts

	XDEF	_Execute
	XREF	_LVOExecute
_Execute
	movem.l	d2/d3,-(sp)
	move.l	12(sp),d3
	move.l	16(sp),d2
	move.l	20(sp),d1
	move.l	_p%DOSBase,a6
	jsr	_LVOExecute(a6)
	movem.l	(sp)+,d2/d3
	tst.l	d0
	sne	d0
	rts

	XDEF	_DOSExit
	XREF	_LVOExit
_DOSExit
	move.l	4(sp),d1
	move.l	_p%DOSBase,a6
	jmp	_LVOExit(a6)

	XDEF	_ExNext
	XREF	_LVOExNext
_ExNext
	move.l	d2,-(sp)
	move.l	8(sp),d2
	move.l	12(sp),d1
	move.l	_p%DOSBase,a6
	jsr	_LVOExNext(a6)
	move.l	(sp)+,d2
	tst.l	d0
	sne	d0
	rts

	XDEF	_DOSInput
	XREF	_LVOInput
_DOSInput
	move.l	_p%DOSBase,a6
	jmp	_LVOInput(a6)

	XDEF	_IoErr
	XREF	_LVOIoErr
_IoErr
	move.l	_p%DOSBase,a6
	jmp	_LVOIoErr(a6)

	XDEF	_Lock
	XREF	_LVOLock
_Lock
	move.l	d2,-(sp)
	move.l	8(sp),d2
	move.l	12(sp),d1
	move.l	_p%DOSBase,a6
	jsr	_LVOLock(a6)
	move.l	(sp)+,d2
	rts

	XDEF	_DOSOpen
	XREF	_LVOOpen
_DOSOpen
	move.l	d2,-(sp)
	move.l	8(sp),d2
	move.l	12(sp),d1
	move.l	_p%DOSBase,a6
	jsr	_LVOOpen(a6)
	move.l	(sp)+,d2
	rts

	XDEF	_DOSOutput
	XREF	_LVOOutput
_DOSOutput
	move.l	_p%DOSBase,a6
	jmp	_LVOOutput(a6)

	XDEF	_DOSRead
	XREF	_LVORead
_DOSRead
	movem.l	d2/d3,-(sp)
	move.l	12(sp),d3
	move.l	16(sp),d2
	move.l	20(sp),d1
	move.l	_p%DOSBase,a6
	jsr	_LVORead(a6)
	movem.l	(sp)+,d2/d3
	rts

	XDEF	_Rename
	XREF	_LVORename
_Rename
	move.l	d2,-(sp)
	move.l	8(sp),d2
	move.l	12(sp),d1
	move.l	_p%DOSBase,a6
	jsr	_LVORename(a6)
	move.l	(sp)+,d2
	tst.l	d0
	sne	d0
	rts

	XDEF	_UnLock
	XREF	_LVOUnLock
_UnLock
	move.l	4(sp),d1
	move.l	_p%DOSBase,a6
	jmp	_LVOUnLock(a6)

	XDEF	_DOSWrite
	XREF	_LVOWrite
_DOSWrite
	movem.l	d2/d3,-(sp)
	move.l	12(sp),d3
	move.l	16(sp),d2
	move.l	20(sp),d1
	move.l	_p%DOSBase,a6
	jsr	_LVOWrite(a6)
	movem.l	(sp)+,d2/d3
	rts

	END

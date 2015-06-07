*
*	DOS2.asm for PCQ Pascal
*	Copyright 1990 Patrick Quaid
*
*	These are the glue routines for the less common procedures
*	and functions defined in Include/Libraries/DOS.i.
*
*

	SECTION	PCQ_Runtime,CODE

	XREF	_p%DOSBase

	XDEF	_CreateDir
	XREF	_LVOCreateDir
_CreateDir
	move.l	4(sp),d1
	move.l	_p%DOSBase,a6
	jmp	_LVOCreateDir(a6)

	XDEF	_CurrentDir
	XREF	_LVOCurrentDir
_CurrentDir
	move.l	4(sp),d1
	move.l	_p%DOSBase,a6
	jmp	_LVOCurrentDir(a6)

	XDEF	_Info
	XREF	_LVOInfo
_Info
	move.l	d2,-(sp)
	move.l	8(sp),d2
	move.l	12(sp),d1
	move.l	_p%DOSBase,a6
	jsr	_LVOInfo(a6)
	move.l	(sp)+,d2
	tst.l	d0
	sne	d0
	rts

	XDEF	_IsInteractive
	XREF	_LVOIsInteractive
_IsInteractive
	move.l	4(sp),d1
	move.l	_p%DOSBase,a6
	jsr	_LVOIsInteractive(a6)
	tst.l	d0
	sne	d0
	rts

	XDEF	_ParentDir
	XREF	_LVOParentDir
_ParentDir
	move.l	4(sp),d1
	move.l	_p%DOSBase,a6
	jmp	_LVOParentDir(a6)

	XDEF	_Seek
	XREF	_LVOSeek
_Seek
	movem.l	d2/d3,-(sp)
	move.l	12(sp),d3
	move.l	16(sp),d2
	move.l	20(sp),d1
	move.l	_p%DOSBase,a6
	jsr	_LVOSeek(a6)
	movem.l	(sp)+,d2/d3
	rts

	XDEF	_SetComment
	XREF	_LVOSetComment
_SetComment
	move.l	d2,-(sp)
	move.l	8(sp),d2
	move.l	12(sp),d1
	move.l	_p%DOSBase,a6
	jsr	_LVOSetComment(a6)
	move.l	(sp)+,d2
	tst.l	d0
	sne	d0
	rts

	XDEF	_SetProtection
	XREF	_LVOSetProtection
_SetProtection
	move.l	d2,-(sp)
	move.l	8(sp),d2
	move.l	12(sp),d1
	move.l	_p%DOSBase,a6
	jsr	_LVOSetProtection(a6)
	move.l	(sp)+,d2
	tst.l	d0
	sne	d0
	rts

	XDEF	_WaitForChar
	XREF	_LVOWaitForChar
_WaitForChar
	move.l	d2,-(sp)
	move.l	8(sp),d2
	move.l	12(sp),d1
	move.l	_p%DOSBase,a6
	jsr	_LVOWaitForChar(a6)
	move.l	(sp)+,d2
	tst.l	d0
	sne	d0
	rts

	END

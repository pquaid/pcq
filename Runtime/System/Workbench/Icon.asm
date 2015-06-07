*
*	Icon.asm for PCQ Pascal
*	Copyright 1990 Patrick Quaid
*
*	Stubs for routines declared in Include/Workbench/Icon.i
*

	XREF	_IconBase

	SECTION	PCQ_Runtime,CODE

	XREF	_LVOAddFreeList
	XDEF	_AddFreeList
_AddFreeList
	move.l	4(sp),a2
	move.l	8(sp),a1
	move.l	12(sp),a0
	move.l	_IconBase,a6
	jsr	_LVOAddFreeList(a6)
	tst.l	d0
	sne	d0
	rts

	XREF	_LVOBumpRevision
	XDEF	_BumpRevision
_BumpRevision
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_IconBase,a6
	jmp	_LVOBumpRevision(a6)

	XREF	_LVOFindToolType
	XDEF	_FindToolType
_FindToolType
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_IconBase,a6
	jmp	_LVOFindToolType(a6)

	XREF	_LVOFreeDiskObject
	XDEF	_FreeDiskObject
_FreeDiskObject
	move.l	4(sp),a0
	move.l	_IconBase,a6
	jmp	_LVOFreeDiskObject(a6)

	XREF	_LVOFreeFreeList
	XDEF	_FreeFreeList
_FreeFreeList
	move.l	4(sp),a0
	move.l	_IconBase,a6
	jmp	_LVOFreeFreeList(a6)

	XREF	_LVOGetDiskObject
	XDEF	_GetDiskObject
_GetDiskObject
	move.l	4(sp),a0
	move.l	_IconBase,a6
	jmp	_LVOGetDiskObject(a6)

	XREF	_LVOMatchToolValue
	XDEF	_MatchToolValue
_MatchToolValue
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_IconBase,a6
	jsr	_LVOMatchToolValue(a6)
	tst.l	d0
	sne	d0
	rts

	XREF	_LVOPutDiskObject
	XDEF	_PutDiskObject
_PutDiskObject
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_IconBase,a6
	jsr	_LVOPutDiskObject(a6)
	tst.l	d0
	sne	d0
	rts

	END

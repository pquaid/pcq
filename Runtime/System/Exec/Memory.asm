*
*	Memory.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	These are the glue routines for the procedures and functions
*	defined in Include/Exec/Memory.i
*

	SECTION	PCQ_Runtime,CODE

	XREF	_AbsExecBase

	XREF	_LVOAddMemList
	XDEF	_AddMemList
_AddMemList
	move.l	d2,-(sp)
	move.l	8(sp),a1
	move.l	12(sp),a0
	move.l	16(sp),d2
	move.l	20(sp),d1
	move.l	24(sp),d0
	move.l	_AbsExecBase,a6
	jsr	_LVOAddMemList(a6)
	move.l	(sp)+,d2
	rts

	XREF	_LVOAllocAbs
	XDEF	_AllocAbs
_AllocAbs
	move.l	4(sp),a1
	move.l	8(sp),d0
	move.l	_AbsExecBase,a6
	jmp	_LVOAllocAbs(a6)

	XREF	_LVOAllocate
	XDEF	_Allocate
_Allocate
	movem.l	4(sp),d0/a0
	move.l	_AbsExecBase,a6
	jmp	_LVOAllocate(a6)

	XREF	_LVOAllocEntry
	XDEF	_AllocEntry
_AllocEntry
	move.l	4(sp),a0
	move.l	_AbsExecBase,a6
	jmp	_LVOAllocEntry(a6)

	XREF	_LVOAllocMem
	XDEF	_AllocMem
_AllocMem
	move.l	4(sp),d1
	move.l	8(sp),d0
	move.l	_AbsExecBase,a6
	jmp	_LVOAllocMem(a6)

	XREF	_LVOAvailMem
	XDEF	_AvailMem
_AvailMem
	move.l	4(sp),d1
	move.l	_AbsExecBase,a6
	jmp	_LVOAvailMem(a6)

	XREF	_LVOCopyMem
	XDEF	_CopyMem
_CopyMem
	movem.l	4(sp),d0/a1
	move.l	12(sp),a0
	move.l	_AbsExecBase,a6
	jmp	_LVOCopyMem(a6)

	XREF	_LVOCopyMemQuick
	XDEF	_CopyMemQuick
_CopyMemQuick
	movem.l	4(sp),d0/a1
	move.l	12(sp),a0
	move.l	_AbsExecBase,a6
	jmp	_LVOCopyMemQuick(a6)

	XREF	_LVODeallocate
	XDEF	_Deallocate
_Deallocate
	movem.l	4(sp),d0/a1
	move.l	12(sp),a0
	move.l	_AbsExecBase,a6
	jmp	_LVODeallocate(a6)

	XREF	_LVOFreeEntry
	XDEF	_FreeEntry
_FreeEntry
	move.l	4(sp),a0
	move.l	_AbsExecBase,a6
	jmp	_LVOFreeEntry(a6)

	XREF	_LVOFreeMem
	XDEF	_FreeMem
_FreeMem
	movem.l	4(sp),d0/a1
	move.l	_AbsExecBase,a6
	jmp	_LVOFreeMem(a6)

	XREF	_LVOInitStruct
	XDEF	_InitStruct
_InitStruct
	move.l	a2,-(sp)
	movem.l	8(sp),d0/a2
	move.l	16(sp),a1
	move.l	_AbsExecBase,a6
	jsr	_LVOInitStruct(a6)
	move.l	(sp)+,a2
	rts

	XREF	_LVOTypeOfMem
	XDEF	_TypeOfMem
_TypeOfMem
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVOTypeOfMem(a6)

	END

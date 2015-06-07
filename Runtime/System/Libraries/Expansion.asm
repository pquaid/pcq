*
*	Expansion.asm for PCQ Pascal
*	Copyright 1990 Patrick Quaid
*
*	These stubs provide access to the expansion.library routines,
*	which are defined in Libraries/Expansion.i and
*	Libraries/ConfigVar.i
*

	XREF	_ExpansionBase

	SECTION	PCQ_Runtime,CODE

	XREF	_LVOAddConfigDev
	XDEF	_AddConfigDev
_AddConfigDev
	move.l	4(sp),a0
	move.l	_ExpansionBase,a6
	jmp	_LVOAddConfigDev(a6)

	XREF	_LVOAddDosNode
	XDEF	_AddDosNode
_AddDosNode
	move.l	4(sp),a0
	move.w	8(sp),d1
	move.w	10(sp),d0
	move.l	_ExpansionBase,a6
	jsr	_LVOAddDosNode(a6)
	tst.l	d0
	sne	d0
	rts

	XREF	_LVOAllocBoardMem
	XDEF	_AllocBoardMem
_AllocBoardMem
	move.l	4(sp),d0
	move.l	_ExpansionBase,a6
	jmp	_LVOAllocBoardMem(a6)

	XREF	_LVOAllocConfigDev
	XDEF	_AllocConfigDev
_AllocConfigDev
	move.l	_ExpansionBase,a6
	jmp	_LVOAllocConfigDev(a6)

	XREF	_LVOAllocExpansionMem
	XDEF	_AllocExpansionMem
_AllocExpansionMem
	move.w	4(sp),d1
	move.w	6(sp),d0
	move.l	_ExpansionBase,a6
	jmp	_LVOAllocExpansionMem(a6)

	XREF	_LVOConfigBoard
	XDEF	_ConfigBoard
_ConfigBoard
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_ExpansionBase,a6
	jsr	_LVOConfigBoard(a6)
	tst.l	d0
	sne	d0
	rts

	XREF	_LVOConfigChain
	XDEF	_ConfigChain
_ConfigChain
	move.l	4(sp),a0
	move.l	_ExpansionBase,a6
	jsr	_LVOConfigChain(a6)
	tst.l	d0
	sne	d0
	rts

	XREF	_LVOFindConfigDev
	XDEF	_FindConfigDev
_FindConfigDev
	move.l	4(sp),d1
	move.l	8(sp),d0
	move.l	12(sp),a0
	move.l	_ExpansionBase,a6
	jmp	_LVOFindConfigDev(a6)

	XREF	_LVOFreeBoardMem
	XDEF	_FreeBoardMem
_FreeBoardMem
	move.w	4(sp),d1
	move.w	6(sp),d0
	move.l	_ExpansionBase,a6
	jmp	_LVOFreeBoardMem(a6)

	XREF	_LVOFreeConfigDev
	XDEF	_FreeConfigDev
_FreeConfigDev
	move.l	4(sp),a0
	move.l	_ExpansionBase,a6
	jmp	_LVOFreeConfigDev

	XREF	_LVOFreeExpansionMem
	XDEF	_FreeExpansionMem
_FreeExpansionMem
	move.w	4(sp),d1
	move.w	6(sp),d0
	move.l	_ExpansionBase,a6
	jmp	_LVOFreeExpansionMem(a6)

	XREF	_LVOGetCurrentBinding
	XDEF	_GetCurrentBinding
_GetCurrentBinding
	move.w	4(sp),d0
	move.l	6(sp),a0
	move.l	_ExpansionBase,a6
	jmp	_LVOGetCurrentBinding(a6)

	XREF	_LVOObtainConfigBinding
	XDEF	_ObtainConfigBinding
_ObtainConfigBinding
	move.l	_ExpansionBase,a6
	jmp	_LVOObtainConfigBinding(a6)

	XREF	_LVOMakeDosNode
	XDEF	_MakeDosNode
_MakeDosNode
	move.l	4(sp),a0
	move.l	_ExpansionBase,a6
	jmp	_LVOMakeDosNode(a6)

	XREF	_LVOReadExpansionByte
	XDEF	_ReadExpansionByte
_ReadExpansionByte
	movem.l	4(sp),d0/a0
	move.l	_ExpansionBase,a6
	jmp	_LVOReadExpansionByte(a6)

	XREF	_LVOReadExpansionRom
	XDEF	_ReadExpansionRom
_ReadExpansionRom
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_ExpansionBase,a6
	jsr	_LVOReadExpansionRom(a6)
	tst.l	d0
	sne	d0
	rts

	XREF	_LVOReleaseConfigBinding
	XDEF	_ReleaseConfigBinding
_ReleaseConfigBinding
	move.l	_ExpansionBase,a6
	jmp	_LVOReleaseConfigBinding(a6)

	XREF	_LVORemConfigDev
	XDEF	_RemConfigDev
_RemConfigDev
	move.l	4(sp),a0
	move.l	_ExpansionBase,a6
	jmp	_LVORemConfigDev(a6)

	XREF	_LVOSetCurrentBinding
	XDEF	_SetCurrentBinding
_SetCurrentBinding
	move.w	4(sp),d0
	move.l	6(sp),a0
	move.l	_ExpansionBase,a6
	jmp	_LVOSetCurrentBinding(a6)

	XREF	_LVOWriteExpansionByte
	XDEF	_WriteExpansionByte
_WriteExpansionByte
	move.w	4(sp),d1
	movem.l	6(sp),d0/a0
	move.l	_ExpansionBase,a6
	jsr	_LVOWriteExpansionByte(a6)
	tst.l	d0
	sne	d0
	rts

	END

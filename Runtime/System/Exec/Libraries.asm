*
*	Libraries.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	The routines defined in Include/exec/libraries.i are implemented
*	here.
*

	SECTION	PCQ_Runtime,CODE

	XREF	_AbsExecBase

	XREF	_LVOAddLibrary
	XDEF	_AddLibrary
_AddLibrary
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVOAddLibrary(a6)

	XREF	_LVOCloseLibrary
	XDEF	_CloseLibrary
_CloseLibrary
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVOCloseLibrary(a6)

	XREF	_LVOMakeFunctions
	XDEF	_MakeFunctions
_MakeFunctions
	move.l	a2,-(sp)
	move.l	8(sp),a2
	move.l	12(sp),a1
	move.l	16(sp),a0
	move.l	_AbsExecBase,a6
	jsr	_LVOMakeFunctions(a6)
	move.l	(sp)+,a2
	rts

	XREF	_LVOMakeLibrary
	XDEF	_MakeLibrary
_MakeLibrary
	move.l	a2,-(sp)
	move.l	8(sp),d1
	movem.l	12(sp),d0/a2
	move.l	20(sp),a1
	move.l	24(sp),a0
	move.l	_AbsExecBase,a6
	jsr	_LVOMakeLibrary(a6)
	move.l	(sp)+,a2
	rts

	XREF	_LVOOldOpenLibrary
	XDEF	_OldOpenLibrary
_OldOpenLibrary
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVOOldOpenLibrary(a6)

	XREF	_LVOOpenLibrary
	XDEF	_OpenLibrary
_OpenLibrary
	movem.l	4(sp),d0/a1
	move.l	_AbsExecBase,a6
	jmp	_LVOOpenLibrary(a6)

	XREF	_LVORemLibrary
	XDEF	_RemLibrary
_RemLibrary
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVORemLibrary(a6)

	XREF	_LVOSetFunction
	XDEF	_SetFunction
_SetFunction
	movem.l	4(sp),d0/a0/a1
	move.l	_AbsExecBase,a6
	jmp	_LVOSetFunction(a6)

	XREF	_LVOSumLibrary
	XDEF	_SumLibrary
_SumLibrary
	move.l	4(sp),a1
	move.l	_AbsExecBase,a6
	jmp	_LVOSumLibrary(a6)

	END

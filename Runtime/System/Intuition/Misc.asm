*
*	Misc.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	This file has the glue routines for the procedures and functions
*	defined in Include/Intuition/Intuition.i that are not defined in
*	any of the other .asm files.
*


	SECTION	PCQ_Runtime,CODE

	XREF	_p%IntuitionBase

	XDEF	_AllocRemember
	XREF	_LVOAllocRemember
_AllocRemember
	move.l	4(sp),d1
	movem.l	8(sp),d0/a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOAllocRemember(a6)

	XDEF	_CurrentTime
	XREF	_LVOCurrentTime
_CurrentTime
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOCurrentTime(a6)

	XDEF	_DoubleClick
	XREF	_LVODoubleClick
_DoubleClick
	movem.l	d2/d3,-(sp)
	move.l	12(sp),d3
	move.l	16(sp),d2
	move.l	20(sp),d1
	move.l	24(sp),d0
	move.l	_p%IntuitionBase,a6
	jsr	_LVODoubleClick(a6)
	movem.l	(sp)+,d2/d3
	tst.l	d0
	sne	d0
	rts

	XDEF	_FreeRemember
	XREF	_LVOFreeRemember
_FreeRemember
	move.w	4(sp),d0
	and.l	#$FF,d0
	move.l	6(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOFreeRemember(a6)

	XDEF	_GetDefPrefs
	XREF	_LVOGetDefPrefs
_GetDefPrefs
	move.w	4(sp),d0
	move.l	6(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOGetDefPrefs(a6)

	XDEF	_GetPrefs
	XREF	_LVOGetPrefs
_GetPrefs
	move.w	4(sp),d0
	move.l	6(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOGetPrefs(a6)

	XDEF	_LockIBase
	XREF	_LVOLockIBase
_LockIBase
	move.l	4(sp),d0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOLockIBase(a6)

	XDEF	_SetPrefs
	XREF	_LVOSetPrefs
_SetPrefs
	move.w	4(sp),d1
	and.l	#$FF,d1
	move.l	6(sp),d0
	move.l	10(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOSetPrefs(a6)

	XDEF	_UnlockIBase
	XREF	_LVOUnlockIBase
_UnlockIBase
	move.l	4(sp),a0
	move.l	_p%IntuitionBase,a6
	jmp	_LVOUnlockIBase(a6)

	XDEF	_ViewAddress
	XREF	_LVOViewAddress
_ViewAddress
	move.l	_p%IntuitionBase,a6
	jmp	_LVOViewAddress(a6)

	END

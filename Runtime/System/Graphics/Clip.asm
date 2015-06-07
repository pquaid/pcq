*
*	Clip.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	These are the glue routines for the procedure and functions
*	defined in Include/Graphics/Clip.i.
*
*

	SECTION	PCQ_Runtime,CODE

	XREF	_GfxBase

	XREF	_LVOAttemptLockLayerRom
	XDEF	_AttemptLockLayerRom
_AttemptLockLayerRom
	move.l	a5,-(sp)
	move.l	4(sp),a5
	move.l	_GfxBase,a6
	jsr	_LVOAttemptLockLayerRom(a6)
	move.l	(sp)+,a5
	tst.b	d0
	sne	d0	; make sure it's my kind of Boolean
	rts

	XREF	_LVOCopySBitMap
	XDEF	_CopySBitMap
_CopySBitMap
	move.l	4(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOCopySBitMap(a6)

	XREF	_LVOLockLayerRom
	XDEF	_LockLayerRom
_LockLayerRom
	move.l	a5,-(sp)
	move.l	4(sp),a5
	move.l	_GfxBase,a6
	jsr	_LVOLockLayerRom(a6)
	move.l	(sp)+,a5
	rts


	XREF	_LVOSyncSBitMap
	XDEF	_SyncSBitMap
_SyncSBitMap
	move.l	4(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOSyncSBitMap(a6)


	XREF	_LVOUnlockLayerRom
	XDEF	_UnlockLayerRom
_UnlockLayerRom
	move.l	a5,-(sp)
	move.l	4(sp),a5
	move.l	_GfxBase,a6
	jsr	_LVOUnlockLayerRom(a6)
	move.l	(sp)+,a5
	rts

	END

*
*	Layers.asm for PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	These are the glue routines for the procedures and functions
*	defined in Include/Graphics/Layers.i
*

	SECTION PCQ_Runtime,CODE

	XREF	_LayersBase

	XREF	_LVOBeginUpdate
	XDEF	_BeginUpdate
_BeginUpdate
	move.l	4(sp),a0
	move.l	_LayersBase,a6
	jsr	_LVOBeginUpdate(a6)
	tst.l	d0
	sne	d0
	rts


	XREF	_LVOBehindLayer
	XDEF	_BehindLayer
_BehindLayer
	move.l	4(sp),a1
	move.l	_LayersBase,a6
	jsr	_LVOBehindLayer(a6)
	tst.l	d0
	sne	d0
	rts

	XREF	_LVOCreateBehindLayer
	XDEF	_CreateBehindLayer
_CreateBehindLayer
	movem.l	d2/d3/d4/a2,-(sp)
	move.l	20(sp),a2
	move.l	24(sp),d4
	move.l	28(sp),d3
	move.l	32(sp),d2
	move.l	36(sp),d1
	movem.l	40(sp),d0/a1
	move.l	48(sp),a0
	move.l	_LayersBase,a6
	jsr	_LVOCreateBehindLayer(a6)
	movem.l	(sp)+,d2/d3/d4/a2
	rts


	XREF	_LVOCreateUpfrontLayer
	XDEF	_CreateUpfrontLayer
_CreateUpfrontLayer
	movem.l	d2/d3/d4/a2,-(sp)
	move.l	20(sp),a2
	move.l	24(sp),d4
	move.l	28(sp),d3
	move.l	32(sp),d2
	move.l	36(sp),d1
	movem.l	40(sp),d0/a1
	move.l	48(sp),a0
	move.l	_LayersBase,a6
	jsr	_LVOCreateUpfrontLayer(a6)
	movem.l	(sp)+,d2/d3/d4/a2
	rts

	XREF	_LVODeleteLayer
	XDEF	_DeleteLayer
_DeleteLayer
	move.l	4(sp),a1
	move.l	_LayersBase,a6
	jsr	_LVODeleteLayer(a6)
	tst.l	d0
	sne	d0
	rts

	XREF	_LVODisposeLayerInfo
	XDEF	_DisposeLayerInfo
_DisposeLayerInfo
	move.l	4(sp),a0
	move.l	_LayersBase,a6
	jmp	_LVODisposeLayerInfo(a6)


	XREF	_LVOEndUpdate
	XDEF	_EndUpdate
_EndUpdate
	move.w	4(sp),d0
	move.l	6(sp),a0
	move.l	_LayersBase,a6
	jmp	_LVOEndUpdate(a6)


	XREF	_LVOInstallClipRegion
	XDEF	_InstallClipRegion
_InstallClipRegion
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_LayersBase,a6
	jmp	_LVOInstallClipRegion(a6)


	XREF	_LVOLockLayer
	XDEF	_LockLayer
_LockLayer
	move.l	4(sp),a1
	move.l	_LayersBase,a6
	jmp	_LVOLockLayer(a6)


	XREF	_LVOLockLayerInfo
	XDEF	_LockLayerInfo
_LockLayerInfo
	move.l	4(sp),a0
	move.l	_LayersBase,a6
	jmp	_LVOLockLayerInfo(a6)


	XREF	_LVOLockLayers
	XDEF	_LockLayers
_LockLayers
	move.l	4(sp),a0
	move.l	_LayersBase,a6
	jmp	_LVOLockLayers(a6)


	XREF	_LVOMoveLayer
	XDEF	_MoveLayer
_MoveLayer
	move.l	4(sp),d1
	movem.l	8(sp),d0/a1
	move.l	_LayersBase,a6
	jsr	_LVOMoveLayer(a6)
	tst.l	d0
	sne	d0
	rts

	XREF	_LVOMoveLayerInFrontOf
	XDEF	_MoveLayerInFrontOf
_MoveLayerInFrontOf
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_LayersBase,a6
	jsr	_LVOMoveLayerInFrontOf(a6)
	tst.l	d0
	sne	d0
	rts

	XREF	_LVONewLayerInfo
	XDEF	_NewLayerInfo
_NewLayerInfo
	move.l	_LayersBase,a6
	jmp	_LVONewLayerInfo(a6)


	XREF	_LVOScrollLayer
	XDEF	_ScrollLayer
_ScrollLayer
	move.l	4(sp),d1
	movem.l	8(sp),d0/a1
	move.l	_LayersBase,a6
	jmp	_LVOScrollLayer(a6)


	XREF	_LVOSizeLayer
	XDEF	_SizeLayer
_SizeLayer
	move.l	4(sp),d1
	movem.l	8(sp),d0/a1
	move.l	_LayersBase,a6
	jsr	_LVOSizeLayer(a6)
	tst.l	d0
	sne	d0
	rts

	XREF	_LVOSwapBitsRastPortClipRect
	XDEF	_SwapBitsRastPortClipRect
_SwapBitsRastPortClipRect
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_LayersBase,a6
	jmp	_LVOSwapBitsRastPortClipRect(a6)


	XREF	_LVOUnlockLayer
	XDEF	_UnlockLayer
_UnlockLayer
	move.l	4(sp),a0
	move.l	_LayersBase,a6
	jmp	_LVOUnlockLayer(a6)


	XREF	_LVOUnlockLayerInfo
	XDEF	_UnlockLayerInfo
_UnlockLayerInfo
	move.l	4(sp),a0
	move.l	_LayersBase,a6
	jmp	_LVOUnlockLayerInfo(a6)


	XREF	_LVOUnlockLayers
	XDEF	_UnlockLayers
_UnlockLayers
	move.l	4(sp),a0
	move.l	_LayersBase,a6
	jmp	_LVOUnlockLayers(a6)


	XREF	_LVOUpfrontLayer
	XDEF	_UpfrontLayer
_UpfrontLayer
	move.l	4(sp),a1
	move.l	_LayersBase,a6
	jsr	_LVOUpfrontLayer(a6)
	tst.l	d0
	sne	d0
	rts

	XREF	_LVOWhichLayer
	XDEF	_WhichLayer
_WhichLayer
	move.l	4(sp),d1
	movem.l	8(sp),d0/a0
	move.l	_LayersBase,a6
	jmp	_LVOWhichLayer(a6)

	END

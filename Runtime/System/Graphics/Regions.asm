*
*	Regions.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	These are the glue routines for the procedures and functions
*	defined in Include/Graphics/Regions.i
*

	SECTION PCQ_Runtime,CODE

	XREF	_GfxBase

	XREF	_LVOAndRectRegion
	XDEF	_AndRectRegion
_AndRectRegion
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOAndRectRegion(a6)


	XREF	_LVOAndRegionRegion
	XDEF	_AndRegionRegion
_AndRegionRegion
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_GfxBase,a6
	jsr	_LVOAndRegionRegion(a6)
	tst.l	d0
	sne	d0
	rts


	XREF	_LVOClearRectRegion
	XDEF	_ClearRectRegion
_ClearRectRegion
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_GfxBase,a6
	jsr	_LVOClearRectRegion(a6)
	tst.l	d0
	sne	d0
	rts

	XREF	_LVOClearRegion
	XDEF	_ClearRegion
_ClearRegion
	move.l	4(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOClearRegion(a6)


	XREF	_LVODisposeRegion
	XDEF	_DisposeRegion
_DisposeRegion
	move.l	4(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVODisposeRegion(a6)


	XREF	_LVONewRegion
	XDEF	_NewRegion
_NewRegion
	move.l	_GfxBase,a6
	jmp	_LVONewRegion(a6)


	XREF	_LVOOrRectRegion
	XDEF	_OrRectRegion
_OrRectRegion
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_GfxBase,a6
	jsr	_LVOOrRectRegion(a6)
	tst.l	d0
	sne	d0
	rts


	XREF	_LVOOrRegionRegion
	XDEF	_OrRegionRegion
_OrRegionRegion
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_GfxBase,a6
	jsr	_LVOOrRegionRegion(a6)
	tst.l	d0
	sne	d0
	rts


	XREF	_LVOXorRectRegion
	XDEF	_XorRectRegion
_XorRectRegion
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_GfxBase,a6
	jsr	_LVOXorRectRegion(a6)
	tst.l	d0
	sne	d0
	rts



	XREF	_LVOXorRegionRegion
	XDEF	_XorRegionRegion
_XorRegionRegion
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_GfxBase,a6
	jsr	_LVOXorRegionRegion(a6)
	tst.l	d0
	sne	d0
	rts

	END

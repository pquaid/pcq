*
*	GFX.asm for PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	These are the glue routines for the procedures and functions
*	defined in Include/Graphics/GFX.i
*

	SECTION PCQ_Runtime,CODE

	XREF	_GfxBase


	XREF	_LVOInitBitMap
	XDEF	_InitBitMap
_InitBitMap
	move.l	d2,-(sp)
	move.w	8(sp),d2
	move.w	10(sp),d1
	move.w	12(sp),d0
	move.l	14(sp),a0
	move.l	_GfxBase,a6
	jsr	_LVOInitBitMap(a6)
	move.l	(sp)+,d2
	rts

	XDEF	_RASSIZE
_RASSIZE
        move.w  4(sp),d0	; d0 := h
        move.w  6(sp),d1	; d1 := w
	add.w	#15,d1		; d1 := h + 15
	lsr.w	#3,d1		; d1 := (h + 15) >> 3
	and.w	#$FFFE,d1	; d1 := ((h + 15) >> 3) & $FFFE
	mulu	d1,d0		; d0 := d0 * d1
	rts

	END

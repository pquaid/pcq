*
*	IFF.asm for PCQ Pascal
*
* This file defines the glue routines for Christian Weber's
* iff.library.
*
*

	SECTION	PCQ_Runtime,CODE

	XREF	_IFFBase

	XDEF	_OpenIFF
_OpenIFF
	move.l	4(sp),a0
	move.l	_IFFBase,a6
	jmp	-30(a6)


	XDEF	_CloseIFF
_CloseIFF
	move.l	4(sp),a1
	move.l	_IFFBase,a6
	jmp	-36(a6)

	XDEF	_FindChunk
_FindChunk
	move.l	4(sp),d0
	move.l	8(sp),a1
	move.l	_IFFBase,a6
	jmp	-42(a6)


	XDEF	_GetBMHD
_GetBMHD
	move.l	4(sp),a1
	move.l	_IFFBase,a6
	jmp	-48(a6)

	XDEF	_GetColorTab
_GetColorTab
	move.l	4(sp),a0
	move.l	8(sp),a1
	move.l	_IFFBase,a6
	jmp	-54(a6)

	XDEF	_DecodePic
_DecodePic
	move.l	4(sp),a0
	move.l	8(sp),a1
	move.l	_IFFBase,a6
	jsr	-60(a6)
	tst.l	d0
	sne	d0
	rts

	XDEF	_SaveBitMap
_SaveBitMap
	move.l	a2,-(sp)
	move.l	8(sp),d0
	move.l	12(sp),a2
	move.l	16(sp),a1
	move.l	20(sp),a0
	move.l	_IFFBase,a6
	jsr	-66(a6)
	tst.l	d0
	sne	d0
	move.l	(sp)+,a2
	rts

	XDEF	_SaveClip
_SaveClip
	movem.l	a2/d2/d3/d4,-(sp)
	move.l	20(sp),d4
	move.l	24(sp),d3
	move.l	28(sp),d2
	move.l	32(sp),d1
	move.l	36(sp),d0
	move.l	40(sp),a2
	move.l	44(sp),a1
	move.l	48(sp),a0
	move.l	_IFFBase,a6
	jsr	-72(a6)
	tst.l	d0
	sne	d0
	movem.l	(sp)+,a2/d2/d3/d4
	rts

	XDEF	_IFFError
_IFFError
	move.l	_IFFBase,a6
	jmp	-78(a6)

	XDEF	_GetViewModes
_GetViewModes
	move.l	4(sp),a1
	move.l	_IFFBase,a6
	jmp	-84(a6)

	XDEF	_ModifyFrame
_ModifyFrame
	move.l	4(sp),a0
	move.l	8(sp),a1
	move.l	_IFFBase,a6
	jsr	-96(a6)
	tst.l	d0
	sne	d0
	rts

	XDEF	_NewOpenIFF
_NewOpenIFF
	move.l	4(sp),d0
	move.l	8(sp),a0
	move.l	_IFFBase,a6
	jmp	-90(a6)

	END


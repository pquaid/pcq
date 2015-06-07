*
*	Blitter.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	These are the glue routines for the procedures and functions
*	defined in Include/Graphics/Blitter.i
*

	SECTION PCQ_Runtime,CODE

	XREF	_GfxBase

	XREF	_LVOBltBitMap
	XDEF	_BltBitMap
_BltBitMap
	movem.l	d2/d3/d4/d5/d6/d7,-(sp)
	move.l	24+4(sp),a2
	move.w	24+8(sp),d7
	move.w	24+10(sp),d6
	move.w	24+12(sp),d5
	move.w	24+14(sp),d4
	move.w	24+16(sp),d3
	move.w	24+18(sp),d2
	move.l	24+20(sp),a1
	move.w	24+24(sp),d1
	move.w	24+26(sp),d0
	move.l	24+28(sp),a0
	move.l	_GfxBase,a6
	jsr	_LVOBltBitMap(a6)
	movem.l	(sp)+,d2/d3/d4/d5/d6/d7
	rts

	XREF	_LVOBltBitMapRastPort
	XDEF	_BltBitMapRastPort
_BltBitMapRastPort
	movem.l	d2/d3/d4/d5/d6,-(sp)
	move.w	20+4(sp),d6
	move.w	20+6(sp),d5
	move.w	20+8(sp),d4
	move.w	20+10(sp),d3
	move.w	20+12(sp),d2
	move.l	20+14(sp),a1
	move.w	20+18(sp),d1
	move.w	20+20(sp),d0
	move.l	20+22(sp),a0
	move.l	_GfxBase,a6
	jsr	_LVOBltBitMapRastPort(a6)
	movem.l	(sp)+,d2/d3/d4/d5/d6
	rts


	XREF	_LVOBltClear
	XDEF	_BltClear
_BltClear
	move.l	4(sp),d1
	move.l	8(sp),d0
	move.l	12(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOBltClear(a6)


	XREF	_LVOBltMaskBitMapRastPort
	XDEF	_BltMaskBitMapRastPort
_BltMaskBitMapRastPort
	movem.l	d2/d3/d4/d5/d6,-(sp)
	move.l	20+4(sp),a2
	move.w	20+8(sp),d6
	move.w	20+10(sp),d5
	move.w	20+12(sp),d4
	move.w	20+14(sp),d3
	move.w	20+16(sp),d2
	move.l	20+18(sp),a1
	move.w	20+22(sp),d1
	move.w	20+24(sp),d0
	move.l	20+26(sp),a0
	move.l	_GfxBase,a6
	jsr	_LVOBltMaskBitMapRastPort(a6)
	movem.l	(sp)+,d2/d3/d4/d5/d6
	rts


	XDEF	_BltPattern
	XREF	_LVOBltPattern
_BltPattern
	movem.l	d2/d3/d4,-(sp)
	move.w	12+4(sp),d4
	move.w	12+6(sp),d3
	move.w	12+8(sp),d2
	move.w	12+10(sp),d1
	move.w	12+12(sp),d0
	move.l	12+14(sp),a0
	move.l	12+18(sp),a1
	move.l	_GfxBase,a6
	jsr	_LVOBltPattern(a6)
	movem.l	(sp)+,d2/d3/d4
	rts


	XREF	_LVOBltTemplate
	XDEF	_BltTemplate
_BltTemplate
	movem.l	d2/d3/d4/d5,-(sp)
	move.w	16+4(sp),d5
	move.w	16+6(sp),d4
	move.w	16+8(sp),d3
	move.w	16+10(sp),d2
	move.l	16+12(sp),a1
	move.w	16+16(sp),d1
	move.w	16+18(sp),d0
	move.l	16+20(sp),a0
	move.l	_GfxBase,a6
	jsr	_LVOBltTemplate(a6)
	movem.l	(sp)+,d2/d3/d4/d5
	rts


	XREF	_LVOClipBlit
	XDEF	_ClipBlit
_ClipBlit
	movem.l	d2/d3/d4/d5/d6,-(sp)
	move.w	20+4(sp),d6
	move.w	20+6(sp),d5
	move.w	20+8(sp),d4
	move.w	20+10(sp),d3
	move.w	20+12(sp),d2
	move.l	20+14(sp),a1
	move.w	20+18(sp),d1
	move.w	20+20(sp),d0
	move.l	20+22(sp),a0
	move.l	_GfxBase,a6
	jsr	_LVOClipBlit(a6)
	movem.l	(sp)+,d2/d3/d4/d5/d6
	rts


	XREF	_LVODisownBlitter
	XDEF	_DisownBlitter
_DisownBlitter
	move.l	_GfxBase,a6
	jmp	_LVODisownBlitter(a6)


	XREF	_LVOOwnBlitter
	XDEF	_OwnBlitter
_OwnBlitter
	move.l	_GfxBase,a6
	jmp	_LVOOwnBlitter(a6)


	XREF	_LVOQBlit
	XDEF	_QBlit
_QBlit
	move.l	4(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOQBlit(a6)


	XREF	_LVOQBSBlit
	XDEF	_QBSBlit
_QBSBlit
	move.l	4(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOQBSBlit(a6)


	XREF	_LVOWaitBlit
	XDEF	_WaitBlit
_WaitBlit
	move.l	_GfxBase,a6
	jmp	_LVOWaitBlit(a6)


	END

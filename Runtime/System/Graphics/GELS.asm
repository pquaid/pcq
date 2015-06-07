*
*	GELS.asm for PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	These are the glue routines for the procedures and functions
*	defined in Include/Graphics/GELS.i
*

	SECTION PCQ_Runtime,CODE

	XREF	_GfxBase


	XREF	_LVOAddAnimOb
	XDEF	_AddAnimOb
_AddAnimOb
	move.l	4(sp),a2
	move.l	8(sp),a1
	move.l	12(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOAddAnimOb(a6)


	XREF	_LVOAddBob
	XDEF	_AddBob
_AddBob
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOAddBob(a6)


	XREF	_LVOAddVSprite
	XDEF	_AddVSprite
_AddVSprite
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOAddVSprite(a6)


	XREF	_LVOAnimate
	XDEF	_Animate
_Animate
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOAnimate(a6)


	XREF	_LVODoCollision
	XDEF	_DoCollision
_DoCollision
	move.l	4(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVODoCollision(a6)


	XREF	_LVODrawGList
	XDEF	_DrawGList
_DrawGList
	move.l	4(sp),a0
	move.l	8(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVODrawGList(a6)


	XREF	_LVOFreeGBuffers
	XDEF	_FreeGBuffers
_FreeGBuffers
	move.w	4(sp),d0
	move.l	6(sp),a1
	move.l	10(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOFreeGBuffers(a6)


	XREF	_LVOGetGBuffers
	XDEF	_GetGBuffers
_GetGBuffers
	move.w	4(sp),d0
	move.l	6(sp),a1
	move.l	10(sp),a0
	move.l	_GfxBase,a6
	jsr	_LVOGetGBuffers(a6)
	tst.l	d0
	sne	d0
	rts

	XREF	_LVOInitGels
	XDEF	_InitGels
_InitGels
	move.l	4(sp),a2
	move.l	8(sp),a1
	move.l	12(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOInitGels(a6)


	XREF	_LVOInitGMasks
	XDEF	_InitGMasks
_InitGMasks
	move.l	4(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOInitGMasks(a6)


	XREF	_LVOInitMasks
	XDEF	_InitMasks
_InitMasks
	move.l	4(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOInitMasks(a6)


	XDEF	_RemBob
_RemBob
	move.l	4(sp),a0
	or.w	#$0400,(a0)	; b.Flags |= BOBSAWAY
	rts

	XREF	_LVORemIBob
	XDEF	_RemIBob
_RemIBob
	move.l	4(sp),a2
	move.l	8(sp),a1
	move.l	12(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVORemIBob(a6)


	XREF	_LVORemVSprite
	XDEF	_RemVSprite
_RemVSprite
	move.l	4(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVORemVSprite(a6)


	XREF	_LVOSetCollision
	XDEF	_SetCollision
_SetCollision
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	12(sp),d0
	move.l	_GfxBase,a6
	jmp	_LVOSetCollision(a6)


	XREF	_LVOSortGList
	XDEF	_SortGList
_SortGList
	move.l	4(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOSortGList(a6)

	END

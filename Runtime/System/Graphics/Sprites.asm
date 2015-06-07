*
*	Sprites.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	These are the glue routines for the procedures and functions
*	defined in Include/Graphics/Sprites.i
*

	SECTION PCQ_Runtime,CODE

	XREF	_GfxBase

	XREF	_LVOChangeSprite
	XDEF	_ChangeSprite
_ChangeSprite
	move.l	4(sp),a2
	move.l	8(sp),a1
	move.l	12(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOChangeSprite(a6)


	XREF	_LVOFreeSprite
	XDEF	_FreeSprite
_FreeSprite
	move.w	4(sp),d0
	move.l	_GfxBase,a6
	jmp	_LVOFreeSprite(a6)


	XREF	_LVOGetSprite
	XDEF	_GetSprite
_GetSprite
	move.w	4(sp),d0
	move.l	6(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOGetSprite(a6)


	XREF	_LVOMoveSprite
	XDEF	_MoveSprite
_MoveSprite
	move.w	4(sp),d1
	move.w	6(sp),d0
	move.l	8(sp),a1
	move.l	12(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOMoveSprite(a6)

	END

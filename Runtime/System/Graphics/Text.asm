*
*	Text.asm of PCQ Pascal
*	Copyright (c) 1990 Patrick Quaid
*
*	These are the glue routines for the procedures and functions
*	defined in Include/Graphics/Text.i
*

	SECTION PCQ_Runtime,CODE

	XREF	_GfxBase

	XREF	_LVOAddFont
	XDEF	_AddFont
_AddFont
	move.l	4(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOAddFont(a6)


	XREF	_LVOAskFont
	XDEF	_AskFont
_AskFont
	movem.l	4(sp),a0/a1
	move.l	_GfxBase,a6
	jmp	_LVOAskFont(a6)


	XREF	_LVOAskSoftStyle
	XDEF	_AskSoftStyle
_AskSoftStyle
	move.l	4(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOAskSoftStyle(a6)


	XREF	_LVOClearEOL
	XDEF	_ClearEOL
_ClearEOL
	move.l	4(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOClearEOL(a6)


	XREF	_LVOClearScreen
	XDEF	_ClearScreen
_ClearScreen
	move.l	4(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOClearScreen(a6)


	XREF	_LVOCloseFont
	XDEF	_CloseFont
_CloseFont
	move.l	4(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVOCloseFont(a6)


	XREF	_LVOOpenFont
	XDEF	_OpenFont
_OpenFont
	move.l	4(sp),a0
	move.l	_GfxBase,a6
	jmp	_LVOOpenFont(a6)


	XREF	_LVORemFont
	XDEF	_RemFont
_RemFont
	move.l	4(sp),a1
	move.l	_GfxBase,a6
	jmp	_LVORemFont(a6)


	XREF	_LVOSetFont
	XDEF	_SetFont
_SetFont
	movem.l	4(sp),a0/a1
	move.l	_GfxBase,a6
	jmp	_LVOSetFont(a6)


	XREF	_LVOSetSoftStyle
	XDEF	_SetSoftStyle
_SetSoftStyle
	move.l	4(sp),d1
	movem.l	8(sp),d0/a1
	move.l	_GfxBase,a6
	jmp	_LVOSetSoftStyle(a6)


	XREF	_LVOText
	XDEF	_GText
_GText
	move.w	4(sp),d0
	movem.l	6(sp),a0/a1
	move.l	_GfxBase,a6
	jmp	_LVOText(a6)


	XREF	_LVOTextLength
	XDEF	_TextLength
_TextLength
	move.w	4(sp),d0
	movem.l	6(sp),a0/a1
	move.l	_GfxBase,a6
	jmp	_LVOTextLength(a6)

	END

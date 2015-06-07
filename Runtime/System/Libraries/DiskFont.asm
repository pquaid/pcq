*
*	DiskFont.asm for PCQ Pascal
*	Copyright 1990 Patrick Quaid
*
*	These are the glue routines for the procedures and functions
*	defined in Include/Libraries/DiskFont.i.
*
*

	SECTION	PCQ_Runtime,CODE

	XREF	_DiskFontBase

	XREF	_LVOAvailFonts
	XDEF	_AvailFonts
_AvailFonts
	move.l	4(sp),d1
	move.l	8(sp),d0
	move.l	12(sp),a0
	move.l	_DiskFontBase,a6
	jmp	_LVOAvailFonts(a6)

	XDEF	_DisposeFontContents
	XREF	_LVODisposeFontContents
_DisposeFontContents
	move.l	4(sp),a1
	move.l	_DiskFontBase,a6
	jmp	_LVODisposeFontContents(a6)

	XDEF	_NewFontContents
	XREF	_LVONewFontContents
_NewFontContents
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.l	_DiskFontBase,a6
	jmp	_LVONewFontContents(a6)

	XDEF	_OpenDiskFont
	XREF	_LVOOpenDiskFont
_OpenDiskFont
	move.l	4(sp),a0
	move.l	_DiskFontBase,a6
	jmp	_LVOOpenDiskFont(a6)

	END

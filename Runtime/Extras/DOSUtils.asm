*
*	DOSUtils.asm for PCQ Pascal
*	Copyright 1990 Patrick Quaid
*
*	These are a couple of handy routines for using AmigaDOS.  They
*	are declared in Include/Utils/DOSUtils.i.
*
*

	SECTION	PCQ_Runtime,CODE

	XREF	_p%DOSBase

	XDEF	_APTRtoBPTR
_APTRtoBPTR
	move.l	4(sp),d0
	lsr.l	#2,d0
	rts

	XDEF	_BPTRtoAPTR
_BPTRtoAPTR
	move.l	4(sp),d0
	lsl.l	#2,d0
	rts

	XDEF	_GetFileHandle
_GetFileHandle
	move.l	4(sp),a0
	move.l	(a0),d0
	rts

	END

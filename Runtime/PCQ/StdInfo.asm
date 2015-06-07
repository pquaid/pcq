*
*  StdInfo.asm of PCQ Pascal
*  Copyright (c) 1991 Patrick Quaid
*
*  This module defines the common data area that all programs have.
*

	XDEF	dosname
	XDEF	intuitionname
	XDEF	mathname

	XDEF	_DOSBase
	XDEF	_IntuitionBase

	XDEF	_p%DOSBase
	XDEF	_p%IntuitionBase
	XDEF	_p%MathBase
	XDEF	_p%WorkBenchMsg

	XDEF	_CommandLine
	XDEF	StkPtr
	XDEF	newkey
	XDEF	_HeapError

	SECTION	PCQ_DATA,DATA

dosname		dc.b	'dos.library',0
intuitionname	dc.b	'intuition.library',0
mathname	dc.b	'mathffp.library',0

	SECTION	PCQ_BSS,BSS

_DOSBase
_p%DOSBase	ds.l	1

_IntuitionBase
_p%IntuitionBase ds.l	1

_p%MathBase	ds.l	1
_p%WorkBenchMsg	ds.l	1

_CommandLine	ds.l	1

StkPtr		ds.l	1
newkey		ds.l	1
_HeapError	ds.l	1

	END


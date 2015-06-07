*
*	ARexxStrings.asm for PCQ Pascal
*	Copyright 1990 Patrick Quaid
*
*	These routines call the ARexx resident library for the
*	procedures and functions declared in Include/Rexx/ARexxStrings.i
*


        SECTION PCQ_Runtime,CODE

	XREF	_RexxSysBase

_LVOErrorMsg	EQU	-96
	XDEF	_LVOErrorMsg
	XDEF	_ErrorMsg
_ErrorMsg
	move.l	8(sp),d0
	move.l	_RexxSysBase,a6
	jsr	_LVOErrorMsg(a6)
	move.l	4(sp),a1
	move.l	a0,(a1)
	rts

_LVOIsSymbol	EQU	-102
	XDEF	_LVOIsSymbol
	XDEF	_IsSymbol
_IsSymbol
	move.l	8(sp),a0
	move.l	_RexxSysBase,a6
	jsr	_LVOIsSymbol(a6)
	move.l	4(sp),a0
	move.l	d1,(a0)
	rts

_LVOLengthArgstring	EQU	-138
	XDEF	_LVOLengthArgstring
	XDEF	_LengthArgstring
_LengthArgstring
	move.l	4(sp),a0
	move.l	_RexxSysBase,a6
	jmp	_LVOLengthArgstring(a6)

_LVOListNames		EQU	-210
	XDEF	_LVOListNames
	XDEF	_ListNames
_ListNames
	move.l	6(sp),a0
	move.w	4(sp),d0
	move.l	_RexxSysBase,a6
	jmp	_LVOListNames(a6)

_LVOCmpString		EQU	-240
	XDEF	_LVOCmpString
	XDEF	_RexxCmpString
_RexxCmpString
	move.l	8(sp),a0
	move.l	4(sp),a1
	move.l	_RexxSysBase,a6
	jmp	_LVOCmpString(a6)

_LVOStcToken		EQU	-246
	XDEF	_LVOStcToken
	XDEF	_StcToken
_StcToken
	move.l	20(sp),a0
	move.l	_RexxSysBase,a6
	jsr	_LVOStcToken(a6)
	move.l	16(sp),a6
	move.b	d0,(a6)
	move.l	12(sp),a6
	move.l	d1,(a6)
	move.l	8(sp),a6
	move.l	a0,(a6)
	move.l	4(sp),a6
	move.l	a1,(a6)
	rts

_LVOStrcmpN	EQU	-252
	XDEF	_LVOStrcmpN
	XDEF	_StrcmpN
_StrcmpN
	move.l	12(sp),a0
	movem.l	4(sp),d0/a1
	move.l	_RexxSysBase,a6
	jmp	_LVOStrcmpN(a6)

_LVOStrcmpU	EQU	-258
	XDEF	_LVOStrcmpU
	XDEF	_StrcmpU
_StrcmpU
	movem.l	4(sp),d0/a1
	move.l	12(sp),a0
	move.l	_RexxSysBase,a6
	jmp	_LVOStrcmpU(a6)

_LVOStrcpyA	EQU	-264
	XDEF	_LVOStrcpyA
	XDEF	_StrcpyA
_StrcpyA
	move.l	12(sp),a0
	movem.l	4(sp),d0/a1
	move.l	_RexxSysBase,a6
	jmp	_LVOStrcpyA(a6)

_LVOStrcpyN	EQU	-270
	XDEF	_LVOStrcpyN
	XDEF	_StrcpyN
_StrcpyN
	move.l	12(sp),a0
	movem.l	4(sp),d0/a1
	move.l	_RexxSysBase,a6
	jmp	_LVOStrcpyN(a6)

_LVOStrcpyU	EQU	-276
	XDEF	_LVOStrcpyU
	XDEF	_StrcpyU
_StrcpyU
	move.l	12(sp),a0
	movem.l	4(sp),d0/a1
	move.l	_RexxSysBase,a6
	jmp	_LVOStrcpyU(a6)

_LVOStrflipN	EQU	-282
	XDEF	_LVOStrflipN
	XDEF	_StrflipN
_StrflipN
	movem.l	4(sp),d0/a0
	move.l	_RexxSysBase,a6
	jmp	_LVOStrflipN(a6)

_LVOStrlen	EQU	-288
	XDEF	_LVOStrlen
	XDEF	_RexxStrlen
_RexxStrlen
	move.l	4(sp),a0
	move.l	_RexxSysBase,a6
	jmp	_LVOStrlen(a6)

_LVOToUpper	EQU	-294
	XDEF	_LVOToUpper
	XDEF	_RexxToUpper
_RexxToUpper
	move.w	4(sp),d0
	move.l	_RexxSysBase,a6
	jmp	_LVOToUpper(a6)

_LVOCVa2i	EQU	-300
	XDEF	_LVOCVa2i
	XDEF	_CVa2i
_CVa2i
	move.l	8(sp),a0
	move.l	_RexxSysBase,a6
	jsr	_LVOCVa2i(a6)
	move.l	4(sp),a0
	move.l	d1,(a0)
	rts

_LVOCVi2a	EQU	-306
	XDEF	_LVOCVi2a
	XDEF	_CVi2a
_CVi2a
	movem.l	12(sp),d0/a0
	move.l	8(sp),d1
	move.l	_RexxSysBase,a6
	jsr	_LVOCVi2a(a6)
	move.l	4(sp),a1
	move.l	a0,(a1)
	rts

_LVOCVi2arg	EQU	-312
	XDEF	_LVOCVi2arg
	XDEF	_CVi2arg
_CVi2arg
	move.l	8(sp),d0
	move.l	4(sp),d1
	move.l	_RexxSysBase,a6
	jmp	_LVOCVi2arg(a6)

_LVOCVi2az	EQU	-318
	XDEF	_LVOCVi2az
	XDEF	_CVi2az
_CVi2az
	movem.l	12(sp),d0/a0
	move.l	8(sp),d1
	move.l	_RexxSysBase,a6
	jsr	_LVOCVi2az(a6)
	move.l	4(sp),a1
	move.l	a0,(a1)
	rts

_LVOCVc2x	EQU	-324
	XDEF	_LVOCVc2x
	XDEF	_CVc2x
_CVc2x
	move.l	16(sp),a0
	movem.l	8(sp),d0/a1
	move.l	4(sp),d1
	move.l	_RexxSysBase,a6
	jmp	_LVOCVc2x(a6)

_LVOCVx2c	EQU	-330
	XDEF	_LVOCVx2c
	XDEF	_CVx2c
_CVx2c
	move.l	16(sp),a0
	movem.l	8(sp),d0/a1
	move.l	4(sp),d1
	move.l	_RexxSysBase,a6
	jmp	_LVOCVx2c(a6)

	END

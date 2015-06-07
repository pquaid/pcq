*
*	RxsLib.asm for PCQ Pascal
*	Copyright 1990 Patrick Quaid
*
*	These routines call the ARexx resident library for the
*	procedures and functions declared in Include/Rexx/RxsLib.i
*


        SECTION PCQ_Runtime,CODE

	XREF	_RexxSysBase

_LVORexx	EQU	-30
	XDEF	_LVORexx
_LVOrxParse	EQU	-36	; (private)
	XDEF	_LVOrxParse
_LVOrxInstruct	EQU	-42	; (private)
	XDEF	_LVOrxInstruct
_LVOrxSuspend	EQU	-48	; (private)
	XDEF	_LVOrxSuspend
_LVOEvalOp	EQU	-54	; (private)
	XDEF	_LVOEvalOp
_LVOAssignValue	EQU	-60	; (private)
	XDEF	_LVOAssignValue
_LVOEnterSymbol	EQU	-66	; (private)
	XDEF	_LVOEnterSymbol
_LVOFetchValue	EQU	-72	; (private)
	XDEF	_LVOFetchValue
_LVOLookUpValue	EQU	-78	; (private)
	XDEF	_LVOLookUpValue
_LVOSetValue	EQU	-84	; (private)
	XDEF	_LVOSetValue
_LVOSymExpand	EQU	-90	; (private)
	XDEF	_LVOSymExpand

_LVOSendDOSPkt		EQU	-420	; private
	XDEF	_LVOSendDOSPkt
_LVOWaitDOSPkt		EQU	-426	; private
	XDEF	_LVOSendDOSPkt

_LVOLockRexxBase	EQU	-450
	XDEF	_LVOLockRexxBase
	XDEF	_LockRexxBase
_LockRexxBase
	move.l	4(sp),d0
	move.l	_RexxSysBase,a6
	jmp	_LVOLockRexxBase(a6)

_LVOUnlockRexxBase	EQU	-456
	XDEF	_LVOUnlockRexxBase
	XDEF	_UnlockRexxBase
_UnlockRexxBase
	move.l	4(sp),d0
	move.l	_RexxSysBase,a6
	jmp	_LVOUnlockRexxBase(a6)

	END

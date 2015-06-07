*
*	Storage.asm for PCQ Pascal
*	Copyright 1990 Patrick Quaid
*
*	These routines call the ARexx resident library for the
*	procedures and functions declared in Include/Rexx/Storage.i
*


        SECTION PCQ_Runtime,CODE

	XREF	_RexxSysBase

_LVOCurrentEnv	EQU	-108
	XDEF	_LVOCurrentEnv
	XDEF	_CurrentEnv
_CurrentEnv
	move.l	4(sp),a0
	move.l	_RexxSysBase,a6
	jmp	_LVOCurrentEnv(a6)

_LVOGetSpace	EQU	-114
	XDEF	_LVOGetSpace
	XDEF	_GetSpace
_GetSpace
	movem.l	4(sp),d0/a0
	move.l	_RexxSysBase,a6
	jmp	_LVOGetSpace(a6)

_LVOFreeSpace	EQU	-120
	XDEF	_LVOFreeSpace
	XDEF	_FreeSpace
_FreeSpace
	move.l	12(sp),a0
	movem.l	4(sp),d0/a1
	move.l	_RexxSysBase,a6
	jmp	_LVOFreeSpace(a6)

_LVOCreateArgstring	EQU	-126
	XDEF	_LVOCreateArgstring
	XDEF	_CreateArgstring
_CreateArgstring
	movem.l	4(sp),d0/a0
	move.l	_RexxSysBase,a6
	jmp	_LVOCreateArgstring(a6)

_LVODeleteArgstring	EQU	-132
	XDEF	_LVODeleteArgstring
	XDEF	_DeleteArgstring
_DeleteArgstring
	move.l	4(sp),a0
	move.l	_RexxSysBase,a6
	jmp	_LVODeleteArgstring(a6)

_LVOCreateRexxMsg	EQU	-144
	XDEF	_LVOCreateRexxMsg
	XDEF	_CreateRexxMsg
_CreateRexxMsg
	move.l	12(sp),a0
	movem.l	4(sp),d0/a1
	move.l	_RexxSysBase,a6
	jmp	_LVOCreateRexxMsg(a6)

_LVODeleteRexxMsg	EQU	-150
	XDEF	_LVODeleteRexxMsg
	XDEF	_DeleteRexxMsg
_DeleteRexxMsg
	move.l	4(sp),a0
	move.l	_RexxSysBase,a6
	jmp	_LVODeleteRexxMsg(a6)

_LVOClearRexxMsg	EQU	-156
	XDEF	_LVOClearRexxMsg
	XDEF	_ClearRexxMsg
_ClearRexxMsg
	movem.l	4(sp),d0/a0
	move.l	_RexxSysBase,a6
	jmp	_LVOClearRexxMsg(a6)

_LVOFillRexxMsg		EQU	-162
	XDEF	_LVOFillRexxMsg
	XDEF	_FillRexxMsg
_FillRexxMsg
	movem.l	8(sp),d0/a0
	move.l	4(sp),d1
	move.l	_RexxSysBase,a6
	jmp	_LVOFillRexxMsg(a6)

_LVOIsRexxMsg		EQU	-168
	XDEF	_LVOIsRexxMsg
	XDEF	_IsRexxMsg
_IsRexxMsg
	move.l	4(sp),a0
	move.l	_RexxSysBase,a6
	jmp	_LVOIsRexxMsg(a6)


_LVOAddRsrcNode		EQU	-174
	XDEF	_LVOAddRsrcNode
	XDEF	_AddRsrcNode
_AddRsrcNode
	move.l	12(sp),a0
	movem.l	4(sp),d0/a1
	move.l	_RexxSysBase,a6
	jmp	_LVOAddRsrcNode(a6)

_LVOFindRsrcNode	EQU	-180
	XDEF	_LVOFindRsrcNode
	XDEF	_FindRsrcNode
_FindRsrcNode
	move.l	12(sp),a0
	movem.l	4(sp),d0/a1
	move.l	_RexxSysBase,a6
	jmp	_LVOFindRsrcNode(a6)

_LVORemRsrcList		EQU	-186
	XDEF	_LVORemRsrcList
	XDEF	_RemRsrcList
_RemRsrcList
	move.l	4(sp),a0
	move.l	_RexxSysBase,a6
	jmp	_LVORemRsrcList(a6)

_LVORemRsrcNode		EQU	-192
	XDEF	_LVORemRsrcNode
	XDEF	_RemRsrcNode
_RemRsrcNode
	move.l	4(sp),a0
	move.l	_RexxSysBase,a6
	jmp	_LVORemRsrcNode(a6)

_LVOOpenPublicPort	EQU	-198
	XDEF	_LVOOpenPublicPort
	XDEF	_OpenPublicPort
_OpenPublicPort
	move.l	8(sp),a0
	move.l	4(sp),a1
	move.l	_RexxSysBase,a6
	jmp	_LVOOpenPublicPort(a6)

_LVOClosePublicPort	EQU	-204
	XDEF	_LVOClosePublicPort
	XDEF	_ClosePublicPort
_ClosePublicPort
	move.l	4(sp),a0
	move.l	_RexxSysBase,a6
	jmp	_LVOClosePublicPort(a6)

_LVOClearMem		EQU	-216
	XDEF	_LVOClearMem
	XDEF	_ClearMem
_ClearMem
	movem.l	4(sp),d0/a0
	move.l	_RexxSysBase,a6
	jmp	_LVOClearMem(a6)

_LVOInitList		EQU	-222
	XDEF	_LVOInitList
	XDEF	_InitList
_InitList
	move.l	4(sp),a0
	move.l	_RexxSysBase,a6
	jmp	_LVOInitList(a6)

_LVOInitPort		EQU	-228
	XDEF	_LVOInitPort
	XDEF	_InitPort
_InitPort
	move.l	8(sp),a0
	move.l	4(sp),a1
	move.l	_RexxSysBase,a6
	jmp	_LVOInitPort(a6)

_LVOFreePort		EQU	-234
	XDEF	_LVOFreePort
	XDEF	_FreePort
_FreePort
	move.l	4(sp),a0
	move.l	_RexxSysBase,a6
	jmp	_LVOFreePort(a6)

_LVODOSCommand		EQU	-390
	XDEF	_LVODOSCommand

_LVOAddClipNode		EQU	-438
	XDEF	_LVOAddClipNode
	XDEF	_AddClipNode
_AddClipNode
	move.l	16(sp),a0
	movem.l	8(sp),d0/a1
	move.l	4(sp),d1
	move.l	_RexxSysBase,a6
	jmp	_LVOAddClipNode(a6)

_LVORemClipNode		EQU	-444
	XDEF	_LVORemClipNode
	XDEF	_RemClipNode
_RemClipNode
	move.l	4(sp),a0
	move.l	_RexxSysBase,a6
	jmp	_LVORemClipNode(a6)

	END

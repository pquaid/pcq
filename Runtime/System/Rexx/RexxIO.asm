*
*	RexxIO.asm for PCQ Pascal
*	Copyright 1990 Patrick Quaid
*
*	These routines call the ARexx resident library for the
*	procedures and functions declared in Include/Rexx/RexxIO.i
*


        SECTION PCQ_Runtime,CODE

	XREF	_RexxSysBase

_LVOOpenF	EQU	-336
	XDEF	_LVOOpenF
	XDEF	_OpenF
_OpenF
	move.l	16(sp),a0
	movem.l	8(sp),d0/a1
	move.l	4(sp),d1
	move.l	_RexxSysBase,a6
	jmp	_LVOOpenF(a6)

_LVOCloseF	EQU	-342
	XDEF	_LVOCloseF
	XDEF	_CloseF
_CloseF
	move.l	4(sp),a0
	move.l	_RexxSysBase,a6
	jmp	_LVOCloseF(a6)

_LVOReadStr	EQU	-348
	XDEF	_LVOReadStr
	XDEF	_ReadStr
_ReadStr
	move.l	16(sp),a0
	movem.l	8(sp),d0/a1
	move.l	_RexxSysBase,a6
	jsr	_LVOReadStr(a6)
	move.l	4(sp),a0
	move.l	a1,(a0)
	rts

_LVOReadF	EQU	-354
	XDEF	_LVOReadF
	XDEF	_ReadF
_ReadF
	move.l	12(sp),a0
	movem.l	4(sp),d0/a1
	move.l	_RexxSysBase,a6
	jmp	_LVOReadF(a6)

_LVOWriteF	EQU	-360
	XDEF	_LVOWriteF
	XDEF	_WriteF
_WriteF
	move.l	12(sp),a0
	movem.l	4(sp),d0/a1
	move.l	_RexxSysBase,a6
	jmp	_LVOWriteF(a6)

_LVOSeekF	EQU	-366
	XDEF	_LVOSeekF
	XDEF	_SeekF
_SeekF
	movem.l	8(sp),d0/a0
	move.l	4(sp),d1
	move.l	_RexxSysBase,a6
	jmp	_LVOSeekF(a6)

_LVOQueueF	EQU	-372
	XDEF	_LVOQueueF
	XDEF	_QueueF
_QueueF
	move.l	12(sp),a0
	movem.l	4(sp),d0/a1
	move.l	_RexxSysBase,a6
	jmp	_LVOQueueF(a6)

_LVOStackF	EQU	-378
	XDEF	_LVOStackF
	XDEF	_StackF
_StackF
	move.l	12(sp),a0
	movem.l	4(sp),d0/a1
	move.l	_RexxSysBase,a6
	jmp	_LVOStackF(a6)

_LVOExistF	EQU	-384
	XDEF	_LVOExistF
	XDEF	_ExistF
_ExistF
	move.l	4(sp),a0
	move.l	_RexxSysBase,a6
	jmp	_LVOExistF(a6)

_LVODOSRead		EQU	-396
	XDEF	_LVODOSRead
	XDEF	_RexxDOSRead
_RexxDOSRead
	move.l	12(sp),a0
	movem.l	4(sp),d0/a1
	move.l	_RexxSysBase,a6
	jmp	_LVODOSRead(a6)

_LVODOSWrite		EQU	-402
	XDEF	_LVODOSWrite
	XDEF	_RexxDOSWrite
_RexxDOSWrite
	move.l	12(sp),a0
	movem.l	4(sp),d0/a1
	move.l	_RexxSysBase,a6
	jmp	_LVODOSWrite(a6)

_LVOCreateDOSPkt	EQU	-408
	XDEF	_LVOCreateDOSPkt
	XDEF	_CreateDOSPkt
_CreateDOSPkt
	move.l	_RexxSysBase,a6
	jmp	_LVOCreateDOSPkt(a6)

_LVODeleteDOSPkt	EQU	-414
	XDEF	_LVODeleteDOSPkt
	XDEF	_DeleteDOSPkt
_DeleteDOSPkt
	move.l	4(sp),a0
	move.l	_RexxSysBase,a6
	jmp	_LVODeleteDOSPkt(a6)

_LVOFindDevice		EQU	-432
	XDEF	_LVOFindDevice
	XDEF	_FindDevice
_FindDevice
	movem.l	4(sp),d0/a0
	move.l	_RexxSysBase,a6
	jmp	_LVOFindDevice(a6)

	END

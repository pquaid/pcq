*
*       PCQMemory.asm of PCQ Pascal
*
*       This file implements the routines defined in
*       Utils/PCQMemory.i.  In the future, these will be
*       standard procedures.
*

        XREF    _p%new
        XREF    _p%dispose


	SECTION	PCQ_Runtime,CODE

	XDEF	_GetMem
_GetMem
        move.l  4(sp),d0
        jsr     _p%new
        move.l  8(sp),a0
        move.l  d0,(a0)
        rts

	XDEF	_FreePCQMem
_FreePCQMem
        move.l  8(sp),a0
        move.l  (a0),d0
        jmp     _p%dispose

        END

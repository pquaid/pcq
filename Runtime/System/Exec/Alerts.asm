*
*	Alert.asm (of PCQ Pascal)
*	Copyright (c) 1990 Patrick Quaid
*
*	This file contains the glue routines for the functions
*	defined in Include/Exec/Alerts.i.  So far, that's just
*	Alert()
*


	SECTION	PCQ_Runtime,CODE

	XREF	_AbsExecBase

	XREF	_LVOAlert
	XDEF	_Alert
_Alert
	movem.l	a5/d7,-(sp)
	move.l	12(sp),a5
	move.l	16(sp),d7
	move.l	_AbsExecBase,a6
	jsr	_LVOAlert(a6)
	movem.l	(sp)+,a5/d7
	rts

	END

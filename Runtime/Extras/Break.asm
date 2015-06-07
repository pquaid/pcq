*
*	Break.asm (of PCQ Pascal runtime library)
*	Copyright (c) 1990 Patrick Quaid
*
*	This just checks whether the Ctrl-C was pressed.
*

	SECTION	PCQ_Runtime,CODE

	XREF	_LVOSetSignal
	XREF	_AbsExecBase

	XDEF	_CheckBreak
_CheckBreak
	move.l	_AbsExecBase,a6
	moveq	#0,d0
	moveq	#0,d1
	jsr	_LVOSetSignal(a6)
	and.l	#4096,d0
	sne	d0
	rts

	END

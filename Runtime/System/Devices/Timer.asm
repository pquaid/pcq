
*
*	Timer.asm
*	of PCQ Pascal (c) 1990 Patrick Quaid
*
*	Makes the actual calls to the timer.device.  Note that TimerBase
*	must have been set up previously, either by a call to CreateTimer
*	or by pulling the device pointer from a valid TimerRequest.
*

	SECTION	PCQ_Runtime,CODE

	XREF	_TimerBase
	XREF	_LVOAddTime
	XREF	_LVOCmpTime
	XREF	_LVOSubTime

	XDEF	_AddTime
_AddTime
	move.l	8(sp),a0
	move.l	4(sp),a1
	move.l	_TimerBase,a6
	jmp	_LVOAddTime(a6)

	XDEF	_CmpTime
_CmpTime
	move.l	8(sp),a0
	move.l	4(sp),a1
	move.l	_TimerBase,a6
	jmp	_LVOAddTime(a6)

	XDEF	_SubTime
_SubTime
	move.l	8(sp),a0
	move.l	4(sp),a1
	move.l	_TimerBase,a6
	jmp	_LVOSubTime(a6)

	END

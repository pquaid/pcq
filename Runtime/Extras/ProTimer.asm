*
*	ProTimer.asm of PCQ Pascal
*
*	If you are profiling a program that doesn't use the
*	timer device, you will need to get _TimerBase from
*	somewhere.  This is defined here just in case it's
*	not defined anywhere else.
*

	XDEF	_TimerBase

	SECTION	PCQ_DATA,DATA

_TimerBase	dc.l	0

	end


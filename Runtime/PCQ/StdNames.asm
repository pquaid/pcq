*
*	StandardNames.asm (of the PCQ Pascal runtime library)
*	Copyright (c) 1989 Patrick Quaid
*
*	This file defines the default Input and Output file names
*	to be used when a program is run from the Workbench but tries
*	to do a ReadLn or WriteLn or whatever.  These values (of type
*	string) can be overridden by defining a global variable or
*	global typed constant with the same name (the linker will
*	choose the object defined in a FROM file in preference to
*	an object defined in a library).
*

	XDEF	_StdInName
	XDEF	_StdOutName

	SECTION	PCQ_DATA,DATA

_StdInName	dc.l	InName
_StdOutName	dc.l	InName		; same darned thing

InName	dc.b	'CON:0/0/640/200/',0

	END

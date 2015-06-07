*
*	Console.asm
*	These routines just calls the two Console.device library-like
*	routines.

	SECTION	PCQ_Runtime,CODE

	XREF	_ConsoleBase
	XREF	_LVORawKeyConvert
	XREF	_LVOCDInputHandler

	XDEF	_RawKeyConvert
_RawKeyConvert
	move.l	16(sp),a0
	movem.l	8(sp),d1/a1
	move.l	4(sp),a2
	move.l	_ConsoleBase,a6
	jmp	_LVORawKeyConvert(a6)

	XDEF	_CDInputHandler
_CDInputHandler
	move.l	8(sp),a0
	move.l	4(sp),a1
	move.l	_ConsoleBase,a6
	jmp	_LVOCDInputHandler(a6)

	END


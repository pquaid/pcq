*
*	Translator.asm for PCQ Pascal
*	Copyright 1990 Patrick Quaid
*
*
*	Stub for the Translate() routine defined in
*	Include/Libraries/Translator.i


	XREF	_TranslatorBase

	SECTION	PCQ_Runtime,CODE

	XREF	_LVOTranslate
	XDEF	_Translate
_Translate
	movem.l	4(sp),d1/a1
	movem.l	12(sp),d0/a0
	move.l	_TranslatorBase,a6
	jmp	_LVOTranslate(a6)

	END

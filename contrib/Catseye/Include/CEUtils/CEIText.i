{

	CEIText.i for PCQ Pascal

	Cat'sEye

	IntuiText : Useful in menus and gadgets... These should be
	easy enough to figure out.

}

{$I "Include:CEUtils/IntuiStuff.i"}

Function IText (Words : String; X,Y,ITColour,ITBackColour: Integer;
		Next : IntuiTextPtr) : IntuiTextPtr;
	External;
Function Shadow (Words : String; X,Y,Col1,Col2,BCol: Integer;
		Next: IntuiTextPtr): IntuiTextPtr;
	External;
Procedure FreeIText (IT : IntuiTextPtr);
	External;

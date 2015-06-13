{

	CEBorders.i for PCQ Pascal

	Cat'sEye

	Intuition Borders : Used for gadgets, &c. All of these
	functions except BorderWindow and MImage allocate
	a nice handy border.

}

{$I "Include:CEUtils/IntuiStuff.i"}

Function PlainBorder (x1,y1,wid,hite,col : Short) : BorderPtr;
	External;
Function TechnoBorder (x1,y1,wid,hite,col1,col2 : Short) : BorderPtr;
	External;
Function WBTechnoBorder (x1,y1,wid,hite,col1,col2 : Short) : BorderPtr;
	External;
Function MBorder (x1,y1,wid,hite,col1,col2: Short; BType: BordType)
	: BorderPtr;
	External;
Function MImage (x,y,col: short) : ImagePtr;
	External;
Function ArrowBord (X,Y,Wid,Hite,Col: Short; Dir: DirType) : BorderPtr;
	External;
Procedure BorderWindow (W : WindowPtr; Bent : BordType; Clr : Boolean);
	External;
Procedure FreeImage (Im : ImagePtr);
	External;
Procedure FreeBorder (Bd : BorderPtr);
	External;

{

	CEMenus.i for PCQ Pascal

	Cat'sEye

	These routines are here as a valid substitute to BuildMenu.i
	for allocating Menus. You have to link them together and
	set them up yourself. More flexibility, less programmer-friendly.

}

{$I "Include:CEUtils/IntuiStuff.i"}

Function MMenu (Title: String; LE: Short;
		FItem: MenuItemPtr; var CMW : Short) : MenuPtr;
	External;
Function MItem (Name : String; ShortCut : Char; CheckT: CheckType;
		VPos : Short; SubPtr: MenuItemPtr; MH : Short;
		Var CMW : Short) : MenuItemPtr;
	External;
Function MSub (Name : String; ShortCut : Char; CheckT: CheckType;
	 	VPos : Short; MH : Short; Var CMW : Short) : MenuItemPtr;
	External;
Procedure GetMenuNum (Var MP, IP, SP : Short; Code: Short);
	External;
Procedure PutMenuNum (MP, IP, SP : Short; Var Code: Short);
	External;

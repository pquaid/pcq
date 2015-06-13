{

	CEOpenThe.i for PCQ Pascal

	Cat'sEye

}

{$I "Include:CEUtils/IntuiStuff.i"}

Function OpenTheWindow(St: String; X1,Y1,X2,Y2,WinFlags,IDFlags:integer;
                       Gadgetp:GadgetPtr; s:Address) : WindowPtr;
	External;
Function OpenTheScreen(St: String; Wid,Hite,Dep,VM : integer) : ScreenPtr;
	External;

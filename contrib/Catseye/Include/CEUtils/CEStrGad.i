{

	CEStrGad.i	Cat'sEye's String Gadgets for PCQ Pascal

	String Gadget-making routines. Ooooh! Please don't get ticked
	at my evasion of any explanation. See one of my demos

}

{$I "Include:CEUtils/IntuiStuff.i"}

Function MString (Initial: String; MaxCh,DispCh,X,Y: Short) : GadgetPtr;
	External;
Function MInt ( Initial: String; LI: Integer;
		MaxCh,DispCh,X,Y: Short) : GadgetPtr;
	External;
Procedure SetIntVal (T : GadgetPtr; W : WindowPtr; Vl : Integer);
	External;
Procedure SetStrGad (T : GadgetPtr; W : WindowPtr; K : String);
	External;

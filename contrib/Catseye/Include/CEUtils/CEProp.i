{

	CEProp.i	Cat'sEye's Proportional Gadgets for PCQ Pascal

	Prop Gadget-making routines. Ooooh! Please don't get ticked
	at my evasion of any explanation. See one of my demos

}

{$I "Include:CEUtils/IntuiStuff.i"}

Function MProp (x1,y1,wid,hite: Short; Align: PropType; Sc, Pos : Short)
			: GadgetPtr;
	External;
Procedure BorderProps (var Rig, Bot: GadgetPtr);
	External;
Function CurPropPos (T : GadgetPtr; Sc : Integer; Way : PropType) : Integer;
	External;
Procedure SetPropPos (T : GadgetPtr; W : WindowPtr; Sc, Pos : Integer;
	Way : PropType);
	External;

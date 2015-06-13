{

	CEGadgets.i	Cat'sEye's Gadgets for PCQ Pascal

	Gadget-making routines. Ooooh! Please don't get ticked
	at my evasion of any explanation. See one of my demos

}

{$I "Include:CEUtils/IntuiStuff.i"}

Function MBoolean (Txt: String; x1,y1,wid,hite: Short;
			Tech :BordType; Arrw : DirType) : GadgetPtr;
	External;
Function DBoolean (Txt: String; x1,y1: Short; Old: GadgetPtr)
			: GadgetPtr;
	External;
Procedure CompGadget (R : RastPortPtr; B : GadgetPtr);
	External;
Procedure EraseGadget (R : RastPortPtr; B : GadgetPtr);
	External;
Procedure FreeGadget (Gg : GadgetPtr);
	External;

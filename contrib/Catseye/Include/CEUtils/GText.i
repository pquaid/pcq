{

	GText.i for PCQ Pascal

	Cat'sEye

	Just some functions/procedures to make GText a bit more
	interesting...
}

{$I "Include:Graphics/Text.i"}

Function StrToReal (s : String) : Real;
	External;

Procedure RealToString (rr : Real; var s : String);
	External;

Procedure GTextLn (Rp : RastPortPtr; L : String);

	{ Now it WOULD be handy if I could pass any number of
	  parameters after the rp and they could be handled
	  by their type handler, see the two below... }

	External;

Procedure GTextInt (Rp : RastPortPtr; k : integer);
	External;

Procedure GTextReal (Rp : RastPortPtr; k : real);
	External;

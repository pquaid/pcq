{
	Translator.i for PCQ Pascal

	Translator error return codes
}

Const

    TR_NotUsed		= -1;	{ This is an oft used system rc }
    TR_NoMem		= -2;	{ Can't allocate memory }
    TR_MakeBad		= -4;	{ Error in MakeLibrary call }

Var
    TranslatorBase : Address;


Function Translate(InString : String; InLen : Integer;
			OutBuf : String; OutLen : Integer) : Integer;
    External;


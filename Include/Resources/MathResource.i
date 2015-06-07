{
	MathResource.i for PCQ Pascal
}

{$I "Include:Exec/Nodes.i"}

{
*	The 'Init' entries are only used if the corresponding
*	bit is set in the Flags field.
*
*	So if you are just a 68881, you do not need the Init stuff
*	just make sure you have cleared the Flags field.
*
*	This should allow us to add Extended Precision later.
*
*	For Init users, if you need to be called whenever a task
*	opens this library for use, you need to change the appropriate
*	entries in MathIEEELibrary.
}

Type

    MathIEEEResource = record
	MathIEEEResource_Node	: Node;
	MathIEEEResource_Flags	: Short;
	MathIEEEResource_BaseAddr : Address;	{ ptr to 881 if exists }
	MathIEEEResource_DblBasInit : Address;
	MathIEEEResource_DblTransInit : Address;
	MathIEEEResource_SglBasInit : Address;
	MathIEEEResource_SglTransInit : Address;
	MathIEEEResource_ExtBasInit : Address;
	MathIEEEResource_ExtTransInit : Address;
    end;
    MathIEEEResourcePtr = ^MathIEEEResource;

Const

{ definations for MathIEEEResource_FLAGS }

    MATHIEEERESOURCEF_DBLBAS	= 1;
    MATHIEEERESOURCEF_DBLTRANS	= 2;
    MATHIEEERESOURCEF_SGLBAS	= 4;
    MATHIEEERESOURCEF_SGLTRANS	= 8;
    MATHIEEERESOURCEF_EXTBAS	= 16;
    MATHIEEERESOURCEF_EXTTRANS	= 32;

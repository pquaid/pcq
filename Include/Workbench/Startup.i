{
	Startup.i for PCQ Pascal
}

{$I "Include:Exec/Ports.i"}
{$I "Include:Libraries/DOS.i"}

Type

    WBArg = record
	wa_Lock		: BPTR;		{ a lock descriptor }
	wa_Name		: String;	{ a string relative to that lock }
    end;
    WBArgPtr = ^WBArg;

    WBArgList = Array [1..100] of WBArg; { Only 1..smNumArgs are valid }
    WBArgListPtr = ^WBArgList;

    WBStartup = record
	sm_Message	: Message;	{ a standard message structure }
	sm_Process	: MsgPortPtr;	{ the process descriptor for you }
	sm_Segment	: BPTR;		{ a descriptor for your code }
	sm_NumArgs	: Integer;	{ the number of elements in ArgList }
	sm_ToolWindow	: String;	{ description of window }
	sm_ArgList	: WBArgListPtr;	{ the arguments themselves }
    end;
    WBStartupPtr = ^WBStartup;



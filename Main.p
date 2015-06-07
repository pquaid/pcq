Program PCQ_Pascal;

{
	PCQ Pascal Compiler
	Copyright (c) 1989 Patrick Quaid.

	This is the main file of the compiler.  When this file is
compiled, it allocates BSS for all the global variables.
}

{$O-}
{$I "Pascal.i"}
{$I "Include/Utils/StringLib.i"}
{$I "Include/Utils/Parameters.i"}

	{ The following routines are all exported by the other
	  compiler files. }

	Procedure Error(s : string);
	    external;
	Function CheckID(s : string): IDPtr;
	    external;

	Function EnterStandard(	st_Name : String;
				st_Object : IDObject;
				st_Type : TypePtr;
				st_Storage : IDStorage;
				st_Offset : Integer) : IDPtr;
	    external;

	Procedure NextSymbol;
	    external;
	Function Match(s : Symbols): Boolean;
	    external;
	Procedure DeclType;
	    external;
	Procedure DeclConst;
	    external;
	Procedure DeclLabel;
	    External;
	Function DeclArgs(ob : IDObject) : IDPtr;
	    external;
	Procedure ns;
	    external;
	Procedure EnterID(CB : BlockPtr; ID : IDPtr);
	    external;
	Procedure ReformArgs(ID : IDPtr);
	    external;
	Function ReadType(): TypePtr;
	    external;
	Function EndOfFile(): boolean;
	    external;
	Function OpenInputFile(n : String) : Boolean;
	    external;
	Procedure CloseInputFile;
	    external;
	Procedure VarDeclarations;
	    external;
	Procedure InitReserved;
	    external;
	Procedure InitGlobals;
	    external;
	Function GetLabel() : Integer;
	    External;
	Procedure DumpIds;
	    external;
	Procedure DumpRefs;
	    external;
	Procedure DumpLits;
	    external;
	Procedure Trailer;
	    external;
	Procedure Compound;
	    external;
	Procedure Header;
	    external;
	Procedure InitStandard;
	    external;
	Procedure ReadChar;
	    external;
	Procedure NeedRightParent;			{ Utilities.p }
	    external;
	Function SimpleType(T : TypePtr): Boolean;	{ Utilities.p }
	    external;
	Procedure NewBlock;				{ Utilities.p }
	    external;
	Procedure KillBlock;				{ Utilities.p }
	    external;
	Procedure KillIDList(ID : IDPtr);		{ Utilities.p }
	    external;
	Procedure Decompose;				{ Utilities.p }
	    external;
	Function CompareProcs(Proc1, Proc2 : IDPtr) : Boolean;	{ Utilities.p }
	    external;
	Procedure BackUpSpell(Position : Integer);
	    external;

Procedure Banner;
begin
    writeln('PCQ Compiler 1.1d  (May 6, 1990)');
    writeln('Copyright ', chr(169),
		' 1989 Patrick Quaid.  All rights reserved.');
end;

Procedure GetFileNames;
var
    Parm : String;
    ParmNum : Short;

    Procedure Die(LastWords : string);
    begin
	Banner;
	Writeln(LastWords);
	Exit(20);
    end;

    Procedure DoOption;
    begin
	if toupper(Parm[1]) = 'Q' then
	    Inform := False
{	else if toupper(Parm[1]) = 'O' then
	    Do_Offsets := True }
	else
	    Die("Unknown Directive");
    end;

begin
    Parm := AllocString(256);
    MainName := Nil;
    OutName := Nil;
    ParmNum := 1;
    repeat
	GetParam(ParmNum, Parm);
	if Parm^ = Chr(0) then begin
	    if MainName = Nil then
		Die("No Input File Name");
	    if OutName = Nil then
		Die("Missing Output File Name");
	end else begin
	    if Parm^ = '-' then
		DoOption
	    else if MainName = Nil then
		MainName := strdup(Parm)
	    else if OutName = Nil then
		OutName := strdup(Parm)
	    else
		Die("Unknown Command");
	end;
	Inc(ParmNum);
    until Parm^ = Chr(0);
    FreeString(Parm);
end;

Procedure OpenFiles;
begin
    InFile := nil;
    if not OpenInputFile(MainName) then begin
	Writeln('Could not open ', MainName);
        Exit(20);
    end;
    if not open(OutName, OutFile, 2048) then begin
	Writeln('Could not open ', OutName);
	Exit(20);
    end;
end;

Procedure DoBlock(isfunction : boolean);


{
	This is the main routine for handling program, procedure
and function blocks.  It handles the various declaration blocks and
the procedure and function parameters.  This is one of the many
routines which should, and will, be broken into more manageable
parts.
}

var
    ID		: IDPtr;
    DupID	: IDPtr;
    savefn	: IDPtr;
    ForwardID   : IDRec;
    Forwarded	: Boolean;
    FirstVar	: IDPtr;
    SaveStack	: Integer;
    SaveSpell	: Integer;
begin
    fnstart := lineno;
    Forwarded := False;
    FirstVar := Nil;
    if CurrentBlock^.Level > 0 then begin
	if currsym <> ident1 then begin
	    error("Missing function or procedure name!");
	    return;
	end;
	CurrFn := CheckID(symtext);
	if CurrFn <> Nil then begin
	    if CurrFn^.Storage <> st_forward then
		error("Duplicate ID")
	    else begin
		ForwardID := CurrFn^;
		Forwarded := True;
		CurrFn^.Param := Nil;
	    end;
	end else begin
	    case isfunction of
		True : CurrFn := EnterStandard(symtext, func, Nil, st_none, 0);
		False: CurrFn := EnterStandard(symtext, proc, Nil, st_none, 0);
	    end;
	    CurrFn^.Unique := GetLabel();
	end;
	nextsymbol;
	SaveSpell := SpellPtr;

	if Match(leftparent1) then begin
	    CurrFn^.Param := DeclArgs(valarg); { Dummy param here }
	    ReformArgs(CurrFn); { Set offsets of args, plus totalsize }
	    NeedRightParent;
	end else
	    CurrFn^.Param := Nil;

	if isfunction then begin
	    if not match(colon1) then
		error("expecting :");
	    CurrFn^.VType := readtype();
	    if not simpletype(CurrFn^.VType) then begin
		error("expecting a simple type");
		CurrFn^.VType := BadType;
	    end;
	end;
	ns;
    end;

    if match(forward1) then begin
	if Forwarded then
	    Error("Already declared");
	CurrFn^.Storage := st_forward;
	ns;
    end else if Match(extern1) then begin
	CurrFn^.Storage := st_external;
	ns;
    end else begin
	if Forwarded then begin
	    if not CompareProcs(Adr(ForwardID), CurrFn) then
		Error("Definitions do not match");
	    KillIDList(ForwardID.Param);
	end;
	NewBlock;
	if CurrentBlock^.Level > 1 then begin
	    CurrFn^.Storage := st_internal;
	    ID := CurrFn^.Param;
	    while ID <> nil do begin
		New(DupID);
		DupID^ := ID^;
		ID^.Name := Nil;
		EnterID(CurrentBlock, DupID);
		ID := ID^.Next;
	    end;
	end;

	StackSpace := 0;

	while currsym <> begin1 do begin
	    if endoffile() then begin
		if mainmode or (CurrentBlock^.Level > 1) then
		    error("There was no code section!");
		return;
	    end else if match(var1) then
		VarDeclarations
	    else if match(type1) then
		DeclType
	    else if match(const1) then
		DeclConst
	    else if match(proc1) then begin
		savefn := currfn;
		SaveStack := StackSpace;
		doblock(false);
		StackSpace := SaveStack;
		currfn := savefn;
	    end else if match(func1) then begin
		savefn := currfn;
		SaveStack := StackSpace;
		doblock(true);
		StackSpace := SaveStack;
		currfn := savefn;
	    end else if match(label1) then
		DeclLabel
	    else begin
		error("expecting block identifier");
		nextsymbol;
	    end;
	end;

	if CurrentBlock^.Level > 1 then begin
	    if odd(StackSpace) then
		StackSpace := Succ(StackSpace);
	    CurrFn^.Offset := StackSpace;
	end;

	if (not mainmode) and (CurrentBlock^.Level = 1) then begin
	    error("Expected a procedure or function header");
	    return;
	end;
	case CurrentBlock^.Level of
	  1 : if MainMode then begin
		  writeln(OutFile, '_MAIN');
	      end;
	  2 : begin
		  if StandardStorage <> st_private then
		      writeln(OutFile, "\n\tXDEF\t_", CurrFn^.Name);
		  writeln(OutFile, '_', CurrFn^.Name, "\tlink\ta5,#",
				-CurrFn^.Offset);
	      end;
	else
	    Writeln(OutFile, '_', CurrFn^.Name, '%', CurrFn^.Unique,
				"\tlink\ta5,#", -CurrFn^.Offset);
	end;
	NextSymbol;

	Compound;

	if CurrentBlock^.Level > 1 then begin
	    ns;
	    writeln(OutFile, "\tunlk\ta5");
	    KillBlock;
	    BackUpSpell(SaveSpell);
	end;
	writeln(OutFile, "\trts");
    end;
end;


Procedure Parse;

{
	This is the outermost parsing routine.  It uses doblock()
mainly, and will eventually be able to handle program parameters.
}

begin
    if Match(program1) then begin
	mainmode:= true;
	StandardStorage := st_internal;
	if currsym = ident1 then
	    NextSymbol { Eat program name }
	else
	    error("Missing program name.");
	if Match(LeftParent1) then begin
	    while CurrSym = Ident1 do begin
		NextSymbol;
		if CurrSym <> RightParent1 then
		    if not Match(Comma1) then
			Error("Expecting a comma");
	    end;
	    NeedRightParent;
	end;
	ns;
    end else if match(extern1) then begin
	mainmode := false;
	StandardStorage := st_external;
	ns;
    end else begin
	error("First symbol must be PROGRAM or EXTERNAL.");
	StandardStorage := st_internal;
	MainMode:= false;
    end;
    Header;
    DoBlock(false);
    if MainMode then
	if not Match(period1) then
	    Error("Program must end with a period.");
    if (not EndOfFile) and (MainMode) then
	Error("There should be nothing after the main procedure.");
end;

begin

{
	This is the big one, the main routine, which by itself does
very little.  Read parse() and doblock() to get a much better idea
of how things work.
}

    initglobals;	{ initialize everything }
    initreserved;
    initstandard;

    GetFileNames;
    if Inform then
	Banner;
    OpenFiles;

    nextsymbol;

    parse; 	{ do everything }

    if Inform then begin
	if errorcount = 0 then
	    writeln('There were no errors.')
	else if errorcount = 1 then
	    writeln('There was one error')
	else
	    writeln('There were ', errorcount, ' errors.');
    end;

    DumpRefs;
    DumpLits;
    DumpIds;		{ write IDs and literals to assem file }
    trailer;		{ write 'END' }
    while InFile <> nil do
	CloseInputFile;	{ be sure to close the main file }

{    if Do_Offsets then
	Decompose;	 Write offset information }

    if errorcount <> 0 then
	exit(10);	{ make sure there's an error if necessary }
end.

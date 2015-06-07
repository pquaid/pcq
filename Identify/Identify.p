Program Identify;

{
	Identify

	This program just writes out useful information about all
sorts of things it knows.  It's based on the compiler, obviously,
but doesn't do any code generation.
}

{$O-}
{$I "Identify.i"}
{$I "Include:Utils/StringLib.i"}
{$I "Include:Utils/Parameters.i"}

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
	Procedure ReportID;
	    External;
	Function CompareProcs(Proc1, Proc2 : IDPtr) : Boolean;	{ Utilities.p }
	    external;
	Procedure BackUpSpell(Position : Integer);
	    external;

Procedure Banner;
begin
    writeln('Identify');
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
	if toupper(Parm[1]) = 'O' then
	    Do_Offsets := True
	else if toupper(Parm[1]) = 'R' then
	    Report_IDS := True
	else
	    Die("Unknown Directive");
    end;

begin
    Parm := AllocString(256);
    MainName := Nil;
    ParmNum := 1;
    repeat
	GetParam(ParmNum, Parm);
	if Parm^ = Chr(0) then begin
	    if MainName = Nil then
		Die("No Input File Name");
	end else begin
	    if Parm^ = '-' then
		DoOption
	    else if MainName = Nil then
		MainName := strdup(Parm)
	    else
		Die("Unknown Command");
	end;
	Inc(ParmNum);
    until Parm^ = Chr(0);
    FreeString(Parm);
    if not (Do_Offsets or Report_IDS) then
	Die("No options specified");
end;

Procedure OpenFiles;
begin
    InFile := nil;
    if not OpenInputFile(MainName) then begin
	Writeln('Could not open ', MainName);
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
	NextSymbol;
	if not match(end1) then
	    Error("Identify can only handle declarations.");

	if CurrentBlock^.Level > 1 then begin
	    ns;
	    KillBlock;
	    BackUpSpell(SaveSpell);
	end;
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
    Banner;
    OpenFiles;

    if (InFile = Nil) or EOF(InFile^.PCQFile) then begin
	Writeln('The infile is already at eof');
	Exit(10);
    end;

    nextsymbol;

    parse; 	{ do everything }

    while InFile <> nil do
	CloseInputFile;	{ be sure to close the main file }

    if Do_Offsets then
	Decompose;	 { Write offset information }
    if Report_IDS then
	ReportID;

    if errorcount <> 0 then
	exit(10);	{ make sure there's an error if necessary }
end.

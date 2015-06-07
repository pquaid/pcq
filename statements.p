External;

{
	Statements.p (of PCQ Pascal)
	Copyright (c) 1989 Patrick Quaid

	This module handles normal statements, including the
	standard statements like if, while, case, etc.
}

{$O-}
{$I "Pascal.i"}

	Function Match(s : Symbols) : Boolean;
	    external;
	Function Expression() : TypePtr;
	    external;
	Procedure Error(s : string);
	    external;
	Function TypeCheck(t1, t2 : TypePtr): Boolean;
	    external;
	Procedure SaveStack(t : TypePtr);
	    external;
	Procedure SaveVal(v : IDPtr);
	    external;
	Procedure ns;
	    external;
	Procedure NextSymbol;
	    external;
	Function GetLabel(): Integer;
	    external;
	Procedure PrintLabel(l : integer);
	    external;
	Function Suffix(s : Integer) : Char;
	    external;
	Procedure Mismatch;
	    external;
	Function LoadAddress() : TypePtr;
	    external;
	Procedure CallProc(ProcID : IDPtr);
	    external;
	procedure StdProc(ID : IDPtr);
	    external;
	Function EndOfFile() : Boolean;
	    external;
	Procedure ReadChar;
	    external;
	Function FindID(s : string): IDPtr;
	    external;
	Function IsVariable(i : IDPtr) : Boolean;
	    external;
	Function ConExpr(var t : TypePtr) : integer;
	    external;
	function BaseType(t : TypePtr) : TypePtr;
	    external;
	Procedure PromoteType(var f : TypePtr; o : TypePtr; r : Short);
	    external;
	Function NumberType(t : TypePtr): Boolean;
	    external;
	Procedure PushLongD0;
	    external;
	Procedure PushLongA0;
	    External;
	Procedure PopStackSpace(amount : Integer);
	    External;
	Function Selector(ID : IDPtr) : TypePtr;
	    external;
	Function FindWithField(s : String) : IDPtr;
	    External;
	Function CheckBreak : Boolean;
	    External;
	Procedure Abort;
	    External;

Procedure Statement;
    forward;

Procedure Assignment(ID : IDPtr);

{
	Not surprisingly, this routine handles assignments.
}

var
    StackedType,
    VarType,
    ExprType : TypePtr;

begin
    NextSymbol;
    StackedType := Selector(ID);
    if StackedType <> Nil then begin
	PushLongA0;
	VarType := StackedType;
    end else
	VarType := ID^.VType;
    if not match(becomes1) then
	error("expecting :=");
    ExprType := Expression();
    if TypeCheck(VarType, ExprType) then begin
	PromoteType(ExprType, VarType, 0);
	if StackedType <> Nil then
	    SaveStack(VarType)
	else
	    SaveVal(ID);
    end else
	Mismatch;
end;

Procedure ReturnVal;

{
	This is similar to the above, but the value is left in d0.
}

var
    ExprType	: TypePtr;
begin
    nextsymbol;
    if not Match(becomes1) then
	error("expecting :=");
    ExprType := Expression();
    if not TypeCheck(CurrFn^.VType, ExprType) then
	Mismatch;
    if NumberType(ExprType) then
	PromoteType(ExprType, CurrFn^.VType, 0);
    writeln(OutFile, "\tunlk\ta5");
    writeln(OutFile, "\trts");
end;

Procedure DoWhile;

{
	Handles the while statement.
}

var
    LoopLabel,
    ExitLabel	: Integer;
begin
    LoopLabel := GetLabel();
    ExitLabel := GetLabel();
    PrintLabel(LoopLabel);
    writeln(OutFile);
    if not TypeCheck(Expression(), BoolType) then
	error("Expecting boolean expression");
    writeln(OutFile, "\ttst.b\td0");
    write(OutFile, "\tbeq\t");
    PrintLabel(ExitLabel);
    writeln(OutFile);
    if not Match(Do1) then
	error("Missing DO");
    Statement;
    write(OutFile, "\tbra\t");
    PrintLabel(LoopLabel);
    writeln(OutFile);
    PrintLabel(ExitLabel);
    writeln(OutFile);
end;

Procedure DoRepeat;

{
	Handles the repeat statement.
}

var
    RepLabel	: Integer;
begin
    RepLabel := GetLabel();
    PrintLabel(RepLabel);
    writeln(OutFile);
    while not Match(until1) do begin
	Statement;
	ns;
    end;
    if not TypeCheck(Expression(), Booltype) then
	error("Expecting a Boolean expression.");
    writeln(OutFile, "\ttst.b\td0");
    write(OutFile, "\tbeq\t");
    PrintLabel(RepLabel);
    writeln(OutFile);
end;

Procedure SaveFor(VarType : TypePtr; off : integer);

{
	This routine saves the new value of the index variable for
for statements.
}

begin
    write(OutFile, "\tmove.l\t");
    if off <> 0 then
	write(OutFile, off);
    writeln(OutFile, '(sp),a0');
    writeln(OutFile, "\tmove.", Suffix(VarType^.Size), "\td0,(a0)");
end;

Procedure IncFor(VarType : TypePtr; Value : Integer);

{
	This routine adjusts the index for increments of 1 or -1.
}

begin
    writeln(OutFile, "\tmove.l\t4(sp),a0");
    writeln(OutFile, "\tadd.", Suffix(VarType^.Size), "\t#", Value,',(a0)');
    writeln(OutFile, "\tmove.", Suffix(VarType^.Size), "\t(a0),d0");
end;

Procedure StackInc(VarType : TypePtr);

{
	This handles non-standard increments.
}

begin
    writeln(OutFile, "\tmove.l\t8(sp),a0");
    writeln(OutFile, "\tmove.l\t(sp),d0");
    writeln(OutFile, "\tadd.", Suffix(VarType^.Size), "\td0,(a0)");
    writeln(OutFile, "\tmove.", suffix(VarType^.Size), "\t(a0),d0");
end;

Procedure DoFor;

{
	handles the for statement.
}

var
    looplabel	: integer;
    varindex	: integer;
    ByType,
    VarType,
    BoundType	: TypePtr;
    increment	: Short;
    default	: Boolean;
begin
    VarType := LoadAddress();
    if VarType^.Object <> ob_ordinal then
	error("expecting an ordinal type");
    PushLongA0;
    if not Match(becomes1) then
	error("missing :=");
    BoundType := Expression();
    if not TypeCheck(VarType, BoundType) then
	Mismatch;
    PromoteType(BoundType, VarType, 0);
    SaveFor(VarType, 0);
    if Match(to1) then
	increment := 1
    else if Match(downto1) then
	increment := -1
    else
	error("Expecting TO or DOWNTO");
    BoundType := Expression();
    if not TypeCheck(BoundType, VarType) then
	Mismatch;
    PromoteType(BoundType, VarType, 0);
    PushLongD0;

    if Match(by1) then begin
	default := false;
	ByType := Expression();
	if not TypeCheck(ByType, VarType) then
	    Mismatch;
	PromoteType(ByType, VarType, 0);
	PushLongD0;
    end else
	default := true;

    if not Match(do1) then
	error("missing DO");
    looplabel := GetLabel();
    PrintLabel(looplabel);
    writeln(OutFile);
    Statement;
    if default then begin
	IncFor(VarType, increment);
	writeln(OutFile, "\tmove.l\t(sp),d1");
    end else begin
	StackInc(VarType);
	writeln(OutFile, "\tmove.l\t4(sp),d1");
    end;
    writeln(OutFile, "\tcmp.", Suffix(VarType^.Size), "\td1,d0");
    if increment > 0 then
	write(OutFile, "\tble\t")
    else
	write(OutFile, "\tbge\t");
    PrintLabel(LoopLabel);
    writeln(OutFile);
    if default then
	PopStackSpace(8)
    else
	PopStackSpace(12);
end;

Procedure DoReturn;

{
	This just takes care of return.
}

begin
    if CurrFn <> Nil then begin
	if CurrFn^.Object = proc then begin
	    writeln(OutFile, "\tunlk\ta5");
	    writeln(OutFile, "\trts");
	end else
	    error("return only allowed in procedures.");
    end else
	error("No return from the main procedure");
end;

Procedure Compound;

{
	This takes care of the begin...end syntax.
}

begin
    while not Match(end1) do begin
	Statement;
	if (CurrSym = Else1) or (CurrSym = Until1) then begin
	    Error("Expecting a statement");
	    NextSymbol;
	end;
	if CurrSym <> End1 then
	    ns;
    end;
end;

procedure DoIf;

{
	This handles the if statement.  Eventually it should handle
elsif.
}

var
    flab1, flab2	: integer;
begin
    flab1 := GetLabel();
    if not TypeCheck(Expression(), BoolType) then
	error("Expecting a Boolean type");
    writeln(OutFile, "\ttst.b\td0");
    write(OutFile, "\tbeq\t");
    PrintLabel(flab1);
    writeln(OutFile);
    if not Match(then1) then
	error("Missing THEN");
    Statement;
    if Match(else1) then begin
	flab2 := getlabel();
	write(OutFile, "\tbra\t");
	PrintLabel(flab2);
	writeln(OutFile);
	PrintLabel(flab1);
	writeln(OutFile);
	Statement;
	PrintLabel(flab2);
	writeln(OutFile);
    end else begin
	PrintLabel(flab1);
	writeln(OutFile);
    end;
end;

procedure DoCase;

    procedure DoRange(first, second, lab, typesize : Integer);
    var
	otherlabel : Integer;
    begin
	otherlabel := GetLabel();
	writeln(OutFile, "\tcmp.", Suffix(typesize), "\t#", first, ',d0');
	write(OutFile, "\tblt\t");
	printlabel(otherlabel);
	writeln(OutFile, "\n\tcmp.", Suffix(typesize), "\t#", second, ',d0');
	write(OutFile, "\tble\t");
	printlabel(lab);
	writeln(OutFile);
	printlabel(otherlabel);
	writeln(OutFile);
    end;

    procedure DoSingle(number, lab, typesize : Integer);
    begin
	writeln(OutFile, "\tcmp.", Suffix(TypeSize), "\t#", number, ',d0');
	write(OutFile, "\tbeq\t");
	PrintLabel(lab);
	writeln(OutFile);
    end;

    Procedure DoCases(ctype : TypePtr; codelabel : Integer);
    var
	firstnumber, secondnumber : Integer;
	contype : TypePtr;
    begin
	while not match(colon1) do begin
	    firstnumber := ConExpr(ConType);
	    if not TypeCheck(ConType, ctype) then
		Mismatch;
	    if Match(dotdot1) then begin
		secondnumber := conexpr(contype);
		if not typecheck(ctype, contype) then
		    mismatch;
		dorange(firstnumber, secondnumber, codelabel,ctype^.Size);
	    end else
		dosingle(firstnumber, codelabel, ctype^.size);
	    if currsym <> colon1 then
		if not match(comma1) then
		    error("Expecting : or ,");
	end;
    end;

var
    casetype : TypePtr;
    outofcases, nextsetlabel, codelabel : Integer;
begin
    CaseType := Expression();
    if CaseType^.Object <> ob_ordinal then
	error("Expecting an ordinal type");
    if not match(of1) then
	error("Missing 'of'");
    outofcases := GetLabel();
    while (currsym <> end1) and (currsym <> else1) and (not endoffile()) do begin
	NextSetLabel := GetLabel();
	CodeLabel := GetLabel();
	DoCases(CaseType, CodeLabel);
	write(OutFile, "\tbra\t");
	PrintLabel(NextSetLabel);
	writeln(OutFile);
	PrintLabel(CodeLabel);
	writeln(OutFile);
	Statement;
	if (CurrSym <> Else1) and (CurrSym <> End1) then
	    ns;
	write(OutFile, "\tbra\t");
	PrintLabel(OutOfCases);
	writeln(OutFile);
	PrintLabel(NextSetLabel);
	writeln(OutFile);
    end;
    if Match(else1) then
	if CurrSym <> end1 then begin
	    Statement;
	    ns;
	end;
    if not Match(end1) then
	Error("Expecting 'end'");
    PrintLabel(outofcases);
    writeln(OutFile);
end;

Procedure DoWith;
var
    TempRec,
    FirstRec : WithRecPtr;
    Stay    : Boolean;
begin
    FirstRec := Nil;
    repeat
	New(TempRec);
	if FirstRec = Nil then
	    FirstRec := TempRec;
	TempRec^.Previous := FirstWith;
	TempRec^.RecType := LoadAddress;
	FirstWith := TempRec;
	if FirstWith^.RecType^.Object <> ob_record then
	    Error("Expecting a record type");
	PushLongA0;
	FirstWith^.Offset := StackLoad;
	Stay := Match(Comma1);
    until not Stay;
    if not Match(Do1) then
	Error("Missing DO");
    Statement;
    repeat
	Stay := FirstWith <> FirstRec;
	TempRec := FirstWith^.Previous;
	Dispose(FirstWith);
	FirstWith := TempRec;
	PopStackSpace(4);
    until not Stay;
end;

Procedure DoGoto;
var
    ID : IDPtr;
begin
    if CurrSym = Ident1 then begin
	ID := FindID(SymText);
	if ID <> Nil then begin
	    if ID^.Object = lab then begin
		if ID^.Level = CurrentBlock^.Level then begin
		    Write(OutFile, '\tbra\t');
		    PrintLabel(ID^.Unique);
		    Writeln(OutFile);
		    NextSymbol;
		end else
		    Error("You cannot jump out of scopes");
	    end else
		Error("Expecting a label");
	end else
	    Error("Unknown ID");
    end else
	Error("Expecting a comment");
end;

Procedure Statement;

{
	This is the main routine for handling statements of all
sorts.  It distributes the work as necessary.
}

var
    VarIndex	: IDPtr;
begin
    if EndOfFile() then
	return;
    VarIndex := Nil;
    if CurrSym = Ident1 then begin { Handle label prefix }
	VarIndex := FindWithField(SymText);
	if VarIndex = Nil then
	    VarIndex := FindID(SymText);
	if VarIndex <> Nil then begin
	    if VarIndex^.Object = lab then begin
		PrintLabel(VarIndex^.Unique);
		Writeln(OutFile);
		NextSymbol;
		if not Match(Colon1) then
		    Error("Missing colon");
		VarIndex := Nil;
	    end;
	end else
	    Error("Unknown ID");
    end;
    if CurrSym = Ident1 then begin
	if VarIndex = Nil then begin { if not Nil, we found it above }
	    VarIndex := FindWithField(SymText);
	    if VarIndex = Nil then
		VarIndex := FindID(symtext);
	end;
	if varindex = nil then begin
	    error("unknown ID");
	    while (currsym <> semicolon1) and
		  (currsym <> end1) and
		  (currentchar <> chr(10)) do
		nextsymbol;
	end else if (varindex = currfn) and (currfn^.Object = func) then
	    returnval
	else if IsVariable(VarIndex) then
	    assignment(varindex)
	else if VarIndex^.Object = proc then
	    callproc(varindex)
	else if VarIndex^.Object = stanproc then
	    stdproc(varindex)
	else begin
	    error("expecting a variable or procedure.");
	    while (currsym <> semicolon1) and
		  (currsym <> end1) and
		  (currentchar <> chr(10)) do
		nextsymbol;
	    if currsym = semicolon1 then
		nextsymbol;
	end;
    end else if match(begin1) then begin
	Compound;
    end else if match(if1) then begin
	DoIf;
    end else if match(while1) then begin
	DoWhile;
    end else if match(repeat1) then begin
	DoRepeat;
    end else if match(for1) then begin
	DoFor;
    end else if match(case1) then begin
	DoCase;
    end else if match(return1) then begin
	DoReturn;
    end else if Match(With1) then begin
	DoWith;
    end else if Match(Goto1) then begin
	DoGoto;
    end else if (CurrSym <> SemiColon1) and (CurrSym <> End1) and
		(CurrSym <> Else1) and (CurrSym <> Until1) then begin
	Error("Expecting a statement");
	while (CurrSym <> SemiColon1) and
	      (CurrSym <> End1) and
	      (CurrSym <> Else1) and
	      (CurrSym <> Until1) and
	      (currentchar <> chr(10)) do
	    NextSymbol;
    end else
	if CheckBreak then
	    Abort;
end;

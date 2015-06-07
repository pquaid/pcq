External;

{
	Calls.p (of PCQ Pascal)
	Copyright (c) 1989 Patrick Quaid

	Calls.p is the first attempt to organize the various
addressing and code generating routines in one section.  If you
read the other sections you'll find that not much effort went into
this project.  Nonetheless, a couple of common addressing things
can be found here.
	If the compiler were designed so that all the addressing
things were here, it would be much easier to port to a different
processor.
}

{$O-}
{$I "Pascal.i"}

	Function Match(s : Symbols) : Boolean;
	    external;
	Procedure Error(s : string);
	    external;
	Function FindField(s : string; TP : TypePtr): IDPtr;
	    external;
	Function FindWithField(S : String) : IDPtr;
	    External;
	Procedure NextSymbol;
	    external;
	Function Expression() : TypePtr;
	    external;
	Function TypeCheck(t1, t2 : TypePtr): Boolean;
	    external;
	Function TypeCmp(t1, t2 : TypePtr) : Boolean;
	    external;
	Function FindID(s : string) : IDPtr;
	    external;
	Function IsVariable(i : IDPtr) : Boolean;
	    external;
	Function GetLabel() : Integer;
	    external;
	Procedure PrintLabel(l : Integer);
	    external;
	Procedure ns;
	    external;
	Function Suffix(s : Integer): Char;
	    external;
	Procedure Mismatch;
	    external;
	Function SimpleType(t : TypePtr): Boolean;
	    external;
	Function NumberType(t : TypePtr): Boolean;
	    external;
	Procedure PromoteType(var f : TypePtr; o : TypePtr; r : Short);
	    external;

Procedure PushLongD0;
begin
    writeln(OutFile, "\tmove.l\td0,-(sp)");
    StackLoad := StackLoad + 4;
end;

Procedure PopLongD0;
begin
    Writeln(OutFile, '\tmove.l\t(sp)+,d0');
    StackLoad := StackLoad - 4;
end;

Procedure PopStackSpace(amount : Integer);
begin
    Writeln(OutFile, '\tadd.l\t#', amount, ',sp');
    StackLoad := StackLoad - amount;
end;

Procedure PushWordD0;
begin
    writeln(OutFile, "\tmove.w\td0,-(sp)");
    StackLoad := StackLoad + 2;
end;

Procedure PushLongD1;
begin
    Writeln(OutFile, '\tmove.l\td1,-(sp)');
    StackLoad := StackLoad + 4;
end;

Procedure PopLongD1;
begin
    writeln(OutFile, "\tmove.l\t(sp)+,d1");
    StackLoad := StackLoad - 4;
end;

Procedure PushLongA0;
begin
    writeln(OutFile, '\tmove.l\ta0,-(sp)');
    StackLoad := StackLoad + 4;
end;

Procedure PopLongA0;
begin
    writeln(OutFile, '\tmove.l\t(sp)+,a0');
    StackLoad := StackLoad - 4;
end;

Procedure PopLongA1;
begin
    writeln(OutFile, '\tmove.l\t(sp)+,a1');
    StackSpace := StackSpace - 4;
end;

Procedure DoRangeCheck(VarType : TypePtr);

{
	This routine is called from selector() when range checking
is turned on.  Notice that the code is now in a library, rather
than inline as it was in 1.0.  Also note that the library code fixes
the stack after the call.
}

begin
    Writeln(OutFile, '\tpea\t', VarType^.Lower);
    Writeln(OutFile, '\tpea\t', VarType^.Upper);
    Writeln(OutFile, '\tjsr\t_p%CheckRange');
end;

Function GetFramePointer(Reference : Integer) : Short;
var
    Current : Integer;
begin
    Current := CurrentBlock^.Level;
    if Current = Reference then
	GetFramePointer := 5
    else begin
	writeln(OutFile, "\tmove.l\t8(a5),a4");
	Current := Pred(Current);
	while Current > Reference do begin
	    Writeln(OutFile, "\tmove.l\t8(a4),a4");
	    Current := Pred(Current);
	end;
	GetFramePointer := 4;
    end;
end;

Procedure GetPointerVal(ID : IDPtr);

{
	This routine puts the value of a pointer variable (or a
reference parameter) into a0.
}
var
    Reg : Short;
begin
    case ID^.Object of
	global : writeln(OutFile, "\tmove.l\t_", ID^.Name, ',a0');
	typed_const :
		 if ID^.Level <= 1 then
		     writeln(OutFile, '\tmove.l\t_', ID^.Name, ',a0')
		 else
		     writeln(OutFile, '\tmove.l\t_',ID^.Name,'%',ID^.Unique, ',a0');
	refarg : begin
		    Reg := GetFramePointer(ID^.Level);
		    writeln(OutFile, "\tmove.l\t", ID^.Offset, '(a', Reg, '),a0');
		    writeln(OutFile, "\tmove.l\t(a0),a0");
		 end;
    else begin
	    Reg := GetFramePointer(ID^.Level);
	    writeln(OutFile, "\tmove.l\t", ID^.Offset, '(a', Reg, '),a0');
	 end;
    end;
end;

Procedure SimpleAddress(ID : IDPtr);

{
	simpleaddress() is passed a idrecord of some sort of
variable, and just loads its address into a0.
}
var
    Reg : Short;
begin
    case ID^.Object of
	global : writeln(OutFile, "\tlea\t_", ID^.Name, ',a0');
	typed_const :
		 if ID^.Level <= 1 then
		     writeln(OutFile, '\tlea\t_', ID^.Name, ',a0')
		 else
		     writeln(OutFile, '\tlea\t_', ID^.Name, '%',
				ID^.Unique, ',a0');
	refarg : begin
		    Reg := GetFramePointer(ID^.Level);
		    writeln(OutFile, "\tmove.l\t", ID^.Offset, '(a', Reg, '),a0');
		 end;
    else begin
	     Reg := GetFramePointer(ID^.Level);
	     writeln(OutFile, "\tlea\t", ID^.Offset, '(a', Reg, '),a0');
	 end;
    end;
end;

Procedure DoMultiply(size : Integer);

    Procedure ShiftLeft(num : Short);
    begin
	Writeln(OutFile, "\tlsl.l\t#", num, ',d0');
    end;

begin
    case size of
	1  : ;
	2  : ShiftLeft(1);
	4  : ShiftLeft(2);
	8  : ShiftLeft(3);
	16 : ShiftLeft(4);
	32 : ShiftLeft(5);
	64 : ShiftLeft(6);
	128: ShiftLeft(7);
	256: ShiftLeft(8);
    else
	writeln(OutFile, "\tmuls\t#", size, ',d0');
    end;
end;

Function Selector(ID : IDPtr) : TypePtr;

{
	This is an overlarge function that handles all the
selectors- in other words ^, ., and [].  It can handle a series of
them, of course.  selector() returns Nil if no selection was
required, and the type if there was some selection.
}

var
    VarType	: TypePtr;
    FieldID	: IDPtr;
    IndexType	: TypePtr;
    Stacked	: Boolean;
    Leave	: Boolean;
    bufsize,
    WithOffset	: Integer;
    Substitute	: TypePtr;
begin
    if ID^.Object = field then begin
	WithOffset := StackLoad - LastWith^.Offset;
	if WithOffset = 0 then
	    Writeln(OutFile, '\tmove.l\t(sp),a0')
	else
	    Writeln(OutFile, '\tmove.l\t', WithOffset, '(sp),a0');
	if ID^.Offset <> 0 then
	    Writeln(OutFile, '\tadda.l\t#', ID^.Offset, ',a0');
	Stacked := True;
    end else
	Stacked := False;
    VarType := ID^.VType;
    while (CurrSym = period1) or (CurrSym = leftbrack1) or
	  (CurrSym = carat1) do begin
	if (not Stacked) and (VarType^.Object <> ob_pointer) then begin
	    SimpleAddress(ID);
	    Stacked := True;
	end;
	if Match(Period1) then begin
	    if VarType^.Object <> ob_record then
		error("not a record type");
	    FieldID := FindField(symtext, VarType);
	    if FieldID = Nil then
		Error("unknown field")
	    else if FieldID^.Offset <> 0 then
		writeln(OutFile, "\tadda.l\t#", FieldID^.Offset, ',a0');
	    NextSymbol;
	    VarType := FieldID^.VType;
	end else if Match(Carat1) then begin
	    if VarType^.Object = ob_file then begin
		BufSize := VarType^.SubType^.Size;
		writeln(OutFile, '\tjsr\t_p%FilePtr');
		if IOCheck then
		    Writeln(OutFile, '\tjsr\t_p%CheckIO');
		VarType := VarType^.SubType;
	    end else if VarType^.Object = ob_pointer then begin
		if not Stacked then begin
		    GetPointerVal(ID);
		    Stacked := True;
		end else
		    writeln(OutFile, "\tmove.l\t(a0),a0");
		VarType := VarType^.SubType;
	    end else
		error("Need a file or pointer for ^");
	end else if Match(LeftBrack1) then begin
	    if VarType^.Object = ob_array then begin
		Leave := False;
		repeat
		    PushLongA0;
		    IndexType := Expression();
		    Substitute := Indextype;
		    PromoteType(Substitute, Inttype, 0);
		    if RangeCheck then
			DoRangeCheck(VarType);
		    if not TypeCheck(IndexType, VarType^.Ref) then
			Mismatch;
		    if VarType^.Lower <> 0 then
			writeln(OutFile, "\tsub.l\t#", VarType^.Lower, ',d0');
		    VarType := VarType^.SubType;
		    DoMultiply(VarType^.Size);
		    PopLongA0;
		    writeln(OutFile, "\tadd.l\td0,a0");
		    if Match(Comma1) then begin
			if VarType^.Object <> ob_array then begin
			    Error("Not a multidimensional array");
			    Leave := True;
			end;
		    end else
			Leave := True;
		until Leave;
		if not Match(RightBrack1) then
		    Error("Expecting ]");
	    end else if TypeCheck(Vartype, StringType) then begin
		if not Stacked then begin
		    GetPointerVal(ID);
		    Stacked := True;
		end else
		    writeln(OutFile, "\tmove.l\t(a0),a0");
		PushLongA0;
		IndexType := Expression();
		if not TypeCheck(IndexType, IntType) then
		    Mismatch
		else
		    PromoteType(IndexType, IntType, 0);
		if not Match(RightBrack1) then
		    error("expecting ]");
		PopLongA0;
		writeln(OutFile, "\tadd.l\td0,a0");
		VarType := CharType;
	    end else
		error("Expecting an Array or String");
	end;
    end;
    if Stacked then
	Selector := VarType
    else
	Selector := Nil;
end;

Function LoadAddress() : TypePtr;

{
	This is the routine used wherever I need the address of a
variable, for example reference parameters or the adr() function.
The address is loaded into a0.
}

var
    ArgIndex	: IDPtr;
    ArgType	: TypePtr;
begin
    if CurrSym = Ident1 then begin
	ArgIndex := FindWithField(SymText);
	if ArgIndex = Nil then
	    ArgIndex := FindID(SymText);
	NextSymbol;
	if ArgIndex = Nil then begin
	    error("Unknown ID");
	    LoadAddress := BadType;
	end else begin
	    if IsVariable(ArgIndex) then begin
		ArgType := Selector(ArgIndex);
		if ArgType = Nil then begin
		    SimpleAddress(ArgIndex);
		    LoadAddress := ArgIndex^.VType
		end else
		    LoadAddress := ArgType;
	    end else if (ArgIndex^.Object = proc) or
			(ArgIndex^.Object = func) then begin
		with ArgIndex^ do begin
		    if Level <= 1 then
			Writeln(OutFile, "\tlea\t_", Name, ',a0')
		    else
			Writeln(OutFile, "\tlea\t_", Name, '%', Unique, ',a0');
		end;
		LoadAddress := AddressType;
	    end else
		error("Expecting a variable (reference parameter)");
	end
    end else
	error("Expecting a variable identifier");
    LoadAddress := BadType;
end;

Procedure PushArgs(ProcID : IDPtr);

{
	This routine handles the parameters of a call (not the
declaration, which is handled in doblock()).  It sorts out the
various reference and value parameters and gets the stack properly
set up.
}

var
    CurrentParam	: IDPtr;
    stay		: Boolean;
    argtype		: TypePtr;
    argindex		: integer;
    totalsize		: integer;
    lab			: integer;
begin
    Stay := True;
    if Match(LeftParent1) then begin
	CurrentParam := ProcID^.Param;
	while (not Match(RightParent1)) and Stay do begin
	    if CurrentParam = Nil then begin
		error("argument not expected");
		nextsymbol;
		Stay := False;
	    end else begin
		if CurrentParam^.Object = valarg then begin
		    ArgType := Expression();
		    if not TypeCheck(ArgType, CurrentParam^.VType) then begin
			Mismatch;
			ArgType := BadType;
		    end else begin
			if NumberType(ArgType) then
			    PromoteType(ArgType, CurrentParam^.VType, 0);
			ArgType := CurrentParam^.VType;
			if SimpleType(ArgType) then begin
			    if ArgType^.Size <= 2 then
				PushWordD0
			    else if ArgType^.Size = 4 then
				PushLongD0;
			end else begin
			    writeln(OutFile, "\tmove.l\td0,a0");
			    writeln(OutFile, "\tmove.l\tsp,a1");
			    writeln(OutFile, "\tsub.l\t#",
				ArgType^.Size, ',a1');
			    writeln(OutFile, "\tmove.l\t#",
				ArgType^.Size - 1, ',d1');

			    lab := GetLabel();
			    PrintLabel(lab);
			    writeln(OutFile, "\tmove.b\t(a0)+,d0");
			    writeln(OutFile, "\tmove.b\td0,(a1)+");
			    write(OutFile, "\tdbra\td1,");
			    PrintLabel(lab);
			    writeln(OutFile);
			    write(OutFile, "\tsub.l\t#");
			    if odd(ArgType^.Size) then begin
				write(OutFile, ArgType^.Size + 1);
				StackLoad := StackLoad + ArgType^.Size + 1;
			    end else begin
				write(OutFile, ArgType^.Size);
				StackLoad := StackLoad + ArgType^.Size;
			    end;
			    writeln(OutFile, ',sp');
			end;
		    end;
		end else if CurrentParam^.Object = refarg then begin
		    if CurrSym = ident1 then begin
			ArgType := LoadAddress();
			PushLongA0;
			if not TypeCmp(ArgType, CurrentParam^.VType) then
			    Mismatch;
		    end else
			error("Expecting a variable name (reference param)");
		end;
		CurrentParam := CurrentParam^.Next;
		if CurrentParam <> Nil then
		    if not Match(Comma1) then
			error("Expected ,");
	    end;
	end;
	if CurrentParam <> Nil then
	    error("more parameters needed");
    end else begin
	if ProcID^.Param <> Nil then
	    error("Expecting some parameters");
    end
end;

Procedure PushFrame(Callee : Integer);
var
    Caller : Integer;
begin
    if Callee <= 1 then { global-level routines, which include externs }
	return
    else begin
	Caller := CurrentBlock^.Level - 1;
	if Callee = Caller + 1 then { calling child procedure }
	    writeln(OutFile, "\tmove.l\ta5,-(sp)")
	else if Callee = Caller then { same level }
	    writeln(OutFile, "\tmove.l\t8(a5),-(sp)")
	else begin
	    writeln(OutFile, "\tmove.l\t8(a5),a4");
	    Caller := Pred(Caller);
	    while Caller > Callee do begin
		writeln(OutFile, "\tmove.l\t8(a4),a4");
		Caller := Pred(Caller);
	    end;
	    writeln(OutFile, "\tmove.l\t8(a4),-(sp)");
	end;
	StackLoad := StackLoad + 4;
    end;
end;

Procedure CallFunc(FuncID : IDPtr);

{
	This calls a function.  It's mostly the same as callproc,
but it's called from deep within expression() rather than
statement().  This will also have to push a back pointer.
}
var
    ArgSize : Integer;
    BaseOffset : Integer;
begin
    PushArgs(FuncID);
    PushFrame(FuncID^.Level);
    if FuncID^.Level <= 1 then
	writeln(OutFile, "\tjsr\t_", FuncID^.Name)
    else
	Writeln(OutFile, "\tjsr\t_", FuncID^.Name, '%', FuncID^.Unique);
    if FuncID^.Param <> Nil then begin
	if FuncID^.Param^.Object = refarg then
	    ArgSize := FuncID^.Param^.Offset - 4
	else
	    ArgSize := FuncID^.Param^.Offset - 8 +
			FuncID^.Param^.VType^.Size;
    end else begin
	if FuncID^.Level <= 1 then
	    ArgSize := 0
	else
	    ArgSize := 4;
    end;
    if ArgSize <> 0 then begin
	if odd(ArgSize) then
	    ArgSize := Succ(ArgSize);
	PopStackSpace(ArgSize);
    end;
end;

Procedure CallProc(ProcID : IDPtr);

var
    ArgSize : Integer;
begin
    NextSymbol;
    CallFunc(ProcID);
end;

Procedure SaveThrougha0(TotalSize : Integer);

{
	This saves a complex data object pointed to by d0 to the
memory at a0.
}

var
    lab		: integer;
begin
    writeln(OutFile, "\tmove.l\td0,a1");
    writeln(OutFile, "\tmove.l\t#", TotalSize - 1, ',d1');
    lab := GetLabel();
    PrintLabel(lab);
    writeln(OutFile, "\tmove.b\t(a1)+,d0");
    writeln(OutFile, "\tmove.b\td0,(a0)+");
    write(OutFile, "\tdbra\td1,");
    PrintLabel(lab);
    writeln(OutFile);
end;

Procedure SaveStack(TP : TypePtr);

{
	This saves a variable into the memory pointed to by the
longword on the top of the stack.  Odd as it may sound, this occurs
fairly often.
}

begin
    PopLongA0;
    if SimpleType(TP) then
	writeln(OutFile, "\tmove.", suffix(TP^.Size), "\td0,(a0)")
    else
	SaveThrougha0(TP^.Size);
end;

Procedure SaveVal(ID : IDPtr);

{
	This saves whatever's in d0 into the variable pointed to by
ID.
}

var
    TotalSize	: Integer;
    Reg : Short;
begin
    TotalSize := ID^.VType^.Size;
    if (ID^.Object = global) or (ID^.Object = typed_const) then begin
	if SimpleType(ID^.VType) then begin
	    if ID^.Level > 1 then { only for typed_const, of course }
		writeln(OutFile, '\tmove.', Suffix(TotalSize), '\td0,_',
				ID^.Name, '%', ID^.Unique)
	    else
		writeln(OutFile, "\tmove.", Suffix(TotalSize),
				"\td0,_", ID^.Name)
	end else begin
	    if ID^.Level > 1 then { only for typed_const, of course }
		writeln(OutFile, '\tlea\t_',ID^.Name,'%',ID^.Unique,',a0')
	    else
		writeln(OutFile, "\tlea\t_", ID^.Name, ',a0');
	    SaveThrougha0(TotalSize);
	end;
    end else if (ID^.Object = local) or (ID^.Object = valarg) then begin
	Reg := GetFramePointer(ID^.Level);
	if SimpleType(ID^.VType) then
	    writeln(OutFile, "\tmove.", Suffix(TotalSize), "\td0,",
			ID^.Offset, '(a', Reg, ')')
	else begin
	    writeln(OutFile, "\tlea\t", ID^.Offset, '(a', Reg, '),a0');
	    savethrougha0(totalsize);
	end;
    end else begin
	Reg := GetFramePointer(ID^.Level);
	writeln(OutFile, "\tmove.l\t", ID^.Offset, '(a', Reg, '),a0');
	if SimpleType(ID^.VType) then
	    writeln(OutFile, "\tmove.", Suffix(TotalSize), "\td0,(a0)")
	else
	    SaveThrougha0(TotalSize);
    end;
end;

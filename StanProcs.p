External;

{
	Stanprocs.p (of PCQ Pascal)
	Copyright (c) 1989 Patrick Quaid

	This routine implements the various standard procedures,
	hence the name.
}

{$O-}
{$I "Pascal.i"}

	Procedure NextSymbol;
	    external;
	Function Match(s : Symbols): Boolean;
	    external;
	Procedure Error(s : string);
	    external;
	Function Expression(): TypePtr;
	    external;
	Function ConExpr(VAR t : TypePtr): Integer;
	    external;
	Function TypeCmp(t1, t2 : TypePtr): Boolean;
	    external;
	Function TypeCheck(t1, t2 : TypePtr): Boolean;
	    external;
	Function LoadAddress() : TypePtr;
	    external;
	Procedure Mismatch;
	    external;
	Procedure NeedLeftParent;
	    external;
	Procedure NeedRightParent;
	    external;
	Procedure NeedNumber;
	    external;
	Function FindID(s : string) : IDPtr;
	    external;
	Function FindWithField(s : String) : IDPtr;
	    External;
	Procedure SaveStack(TP : TypePtr);
	    external;
	Procedure SaveVal(ID : IDPtr);
	    external;
	Procedure ns;
	    external;
	Procedure PromoteType(var f : TypePtr; o : TypePtr; r : Short);
	    external;
	Function NumberType(t : TypePtr): Boolean;
	    external;
	Procedure PushLongD0;
	    external;
	Procedure PushWordD0;
	    external;
	Procedure PopLongD1;
	    external;
	Procedure PopStackSpace(amount : Integer);
	    External;
	Procedure PushLongA0;
	    External;
	Function Selector(ID : IDPtr) : TypePtr;
	    external;
	Function Suffix(size : Integer) : Char;
	    External;

Procedure CallWrite(TP : TypePtr);

{
	This routine calls the appropriate library routine to write
vartype to a text file.
}

var
    ElementType	: TypePtr;
begin
    if TypeCmp(TP, RealType) then
	writeln(OutFile, "\tjsr\t_p%WriteReal")
    else if NumberType(TP) then begin
	PromoteType(TP, IntType, 0);
	writeln(OutFile, "\tjsr\t_p%WriteInt");
    end else if TypeCmp(TP, CharType) then
	writeln(OutFile, "\tjsr\t_p%WriteChar")
    else if TypeCmp(TP, BoolType) then
	writeln(OutFile, "\tjsr\t_p%WriteBool")
    else if TP^.Object = ob_array then begin
	ElementType := TP^.SubType;
	if TypeCmp(ElementType, CharType) then begin
	    writeln(OutFile, "\tmove.l\t#", TP^.Upper - TP^.Lower + 1, ',d3');
	    writeln(OutFile, "\tjsr\t_p%WriteCharray");
	end else
	    Error("Write() can only write arrays of char");
    end else if TP = StringType then
	writeln(OutFile, "\tjsr\t_p%WriteString")
    else
	Error("can't write that type to text file");
    if IOCheck then
	Writeln(OutFile, '\tjsr\t_p%CheckIO');
end;

Procedure FileWrite(TP : TypePtr);

{
	This routine writes a variable to a File of TP
}

begin
    writeln(OutFile, "\tmove.l\t#", TP^.Size, ',d3');
    writeln(OutFile, "\tjsr\t_p%WriteArb");
    if IOCheck then
	Writeln(OutFile, '\tjsr\t_p%CheckIO');
end;

Procedure DoWrite(ID : IDPtr);

{
	This routine handles all aspects of the write and writeln
statements.
}

var
    FileType	: TypePtr; { file type if there is one }
    ExprType	: TypePtr; { current element type }
    Pushed	: Boolean; { have pushed the file handle on stack }
    Width	: Integer; { constant field width }
    WidType     : TypePtr; { type of the above }
begin
    if Match(LeftParent1) then begin
	FileType := Expression();
	Pushed := True;
	if FileType^.Object = ob_file then
	    PushLongD0
	else begin
	    writeln(OutFile, "\tmove.l\t#_Output,-(sp)");
	    StackLoad := StackLoad + 4;
	    if Match(colon1) then begin
		PushLongD0;
		WidType := Expression();
		if not TypeCheck(IntType, WidType) then
		    NeedNumber;
		PopLongD1;
		PushWordD0;
		writeln(OutFile, "\tmove.l\td1,d0");
	    end else begin
		writeln(OutFile, "\tmove.w\t#1,-(sp)");
		StackLoad := StackLoad + 2;
	    end;
	    if TypeCmp(FileType, RealType) then begin
		if Match(colon1) then begin
		    PushLongD0;
		    WidType := Expression();
		    if not TypeCheck(IntType, WidType) then
			NeedNumber;
		    PopLongD1;
		    PushWordD0;
		    writeln(OutFile, "\tmove.l\td1,d0");
		end else begin
		    writeln(OutFile, "\tmove.w\t#2,-(sp)");
		    StackLoad := StackLoad + 2;
		end;
	    end;
	    CallWrite(FileType);
	    if TypeCmp(FileType, RealType) then
		PopStackSpace(4)
	    else
		PopStackSpace(2);
	    FileType := TextType;
	end;
	while not Match(RightParent1) do begin
	    if not Match(Comma1) then
		Error("expecting , or )");
	    ExprType := Expression();
	    if FileType = TextType then begin
		if Match(Colon1) then begin
		    PushLongD0;
		    WidType := Expression();
		    if not TypeCheck(IntType, WidType) then
			NeedNumber;
		    PopLongD1;
		    PushWordD0;
		    writeln(OutFile, "\tmove.l\td1,d0");
		end else begin
		    writeln(OutFile, "\tmove.w\t#1,-(sp)");
		    StackLoad := StackLoad + 2;
		end;
		if TypeCmp(ExprType, RealType) then begin
		    if Match(colon1) then begin
			PushLongD0;
			WidType := Expression();
			if not TypeCheck(IntType, WidType) then
			    NeedNumber;
			PopLongD1;
			PushWordD0;
			writeln(OutFile, "\tmove.l\td1,d0");
		    end else begin
			writeln(OutFile, "\tmove.w\t#2,-(sp)");
			StackLoad := StackLoad + 2;
		    end;
		end;
		CallWrite(ExprType);
		if TypeCmp(ExprType, RealType) then
		    PopStackSpace(4)
		else
		    PopStackSpace(2);
	    end else begin
		if TypeCmp(FileType^.SubType, ExprType) then
		    FileWrite(ExprType)
		else
		    Mismatch;
	    end;
	end;
    end else begin
	FileType := TextType;
	Pushed := False;
	if ID^.Offset = 1 then
	    error("'write' requires arguments.");
    end;
    if ID^.Offset = 2 then begin
	if FileType = TextType then begin
	    if Pushed then
		writeln(OutFile, "\tjsr\t_p%WriteLn")
	    else begin
		writeln(OutFile, "\tmove.l\t#_Output,-(sp)");
		writeln(OutFile, "\tjsr\t_p%WriteLn");
		writeln(OutFile, "\taddq.l\t#4,sp");
	    end;
	    if IOCheck then
		Writeln(OutFile, '\tjsr\t_p%CheckIO');
	end else
	   error("Writeln is only for text files");
    end;
    if Pushed then
	PopStackSpace(4);
end;

Procedure CallRead(TP : TypePtr);

{
	This routine calls the appropriate library routines to read
the vartype from a text file.
}

begin
    if TypeCmp(TP, CharType) then
	writeln(OutFile, "\tjsr\t_p%ReadChar")
    else if TypeCmp(TP, IntType) then begin
	writeln(OutFile, "\tjsr\t_p%ReadInt");
	writeln(OutFile, "\tmove.l\td0,(a0)");
    end else if TypeCmp(TP, ShortType) then begin
	writeln(OutFile, "\tjsr\t_p%ReadInt");
	writeln(OutFile, "\tmove.w\td0,(a0)");
    end else if TypeCmp(TP, RealType) then
	writeln(OutFile, "\tjsr\t_p%ReadReal")
    else if TP^.Object = ob_array then begin
	if TypeCmp(TP^.SubType, chartype) then begin
	    writeln(OutFile, "\tmove.l\t#", TP^.Upper - TP^.Lower + 1, ',d3');
	    writeln(OutFile, "\tjsr\t_p%ReadCharray");
	end else
	    Error("can only read character arrays");
    end else if TP = StringType then
	writeln(OutFile, "\tjsr\t_p%ReadString")
    else
	Error("cannot read that type from a text file");
    if IOCheck then
	Writeln(OutFile, '\tjsr\t_p%CheckIO');
end;

Procedure DoRead(ID : IDPtr);

{
	This handles the read statement.  Note that read(f, var) from a
non-text file really does end up being var := f^; get(f).  Same
goes for text files, but it's all handled within the library.
	Note the difference between this and dowrite(),
specifically the use of expression() up there and loadaddress()
here.
}

var
    FileType,
    VarType	: TypePtr;
    Pushed	: Boolean;
begin
    if Match(LeftParent1) then begin
	FileType := LoadAddress();
	Pushed := True;
	if FileType^.Object = ob_file then
	    PushLongA0
	else begin
	    writeln(OutFile, "\tmove.l\t#_Input,-(sp)");
	    StackLoad := StackLoad + 4;
	    CallRead(FileType);
	    FileType := TextType;
	end;
	while not Match(RightParent1) do begin
	    if not Match(Comma1) then
		Error("expecting , or )");
	    VarType := LoadAddress();
	    if FileType = TextType then
		CallRead(VarType)
	    else begin
		if TypeCmp(FileType^.SubType, VarType) then
		    writeln(OutFile, "\tjsr\t_p%ReadArb")
		else
		    Mismatch;
		if IOCheck then
		    Writeln(OutFile, '\tjsr\t_p%CheckIO');
	    end;
	end;
    end else begin
	FileType := TextType;
	Pushed := False;
	if ID^.Offset = 3 then
	    error("'read' requires arguments.");
    end;
    if ID^.Offset = 4 then begin
	if TypeCmp(FileType, TextType) then begin
	    if Pushed then
		writeln(OutFile, "\tjsr\t_p%ReadLn")
	    else begin
		writeln(OutFile, "\tmove.l\t#_Input,-(sp)");
		writeln(OutFile, "\tjsr\t_p%ReadLn");
		writeln(OutFile, "\taddq.l\t#4,sp");
	    end;
	    if IOCheck then
		Writeln(OutFile, '\tjsr\t_p%CheckIO');
	end else
	   error("Readln applies only to Text files");
    end;
    if Pushed then
	PopStackSpace(4);
end;

Procedure DoNew;

{
	This just handles allocation of memory.
}

var
    ID		: IDPtr;
    TP		: TypePtr;
    StackVar	: TypePtr;
begin
    NeedLeftParent;
    ID := FindWithField(SymText);
    if ID = Nil then
	ID := FindID(SymText);
    if ID <> Nil then begin
	NextSymbol;
	StackVar := Selector(ID);
	if StackVar = Nil then
	    TP := ID^.VType
	else begin
	    PushLongA0;
	    TP := StackVar;
	end;
	if TP^.Object <> ob_pointer then
	    Error("expecting a pointer type");
	writeln(OutFile, "\tmove.l\t#", TP^.SubType^.Size, ',d0');
	writeln(OutFile, "\tjsr\t_p%new");
	if StackVar = Nil then
	    SaveVal(ID)
	else
	    SaveStack(TP);
    end else
	Error("Unknown identifier");
    NeedRightParent;
end;

Procedure DoDispose;

{
	This routine calls the library routine that frees memory.
}

var
    ExprType	: TypePtr;
begin
    NeedLeftParent;
    ExprType := Expression();
    if ExprType^.Object <> ob_pointer then
	Error("Expecting a pointer type")
    else
	writeln(OutFile, "\tjsr\t_p%dispose");
    NeedRightParent;
end;

Procedure DoClose;

{
	Closes a file.  The difference between this and a normal
DOS close is that this routine must un-link the file from the
program's open file list.
}

var
    ExprType	: TypePtr;
begin
    NeedLeftParent;
    ExprType := LoadAddress();
    if ExprType^.Object <> ob_file then
	Error("Expecting a file type")
    else
	writeln(OutFile, "\tjsr\t_p%Close");
    if IOCheck then
	Writeln(OutFile, '\tjsr\t_p%CheckIO');
    NeedRightParent;
end;

Procedure DoGet;

{
	This implements get.
}

var
    ExprType	: TypePtr;
begin
    NeedLeftParent;
    ExprType := LoadAddress();
    if ExprType^.Object <> ob_file then
	Error("Expecting a file type")
    else
	Writeln(OutFile, '\tjsr\t_p%Get');
    if IOCheck then
	Writeln(OutFile, '\tjsr\t_p%CheckIO');
    NeedRightParent;
end;

Procedure DoPut;

{
	This just implements put.  The real guts of these two
routines is in the runtime library.
}

var
    ExprType	: TypePtr;
begin
    NeedLeftParent;
    ExprType := LoadAddress();
    if ExprType^.Object <> ob_file then
	Error("Expecting a file type")
    else
	Writeln(OutFile, '\tjsr\t_p%Put');
    if IOCheck then
	Writeln(OutFile, '\tjsr\t_p%CheckIO');
    NeedRightParent;
end;

Procedure DoInc;

{
	This takes care of Inc.
}

var
    ExprType	: TypePtr;
begin
    NeedLeftParent;
    ExprType := LoadAddress();
    with ExprType^ do begin
	case Object of
	  ob_ordinal : Writeln(OutFile, '\taddq.',Suffix(Size),'\t#1,(a0)');
	  ob_pointer : Writeln(OutFile, '\tadd.l\t#', SubType^.Size,',(a0)');
	else
	    Error("Expecting an ordinal or pointer type");
	end;
    end;
    NeedRightParent;
end;

Procedure DoDec;

{
	This takes care of Dec.
}

var
    ExprType	: TypePtr;
begin
    NeedLeftParent;
    ExprType := LoadAddress();
    with ExprType^ do begin
	case Object of
	  ob_ordinal : Writeln(OutFile, '\tsubq.',Suffix(Size),'\t#1,(a0)');
	  ob_pointer : Writeln(OutFile, '\tsub.l\t#', SubType^.Size,',(a0)');
	else
	    Error("Expecting an ordinal or pointer type");
	end;
    end;
    NeedRightParent;
end;

Procedure DoExit;

{
	Just calls the routine that allows the graceful shut-down
of the program.
}

var
    ExprType : TypePtr;
begin
    NeedLeftParent;
    ExprType := Expression();
    if not TypeCheck(ExprType, IntType) then
	Error("Expecting an integer argument.");
    writeln(OutFile, "\tjsr\t_p%exit");
    NeedRightParent;
end;

Procedure DoTrap;

{
	This is just for debugging a program.  Use some trap, and
your debugger will stop at that statement.
}

var
    ExprType  : TypePtr;
    TrapNum   : Integer;
begin
    NeedLeftParent;
    TrapNum := ConExpr(ExprType);
    writeln(OutFile, "\ttrap\t#", trapnum);
    NeedRightParent;
end;

Procedure StdProc(ProcID : IDPtr);

{
	This routine sifts out the proper routine to call.
}

begin
    NextSymbol;
    case ProcID^.Offset of
      1,2 : DoWrite(ProcID);
      3,4 : DoRead(ProcID);
      5   : DoNew;
      6   : DoDispose;
      7   : DoClose;
      8   : DoGet;
      9   : DoExit;
      10  : DoTrap;
      11  : DoPut;
      12  : DoInc;
      13  : DoDec;
    end;
end;


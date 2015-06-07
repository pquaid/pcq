External;

{
	Initialize.p (of PCQ Pascal)
	Copyright (c) 1989 Patrick Quaid.

	This routine initializes all the global variables and
enters the standard identifiers.
}

{$O-}
{$I "Identify.i"}

	Function AddType(at_Object : TypeObject;
			 at_SubType: TypePtr;
			 at_Ref    : Address;
			 at_Upper,
			 at_Lower,
			 at_Size   : Integer) : TypePtr;
	    external;

	Function EnterStandard(	es_Name : String;
				es_Object : IDObject;
				es_Type : TypePtr;
				es_Storage : IDStorage;
				es_Offset : Integer) : IDPtr;
	    external;

	Function AllocString(l : integer): string;
	    external;

	Procedure NewBlock;
	    external;
	Procedure NewSpell;
	    external;
	
Procedure InitStandard;

{
	This is a huge routine, but since it's so straightforward I
don't think I'll split it up.  It just enters all the standard
identifiers into the identifier table.  Note that 'nil' is
considered a standard identifier.
}
var
    ID : IDPtr;
    TP : TypePtr;
begin
    BadType := AddType(ob_ordinal, nil, nil, 0, 0, 4);

    IntType := AddType(ob_ordinal, nil, nil, 0, 0, 4);
    ID := EnterStandard("Integer", obtype, IntType, st_none, 0);

    ShortType := AddType(ob_ordinal, nil, nil, 0, 0, 2);
    ID := EnterStandard("Short", obtype, ShortType, st_none, 0);

    BoolType := AddType(ob_ordinal, nil, nil, 0, 0, 1);
    ID := EnterStandard("Boolean", obtype, BoolType, st_none, 0);

    CharType := AddType(ob_ordinal, nil, nil, 0, 0, 1);
    ID := EnterStandard("Char", obtype, CharType, st_none, 0);

    TextType := AddType(ob_file, CharType, nil, 0, 0, 32);
    ID := EnterStandard("Text", obtype, TextType, st_none, 0);

    StringType := AddType(ob_pointer, CharType, nil, 0, 0, 4);
    ID := EnterStandard("String", obtype, StringType, st_none, 0);

    RealType := AddType(ob_real, nil, nil, 0, 0, 4);
    ID := EnterStandard("Real", obtype, RealType, st_none, 0);

    ByteType := AddType(ob_ordinal, nil, nil, 0, 0, 1);
    ID := EnterStandard("Byte", obtype, ByteType, st_none, 0);

    AddressType := AddType(ob_pointer, BadType, nil, 0, 0, 4);
    ID := EnterStandard("Address", obtype, AddressType, st_none, 0);

    LiteralType := AddType(ob_array, CharType, IntType, 1, 1, 1);

    ID := EnterStandard("Write", stanproc, nil, st_none, 1);
    ID := EnterStandard("WriteLn", stanproc, nil, st_none, 2);
    ID := EnterStandard("Read", stanproc, nil, st_none, 3);
    ID := EnterStandard("ReadLn", stanproc, nil, st_none, 4);
    ID := EnterStandard("New", stanproc, nil, st_none, 5);
    ID := EnterStandard("Dispose", stanproc, nil, st_none, 6);
    ID := EnterStandard("Close", stanproc, nil, st_none, 7);
    ID := EnterStandard("Get", stanproc, nil, st_none, 8);
    ID := EnterStandard("Exit", stanproc, nil, st_none, 9);
    ID := EnterStandard("Trap", stanproc, nil, st_none, 10);
    ID := EnterStandard("Put", stanproc, nil, st_none, 11);
    ID := EnterStandard("Inc", stanproc, nil, st_none, 12);
    ID := EnterStandard("Dec", stanproc, nil, st_none, 13);

    ID := EnterStandard("Ord", stanfunc, IntType, st_none, 1);
    ID := EnterStandard("Chr", stanfunc, CharType, st_none, 2);
    ID := EnterStandard("Odd", stanfunc, BoolType, st_none, 3);
    ID := EnterStandard("Abs", stanfunc, IntType, st_none, 4);
    ID := EnterStandard("Succ", stanfunc, IntType, st_none, 5);
    ID := EnterStandard("Pred", stanfunc, IntType, st_none, 6);
    ID := EnterStandard("Reopen", stanfunc, BoolType, st_none, 7);
    ID := EnterStandard("Open", stanfunc, BoolType, st_none, 8);
    ID := EnterStandard("EOF", stanfunc, BoolType, st_none, 9);
    ID := EnterStandard("Trunc", stanfunc, IntType, st_none, 10);
    ID := EnterStandard("Round", stanfunc, IntType, st_none, 11);
    ID := EnterStandard("Float", stanfunc, RealType, st_none, 12);
    ID := EnterStandard("Floor", stanfunc, RealType, st_none, 13);
    ID := EnterStandard("Ceil", stanfunc, RealType, st_none, 14);
    ID := EnterStandard("SizeOf", stanfunc, IntType, st_none, 15);
    ID := EnterStandard("Adr", stanfunc, AddressType, st_none, 16);
    ID := EnterStandard("Bit", stanfunc, IntType, st_none, 17);
    ID := EnterStandard("Sqr", stanfunc, RealType, st_none, 18);
    ID := EnterStandard("Sin", stanfunc, RealType, st_none, 19);
    ID := EnterStandard("Cos", stanfunc, RealType, st_none, 20);
    ID := EnterStandard("Sqrt", stanfunc, RealType, st_none, 21);
    ID := EnterStandard("Tan", stanfunc, RealType, st_none, 22);
    ID := EnterStandard("ArcTan", stanfunc, RealType, st_none, 23);
    ID := EnterStandard("Ln", stanfunc, RealType, st_none, 24);
    ID := EnterStandard("Exp", stanfunc, RealType, st_none, 25);

    ID := enterstandard("True", constant, BoolType, st_none, -1);
    ID := enterstandard("False", constant, BoolType, st_none, 0);
    ID := enterstandard("MaxInt", constant, IntType, st_none, $7FFFFFFF);
    ID := enterstandard("MaxShort", constant, ShortType, st_none, $7FFF);
    ID := enterstandard("Nil", constant, AddressType, st_none, 0);

    ID := EnterStandard("CommandLine", global, StringType, st_external, 0);
    ID := EnterStandard("ExitProc", global, AddressType, st_external, 0);
    ID := EnterStandard("ExitCode", global, IntType, st_external, 0);
    ID := EnterStandard("ExitAddr", global, AddressType, st_external, 0);
    ID := EnterStandard("IOResult", func, IntType, st_external, 0);
    ID := EnterStandard("Input", global, TextType, st_external, 0);
    ID := EnterStandard("Output", global, TextType, st_external, 0);
    ID := EnterStandard("HeapError", global, AddressType, st_external, 0);
end;


Procedure InitReserved();

{
	This initializes the array of reserved words.  If you mess
around with this, be advised that the symbol numbers defined in
pasconst.i correspond with the indices of these words.  Look at
searchreserved in utilities.p to explain the previous sentence.
}

begin
    Reserved[And1]	:= "AND";
    Reserved[Array1]	:= "ARRAY";
    Reserved[Begin1]	:= "BEGIN";
    Reserved[By1]	:= "BY";
    Reserved[Case1]	:= "CASE";
    Reserved[Const1]	:= "CONST";
    Reserved[Div1]	:= "DIV";
    Reserved[Do1]	:= "DO";
    Reserved[Downto1]	:= "DOWNTO";
    Reserved[Else1]	:= "ELSE";
    Reserved[End1]	:= "END";
    Reserved[Extern1]	:= "EXTERNAL";
    Reserved[File1]	:= "FILE";
    Reserved[For1]	:= "FOR";
    Reserved[Forward1]	:= "FORWARD";
    Reserved[Func1]	:= "FUNCTION";
    Reserved[Goto1]	:= "GOTO";
    Reserved[If1]	:= "IF";
    Reserved[In1]	:= "IN";
    Reserved[Label1]	:= "LABEL";
    Reserved[Mod1]	:= "MOD";
    Reserved[Not1]	:= "NOT";
    Reserved[Of1]	:= "OF";
    Reserved[Or1]	:= "OR";
    Reserved[Packed1]	:= "PACKED";
    Reserved[Private1]	:= "PRIVATE";
    Reserved[Proc1]	:= "PROCEDURE";
    Reserved[Program1]	:= "PROGRAM";
    Reserved[Record1]	:= "RECORD";
    Reserved[Repeat1]	:= "REPEAT";
    Reserved[Return1]	:= "RETURN";
    Reserved[Set1]	:= "SET";
    Reserved[Shl1]	:= "SHL";
    Reserved[Shr1]	:= "SHR";
    Reserved[Then1]	:= "THEN";
    Reserved[To1]	:= "TO";
    Reserved[Type1]	:= "TYPE";
    Reserved[Until1]	:= "UNTIL";
    Reserved[Var1]	:= "VAR";
    Reserved[While1]	:= "WHILE";
    Reserved[With1]	:= "WITH";
    Reserved[Xor1]	:= "XOR";
end;

Function IsInteractive(handle : Address) : Boolean;
    External;

Procedure CheckStdIn;
var
    FileRec : ^Address;
begin
    FileRec := Adr(Output);
    StdOut_Interactive := IsInteractive(FileRec^);
end;

Procedure InitGlobals;

{
	This just puts the startup values into the variables.
}

begin
    litlab := 1;

    symtext := allocstring(80);

    eqstart := 0;
    eqend := 0;
    errorptr := 0;

    LitPtr := 0;
    SpellPtr := 0;
    NewSpell;
    errorcount := 0;
    lineno := 1;
    FirstWith := Nil;
    StackLoad := 0;
    currsym := Unknown1;
    symloc := 0;
    currfn := Nil;
    TypeID := Nil;
    nxtlab := 1;
    CharBuffed := False;
    RangeCheck := false;
    IOCheck := True;
    Do_Offsets := False;
    Report_IDS := False;
    CheckStdIn;
    IncludeList := Nil;
    CurrentBlock := Nil;
    InputName := "";
    NewBlock;
end;

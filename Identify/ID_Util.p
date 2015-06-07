external;

{
	ID_Util.p
}

{$O-}
{$I "Identify.i"}
{$I "Include:Utils/StringLib.i"}
{$I "Include:Utils/Break.i"}

	Procedure Error(s : string);
	    external;
	Procedure NextSymbol;
	    external;
	Procedure Abort;
	    external;

Procedure NewSpell;
var
    TempPtr : SpellRecPtr;
begin
    New(TempPtr);
    TempPtr^.Previous := CurrentSpellRec;
    CurrentSpellRec := TempPtr;
    CurrentSpellRec^.First := SpellPtr;
end;

Procedure BackUpSpell(Position : Integer);
var
    TempPtr : SpellRecPtr;
begin
    while Position < CurrentSpellRec^.First do begin
	TempPtr := CurrentSpellRec^.Previous;
	Dispose(CurrentSpellRec);
	CurrentSpellRec := TempPtr;
    end;
    SpellPtr := Position;
end;

Function EnterSpell(S : String) : String;
var
    Length : Integer;
    Result : String;
begin
    Length := strlen(S) + 1;
    if (Length + SpellPtr) - CurrentSpellRec^.First > Spell_Max then
	NewSpell;
    Result := Adr(CurrentSpellRec^.Data[SpellPtr - CurrentSpellRec^.First]);
    strcpy(Result, S);
    SpellPtr := SpellPtr + Length;
    EnterSpell := Result;
end;

Function SimpleType(testtype : TypePtr) : Boolean;

{
	If a variable passes this test, it is held in a register
during processing.  If not, the address of the variable is held in
the register.  This is the main reason why type conversions don't
work across all types of the same size.
}

begin
    SimpleType := (TestType^.Size <= 4) and
		  (TestType^.Size <> 3) and
		  (TestType^.Object <> ob_record) and
		  (TestType^.Object <> ob_array);
end;

Function BaseType(orgtype : TypePtr): TypePtr;

{
	This routine returns the base type of type.  If this
routine is used consistently, ranges and subtypes will work with
some consistency.
}

begin
    while (orgtype^.Object = ob_subrange) or (orgtype^.Object = ob_synonym) do
	orgtype := orgtype^.SubType;
    basetype := orgtype;
end;

Function HigherType(typea, typeb : TypePtr): TypePtr;

{
	This routine returns the more complex type of the two
numeric types passed to it.  In other words a 32 bit integer is
'higher' than a 16 bit one.
}

begin
    if (TypeA = RealType) or (TypeB = RealType) then
	HigherType := RealType;
    if (typea = inttype) or (typeb = inttype) then
	highertype := inttype;
    if (typea = shorttype) or (typeb = shorttype) then
	highertype := shorttype;
    highertype := typea;
end;

Procedure NewBlock;
var
    CB : BlockPtr;
    i  : Short;
begin
    New(CB);
    CB^.FirstType := Nil;
    for i := 0 to Hash_Size do
	CB^.Table[i] := Nil;
    if CurrentBlock = Nil then
	CB^.Level := 0
    else
	CB^.Level := Succ(CurrentBlock^.Level);
    CB^.Previous := CurrentBlock;
    CurrentBlock := CB;
end;

Procedure KillIDList(ID : IDPtr);
var
    TempID : IDPtr;
begin
    while ID <> Nil do begin
	if (ID^.Object = proc) or (ID^.Object = func) then
	    KillIDList(ID^.Param);
	TempID := ID^.Next;
	Dispose(ID);
	ID := TempID;
    end;
end;

Procedure KillBlock;
var
    CB : BlockPtr;
    ID : IDPtr;
    TP : TypePtr;
    i  : Integer;

    Procedure KillTypeList(TP : TypePtr);
    var
	TempType : TypePtr;
    begin
	while TP <> nil do begin
	    if TP^.Object = ob_record then
		KillIDList(TP^.Ref);
	    TempType := TP^.Next;
	    Dispose(TP);
	    TP := TempType;
	end;
    end;

begin
    CB := CurrentBlock;
    CurrentBlock := CurrentBlock^.Previous;
    for i := 0 to Hash_Size do
	KillIDList(CB^.Table[i]);
    KillTypeList(CB^.FirstType);
end;

Function Match(sym : Symbols): Boolean;

{
	If the current symbol is sym, return true and get the
next one.
}

begin
    if CurrSym = Sym then begin
	NextSymbol;
	Match := True;
    end else
	Match := False;
end;

{
	The following routines just print out common error messages
and make some common tests.
}
 
procedure Mismatch;
begin
    error("Mismatched types");
end;

procedure NeedNumber;
begin
    error("Need a numeric type");
end;

procedure NoLeftParent;
begin
    error("No left parenthesis");
end;

procedure NoRightParent;
begin
    error("No right parenthesis");
end;

procedure NeedLeftParent;
begin
    if not match(leftparent1) then
	noleftparent;
end;

procedure NeedRightParent;
begin
    if not match(rightparent1) then
	norightparent;
end;

Procedure EnterID(EntryBlock : BlockPtr; ID : IDPtr);
var
    HVal : Short;
begin
    ID^.Level := EntryBlock^.Level;
    HVal := Hash(ID^.Name) and Hash_Size;
    ID^.Next := EntryBlock^.Table[HVal];
    EntryBlock^.Table[HVal] := ID;
    ID^.Source := InputName;
end;

Function EnterStandard( st_Name : String;
			st_Object : IDObject;
			st_Type : TypePtr;
			st_Storage : IDStorage;
			st_Offset  : Integer)	: IDPtr;
var
    ID : IDPtr;
begin
    new(ID);
    ID^.Next := Nil;
    ID^.Name := EnterSpell(st_Name);
    ID^.Object := st_Object;
    ID^.VType := st_Type;
    ID^.Param := Nil;
    ID^.Storage := st_Storage;
    ID^.Offset := st_Offset;
    EnterID(CurrentBlock, ID);
    EnterStandard := ID;
end;

Procedure ns;

{
	This routine just tests for a semicolon.
}

begin
    if not match(semicolon1) then begin
	if (currsym <> end1) and (currsym <> else1) and (currsym <> until1) then
	    error("missing semicolon");
    end else
	while match(semicolon1) do;
end;

Function TypeCmp(TypeA, TypeB : TypePtr) : Boolean;

{
	This routine just compares two types to see if they're
equivalent.  Subranges of the same type are considered equivalent.
Note that 'badtype' is actually a universal type used when there
are errors, in order to avoid streams of errors.
}

var
	t1ptr,
	t2ptr  : IDPtr;
begin
    TypeA := BaseType(TypeA);
    TypeB := BaseType(TypeB);

    if TypeA = TypeB then
	TypeCmp := True;
    if (TypeA = BadType) or (TypeB = BadType) then
	TypeCmp := True;
    if TypeA^.Object <> TypeB^.Object then
	typecmp := false;
    if TypeA^.Object = ob_array then begin
	if (TypeA^.Upper - TypeA^.Lower) <>
	   (TypeB^.Upper - TypeB^.Lower) then
	    typecmp := false;
	TypeCmp := TypeCmp(TypeA^.Subtype, TypeB^.SubType);
    end;
    if TypeA^.Object = ob_pointer then
	TypeCmp := TypeCmp(TypeA^.SubType, TypeB^.SubType);
    if TypeA^.Object = ob_file then
	TypeCmp := TypeCmp(TypeA^.SubType, TypeB^.Subtype);
    TypeCmp := false;
end;

Function NumberType(testtype : TypePtr) : Boolean;

{
	Return true if this is a numeric type.
}

begin
    TestType := BaseType(TestType);
    if TestType = IntType then
	NumberType := true
    else if TestType = ShortType then
	NumberType := True
    else if TestType = ByteType then
	NumberType := True;
    NumberType := False;
end;

Function TypeCheck(TypeA, TypeB : TypePtr) : Boolean;

{
	This is similar to typecmp, but considers numeric types
equivalent.
}

begin
    TypeA := BaseType(TypeA);
    TypeB := BaseType(TypeB);
    if TypeA = TypeB then
	TypeCheck := True;
    if NumberType(TypeA) and NumberType(TypeB) then
	TypeCheck := True;
    TypeCheck := TypeCmp(TypeA, TypeB);
end;

Function AddType(at_Object : TypeObject;
		 at_SubType: TypePtr;
		 at_Ref    : Address;
		 at_Upper,
		 at_Lower,
		 at_Size   : Integer) : TypePtr;

{
	Adds a type to the id array.
}

var
    TP	: TypePtr;
begin
    New(TP);
    TP^.Object := at_Object;
    TP^.SubType := at_SubType;
    TP^.Ref := at_Ref;
    TP^.Upper := at_Upper;
    TP^.Lower := at_Lower;
    TP^.Size  := at_Size;
    TP^.Next  := CurrentBlock^.FirstType;
    CurrentBlock^.FirstType := TP;
    AddType := TP;
end;

Function FindID(idname : string): IDPtr;
{ Find the most local reference to a variable }
var
    ID	: IDPtr;
    CB  : BlockPtr;
    HVal : Short;
begin
    CB := CurrentBlock;
    HVal := Hash(idname) and Hash_Size;
    while CB <> nil do begin
	ID := CB^.Table[HVal];
	while ID <> nil do begin
	    if strieq(idname, ID^.Name) then
		FindID := ID;
	    ID := ID^.Next;
	end;
	CB := CB^.Previous;
    end;
    FindID := Nil;
end;

Function CheckID(idname : string): IDPtr;

{
	This is like the above, but only checks the current block.
}

var
    ID : IDPtr;
begin
    ID := CurrentBlock^.Table[Hash(idname) and Hash_Size];
    while ID <> nil do begin
	if strieq(idname, ID^.Name) then
	    CheckID := ID;
	ID := ID^.Next;
    end;
    CheckID := Nil;
end;

Function CheckIDList(S : String; ID : IDPtr) : Boolean;
begin
    while ID <> nil do begin
	if strieq(S, ID^.Name) then
	    CheckIDList := True;
	ID := ID^.Next;
    end;
    CheckIDList := False;
end;

Function FindField(idname : string; RecType : TypePtr) : IDPtr;

{
	This just finds the appropriate field, given the index of
the record type.

}

var
    ID	: IDPtr;
begin
    ID := RecType^.Ref;
    while ID <> Nil do begin
	if strieq(idname, ID^.Name) then
	    FindField := ID;
	ID := ID^.Next;
    end;
    FindField := Nil;
end;

Function FindWithField(Str : String) : IDPtr;
var
    CurrentWith : WithRecPtr;
    ID : IDPtr;
begin
    CurrentWith := FirstWith;
    while CurrentWith <> Nil do begin
	ID := FindField(Str, CurrentWith^.RecType);
	if ID <> Nil then begin
	    LastWith := CurrentWith;
	    FindWithField := ID;
	end;
	CurrentWith := CurrentWith^.Previous;
    end;
    FindWithField := Nil;
end;

Function IsVariable(ID : IDPtr) : Boolean;

{
	Returns true if index is a variable.
}

begin
    case ID^.Object of
	local,
	refarg,
	valarg,
	global,
	typed_const,
	field	: IsVariable := True;
    else
	IsVariable := False;
    end;
end;

Procedure WriteTabs(Tabs : Short);
var
   I : Short;
begin
    I := 0;
    while I < Tabs do begin
	Write('    ');
	I := Succ(I);
    end;
end;

Procedure WriteID(ID : IDPtr; Tabs : Short; Primary : Boolean);
    forward;

Procedure WriteType(TP : TypePtr; Tabs : Short; Primary : Boolean);
var
    ID : IDPtr;
begin
    if CheckBreak() then
	Abort;
    case TP^.Object of
	ob_array : begin
		     write('Array [', TP^.lower, '..', TP^.upper, '] of ');
		     WriteType(TP^.SubType, Tabs, False);
		   end;
	ob_record : begin
			Write('Record');
			if not Primary then
			    return
			else
			    Writeln;
			ID := TP^.Ref;
			while ID <> Nil do begin
			    WriteID(ID, Succ(Tabs), False);
			    ID := ID^.Next;
			end;
			WriteTabs(Tabs);
			Write('END');
		    end;
	ob_ordinal : begin
			if TP = IntType then
			    Write('Integer')
			else if TP = ShortType then
			    Write('Short')
			else if TP = BoolType then
			    Write('Boolean')
			else if TP = CharType then
			    Write('Char')
			else if TP = ByteType then
			    Write('Byte')
			else if TP = BadType then
			    Write('Universal')
			else
			    Write('Enumerated');
		    end;
	ob_pointer : begin
			if TP^.SubType = BadType then
			    Write('Address')
			else begin
			    write('^');
			    WriteType(TP^.SubType, Tabs, False);
			end;
		    end;
	ob_file   : begin
			if TP = TextType then
			    Write('Text')
			else begin
			    write('File of ');
			    WriteType(TP^.SubType,Tabs, False);
			end;
		    end;
	ob_real   : Write('Real');
	ob_subrange : begin
			Write(TP^.Lower, ' .. ', TP^.Upper, ' of ');
			WriteType(TP^.SubType, Tabs, False);
		      end;
    end;
end;

procedure WriteID(ID : IDPtr; Tabs : Short; Primary : Boolean);
var
    TempID : IDPtr;

    Procedure WriteName;
    begin
	if ID^.Name = Nil then
	    Write('""')
	else
	    Write(ID^.Name);
    end;

begin
    if CheckBreak() then
	Abort;
    if (ID^.Object <> obtype) and (ID^.Object <> field) then
	return;
    if Primary then
	Writeln;
    WriteTabs(Tabs);
    if ID^.Object = obtype then begin
	write('TYPE ');
	WriteName;
	Write(' = ');
	WriteType(ID^.VType, Tabs, True);
	Writeln(';');
	Write('SizeOf(');
	WriteName;
	Writeln(') = ', ID^.VType^.Size);
    end else begin
	WriteName;
	Write(' (', ID^.Offset, ')\t: ');
	WriteType(ID^.VType, Tabs, False);
	Writeln(';');
    end;
end;

Procedure Decompose;
type
    DecompRec = Record
	Left,
	Right	: ^DecompRec;
	ID	: IDPtr;
    end;
    DecompPtr = ^DecompRec;

var
    Decomp : DecompPtr;
    ID     : IDPtr;
    i      : Integer;

    Procedure WriteAllIDS(DPtr : DecompPtr);
    begin
	if DPtr <> Nil then begin
	    WriteAllIDS(Dptr^.Left);
	    WriteID(DPtr^.ID, 0, True);
	    WriteAllIDS(Dptr^.Right);
	end;
    end;

    Procedure AddID(Add : IDPtr);
    var
	DPtr,
	Current : DecompPtr;
    begin
	New(DPtr);
	with DPtr^ do begin
	    Left := Nil;
	    Right := Nil;
	    ID := Add;
	end;
	if Decomp = Nil then begin
	    Decomp := DPtr;
	    return;
	end;
	Current := Decomp;
	while True do begin
	    if stricmp(Add^.Name, Current^.ID^.Name) < 0 then begin
		if Current^.Left = Nil then begin
		    Current^.Left := DPtr;
		    return;
		end else
		    Current := Current^.Left;
	    end else begin
		if Current^.Right = Nil then begin
		    Current^.Right := DPtr;
		    return;
		end else
		    Current := Current^.Right;
	    end;
	end;
    end;

    Procedure KillIDTree(DPtr : DecompPtr);
    begin
	if DPtr <> Nil then begin
	    KillIDTree(DPtr^.Left);
	    KillIDTree(DPtr^.Right);
	    Dispose(DPtr);
	end;
    end;

begin
    Decomp := Nil;
    for i := 0 to Hash_Size do begin
	ID := CurrentBlock^.Table[i];
	while ID <> nil do begin
	    AddID(ID);
	    ID := ID^.Next;
	end;
    end;
    Writeln('\nTYPE Definitions\n\n');
    WriteAllIDS(Decomp);
    KillIDTree(Decomp);
end;

Procedure ReportID;
type
    DecompRec = Record
	Left,
	Right	: ^DecompRec;
	ID	: IDPtr;
    end;
    DecompPtr = ^DecompRec;

var
    Decomp : DecompPtr;
    ID     : IDPtr;
    i      : Integer;
    Internals : BlockPtr;

    Procedure ReportOneID(ID : IDPtr);
    const
	IDLength = 32;
    var
	s : Integer;
	Thing : String;
    begin
	Write(ID^.Name);
	s := strlen(ID^.Name);
	if s < IDLength then begin
	    Write(' ':IDLength-s);
	    s := IDLength;
	end else begin
	    Write(' ');
	    s := s + 2;
	end;
	case ID^.Object of
	  global,
	  local		: Thing := "VAR";
	  stanproc,
	  proc		: Thing := "PROCEDURE";
	  stanfunc,
	  func		: Thing := "FUNCTION";
	  obtype	: Thing := "TYPE";
	  constant	: Thing := "CONST";
	  typed_const	: Thing := "TYPED CONST";
	else
	    Thing := "Unknown";
	end;
	Write(Thing);
	s := s + strlen(Thing);
	if s < 45 then
	    Write(' ':44-s)
	else
	    Write('  ');
	Writeln(ID^.Source);
	if CheckBreak then
	    Abort;
    end;

    Procedure WriteAllIDS(DPtr : DecompPtr);
    begin
	if DPtr <> Nil then begin
	    WriteAllIDS(Dptr^.Left);
	    ReportOneID(DPtr^.ID);
	    WriteAllIDS(Dptr^.Right);
	end;
    end;

    Procedure AddID(Add : IDPtr);
    var
	DPtr,
	Current : DecompPtr;
    begin
	New(DPtr);
	with DPtr^ do begin
	    Left := Nil;
	    Right := Nil;
	    ID := Add;
	end;
	if Decomp = Nil then begin
	    Decomp := DPtr;
	    return;
	end;
	Current := Decomp;
	while True do begin
	    if stricmp(Add^.Name, Current^.ID^.Name) < 0 then begin
		if Current^.Left = Nil then begin
		    Current^.Left := DPtr;
		    return;
		end else
		    Current := Current^.Left;
	    end else begin
		if Current^.Right = Nil then begin
		    Current^.Right := DPtr;
		    return;
		end else
		    Current := Current^.Right;
	    end;
	end;
    end;

    Procedure KillIDTree(DPtr : DecompPtr);
    begin
	if DPtr <> Nil then begin
	    KillIDTree(DPtr^.Left);
	    KillIDTree(DPtr^.Right);
	    Dispose(DPtr);
	end;
    end;

begin
    Decomp := Nil;
    for i := 0 to Hash_Size do begin
	ID := CurrentBlock^.Table[i];
	while ID <> nil do begin
	    AddID(ID);
	    ID := ID^.Next;
	end;
    end;
    Internals := CurrentBlock^.Previous;
    for i := 0 to Hash_Size do begin
	ID := Internals^.Table[i];
	while ID <> Nil do begin
	    ID^.Source := "PCQ Internal";
	    AddID(ID);
	    ID := ID^.Next;
	end;
    end;
    Writeln('\nIdentifiers Declared\n\n');
    WriteAllIDS(Decomp); { Don't bother disposing - it'll happen momentarily }
end;
    
Function CompareProcs(Proc1, Proc2 : IDPtr) : Boolean;
var
    ID1, ID2 : IDPtr;
begin
    if Proc1^.Object <> Proc2^.Object then
	CompareProcs := False;
    if Proc1^.Object = func then
	if not TypeCmp(Proc1^.VType, Proc2^.VType) then
	    CompareProcs := False;
    ID1 := Proc1^.Param;
    ID2 := Proc2^.Param;
    while (ID1 <> Nil) and (ID2 <> Nil) do begin
	if not TypeCmp(ID1^.VType, ID2^.VType) then
	    CompareProcs := False;
	ID1 := ID1^.Next;
	ID2 := ID2^.Next;
    end;
    CompareProcs := ID1 = ID2;
end;

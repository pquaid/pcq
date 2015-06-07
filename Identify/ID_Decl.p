External;

{
	ID_Decl.p
}

{$O-}
{$I "Identify.i"}

	Function EnterStandard(	st_Name : String;
				st_Object : IDObject;
				st_Type : TypePtr;
				st_Storage : IDStorage;
				st_Offset : Integer) : IDPtr;
	    external;
	Function EnterSpell(Str : String) : String;
	    external;
	Function Match(i : Symbols): boolean;
	    external;
	Procedure Error(s : string);
	    external;
	Function ConExpr(VAR ConType : TypePtr): Integer;
	    external;
	Function AddType(at_Object : TypeObject;
			 at_SubType : TypePtr;
			 at_Ref : Address;
			 at_Upper,
			 at_Lower,
			 at_Size : Integer) : TypePtr;
	    external;

	procedure ns;
	    external;
	Function TypeCmp(f, s : TypePtr): Boolean;
	    external;
	Function FindID(s: string): IDPtr;
	    external;
	function CheckID(s : string): IDPtr;
	    external;
	Function CheckIDList(s : String; ID : IDPtr) : Boolean;
	    external;
	Procedure EnterID(EntryBlock : BlockPtr; ID : IDPtr);
	    external;
	procedure NextSymbol;
	    external;
	Procedure NeedLeftParent;
	    External;
	procedure NeedRightParent;
	    external;
	Procedure Mismatch;
	    External;
	Function TypeCheck(T1, T2 : TypePtr) : Boolean;
	    External;

Function DeclVar(ob : IDObject) : IDPtr;
    forward;

Procedure ReformArgs(ProcID : IDPtr);

{
	This is the first in a series of routines that assigns the
proper addresses to procedure or function arguments.
}

var
    TotalSize	: Integer;
    ID		: IDPtr;
begin
    ID := ProcID^.Param;
    if ProcID^.Level = 1 then
	TotalSize := 8
    else
	TotalSize := 12;
    While ID <> Nil do begin
	if ID^.Object = ValArg then begin
	    TotalSize := TotalSize + ID^.VType^.Size;
	    if Odd(TotalSize) then
		TotalSize := Succ(TotalSize);
	end else
	    TotalSize := TotalSize + 4;
	ID := ID^.Next;
    end;
    ID := ProcID^.Param;
    while ID <> Nil do begin
	if ID^.Object = ValArg then begin
	    TotalSize := TotalSize - ID^.VType^.Size;
	    if Odd(TotalSize) then begin
		if ID^.VType^.Size = 1 then begin
		    ID^.Offset := TotalSize;
		    TotalSize := Pred(TotalSize);
		end else begin
		    TotalSize := Pred(TotalSize);
		    ID^.Offset := TotalSize;
		end;
	    end else
		ID^.Offset := TotalSize;
	end else begin { RefArg }
	    TotalSize := TotalSize - 4;
	    ID^.Offset := TotalSize;
	end;
	ID := ID^.Next;
    end;
end;

Function ReformFields(ID : IDPtr) : Integer;

{
	...Determines the proper offsets of the fields, and returns the
total size of the record.
}
var
    TotalSize : Integer;
begin
    TotalSize := 0;
    while ID <> Nil do begin
	if Odd(TotalSize) and (ID^.VType^.Size <> 1) then
	    TotalSize := Succ(TotalSize);
	ID^.Offset := TotalSize;
	TotalSize := TotalSize + ID^.VType^.Size;
	ID := ID^.Next;
    end;
    ReformFields := TotalSize;
end;

Function GetRange() : TypePtr;
var
    TP		: TypePtr;
    IndexType1,
    IndexType2	: TypePtr;
    Hold,
    Lo, Hi	: Integer;
begin
    New(TP);
    TP^.Object := ob_subrange;
    Lo := ConExpr(IndexType1);
    if not Match(DotDot1) then
	error("expecting '..' here");
    Hi := ConExpr(IndexType2);
    if not TypeCmp(IndexType1, IndexType2) then begin
	Error("Incompatible range types");
	IndexType1 := BadType;
    end;
    if Lo > Hi then begin
	Error("Lower bound greater than upper bound");
	Hold := Hi;
	Hi := Lo;
	Lo := Hold;
    end;
    GetRange := AddType(ob_subrange, IndexType1, IndexType1,
			Hi, Lo, IndexType1^.Size);
end;

Function DeclArgs(ob : IDObject) : IDPtr;
    forward;

Function ReadRecord(): TypePtr;

{
	This just reads a record.
}
var
    Size   : Integer;
    TP     : TypePtr;
begin
    TP := AddType(ob_record, Nil, Nil, 0, 0, 0);
    if TypeID <> Nil then
	TypeID^.VType := TP;
    TP^.Ref := DeclArgs(field);
    if not match(end1) then
	error("Missing END of record");
    TP^.Size := ReformFields(TP^.Ref);
    ReadRecord := TP;
end;

Function ReadEnumeration(): TypePtr;

{
	This just reads enumerations and assigns them numbers
starting with zero.  The size of an enumerated type is either 1
or two bytes: Enumerations with > 127 items are contained in 2.
}

var
    Position : Integer;
    EnumType : TypePtr;
    ID	     : IDPtr;
begin
    Position := 0;
    EnumType := AddType(ob_ordinal, Nil, Nil, 0, 0, 0);
    While CurrSym = Ident1 do begin
	if FindID(SymText) <> Nil then
	    Error("Duplicate ID");
	ID := EnterStandard(SymText, constant, EnumType, st_none, Position);
	Position := Succ(Position);
	NextSymbol;
	if CurrSym <> RightParent1 then
	    if not Match(Comma1) then
		Error("Missing Comma");
    end;
    if Position <= 128 then	{ Position = # of enumerations + 1 }
	EnumType^.Size := 1
    else
	EnumType^.Size := 2;
    NeedRightParent;
    ReadEnumeration := EnumType;
end;

    Function ReadType : TypePtr;
	Forward;

Function DefineArray : TypePtr;
var
    TP, TP2,
    LastType : TypePtr;
    ID : IDPtr;

    Function DeclareDimension : TypePtr;
    var
	TP : TypePtr;
    begin
	TP := GetRange;
	with TP^ do begin
	    Ref := SubType;
	    Object := ob_array;
	    if Match(Comma1) then
		SubType := DeclareDimension
	    else
		SubType := Nil;
	end;
	DeclareDimension := TP;
    end;

    Procedure FixArraySize(TP : TypePtr);
    begin
	if TP^.Object = ob_array then begin
	    FixArraySize(TP^.SubType);
	    TP^.Size := TP^.SubType^.Size * (TP^.Upper - TP^.Lower + 1);
	end;
    end;

begin
    if Match(LeftBrack1) then begin
	TP := DeclareDimension;
	LastType := TP;
	While LastType^.SubType <> Nil do
	    LastType := LastType^.SubType;   { Get the last array dim }
	if not Match(RightBrack1) then
	    error("Expecting a right bracket");
    end else if CurrSym = Ident1 then begin
	ID := FindID(SymText);
	NextSymbol;
	if ID = Nil then begin
	    error("Unknown ID");
	    TP := BadType;
	end else if ID^.Object <> obtype then begin
	    error("Expecting a type");
	    TP := BadType;
	end else if ID^.VType^.Object <> ob_subrange then begin
	    error("Expecting a range");
	    TP := BadType;
	end else
	    TP := ID^.VType;
	New(TP2);
	TP2^ := TP^;
	TP := TP2;
	TP^.Next := CurrentBlock^.FirstType;
	CurrentBlock^.FirstType := TP;
	LastType := TP;
    end else begin
	error("Expecting range");
	New(TP);
	TP^ := BadType^;
	LastType := TP;
    end;
    TP^.Object := ob_array;
    if not match(of1) then
	error("expecting OF");
    LastType^.SubType := ReadType;
    FixArraySize(TP);
    DefineArray := TP;
end;

Function ReadType(): TypePtr;

{
	This is a bit of a monster function, but needs yet more
stuff (like ranges).  The pointer part should have support for a
pointer to an as-yet-unknown-id.  This routine returns the index of
the type produced by the type declaration.  Note that I use the
same routine almost wherever I need a type, which is why you can
use a full type description most places.
}

var
    TP	: TypePtr;
    ID  : IDPtr;
begin
    if currsym = ident1 then begin
	ID := FindID(symtext);
	if ID = Nil then begin
	    Error("Unknown ID");
	    TP := BadType;
	    NextSymbol;
	end else if ID^.Object = obtype then begin
	    TP := ID^.VType;
	    NextSymbol;
	end else if ID^.Object = constant then
	    TP := GetRange()
	else begin
	    Error("Expecting a TYPE");
	    TP := BadType;
	    NextSymbol;
	end;
    end else if (CurrSym = Numeral1) or (CurrSym = Apostrophe1) then
	TP := GetRange()
    else if match(carat1) then begin
	TP := ReadType();
	TP := AddType(ob_pointer, TP, nil, 0, 0, 4);
    end else if match(leftparent1) then
	TP := ReadEnumeration()
    else if match(array1) then
	TP := DefineArray
    else if match(record1) then begin
	TP := ReadRecord();
    end else if match(file1) then begin
	if not match(of1) then
	    error("expecting OF");
	TP := ReadType();
	TP := AddType(ob_file, TP, nil, TP^.Size, 0, 32);
    end else begin
	error("unknown type of thing");
	TP := BadType;
    end;
    readtype := TP;
end;

Procedure DeclType;

{
	This handles a type declaration block.
}
begin
    While CurrSym = ident1 do begin
	if CheckID(SymText) <> nil then
	    error("duplicate id");
	TypeID := EnterStandard(SymText, obtype, BadType, st_none, 0);
	NextSymbol;
	if not Match(equal1) then
	    Error("expecting '=' here");
	TypeID^.VType := ReadType();
	ns;
    end;
    TypeID := Nil;
end;

Function DeclArgs(ob : IDObject) : IDPtr;

    Procedure DeclArgList(var VarList : IDPtr; ob : IDObject);
    var
	ID,
	RunID : IDPtr;
    begin
	if CurrSym = Ident1 then begin
	    if CheckIDList(SymText, VarList) then
		error("Duplicate Parameter Name");
	    New(ID);
	    ID^.Name := EnterSpell(SymText);
	    ID^.Object := ob;
	    ID^.Next := Nil;
	    if VarList = Nil then
		VarList := ID
	    else begin
		RunID := VarList;
		while RunID^.Next <> Nil do
		    RunID := RunID^.Next;
		RunID^.Next := ID;
 	    end;
	    NextSymbol;
	    if Match(Comma1) then begin
		DeclArgList(VarList, ob);
		ID^.VType := ID^.Next^.VType;
	    end else begin
		if not Match(colon1) then
		    error("Expecting a colon");
		ID^.VType := ReadType();
	    end;
	    if (ob = valarg) and (ID^.VType^.Object = ob_file) then
		error("Files must be VAR parameters");
	end;
    end;

var
    ID : IDPtr;

begin
    ID := Nil;
    if ob = field then begin
	While CurrSym = Ident1 do begin
	    DeclArgList(ID, field);
	    ns;
	end;
    end else begin
	while (CurrSym = Ident1) or (CurrSym = Var1) do begin
	    if Match(Var1) then
		DeclArgList(ID, refarg)
	    else
		DeclArgList(ID, valarg);
	    if CurrSym <> RightParent1 then
		ns;
	end;
    end;
    DeclArgs := ID;
end;
		    		
Function DeclVar(ob : IDObject) :  IDPtr;

{
	This is used to declare a local or global variable.
}

var
    ID,
    NextID : IDPtr;
    TP	: TypePtr;
begin
    if currsym = ident1 then begin
	if CheckID(symtext) <> Nil then
	    error("Duplicate id");
	ID := EnterStandard(symtext, ob, BadType, StandardStorage, 0);
	NextSymbol;
	if match(comma1) then begin
	    NextID := DeclVar(ob);
	    ID^.VType := NextID^.VType;
	end else begin
	    if not match(colon1) then
		error("expecting :");
	    ID^.VType := ReadType();
	end;
	if ob = local then begin
	    StackSpace := StackSpace + ID^.VType^.Size;
	    if Odd(StackSpace) and (ID^.VTYpe^.Size <> 1) then
		StackSpace := Succ(StackSpace);
	    ID^.Offset := -StackSpace;
	end;
    end else begin
	error("expecting an identifier");
	if CurrSym = Colon1 then
	    TP := ReadType()
	else if match(colon1) then
	    TP := ReadType();
    end;
    DeclVar := ID;
end;

Procedure VarDeclarations;

{
	This handles a variable declaration block.
}
var
    ID	: IDPtr;
begin
    While CurrSym = ident1 do begin
	if CurrentBlock^.Level = 1 then begin
	    ID := DeclVar(global);
	    ns;
	end else begin
	    ID := DeclVar(local);
	    ns;
	end;
    end;
end;

Function TypedConstant(TP : TypePtr) : Integer;
var
    DefineIt : Boolean;

    Function TypedOrdinal(TP : TypePtr) : Integer;
    var
	ExprType : TypePtr;
	ExprVal  : Integer;
    begin
	ExprVal := ConExpr(ExprType);
	if not TypeCheck(ExprType, TP) then
	    Mismatch;
	TypedOrdinal := ExprVal;
    end;

    Function TypedArray(TP : TypePtr) : Integer;
    var
	ExprType : TypePtr;
	ExprVal  : Integer;
	Column   : Short;
	Current  : Integer;
    begin
	if TypeCheck(TP^.SubType, CharType) then begin { special }
	    ExprVal := ConExpr(ExprType);
	    if not TypeCheck(ExprType, TP) then
		MisMatch;
	    LitPtr := ExprVal;
	    TypedArray := 1;
	end else if TP^.SubType^.Object = ob_ordinal then begin
	    NeedLeftParent;
	    Column := 0;
	    for Current := 1 to TP^.Upper - TP^.Lower + 1 do begin
		ExprVal := ConExpr(ExprType);
		if not TypeCheck(ExprType, TP^.SubType) then
		    Mismatch;
		if CurrSym <> RightParent1 then
		    if not Match(Comma1) then
			Error("Expecting a comma");
	    end;
	    NeedRightParent;
	    TypedArray := 1;
	end else begin
	    NeedLeftParent;
	    for Current := 1 to TP^.Upper - TP^.Lower + 1 do begin
		ExprVal := TypedConstant(TP^.SubType);
		if CurrSym <> RightParent1 then
		    if not match(Comma1) then
			Error("Expecting a comma");
	    end;
	    NeedRightParent;
	    TypedArray := 1;
	end;
    end;

    Function TypedPointer(TP : TypePtr) : Integer;
    var
	ID : IDPtr;
	ExprVal : Integer;
	ExprType : TypePtr;
    begin
	if Match(At1) then begin
	    if CurrSym = Ident1 then begin
		ID := FindID(SymText);
		if (ID^.Object = Global) or
		   (ID^.Object = typed_const) then begin
		    if not TypeCheck(TP^.SubType, ID^.VType) then
			MisMatch;
		end else
		    Error("Expecting a global identifier");
		NextSymbol;
	    end else
		Error("Expecting an identifier");
	    TypedPointer := 1;
	end else begin
	    ExprVal := ConExpr(ExprType);
	    if not TypeCheck(ExprType, TP) then
		Mismatch;
	    TypedPointer := ExprVal;
	end;
    end;

    Function TypedRecord(TP : TypePtr) : Integer;
    var
	ID : IDPtr;
	ExprVal : Integer;
    begin
	NeedLeftParent;
	ID := TP^.Ref;
	while ID <> Nil do begin
	    ExprVal := TypedConstant(ID^.VType);
	    ID := ID^.Next;
	    if ID <> Nil then
		if not Match(Comma1) then
		    Error("Expecting a comma");
	end;
	NeedRightParent;
	TypedRecord := 1;
    end;

    Function TypedReal : Integer;
    var
	ExprVal : Integer;
	ExprType : TypePtr;
    begin
	ExprVal := ConExpr(ExprType);
	if not TypeCheck(ExprType, RealType) then
	    MisMatch;
	TypedReal := ExprVal;
    end;

begin
    DefineIt := StandardStorage <> st_external;
    case TP^.Object of
	ob_ordinal,
	ob_subrange : TypedConstant := TypedOrdinal(TP);
	ob_array   : TypedConstant := TypedArray(TP);
	ob_pointer : TypedConstant := TypedPointer(TP);
	ob_record  : TypedConstant := TypedRecord(TP);
	ob_real    : TypedConstant := TypedReal;
    else
	Error("No typed constants allowed for this type");
    end;
end;

Procedure DeclConst;

{
	This handles a const declaration block.  The grunt work is
does by conexpr() in expression.p, which is the routine to look at
if you want to improve constant declarations.
}
var
    ID : IDPtr;
    BackName : String;
    TP : TypePtr;
begin
    While CurrSym = Ident1 do begin
	if CheckID(SymText) <> Nil then
	    Error("Duplicate ID");
	ID := EnterStandard(SymText, constant, Nil, st_none, 0);
	BackName := ID^.Name;
	ID^.Name := "";	{ So the ID can't be used in the expression }
	NextSymbol;
	if Match(Colon1) then begin
	    ID^.VType := ReadType;
	    if not Match(Equal1) then
		Error("Missing =");
	    ID^.Offset := TypedConstant(ID^.VType);
	    ID^.Name := BackName;
	    ID^.Object := typed_const;
	    if StandardStorage <> st_external then
		ID^.Storage := st_initialized
	    else
		ID^.Storage := st_external;
	end else begin
	    if not Match(Equal1) then
		Error("Expecting =");
	    ID^.Offset := ConExpr(TP);
	    ID^.VType := TP;
	    ID^.Name := BackName;
	end;
	ns;
    end;
end;

Procedure DeclLabel;
{
	This routine accepts a list of identifiers to be used as
	labels in the program.  Standard Pascal's labels are four
	digit numbers, but I didn't want to mess with that.
}
var
    ID : IDPtr;
begin
    while CurrSym = Ident1 do begin
	ID := EnterStandard(SymText, lab, Nil, st_none, 0);
	NextSymbol;
	if not Match(Comma1) then begin
	    ns;
	    return;
	end;
    end;
    Error("Expecting an identifier");
end;

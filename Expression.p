External;

{
	Expression.p (of PCQ Pascal)
	Copyright (c) 1989 Patrick Quaid

	This module only has two parts.  The first is expression(),
which handles all run-time expressions.  The other one is
conexpr(), which handles all constant expressions.
}

{$O-}
{$I "Pascal.i"}

	Function TypeCheck(l, r : TypePtr) : Boolean;
	    external;
	procedure NextSymbol;
	    external;
	procedure Error(s : string);
	    external;
	Procedure Abort;
	    external;
	Procedure ReadChar;
	    external;
	Function  EndOfFile() : Boolean;
	    external;
	Procedure CallFunc(f : IDPtr);
	    external;
	Procedure StdFunc(f : IDPtr);
	    external;
	Function Match(s : Symbols): Boolean;
	    external;
	Function FindID(s : string) : IDPtr;
	    external;
	Function FindWithField(s : String) : IDPtr;
	    External;
	Procedure PrintLabel(l : Integer);
	    external;
	Function GetLabel() : Integer;
	    external;
	Function Selector(f : IDPtr) : TypePtr;
	    external;
	Function GetFramePointer(Ref : Integer) : Short;
	    External;
	Procedure Mismatch;
	    external;
	Procedure NoLeftParent;
	    external;
	Procedure NoRightParent;
	    external;
	Procedure NeedNumber;
	    external;
	Procedure NeedRightParent;
	    external;
	Procedure NeedLeftParent;
	    external;
	Function Suffix(s : Integer) : Char;
	    external;
	Function NumberType(l : TypePtr) : Boolean;
	    external;
	Function BaseType(b : TypePtr): TypePtr;
	    external;
	Function SimpleType(t : TypePtr) : Boolean;
	    external;
	Procedure WriteHex(h : Integer);
	    external;
	Procedure PromoteType(var f : TypePtr; o : TypePtr; r : Short);
	    external;
	Procedure PushLongD0;
	    external;
	Procedure PushLongD1;
	    External;
	Procedure PopLongD1;
	    external;
	Procedure PopLongA1;
	    External;
	Procedure PopStackSpace(amount : Integer);
	    External;
	Function EnterStandard(	st_Name : String;
				st_Object : IDObject;
				st_Type : TypePtr;
				st_Storage : IDStorage;
				st_Offset : Integer) : IDPtr;
	    external;

Function Expression() : TypePtr;
    forward;

Procedure IncLitPtr;
begin
    if LitPtr >= LiteralSize then begin
	Writeln('Too much literal data');
	Abort;
    end else
	LitPtr := Succ(LitPtr);
end;

Function ReadLit(Quote : Char) : TypePtr;

{
	This routine reads a literal array of char into the literal
array.
}
var
    Length : Short;
begin
    Length := 1;
    while (currentchar <> Quote) and (currentchar <> chr(10)) do begin
	if CurrentChar = '\\' then begin
	    ReadChar;
	    if CurrentChar = Chr(10) then
		Error("Missing closing quote");
	    case CurrentChar of
	      'n' : Litq[LitPtr] := Chr(10);
	      't' : Litq[LitPtr] := Chr(9);
	      '0' : Litq[LitPtr] := Chr(0);
	      'b' : Litq[LitPtr] := Chr(8);
	      'e' : Litq[LitPtr] := Chr(27);
	      'c' : Litq[LitPtr] := Chr($9B);
	      'a' : Litq[LitPtr] := Chr(7);
	      'f' : Litq[LitPtr] := Chr(12);
	      'r' : Litq[LitPtr] := Chr(13);
	      'v' : Litq[LitPtr] := Chr(11);
	    else
		Litq[LitPtr] := CurrentChar;
	    end;
	end else
	    Litq[LitPtr] := CurrentChar;
	if CurrentChar <> Chr(10) then begin
	    ReadChar;
	    if currentchar = chr(10) then
		error("Missing closing quote");
	end;
	Length := Succ(Length);
	IncLitPtr;
    end;
    ReadChar;
    NextSymbol;
    if Quote = '"' then begin
	LitQ[LitPtr] := Chr(0);
	IncLitPtr;
	ReadLit := StringType;
    end else begin
	LiteralType^.Upper := Length - 1;
	ReadLit := LiteralType;
    end;
end;

Function LoadValue(ID : IDPtr) : TypePtr;
var
    TP : TypePtr;
    Reg : Short;
begin
    TP := ID^.VType;
    case ID^.Object of
      typed_const,
      global : if ID^.Level <= 1 then begin
		   if SimpleType(TP) then
			writeln(OutFile,"\tmove.", Suffix(TP^.Size),
					"\t_", ID^.Name, ',d0')
		   else
			Writeln(OutFile, "\tmove.l\t#_", ID^.Name, ',d0');
		end else begin
		   if SimpleType(TP) then
			writeln(OutFile, '\tmove.', Suffix(TP^.Size), '\t_',
					ID^.Name, '%', ID^.Unique, ',d0')
		   else
			writeln(OutFile, '\tmove.l\t#_', ID^.Name, '%',
					ID^.Unique, ',d0');
		end;
      local,
      valarg : begin
		   Reg := GetFramePointer(ID^.Level);
		   if SimpleType(TP) then
			Writeln(OutFile, "\tmove.", Suffix(TP^.Size),
					Chr(9), ID^.Offset, '(a', Reg, '),d0')
		   else begin
			Writeln(OutFile, "\tlea\t", ID^.Offset, '(a', Reg, '),a0');
			Writeln(OutFile, "\tmove.l\ta0,d0");
		   end;
	       end;
      refarg : begin
		   Reg := GetFramePointer(ID^.Level);
		   if SimpleType(TP) then begin
			Writeln(OutFile, "\tmove.l\t", ID^.Offset, '(a', Reg, '),a0');
			Writeln(OutFile, "\tmove.", Suffix(TP^.Size), "\t(a0),d0");
		   end else
			writeln(OutFile, "\tmove.l\t", ID^.Offset, '(a', Reg, '),d0')
	       end;
    else begin
	    Error("expecting a variable or function");
	    TP := BadType;
	 end;
    end;
    LoadValue := TP;
end;

Procedure ReadBadArgs;
var
    TP : TypePtr;
begin
    if Match(LeftParent1) then begin
	While (CurrSym <> RightParent1) and (CurrSym <> SemiColon1) and
		(Not EndOfFile()) do begin
	    TP := Expression();
	    if CurrSym <> RightParent1 then
		if not Match(Comma1) then
		    Error("Expecting a comma");
	end;
	NeedRightParent;
    end;
end;

Function IDFactor(ID : IDPtr) : TypePtr;

{
	idfactor() is another nightmare function.  It does whatever
is necessary when the compiler runs across an identifer in an
expression, which almost always means loading a value into d0.
}

var
    TP : TypePtr;
begin
    if ID = nil then begin
	Error("Unknown ID");
	ID := EnterStandard(SymText, global, BadType, st_none, 1);
	NextSymbol;
	ReadBadArgs;
	IDFactor := BadType;
    end else begin
	case ID^.Object of
	  func : begin
		    CallFunc(ID);
		    IDFactor := ID^.VType;
		 end;
	  stanfunc : begin
		    StdFunc(ID);
		    IDFactor := ID^.VType;
		 end;
	  obtype : begin
		    NeedLeftParent;
		    TP := Expression();
		    NeedRightParent;
		    IDFactor := ID^.VType;
		 end;
	  constant : begin
			TP := ID^.VType;
			if TP^.Object = ob_ordinal then { Integer, Short, etc. }
			    writeln(OutFile, "\tmove.l\t#",
				    ID^.Offset, ',d0')
			else if TP^.Object = ob_pointer then begin
			 { String or Nil }
			    if TP = StringType then begin
				write(OutFile, "\tmove.l\t#");
				PrintLabel(litlab);
				writeln(OutFile, '+', ID^.Offset, ',d0');
			    end else
				writeln(OutFile, "\tmove.l\t#", ID^.Offset, ',d0');
			end else if TP^.Object = ob_array then begin
			  { Must be charray }
			    write(OutFile, "\tmove.l\t#");
			    PrintLabel(litlab);
			    writeln(OutFile, '+', ID^.Offset, ',d0');
			end else if TP^.Object = ob_real then begin
			    Write(Outfile, "\tmove.l\t#");
			    writehex(ID^.Offset);
			    writeln(OutFile, ',d0');
			end;
			IDFactor := TP;
		    end;
	else begin { Else clause of CASE, remember }
		TP := Selector(ID);
		if TP <> Nil then begin
		    if SimpleType(TP) then
			writeln(OutFile, "\tmove.",
				Suffix(TP^.Size), "\t(a0),d0")
		    else
			writeln(OutFile, "\tmove.l\ta0,d0");
		end else
		    TP := LoadValue(ID);
		IDFactor := TP;
	     end;
	end;
    end;
end;

Function Factor() : TypePtr;

{
	This is the lowest level of the expression parsing
business.  It's pretty standard stuff.  All these expression
routines return a pointer to the type they're working on.
}
var
    ID : IDPtr;
    TP, TP2 : TypePtr;
    LitSpot : Integer;
begin
    if CurrSym = Ident1 then begin
	ID := FindWithField(SymText);
	if ID = Nil then
	    ID := FindID(SymText);
	nextsymbol;
	Factor := IDFactor(ID);
    end else if CurrSym = Numeral1 then begin
	Write(OutFile, "\tmove.l\t#");
	if abs(symloc) > 1000000 then begin
	    writehex(symloc);
	    writeln(OutFile, ',d0');
	end else
	    writeln(OutFile, symloc, ',d0');
	nextsymbol;
	Factor := IntType;
   end else if CurrSym = RealNumeral1 then begin
	write(OutFile, "\tmove.l\t#");
	writehex(integer(RealValue));
	writeln(OutFile, ',d0');
	nextsymbol;
	Factor := RealType;
    end else if Currsym = Apostrophe1 then begin
	LitSpot := LitPtr;
	TP := ReadLit(Chr(39));
	if TP^.Upper = 1 then begin
	    LitPtr := Pred(LitPtr);
	    Writeln(OutFile, "\tmove.b\t#", Ord(LitQ[LitPtr]), ',d0');
	    Factor := CharType;
	end else begin
	    New(TP2);
	    TP2^ := TP^;
	    TP2^.Next := CurrentBlock^.FirstType;
	    CurrentBlock^.FirstType := TP2;
	    Write(OutFile, "\tmove.l\t#");
	    PrintLabel(LitLab);
	    Writeln(OutFile, '+', LitSpot, ',d0');
	    Factor := TP2;
	end;
    end else if CurrSym = Quote1 then begin
	Write(OutFile, "\tmove.l\t#");
	PrintLabel(LitLab);
	Writeln(OutFile, '+', LitPtr, ',d0');
	Factor := ReadLit('"');
    end else if match(not1) then begin
	TP := Factor();
	if TP^.Object <> ob_ordinal then begin
	    error("NOT applies only to ordinal values");
	    Factor := BadType;
	end else
	    writeln(OutFile, "\tnot.", Suffix(TP^.Size), "\td0");
	Factor := TP;
    end else if Match(LeftParent1) then begin
	TP := Expression();
	NeedRightParent;
	Factor := TP;
    end else begin
	error("Unrecognizable expression");
	NextSymbol;
	Factor := BadType;
    end;
end;
	
Function Operate(LeftType, RightType : TypePtr; Operator : Symbols) : TypePtr;

{
	This routine handles the actual code generation for the
various operations.  This handles all the math stuff, even though
it's called by different routines.
}

var
    Suffer : Char;
begin
    if not TypeCheck(LeftType, RightType) then begin
	Mismatch;
	Operate := BadType;
    end else begin
	PopLongD1;
	if (Operator = And1) or (Operator = Or1) or (Operator = Xor1) or
	   (Operator = Shl1) or (Operator = Shr1) then begin
	    if LeftType^.Object <> ob_ordinal then
		Error("Need ordinal expression")
	    else if LeftType^.size <> RightType^.Size then begin
		PromoteType(lefttype, RightType, 1);
		PromoteType(RightType, lefttype, 0);
	    end;
	end else begin
	    if NumberType(LeftType) or (LeftType = RealType) then begin
		PromoteType(LeftType, RightType, 1);
		PromoteType(RightType, LeftType, 0);
	    end else
		NeedNumber;
	end;
	Suffer := Suffix(LeftType^.Size);
	if Operator = Asterisk1 then begin
	    if LeftType = ByteType then begin
		PromoteType(LeftType, ShortType, 1);
		PromoteType(RightType, ShortType, 0);
	    end;
	    if LeftType = ShortType then begin
		writeln(OutFile, "\tmuls\td1,d0");
		Operate := IntType;
	    end else if LeftType = IntType then begin
		PushLongD0;
		PushLongD1;
		writeln(OutFile, "\tjsr\t_p%lmul");
		PopStackSpace(8);
		Operate := Inttype;
	    end else begin
		writeln(OutFile, "\tmove.l\t_p%MathBase,a6");
		writeln(OutFile, "\tjsr\t-78(a6)");
		Operate := RealType;
	    end;
	end else if Operator = Div1 then begin
	    if LeftType <> IntType then
		PromoteType(LeftType, IntType, 1);
	    if RightType = ByteType then
		PromoteType(RightType, ShortType, 0);
	    if RightType = ShortType then begin
		writeln(OutFile, "\tdivs\td0,d1");
		writeln(OutFile, "\tmove.l\td1,d0");
		Operate := ShortType;
	    end else if RightType = IntType then begin
		PushLongD0;
		PushLongD1;
		writeln(OutFile, "\tjsr\t_p%ldiv");
		PopStackSpace(8);
		Operate := IntType;
	    end else begin
		Error("No reals allowed for DIV");
		Operate := BadType;
	    end;
	end else if Operator = Mod1 then begin
	    if LeftType <> IntType then
		PromoteType(LeftType, IntType, 1);
	    if RightType = ByteType then
		PromoteType(RightType, ShortType, 0);
	    if RightType = ShortType then begin
		writeln(OutFile, "\tdivs\td0,d1");
		writeln(OutFile, "\tmove.l\td1,d0");
		writeln(OutFile, "\tswap\td0");
		Operate := ShortType;
	    end else if RightType = IntType then begin
		PushLongD0;
		PushLongD1;
		writeln(OutFile, "\tjsr\t_p%lrem");
		PopStackSpace(8);
		Operate := IntType;
	    end else begin
		Error("No reals allowed for MOD");
		Operate := BadType;
	    end;
	end else if Operator = And1 then begin
	    writeln(OutFile, "\tand.", suffer, "\td1,d0");
	    Operate := LeftType;
	end else if Operator = Shl1 then begin
	    writeln(OutFile, "\tand.w\t#31,d0");
	    if LeftType^.Size = 1 then
		Writeln(OutFile, '\tand.l\t#$FF,d1')
	    else if LeftType^.Size = 2 then
		Writeln(OutFile, '\tand.l\t#$FFFF,d1');
	    writeln(OutFile, "\tasl.", Suffer, "\td0,d1");
	    writeln(OutFile, "\tmove.", Suffer, "\td1,d0");
	    Operate := LeftType;
	end else if Operator = Shr1 then begin
	    writeln(OutFile, "\tand.w\t#31,d0");
	    if LeftType^.Size = 1 then
		Writeln(OutFile, '\tand.l\t#$FF,d1')
	    else if LeftType^.Size = 2 then
		Writeln(OutFile, '\tand.l\t#$FFFF,d1');
	    writeln(OutFile, "\tlsr.", Suffer, "\td0,d1");
	    writeln(OutFile, "\tmove.", Suffer, "\td1,d0");
	    Operate := LeftType;
	end else if Operator = Plus1 then begin
	    if LeftType = RealType then begin
		writeln(OutFile, "\tmove.l\t_p%MathBase,a6");
		writeln(OutFile, "\tjsr\t-66(a6)");
	    end else
		writeln(OutFile, "\tadd.", Suffer, "\td1,d0");
	    Operate := LeftType;
	end else if Operator = Minus1 then begin
	    writeln(OutFile, "\texg\td0,d1");
	    if LeftType = RealType then begin
		writeln(OutFile, "\tmove.l\t_p%MathBase,a6");
		writeln(OutFile, "\tjsr\t-72(a6)");
	    end else
		writeln(OutFile, "\tsub.", Suffer, "\td1,d0");
	    Operate := LeftType;
	end else if Operator = RealDiv1 then begin
	    PromoteType(LeftType, RealType, 1);
	    PromoteType(RightType, RealType, 0);
	    writeln(OutFile, "\texg\td0,d1");
	    writeln(OutFile, "\tmove.l\t_p%MathBase,a6");
	    writeln(OutFile, "\tjsr\t-84(a6)");
	    Operate := RealType;
	end else if Operator = Or1 then begin
	    writeln(OutFile, "\tor.", suffer, "\td1,d0");
	    Operate := LeftType;
	end else if Operator = Xor1 then begin
	    writeln(OutFile, "\teor.", Suffer, "\td1,d0");
	    Operate := LeftType;
	end;
    end;
end;

Function Term() : TypePtr;

{
	Again, pretty standard stuff.  This handles the level of
precedence that includes *, div, mod, /, and, and unary minus.
}

var
    LeftType  : TypePtr;
    stay : Boolean;
begin
    if Match(Minus1) then begin
	LeftType := Factor();
	if LeftType = RealType then begin
	    writeln(OutFile, "\tmove.l\t_p%MathBase,a6");
	    writeln(OutFile, "\tjsr\t-60(a6)");
	end else if TypeCheck(LeftType, IntType) then
	    writeln(OutFile, "\tneg.", suffix(LeftType^.Size),"\td0")
	else begin
	    Error("Need numeric type for unary minus");
	    LeftType := BadType;
	end;
    end else
	LeftType := Factor();
    stay := true;
    while stay do begin
	if Match(Asterisk1) then begin
	    PushLongD0;
	    LeftType := Operate(LeftType, Factor(), asterisk1);
	end else if Match(Div1) then begin
	    PushLongD0;
	    LeftType := Operate(LeftType, Factor(), div1);
	end else if match(realdiv1) then begin
	    PushLongD0;
	    LeftType := Operate(LeftType, Factor(), realdiv1);
	end else if match(mod1) then begin
	    PushLongD0;
	    LeftType := Operate(LeftType, Factor(), mod1);
	end else if match(and1) then begin
	    PushLongD0;
	    LeftType := Operate(LeftType, Factor(), and1);
	end else if Match(Shl1) then begin
	    PushLongD0;
	    LeftType := Operate(LeftType, Factor(), Shl1);
	end else if Match(Shr1) then begin
	    PushLongD0;
	    LeftType := Operate(LeftType, Factor(), Shr1);
	end else
	    stay := false;
    end;
    Term := LeftType;
end;

Function Simple() : TypePtr;

{
	This is similar to term(), except it handles plus, minus,
and or.
}

var
    LeftType	: TypePtr;
    Stay	: Boolean;
begin
    LeftType := Term();
    Stay := True;
    while Stay do begin
	if Match(Plus1) then begin
	    PushLongD0;
	    LeftType := Operate(LeftType, Term(), plus1);
	end else if match(minus1) then begin
	    PushLongD0;
	    LeftType := Operate(LeftType, Term(), minus1);
	end else if match(or1) then begin
	    PushLongD0;
	    LeftType := Operate(LeftType, Term(), or1);
	end else if Match(Xor1) then begin
	    PushLongD0;
	    LeftType := Operate(LeftType, Term(), Xor1);
	end else
	    Stay := false;
    end;
    Simple := LeftType;
end;

Function ExprRelOp(LeftType : TypePtr; Operation : Symbols) : TypePtr;

{
	This handles the code for the various relative comparisons
(like <, >, <=, etc.)
}

var
    RightType	: TypePtr;
begin
    NextSymbol;
    PushLongD0;
    RightType := Simple();
    if not TypeCheck(LeftType, RightType) then begin
	Mismatch;
	ExprRelOp := BadType;
    end else if not SimpleType(LeftType) then begin
	error("only simple types allowed in inequalities");
	ExprRelOp := BadType;
    end else begin
	PopLongD1;
	if NumberType(LeftType) or (LeftType = RealType) then begin
	    PromoteType(LeftType, RightType, 1);
	    PromoteType(RightType, LeftType, 0);
	end;
	if LeftType = RealType then begin
	    writeln(OutFile, "\texg\td0,d1");
	    writeln(OutFile, "\tmove.l\t_p%MathBase,a6");
	    writeln(OutFile, "\tjsr\t-42(a6)");
	end else
	    writeln(OutFile, "\tcmp.", Suffix(LeftType^.Size), "\td0,d1");
	if Operation = Less1 then
	    writeln(OutFile, "\tslt\td0")
	else if Operation = greater1 then
	    writeln(OutFile, "\tsgt\td0")
	else if Operation = notless1 then
	    writeln(OutFile, "\tsge\td0")
	else if Operation = notgreater1 then
	    writeln(OutFile, "\tsle\td0");
	ExprRelOp := BoolType;
    end;
end;

Function ExprEqOp(LeftType : TypePtr; Operation : Symbols) : TypePtr;

{
	This generates code for comparisons of equality.  The main
difference between this and the previous routine is that Pascal
allows the comparison of complex types, so this routine has to
handle that.
}

var
    RightType	: TypePtr;
    lab		: Integer;
    TotalSize	: Integer;
begin
    NextSymbol;
    PushLongD0;
    RightType := Simple();
    if not TypeCheck(LeftType, RightType) then begin
	Mismatch;
	ExprEqOp := BadType;
    end else begin
	TotalSize := LeftType^.Size;
	if not SimpleType(LeftType) then begin
	    writeln(OutFile, "\tmove.l\td0,a0");
	    PopLongA1;
	    writeln(OutFile, "\tmove.b\t#-1,d0");
	    writeln(OutFile, "\tmove.l\t#", totalsize - 1, ",d1");
	    lab := GetLabel();
	    PrintLabel(lab);
	    writeln(OutFile, "\tmove.b\t(a0)+,d2");
	    writeln(OutFile, "\tcmp.b\t(a1)+,d2");
	    writeln(OutFile, "\tseq\td2");
	    writeln(OutFile, "\tand.b\td2,d0");
	    write(OutFile, "\tdbra\td1,");
	    PrintLabel(lab);
	    writeln(OutFile);
	    writeln(OutFile, "\ttst.b\td0");
	    if Operation = notequal1 then
		writeln(OutFile, "\tseq\td0");
	end else begin
	    PopLongD1;
	    if NumberType(LeftType) or (LeftType = RealType) then begin
		promotetype(LeftType, RightType, 1);
		promotetype(RightType, LeftType, 0);
	    end;
	    if LeftType = RealType then begin
		writeln(OutFile, "\tmove.l\t_p%MathBase,a6");
		writeln(OutFile, "\tjsr\t-42(a6)");
	    end else
		writeln(OutFile, "\tcmp.", Suffix(LeftType^.Size), "\td0,d1");
	    if Operation = equal1 then
		writeln(OutFile, "\tseq\td0")
	    else
		writeln(OutFile, "\tsne\td0");
	end;
	ExprEqOp := BoolType;
    end;
end;

Function Expression() : TypePtr;

{
	This is the main part of expression().  If there weren't
any errors, the result of the expression will be in d0.
}

var
    LeftType : TypePtr;
    stay : Boolean;
begin
    LeftType := Simple();
    stay := True;
    while stay do begin
	case CurrSym of
	  equal1,
	  notequal1 : LeftType := ExprEqOp(LeftType, CurrSym);
	  less1,
	  greater1,
	  notless1,
	  notgreater1 : LeftType := ExprRelOp(LeftType, CurrSym);
	else
	  stay := False;
	end;
    end;
    Expression := LeftType;
end;

Function ConExpr(VAR ConType : TypePtr) : Integer;
    forward;

Function ConPrimary(VAR ConType : TypePtr) : Integer;

{
	These routines are very similar to the other expression
routines, but are much simpler.  They return the running value of
the expression.  The type is returned in the reference parameter.
This routine should handle type conversions and standard functions.
}

var
    Result	: Integer;
    ID		: IDPtr;
    TP		: TypePtr;
begin
    if Match(LeftParent1) then begin
	Result := ConExpr(contype);
	NeedRightParent;
	ConPrimary := Result;
    end else if CurrSym = Numeral1 then begin
	Result := Symloc;
	NextSymbol;
	ConType := IntType;
	ConPrimary := Result;
    end else if CurrSym = RealNumeral1 then begin
	Result := Integer(RealValue);
	NextSymbol;
	ConType := RealType;
	ConPrimary := Result;
    end else if Match(Minus1) then begin
	Result := ConPrimary(ConType);
	if ConType = RealType then
	    ConPrimary := Integer(-Real(Result))
	else if NumberType(ConType) then
	    ConPrimary := -Result
	else begin
	    NeedNumber;
	    ConPrimary := 1;
	end;
    end else if Currsym = Apostrophe1 then begin
	Result := LitPtr;
	ConType := ReadLit(Chr(39));
	if ConType^.Upper = 1 then begin
	    LitPtr := Pred(LitPtr);
	    Result := Ord(LitQ[LitPtr]);
	    ConType := CharType;
	end else begin
	    New(TP);
	    TP^ := ConType^;
	    TP^.Next := CurrentBlock^.FirstType;
	    CurrentBlock^.FirstType := TP;
	    ConType := TP;
	end;
	ConPrimary := Result;
    end else if CurrSym = Quote1 then begin
	Result := LitPtr;
	ConType := ReadLit('"');
	ConPrimary := Result;
    end else if CurrSym = Ident1 then begin
	ID := FindID(symtext);
	if ID <> Nil then begin
	    if (ID^.Object = constant) or (ID^.Object = typed_const) then begin
		NextSymbol;
		ConType := ID^.VType;
		ConPrimary := ID^.Offset;
	    end;
	end;
	error("Expecting a constant");
	ConType := IntType;
	ConPrimary := 1;
    end else begin
	error("Unknown Constant");
	ConType := IntType;
	ConPrimary := 1;
    end;
end;

Function ConFactor(VAR ConType : TypePtr) : Integer;

{
	This handles the second level of precedence for constant
expressions.
}

var
    Result, Rightresult	: integer;
    RightType	: TypePtr;
begin
    Result := ConPrimary(ConType);
    While (CurrSym = Asterisk1) or (CurrSym = Div1) or
	  (CurrSym = RealDiv1) do begin
	if (not NumberType(ConType)) and (ConType <> RealType) then
	    NeedNumber;
	if Match(Asterisk1) then begin
	    RightResult := ConPrimary(RightType);
	    if TypeCheck(ConType, RightType) then begin
		if ConType = Realtype then
		    Result := Integer(Real(result) * Real(RightResult))
		else
		    Result := Result * RightResult
	    end else
		Mismatch;
	end else if (CurrSym = Div1) or (CurrSym = RealDiv1) then begin
	    NextSymbol;
	    Rightresult := ConPrimary(RightType);
	    if TypeCheck(ConType, RightType) then begin
		if RightResult = 0 then begin
		    error("Division by zero");
		    RightResult := 1;
		end;
		if ConType = Realtype then
		    Result := Integer(real(Result) / Real(RightResult))
		else
		    Result := Result div RightResult;
	    end else
		Mismatch;
	end;
    end;
    ConFactor := Result;
end;

Function ConExpr(VAR ConType : TypePtr) : Integer;

{
	This handles the other level of constant expressions, and
is also the outermost level.
}

var
    Result,
    RightResult	: Integer;
    Righttype	: TypePtr;
begin
    Result := ConFactor(ConType);
    while (CurrSym = Minus1) or (CurrSym = Plus1) do begin
	if (not NumberType(ConType)) and (ConType <> RealType) then
	    NeedNumber;
	if Match(Minus1) then begin
	    RightResult := ConFactor(RightType);
	    if TypeCheck(ConType, RightType) then begin
		if ConType = RealType then
		    Result := Integer(Real(Result) - Real(RightResult))
		else
		    Result := Result - Rightresult;
	    end else
		Mismatch;
	end else if Match(Plus1) then begin
	    RightResult := ConFactor(RightType);
	    if TypeCheck(ConType, RightType) then begin
		if ConType = RealType then
		    Result := Integer(Real(Result) + Real(RightResult))
		else
		    Result := Result + Rightresult;
	    end else
		Mismatch;
	end;
    end;
    ConExpr := Result;
end;

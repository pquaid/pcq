External;

{
	ID_Expr.p
}

{$O-}
{$I "Identify.i"}

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
	Function Selector(f : IDPtr) : TypePtr;
	    external;
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
	Function NumberType(l : TypePtr) : Boolean;
	    external;
	Function BaseType(b : TypePtr): TypePtr;
	    external;
	Function SimpleType(t : TypePtr) : Boolean;
	    external;
	Function EnterStandard(	st_Name : String;
				st_Object : IDObject;
				st_Type : TypePtr;
				st_Storage : IDStorage;
				st_Offset : Integer) : IDPtr;
	    external;

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

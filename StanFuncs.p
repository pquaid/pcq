external;

{
	Stanfuncs.p (of PCQ Pascal)
	Copyright (c) 1989 Patrick Quaid

	This module handles all the standard functions.
}

{$O-}
{$I "Pascal.i"}

	Function LoadAddress(): TypePtr;
	    external;
	Function Match(s : Symbols): Boolean;
	    external;
	Function TypeCheck(t1, t2 : TypePtr): Boolean;
	    external;
	Procedure Mismatch;
	    External;
	Procedure Error(s : String);
	    external;
	Function Expression() : TypePtr;
	    external;
	Function NumberType(i : TypePtr): Boolean;
	    external;
	Procedure NeedLeftParent;
	    external;
	Procedure NeedRightParent;
	    external;
	Procedure NeedNumber;
	    external;
	Function GetLabel(): Integer;
	    external;
	Procedure PrintLabel(l : Integer);
	    external;
	Function Suffix(s : Integer) : Char;
	    external;
	Procedure NextSymbol;	{ io.p }
	    external;
	Function FindID(s : String) : IDPtr;
	    external;
	Procedure PromoteType(var f : TypePtr; o : TypePtr; r : Short);
	    external;
	Procedure PushLongD0;
	    external;
	Procedure PushLongA0;
	    External;
	Procedure PopStackSpace(amount : Integer);
	    External;
	Procedure PopLongD0;
	    External;

Procedure DoOpen(NameType : TypePtr; AccessMode : Short);

{
	This routine handles both open and reopen, depending on the
AccessMode sent to it.  This is just passed on to the DOS routine.
}

var
    FileType	: TypePtr;
    RecSize	: Integer;
    SizeType	: TypePtr;
begin
    if TypeCheck(NameType, StringType) then begin
	PushLongD0;
	if Match(Comma1) then begin
	    FileType := LoadAddress();
	    if FileType^.Object = ob_file then begin
		PushLongA0;
		writeln(OutFile, "\tmove.w\t#", AccessMode, ',30(a0)');
		RecSize := FileType^.SubType^.Size;
		writeln(OutFile, "\tmove.l\t#", RecSize, ',24(a0)');
		if Match(comma1) then begin
		    SizeType := expression();
		    if not TypeCheck(SizeType, IntType) then
			mismatch;
		    writeln(OutFile, '\tmove.l\t(sp),a0');
		    writeln(OutFile, '\tmove.l\td0,20(a0)');
		end else
		    writeln(OutFile, "\tmove.l\t#128,20(a0)");
		writeln(OutFile, "\tjsr\t_p%Open");
		PopStackSpace(8);
	    end else
		Error("Need a file variable");
	end else begin
	    Error("Expecting a comma");
	    PopStackSpace(4);
	end;
    end else
	Error("Expecting a string (the file name).");
end;

Procedure DoSizeOf;

{
	This implements the SizeOf() function.  Upon entry to this
routine, we have just read the (.  We will read up to, but not
including, the ).  In this case that's just the type name.
}

var
    ID : IDPtr;
begin
    if CurrSym = Ident1 then begin
	ID := FindId(SymText);
	if ID <> Nil then begin
	    if ID^.Object = obtype then
		writeln(OutFile, "\tmove.l\t#", ID^.VType^.Size,	',d0')
	    else
		Error("Expecting a type");
	end else
	    Error("Unknown ID");
    end else
	Error("Expecting an ID");
    NextSymbol;
end;

Procedure StdFunc(ID : IDPtr);

{
	This routine handles all the standard functions.  All but
open and reopen are handled in-line.
}

var
    ExprType	: TypePtr;
    Lab		: Integer;
begin
    NeedLeftParent;
    if ID^.Offset < 15 then
	ExprType := Expression();
    case ID^.Offset of
{Ord} 1 : begin
	    if ExprType^.Object = ob_ordinal then begin
		case ExprType^.Size of
		  1 : ID^.VType := ByteType;
		  2 : ID^.VType := ShortType;
		  4 : ID^.VType := IntType;
		end;
	    end else
		Error("Must be an ordinal type");
	  end;
{Chr} 2 : if not NumberType(ExprType) then
	      NeedNumber;
{Odd} 3 : begin
	    if not NumberType(ExprType) then
		NeedNumber;
	    writeln(OutFile, "\tand.", Suffix(ExprType^.Size), "\t#1,d0");
	    writeln(OutFile, "\tsne\td0");
	  end;
{Abs} 4 : if TypeCheck(ExprType, RealType) then begin
	    writeln(OutFile, "\tmove.l\t_p%MathBase,a6");
	    writeln(OutFile, "\tjsr\t-54(a6)");
	    ID^.VType := RealType;
	  end else begin
	    if not NumberType(ExprType) then
		Error("Expecting a number");
	    lab := GetLabel();
	    writeln(OutFile, "\ttst.", Suffix(ExprType^.Size), "\td0");
	    write(OutFile, "\tbpl\t");
	    PrintLabel(lab);
	    writeln(OutFile);
	    writeln(OutFile, "\tneg.", Suffix(ExprType^.Size), "\td0");
	    PrintLabel(lab);
	    writeln(OutFile);
	    ID^.VType := ExprType;
	  end;
{Succ} 5 : begin
	    if ExprType^.Object <> ob_ordinal then
		Error("expecting an ordinal type");
	    writeln(OutFile, "\taddq.", Suffix(ExprType^.Size),
			    "\t#1,d0");
	    ID^.VType := exprtype;
	   end;
{Pred} 6 : begin
	    if ExprType^.Object <> ob_ordinal then
		Error("expecting an ordinal type");
	    writeln(OutFile, "\tsubq.", Suffix(ExprType^.Size), "\t#1,d0");
	    ID^.VType := ExprType;
	   end;
{ReOpen}
      7 : DoOpen(ExprType, 1005);
{Open}
      8 : DoOpen(ExprType, 1006);
{EOF} 9 : if ExprType^.Object = ob_file then begin
	    writeln(OutFile, "\tmove.l\td0,a0");
	    writeln(OutFile, "\tmove.b\t29(a0),d0");
	  end else
	    error("Expecting a file type");
{Trunc}
     10 : begin
	    if not TypeCheck(ExprType, RealType) then
		Error("Expecting a real type");
	    writeln(OutFile, "\tmove.l\t_p%MathBase,a6");
	    writeln(OutFile, "\tjsr\t-30(a6)");
	  end;
{Round}
     11 : begin
	    if not TypeCheck(ExprType, RealType) then
		Error("Expecting a real type");
	    writeln(OutFile, "\tmove.l\t#$80000040,d1"); { 0.5 }
	    writeln(OutFile, "\tmove.l\t_p%MathBase,a6");
	    writeln(OutFile, "\tjsr\t-66(a6)"); { add 0.5 }
	    writeln(OutFile, "\tjsr\t-90(a6)"); { floor }
	    writeln(OutFile, "\tjsr\t-30(a6)"); { fix }
	  end;
{Float}
     12 : begin
	    if not NumberType(ExprType) then
		NeedNumber;
	    PromoteType(ExprType, IntType, 0);
	    writeln(OutFile, "\tmove.l\t_p%MathBase,a6");
	    writeln(OutFile, "\tjsr\t-36(a6)");
	  end;
{Floor}
     13 : begin
	    if not TypeCheck(ExprType, RealType) then
		Error("Expected real type");
	    writeln(OutFile, "\tmove.l\t_p%MathBase,a6");
	    writeln(OutFile, "\tjsr\t-90(a6)");
	  end;
{Ceil}
     14 : begin
	    if not TypeCheck(ExprType, RealType) then
		Error("Expected real type");
	    writeln(OutFile, "\tmove.l\t_p%MathBase,a6");
	    writeln(OutFile, "\tjsr\t-96(a6)");
	  end;
{SizeOf}
     15 : DoSizeOf;
{Adr}
     16 : begin
	    ExprType := LoadAddress();
	    writeln(OutFile, "\tmove.l\ta0,d0");
	  end;
{Bit}
     17 : begin
	    ExprType := Expression();
	    if not TypeCheck(ExprType, IntType) then
		Error("Expecting an integer type");
	    writeln(OutFile, "\tmoveq.l\t#0,d1");
	    writeln(OutFile, "\tand.l\t#31,d0");
	    writeln(OutFile, "\tbset\td0,d1");
	    writeln(OutFile, "\tmove.l\td1,d0");
	  end;
{ Sqr }
     18 : begin
	      ExprType := Expression;
	      if not TypeCheck(ExprType, RealType) then
		  Error("Expecting a Floating Point Type");
	      Writeln(OutFile, "\tmove.l\td0,d1");
	      Writeln(OutFile, "\tmove.l\t_p%MathBase,a6");
	      Writeln(OutFile, "\tjsr\t-78(a6)");
	  end;
 { Sin, Cos, Sqrt, Tan, ArcTan }
     19..25 : begin
		ExprType := Expression;
		if not TypeCheck(ExprType, RealType) then
		    Error("Expecting a Floating Point Type");
		Writeln(OutFile, "\tmove.l\td0,-(sp)");
		case ID^.Offset of
		  19 : Writeln(OutFile, "\tjsr\t_p%sin");
		  20 : Writeln(OutFile, "\tjsr\t_p%cos");
		  21 : Writeln(OutFile, "\tjsr\t_p%sqrt");
		  22 : Writeln(OutFile, "\tjsr\t_p%tan");
		  23 : Writeln(OutFile, "\tjsr\t_p%atn");
		  24 : Writeln(OutFile, '\tjsr\t_p%ln');
		  25 : Writeln(OutFile, '\tjsr\t_p%exp');
		end;
		Writeln(OutFile, "\taddq.l\t#4,sp");
	    end;
    end;
    NeedRightParent;
end;

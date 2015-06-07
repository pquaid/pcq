Program Dhrystone;

{
    This is the Dhrystone benchmark program, used to judge the
efficiency of a realistic mix of instruction types.  That mix is
approximately  53% assignments, 32% control statements, and 15%
procedure and function calls.  Apparently by some measure that's
typical.  It also attempts to balance statement types, operand
types, and operand access (global, local, etc).

    The original benchmark was written by Reinhold P. Weicker for
CACM Volume 27, Number 10, 10/84 p. 1013.  That program was in
Ada, but the version I used was a translation to C by Rick
Richardson, from Fred Fish disk #1.

    I translated this program to get a general sense of how PCQ
stacks up against other compilers for the Amiga.  I got (on my
25MHz Amiga 3000) just under 4000 dhrystones/second in Pascal, and
about 4500 dhrystones/second for DICE, which is actually closer
than I expected.  Never put too much faith in benchmarks, however.
}


{$I "Include:Utils/TimerUtils.i"}
{$I "Include:Devices/Timer.i"}
{$I "Include:Utils/StringLib.i"}

{ Accuracy of timings and human fatigue controlled by next two lines }

Const
    LOOPS   = 50000;		{ Use this for slow or 16 bit machines }

{ Compiler dependent options }

    HZ      = 100;		{ For the Time function below }


Type
    Enumeration = (Ident1, Ident2, Ident3, Ident4, Ident5);

    OneToThirty   = Integer;
    OneToFifty    = Integer;
    CapitalLetter = Char;
    String30      = Array [0..30] of Char;
    Array1Dim     = Array [0..51] of Integer;
    Array2Dim     = Array [0..51,0..51] of Integer;

    RecordStruct = record
	PtrComp     : ^RecordStruct;
	Discr       : Enumeration;
        EnumComp    : Enumeration;
        IntComp     : OneToFifty;
        StringComp  : String30;
    end;

    RecordType   = RecordStruct;
    RecordPtr    = ^RecordType;



{ * Package 1 }

Var
    IntGlob	: Integer;
    BoolGlob	: Boolean;
    Char1Glob	: Char;
    Char2Glob	: Char;
    Array1Glob	: Array1Dim;
    Array2Glob	: Array2Dim;
    PtrGlb	: RecordPtr;
    PtrGlbNext	: RecordPtr;

    Timer	: TimeRequestPtr;

{  Return system time in hundreths of a second }

Function Time : Integer;
var
    TV : TimeVal;
begin
    GetSysTime(Timer,TV);
    with TV do
	Time := tv_Secs * 100 + tv_Micro div 10000;
end;



Function Func1(CharPar1, CharPar2 : CapitalLetter) : Enumeration;
var
    CharLoc1	: CapitalLetter;
    CharLoc2	: CapitalLetter;
begin
    CharLoc1 := CharPar1;
    CharLoc2 := CharLoc1;
    if CharLoc2 <> CharPar2 then
	Func1 := Ident1
    else
	Func1 := Ident2;
end;



Function Func2(var StrParI1, StrParI2 : String30) : Boolean;
var
    IntLoc	: OneToThirty;
    CharLoc	: CapitalLetter;
begin
    IntLoc := 1;
    while IntLoc <= 1 do
	if Func1(StrParI1[IntLoc], StrParI2[IntLoc+1]) = Ident1 then begin
	    CharLoc := 'A';
	    Inc(IntLoc);
	end;

    if (CharLoc >= 'W') and (CharLoc <= 'Z') then
	IntLoc := 7;

    if CharLoc = 'X' then
	Func2 := True
    else begin
	if strcmp(Adr(StrParI1), Adr(StrParI2)) > 0 then begin
	    IntLoc := IntLoc + 7;
	    Func2 := True;
	end else
	    Func2 := False;
    end;
end;



Function Func3(EnumParIn : Enumeration) : Boolean;
var
    EnumLoc	: Enumeration;
begin
    EnumLoc := EnumParIn;
    if EnumLoc = Ident3 then
	Func3 := True;
    Func3 := False;
end;



Procedure Proc8(var Array1Par : Array1Dim;
		var Array2Par : Array2Dim;
		IntParI1, IntParI2 : OneToFifty);
var
    IntLoc	: OneToFifty;
    IntIndex	: OneToFifty;
begin
    IntLoc := IntParI1 + 5;
    Array1Par[IntLoc] := IntParI2;
    Array1Par[IntLoc+1] := Array1Par[IntLoc];
    Array1Par[IntLoc+30] := IntLoc;

    for IntIndex := IntLoc to IntLoc + 1 do
	Array2Par[IntLoc,IntIndex] := IntLoc;

    Inc(Array2Par[IntLoc,IntLoc-1]);
    Array2Par[IntLoc+20,IntLoc] := Array1Par[IntLoc];
    IntGlob := 5;
end;



Procedure Proc7(IntParI1, IntParI2 : OneToFifty;
		var IntParOut : OneToFifty);
var
    IntLoc	: OneToFifty;
begin
    IntLoc := IntParI1 + 2;
    IntParOut := IntParI2 + IntLoc;
end;



Procedure Proc6(EnumParIn : Enumeration; var EnumParOut : Enumeration);
begin
    EnumParOut := EnumParIn;
    if not Func3(EnumParIn) then
	EnumParOut := Ident4;
    case EnumParIn of
      Ident1	: EnumParOut := Ident1;
      Ident2    : if IntGlob > 100 then
		      EnumParOut := Ident1
		  else
		      EnumParOut := Ident4;
      Ident3    : EnumParOut := Ident2;
      Ident4    : ;
      Ident5    : EnumParOut := Ident3;
    end;
end;



Procedure Proc5;
begin
    Char1Glob := 'A';
    BoolGlob  := FALSE;
end;



Procedure Proc4;
var
    BoolLoc	: Boolean;
begin
    BoolLoc := Char1Glob = 'A';
    BoolLoc := BoolLoc or BoolGlob;
    Char2Glob := 'B';
end;



Procedure Proc3(var PtrParOut : RecordPtr);
begin
    if PtrGlb <> Nil then
        PtrParOut := PtrGlb^.PtrComp
    else
        IntGlob := 100;
    Proc7(10, IntGlob, PtrGlb^.IntComp);
end;



Procedure Proc2(var IntParIO : OneToFifty);
var
    IntLoc	: OneToFifty;
    EnumLoc	: Enumeration;
begin
    IntLoc := IntParIO + 10;
    while true do begin
	if Char1Glob = 'A' then begin
	    Dec(IntLoc);
	    IntParIO := IntLoc - IntGlob;
	    EnumLoc := Ident1;
	end;
	if EnumLoc = Ident1 then
	    return;
    end;
end;



Procedure Proc1(PtrParIn : RecordPtr);
begin
    with PtrParIn^ do begin
	PtrComp^ := PtrGlb^;
	IntComp  := 5;
	PtrComp^.IntComp := IntComp;
	PtrComp^.PtrComp := PtrComp;
	Proc3(PtrComp^.PtrComp);

	if PtrComp^.Discr = Ident1 then begin
	    PtrComp^.IntComp := 6;
	    Proc6(EnumComp, PtrComp^.EnumComp);
	    PtrComp^.PtrComp := PtrGlb^.PtrComp;
	    Proc7(PtrComp^.IntComp, 10, PtrComp^.IntComp);
	end else
	    PtrParIn^ := PtrComp^;
    end;
end;



Procedure Proc0;
var
    IntLoc1	: OneToFifty;
    IntLoc2	: OneToFifty;
    IntLoc3	: OneToFifty;
    CharLoc	: Char;
    CharIndex	: Char;
    EnumLoc	: Enumeration;
    String1Loc  : String30;
    String2Loc  : String30;
    i		: Integer;

    starttime	: Integer;
    benchtime	: Integer;
    nulltime	: Integer;

begin
    Timer := CreateTimer(UNIT_MICROHZ);
    if Timer = Nil then
	return;

    starttime := Time;

    for i := 1 to LOOPS do ;

    nulltime := Time - starttime;    { Computes overhead of looping }

    New(PtrGlbNext);
    New(PtrGlb);

    PtrGlb^.PtrComp  := PtrGlbNext;
    PtrGlb^.Discr    := Ident1;
    PtrGlb^.EnumComp := Ident3;
    PtrGlb^.IntComp  := 40;
    strcpy(Adr(PtrGlb^.StringComp), "DHRYSTONE PROGRAM, SOME STRING");

{****************
-- Start Timer --
****************}

    Writeln('Start timer!');
    starttime := Time;

    for i := 0 to Pred(Loops) do begin
	Proc5;
	Proc4;
	IntLoc1 := 2;
	IntLoc2 := 3;
	strcpy(Adr(String2Loc), "DHRYSTONE PROGRAM, 2'ND STRING");

	EnumLoc := Ident2;
	BoolGlob := not Func2(String1Loc, String2Loc);

	while IntLoc1 < IntLoc2 do begin
	    IntLoc3 := 5 * IntLoc1 - IntLoc2;
	    Proc7(IntLoc1, IntLoc2, IntLoc3);
	    Inc(IntLoc1);
	end;

	Proc8(Array1Glob, Array2Glob, IntLoc1, IntLoc3);
	Proc1(PtrGlb);
	for CharIndex := 'A' to Char2Glob do
	    if EnumLoc = Func1(CharIndex, 'C') then
		Proc6(Ident1, EnumLoc);
	IntLoc3 := IntLoc2 * IntLoc1;
	IntLoc2 := IntLoc3 div IntLoc1;
	IntLoc2 := 7 * (IntLoc3 - IntLoc2) - IntLoc1;
	Proc2(IntLoc1);

    end;

{****************
-- Stop Timer --
****************}
    Writeln('Stop timer!');

    benchtime := (Time - starttime) - nulltime;

    Writeln('Dhrystone time for ', LOOPS, ' passes = ',
		benchtime div HZ, ' seconds');
    Writeln('This benchmarks at ', LOOPS * HZ div benchtime, ' dhrystones/second');

    DeleteTimer(Timer);
end;


begin
   Proc0;
end.

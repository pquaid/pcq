{

	GText.x for PCQ Pascal

	Cat'sEye

	Just some functions/procedures to make GText a bit more
	interesting...
}

{$I "Include:Graphics/Text.i"}

Function StrToReal (s : String) : Real;

Var	I		: integer;
	sr		: real;
	sc		: char;
	TensPastDec	: real;

begin
sr := 0.0;
I := 0;
TensPastDec := 0.0;
while I <= StrLen(s) do
	begin
	sc := s[I];
	if isdigit (sc) then
		if (TensPastDec = 0.0) then
			sr := sr * 10.0 + float(ord(sc)-ord('0'))
		else	sr := sr + float(ord(sc)-ord('0')) / TensPastDec;
	if sc = '.' then TensPastDec := 1.0;
	TensPastDec := TensPastDec * 10.0;
	Inc (I);
	end;
StrToReal := sr;
end;

Procedure RealToString (rr : Real; var s : String);

var	L, R	: Integer;
	Ls, Rs	: String;
	Rt	: String;

begin
Ls := AllocString (10);
Rs := AllocString (10);
Rt := AllocString (10);
StrCpy (s, "");
l := abs (trunc (rr));
if l > 0 then
	r := abs (trunc ((float (l)-rr) * 100.00)) else
	r := abs (trunc (rr * 100.00));
if (rr < 0.0) then StrCat (S, "-");
if IntToStr (Rs, R) < 0 then;
if R < 10 then
	begin
	StrCpy (Rt, "0");
	StrCat (rt, rs);
	StrCpy (Rs, Rt);
	end;
if IntToStr (Ls, L) < 0 then;
StrCat (S, Ls);
StrCat (S, ".");
StrCat (S, Rs);
FreeString (Ls);
FreeString (Rs);
FreeString (Rt);
end;

Procedure GTextLn (Rp : RastPortPtr; L : String);

var	ox, oy	: Short;

begin
ox := RP^.cp_x;
oy := RP^.cp_y;
GText (Rp, L, StrLen (L));
Move (Rp, Ox, Oy + RP^.TxHeight);
end;

Procedure GTextInt (Rp : RastPortPtr; k : integer);

var len : integer; SS : string;

begin
SS := AllocString(20);
len := IntToStr (SS, k);
GText (Rp, SS, len);
FreeString (Ss);
end;

Procedure GTextReal (Rp : RastPortPtr; k : real);

var	s	: string;

begin
s := AllocString (20);
RealToString (k, s);
GText (Rp, s, strlen(s));
freestring(s);
end;

External;

{
	Random.p

	This implements a very long cycle random number generator
	by combining three independant generators.  The technique
	was described in the March 1987 issue of Byte.
}

{$I "Include:Libraries/DOS.i"}
{$SP}

var
    Seed1,
    Seed2,
    Seed3	: Integer;

{$SX}

Function RealRandom : Real;
var
    ReturnValue : Real;
begin
    Inc(Seed1);
    Seed1 := (Seed1 * 706) mod 500009;
    INC(Seed2);
    Seed2 := (Seed2 * 774) MOD 600011;
    INC(Seed3);
    Seed3 := (Seed3 * 871) MOD 765241;
    ReturnValue := FLOAT(Seed1)/500009.0 +
		   FLOAT(Seed2)/600011.0 +
		   FLOAT(Seed3)/765241.0;
    RealRandom := ReturnValue - floor(ReturnValue);
end;

Function RangeRandom(MaxValue : Integer) : Integer;
begin
    Inc(Seed1);
    Seed1 := (Seed1 * 998) mod 1000003;
    RangeRandom := Seed1 mod Succ(MaxValue);
end;

Procedure UseSeed(seed : Integer);
begin
    Seed1 := seed mod 1000003;
    Seed2 := (RangeRandom(65000) * RangeRandom(65000)) mod 600011;
    Seed3 := (RangeRandom(65000) * RangeRandom(65000)) mod 765241;
end;

Procedure SelfSeed;
var
    time : DateStampRec;
begin
    DateStamp(time);
    with time do
	UseSeed(ds_Days + ds_Minute + ds_Tick)
end;

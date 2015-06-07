External;

{
	DateTools.p of PCQ Pascal

	These routines help to use AmigaDOS's DateStamps and Intuition's
	CurrentTime(), which, to save memory, are formatted relatively
	inconveniently.  These routines use DateDescription records,
	which have the Year, Month, etc. formatted in normal human
	form.  This module also exports some typed constants that spell
	out the month and day names in case you've forgotten.

	It appears that the DateStamp and the values from Intuition's
	CurrentTime routine are normalized - that is, if the number of
	minutes in a DateStamp, for example, is greater than 1440
	(the number of minutes in a day), it wraps to zero and the
	number of days in incremented.  If it turns out that the
	stamps are not normalized, you'll need to account for the
	minutes using some code in GetDescription that is currently
	commented out.
}

{$I "Include:Libraries/DOS.i"}
{$I "Include:Intuition/Intuition.i"}

Type
    DaysOfTheWeek = (Sunday, Monday, Tuesday, Wednesday,
			Thursday, Friday, Saturday);

    DateDescription = record
	Day	: Byte;			{ Day of month, 1..31 }
	Month	: Byte;			{ Month, 1..12 }
	Year	: Short;		{ Year, 1978... }
	DOW	: DaysOfTheWeek;	{ Sunday .. Saturday }
	Hour	: Byte;			{ 0..23.  0 = 12 AM, 12 = Noon }
	Minute	: Byte;			{ 0..59 }
	Second	: Byte;			{ 0..59 }
    end;

Const
    MonthNames : Array [1..12] of String =
		       ("January",
			"February",
			"March",
			"April",
			"May",
			"June",
			"July",
			"August",
			"September",
			"October",
			"November",
			"December");

    DayNames : Array [Sunday..Saturday] of String =
		       ("Sunday",
			"Monday",
			"Tuesday",
			"Wednesday",
			"Thursday",
			"Friday",
			"Saturday");

	{ This array changes if you get a date description for
	  a leap year date.  Thus if you are going to use these
	  values, make sure you set DaysInMonth[1] to the value
	  you need.  Also note that this array is zero based,
	  unlike the month names above }

    DaysInMonth : Array [0..11] of Byte = (31,28,31,30,31,30,
					   31,31,30,31,30,31);


{ Given Total seconds, figure out the day, month, year, time of day,
  etc. }

Procedure GetDescription(Total : Integer; var DD : DateDescription);
var
    Compare : Integer;
    Tally   : Short;
begin
    with DD do begin
	Second	:= Total mod 60;
	Minute	:= (Total div 60) mod 60;
	Hour	:= (Total div 3600) mod 24;

	Total := Total div 86400; { Total Days }
	DOW := DaysOfTheWeek(Total mod 7);
	Year := 1978;
	Tally := 2;
	Compare := 365;
	while Total >= Compare do begin
	    Total := Total - Compare;
	    Inc(Year);
	    Inc(Tally);
	    Compare := 365;
	    if (Tally and 3) = 0 then
		if (Tally mod 100) <> 0 then
		    Compare := 366;
	end;
	DaysInMonth[1] := 28;
	if (Tally and 3) = 0 then
	    if (Tally mod 100) <> 0 then
		DaysInMonth[1] := 29;
	for Tally := 0 to 11 do begin
	    if Total < DaysInMonth[Tally] then begin
		Month := Succ(Tally);
		Day   := Succ(Total);
		return;
	    end else
		Total := Total - DaysInMonth[Tally];
	end;
    end;
end;


{  Get a description for the current time }

Procedure TimeDesc(var DD : DateDescription);
var
    Secs, Mics : Integer;
begin
    CurrentTime(Secs,Mics);
    GetDescription(Secs,DD);
{ if not normalized, should be: Secs + Mics div 1000000 }
end;


{ Get a description based on a DateStampRec }

Procedure StampDesc(DS : DateStampRec; var DD : DateDescription);
begin
    with DS do
	GetDescription(ds_Days * 86400 + ds_Minute * 60 + ds_Tick div 50,DD);
end;

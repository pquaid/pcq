{
	DateTools.i of PCQ Pascal

	These routines help to use AmigaDOS's DateStamps and Intuition's
	CurrentTime(), which, to save memory, are formatted relatively
	inconveniently.  These routines use DateDescription records,
	which have the Year, Month, etc. formatted in normal human
	form.  This module also exports some typed constants that spell
	out the month and day names in case you've forgotten.

	The MonthNames and DayNames arrays can be altered or removed
	as necessary.  If you don't use English, for example, you can
	change them in this file and will not need to bother with
	anywhere else.  If you want to save the memory, you can get rid
	of them entirely.  You can't, however, get rid of the DaysInMonth
	array, since that is used by the DateTools routines.
}

{$I "Include:Libraries/DOS.i"}

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
    External;


{  Get a description for the current time }
Procedure TimeDesc(var DD : DateDescription);
    External;


{ Get a description based on a DateStampRec }
Procedure StampDesc(DS : DateStampRec; var DD : DateDescription);
    External;

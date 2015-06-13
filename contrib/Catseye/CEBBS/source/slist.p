{$I "CEGetParam.p"}

Function Slist (P : String; formfield : string) : boolean;

{	This is my interpolation of Kerry Paulson's SList function
	(which he was kind enough to let me use.) It is simply called
	with what one would normally find on the Command Line in the
	string P. I have included it directly in CEBBS for reasons
	of :
		speed
		unity
		error handling

	drawbacks :

		CEBBS is TOO HUGE for WORDS
		had to write a CEGetParam(); no big deal, I needed one
			anyway
		still have to use list to create a list (for user list);
			I might put a "snoop" option in SList intead
}

{$I "Include:Exec/Exec.i"}
{$I "Include:Libraries/Dos.i"}
{$I "Include:Libraries/Dosextens.i"}
{$I "Include:Utils/Stringlib.i"}
{$I "Include:Utils/Datetools.i"}
{$I "Include:Utils/SameName.i"}

Type	ListRec = Record
	  LastFile	: ^ListRec;
	  FName		: String;
	  FVald		: Boolean;
	  FComm		: String;
	  FSize		: Integer;
	  FDate		: DateDescription;
	end;
	ListRecPtr	= ^ListRec;

Const	Prot		= (FIBF_Pure or FIBF_Script);

Var	Altern,
	Srt,
	USE,		{* Option Flags *}
	Test		: Boolean;

	WDTH		: Byte;		{* WDTH of Name field *}

	AR		: Short;	{* Alternate Array Num *}
	i,
	j		: Short;
	Nfiles		: Short;	{* # files found *}
	One		: Short;	{* Write this file *}
	tmp		: Short;
	WFile		: Short;	{* # files written (as opposed to found) *}

	WFld		: Array [0..2] of Char; {* for W2Dig *}

	Dir		: String;	{* Directory to take *}
	Excl		: String;	{* Pattern excluded *}
	Param		: String;
	Pat		: String;	{* Pattern to Match *}
	Temp		: String;	{* Scratch String *}
	WFldS		: String;	{* for W2Dig *}

	ListLock	: FileLock;

	ListInfo	: FileInfoBlockPtr;

	CFile		: ListRecPtr;	{* Current File *}
	LastAd		: ListRecPtr;
	Least		: ListRecPtr;

	UInfo		: InfoDataPtr;

Procedure Xit;

begin
freestring (Dir);
freestring (Excl);
freestring (Pat);
freestring (Temp);
freestring (WFldS);
end;

{* Produces a string contain 0n or nn *}

Function W2dig(Num:Byte):String;

begin
	j	:= IntToStr(WFlds,Num);
	if j = 2 then
	begin
		WFld[0] := WFldS[0];
		WFld[1] := WFldS[1];
	end else
	begin
		WFld[0] := '0';
		WFld[1] := WFldS[0];
	end;
	W2Dig	:= @WFld;
end;


{* Write the appropriate info in the record we receive *}

Procedure Wrtinfo(CF:ListRecPtr;Num:short);

Var	FCounter	: Short;
	ARN		: Short;
	i		: Short;	{|}

begin
Inc(WFile);	{* number of files printed *}
FCounter := 0;
ARN :=0;

While FCounter < (StrLen(FormField) - 1) do
begin

	if FormField[FCounter] <> '%' then
	begin
		if FormField[FCounter] = '' then {ANSI!}
			else sendchar(FormField[FCounter]);
	end
	else
	begin
		Inc(FCounter);
		Case FormField[FCounter] of

		'R','r':
			sendstring("\n");

		{* Print a CR every AR times *}
		'A','a':
		begin
			Inc(AR);
			Inc(FCounter);
			if IsDigit(FormField[FCounter]) then
				ARN := Ord(FormField[FCounter]) - 48;

			if ARN = 0 then
				ARN := 10;

			if ARN = AR then
			begin
				AR := 0;
				sendstring("\n");
			end;
			Altern := ((AR mod ARN) <> 0);
		end;

		'%':
			sendstring("%");

		'#':
			sendnum (Num);

		'L','l':
			sendnum (CF^.FSize);

		{* You might want to take this out if you aren't using that *}
		{* kind of validation *}

		'V','v':
		begin
			if CF^.Fvald then
				sendstring(" ")
			else
				sendstring("*");
		end;

		'N','n':begin
			sendstring(CF^.Fname);
			if wdth > 0 then
			    for i := 1 to (WDTH-Strlen(String(CF^.Fname))) do
				sendstring (" ");
			end;

		'd':
		begin
			tmp := IntToStr(Temp,CF^.FDate.year);
			StrCpy(Temp,@Temp[2]);
			sendstring(W2Dig(CF^.FDate.Month));
			sendstring("/");
			sendstring(W2Dig(CF^.FDate.Day));
			sendstring("/");
			sendstring(Temp);
		end;
		'D':
		begin
			Tmp := (10 - StrLen(MonthNames[CF^.FDate.Month]));
			for i := 1 to (Tmp div 2 + (tmp mod 2)) do
				sendstring (" ");
			sendstring (MonthNames[CF^.FDate.Month]);
			for i := 1 to (tmp div 2) do
				sendstring (" ");
			sendstring (" ");
			sendstring (W2Dig(CF^.FDate.Day));
			sendstring (",");
			sendnum (CF^.FDate.Year);
		end;
		't':
		begin
			sendstring(W2Dig(CF^.FDate.Hour));
			sendstring(":");
			sendstring(W2Dig(CF^.FDate.Minute));
			sendstring(":");
			sendstring(W2Dig(CF^.FDate.Second));
		end;
		'T':
		begin
			tmp	:= CF^.FDate.Hour;
			if tmp <12  then
				Strcpy(Temp,"AM")
			else
				Strcpy(Temp,"PM");

			if Tmp = 0 then
				Tmp := 12;
			if Tmp >12 then
				Tmp	:= (Tmp - 12);

			sendstring(W2Dig(Tmp));
			sendstring(":");
			sendstring(W2Dig(CF^.FDate.Minute));
			sendstring(":");
			sendstring(W2Dig(CF^.FDate.Second));
			sendstring(" ");
			sendstring(Temp);
		end;
		'C','c':
			sendstring(CF^.FComm);

		end;	{* Case *}

	end; {* If *}

	Inc(FCounter);

end;	{* While *}
end;{* WriteInfo *}

procedure C_Dispose (var L : ListRecPtr);

begin
freestring(L^.FName);
freestring(L^.FComm);
dispose (L);
end;

{* Main *}
begin

{* These are a little large, just to be on the safe side.  Param is freed *}
{* after checking all the Parameters *}

Dir		:= AllocString(40);
Excl		:= AllocString(30);
Param		:= AllocString(256);
Pat		:= AllocString(30);
Temp		:= Allocstring(128);
WFldS		:= AllocString(4);

if strlen (formfield) < 1 then
	StrCpy (FormField, "%#%1. %N%0 %L %d  %t%R");

WFld[2]		:= '\0';	{* To make writing as a string easier *}

AR	:= 0;
i	:= 1;
one	:= 0;
WDTH	:= 10;	{* Width automatically = MinFileWidth +1, so this can be small  *}
WFile	:= 0;

Altern	:= False;
Srt	:= False;
Use	:= False;

StrCpy(Excl,"");	{* Exclude nothing *}
Strcpy(Pat,"#?");	{* Match all files *}

repeat;
	CEGetParam(P, Param, i);
	if Param[0] = '-' then
	begin
		Param[1]	:= ToUpper(Param[1]);

		Case Param[1] of
		'E'	:
			StrCpy(Excl,@Param[2]);		{* Pattern to exclude *}

		'O'	:
			one	:= StrToInt(@Param[2]);	{* Show only this file *}

		'P'	:
			StrCpy(Pat,@Param[2]);		{* Pattern to search for *}

		'S'	:
			Srt	:= True;		{* Sort file list *}

		'U'	:
			USE	:= True;		{* Show usage *}

		'W'	:
			WDTH	:= StrToInt(@Param[2]);	{* Base Width *}
		end;

	end else 
		if Param^ <> '\0' then
			Strcpy(Dir,Param);
	inc(i);
until (Param^ = '\0');
freestring(Param);

new (ListInfo);
ListLock := lock(Dir,ACCESS_READ);

if ListLock = nil then
	begin
	xit;
	SList := FALSE;
	end;

if not Examine(ListLock,ListInfo) then
	begin
	xit;
	SList := FALSE;
	end;

if (ListInfo^.fib_DirEntryType < 0) then
	begin
	xit;
	SList := FALSE;
	end;

New(UInfo);

if USE then
	Test := Info(ListLock,UInfo);

New(CFile);		{* Dummy record *}

CFile^.LastFile	:= Nil;
LastAd		:= CFile;
NFiles		:= 1;

while Exnext(ListLock,ListInfo) do
begin
	if ((ListInfo^.fib_DirEntryType < 0) and SameName(Pat,@ListInfo^.fib_FileName) and (not SameName(Excl,@ListInfo^.Fib_FileName))) then
	begin
		With ListInfo^ do
		begin
			New(CFile);
			CFile^.LastFile		:= LastAd;
			CFile^.FName		:= StrDup(@Fib_Filename);
			Tmp			:= StrLen(CFile^.FName);
			CFile^.FVald		:= ((fib_Protection and Prot)=Prot);
			CFile^.FComm		:= StrDup(@fib_Comment);
			CFile^.FSize		:= Fib_Size;
			StampDesc(fib_Date,CFile^.FDate);

			{* Stampdesc gives the wrong values, so I do it myself *}
			CFile^.FDate.Hour	:= (fib_date.ds_Minute div 60);
			CFile^.FDate.Minute	:= (fib_date.ds_minute - (CFile^.FDate.Hour * 60));
			CFile^.FDate.Second	:= (fib_date.ds_Tick div TICKS_PER_SECOND);

			inc(Nfiles);
			LastAd := CFile;
		end;
	end;

end;
Dec(Nfiles);

if Srt = False then	{* Write & Dispose File info *}
begin
i := 0;
	While CFile^.LastFile <> Nil do
	begin
		inc(i);
		WrtInfo(CFile,i);		{* Write Current file info *}
		LastAd	:= Cfile;		{* Point to Current rec *}
		CFile	:= CFile^.LastFile;	{* Change Current to Prev *}
		C_Dispose(LastAd);		{* Dispose old Rec *}
	end;;
end else

begin
i	:= 0;

	{* Find least file in list, write & dispose *}

	While CFile^.LastFile <> Nil do
	begin
		inc(i);
		LastAd	:= CFile;
		Least	:= CFile;

		{* Find least file *}

		While CFile^.LastFile <> Nil do
		begin
			if StriCmp(Least^.FName,CFile^.FName) >0 then
				Least	:= CFile;
			CFile	:= CFile^.LastFile;
		end;

		{* if it's the last one, Just Write, dispose it, then move to *}
		{* the next (last) file *}

		if Least = LastAd then
		begin
			if (one = 0) or (i = one) then
				WrtInfo(Least,i);
			CFile	:= Least^.LastFile;
			C_Dispose(Least);
		end else
		{* Otherwise, Write, link Last and next, dispose, go to *}
		{* the last file in the list *}
 
		begin
			if (one = 0) or (i = one) then
				WrtInfo(Least,i);
			CFile	:= LastAd;
			While (CFile^.LastFile <> Least) do
				CFile	:= CFile^.LastFile;
			CFile^.LastFile	:= CFile^.LastFile^.LastFile;
			C_Dispose(least);
			CFile	:= LastAd;
		end;
	end;

end;

{* print return if we're left on an odd alternate return *}

If Altern then
	sendstring("\n");


if WFile = 0 then sendstring("No Files Available\n");

{* You might want to expand this if you need more info.  I save the entire *}
{* infoblock, so it's there if you need it (check dos.i) *}

if USE then
	begin
	sendstring("Bytes Used: ");
	sendnum   ((UInfo^.id_NumBlocksUsed * UInfo^.id_BytesPerBlock));
	sendstring(" Free: ");
	sendnum   (((UInfo^.id_NumBlocks - UInfo^.id_NumBlocksUsed)
			* Uinfo^.id_BytesPerBlock));
	sendstring("\n");
	end;

xit;
Sendstring ("\n");
SList := TRUE;
end;

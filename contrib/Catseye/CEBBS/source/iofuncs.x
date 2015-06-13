external;

 {$I "Include:ceutils/cetypes.i"}
 {$I "Include:exec/exec.i"}
 {$I "Include:intuition/intuition.i"}
 {$I "Include:intuition/intuitionbase.i"}
 {$I "Include:devices/serial.i"}
 {$I "Include:devices/keymap.i"}
 {$I "Include:devices/timer.i"}
 {$I "Include:hardware/cia.i"}
 {$I "Include:exec/nodes.i"}
 {$I "Include:exec/lists.i"}
 {$I "Include:exec/libraries.i"}
 {$I "Include:exec/ports.i"}
 {$I "Include:exec/interrupts.i"}
 {$I "Include:exec/io.i"}
 {$I "Include:exec/memory.i"}
 {$I "Include:libraries/dos.i"}
 {$I "Include:libraries/dosextens.i"}
 {$I "Include:utils/stringlib.i"}
 {$I "Include:utils/ioutils.i"}
 {$I "Include:Utils/ConsoleUtils.i"}
 {$I "Include:Utils/DOSUtils.i"}
 {$I "Include:Utils/ConsoleIO.i"}
 {$I "Include:Utils/SameName.i"}
 {$I "Include:Utils/Random.i"}
 {$I "Include:Utils/DateTools.i"}
 {$I "Include:Utils/BuildMenu.i"}
{$I "BBS.i"}
{$I "BBSFwds.p"}

Procedure about;

begin
emit(char(12));
Emits ("About ");
emits (version);
emits ("\nCopyright (C) 1991 Chris Pressey\n\n");

emits (version);

if not Cripple then
	begin
	emits (" is not ShareWare or Public Domain. This is a registered copy, and\n");
	emits ("is not redistributable without prior consent of the author (me.)\n\n");
	end else
	begin
	emits (" is a CrippleWare (demo) copy of CEBBS. It can not actually be used\n");
	emits ("to run a BBS as it will only set up in local mode.\n\n");
	end;
emits ("Send all complaints, praise, or C$15 to get a registered copy, to :\n\n");
emits ("Chris Pressey\n");
emits ("917 Wicklow Place\n");
emits ("Winnipeg, MB, Canada\n");
emits ("R3T 0J1\n");
end;

Procedure Process_Intuition_menu (v : short);

var	Itnum,	Mnnum	: short;

begin
Itnum := ItemNum (v);
MnNum := MenuNum (v);
case ItNum of
	0	: about;
	1	: begin
		full := not full;
		if full then
			SizeWindow(W, 540,190) else
			SizeWindow(W, -540,-190);
		end;
	2	: begin
			sendstring(bbsdata[18]);
			chat_withem (2);
			sendstring(bbsdata[19]);
		end;
	3	: begin
			sendstring(bbsdata[20]);
			chat_withem (3);
			sendstring(bbsdata[21]);
		end;
	4	: sendchar (char(24));
	5	: closeup;
	end;
end;

function check_menu : boolean;

var
	C	: Char;
	Class	: Integer;
	code,
	amenunum,
	aitemnum : Short;

begin
if (not check_carrier) and (online) then
	check_menu := true;
if ((CheckIO(ReadSer_Req)) <> nil) and (not local) then
	begin
	if WaitIO(ReadSer_Req) <> 0 then;
	c := rs_in[0];
	BeginIO(ReadSer_Req);
	if not usermask then globalchar := c else displaybeep (nil);
	check_menu := not usermask;
	end
	else
	begin
	IM := IntuiMessagePtr(GetMsg(W^.UserPort));
	if IM <> nil then
		begin
		class := IM^.Class;
		code := IM^.Code;
		ReplyMsg(MessagePtr(IM));
		case class of
		MENUPICK_f	: Process_Intuition_Menu (IM^.code);
		VANILLAKEY_f	: begin
				c := char (IM^.code);
				if (c <> char(0)) then
					begin
					globalchar := c;
					check_menu := TRUE;
				 	end
				  end;
		end;
	end;
    end;
end;

procedure emit(c : char);

	{ * emit(char)
	Very simply, outputs the given character to the console only
	(not the modem.)  If it is a CR, it will be output at a LF. }

begin
if c = char(13) then c := char(10);
if full then ConPutChar (WriteReq, c);
end;

procedure emits(s : string);

	{ * emits(string)
	Does an emit() for every character in the given string. }

var	I : short;

begin
if full then
	begin
	for I := 0 to strlen(s)-1 do
		if (s[i] = char(13)) then
			s[i] := char(10);
	ConPutStr (WriteReq, s);
	end
end;

procedure ANSI_colours (c1 : ANSI);

var	rc2 : boolean;

begin
rc2 := rc;
rc := FALSE;
if (curuser.haveANSI = 'D') then
	case c1 of
		Red	: sendstring("[0;31m");
		DkGray	: sendstring("[1;30m");
		LtRed	: sendstring("[1;31m");
		Blue	: sendstring("[0;34m");
		Magenta	: sendstring("[0;35m");
		LtBlue	: sendstring("[1;34m");
		Yellow	: sendstring("[1;33m");
		Green	: sendstring("[0;32m");
		Brown	: sendstring("[0;33m");
		LtGreen	: sendstring("[1;32m");
		LtMag	: sendstring("[1;35m");
		Cyan	: sendstring("[0;36m");
		Gray	: sendstring("[0;37m");
		LtCyan	: sendstring("[1;36m");
		White	: sendstring("[1;37m");
		Black	: sendstring("[1;30m");
		end;
if (curuser.haveANSI = 'C') then
	case c1 of
		Red,
		DkGray,
		Black,
		Blue,
		Magenta,
		Green,
		Brown	: sendstring ("[0m");	

		LtRed,
		LtBlue,
		Yellow,
		LtGreen,
		LtMag,
		Cyan,
		Gray,
		LtCyan,
		White	: sendstring ("[1m");	
		end;
rc := rc2;
end;

procedure sendchar(ch : char);

	{ * sendchar(char)
	Sends the character to the modem (if the call is not "local.") }

begin
if check_menu then;
if rc then case rangerandom (1) of
		0 : ch := tolower(ch);
		1 : ch := toupper(ch);
		end;
emit (ch);
if (not local) then
	begin
	rs_out[0] := ch;
	if DoIO(WriteSer_Req) <> 0 then;
		case ch of
			'\r' : begin
				rs_out[0] := '\n';
				if DoIO(WriteSer_Req) <> 0 then;
				end;
			'\n': begin
				rs_out[0] := '\r';
				if DoIO(WriteSer_Req) <> 0 then;
				end;
		end;
	end;
end;

procedure sendstring(s : string);

	{ * sendstring(string)
	}

var	i	: integer;
	c	: char;
	a1	: ansi;

begin
i := 0;
while (s[i] <> char(0)) do
	begin
	c := s[i]; 
	if (c = char(10)) then c := char(13);
	if c = char (16) then
		begin
		inc (i);
		a1 := ANSI (ord(s[i])-ord('0'));
		ANSI_colours (a1);
		end else
	if c = char (17) then
		begin
		inc (i);
		case toupper(s[i]) of
			'A': ANSI_colours (curpr.back);
			'B': ANSI_colours (curpr.normal);
			'C': ANSI_colours (curpr.prompt);
			'D': ANSI_colours (curpr.branch);
			'E': ANSI_colours (curpr.name);
			'F': ANSI_colours (curpr.field);
			'G': ANSI_colours (curpr.key);
			'H': ANSI_colours (curpr.alert);
			'I': ANSI_colours (curpr.rank);
			'J': ANSI_colours (curpr.delim);
			end;
		end else
		sendchar(c);
	inc(i);
	end
end;

procedure clear_terminal;

	{ * clear_terminal()
	}

begin
ANSI_colours (curpr.normal);
if curuser.cls = 'Y' then
	begin
	if (curuser.haveANSI = 'B') or (curuser.haveANSI = 'C') or
	   (curuser.haveANSI = 'D') then
		Sendstring ("[00;00H[J") else
		sendchar (char(12));
	end;
end;

function readchar : char;

	{ * readchar : char;
	}

var
	ct	: char;
	rd	: boolean;

begin
rd := false;
ct := char(0);
while (not rd) do
	begin
	rd := check_menu;
	if rd then ct := globalchar;
	end;
readchar := ct;
end;

function check_carrier : boolean;

	{ * check_carrier()
	}

begin
check_carrier := (not ((ff^ and CIAF_COMCD) = CIAF_COMCD)) or local;
end;

Procedure SetDTR(setit : boolean);

	{ * SetDTR(bool)
	}

begin
cia_ptr^.ciaddra := cia_ptr^.ciaddra or CIAF_COMDTR;
if (setit) then
	cia_ptr^.ciapra := cia_ptr^.ciapra and (not CIAF_COMDTR)
	else
	cia_ptr^.ciapra := cia_ptr^.ciapra or CIAF_COMDTR;
end;

procedure right_string (var sc : string; var ds : string; n : short);

	{ * right_string(string1, string2, short)
	Copies the rightmost n characters from string1 into string2.
	}

var	i, j, k	: short;

begin
i := StrLen (sc) - n;
j := 0;
ds [j] := char (0);
if strlen (sc) >= n then
	while (sc[i] <> char(0)) do
		begin
		ds[j] := sc[i];
		inc (j);
		inc (i);
		end;
ds [j] := char(0);
emits ("*");
emits (ds);
emits ("*\n");
end;

procedure setbaud(setit : string);

	{ * SetBaud(string)
	}

var	s : string;

begin
s := allocstring (8);
if AbortIO(ReadSer_Req) <> 0 then;
ReadSer_Req^.io_Baud := 1200;
strcpy (s, "");
right_string (setit, s, 4);
if strieq (s, bbsdata[29]) then ReadSer_Req^.io_Baud:=300;
if strieq (s, bbsdata[30]) then ReadSer_Req^.io_Baud:=1200;
if strieq (s, bbsdata[31]) then ReadSer_Req^.io_Baud:=2400;
if strieq (s, bbsdata[32]) then ReadSer_Req^.io_Baud:=9600;
ReadSer_Req^.IOSer.io_Command := SDCMD_SETPARAMS;
if DoIO(ReadSer_Req) <> 0 then;
ReadSer_Req^.IOSer.io_Command := CMD_READ;
BeginIO(ReadSer_Req);
freestring (s);
end;

Procedure purge_line;

begin
if AbortIO(ReadSer_Req) <> 0 then;
ReadSer_Req^.IOSer.io_Command := CMD_CLEAR;
if DoIO(ReadSer_Req) <> 0 then;
ReadSer_Req^.IOSer.io_Command := CMD_READ;
SendIO(ReadSer_Req);
end;

Procedure Plus_Plus_Plus;

begin
delay (65);
sendstring(bbsdata[5]);
delay (5);
sendstring(bbsdata[5]);
delay (5);
sendstring(bbsdata[5]);
delay (65);
end;

Procedure reset_modem;

	{ * reset_modem()
	}

begin
if not local then
	begin
	setbaud (bbsdata[30]);
	sendstring (bbsdata [4]);
	sendstring ("\n");
	end;
end;

Procedure hang_up;

	{ * hang_up()
	}

begin
if not local then
	begin
	Plus_Plus_Plus;
	sendstring (bbsdata[6]);
	sendstring ("\n");
	delay (30);
	purge_line;
	sendstring ("\n");
	setbaud (bbsdata[30]);
	delay (30);
	sendstring ("\n");
	end;
end;

function answer_phone : boolean;

	{ * answer_phone() : bool
	}

var 	waitbaud,
	s		: string;
	i		: short;

begin
waitbaud := allocstring (80);
s := allocstring (10);
strcpy (waitbaud, "");
readstring (waitbaud, "", 80, rs_noecho + rs_overboard);
setbaud (waitbaud);
emit ('"');
emits (waitbaud);
emit ('"');
emit ('\n');
strcpy (s, "");
right_string (waitbaud, s, 4);
if	strieq (s, bbsdata[29]) or
	strieq (s, bbsdata[30]) or
	strieq (s, bbsdata[31]) or
	strieq (s, bbsdata[32]) then
		begin
		online := true;
		sendstring ("\n\n\n");
		freestring (waitbaud);
		freestring (s);
		answer_phone := true;
		end;
freestring (waitbaud);
freestring (s);
answer_phone := false;
end;

procedure sendbeep;

	{ * sendbeep()
	Does a sendchar(BEL) }

begin
sendchar(char(7));
end;

procedure readstring(st, def : string; number : integer; flags : short);

	{ * readstring(string, default_string, integer, flags)
	}

var	x		: integer;
	c, c2, c3	: char;
	done		: boolean;
	ds		: string;

begin
x := 0;
done := false;
ds := allocstring (number * 2);
StrCpy (ds, "");
while (not done) do
   begin
	if (not check_carrier) and (online) then done := true;
	c := readchar;
	case ord(c) of
		13 : begin
			ds[x] := '\0';
			if (strlen (ds) > 0) and ((flags and rs_noecho) = 0)
				then sendchar (char(10));
			done := true;
			end;
		127, 8: begin
			if (x > 0) then
			   begin
			   if (ds[x] <> char (10)) and (ds[x] <> char(13)) then
				begin
				dec (x);
				if ((flags and rs_noecho) = 0) then sendstring ("\b \b");
				end
				else
					begin
					if ((flags and rs_noecho) = 0) then sendbeep;
					end
			   end else
					begin
					if ((flags and rs_noecho) = 0) then sendbeep;
					end
			end
		else
			begin
			if(ord (c) >= 32) and (x < number) then
				begin
				if (flags and rs_caps) <> 0 then
					c := toupper(c);
				if ((flags and rs_capfirsts) <> 0) and
					(isspace(ds[x-1]) or (x = 0)) then
					c := toupper(c);
				if ((flags and rs_nums) <> 0) and not (isdigit (c))
					then c := char(0);
				if ((flags and rs_password) <> 0) and
				   ((flags and rs_noecho) = 0) then
					sendchar('*') else
					if ((flags and rs_noecho) = 0) then
						case ord(c) of
						128..255 :
							begin
							if curuser.filter <> 'Y' then
								sendchar (c) else c := char (0);
							end;
						32..126 : sendchar (c);
						end;
				if c <> char(0) then ds[x] := c;
				inc (x);
				end else
				begin
				if (flags and rs_overboard) <> 0 then
					begin
					ds[x] := '\0';
					done := true;
					end else if ((flags and rs_noecho) = 0) then sendbeep;
				end;
			end;
	   end;
   end;
while ds[x-1] = ' ' do
	begin
	ds[x-1] := char(0);
	dec(x);
	end;
if strlen (ds) > 0 then
	strcpy (st, ds) else
	begin
	strcpy (st, def);
	if ((flags and rs_noecho) = 0) then sendstring (def);
	if ((flags and rs_noecho) = 0) then sendstring ("\n");
	end;
freestring (ds);
end;

function power_packed (fspec : string) : boolean;

var	tx	: text;
	c1, c2	: char;

begin
if reopen (fspec, tx) then
	begin
	read (tx, c1, c2);
	close (tx);
	end;
power_packed := (c1 = c2) and (c1 = 'P');
end;

function logoff : boolean;

begin
sendstring(bbsdata[83]);
if (readoption ('Y','N') = 'Y') then
	begin
	sendstring("\n");
	if not local then
		begin
		sendstring(bbsdata[106]);
		readstring (adr (scratch), "", 79, rs_field);
		strcpy (adr(lastuser), adr(curuser.handle));
		sendstring("\n");
		end;
	send_file ("BBSTXT:ByeBye.txt", sf_none);
	if not local then hang_up;
	logoff := TRUE;
	end else
		begin
		sendstring("\n");
		logoff := FALSE;
		end;
end;

procedure sendnum (d : integer);

var s : string;

begin
s := allocstring (20);
if inttostr (s, d) > 2 then;
sendstring (s);
freestring (s);
end;

function StrtoInt (Str : String) : Integer;

{	StrtoInt : Kerry Paulson (what would I do without him?!? ;)	}

var	Int		: Integer;
	Mult		: Integer;
	beg		: byte;
	J		: short;

begin
beg	:= 0;
Mult	:= 1; 
Int	:= 0;

if str[0] = '-' then
	begin
	beg	:= 1;
	Mult	:= Mult * -1;
end;

	for j := (Strlen(Str)-1) downto beg do
	begin
		if IsDigit(Str[j]) then
		begin
			Int	:= Int + (ord(Str[j])-48)*Mult;
			Mult	:= Mult *10;			
		end;
	end;
	StrtoInt	:= Int;
end;

function readnum (def : string) : integer;

var	s : string;
	d : short;

begin
s := allocstring (20);
sendstring (s);
readstring (s, def, 19, rs_nums);
d := strtoint (s);
freestring (s);
readnum := d;
end;

procedure send_file (filename : string; flags : short);

var	c1, c2,
	quest				: char;

	tempstring,
	word				: string;

	sendfileoff,
	bb				: short;

	wordwrap,
	restricted			: boolean;

	tf				: text;

	s, m				: integer;

	procedure print;

	begin
	if not restricted then
		begin
		if not wordwrap then
			begin
			sendstring (tempstring);
			sendstring ("\n");
			end else
			begin
			word_wrap (tempstring, byte(curuser.cols));
			end;
		end;
	end;

	procedure at_command (tempstring : string);
	
	var	ct	: char;
		i, j	: short;

	begin
	case toupper(tempstring[1]) of
		'O' :	begin
			case tempstring[2] of
				'+' : wordwrap := true;
				'-' : wordwrap := false;
				end;
			end;
		'Q' : 	begin
			c1 := tempstring [2];
			c2 := tempstring [3];
			readln (tf, tempstring);
			sendstring (tempstring);
			quest := readoption (c1, c2);
			end;
		'#' : 	begin
			readln (tf, tempstring);
			sendstring (tempstring);
			bb := readnum("0");
			quest := char(bb);
			end;
		'W' :	begin
			readln (tf, tempstring);
			sendstring (tempstring);
			selfseed;
			readln (tf, j);
			j := rangerandom (j-1);
			if j <> 0 then
				for i := 1 to j do
					readln (tf, tempstring);
			readln (tf, tempstring);
			sendstring (tempstring);
			while not strieq (tempstring, "EOQ") do
				readln (tf, tempstring);
			sendstring ("\n");
			end;
		'N' :	begin
			readln (tf, tempstring);
			strcpy (mess, "Notice : ");
			strcat (mess, adr(curuser.handle));
			strcat (mess, " read file '");
			readln (tf, word);
			strcat (mess, word);
			strcat (mess, "' on ");
			CurrentTime(S, M);
			time_info (word, s);
			strcat (mess, word);
			strcat (mess, ".\n\n");
			save_mail (tempstring, 1);
			end;
		'I' :	begin
			readln (tf, tempstring);
			send_file (tempstring, flags);
			end;
		'L' :	begin
			clear_terminal
			end;
		'R' :	begin
			case tempstring[2] of
	    'R','P','C','M','S','Y' : restricted := not (verify_rank (getrank(tempstring[2])));
				'I' : restricted := not restricted;
				'8' : restricted := (ord(curuser.cols) < 80);
				end;
			end;
		'B' : begin
			if (getrank(tempstring[2])) <= curuser.access then
				begin
				readln (tf, tempstring);
				sendstring (tempstring);
				sendstring ("\n");
				end else
				readln (tf, tempstring);
		      end;
		'X' : begin
			if (curuser.xpert) <> 'Y' then
				begin
				readln (tf, tempstring);
				sendstring (tempstring);
				sendstring ("\n");
				end else
				readln (tf, tempstring);
		      end;
		'?' : rc := not rc;
		'D' : begin
			readln (tf, bb);
			delay (bb);
			end;
		end;
	end;

begin
sendfileoff := 0;
if (flags and sf_skiphead) <> 0 then sendfileoff := 7;
wordwrap := false;
restricted := false;
tempstring := allocstring (2000);
word := allocstring (240);
globalchar := char(34);
abort := false;
if power_packed (filename) then
	begin
	strcpy (tempstring, "decrunch >T:Tfly ");
	strcat (tempstring, filename);
	exec_command (tempstring);
	send_file ("T:Tfly", sf_none);
	end else
	begin
	if not reopen(filename, tf) then
		begin
		sendstring ("Can't find file : ");
		sendstring (filename);
		sendstring ("\n");
		end else
		begin
		while sendfileoff <> 0 do
			begin
			readln (tf, tempstring);
			dec(sendfileoff);
			end;
		readln (tf, tempstring);
		while(not eof(tf)) and (not abort) do
			begin
			if (tempstring[0] = '@') and
				((flags and sf_noatcodes) = 0) then
				at_command (tempstring) else print;
			if(globalchar=char(3)) or (globalchar=char(32)) then
				abort := true;
			if not check_carrier then abort := true;
			if(globalchar=char(19)) then
				while readchar <> char(19) do;
			if(globalchar=char(19)) then globalchar := char(0);
			readln (tf, tempstring);
			end;
		print;
		close (tf);
		end;
	end;
freestring (tempstring);
freestring (word);
abort := false;
rc := false;
end;

{$I "bbsfuncs.x"}
{$I "MGB.p"}
{$I "user.p"}
{$I "mail.p"}

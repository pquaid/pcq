procedure closemodem;

begin
CloseDevice(ReadSer_Req);
DeletePort(ReadSer_Req^.IOSer.io_Message.mn_ReplyPort);
FreeMem(ReadSer_Req,sizeof(IOExtSer));
CloseDevice(WriteSer_Req);
DeletePort(WriteSer_Req^.IOSer.io_Message.mn_ReplyPort);
FreeMem(WriteSer_Req,sizeof(IOExtSer));
DeleteStdIO(WriteReq);
end;

procedure closeup;

begin
if not local then closemodem;
DeletePort(WritePort);
CloseConsoleDevice;
DetachMenu;
CloseWindow(W);
exit(0);
end;

function cb : short;

begin
cb := (ord(curbranch)-ord('A'))+1;
end;

function getrank (ch : char) : byte;

begin
case ch of
	'R' : getrank := 1;
	'P' : getrank := 10;
	'C' : getrank := 50;
	'M' : getrank := 100;
	'S' : getrank := 200;
	'Y' : getrank := 255;
	else getrank := 0;
	end;
end;

procedure send_delimeter;

var i : integer;

begin
ANSI_colours (curpr.delim);
for i := 1 to (ord(curuser.cols)-1) do sendchar('-');
sendstring ("\n");
ANSI_colours (curpr.normal);
end;

Procedure loadindex;

var
	f	: text;
	i, j	: integer;
	ss	: string;

begin
ss := allocstring (10);
for I := 1 to numbases do
	with BBSInfo do
		begin
		lmsg[i] := 1;
		fmsg[i] := 1;
		nummsgs[i] := 1;
		maxmsgs[i] := 1;
		postrank[i] := 10;
		readrank[i] := 10;
		textrank[i] := 10;
		filerank[i] := 200;
		bt[i] := noecho;
		name[i] := allocstring (60);
		end;
if not reopen ("BBSTXT:BBSInfo", f) then
	begin
	BBSInfo.calls := 1;
	saveindex;
	end else
	begin
	ReadLn (f, BBSinfo.calls);
	for I := 1 to numbases do
		with BBSInfo do
			ReadLn (f, name[i]);
	for I := 1 to numbases do
		with BBSInfo do
			ReadLn (f, fmsg[i]);
	for I := 1 to numbases do
		with BBSInfo do
			ReadLn (f, lmsg[i]);
	for I := 1 to numbases do
		with BBSInfo do
			ReadLn (f, nummsgs[i]);
	for I := 1 to numbases do
		with BBSInfo do
			ReadLn (f, maxmsgs[i]);
	for I := 1 to numbases do
		with BBSInfo do
			ReadLn (f, postrank[i]);
	for I := 1 to numbases do
		with BBSInfo do
			ReadLn (f, readrank[i]);
	for I := 1 to numbases do
		with BBSInfo do
			ReadLn (f, textrank[i]);
	for I := 1 to numbases do
		with BBSInfo do
			ReadLn (f, filerank[i]);
	for I := 1 to numbases do
		with BBSInfo do
			begin
			ReadLn (f, j);
			bt[i] := BranchType (j);
			end;
	Close (f);
	end;
freestring (ss);
end;

Procedure saveindex;

var

	f	: text;
	i	: integer;

begin
if open ("BBSTXT:BBSInfo", f) then
	begin
	WriteLn (f, BBSinfo.calls);
	for I := 1 to numbases do
		with BBSInfo do
			WriteLn (f, name[i]);
	for I := 1 to numbases do
		with BBSInfo do
			WriteLn (f, fmsg[i]);
	for I := 1 to numbases do
		with BBSInfo do
			WriteLn (f, lmsg[i]);
	for I := 1 to numbases do
		with BBSInfo do
			WriteLn (f, nummsgs[i]);
	for I := 1 to numbases do
		with BBSInfo do
			WriteLn (f, maxmsgs[i]);
	for I := 1 to numbases do
		with BBSInfo do
			WriteLn (f, postrank[i]);
	for I := 1 to numbases do
		with BBSInfo do
			WriteLn (f, readrank[i]);
	for I := 1 to numbases do
		with BBSInfo do
			WriteLn (f, textrank[i]);
	for I := 1 to numbases do
		with BBSInfo do
			WriteLn (f, filerank[i]);
	for I := 1 to numbases do
		with BBSInfo do
			WriteLn (f, ord(bt[i]));
	Close (f);
	end;
end;

Procedure SaveUser;

var j : string; u : file of user;

begin
j := allocstring (90);
strcpy (j, "USER:");
strcat (j, adr(curuser.handle));
if not open (j, u) then;
write (u, curuser);
close (u);
freestring (j);
end;

procedure loaduser (var u : user; fs : string);

var	ufile	: file of user;
	i	: integer;

begin

if (reopen(fs, ufile)) then
	begin
	Read (UFile, CurUser);
	close(ufile);
	end;

for I := 1 to numbases do
    with BBSInfo do
	begin
	if curuser.last[i] > lmsg[i] then curuser.last[i] := lmsg[i];
	if curuser.last[i] < fmsg[i] then curuser.last[i] := fmsg[i];
	end;
end;

procedure tapreturn;

begin
	sendstring("C\n");
	sendstring(bbsdata[16]);
	if readchar <> 'c' then;
	sendstring("B\n");
end;

procedure sendrank (lev : short);

begin
ANSI_colours (curpr.rank);
case lev of
	0..9	: sendstring (bbsdata[55]);
	10..49	: sendstring (bbsdata[56]);
	50..99	: sendstring (bbsdata[57]);
	100..199: sendstring (bbsdata[58]);
	200..254: sendstring (bbsdata[59]);
	255	: sendstring (bbsdata[60]);
	end;
ANSI_colours (curpr.normal);
end;

function verify_rank(lev : short) : boolean;

begin
if lev <= curuser.access then verify_rank := true else
	begin
	sendbeep;
	sendstring ("H*** Restricted to ");
	sendrank (lev);
	sendstring (" ***\nB");
	if curuser.xpert <> 'Y' then tapreturn;
	verify_rank := false;
	end;
end;

{$I "chat.x"}

function verify_file (pth, fil : string; num : integer) : boolean;

var
	b	: boolean;
	sf	: text;
	s, ns	: string;

begin
s := allocstring (100);
ns := allocstring (10);
strcpy (ns, "");
if num <> 0 then
	begin
	if IntToStr (ns, num) > 0 then;
	end;
strcpy (s, pth);
strcat (s, fil);
strcat (s, ns);
b := reopen (s, sf);
if b then close(sf);
freestring (s);
freestring (ns);
verify_file := b;
end;

function verify_user (var d : string) : boolean;

begin
verify_user := verify_file ("USER:", d, 0);
end;

Procedure exec_command (com : string);

var	Limbo		: FileHandle;

begin
Limbo := DOSOpen ("NIL:", Mode_OldFile);
if not Execute (com, Limbo, Limbo) then
	begin
	Sendstring ("HCould not execute :");
	Sendstring (com);
	Sendstring ("B\n");
	end;
DOSClose (Limbo);
end;

procedure chat_request;

begin
exec_command (bbsdata[105]);
sendstring(bbsdata[82]);
end;

procedure word_wrap (s : string; cols : short);

var	sac			: array [0..255] of char;
	c, i, sap		: integer;
	done			: boolean;

begin
c := 0;
done := false;
repeat
	sap := 0;
	for i := c to c + cols do
		begin
		sac[sap] := s[i];
		inc(sap);
		end;
	sac[cols] := char(0);
	i := cols;
	if (c + i) >= strlen (s) then
		begin
		i := strlen(s) - c;
		done := true;
		end else
		begin
		while (sac[i] <> ' ') and (i > 0) do
			begin
			dec (i);
			end;
		c := c + i + 1;
		end;
	if i = 0 then
		begin
		i := cols;
		c := c + i + 1;
		end;
	sac[i] := char(0);
	sendstring (adr(sac[0]));
	sendstring ("\n");
	if(globalchar=char(3)) or (globalchar=char(32)) then
		abort := true;
	if not check_carrier then abort := true;
	if((globalchar=char(19)) or (toupper(globalchar)='P')) then
		tapreturn;
	if((globalchar=char(19)) or (toupper(globalchar)='P')) then globalchar := char(0);
until (done or abort);
end;

function readoption (lowchar, hichar : char) : char;

var	done	: boolean;
	ch	: char;

begin
ANSI_colours (curpr.key);
hichar := toupper(hichar);
lowchar := toupper(lowchar);
if hichar < lowchar then
	begin
	ch := lowchar;
	lowchar := hichar;
	hichar := ch;
	end;
done := false;
if (lowchar = 'N') and (hichar = 'Y') then
	begin
	repeat
		ch := toupper(readchar);
		if (ch = 'Y') or (ch = 'N') then
			done := true;
	until done;
	if ch = 'Y' then sendstring ("(Yes)\n");
	if ch = 'N' then sendstring ("(No)\n");
	end else
	begin
	repeat
		ch := toupper(readchar);
		if (ord (ch) >= ord (lowchar)) and
		   (ord (ch) <= ord (hichar)) or (
			(ch = ' ') or (ch = char(13)) or (ch = '?')) then
			done := true;
	until done;
	if ord(ch) >= ord(lowchar) then
		begin
		sendchar ('(');
		sendchar (ch);
		sendchar (')');
		end;
	if ch = ' ' then sendstring ("(space)");
	if ch = '?' then sendstring ("(wha?)");
	end;
ANSI_colours (curpr.normal);
readoption := ch;
end;

procedure list_branches;

var	i, j : short;

begin
clear_terminal;
sendstring (bbsdata[103]);
for i := 1 to numbases do
	begin
	if curuser.access >= BBSinfo.readrank[i] then
		begin
		ANSI_colours (curpr.branch);
		sendstring (BBSinfo.name[i]);
		for j := 1 to 30-(strlen (bbsinfo.name[i])) do
			sendchar(' ');
		ANSI_colours (curpr.normal);
		sendnum (bbsinfo.Nummsgs[i]);
		sendstring ("\n");
		end;
	end;
sendstring ("\n");
ANSI_colours (curpr.normal);
if curuser.xpert <> 'Y' then tapreturn;
end;

procedure new_branch;

begin
if isalpha (curbranch) then
    with BBSinfo do
	begin
	ANSI_colours (curpr.branch);
	sendstring (name[cb]);
	sendstring ("\n");
	ANSI_colours (curpr.normal);
	curmessage := curuser.last[cb] + 1;
	while curmessage > lmsg[cb] do dec (curmessage);
	sendnum (nummsgs[cb]);
	sendstring (" messages, numbered ");
	sendnum (fmsg[cb]);
	sendstring (" to ");
	sendnum (lmsg[cb]);
	sendstring ("; ");
	sendnum (lmsg[cb]-curuser.last[cb]);
	sendstring (" new.\n\n");
	end;
end;

procedure branch_stats;

begin
clear_terminal;
with bbsinfo do
    begin
	ANSI_colours (curpr.name);
	sendstring (name[cb]);
	sendstring ("\n\nFAccess level        > ");
	sendrank (readrank[cb]);
	sendstring ("\nFAccess level (post) > ");
	sendrank (postrank[cb]);
	sendstring ("\nFAccess level (text) > ");
	sendrank (textrank[cb]);
	sendstring ("\nFAccess level (D/UL) > ");
	sendrank (filerank[cb]);
	sendstring ("\n\nFNumber of messages  > ");
	sendnum (nummsgs[cb]);
	sendstring ("\nFMaximum messages    > ");
	sendnum (maxmsgs[cb]);
	sendstring ("\nFFirst message       > ");
	sendnum (fmsg[cb]);
	sendstring ("\nFLast message        > ");
	sendnum (lmsg[cb]);
	sendstring ("\nFLast message read   > ");
	sendnum (curuser.last[cb]);
	sendstring ("\n\nFBranch type         > E");
	sendstring (BTEnglish[bt[cb]]);
	sendstring ("\n\n");
    end;
end;

procedure jump_to_branch;

var	tcb : char;

begin
sendstring (bbsdata[107]);
repeat
	tcb := readoption ('A','Z');
	if tcb = '?' then
		begin
		list_branches;
		tapreturn;
		sendstring (bbsdata[107]);
		end;
until isalpha (tcb);
sendstring ("\n\n");
if curuser.access >= BBSinfo.readrank[(ord(tcb)-ord('A'))+1] then
	begin
	curbranch := tcb;
	new_branch;
	end else
	sendstring ("Access not allowed.\n\n");
if curuser.xpert <> 'Y' then tapreturn;
end;

procedure loadbbsdata;

var i, j : integer; t : text; s : string;

begin
if reopen ("BBSTXT:BBSData.txt", t) then;

for i := 1 to numdata do
	begin
	bbsdata [i] := allocstring (90);
	readln (t, bbsdata[i]);
	s := bbsdata [i];
	for j := 0 to strlen (s) do
		begin
{ alt - 1 }	if s[j] = '¹' then s[j] := char(10);
{ alt - 2 }	if s[j] = '²' then s[j] := char(12);
		end;
	end;
close (t);
end;

Procedure sendprompt (s : string);

begin
ANSI_colours (curpr.prompt);
sendstring (s);
ANSI_colours (curpr.branch);
sendstring (" (");
sendstring (bbsinfo.name[cb]);
sendstring (") ");
ANSI_colours (curpr.prompt);
sendnum (curmessage);
sendstring ("/");
sendnum (BBSInfo.lmsg[cb]);
sendstring (" > ");
ANSI_colours (curpr.normal);
end;

procedure time_info (var st : string; s : integer);

var	ts : string;
	v : short;
	dd : datedescription;

begin
ts := allocstring (30);
GetDescription (s, DD);
strcpy (st, "");
strcat (st, DayNames[DD.DOW]);
strcat (st, " ");
strcat (st, MonthNames[DD.Month]);
strcat (st, " ");
if inttostr (ts, DD.Day) > 0 then;
strcat (st, ts);
strcat (st, " ");
if inttostr (ts, DD.Year) > 0 then;
strcat (st, ts);
strcat (st, " ");

while s > 86400 do dec (s, 86400);
v := inttostr (ts, s div 3600);
strcat (st, ts);

strcat (st, ":");

while s > 3600 do dec (s, 3600);
v := inttostr (ts, s div 60);
if v = 1 then strcat (st, "0");
strcat (st, ts);
freestring (ts);
end;

procedure obtain_time;

var	b		: string;
	s, m		: integer;

begin
CurrentTime(S, M);
b := allocstring (50);
Time_Info (b, s);
sendstring (b);
sendstring ("\n");
freestring (b);
if curuser.xpert <> 'Y' then tapreturn;
end;

procedure print_header (h : message_header);

var	b : string;

begin
b := allocstring (90);
clear_terminal;
with h do
	begin
	ANSI_colours (curpr.field);
	sendstring ("Message #");
	ANSI_colours (curpr.key);
	sendnum (num);
	ANSI_colours (curpr.field);
	sendstring ("\n\n");

	ANSI_colours (curpr.field);
	sendstring (bbsdata[24]);
	ANSI_colours (curpr.name);
	sendstring (adr(userto));
	sendstring ("\n");

	ANSI_colours (curpr.field);
	sendstring (bbsdata[25]);
	ANSI_colours (curpr.name);
	sendstring (adr(userfrom));
	sendstring ("\n");

	ANSI_colours (curpr.field);
	sendstring (bbsdata[26]);
	ANSI_colours (curpr.name);
	sendstring (adr(re));
	sendstring ("\n");

	Time_Info (b, s);
	ANSI_colours (curpr.field);
	sendstring ("Date > ");
	ANSI_colours (curpr.name);
	sendstring (b);
	sendstring ("\n\n");
	ANSI_colours (curpr.normal);
	end;
freestring (b);
end;

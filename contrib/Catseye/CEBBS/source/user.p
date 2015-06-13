procedure getdefBBSprefs;

var	i : short;

begin
with curpr do
	begin
	back := black;
	normal := green;
	prompt := brown;
	branch := brown;
	name := ltgreen;
	field := yellow;
	key := white;
	alert := white;
	rank := red;
	delim := white;
	for i := 1 to 11 do ANSIpad[i] := dkgray;
	msgfmt := 0;
	pr := pr_menu + pr_branch + pr_msg;
	strcpy (adr(macro), "");
	_ := '_';			{ probably the most confusing
					  pascal statement I'll ever write}
	for i := 1 to numbases do disable[i] := FALSE;
	end;
end;

procedure clearcuruser;

var	i	: short;

begin
with curuser do
	begin
		strcpy (adr(handle), "Guest");
		strcpy (adr(name), "Joe User");
		strcpy (adr(password), "");
		strcpy (adr(phone), "204-555-5555");
		byear := 1991;
		month := 1;
		day := 1;
		access := 1;
		animeacc := 'N';
		haveansi := 'A';
		xpert := 'N';
		linenoise := 'N';
		proto := 'A';
		IBMchars := 'N';
		cols := char(80);
		rows := char(24);
		filter := 'N';
		cls := 'Y';
		calls := 0;
		posts := 0;
		Kul := 0;
		Kdl := 0;
		Ful := 0;
		Fdl := 0;
		Space := 0;
		for i := 1 to 10 do pad[i] := 0;
		s := 0;
		for i := 1 to 26 do last[i] := bbsinfo.lmsg[i];
	end;
end;

procedure check_userfile;

var
	variable	: integer;
	namestring	: string;
	fs		: string;
	i		: integer;
	logged_in	: boolean;

begin
namestring := allocstring (90);
fs := allocstring (90);
logged_in := FALSE;
while (not logged_in) and (check_carrier) do
	begin
	strcpy (fs, "USER:");
	abort := false;
	strcpy (namestring, "");
	sendstring(bbsdata[62]);
	readstring(namestring, "", 25, rs_caps);
	strcat (fs, namestring);
	if (strnieq (namestring, "NEW", 3)) then
		begin
		join_bbs;
		logged_in := true;
		end else
		begin
		if not verify_user (namestring) then sendstring(bbsdata[63])
			else logged_in := true;
		end
	end;
loaduser (curuser, fs);
logged_in := true;
freestring (fs);
freestring (namestring);
end;

Procedure show_userlist;

begin
Sendstring (bbsdata[64]);
send_file ("BBSTXT:userlist.txt", sf_none);
Tapreturn;
end;

Procedure snoop (d : string);

var	s : string;
	f : file of user;
	u : user;
	ss : boolean;
	i : integer;

begin
ss := false;
if not verify_user (d) then
	sendstring (bbsdata[28]) else
	begin
	s := allocstring (90);
	strcpy (s, "USER:");
	strcat (s, d);
	if not reopen (s, f) then;
	read (f, u);
	close (f);

	if (curuser.access = 255) or strieq(adr(curuser.handle), adr(u.handle)) then
		ss := true;
	clear_terminal;
	sendstring ("\nFUser Handle  > E");
	sendstring (adr(u.handle));
	for i := strlen (adr(u.handle)) to 25 do sendchar (' ');

	sendstring ("FLast call    > E");
	time_info (s, u.s);
	sendstring (s);
	sendstring ("\nFReal Name    > ");
	if ss then
		begin
		ANSI_colours (curpr.name);
		sendstring (adr(u.name));
		for i := strlen (adr(u.name)) to 25 do sendchar (' ');
		end else
		begin
		sendstring ("H*** Not shown ***        ");
		end;

	sendstring ("FTotal Calls  > ");
	sendnum (u.calls);
	sendstring ("\n");

	sendstring ("FPassword     > ");
	if ss then
		begin
		ANSI_colours (curpr.name);
		sendstring (adr(u.password));
		for i := strlen (adr(u.password)) to 25 do sendchar (' ');
		end else
		begin
		sendstring ("H*** Not shown ***        ");
		end;

	sendstring ("FTotal Posts  > G");
	sendnum (u.posts);
	sendstring ("\n");

	sendstring ("FPhone Number > ");
	if ss then
		begin
		ANSI_colours (curpr.key);
		sendstring (adr(u.phone));
		for i := strlen (adr(u.phone)) to 25 do sendchar (' ');
		end else
		begin
		sendstring ("H*** Not shown ***        ");
		end;

	sendstring ("FP/C Ratio    > G");
	if u.calls > 1 then sendnum (u.posts div u.calls);
	sendstring ("\n\n");

	sendstring ("FRank         > ");
	sendrank (u.access);
	if u.animeacc = 'Y' then sendstring ("J") else sendstring (" ");

	sendstring ("F              Space Used   > G");
	sendnum (u.space);
	sendstring ("\n\n");

	sendstring ("FKB UL'ed     > G");
	sendnum (u.kul);
	sendstring ("\n");

	sendstring ("FKB DL'ed     > G");
	sendnum (u.kdl);
	sendstring ("\n");

	sendstring ("FFiles UL'ed  > G");
	sendnum (u.ful);
	sendstring ("\n");

	sendstring ("FFiles DL'ed  > G");
	sendnum (u.fdl);
	sendstring ("\n");

	sendstring ("FANSI         > B");
	sendstring (ANSIEnglish[u.haveansi]);
	for i := strlen (ANSIEnglish[u.haveansi]) to 25 do sendchar (' ');

	sendstring ("FExpert Mode  > G");
	case u.xpert of
		'Y' : sendstring ("Yes");
		'N' : sendstring ("No");
		end;
	sendstring ("\n");

	sendstring ("FXfer Proto   > B");
	sendstring (ProtoEnglish[u.proto]);
	for i := strlen (ProtoEnglish[u.proto]) to 25 do sendchar (' ');

	sendstring ("FIBM Chars    > G");
	case u.ibmchars of
		'Y' : sendstring ("Yes");
		'N' : sendstring ("No");
		end;
	sendstring ("\n");

	sendstring ("FScreen       > G");
	sendnum (ord(u.cols));
	sendstring ("F columns, G");
        sendnum (ord(u.rows));
	sendstring ("F lines      ");
	if ord(u.rows) < 10 then sendstring (" ");

	sendstring ("FASCII filter > G");
	case u.filter of
		'Y' : sendstring ("Yes");
		'N' : sendstring ("No");
		end;
	sendstring ("\n\n");
	freestring (s);
	end;
end;

Procedure changerank (d : string);

var	s : string;
	f : file of user;
	u : user;
	ct2 : char;

begin
if not strieq (d, adr(curuser.handle)) then
   begin
   if not verify_user (d) then
	sendstring (bbsdata[28]) else
	begin
	s := allocstring (90);
	strcpy (s, "USER:");
	strcat (s, d);
	if not reopen (s, f) then;
	read (f, u);
	close (f);
	ANSI_colours (curpr.prompt);
	sendstring (bbsdata[12]);
	ct2 := readoption ('A','Z');
	sendstring ("\n");
	u.access := getrank (toupper(ct2));
	if not open (s, f) then;
	write (f, u);
	close (f);
	end;
   end else
	begin
	ANSI_colours (curpr.prompt);
	sendstring (bbsdata[12]);
	ct2 := readoption ('A','Z');
	sendstring ("\n");
	curuser.access := getrank(toupper(ct2));
	saveuser;
	end;
freestring (s);
end;

procedure changeANSI;

var	ch : char;

begin
clear_terminal;
Sendstring ("FCurrent ANSI setting : B");
sendstring (ANSIEnglish[curuser.haveansi]);
sendstring ("\n\n");
for ch := 'A' to 'D' do
	begin
	sendchar (ch);
	sendstring (". ");
	sendstring (ANSIEnglish[ch]);
	sendstring ("\n");
	end;
sendstring ("\n");
repeat
	sendstring ("CPlease choose a new ANSI setting (A - D) ? ");
	curuser.haveansi := readoption ('A','D');
until isalpha(curuser.haveansi);
saveuser;
end;

procedure changeProtocol;

var	ch : char;

begin
clear_terminal;
Sendstring ("FCurrent Xfer protocol : B");
sendstring (ProtoEnglish[curuser.haveansi]);
sendstring ("\n\n");
for ch := 'A' to 'F' do
	begin
	sendchar (ch);
	sendstring (". ");
	sendstring (ProtoEnglish[ch]);
	sendstring ("\n");
	end;
sendstring ("\n");
repeat
	sendstring ("CPlease choose a new Xfer protocol (A - F) ? ");
	curuser.proto := readoption ('A','F');
until isalpha(curuser.proto);
saveuser;
end;

procedure changecols;

var	ch : char;

begin
clear_terminal;
Sendstring ("FCurrent screen width : G");
sendnum (ord(curuser.cols));
sendstring ("\n");
Sendstring ("FCurrent page length : G");
sendnum (ord(curuser.rows));
sendstring ("\n\n");
sendstring ("CPlease choose a new screen width (RETURN = 80 columns) ? ");
curuser.cols := char(readnum("80"));
if ord (curuser.cols) < 22 then curuser.cols := char(22);
if ord (curuser.cols) > 250 then curuser.cols := char(250);
sendstring ("CPlease choose a new page length (1 - 255 lines, 0 = don't care) ? ");
curuser.rows := char(readnum("0"));
ANSI_colours (curpr.normal);
saveuser;
end;

procedure q2;

begin
changeANSI;
changeProtocol;
changecols;
send_file ("BBSTXT:userstats1.txt", sf_none);
curuser.ibmchars := readoption ('Y','N');
send_file ("BBSTXT:userstats2.txt", sf_none);
curuser.filter := readoption ('Y','N');
send_file ("BBSTXT:userstats3.txt", sf_none);
curuser.xpert := readoption ('Y','N');
end;

procedure check_whitelist;

var	u : user;
	m : file of user;
	fs : string;
	i : short;

begin
fs := allocstring (100);
if verify_file ("BBS:whitelist/",adr(curuser.handle),0) then
	begin
	strcpy (fs, "BBS:whitelist/");
	strcat (fs, adr(curuser.handle));
	if reopen (fs, m) then
		begin
		read (m, u);
		if strieq(adr(u.password),adr(curuser.password)) then
			begin
			curuser.access := 10;
			for i := 1 to numbases do
				curuser.last[i] := bbsinfo.lmsg[i];
			end;
		close (m);
		end;
	end;
if verify_file ("BBS:blacklist/",adr(curuser.handle),0) then
	begin
	strcpy (adr(curuser.password), "+++");
	curuser.access := 0;
	hang_up;
	end;
freestring(fs);
end;

procedure join_bbs;

var	done, dont	: boolean;
	variable, i	: short;
	ts		: string;
	fs, s1		: string;
	uufile		: file of user;

begin
s1 := adr(curuser.handle);
done := false;
dont := false;
curuser.cols := char(80);
send_file ("BBSTXT:join.txt", sf_none);
while (not done) do
	begin 
	sendstring("\n");
	sendstring(bbsdata[65]);
	ts := adr(CurUser.name);
	readstring(ts, "", 25, rs_capfirsts);
	for i := 1 to 25 do curuser.handle[i] := toupper(curuser.handle[i]);
	sendstring(bbsdata[66]);
	ts := adr(CurUser.handle);
	readstring(ts, adr(curuser.name), 25, rs_caps);
	for i := 1 to 25 do curuser.name[i] := toupper(curuser.name[i]);
	sendstring(bbsdata[67]);
	ts := adr(CurUser.password);
	readstring(ts, "password", 25, rs_none);
	sendstring(bbsdata[68]);
	ts := adr(CurUser.phone);
	readstring(ts, "204-555-5555", 15, rs_none);
	sendstring(bbsdata[70]);
	sendstring ("\n");
	sendstring(bbsdata[71]);sendstring(adr(CurUser.name));
	sendstring ("\n");
	sendstring(bbsdata[72]);sendstring(adr(CurUser.handle));
	sendstring ("\n");
	sendstring(bbsdata[73]);sendstring(adr(CurUser.password));
	sendstring ("\n");
	sendstring(bbsdata[74]);sendstring(adr(CurUser.phone));
	sendstring ("\n");
	sendstring(bbsdata[76]);
	if (readoption ('Y','N') = 'Y') then done := true;
	if verify_user (s1) then
		begin
		sendstring (bbsdata[77]);
		done := false;
		end;
	end;

q2;

for i := 1 to numbases do
	curuser.last[i] := bbsinfo.fmsg[i];

curuser.access := 1;
curuser.animeacc := 'N';
curuser.linenoise := 'N';
curuser.calls := 0;

fs := allocstring (90);
saveuser;
sendstring("\n");

strcpy (fs, "makedir \"MAIL:");
strcat (fs, adr(curuser.handle));
strcat (fs, "\"");
exec_command (fs);

send_file ("BBSTXT:member.txt", sf_none);
check_whitelist;
saveuser;
if (curuser.access < 10) and (curuser.access > 0) then
	begin
	tapreturn;
	leave_feedback;
	end;
freestring (fs);
end;

procedure user_lister;

var	tf, zf		: text;
	s1, s2, s3	: string;
	u		: user;
	f		: file of user;
	i		: short;
	sec, mic	: integer;

begin
s1 := allocstring (80);
s2 := allocstring (80);
s3 := allocstring (80);
exec_command ("list >ram:uler USER: quick nohead sort");
if open ("BBSTXT:userlist.txt", zf) then
    begin
    if reopen ("ram:uler", tf) then
	begin
	write (zf, "Last update : ");
	CurrentTime(Sec, Mic);
	time_info (s3, sec);
	write (zf, s3);
	write (zf, "\n\n");
	writeln (zf, "Handle                   Rank        Calls Posts Last Call");
	writeln (zf, "------                   ----        ----- ----- ---------");
	while not eof (tf) do
		begin
		readln (tf, s1);
		if verify_user (s1) then
			begin
			strcpy (s2, "USER:");
			strcat (s2, s1);
			if reopen (s2, f) then
				begin
				read (f, u);
				close (f);
				end;
			strcpy (s3, adr(u.handle));
			write (zf, s3);
			for i := 1 to 25-strlen (adr(u.handle)) do
				write (zf, ' ');
			case u.access of
				0..9	: write (zf, bbsdata[55]);
				10..49	: write (zf, bbsdata[56]);
				50..99	: write (zf, bbsdata[57]);
				100..199: write (zf, bbsdata[58]);
				200..254: write (zf, bbsdata[59]);
				255	: write (zf, bbsdata[60]);
				else write (zf, bbsdata[58]);
			end;
			write (zf, u.calls:4);
			write (zf, "  ");
			write (zf, u.posts:4);
			write (zf, "  ");
			time_info (s3, u.s);
			write (zf, s3);
			write (zf, char(10));
			end;
		end;
	close (tf);
	end;
   close (zf);
   end;
freestring (s1);
freestring (s2);
freestring (s3);
end;

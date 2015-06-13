{
***********************************************************
**  CEBBS MAIL PROCESSOR        by: Chris A. Pressey     **
***********************************************************
}

function enter_message : boolean;

var
	tstring : string;
	t	: char;

begin
	strcpy (mess, "");
	MGB (mess, 1999);
	if not abort then
		enter_message := true;
	abort := false;
	enter_message := false;
end;

procedure save_mail (userto : string; nombre : short);

var	count	: short;
	astr,
	bstr,
	cstr	: string;
	good	: boolean;
	ofile	: text;
	ps	: string;

begin
astr := allocstring (90);
bstr := allocstring (90);

good := false;

repeat
	strcpy (astr, "MAIL:");
	strcat (astr, userto);
	strcat (astr, "/");
	if InttoStr (bstr, nombre) > 3 then;
	strcat (astr, bstr);
	if not reopen (astr, ofile) then good := true else
		begin
		inc (nombre);
		close (ofile);
		end;
until good;

if open (astr, ofile) then
	begin
	writeln (ofile, nombre);
	writeln (ofile, "* private mailbox");
	ps := string(adr(MH_MailPost.userfrom));
	writeln (ofile, ps);
	ps := string(adr(MH_MailPost.poster));
	writeln (ofile, ps);
	ps := string(adr(MH_MailPost.re));
	writeln (ofile, ps);
	ps := string(adr(MH_MailPost.blankline));
	writeln (ofile, ps);
	Writeln (ofile, MH_MailPost.s);
	Writeln (ofile, "@O+");
	writeln (ofile, mess);
	close (ofile);
	end;

sendstring("\n");
freestring (astr);
freestring (bstr);
end;

function verify_mail (num : short) : boolean;

var	ct : string;

begin
ct := allocstring (80);
strcpy (ct, "MAIL:");
strcat (ct, adr(curuser.handle));
strcat (ct, "/");
verify_mail := verify_file (ct, "", num);
freestring (ct);
end;

procedure pre_read_mail (h : short; var fstr : string; var MH : message_header);

var	gf		: text;
	i		: short;
	ok		: boolean;
	ss		: string;
	ts		: string;

begin
ts := allocstring (20);
strcpy (fstr, "MAIL:");
strcat (fstr, adr(curuser.handle));
strcat (fstr, "/");
if inttostr(ts, h) > 10 then;
strcat (fstr, ts);
freestring (ts);

ok := reopen (fstr, gf);
if ok then
   with MH do
	begin
	readln (gf, num);
	ss := string(adr(poster));
	strcpy(adr(userto), adr(curuser.handle));
	readln (gf, ss);
	ss := string(adr(poster));
	readln (gf, ss);
	ss := string(adr(userfrom));
	readln (gf, ss);
	ss := string(adr(re));
	readln (gf, ss);
	ss := string(adr(blankline));
	readln (gf, ss);
	readln (gf, s);
	close (gf);
	end;
end;

procedure scan_mail (msg : short);

var	fs	: string;
	MH_Scan	: message_header;

begin
fs := allocstring (80);
if verify_mail (msg) then
	begin
	pre_read_mail (msg, fs, MH_Scan);
	sendnum (msg);
	sendstring (". To > ");
	sendstring (adr(MH_Scan.userto));
	sendstring ("   From > ");
	sendstring (adr(MH_Scan.userfrom));
	sendstring ("   Re > ");
	sendstring (adr(MH_Scan.re));
	sendstring ("\n");
	end;
freestring (fs);
end;

function read_mail (h : short) : boolean;

var	d, e	: string;
	ok	: boolean;
	tx	: text;
	i	: short;
	s	: integer;

begin
d := allocstring (100);
e := allocstring (100);
pre_read_mail (h, e, MH_MailRead);
if not reopen (e, tx) then
	begin
	ok := false;
	end else
	begin
	ok := true;
	close (tx);
	print_header (MH_MailRead);
	send_file (e, sf_skiphead);
	ok := true;
	end;
freestring (d);
freestring (e);
read_mail := ok;
end;

procedure kill_mail (h : short);

var	d : string;

begin
d := allocstring (90);
pre_read_mail (h, d, MH_MailRead);
sendstring ("\n");
sendstring (bbsdata[53]);
if (readoption ('Y','N') = 'Y') then
	if not deletefile (d) then
		sendstring (bbsdata[45]) else
		sendstring (bbsdata[46]);
freestring (d);
end;

function read_my_mail : boolean;

var	p : short;

begin
p := 0;
curmail := 0;
while curmail < max_mail do
	begin
	if verify_mail (curmail) then
		begin
		scan_mail (curmail);
		inc (p);
		end;
	inc (curmail);
	end;
curmail := 0;
if p > 0 then
	begin
	sendstring ("\n\nBYou have been sent ");
	sendnum (p);
	sendstring (" pieces of mail.\n\n");
	sendstring ("CRead your mail now ? (Y/N) B");
	read_my_mail := (readoption ('Y','N') = 'Y');
	end else
	begin
	sendstring ("\n\nBNo mail waiting.\n\n");
	read_my_mail := false;
	end;
end;

procedure get_next_mail;

var	t : short;

begin
t := curmail;
inc (curmail);
while (not verify_mail (curmail)) and (curmail < Max_Mail) do
	inc (curmail);
if curmail = Max_Mail then sendstring ("End of mail.\n");
if curmail = Max_Mail then curmail := t;
end;

procedure get_prev_mail;

var	t : short;

begin
t := curmail;
dec (curmail);
while (not verify_mail (curmail)) and (curmail > 0) do
	dec (curmail);
if curmail = 0 then sendstring ("You are already at the start of the mail.\n");
if curmail = 0 then curmail := t;
end;

procedure mail_chute;

var
	xstring	: string;
	s, m	: integer;

begin

xstring := allocstring (90);

clear_terminal;
sendstring (bbsdata[124]);

sendstring(bbsdata[24]);
readstring(xstring, "", 25, rs_field + rs_caps);
strcpy(adr(MH_MailPost.userto),xstring);

if not verify_user(xstring) then
	sendstring (bbsdata[28]) else

	begin
	sendstring(bbsdata[25]);
	sendstring(adr(curuser.handle));
	sendstring("\n");
	strcpy(adr(MH_MailPost.userfrom),adr(curuser.handle));

	strcpy(adr(MH_MailPost.poster),adr(curuser.handle));

	sendstring(bbsdata[26]);
	readstring(xstring, "Nothing in particular", 80, rs_field);
	strcpy(adr(MH_MailPost.re),xstring);

	sendstring(bbsdata[27]);
	CurrentTime(S, M);
	Time_info (xstring, s);
	sendstring (xstring);
	sendstring ("\n");

	MH_MailPost.s := s;

	strcpy (mess, "");
	if enter_message then save_mail (adr(MH_MailPost.userto), 1);
	end;

freestring (xstring);
end;

procedure mail_reply;

var
	xstring	: string;
	s, m	: integer;

begin

xstring := allocstring (90);

clear_terminal;
sendstring (bbsdata [126]);

pre_read_mail (curmail, xstring, MH_MailRead);

sendstring(bbsdata[24]);
strcpy(adr(MH_MailPost.userto), adr(MH_MailRead.userfrom));
sendstring(adr(MH_MailPost.userto));
sendstring ("\n");

strcpy(xstring, adr(MH_MailRead.userfrom));
if not verify_user(xstring) then
	sendstring (bbsdata[28]) else

	begin
	sendstring(bbsdata[25]);
	sendstring(adr(curuser.handle));
	sendstring("\n");
	strcpy(adr(MH_MailPost.userfrom),adr(curuser.handle));

	strcpy(adr(MH_MailPost.poster),adr(curuser.handle));

	sendstring(bbsdata[26]);
	strcpy(adr(MH_MailPost.re), adr(MH_MailRead.re));
	sendstring(adr(MH_MailPost.re));
	sendstring ("\n");

	sendstring(bbsdata[27]);
	CurrentTime(S, M);
	Time_info (xstring, s);
	sendstring (xstring);
	sendstring ("\n");

	MH_MailPost.s := s;

	strcpy (mess, "");
	if enter_message then save_mail (adr(MH_MailPost.userto), 1);
	end;

freestring (xstring);
end;

procedure leave_feedback;

var
	xstring : string;

begin

xstring := allocstring (90);

clear_terminal;

sendstring(bbsdata[122]);
sendstring(bbsdata[24]);
sendstring(bbsdata[2]);
sendstring(" & ");
sendstring(bbsdata[3]);
sendstring("\n");
sendstring(bbsdata[25]);
sendstring(adr(curuser.handle));
strcpy (adr(MH_MailPost.userfrom),adr(curuser.handle));
strcpy (adr(MH_MailPost.poster),adr(curuser.handle));
sendstring("\n");
sendstring(bbsdata[26]);
readstring(xstring, "Er... validate me?", 80, rs_field);
strcpy(adr(MH_MailPost.re),xstring);

strcpy (mess, "");
if enter_message then
	begin
	save_mail (bbsdata[2], 1);
	save_mail (bbsdata[3], 1);
	end;

freestring (xstring);
end;

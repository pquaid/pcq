{

 *************************************************************
 **  MESSAGE HANDLING             by: David R. Stromberger  **
 **  message.p                    date: 2/10/89             **
 **  modified exTENSIVEly by Chris Pressey, 28 Aug 91       **
 *************************************************************

}

procedure get_from_field (var MH : message_header);

var
	xstring : string;

begin
xstring := allocstring (80);
sendstring(bbsdata[25]);
case BBSInfo.bt[cb] of
	noecho : begin
		sendstring(adr(curuser.handle));
		strcpy(adr(MH.userfrom),adr(curuser.handle));
		sendstring("\n");
		end;
	echomail, fidoecho, rno : begin
		sendstring(adr(curuser.name));
		strcpy(adr(MH.userfrom),adr(curuser.name));
		sendstring("\n");
		end;
	zany : begin
		readstring(xstring, adr(curuser.handle), 70, rs_field);
		if verify_user(xstring) and (not strieq(adr(curuser.handle), xstring)) then
			begin
			sendstring ("Can't post under someone else's handle.\n");
			strcpy(adr(MH.userfrom), adr(curuser.handle));
			end else
			strcpy(adr(MH.userfrom), xstring);
		end;
	end;
strcpy(adr(MH.poster),adr(curuser.handle));
freestring (xstring);
end;

procedure get_time_field (var MH : message_header); 

var	s, m	: integer;
	xstring : string;

begin
xstring := allocstring (80);
sendstring(bbsdata[27]);
case BBSInfo.bt[cb] of
	zany : S := RangeRandom (MaxInt);
	else CurrentTime(S, M);
	end;
Time_info (xstring, s);
sendstring (xstring);
sendstring ("\n");
MH.s := s;
freestring (xstring);
end;

procedure post_message;

var
	xstring : string;
	i	: integer;

begin
xstring := allocstring (90);
if verify_rank(bbsinfo.postrank[cb]) then
	begin
	clear_terminal;
	sendstring("\nEnter Public Message\n\n");
	sendstring(bbsdata[24]);
	readstring(xstring, "All", 80, rs_field);
	strcpy(adr(MH_Post.userto),xstring);
	if verify_user (xstring) then
		for i := 1 to 25 do
		MH_Post.Userto[i] := toupper(MH_Post.userto[i]);

	get_from_field (MH_Post);

	sendstring(bbsdata[26]);
	readstring(xstring, "Nothing in particular", 80, rs_field);
	strcpy(adr(MH_Post.re),xstring);

	get_time_field (MH_Post);

	strcpy (mess, "");
	if enter_message then
		begin
		save_message;
		inc (curuser.posts);
		end;
	end else sendstring (bbsdata[118]);
freestring (xstring);
end;

procedure reply_to_message;

var
	xstring : string;
	s, m	: integer;

begin
xstring := allocstring (90);
if verify_rank(bbsinfo.postrank[cb]) then
	begin
	clear_terminal;
	sendstring("\nPublic Reply\n\n");
	sendstring(bbsdata[24]);
	sendstring(adr(MH_Read.userfrom));
	strcpy(adr(MH_Post.userto), adr(MH_Read.userfrom));
	sendstring("\n");

	get_from_field (MH_Post);

	sendstring(bbsdata[26]);
	readstring(xstring, adr(MH_Read.re), 80, rs_field);
	strcpy(adr(MH_Post.re), xstring);

	get_time_field (MH_Post);

	strcpy (mess, "");
	if enter_message then
		begin
		save_message;
		inc (curuser.posts);
		end
	end else
	sendstring (bbsdata[119]);
freestring (xstring);
end;

procedure kill_message (d : integer);

var
	numstr		: string;
	fstr		: string;

begin
if streq (adr(MH_Read.poster), adr(curuser.handle)) or
    verify_rank (255) then
	begin
	numstr := allocstring (90);
	fstr := allocstring (90);

	strcpy (numstr, "");
	strcpy (fstr, "MESS:A/");
	fstr[5] := curbranch;
	if IntToStr (numstr, d) <> 0 then;
	strcat (fstr, numstr);
	
	sendstring (bbsdata[47]);
	if (readoption ('Y','N') = 'Y') then
	    if not DeleteFile (fstr) then
		sendstring (bbsdata[45]) else
		with BBSinfo do
		begin
		sendstring (bbsdata[46]);
		while not verify_message (lmsg[cb]) do dec (lmsg[cb]);
		while not verify_message (fmsg[cb]) do inc (fmsg[cb]);
		if curmessage < fmsg[cb] then curmessage := fmsg[cb];
		if curmessage > lmsg[cb] then curmessage := lmsg[cb];
		dec(nummsgs[cb]);
		saveindex;
		end;
	freestring (numstr);
	freestring (fstr);
	end else
	sendstring (bbsdata[44]);
abort := false;
if not verify_message(curmessage) then fwd_message;
if abort then curmenu := main_menu else
	begin
	if not read_message(curmessage) then;
	end;
end;

procedure back_message;

var	exit	: boolean;

begin
exit := false;
if curmessage <> bbsinfo.fmsg[cb] then
	begin
	dec (curmessage);
	repeat
		if not verify_message (curmessage) then
			begin
			dec (curmessage);
			if curmessage = bbsinfo.fmsg[cb] then
				begin
				exit := true;
				if read_message (curmessage) then;
				end
			end else
			begin
			if read_message (curmessage) then;
			exit := true;
			end;
	until exit;
	end else sendstring (bbsdata[42]);
end;

procedure new_scan_next;

var
	tempcurbranch	: char;
	done		: boolean;

begin
sendstring (bbsdata[43]);
done := false;
tempcurbranch := curbranch;

repeat
inc (curbranch);
if curbranch <> 'Z' then
	begin
	if (bbsinfo.lmsg[cb] <> curuser.last[cb]) and
	   (bbsinfo.readrank[cb] <= curuser.access) then
		begin
		new_branch;
		if read_message(curmessage) then;
		done := true;
		end;
	end else
	begin
	sendstring ("No more new messages.\n");
	curbranch := tempcurbranch;
	new_branch;
	abort := true;
	done := true;
	end;
until done;
end;

procedure fwd_message;

var	exit		: boolean;

begin
exit := false;
if curmessage <> bbsinfo.lmsg[cb] then
	begin
	inc (curmessage);
	repeat
		if not verify_message (curmessage) then
			begin
			inc (curmessage);
			if curmessage = bbsinfo.fmsg[cb] then
				begin
				exit := true;
				if read_message (curmessage) then;
				end
			end else
			begin
			if read_message (curmessage) then;
			exit := true;
			end;
	until exit;
	end else new_scan_next;
end;

procedure save_message;

var	astr,
	bstr		: string;
	ofile		: text;

begin
inc (bbsinfo.lmsg[cb]);
inc (bbsinfo.nummsgs[cb]);

while bbsinfo.nummsgs[cb] > bbsinfo.maxmsgs[cb] do
	begin
	kill_message (bbsinfo.fmsg[cb]);
	while not (verify_message(bbsinfo.fmsg[cb])) do
		inc (bbsinfo.fmsg[cb]);
	dec (bbsinfo.nummsgs[cb]);
	end;

astr := allocstring (90);
bstr := allocstring (90);
strcpy (astr, "MESS:A/");
if InttoStr (bstr, bbsinfo.lmsg[cb]) > 3 then;
strcat (astr, bstr);
astr[5] := curbranch;
if open (astr, ofile) then
	begin
	writeln (ofile, bbsinfo.lmsg[cb]);
	writeln (ofile, string(adr(MH_Post.userto)));
	writeln (ofile, string(adr(MH_Post.poster)));
	writeln (ofile, string(adr(MH_Post.userfrom)));
	writeln (ofile, string(adr(MH_Post.re)));
	writeln (ofile, ":");
	Writeln (ofile, MH_Post.s);
	Writeln (ofile, "@O+");
	writeln (ofile, mess);
	close (ofile);
	end else sendstring ("Can't open file.\n\n");

sendstring("\n");

freestring (astr);
freestring (bstr);
saveindex;
end;

procedure scan_to (uto : string; dir : short);

var	sm	: short;
	done	: boolean;
	fstr	: string;

begin
fstr := allocstring (90);
sm := curmessage;
done := false;
while not done do
	begin
	sendstring (".");
	sm := sm + dir;
	if (sm <= bbsinfo.lmsg[cb]) and (sm >= bbsinfo.fmsg[cb]) then
		begin
		pre_read_message (sm, fstr, MH_Read);
		if strieq (adr(MH_Read.userto), uto) then
			begin
			if read_message (sm) then;
			curmessage := sm;
			done := true;
			end
		end else
		begin
		sendstring ("No more messages to ");
		sendstring (uto);
		sendstring (".\n");
		done := true;
		end;
	end;
freestring (fstr);
end;

procedure scan_re (uto : string; dir : short);

var	sm	: short;
	done	: boolean;
	fstr	: string;

begin
fstr := allocstring (90);
sm := curmessage;
done := false;
while not done do
	begin
	sendstring (".");
	sm := sm + dir;
	if (sm <= bbsinfo.lmsg[cb]) and (sm >= bbsinfo.fmsg[cb]) then
		begin
		pre_read_message (sm, fstr, MH_Read);
		if strieq (adr(MH_Read.re), uto) then
			begin
			if read_message (sm) then;
			curmessage := sm;
			done := true;
			end
		end else
		begin
		sendstring ("No more messages about '");
		sendstring (uto);
		sendstring (".'\n");
		done := true;
		end;
	end;
freestring (fstr);
end;

function verify_message (num : short) : boolean;

const	ct : string = "MESS:A/";

begin
ct[5] := curbranch;
verify_message := verify_file (ct, "", num);
end;

procedure pre_read_message (num : short; var fstr : string;
			var MH : message_header);

var	numstr		: string;
	ss		: string;
	gf		: text;
	test		: char;
	i		: short;
	ok		: boolean;

begin
numstr := allocstring (90);
strcpy (numstr, "");
strcpy (fstr, "MESS:A/");
fstr[5] := curbranch;
if IntToStr (numstr, num) <> 0 then;
strcat (fstr, numstr);

ok := reopen (fstr, gf);
if ok then
   with MH do
	begin
	readln (gf, num);
	ss := string(adr(userto));
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
freestring (numstr);
end;

procedure scan_message (msg : short);

var	fs	: string;
	MH_Scan	: message_header;

begin
fs := allocstring (80);
pre_read_message (msg, fs, MH_Scan);
sendnum (msg);
sendstring (". To > ");
sendstring (adr(MH_Scan.userto));
sendstring ("   From > ");
sendstring (adr(MH_Scan.userfrom));
sendstring ("   Re > ");
sendstring (adr(MH_Scan.re));
sendstring ("\n");
freestring (fs);
end;

function read_message (num : short) : boolean;

var	i		: integer;
	test, ch	: char;
	fstr, b		: string;
	ok		: boolean;
	gf		: text;
	s		: integer;

begin
fstr := allocstring (90);
b := allocstring (90);
if verify_rank (bbsinfo.readrank[cb]) then
	begin
	pre_read_message (num, fstr, MH_Read);
	if reopen (fstr, gf) then
		begin
			close (gf);
			print_header (MH_Read);
			ok := true;
			send_file (fstr, sf_skiphead);
		end else ok := false;
	end else begin
	ok := true;
	sendstring (bbsdata[120]);
	end;
freestring (fstr);
freestring (b);
read_message := ok;
end;

{

*************
*  Main.p  **
*************

}

Procedure bbs;

var 	ch	: char;
	ufile	: file of user;
	st	: string;

begin
st := allocstring (90);
reset_modem;
loadindex;
strcpy (adr(lastuser), bbsdata[114]);
strcpy (adr(scratch), bbsdata[115]);
while true do
	begin
	if local then
		begin
		online := true;
		clearcuruser;
		getdefBBSprefs;
		login;
		saveindex;
		saveuser;
		end else
		begin
		if answer_phone then
			begin
			clearcuruser;
			getdefBBSprefs;
			login;
			purge_line;
			reset_modem;
			online := false;
			saveindex;
			saveuser;
			end;
		end;
	end;
end;

procedure werein;

var	m, s			: integer;
	b			: string;

begin
for m := 1 to 25 do curuser.handle[m] := toupper(curuser.handle[m]);
for m := 1 to 25 do curuser.name[m] := toupper(curuser.name[m]);
SetWindowTitles(w, adr(curuser.handle), adr(curuser.handle));
clear_terminal;
sendstring (bbsdata[78]);
sendstring (adr(CurUser.handle));
sendstring (".\n");
if not local then
	begin
	inc(bbsinfo.calls);
	inc(curuser.calls);
	Sendstring (bbsdata[79]);
	sendnum (bbsinfo.calls);
	sendstring (".\n");
	Sendstring (bbsdata[80]);
	sendnum (curuser.calls);
	sendstring (bbsdata[81]);
	sendstring (bbsdata[112]);
	sendstring (adr(lastuser));
	if strlen (adr(scratch)) > 1 then
		begin
		sendstring (bbsdata[113]);
		sendstring (adr(scratch));
		sendstring ("\"");
		end else sendstring (bbsdata[50]);
	end;
sendstring ("\n\n");
sendstring (bbsdata[121]);
CurrentTime(S, M);
b := allocstring (50);
Time_Info (b, s);
sendstring (b);
sendstring ("\n\n");
freestring (b);
curuser.S := S;
saveuser;
tapreturn;
if read_my_mail then
	begin
	curmail := 0;
	get_next_mail;
	curmenu := mail_menu;
	end;
end;

procedure login;

var	temp : integer;
	ct   : char;
	tms  : string;
	t    : array [1..90] of char;
	trycount : short;

begin
send_file("BBSTXT:login.txt", sf_none);
purge_line;
check_userfile;
tms := adr(t[1]);
t[1] := '\0';
curbranch := 'A';
trycount := 0;
strcpy (tms, "");
while (not(strieq(adr(CurUser.password),tms) and check_carrier)
	and (trycount < 3)) do
	begin
	sendstring(bbsdata[17]);
	strcpy (tms, "");
	readstring(tms, "", 30, rs_password + rs_overboard);
	inc (trycount);
	end;
if not (strieq(adr(CurUser.password),tms)) or (trycount >=3) then
	begin
        sendstring(bbsdata[54]);
	purge_line;
	hang_up;
	end else main;
end;

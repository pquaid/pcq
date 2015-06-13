procedure chat_withem (sysop : short);

var	cj	: char;

	curpos	: short;
	slc	: short;

	saveline: array [0..255] of char;
	tsl	: array [0..255] of char;

	twonewline : boolean;

	procedure addchar (ch : char);
		forward;

	procedure chat_prompt;

	var	I : short;
		s : string;

	begin
	if not usermask then
		begin
		sendstring ("\n");
		s := adr(curuser.handle);
		I := 0;
		while s[I] <> char(0) do
			begin
			addchar (s[I]);
			inc (i);
			end;
		addchar (' ');
		addchar ('>');
		addchar (' ');
		end else
		begin
		sendstring ("\n");
		s := bbsdata[sysop];
		I := 0;
		while s[I] <> char(0) do
			begin
			addchar (s[I]);
			inc (i);
			end;
		addchar (' ');
		addchar ('>');
		addchar (' ');
		end;
	end;

	procedure newline;

	begin
	if twonewline then
		begin
		twonewline := FALSE;
		cj := char(0);
		usermask := not usermask;
		chat_prompt;
		end else
		begin
		sendstring ("\n");
		curpos := 0;
		end;
	twonewline := TRUE;
	end;

	procedure addchar (ch : char);

	begin
	twonewline := FALSE;
	if(ord (ch) >= 32) then
	    begin
	    if (curpos < (ord(curuser.cols)-2)) then
		begin
		sendchar (ch);
		saveline[curpos] := ch;
		inc (curpos);
		end
		else
		begin
		slc := 0;
		while (not isspace(saveline[curpos])) and (curpos > 0) do
			begin
			tsl [slc] := saveline[curpos];
			saveline[curpos] := char(0);
			dec (curpos);
			sendstring ("\b \b");
			inc (slc);
			end;
		dec (slc);
		if curpos > 0 then
			begin
			newline;
			if slc > 0 then
				repeat
					addchar(tsl[slc]);
					dec(slc);
				until slc = 0;
			addchar(ch);
			end else
			begin
			if slc > 0 then
				repeat
					addchar(tsl[slc]);
					dec(slc);
				until slc = 0;
			newline;
			addchar(ch);
			end;
		end;
	    end else sendbeep;
	end;

begin
twonewline := false;
curpos := 0;

rc := false;
cj := char(0);

usermask := true;

chat_prompt;

while (cj <> char (24)) do
	begin
	cj := readchar;
	case ord(cj) of
		24 : if not usermask then cj := char(0);
		26 : rc := not rc;
		13 : newline;
		8, 127 : if (curpos > 0) then
			begin
			sendstring ("\b \b");
			dec(curpos);
			end;
		32..126 : addchar (cj);
		end;

	end;
usermask := false;
end;

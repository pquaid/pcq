{
 _______________________________________________________________
|								|
| Message-Getter-Better (MGB) by Chris Pressey			|
|								|
| Christening : Sept 13, AD 1991				|
| CEBBS debut : Sept 20, AD 1991				|
|_______________________________________________________________|

}

procedure delchar (var st : string; pos : short);

begin
while st[pos] <> char(0) do
	begin
	st[pos] := st[pos + 1];
	inc (pos);
	end;
end;

procedure MGB (st : string; number : integer);

var
	ms		: array [0..40] of string;
	i		: integer;
	done		: boolean;
	curline,
	lastline,
	curpos		: short;
	ch		: array [0..3] of char;
	saveline	: array [0..179] of char;
	slc		: short;
	r		: string;

	procedure newline;

	begin
	sendchar (char(10));
	if curline = lastline then inc(lastline);
	inc(curline);
	if lastline > 39 then
		begin
		Sendstring ("Message too long! :(\n");
		lastline := 39;
		curline := 39;
		end;
	sendstring ("[");
	sendnum (curline);
	if curline < 10 then sendstring (" ");
	sendstring ("] ");
	if strlen (ms[curline]) > 0 then sendstring (ms[curline]);
	curpos := strlen (ms[curline]);
	end;

	procedure addchar (ch : char);

	var	r : string;

	begin
	if(ord (ch) >= 32) then
	    begin
	    if (curpos < (ord(curuser.cols)-7)) then
		begin
		sendchar(ch);
		r := ms[curline];
		r[curpos] := ch;
		inc (curpos);
		end
		else
		begin
		r := ms[curline];
		slc := 0;
		while (not isspace(r[curpos])) and (curpos > 0) do
			begin
			saveline [slc] := r[curpos];
			r[curpos] := char(0);
			dec (curpos);
			sendstring ("\b \b");
			inc (slc);
			end;
		inc (curpos);
		r[curpos] := char (26);
		inc (curpos);
		r[curpos] := char(0);
		dec (slc);
		if curpos <> 0 then
			begin
			newline;
			if slc > 0 then
				repeat
					addchar(saveline[slc]);
					dec(slc);
				until slc = 0;
			addchar(ch);
			end else
			begin
			if slc > 0 then
				repeat
					addchar(saveline[slc]);
					dec(slc);
				until slc = 0;
			newline;
			addchar(ch);
			end;
		end;
	    end else sendbeep;
	end;

	procedure drawmessage;

	begin
	sendstring ("MGB v1.00 - CEBBS Text Editor. Type .H on a fresh line for help.\n");
	send_delimeter;
	for i := 0 to lastline do
		begin
		sendstring ("[");
		sendnum (i);
		if i < 10 then sendstring (" ");
		sendstring ("] ");
		sendstring (ms[i]);
		if i <> lastline then sendstring ("\n");
		end;
	end;

	procedure backspace;

	var r : string;

	begin
	if (curpos > 0) then
		begin
		dec (curpos);
		sendstring ("\b \b");
		delchar(ms[curline], curpos);
		if curuser.haveansi <> 'A' then sendstring ("[P");
		end
		else
		begin
		if curuser.haveansi = 'A' then r[curpos] := char(0);
		if (curline > 0) then
			begin
			dec (curline, 2);
			if curuser.haveansi <> 'A' then sendstring ("[2A[4D");
			newline;
			end;
		end;
	end;

	procedure edit_line;

	var	l : short;

	begin
		sendstring ("Edit which line (0 - ");
		sendnum (lastline);
		sendstring (") ? ");
		l := readnum ("0");
		sendstring ("Enter replacement line :\n[>>] ");
		readstring (ms[l], "", ord(curuser.cols), rs_none);
		drawmessage;
	end;

	procedure insert_line;

	var	l, i	: short;
		m	: string;

	begin
		m := allocstring (ord(curuser.cols));
		sendstring ("Insert line before which line (0 - ");
		sendnum (lastline);
		sendstring (") ? ");
		l := readnum ("0");
		sendstring ("Enter insertion line :\n[>>] ");
		readstring (m, "", ord(curuser.cols), rs_none);
		inc (lastline);
		inc (curline);
		for i := (lastline) downto (l) do
			strcpy (ms[i+1], ms[i]);
		strcpy (ms[l], m);
		drawmessage;
		freestring (m);
	end;

	procedure delete_line;

	var	l, i : short;

	begin
		sendstring ("Delete which line (0 - ");
		sendnum (lastline);
		sendstring (") ? ");
		l := readnum ("0");
		for i := (l) to (lastline - 1) do
			strcpy (ms[i], ms[i+1]);
		strcpy (ms[lastline], "");
		drawmessage;
	end;

begin
abort := false;
curline := 0;
curpos := 0;
lastline := 0;
done := false;
for I := 0 to 40 do
	begin
	ms[i] := allocstring (ord(curuser.cols) + 10);
	strcpy (ms[i], "");
	end;

drawmessage;

while (not done) do
	begin
	ch[0] := readchar;
	case ord(ch[0]) of
		27    : if curuser.haveansi <> 'A' then begin
			ch[1] := readchar;
			if ch[1] = '[' then
				begin
				ch[2] := readchar;
				case ch[2] of
					'A' : if curline > 0 then
						begin
						dec(curline);
						sendstring("[A");
						end else sendbeep;
					'B' : if curline < lastline then
						begin
						inc(curline);
						sendstring("[B");
						end else sendbeep;
					'D' : if curpos > 0 then
						begin
						dec(curpos);
						sendstring("[D");
						end else sendbeep;
					'C' : if curpos < ord(curuser.cols) then
						begin
						inc(curpos);
						sendstring("[C");
						end else sendbeep;
					end;
				end;
			end;
		13 :	newline;
		8, 127 :	backspace;
		46, 92, 47 :	if curpos = 0 then
				begin
				if curline <> lastline then
					begin
					curline := lastline;
					clear_terminal;
					drawmessage;
					end;
				sendstring ("\b\b\b\b\b[Ed] ");
				ch[1] := toupper(readchar);
				case ch[1] of
					'S' : begin
						done := true;
						Sendstring ("Saving ... \n");
						end;
					'R' : begin
						clear_terminal;
						drawmessage;
					      end;
					'A' : begin
						sendstring ("Abort : are you sure (Y/N) ? ");
						if readoption ('Y','N') = 'Y' then
							begin
							abort := true;
							done := true;
							end else
							begin
							clear_terminal;
							drawmessage;
							end;
						end;
					'?', 'H' : begin
						send_file ("BBSTXT:MGB_help.txt", sf_none);
						tapreturn;
						clear_terminal;
						drawmessage;
						end;
					'.' : addchar ('.');
					'\\' : addchar ('\\');
					'/' : addchar ('/');
					'E' : edit_line;
					'I' : insert_line;
					'D' : delete_line;
					else
						begin
						sendbeep;
						sendstring ("\b\b\b\b\b[");
						sendnum (curline);
						if curline < 10 then sendstring (" ");
						sendstring ("] ");
						end;
					end;
				end else addchar(ch[0]);
		else	addchar(ch[0]);
	   end;
   end;
strcpy (st, "");
for i := 0 to lastline do
	begin
	r := ms[i];
	if (r[strlen(r)-1] = char(26)) then
		begin
		r[strlen(r)-1] := char (0);
		strcat (st, ms[i]);
		end else
		begin
		strcat (st, ms[i]);
		strcat (st, "\n");
		end;
	end;
for i := 0 to 40 do freestring (ms[i]);
end;

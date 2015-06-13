procedure saveresults;

var	rs	: string;
	i	: short;
	tx	: text;

begin
rs := allocstring (80);
strcpy (rs, "RESULT:");
strcat (rs, adr(curuser.handle));
if open (rs, tx) then
	begin
	write (tx, results);
	close (tx);
	end;
freestring (rs);
end;

procedure loadresults (per : string);

var	rs	: string;
	i	: short;
	tx	: text;

begin
for i := 1 to 100 do results[i] := '@';
rs := allocstring (80);
strcpy (rs, "RESULT:");
strcat (rs, per);
if not reopen (rs, tx) then
	saveresults else
	begin
	read (tx, results);
	close (tx);
	end;
freestring (rs);
end;

procedure poll (fspec : string);

var	t	: text;
	noq,i,j,
	noc	: short;
	ts	: string;
	c1, c2	: char;
	chz	: char;

begin
loadresults (adr(curuser.handle));
ts := allocstring (100);
if reopen (fspec, t) then
	begin
	readln (t, ts);
	if strieq (ts, "poll") then
	begin
		readln (t, noq);
		sendstring (bbsdata[116]);
		sendnum (noq);
		sendstring (" :\n");
		readln (t, ts);
		sendstring (ts);
		sendstring ("\n\n");
		readln (t, noc);
		for j := 1 to noc do
			begin
			readln (t, ts);
			sendstring (ts);
			sendstring ("\n");
			end;
		sendstring ("\nYour previous vote was :");
		if results[noq] <> '@' then
			sendchar (results[noq]) else
			sendstring (" you have not voted");
		sendstring ("\n");
		sendstring (bbsdata[117]);
		c1 := 'A';
		c2 := char(ord(c1)+noc-1);
		repeat
			chz := readoption (c1, c2);
		until isalpha (chz);
		results[noq] := chz;
		end;
	close (t);
	end;
saveresults;
sendstring("\n");
freestring (ts);
end;

procedure seeresults (qn : short; fspec : string);

var	tf, zf		: text;
	s, s2, s3	: string;
	ch		: char;
	i, noq, noc, j	: short;
	v		: array ['A'..'Z'] of short;
	pc		: array ['A'..'Z'] of real;

begin
s := allocstring (80);
s2 := allocstring (80);
s3 := allocstring (80);
for ch := 'A' to 'Z' do
	begin
	v[ch] := 0;
	pc[ch] := 0.0;
	end;
exec_command ("list >ram:uler RESULT: quick nohead sort");
if reopen ("ram:uler", tf) then
	begin
	while not eof(tf) do
		begin
		readln (tf, s);
		loadresults (s);
		if isalpha(results[qn]) then
			inc(v[results[qn]]);
		end;
	close (tf);
	end;

if reopen (fspec, zf) then
	begin
	readln (zf, s3);
	if strieq (s3, "poll") then
	begin
		readln (zf, noq);
		sendstring (bbsdata[116]);
		sendnum (noq);
		sendstring (" :\n");
		readln (zf, s3);
		sendstring (s3);
		sendstring ("\n\n");
		readln (zf, noc);
		for j := 1 to noc do
			begin
			readln (zf, s3);
			sendnum (v[char(j-1+ord('A'))]);
			case v[char(j-1+ord('A'))] of
				0..9 : sendstring ("   ");
				10..99 : sendstring ("  ");
				100..999 : sendstring (" ");
				end;
			sendstring (s3);
			sendstring ("\n");
			end;
		sendstring ("\n");
		end;
	close (zf);
	end;
freestring (s);
freestring (s2);
freestring (s3);
end;

procedure snoop_results (name : string);

var	tf, zf		: text;
	i		: short;

begin
loadresults ("Cat's Eye");
results2 := results;
loadresults (name);

for i := 1 to 100 do
	if (results2[i] <> '@') then
		begin
		sendnum (i);
		sendstring (" > ");
		sendchar (results[i]);
		sendstring ("\n");
		end;
end;

procedure add_poll;

var
	f	: text;
	st, s2	: string;
	v1, v2	: short;
	i	: short;

begin
s2 := allocstring (80);
st := allocstring (80);
clear_terminal;
sendstring ("What is the title of this poll ? ");
readstring (st, "A poll", 79, rs_none);
strcpy (s2, "VOTE:");
strcat (s2, st);
sendstring ("What poll number is this poll ? ");
v1 := readnum ("1");
sendstring ("How many choices are there in this poll ? ");
v2 := readnum ("10");
if open (st, f) then
	begin
	writeln (f, "poll");
	writeln (f, v1);
	sendstring ("What question does this poll ask ? ");
	readstring (st, "WHY?!?", 79, rs_none);
	writeln (f, st);
	writeln (f, v1);
	for i := 1 to v2 do
		begin
		sendnum (i);
		sendstring (" > ");
		readstring (st, "No opinion.", 79, rs_none);
		writeln (f, st);
		end;
	end;
freestring (st);
freestring (s2);
end;

External;

{
	IO.p (of PCQ Pascal)
	Copyright (c) 1989 Patrick Quaid

	This module handles the IO of the compiler.  The actual
compilation of the io statements is handled in stanprocs.p
}

{$O-}
{$I "Pascal.i"}
{$I "Include/Libraries/DOS.i" }
{$I "Include/Utils/StringLib.i"}
{$I "Include/Utils/Break.i"}


Function EndOfFile() : Boolean;

{
    This just determines when the end of all input has occured.
}

begin
    EndOfFile := (InFile = nil) and (not CharBuffed);
end;

Procedure AnnounceFile;
begin
    if StdOut_Interactive then
	Write('\r\cK', LineNo:5, ' ', InFile^.Name, '\r');
end;

Procedure WriteLineNo;
begin
    if StdOut_Interactive then
	Write(Chr(13), LineNo:5);
end;

Procedure CountLines;

{ Does the bookkeeping for errors }

begin
    if CurrentChar = Chr(10) then begin
	LineNo := Succ(LineNo);
	if Inform then
	    if (LineNo and 15) = 0 then
		WriteLineNo;
    end;
end;

Procedure EndComment;
    forward;	{ It's in this module }

Procedure CloseInputFile;

{ This closes the current input file and restores the saved stuff }

var
    TempPtr : FileRecPtr;
begin
    if Inform and StdOut_Interactive then begin
	WriteLineNo;
	Writeln;
    end;
    Close(InFile^.PCQFile);
    TempPtr := InFile^.Previous;
    FreeString(InFile^.Name);
    Dispose(InFile);
    InFile := TempPtr;
    if InFile <> nil then begin
	LineNo := InFile^.SaveLine;
	FNStart := InFile^.SaveStart;
	CurrentChar := InFile^.SaveChar;
	if Inform then
	    AnnounceFile;
	EndComment;
    end else
	CurrentChar := Chr(0);
end;

Procedure Abort;

{
	This routine cuts out cleanly.  If you are debugging the
compiler, this is a likely place to put post mortem dumps, like the
one commented out.
}

begin
    While InFile <> nil do
	CloseInputFile;
    Close(OutFile);
    Writeln('Compilation Aborted');
    Exit(20);
end;

Function OpenInputFile(name : String) : Boolean;

{ This routine opens a new file record, and a new file.  It also
  saves the state of the File-dependant variables, like LineNo. }

var
    TempPtr : FileRecPtr;
    OpenError : Integer;
begin
    New(TempPtr);
    if not ReOpen(name, TempPtr^.PCQFile, 2048) then begin
	Dispose(TempPtr);
	OpenError := IOResult;
	OpenInputFile := False;
    end;
    TempPtr^.Previous := InFile;
    if InFile <> nil then begin
	InFile^.SaveLine := LineNo;
	InFile^.SaveStart := FNStart;
	InFile^.SaveChar  := CurrentChar;
    end;
    LineNo := 1;
    FNStart := 1;
    TempPtr^.Name := strdup(name);
    InFile := TempPtr;
    if EOF(InFile^.PCQFile) then
	CloseInputFile
    else
	Read(Infile^.PCQFile, CurrentChar);
    if Inform then
	AnnounceFile;
    OpenInputFile := True;
end;

Function EQFix(x : integer): integer;

{
	This helps implement a queue.  In this case it's for the
error queue.
}

begin
    EQFix := x and EQSize;
end;

Procedure Error(ptr : string);

{
	This just writes out at most the previous 128 characters or
two lines, then writes the error message passed to it.  If there
are five errors, it aborts.
}

var
    index : integer;
    newlines : integer;
begin
    index := EQEnd;
    newlines := 0;
    while (index <> EQStart) and (newlines < 2) do begin
	index := EQFix(index - 1);
	if ErrorQ[EQFix(index - 1)] = chr(10) then
	    newlines := newlines + 1;
    end;

    if Inform then begin
	if StdOut_Interactive then
	    write('\n\cK'); { newline, ClrEOL }
	while index <> EQEnd do begin
	    if (index = ErrorPtr) and StdOut_Interactive then
		write('\c0;33;40m');  { start highlight for ANSI }
	    write(ErrorQ[index]);
	    index := EQFix(index + 1);
	end;
	if StdOut_Interactive then
	    write('\c0;31;40m');  { end highlight }
	writeln;
	write('Line ', lineno, ' ');
	if currfn <> nil then
	    write('(', CurrFn^.Name, ')');
	writeln(': ', ptr, '\n');
    end else
	Writeln('Line ', LineNo, ' : ', ptr); { Quiet mode, no surprises }

    Inc(errorcount);
    if errorcount > 4 then
	Abort;
    if CheckBreak() then
	Abort;
    if Inform then
	AnnounceFile;
end;

Procedure ReadChar;

{ This is the main link between the lexical analysis stuff and the
  IO stuff.  It sets up CurrentChar and keeps the line count. }
var
    IOError : Integer;
begin
    if CheckBreak() then
	Abort;
    if CharBuffed then begin
	CurrentChar := BuffedChar;
	CharBuffed := False;
	return;
    end;
    if EOF(InFile^.PCQFile) then
	CloseInputFile
    else begin
	Read(InFile^.PCQFile, CurrentChar);
	IOError := IOResult;
	CountLines;
    end;
    EQEnd := EQFix(Succ(EQEnd));
    ErrorQ[EQEnd] := CurrentChar;
    if EQStart = EQEnd then
	EQStart := EQFix(Succ(EQStart));
end;

Function NextChar() : Char;
var
    c : Char;
begin
    if not CharBuffed then begin
	c := CurrentChar;
	ReadChar;
	BuffedChar := CurrentChar;
	CurrentChar := c;
	CharBuffed := True;
    end;
    NextChar := BuffedChar;
end;

Procedure EndComment;

{
	This just eats characters up to the end of a comment.  If
you want nested comments, this is probably the place to do it.
}

begin
    while (Currentchar <> '}') and (not EndOfFile()) do
	ReadChar;
    if not EndOfFile() then
	ReadChar;
end;

Function GetLabel() : integer;

{
	As in all compilers, this just returns a unique serial
number.
}

begin
    Inc(NxtLab);
    getlabel := nxtlab;
end;

Procedure PrintLabel(lab : integer);

{
	This routine prints a label based on a number from the
above procedure.  The prefix for the label can be anything the
assembler accepts - in this case I wanted it similar to the prefix
of the run time library routines.  I didn't realize how ugly it
would look.
}

begin
    write(OutFile, '_p%', lab);
end;

Function JustFileName(S : String) : String;

{ returns a string that is the file name part of a path.  It does
  NOT allocate space. }

var
    Ptr : String;
begin
    if S^ = Chr(0) then
	JustFileName := S;
    Ptr := S;
    while Ptr^ <> Chr(0) do
	Inc(Ptr);
    while (Ptr^ <> ':') and (Ptr^ <> '/') do begin
	if Ptr = S then
	    JustFileName := S;
	Dec(Ptr);
    end;
    Inc(Ptr);
    JustFileName := Ptr;
end;

Procedure AddIncludeName(S : String);

{ Adds the name of an include file to the list, so it won't be
  included again. }

var
    Ptr : IncludeRecPtr;
begin
    Ptr := IncludeRecPtr(AllocString(strlen(S) + 5));
    if Ptr = nil then
	Abort;
    strcpy(Adr(Ptr^.Name), S);
    Ptr^.Next := IncludeList;
    IncludeList := Ptr;
end;

Function AlreadyIncluded(S : String) : Boolean;

{ Determines whether a file has been included already }

var
    Ptr : IncludeRecPtr;
begin
    Ptr := IncludeList;
    while Ptr <> nil do begin
	if strieq(Adr(Ptr^.Name), S) then
	    AlreadyIncluded := True;
	Ptr := Ptr^.Next;
    end;
    AlreadyIncluded := False;
end;

Procedure DoInclude;

{
	The name says it all.  The mechanics of the include
directive are all handled here.
}

var
    Ptr : String;
begin
    ReadChar;
    While (CurrentChar <= ' ') and (not EndOfFile()) do
	ReadChar;
    if CurrentChar <> '"' then begin
	Error("Missing Quote");
	EndComment;
	Return;
    end;
    ReadChar;
    Ptr := SymText;
    while CurrentChar <> '"' do begin
	Ptr^ := CurrentChar;
	Inc(Ptr);
	if EndOfFile() then
	    Return;
	ReadChar;
    end;
    Ptr^ := Chr(0); { mark then end of the file name }
    ReadChar;		{ read the end quote }
    if not AlreadyIncluded(JustFileName(SymText)) then begin
	if OpenInputFile(SymText) then
	    AddIncludeName(JustFileName(SymText))
	else begin
	    Error("Could not open input file");
	    EndComment;
	end;
    end else
	EndComment;
end;

Procedure DoComment;

{
	This routine implements compiler directives.
}

    Procedure DoASM;
    begin
	ReadChar;
	while CurrentChar <> '}' do begin
	    Write(OutFile, currentchar);
	    if EndOfFile() then begin
		Error("File ended in a comment");
		return;
	    end;
	    ReadChar;
	end;
	ReadChar;
	Writeln(OutFile);
    end;

    Procedure DoOnOff(var Flag : Boolean);
    begin
	ReadChar;
	if CurrentChar = '+' then
	    Flag := True
	else if CurrentChar = '-' then
	    Flag := False;
    end;

    Procedure DoStorage;
    var
	KillChar : Boolean;
    begin
	ReadChar;
	KillChar := True;
	case CurrentChar of
	  'X' : StandardStorage := st_external;
	  'P' : StandardStorage := st_private;
	  'N' : StandardStorage := st_internal;
          'D' : if MainMode then
		    StandardStorage := st_internal
		else
		    StandardStorage := st_external;
	else begin
		Error("Unknown storage class");
		KillChar := False;
	     end;
	end;
	if KillChar then
	    ReadChar;
    end;

begin
    readchar;
    if currentchar = '$' then begin
	repeat
	    readchar; { either $ or , }
	    Case CurrentChar of
	      'I' : begin
			DoInclude;
			return;
		    end;
	      'A' : begin
			DoASM;
			return;
		    end;
	      'R' : DoOnOff(RangeCheck);
	      'O' : DoOnOff(IOCheck);
	      'S' : DoStorage;
	    else begin
		    Error("Unknown Directive");
		    EndComment;
		    return;
		 end;
	    end;
	    if (CurrentChar <> ',') or EndOfFile then begin
		EndComment;
		return;
	    end;
	until false;
    end else
	EndComment;
end;

Function Alpha(c : char): boolean;

{
	This function answers the eternal question "is this
character an alphabetic character?"  Note that _ is.
}

begin
    c := toupper(c);
    Alpha := ((c >= 'A') and (c <= 'Z')) or (c = '_');
end;

Function AlphaNumeric(c : char): boolean;

{
	Is the character a letter or digit?
}

begin
    AlphaNumeric := Alpha(c) or isdigit(c);
end;

Procedure Header;

{
	This routine references all the run time library routines.
One thing I like about A68k is that the only routines that are
used in the assembly code end up in the object file.  Maybe all
assemblers do it, but I don't know.
}

begin
    writeln(OutFile, "* Pascal compiler intermediate assembly program.\n\n");
    writeln(OutFile, "\tSECTION\tPCQMain\n");
    writeln(OutFile, "\tXREF\t_Input");
    writeln(OutFile, "\tXREF\t_Output");
    writeln(OutFile, "\tXREF\t_p%WriteInt");
    writeln(OutFile, "\tXREF\t_p%WriteReal");
    writeln(OutFile, "\tXREF\t_p%WriteChar");
    writeln(OutFile, "\tXREF\t_p%WriteBool");
    writeln(OutFile, "\tXREF\t_p%WriteCharray");
    writeln(OutFile, "\tXREF\t_p%WriteString");
    writeln(OutFile, "\tXREF\t_p%WriteLn");
    writeln(OutFile, "\tXREF\t_p%ReadInt");
    writeln(OutFile, "\tXREF\t_p%ReadReal");
    writeln(OutFile, "\tXREF\t_p%ReadCharray");
    writeln(OutFile, "\tXREF\t_p%ReadChar");
    writeln(OutFile, "\tXREF\t_p%ReadString");
    writeln(OutFile, "\tXREF\t_p%ReadLn");
    writeln(OutFile, "\tXREF\t_p%ReadArb");
    writeln(OutFile, '\tXREF\t_p%FilePtr');
    writeln(OutFile, '\tXREF\t_p%Get');
    writeln(OutFile, '\tXREF\t_p%Put');
    writeln(OutFile, "\tXREF\t_p%dispose");
    writeln(OutFile, "\tXREF\t_p%new");
    writeln(OutFile, "\tXREF\t_p%Open");
    writeln(OutFile, "\tXREF\t_p%WriteArb");
    writeln(OutFile, "\tXREF\t_p%Close");
    writeln(OutFile, "\tXREF\t_p%exit");
    writeln(OutFile, "\tXREF\t_p%lmul");
    writeln(OutFile, "\tXREF\t_p%ldiv");
    writeln(OutFile, "\tXREF\t_p%lrem");
    writeln(OutFile, "\tXREF\t_p%MathBase");
    writeln(OutFile, '\tXREF\t_p%sin');
    writeln(OutFile, '\tXREF\t_p%cos');
    writeln(OutFile, '\tXREF\t_p%sqrt');
    Writeln(OutFile, '\tXREF\t_p%tan');
    Writeln(OutFile, '\tXREF\t_p%atn');
    Writeln(OutFile, '\tXREF\t_p%ln');
    Writeln(OutFile, '\tXREF\t_p%exp');
    Writeln(OutFile, '\tXREF\t_p%CheckIO');
    Writeln(OutFile, '\tXREF\t_p%CheckRange\n');
    if mainmode then begin
	writeln(OutFile, "\tXREF\t_p%initialize");
	writeln(OutFile, "\tjsr\t_p%initialize");
	writeln(OutFile, "\tjsr\t_MAIN");
	writeln(OutFile, '\tmoveq\t#0,d0');
	writeln(OutFile, "\tjsr\t_p%exit");
	writeln(OutFile, "\trts");
    end
end;

Procedure Trailer;

{
	This routine is the most important in the compiler
}

begin
    writeln(OutFile, "\tEND");
end;

Procedure Blanks;

{
	blanks() skips spaces, tabs and eoln's.  It handles
comments if it comes across one.
}

var
    done : boolean;
begin
    while ((CurrentChar <= ' ') or (CurrentChar = '{')) and
	  (not EndOfFile()) do begin
	if CurrentChar = '{' then
	    DoComment
	else
	    ReadChar;
    end;
end;

Procedure DumpLitQ(k : Integer);

{
	This procedure dumps the literal table at the end of the
compilation.  Individual components are referenced as offsets to
the literal label.
}

var
    j		: integer;
    quotemode	: boolean;
begin
    while k < litptr do begin
	write(OutFile, "\tdc.b\t");
	j := 0;
	quotemode := false;
	while j < 40 do begin
	    if (ord(litq[k]) > 31) and (ord(litq[k]) <> 39) then begin
		if quotemode then
		    write(OutFile, litq[k])
		else begin
		    if j > 0 then
			write(OutFile, ',');
		    write(OutFile, chr(39), litq[k]);
		    quotemode := true;
		end;
	    end else begin
		if quotemode then begin
		    write(OutFile, chr(39));
		    quotemode := false;
		end;
		if j > 0 then
		    write(OutFile, ',');
		write(OutFile, ord(litq[k]));
		if j > 32 then
		    j := 40
		else
		    j := j + 3;
	    end;
	    j := j + 1;
	    k := k + 1;
	    if k >= litptr then
		j := 40;
	end;
	if quotemode then
	    write(OutFile, chr(39));
	writeln(OutFile);
    end
end;

Procedure DumpLits;
begin
    if LitPtr = 0 then
	return;
    writeln(OutFile, '\n\tSECTION\tLITS,DATA');
    PrintLabel(LitLab);
    DumpLitQ(0);
end;

Procedure DumpIds;

{
	This routine does whatever is appropriate with the various
identifers.  If it's a global, it either references it or allocates
space.  Similar stuff for the other ids.  When the modularity of
PCQ is better defined, this routine will have to do more work.
}

var
    CB		: BlockPtr;
    ID		: IDPtr;
    TP		: TypePtr;
    i		: Integer;
    isodd	: boolean;
    WroteSection : Boolean;
begin
    WroteSection := False;
    isodd := false;
    CB := CurrentBlock;
    while CB <> nil do begin
	for i := 0 to Hash_Size do begin
	    ID := CB^.Table[i];
	    while ID <> nil do begin
		case ID^.Object of
		  global : case ID^.Storage of
			    st_internal,
			    st_private  : begin
					    if not WroteSection then begin
						writeln(OutFile, "\n\tSECTION\tSTORAGE,BSS\n");
						WroteSection := True;
					    end;
					    TP := ID^.VType;
					    if isodd and (TP^.Size > 1) then begin
						Writeln(OutFile, "\tCNOP\t0,2");
						isodd := False;
					    end;
					    if ID^.Storage <> st_private then
						Writeln(OutFile,"\tXDEF\t_", ID^.Name);
					    Write(OutFile, '_', ID^.Name);
					    Writeln(OutFile, "\tds.b\t", TP^.Size);
					    if odd(TP^.Size) then
						isodd := not isodd;
					  end;
			   end;
		  proc,
		  func  : if ID^.Storage = st_forward then
				Writeln(ID^.Name, ' was never defined.');
		end;
		ID := ID^.Next;
	    end;
	end;
	CB := CB^.Previous;
    end;
end;

Procedure DumpRefs;

{
	This routine makes all the external references necessary.
}

var
    CB		: BlockPtr;
    ID		: IDPtr;
    i		: Integer;
begin
    writeln(OutFile);
    CB := CurrentBlock;
    while CB <> nil do begin
	for i := 0 to Hash_Size do begin
	    ID := CB^.Table[i];
	    while ID <> nil do begin
		if ID^.Storage = st_external then
		    writeln(OutFile, "\tXREF\t_", ID^.Name);
		ID := ID^.Next;
	    end;
	end;
	CB := CB^.Previous;
    end
end;

Procedure SearchReserved;

{
	This just does a binary chop search of the list of reserved
words.
}

var
    top,
    middle,
    bottom	: Symbols;
    compare	: Short;
begin
    Bottom := And1;
    Top := LastReserved;
    while Bottom <= Top do begin
	middle := Symbols((Short(bottom) + Short(top)) div 2);
	Compare := stricmp(Reserved[Middle], SymText);
	if Compare = 0 then begin
	    CurrSym := Middle;
	    Return;
	end else if Compare < 0 then
	    Bottom := Succ(Middle)
	else
	    Top := Pred(Middle);
    end;
    CurrSym := Ident1;
end;

Procedure ReadWord;

{
	This reads a Pascal identifier into symtext.
}

var
    ptr		: string;
begin
    ptr := symtext;
    repeat
	Ptr^ := CurrentChar;
	Ptr := String(Integer(Ptr) + 1);
	ReadChar;
    until not AlphaNumeric(CurrentChar);
    Ptr^ := chr(0);
    SearchReserved;
end;

Function DigVal(c : Char) : Integer;
begin
    DigVal := Ord(c) - Ord('0');
end;

Procedure ReadNumber;

{
	This routine reads a literal integer.  Note that _ can be used.
}

var
    Divider : Real;
    Fraction : Real;
begin
    SymLoc := 0;
    While isdigit(CurrentChar) do begin
	SymLoc := (SymLoc * 10) + DigVal(CurrentChar);
	ReadChar;
	if CurrentChar = '_' then
	    ReadChar;
    end;
    CurrSym := Numeral1;
    if (CurrentChar = '.') and isdigit(NextChar()) then begin { It's real! }
	ReadChar; { skip the . }
	RealValue := Float(SymLoc);
	Divider := 1.0;
	Fraction := 0.0;
	while isdigit(CurrentChar) do begin
	    Fraction := Fraction * 10.0 + Float(DigVal(CurrentChar));
	    Divider := Divider * 10.0;
	    ReadChar;
	end;
	RealValue := RealValue + Fraction / Divider;
	CurrSym := RealNumeral1;
    end;
end;

Procedure ReadHex;

{
	readhex() reads a hexadecimal number.
}

var
   rc : integer;
begin
    ReadChar;
    symloc := 0;
    rc := ord(toupper(currentchar));
    while isdigit(currentchar) or
	  ((rc >= ord('A')) and (rc <= ord('F'))) do begin
	SymLoc := SymLoc shl 4;
	if isdigit(currentchar) then
	    symloc := symloc + ord(currentchar) - ord('0')
	else
	    symloc := symloc + rc - ord('A') + 10;
	ReadChar;
	rc := ord(toupper(currentchar));
    end;
    currsym := numeral1;
end;

Procedure WriteHex(num : integer);

{
	This writes full 32 bit hexadecimal numbers.
}

var
    numary  : array [1..8] of char;
    pos     : integer;
    ch      : Short;
begin
    pos := 8;
    while (num <> 0) and (pos > 0) do begin
	ch := num and 15;
	if ch < 10 then
	    numary[pos] := chr(ch + ord('0'))
	else
	    numary[pos] := chr(ch + ord('A') - 10);
	pos := pos - 1;
	num := num shr 4;
    end;
    if pos = 8 then begin
	pos := 7;
	numary[8] := '0';
    end;
    write(OutFile, '$');
    for num := pos + 1 to 8 do
	write(OutFile, numary[num]);
end;

Procedure NextSymbol;

{
	This is the workhorse lexical analysis routine.  It sets
currsym to the appropriate symbol number, sets symtext equal to
whatever identifier is read, and symloc to the value of a literal
integer.
}

begin
    ErrorPtr := EQEnd;
    Blanks;
    if EndOfFile then begin
	CurrentChar := Chr(0);
	CurrSym := EndText1; { I don't think this routine is ever hit }
	Return;
    end;
    if Alpha(CurrentChar) then
	readword
    else if isdigit(currentchar) then
	readnumber
    else begin
	case CurrentChar of
	  '[' : begin
		    CurrSym:= leftbrack1;
		    ReadChar;
		end;
	  ']' : begin
		    CurrSym:= rightbrack1;
		    ReadChar;
		end;
	  '(' : begin
		    CurrSym:= leftparent1;
		    ReadChar;
		end;
	  ')' : begin
		    CurrSym:= rightparent1;
		    ReadChar;
		end;
	  '+' : begin
		    CurrSym := plus1;
		    ReadChar;
		end;
	  '-' : begin
		    CurrSym := minus1;
		    ReadChar;
		end;
	  '*' : begin
		    CurrSym:= asterisk1;
		    ReadChar;
		end;
	  '/' : begin
		    CurrSym := RealDiv1;
		    ReadChar;
		end;
	  '<' : begin
		    ReadChar;
		    if CurrentChar = '=' then begin
			CurrSym := notgreater1;
			ReadChar;
		    end else if currentchar = '>' then begin
			CurrSym := notequal1;
			ReadChar;
		    end else
			CurrSym:= less1;
		end;
	  '=' : begin
		    CurrSym:= equal1;
		    ReadChar;
		end;
	  '>' : begin
		    ReadChar;
		    if CurrentChar = '=' then begin
			CurrSym:= notless1;
			ReadChar;
		    end else
			CurrSym:= greater1;
		end;
	  ':' : begin
		    ReadChar;
		    if CurrentChar = '=' then begin
			CurrSym:= Becomes1;
			ReadChar;
		    end else
			CurrSym:= colon1;
		end;
	  ',' : begin
		    CurrSym:= comma1;
		    ReadChar;	
		end;
	  '.' : begin
		    ReadChar;
		    if CurrentChar = '.' then begin
			CurrSym:= DotDot1;
			ReadChar;
		    end else
			CurrSym:= period1;
		end;
	  ';' : begin
		    CurrSym:= semicolon1;
		    ReadChar;
		end;
	  '\'': begin
		    CurrSym:= apostrophe1;
		    ReadChar;
		end;
	  '"' : begin
		    CurrSym:= quote1;
		    ReadChar;
		end;
	  '^' : begin
		    CurrSym:= carat1;
		    ReadChar;
		end;
	  '@' : begin
		    CurrSym := At1;
		    ReadChar;
		end;
	  '$' : ReadHex;
	 '\0' : CurrSym := EndText1;
	else begin
		Error("Unknown symbol.");
		ReadChar;
	     end;
	end; { Case }
    end { Else }
end;

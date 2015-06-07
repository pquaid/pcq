External;

{
	ID_IO.p
}

{$O-}
{$I "Identify.i"}
{$I "Include:Libraries/DOS.i" }
{$I "Include:Utils/StringLib.i"}
{$I "Include:Utils/Break.i"}




Function EndOfFile() : Boolean;

{
    This just determines when the end of all input has occured.
}

begin
    EndOfFile := (InFile = nil) and (not CharBuffed);
end;

Procedure AnnounceFile;
begin
end;

Procedure WriteLineNo;
begin
end;


Procedure CountLines;

{ Does the bookkeeping for errors }

begin
    if CurrentChar = Chr(10) then begin
	LineNo := Succ(LineNo);
    end;
end;

Procedure EndComment;
    forward;	{ It's in this module }

Procedure CloseInputFile;

{ This closes the current input file and restores the saved stuff }

var
    TempPtr : FileRecPtr;
begin
    Close(InFile^.PCQFile);
    TempPtr := InFile^.Previous;
    FreeString(InFile^.Name);
    Dispose(InFile);
    InFile := TempPtr;
    if InFile <> nil then begin
	LineNo := InFile^.SaveLine;
	FNStart := InFile^.SaveStart;
	CurrentChar := InFile^.SaveChar;
	InputName := strdup(Infile^.Name);
	EndComment;
    end else
	CurrentChar := Chr(0);
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
    InputName := strdup(InFile^.Name);
    OpenInputFile := True;
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
    Writeln('Compilation Aborted');
    Exit(20);
end;


Function EQFix(x : integer): integer;

{
	This helps implement a queue.  In this case it's for the
error queue.
}

begin
    if x = -1 then
	EQFix := EQSize
    else
	EQFix := x mod (Succ(EQSize));
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

    Writeln('Line ', LineNo, ' : ', ptr); { Quiet mode, no surprises }

    Inc(errorcount);
    if errorcount > 4 then
	Abort;
    if CheckBreak() then
	Abort;
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

Function JustFileName(S : String) : String;

{ returns a string that is the file name part of a path.  It does
  NOT allocate space. }

var
    Ptr : String;
begin
    if S^ = Chr(0) then
	JustFileName := S;
    Ptr := String(Integer(S) + strlen(s) - 1);
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
    Ptr := IncludeRecPtr(AllocString(strlen(S) + 13));
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
	    if EndOfFile() then begin
		Error("File ended in a comment");
		return;
	    end;
	    ReadChar;
	end;
	ReadChar;
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
	middle := Symbols((Byte(bottom) + Byte(top)) div 2);
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

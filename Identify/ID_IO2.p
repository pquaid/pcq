External;

{$O-}
{$I "Identify.i"}
{$I "Include:Libraries/DOS.i" }
{$I "Include:Utils/StringLib.i"}
{$I "Include:Utils/Break.i"}

    Procedure EndComment;
        External;
    Procedure DoComment;
	External;
    Procedure ReadChar;
	External;


Function EndOfFile() : Boolean;

{
    This just determines when the end of all input has occured.
}

begin
    EndOfFile := (InFile = nil) and (not CharBuffed);
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


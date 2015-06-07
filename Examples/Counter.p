Program Counter;

{
This program reads a text file, then prints a report telling
you all the words in the file, and how many times each was
used.  It was intended as a demonstration and test of string
stuff and some addressing things.  The other major reason I
wrote it is because I am currently re-writing the compiler's
symbol table stuff, and the two designs I'm thinking about are
binary trees and hash tables.  I am going to use the hash
tables, but I wanted to get familiar with both methods before
I started the actual work.
}

{$I "Include:Utils/Parameters.i"}
{$I "Include:Utils/StringLib.i"}

type
    WordRec = Record
	Left,
	Right : ^WordRec;
	Count : Integer;
	Data  : array [0..255] of char;
    end;
    WordPtr = ^WordRec;

var
   Root		: WordPtr;
   CurrentChar	: Char;
   InFile	: Text;
   CurrentWord	: String;
   TotalWords	: Integer;

Procedure ReadChar;
begin
    if eof(InFile) then
	CurrentChar := Chr(0)
    else
	Read(Infile, CurrentChar);
end;

Procedure SkipWhiteSpace;
begin
    while (not eof(Infile)) and (not isalpha(CurrentChar)) do
	ReadChar;
end;

Procedure ReadWord;
var
   i : Integer;
begin
    i := 0;
    while isalnum(CurrentChar) do begin
	CurrentWord[i] := CurrentChar;
	i := Succ(i);
	ReadChar;
    end;
    CurrentWord[i] := Chr(0);
end;

Procedure EnterWord(rec : WordPtr);
var
    Current : WordPtr;
begin
    if Root = nil then begin
	Root := rec;
	return;
    end;
    Current := Root;
    while true do begin
	if Stricmp(Adr(rec^.Data), Adr(Current^.Data)) < 0 then begin
	    if Current^.Left = nil then begin
		Current^.Left := rec;
		return;
	    end else
		Current := Current^.Left;
	end else begin
	    if Current^.Right = nil then begin
		Current^.Right := rec;
		return;
	    end else
		Current := Current^.Right;
	end;
    end;
end;

Procedure AddWord(str : String);
var
    rec : WordPtr;
begin
    rec := WordPtr(AllocString(13 + strlen(str)));
    strcpy(Adr(rec^.Data), str);
    rec^.Left := nil;
    rec^.Right := nil;
    rec^.Count := 1;
    EnterWord(rec);
end;

Function FindWord(str : String) : WordPtr;
var
    Current : WordPtr;
    Result  : Integer;
begin
    Current := Root;
    while true do begin
	if Current = nil then
	    FindWord := nil;
	Result := stricmp(str, Adr(Current^.Data));
	if Result < 0 then
	    Current := Current^.Left
	else if Result > 0 then
	    Current := Current^.Right
	else
	    FindWord := Current;
    end;
end;

Procedure Report(W : WordPtr);
begin
    if W <> nil then begin
	Report(W^.Left);
	Writeln(W^.Count:5, Chr(9), String(Adr(W^.Data)));
	TotalWords := TotalWords + W^.Count;
	Report(W^.Right);
    end;
end;

var
    W : WordPtr;
    FileName : String;
begin
    Root := nil;
    CurrentWord := AllocString(128);
    FileName := AllocString(80);
    GetParam(1, FileName);
    if FileName^ = Chr(0) then begin	{ No parameter }
	Writeln('Usage: Counter Filename');
	Exit(10);
    end;
    if reopen(FileName, Infile) then begin
	SkipWhiteSpace;
	while not eof(Infile) do begin
	    ReadWord;
	    SkipWhiteSpace;
	    W := FindWord(CurrentWord);
	    if W = nil then
		AddWord(CurrentWord)
	    else
		W^.Count := Succ(W^.Count);
	end;
	TotalWords := 0;
	Report(Root);
	Writeln('Total Words: ', TotalWords);
	Close(Infile);
    end else
	Writeln('Could not open the input file : ', FileName);
end.

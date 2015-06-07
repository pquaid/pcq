Program Counter2;

{
This program reads a text file, then prints a report telling
you all the words in the file, and how many times each was
used.  It was intended as a demonstration and test of string
stuff and some addressing things.  The other major reason I
wrote it is because I am currently re-writing the compiler's
symbol table stuff, and the two designs I'm thinking about are
binary trees and hash tables.  I am going to use the hash
tables, but I wanted to get familiar with both methods before
I started the actual work.  This program uses the hash tables.
}

{$I "Include:Utils/Parameters.i"}
{$I "Include:Utils/StringLib.i"}

const
    TableSize = 511;

type
    WordRec = Record
	Next  : ^WordRec;
	Count : Integer;
	Data  : array [0..255] of char;
    end;
    WordPtr = ^WordRec;

var
   Table : Array [0..TableSize] of WordPtr;
   CurrentChar : Char;
   InFile : Text;
   CurrentWord : String;
   TotalWords : Integer;

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
    Result : Short;
begin
    Result := Hash(Adr(rec^.Data)) and TableSize;
    rec^.Next := Table[Result];
    Table[Result] := rec;
end;

Procedure AddWord(str : String);
var
    rec : WordPtr;
begin
    rec := WordPtr(AllocString(13 + strlen(str)));
    strcpy(Adr(rec^.Data), str);
    rec^.Count := 1;
    EnterWord(rec);
end;

Function FindWord(str : String) : WordPtr;
var
    Current : WordPtr;
begin
    Current := Table[Hash(str) and TableSize];
    while Current <> nil do begin
	if strieq(str, Adr(Current^.Data)) then
	    FindWord := Current;
	Current := Current^.Next;
    end;
    FindWord := nil;
end;

Procedure Report;
var
    i : Short;
    W : WordPtr;
begin
    for i := 0 to TableSize do begin
	W := Table[i];
	while W <> nil do begin
	    Writeln(W^.Count:5, Chr(9), String(Adr(W^.Data)));
	    TotalWords := TotalWords + W^.Count;
	    W := W^.Next;
	end
    end
end;

var
    W : WordPtr;
    FileName : String;
    index : Integer;
begin
    for index := 0 to TableSize do
	Table[index] := nil;
    CurrentWord := AllocString(128);
    FileName := AllocString(80);
    GetParam(1, FileName);
    if FileName^ = Chr(0) then begin
	Writeln('Usage: Counter2 FileName');
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
	Report;
	Writeln('Total Words: ', TotalWords);
	Close(Infile);
    end else
	Writeln('Could not open the input file : ', FileName);
end.

Program Find;

{
	Find.p searches through an AmigaDOS directory structure for files
matching the pattern given.  The command line format is:

	Find BaseDirectory Pattern

	This program shows how to use the SameName pattern matching routine,
as well as how to work with AmigaDOS a bit.  If you don't already have
a utility like this, Find can actually be useful.  Kinda scary....

	By the way: if you want to start your search on the current
directory, just type: Find "" FilePattern
}

{$I "Include:Utils/Break.i"}
{$I "Include:Libraries/DOS.i"}
{$I "Include:Utils/Parameters.i"}
{$I "Include:Utils/StringLib.i"}
{$I "Include:Utils/SameName.i"}

type
{
	When I'm searching through a directory for files matching the
pattern, I also come across directories.  When I do I keep them in a
linked stack, using the record below, then print all the subdirectories
after I'm finished with the current directory.  That way the files from
the subdirectory aren't printed in the middle of files from the current
directory.
}
    DirRec = record
	Previous : ^DirRec;
	Name : Array [0..109] of Char;
    end;
    DirRecPtr = ^DirRec;

var
    FullPath : String;
    Directory : String;
    FileName : String;
    TestName : String;

Function DirEnded(FName : String) : Boolean;
{
	returns false if you would want to append a '\' to the end
of FName before added a file name.
}
var
    l : Short;
begin
    l := strlen(FName);
    if l = 0 then
	DirEnded := True;
    DirEnded := (FName[l - 1] = ':') or (FName[l - 1] = '/');
end;

Procedure Display(FileInfo : FileInfoBlockPtr);
{
	Displays whatever information you want from the FileInfoBlock
}
var
    l : Short;
begin
    with FileInfo^ do begin
	Write(FullPath);
	l := strlen(FullPath);
	if l > 0 then
	    if not DirEnded(FullPath) then begin
		Write('/');
		l := Succ(l);
	    end;
	l := l + strlen(Adr(fib_FileName));
	Write(String(ADR(fib_FileName)), ' ':40-l);
	WriteLn(fib_Size:6)
    end;
end;

Procedure UpCase(str : String);
{
	Converts a string to uppercase
}
var
    i : Integer;
begin
    i := 0;
    while str[i] <> '\0' do begin
	str[i] := toupper(str[i]);
	i := Succ(i);
    end;
end;

Procedure SearchDirectory(DirName : String);
{
	The big routine.  Runs through the named directory, printing
file names that match the global variable FileName, and making a list
of directories.  When it has finished looking through the directories,
it calls itself recursively to print its subdirectories.
}
var
    FL		: FileLock;
    FB		: FileInfoBlockPtr;
    Stay	: Boolean;
    LastPos	: Short;
    FirstDir,
    TempDir	: DirRecPtr;
    DOSError	: Integer;
begin
    if CheckBreak then
	return;
    LastPos := StrLen(FullPath);
    FirstDir := Nil;
    if not DirEnded(FullPath) then
	strcat(FullPath, "/");
    strcat(FullPath, DirName);
    FL := Lock(FullPath, ACCESS_READ);
    if FL = Nil then begin
	FullPath[LastPos] := '\0';
	return;
    end;
    New(FB);	{ Since New() uses AllocMem, FB is longword aligned }
    if not Examine(FL, FB) then begin
	Unlock(FL);
	FullPath[LastPos] := '\0';
	return;
    end;
    if FB^.fib_DirEntryType < 0 then begin { means it's a file, not a dir }
	Unlock(FL);
	FullPath[LastPos] := '\0';
	return;
    end;
    repeat
	Stay := ExNext(FL, FB);
	if Stay then begin
	    with FB^ do begin
		if fib_DirEntryType < 0 then begin { file }
		    StrCpy(TestName, Adr(fib_FileName));
		    UpCase(TestName);
		    if SameName(FileName, TestName) then
			Display(FB);
		end else begin			{ a dir }
		    new(TempDir);		{ add it to the list }
		    with TempDir^ do begin
			strcpy(Adr(Name), Adr(fib_FileName));
			Previous := FirstDir;
		    end;
		    FirstDir := TempDir;
		end;
	    end;
	end else begin
	    DOSError := IoErr;	{ expect Error_No_More_Entries - not an error }
	    if DOSError <> ERROR_NO_MORE_ENTRIES then
		Writeln('DOS Error number ', DOSError);
	end;
	if CheckBreak then begin		{ user pressed Ctrl-C? }
	    while FirstDir <> Nil do begin
		TempDir := FirstDir^.Previous;	{ don't go through subs }
		Dispose(FirstDir);
		FirstDir := TempDir;
	    end;
	    Stay := False;
	end;
    until not Stay;
    Unlock(FL);
    while FirstDir <> Nil do begin		{ print sub-directories }
	SearchDirectory(Adr(FirstDir^.Name));
	TempDir := FirstDir^.Previous;
	Dispose(FirstDir);
	FirstDir := TempDir;
    end;
    FullPath[LastPos] := '\0';			{ restore global path name }
end;

Procedure Usage;
begin
    Writeln('Usage: FIND BaseDirectory FilePattern');
    Writeln('\t\tWhere BaseDirectory specifies the root search');
    Writeln('\t\tDirectory, and FilePattern is the file name,');
    Writeln('\t\tpossibly containing wildcards, to be compared.');
    Exit(20);
end;

begin
    Directory := AllocString(128);
    FileName := AllocString(40);
    TestName := AllocString(110);
    FullPath := AllocString(300);	{ allocate plenty of space }
    FullPath[0] := '\0';
    GetParam(1, Directory);
    GetParam(2, FileName);
    if StrLen(FileName) = 0 then
	Usage;
    UpCase(FileName);
    SearchDirectory(Directory);
end.

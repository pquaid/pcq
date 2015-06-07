Program PCQ;

{$I "Include:Utils/StringLib.i"}
{$I "Include:Utils/Parameters.i"}
{$I "Include:Libraries/DOS.i"}
{$I "Include:Exec/Tasks.i"}
{$I "Include:Libraries/DOSExtens.i"}
{$I "Include:Utils/Break.i"}


Type

{
     The WordList type stores all sorts of lists of strings,
     like the legal suffixes of Pascal source files or whatever.
     A variable of type WordListPtr can be Nil.
}

    WordListPtr = ^WordList;
    WordList = record
	Next	: WordListPtr;
	Name	: String;
    end;

{
    This enumerated type spells out each available command.  Since
    we use a simple binary search to look through the commands,
    these must remain in alphabetical order.
}

    KeyWord = (
		key_a,
		key_assemble,
		key_assembler,
		key_assemblererror,
		key_assembly,
		key_b,
		key_c,
		key_ccalls,
		key_checkio,
		key_compiler,
		key_compilererror,
		key_d,
		key_debug,
		key_destination,
		key_discard,
		key_exec,
		key_execute,
		key_external,
		key_f,
		key_force,
		key_i,
		key_l,
		key_library,
		key_link,
		key_linker,
		key_linkererror,
		key_linkform,
		key_main,
		key_map,
		key_mapoptions,
		key_mathtrans,
		key_n,
		key_nodebug,
		key_o,
		key_object,
		key_optimize,
		key_optimizer,
		key_optimizererror,
		key_p,
		key_pascal,
		key_profiler,
		key_project,
		key_r,
		key_range,
		key_s,
		key_shortcircuit,
		key_smallcode,
		key_smalldata,
		key_smallinit,
		key_source,
		key_temp,
		key_v,
		key_verbose,
		key_x,
		key_xref,

		key_unknown
		);

const

{
    This typed constant gives the actual text for each
    possible command.
}

    Keywords : Array [key_a .. Pred(key_unknown)] of String = (
		"a",
		"assemble",
		"assembler",
		"assemblererror",
		"assembly",
		"b",
		"c",
		"ccalls",
		"checkio",
		"compiler",
		"compilererror",
		"d",
		"debug",
		"destination",
		"discard",
		"exec",
		"execute",
		"external",
		"f",
		"force",
		"i",
		"l",
		"library",
		"link",
		"linker",
		"linkererror",
		"linkform",
		"main",
		"map",
		"mapoptions",
		"mathtrans",
		"n",
		"nodebug",
		"o",
		"object",
		"optimize",
		"optimizer",
		"optimizererror",
		"p",
		"pascal",
		"profiler",
		"project",
		"r",
		"range",
		"s",
		"shortcircuit",
		"smallcode",
		"smalldata",
		"smallinit",
		"source",
		"temp",
		"v",
		"verbose",
		"x",
		"xref");

var

{ The current command line parameter being processed }

    ParamNumber		: Integer;

{ The text of that command line parameter }

    Parameter		: String;

{ Where the current command is coming from }

    CommandSource	: (src_commandline, src_cfg, src_project);

{ Which type of file is being processed }

    FileClass		: (class_unknown, class_main, class_external);

{ A number for creating unique file names }

    Unique		: Integer;

{ The general purpose output file }

    Handle		: FileHandle;


{ Options set in .CFG or .PROJECT files }

	{ Path options }

    Compiler_path	: String;	{ Command string for the compiler }
    Assembler_path	: String;	{ Command string for the assembler }
    Linker_path		: String;	{ Command string for the linker }
    Optimizer_path	: String;	{ Command string for the optimizer }
    Source_path		: String;	{ Directory for source files }
    Dest_path		: String;	{ Directory to leave files in }
    Temp_path		: String;	{ Directory for temporary files }

    CompError_name	: String;	{ template for compiler error handler }
    OptError_name	: String;	{ template for optimizer error handler }
    AssemError_name	: String;	{ template for assembler error handler }
    LinkError_name	: String;	{ template for linker error handler }

    Exec_name		: String;	{ Name of executable }
    Main_name		: String;	{ Name of main module }
    Map_name		: String;	{ Name of map file }
    Xref_name		: String;	{ Name of XREF file }

    External_names	: WordListPtr;	{ Name of external files }

	{ Suffixes }

    Project_suffix	: WordListPtr;	{ Suffixes for Project files }
    Pascal_suffix	: WordListPtr;	{ Suffixes for Pascal source files }
    Assembly_suffix	: WordListPtr;	{ Suffixes for Assembly source files }
    Object_suffix	: WordListPtr;	{ Suffixes for Object files }

	{ PCQ options }

    opt_Verbose		: Boolean;	{ TRUE => Should write messages }

	{ Compiler options }

    opt_SmallInit	: Boolean;	{ TRUE => specify -s option }
    opt_Profiler	: Boolean;	{ TRUE => specify -p option }
    opt_Shortcircuit	: Boolean;	{ FALSE => specify -$B option }
    opt_CheckIO		: Boolean;	{ FALSE => specify -$B option }
    opt_MathTrans	: Boolean;	{ TRUE => specify +$N option }
    opt_RangeCheck	: Boolean;	{ TRUE => specify +$R option }
    opt_Force		: Boolean;	{ TRUE => ignore time diffs }
    opt_CCalls		: Boolean;	{ TRUE => use C calling conventions }
    opt_Discard		: Boolean;	{ TRUE => use functions as procedures }

	{ Optimizer options }

    opt_Optimize	: Boolean;	{ TRUE => run peephole optimizer }

	{ Assembler options }

    opt_Debug		: Boolean;	{ TRUE => specify -d option }
    opt_Assemble	: Boolean;	{ TRUE => run assembler }

	{ Linker options }

    opt_NoDebug		: Boolean;	{ TRUE => specify NODEBUG }
    opt_SmallCode	: Boolean;	{ TRUE => specify SMALLCODE }
    opt_SmallData	: Boolean;	{ TRUE => specify SMALLDATA }
    opt_Map		: Boolean;	{ TRUE => specify MAP }
    opt_Xref		: Boolean;	{ TRUE => generate XREF }
    opt_Link		: Boolean;	{ TRUE => run the linker }
    MapOptions		: String;	{ passsed to Blink }
    LinkForm		: (form_Alink,form_Blink,form_Dlink);
					{ the linker to be used }

    LibraryList		: WordListPtr;	{ List of libraries to send to linker }


{   This function returns TRUE if the given file exists }

Function ExistFile(Name : String) : Boolean;
var
    MyLock : FileLock;
begin
    MyLock := Lock(Name, SHARED_LOCK);
    if MyLock <> Nil then begin
	Unlock(MyLock);
	ExistFile := True
    end else
	ExistFile := False;
end;


{ This routine deletes Num characters from Str, starting at Pos }

Procedure strdel(Str : String; Pos, Num : Short);
var
    i : Short;
begin
    for i := Pos to strlen(Str) - Num do
	Str[i] := Str[i + Num];
end;


{
  This routine inserts the string Insertion into the string Str,
  beginning at location Pos
}

Procedure strins(Str, Insertion : String; Pos : Short);
var
    i : Short;
    len : Short;
begin
    if strlen(Str) <= Pos then
	strcat(Str, Insertion)
    else begin
	len := strlen(Insertion);
	for i := strlen(Str) downto Pos do
	    Str[i + Len] := Str[i];
	for i := Pos to Pred(Pos + Len) do
	    Str[i] := Insertion[i - Pos];
    end;
end;

{ This routine adds a new word to a word list }

Procedure AddWord(VAR WList : WordListPtr; NewWord : String);
var
    TempWord : WordListPtr;
begin
    New(TempWord);
    with TempWord^ do begin
	Next := WList;
	Name := strdup(NewWord);
    end;
    WList := TempWord;
end;


{ This routine aborts the program with an error message }

Procedure Abort(Error : String);
begin
    Writeln(Error);
    if Handle <> Nil then
	DOSClose(Handle);
    Exit(20);
end;


(*

{ This is a debugging routine that displays a word list }

Procedure WriteWordList(Prefix : String; WL : WordListPtr);
begin
    Write(Prefix);
    while WL <> Nil do begin
	Write(WL^.Name);
	WL := WL^.Next;
	if WL <> Nil then
	    Write(',');
    end;
    Writeln;
end;


{ This is a debugging routine that displays all the options }

Procedure ShowOptions;
begin

    Writeln('Compiler     ', Compiler_path);
    Writeln('Assembler    ', Assembler_path);
    Writeln('Linker       ', Linker_path);
    Writeln('Optimizer    ', Optimizer_path);
    Writeln('Source dir   ', Source_path);
    Writeln('Destination  ', Dest_path);
    Writeln('Temporary    ', Temp_path);

    Writeln('Executable   ', Exec_name);
    Writeln('Map file     ', Map_name);
    Writeln('Xref file    ', Xref_name);

	{ Suffixes }

    WriteWordList("Projects:   ", Project_suffix);
    WriteWordList("Pascal:     ", Pascal_suffix);
    WriteWordList("Assembly:   ", Assembly_suffix);
    WriteWordList("Object:     ", Object_suffix);

	{ Compiler options }

    Writeln('SmallInit    ', opt_SmallInit);
    Writeln('Profiler     ', opt_Profiler);
    Writeln('ShortCircuit ', opt_Shortcircuit);
    Writeln('CheckIO      ', opt_CheckIO);
    Writeln('MathTrans    ', opt_MathTrans);
    Writeln('Range Check  ', opt_RangeCheck);

	{ Optimizer options }

    Writeln('Optimize     ', opt_Optimize);

	{ Assembler options }

    Writeln('Debug        ', opt_Debug);
    Writeln('Assemble     ', opt_Assemble);

	{ Linker options }

    Writeln('NODEBUG      ', opt_NoDebug);
    Writeln('SMALLCODE    ', opt_SmallCode);
    Writeln('SMALLDATA    ', opt_SmallData);
    Writeln('MAP          ', opt_Map);
    Writeln('Link         ', opt_Link);
    Writeln('XREF         ', opt_Xref);
    Writeln('Map options  "', MapOptions, '"');

    WriteWordList("Libraries   ", LibraryList);
end;
*)

{ This routine sets up all the options with default values }

Procedure SetDefaults;
begin
	{ Paths }

    Compiler_path	:= strdup("Pascal");
    Assembler_path	:= strdup("A68k");
    Linker_path		:= strdup("Blink");
    Optimizer_path	:= strdup("Peep");
    Source_path		:= strdup("");
    Dest_path		:= strdup("");
    Temp_path		:= strdup("T:");

    CompError_name	:= strdup("CompErrors \\s \\d \\e");
    OptError_name	:= strdup("OptErrors \\s \\e");
    AssemError_name	:= strdup("AssemErrors \\s \\e");
    LinkError_name	:= strdup("LinkErrors \\e");

    Exec_name		:= strdup("");
    Main_name		:= strdup("");
    Map_name		:= strdup("");
    Xref_name		:= strdup("");
    External_names	:= Nil;

	{ Suffixes }

    Project_suffix := Nil;
    AddWord(Project_suffix, ".project");

    Pascal_suffix := Nil;
    AddWord(Pascal_suffix, ".p");

    Assembly_suffix := Nil;
    AddWord(Assembly_suffix, ".asm");

    Object_suffix := Nil;
    AddWord(Object_suffix, ".o");

	{ PCQ options }

    opt_Verbose		:= True;

	{ Compiler options }

    opt_SmallInit	:= False;
    opt_Profiler	:= False;
    opt_Shortcircuit	:= True;
    opt_CheckIO		:= True;
    opt_MathTrans	:= False;
    opt_RangeCheck	:= False;
    opt_Force		:= False;
    opt_CCalls		:= False;
    opt_Discard		:= False;

	{ Optimizer options }

    opt_Optimize	:= True;

	{ Assembler options }

    opt_Debug		:= False;
    opt_Assemble	:= True;

	{ Linker options }

    opt_NoDebug		:= True;
    opt_SmallCode	:= False;
    opt_SmallData	:= False;
    opt_Map		:= False;
    opt_Xref		:= False;
    opt_Link		:= True;
    LinkForm		:= form_Blink;
    MapOptions		:= strdup("S PLAIN");

    LibraryList := Nil;
    AddWord(LibraryList, "PCQ.lib");

    FileClass           := class_unknown;
end;


{
  This routine takes an InputLine and points the string Command
  to the first word in the line, and Suffix to the first of the
  remaining words.  No new strings are allocated, and Command
  and Suffix both point to memory inside the original string.
}

Procedure SplitLine(InputLine : String;
		    VAR Command, Suffix : String);
var
    i : Integer;
begin
    i := 0;

    while (InputLine[i] <> '\0') and (InputLine[i] <= ' ') do
	Inc(i);

    Command := String(@InputLine[i]);

    while InputLine[i] > ' ' do
	Inc(i);

    if InputLine[i] <> '\0' then begin
	InputLine[i] := '\0';
	Inc(i);
	while (InputLine[i] <> '\0') and (InputLine[i] <= ' ') do
	    Inc(i);
    end;
    Suffix := String(@InputLine[i]);
end;


{
    This routine figures out which of the options corresponds to
    the given command word, using a binary search.
}

Function FindOption(Option : String) : Keyword;
var
    top,
    middle,
    bottom	: Short;
    compare	: Short;
begin
    Bottom := Ord(key_a);
    Top    := Ord(Pred(key_unknown));
    while Bottom <= Top do begin
	middle := (bottom + top) div 2;
	Compare := stricmp(Keywords[Keyword(Middle)], Option);
	if Compare = 0 then
	    FindOption := Keyword(Middle)
	else if Compare < 0 then
	    Bottom := Succ(Middle)
	else
	    Top := Pred(Middle);
    end;
    FindOption := key_unknown;
end;

{
    This routine sets a Boolean value based on a switch
    character
}

Procedure SetSwitch(VAR Switch : Boolean; Value : Char);
begin
    case Value of
     '-' : Switch := False;
     '+' : Switch := True;
    else
	Abort("Unknown command");
    end;
end;

{    This routine sets a command path }

Procedure SetCommandPath(VAR Path : String; NewPath : String);
begin
    FreeString(Path);
    Path := strdup(NewPath);
end;


{
  This routine either adds a new word to a word list, or if the
  word is blank (i.e. ""), it clears the word list.
}

Procedure SetList(VAR WL : WordListPtr; NewWord : String);
var
    Temp : WordListPtr;
begin
    if NewWord^ = Chr(0) then begin
	while WL <> Nil do begin
	    Temp := WL^.Next;
	    Dispose(WL);
	    WL := Temp;
	end;
    end else
	AddWord(WL, NewWord);
end;

{
    This routine sets a directory name, appending a slash
    character if necessary.
}

Procedure SetPath(VAR Path : String; NewPath : String);
var
    LastChar : Char;
begin
    FreeString(Path);
    Path := AllocString(strlen(NewPath) + 2);
    strcpy(Path, NewPath);
    if strlen(Path) > 0 then begin
	LastChar := Path[Pred(strlen(Path))];
	if (LastChar <> '/') and (LastChar <> ':') then
	    strcat(Path, "/");
    end;
end;

{
    This routine sets a string variable to the given name
}

Procedure SetName(VAR Name : String; NewName : String);
begin
    FreeString(Name);
    Name := strdup(NewName);
end;

{
    This routine sets the map name, as well as whether or not
    a map file will be generated.
}

Procedure SetMapName(Flag : Char; NewName : String);
begin
    if Flag = '+' then begin
	opt_Map := True;
	if strlen(NewName) > 0 then
	    SetName(Map_name, NewName);
    end else if Flag = '-' then
	opt_Map := False;
end;

Procedure SetXrefName(Flag : Char; NewName : String);
begin
    if Flag = '+' then begin
	opt_Xref := True;
	if strlen(NewName) > 0 then
	    SetName(Xref_name, NewName);
    end else if Flag = '-' then
	opt_Xref := False;
end;


{
    This routine determines whether the string Suffix is a
    suffix of Str.
}

Function IsSuffix(Str, Suffix : String) : Boolean;
var
    Len1, Len2 : Integer;
begin
    Len1 := strlen(Str);
    Len2 := strlen(Suffix);
    if Len1 < Len2 then
	IsSuffix := False;
    IsSuffix := strieq(String(@Str[Len1 - Len2]), Suffix);
end;


{
    This function determines whether any of the suffixes in a
    list is the suffix of Name.  If it exists, it returns a
    pointer to the word record, or Nil if the suffix is not there.
}

Function HasSuffix(Name : String; WL : WordListPtr) : WordListPtr;
begin
    while WL <> Nil do begin
	if issuffix(Name,WL^.Name) then
	    HasSuffix := WL;
	WL := WL^.Next;
    end;
    HasSuffix := Nil;
end;

{
    This function returns a file's date and time as the number of
    seconds after January 1, 1978 that the file was created.
}

Function FileTime(FName : String) : Integer;
var
    FInfo : FileInfoBlockPtr;
    FTime : Integer;
    FLock : FileLock;
begin
    FLock := Lock(FName, SHARED_LOCK);
    if FLock = Nil then
	FileTime := 0;

    New(FInfo);
    if Examine(FLock, FInfo) then begin
	with FInfo^.fib_Date do
	    FTime := ds_Days * (24 * 60 * 60) +
		     ds_Minute * 60 +
		     ds_Tick div 50;
    end else
	FTime := 0;

    Unlock(FLock);
    Dispose(FInfo);

    FileTime := FTime;
end;

{
    This function returns a file's size
}

Function FileSize(FileName : String) : Integer;
var
    FInfo : FileInfoBlockPtr;
    FLock : FileLock;
    FSize : Integer;
begin
    FLock := Lock(FileName,SHARED_LOCK);
    if FLock = Nil then
	FileSize := 0
    else begin
	New(FInfo);
	if Examine(FLock, FInfo) then
	    FSize := FInfo^.fib_Size
	else
	    FSize := 0;
	Dispose(FInfo);
	Unlock(FLock);
	FileSize := FSize;
    end;
end;

{
    This function returns in Result the file name from FullPath,
    with any directory and volume information stripped off.  Result
    must already be allocated.
}

Procedure OnlyFileName(FullPath, Result : String);
var
   i,j : Integer;
begin
    strcpy(Result, FullPath);
    i := strrpos(Result, '/');
    j := strrpos(Result, ':');
    if i < j then
	i := j;
    if i <> 0 then
	strdel(Result, 0, Succ(i));
end;

{
    This function strips the suffix off the Str
}

Procedure StripSuffix(Str, Suffix : String);
begin
    Str[strlen(Str) - strlen(Suffix)] := '\0';
end;

{
    This function concatenates a parameter onto a command string,
    first appending a space.
}

Procedure CatParam(Dest, Param : String);
begin
    strcat(Dest, " ");
    strcat(Dest, Param);
end;

{
    This routine finds an unused file name with the appropriate suffix
}

Procedure GetTempFileName(Name, Suffix : String);
var
    Dummy  : Integer;
    Temp   : Array [0..19] of Char;
begin
    repeat
	Dummy := IntToStr(String(@Temp), Unique);
	strcpy(Name, Temp_path);
	strcat(Name, "PCQ_Temp");
	strcat(Name, String(@Temp));
	strcat(Name, Suffix);
	Inc(Unique);
    until not ExistFile(Name);
end;


{
    This routine executes the program, aborting if there are any
    errors.
}

Procedure ExecuteProgram(Command : String);
var
    Success : Boolean;
begin
    if CheckBreak then
	Abort("User Aborted");
    Success := Execute(Command, Nil, Handle);
    if not Success then
	Abort("Could not execute program");
end;



{
    This routine executes an error routine
}

Procedure ProcessError(Template, FromName, ToName, ErrorFile : String);
var
    ErrorCommand : String;
    i		 : Integer;
begin
    ErrorCommand := AllocString(256);
    strcpy(ErrorCommand, Template);
    i := 0;
    while ErrorCommand[i] <> '\0' do begin
	if ErrorCommand[i] = '\\' then begin
	    Inc(i);
	    case toupper(ErrorCommand[i]) of
	      'S' : begin
			strdel(ErrorCommand,Pred(i),2);
			strins(ErrorCommand,FromName,Pred(i));
			Inc(i,Pred(strlen(FromName)));
		    end;
	      'D' : begin
			strdel(ErrorCommand,Pred(i),2);
			strins(ErrorCommand,ToName,Pred(i));
			Inc(i,Pred(strlen(ToName)));
		    end;
	      'E' : begin
			strdel(ErrorCommand,Pred(i),2);
			strins(ErrorCommand,ErrorFile,Pred(i));
			Inc(i,Pred(strlen(ErrorFile)));
		    end;
	    else
		Inc(i);
	    end;
	end else
	    Inc(i);
    end;

    if opt_Verbose then
	Writeln(ErrorCommand);

    ExecuteProgram(ErrorCommand);
    Abort("PCQ found errors");
end;


{
    This routine compiles the file FromName.  It figures out an
    appropriate ToName, and copies it into ToName (which must
    already be allocated).

    If there are any errors, this routine executes the compiler
    error command string.
}

Procedure Compile(FromName, BaseName, ToName : String);
var
    Command : String;
    ErrorFile : String;
begin
    Command   := AllocString(256);
    ErrorFile := AllocString(256);

    GetTempFileName(ErrorFile, "");

    if opt_Optimize or opt_Assemble then begin
	if Assembly_suffix <> Nil then
	    GetTempFileName(ToName, Assembly_suffix^.Name)
	else
	    GetTempFileName(ToName, ".asm");
    end else begin
	strcpy(ToName, Dest_path);
	strcat(ToName, BaseName);
	if Assembly_suffix <> Nil then
	    strcat(ToName, Assembly_suffix^.Name)
	else
	    strcat(ToName, ".asm");
    end;

    Handle := DOSOpen(ErrorFile, MODE_NEWFILE);
    if Handle = Nil then
	Abort("Could not open temporary file");

    strcpy(Command, Compiler_path);
    CatParam(Command, FromName);
    CatParam(Command, ToName);
    strcat(Command, " -q");

    if opt_SmallInit then
	strcat(Command, " -s");
    if opt_Profiler then
	strcat(Command, " -p");
    if not opt_ShortCircuit then
	strcat(Command, " -$B");
    if not opt_CheckIO then
	strcat(Command, " -$I");
    if opt_MathTrans then
	strcat(Command, " +$N");
    if opt_RangeCheck then
	strcat(Command, " +$R");
    if opt_CCalls then
	strcat(Command, " +$C");
    if opt_Discard then
	strcat(Command, " +$X");

    if opt_Verbose then
	Writeln(Command);

    ExecuteProgram(Command);

    DOSClose(Handle);
    Handle := Nil;

    if FileSize(ErrorFile) > 0 then
	ProcessError(CompError_name, FromName, ToName, ErrorFile);

    if not DeleteFile(ErrorFile) then
	Abort("Could not delete temporary file");

    FreeString(Command);
    FreeString(ErrorFile);
end;

{
    This routine optimizes FromName.  It figures out the destination
    name, and copies it to ToName, which must already be initialized.
}

Procedure Optimize(FromName, BaseName, ToName : String);
var
    Command : String;
    ErrorFile : String;
begin
    Command   := AllocString(256);
    ErrorFile := AllocString(256);

    GetTempFileName(ErrorFile, "");

    if opt_Assemble then begin
	if Assembly_suffix <> Nil then
	    GetTempFileName(ToName, Assembly_suffix^.Name)
	else
	    GetTempFileName(ToName, ".s");
    end else begin
	strcpy(ToName, Dest_path);
	strcat(ToName, BaseName);
	if Assembly_suffix <> Nil then
	    strcat(ToName, Assembly_suffix^.Name)
	else
	    strcat(ToName, ".s");
    end;

    Handle := DOSOpen(ErrorFile, MODE_NEWFILE);
    if Handle = Nil then
	Abort("Could not create temporary file");

    strcpy(Command, Optimizer_path);
    CatParam(Command, FromName);
    CatParam(Command, ToName);

    if opt_Verbose then
	Writeln(Command);

    ExecuteProgram(Command);

    DOSClose(Handle);
    Handle := Nil;

    if FileSize(ErrorFile) > 0 then
	ProcessError(OptError_name, FromName, ToName, ErrorFile);

    if not DeleteFile(ErrorFile) then
	Abort("Could not delete temporary file");

    FreeString(Command);
    FreeString(ErrorFile);
end;

Procedure Assemble(FromName, BaseName, ToName : String);
var
    Command : String;
    ErrorFile : String;
begin
    Command   := AllocString(256);
    ErrorFile := AllocString(256);

    GetTempFileName(ErrorFile, "");

    if opt_Link and (CommandSource = src_CommandLine) then begin
	if Object_suffix <> Nil then
	    GetTempFileName(ToName, Object_suffix^.Name)
	else
	    GetTempFileName(ToName, ".o");
    end else begin
	strcpy(ToName, Dest_path);
	strcat(ToName, BaseName);
	if Object_suffix <> Nil then
	    strcat(ToName, Object_suffix^.Name)
	else
	    strcat(ToName, ".o");
    end;

    Handle := DOSOpen(ErrorFile, MODE_NEWFILE);
    if Handle = Nil then
	Abort("Could not open temporary file");

    strcpy(Command, Assembler_path);
    CatParam(Command, FromName);
    CatParam(Command, ToName);
    strcat(Command, " -q");

    if opt_Debug then
	strcat(Command, " -d");

    if opt_Verbose then
	Writeln(Command);

    ExecuteProgram(Command);

    DOSClose(Handle);
    Handle := Nil;

    if not ExistFile(ToName) then
	ProcessError(AssemError_name, FromName, ToName, ErrorFile);

    if not DeleteFile(ErrorFile) then
	Abort("Could not delete temporary file");

    FreeString(Command);
    FreeString(ErrorFile);
end;


{
    Link a single file
}

Procedure Link(FromName, BaseName, ToName : String);
var
    Command : String;
    ErrorFile : String;
    Lib	      : WordListPtr;
    Errors    : Text;
begin
    Command   := AllocString(256);
    ErrorFile := AllocString(256);

    GetTempFileName(ErrorFile, "");

    strcpy(ToName, Dest_path);
    strcat(ToName, BaseName);

    Handle := DOSOpen(ErrorFile, MODE_NEWFILE);
    if Handle = Nil then
	Abort("Could not open temporary file");

    strcpy(Command, Linker_path);
    CatParam(Command, FromName);
    if LinkForm <> form_Dlink then
	strcat(Command, " TO ")
    else
	strcat(Command, " -o ");
    strcat(Command, ToName);

    if LibraryList <> Nil then begin
	if LinkForm <> form_Dlink then
	    strcat(Command, " LIBRARY");
	Lib := LibraryList;
	while Lib <> Nil do begin
	    CatParam(Command, Lib^.Name);
	    Lib := Lib^.Next;
	end;
    end;

    if opt_NoDebug then begin
	if LinkForm = form_Blink then
	    strcat(Command, " NODEBUG");
    end else if LinkForm = form_Dlink then
	strcat(Command, " -s");

    if opt_Map and (LinkForm <> form_Dlink) then begin
	strcat(Command, " MAP ");
	if strlen(Map_name) > 0 then
	    strcat(Command, Map_name)
	else begin
	    strcat(Command, Dest_path);
	    strcat(Command, BaseName);
	    strcat(Command, ".MAP");
	end;
	if LinkForm = form_Blink then
	    CatParam(Command, MapOptions);
    end;

    if opt_Xref and (LinkForm <> form_Dlink) then begin
	strcat(Command, " XREF ");
	if strlen(Xref_name) > 0 then
	    strcat(Command, Xref_name)
	else begin
	    strcat(Command, Dest_path);
	    strcat(Command, BaseName);
	    strcat(Command, ".XREF");
	end;
    end;

    if opt_SmallCode then begin
	if LinkForm = form_Alink then
	    strcat(Command, " SMALL")
	else if LinkForm = form_Blink then
	    strcat(Command, " SMALLCODE");
    end else if LinkForm = form_Dlink then
	strcat(Command, " -f");

    if opt_SmallData then begin
	if LinkForm = form_Blink then
	    strcat(Command, " SMALLDATA")
	else if (LinkForm = form_Alink) and (not opt_SmallCode) then
	    strcat(Command, " SMALL");
    end else if (LinkForm = form_Dlink) and opt_SmallCode then
	strcat(Command, " -f");

    if opt_Verbose then
	Writeln(Command);

    ExecuteProgram(Command);

    DOSClose(Handle);
    Handle := Nil;

    if LinkForm = form_Blink then begin
	if ReOpen(ErrorFile, Errors) then begin
	    while not EOF(Errors) do begin
		ReadLn(Errors, Command);
		if strnieq(Command, "Error", 5) then begin
		    Close(Errors);
		    ProcessError(LinkError_name,FromName,ToName,ErrorFile);
		end;
	    end;
	    Close(Errors);
	end;
    end else if LinkForm = form_Alink then begin
	if ReOpen(ErrorFile, Errors) then begin
	    while not EOF(Errors) do begin
		ReadLn(Errors, Command);
		if strnieq(Command, "Linker", 6) then begin
		    Close(Errors);
		    ProcessError(LinkError_name,FromName,ToName,ErrorFile);
		end;
	    end;
	    Close(Errors);
	end;
    end else if FileSize(ErrorFile) > 0 then
	ProcessError(LinkError_name,FromName,ToName,ErrorFile);

    if not DeleteFile(ErrorFile) then
	Abort("Could not delete temporary file");

    FreeString(Command);
    FreeString(ErrorFile);
end;

Procedure MultiLink(MainName : String; ExternalName : WordListPtr;
		    BaseName : String; ToName : String);
var
    Command   : String;
    ErrorFile : String;
    LinkListName  : String;
    LinkList  : Text;
    Lib	      : WordListPtr;
    Errors    : Text;
begin
    Command   := AllocString(256);
    ErrorFile := AllocString(256);
    LinkListName  := AllocString(256);

    GetTempFileName(ErrorFile, "");

    Handle := DOSOpen(ErrorFile, MODE_NEWFILE);
    if Handle = Nil then
	Abort("Could not open temporary file");

    GetTempFileName(LinkListName, "");
    if not Open(LinkListName, LinkList) then
	Abort("Could not open temporary file");

    strcpy(Command, Linker_path);
    if LinkForm <> form_Dlink then
	strcat(Command, " WITH ")
    else
	strcat(Command, " @");
    strcat(Command, LinkListName);

    if LinkForm <> form_Dlink then
	Write(LinkList, 'FROM ');
    Write(LinkList, MainName);
    if LinkForm = form_Dlink then
	Writeln(LinkList);

    while ExternalName <> Nil do begin
	if LinkForm <> form_Dlink then
	    Write(LinkList, ',');
	Write(LinkList, ExternalName^.Name);
	if LinkForm = form_Dlink then
	    Writeln(LinkList);
	ExternalName := ExternalName^.Next;
    end;
    if LinkForm <> form_Dlink then
	Writeln(LinkList);

    if LinkForm <> form_Dlink then
	strcat(Command, " TO ")
    else
	strcat(Command, " -o ");
    strcat(Command, ToName);

    Lib := LibraryList;
    if (Lib <> Nil) and (LinkForm <> form_Dlink) then
	Write(LinkList, 'LIBRARY ');

    while Lib <> Nil do begin
	Write(LinkList, Lib^.Name);
	Lib := Lib^.Next;
	if LinkForm = form_Dlink then
	    Writeln(LinkList)
	else if Lib <> Nil then
	    Write(LinkList, ',');
    end;
    if (LibraryList <> Nil) and (LinkForm <> form_Dlink) then
	Writeln(LinkList);

    if opt_NoDebug then begin
	if LinkForm = form_Blink then
	    strcat(Command, " NODEBUG");
    end else if LinkForm = form_Dlink then
	strcat(Command, " -s");

    if opt_Map and (LinkForm <> form_Dlink) then begin
	strcat(Command, " MAP ");
	if strlen(Map_name) > 0 then
	    strcat(Command, Map_name)
	else begin
	    strcat(Command, Dest_path);
	    strcat(Command, BaseName);
	    strcat(Command, ".MAP");
	end;
	if LinkForm = form_Blink then
	    CatParam(Command, MapOptions);
    end;

    if opt_Xref and (LinkForm <> form_Dlink) then begin
	strcat(Command," XREF ");
	if strlen(Xref_name) > 0 then
	    strcat(Command, Xref_name)
	else begin
	    strcat(Command, Dest_path);
	    strcat(Command, BaseName);
	    strcat(Command, ".XREF");
	end;
    end;

    if opt_SmallCode then begin
	if LinkForm = form_Blink then
	    strcat(Command, " SMALLCODE")
	else if LinkForm = form_Alink then
	    strcat(Command, " SMALL");
    end else if LinkForm = form_Dlink then
	strcat(Command, " -f");

    if opt_SmallData then begin
	if LinkForm = form_Blink then
	    strcat(Command, " SMALLDATA")
	else if (LinkForm = form_Alink) and (not opt_SmallCode) then
	    strcat(Command, " SMALL");
    end else if (LinkForm = form_Dlink) and opt_SmallCode then
	strcat(Command, " -f");

    Close(LinkList);

    if opt_Verbose then
	Writeln(Command);

    ExecuteProgram(Command);

    DOSClose(Handle);
    Handle := Nil;

    if LinkForm = form_Blink then begin
	if ReOpen(ErrorFile, Errors) then begin
	    while not EOF(Errors) do begin
		ReadLn(Errors, Command);
		if strnieq(Command, "Error", 5) then begin
		    Close(Errors);
		    ProcessError(LinkError_name,MainName,ToName,ErrorFile);
		end;
	    end;
	    Close(Errors);
	end;
    end else if LinkForm = form_Alink then begin
	if ReOpen(ErrorFile, Errors) then begin
	    while not EOF(Errors) do begin
		Readln(Errors, Command);
		if strnieq(Command, "Linker", 6) then begin
		    Close(Errors);
		    ProcessError(LinkError_name,MainName,ToName,ErrorFile);
		end;
	    end;
	    Close(Errors);
	end;
    end else if FileSize(ErrorFile) > 0 then
	ProcessError(LinkError_name,MainName,ToName,ErrorFile);

    if not DeleteFile(ErrorFile) then
	Abort("Could not delete temporary file");
    if not DeleteFile(LinkListName) then
	Abort("Could not delete temporary file");

    FreeString(LinkListName);
    FreeString(Command);
    FreeString(ErrorFile);
end;



	Procedure ProcessOption(OptionLine : String);
	    Forward;


Procedure ProcessProject(ProjectName : String);
var
    ProjectFile : Text;
    ProjectLine : String;
    MainSuffix  : WordListPtr;
    BaseName	: String;
begin
    SetList(External_names, "");

    if strlen(Main_name) > 0 then begin
	FreeString(Main_name);
	Main_name := strdup("");
    end;

    if strlen(Exec_name) > 0 then begin
	FreeString(Exec_name);
	Exec_name := strdup("");
    end;

    ProjectLine := AllocString(256);
    if reopen(ProjectName, ProjectFile) then begin
	while not EOF(ProjectFile) do begin
	    CommandSource := src_project;
	    Readln(ProjectFile, ProjectLine);
	    ProcessOption(ProjectLine);
	end;
	Close(ProjectFile);
    end;

    if strlen(Main_name) = 0 then
	Abort("No MAIN module was specified in the project file");

    BaseName := AllocString(256);

    if strlen(Exec_name) = 0 then begin
	OnlyFileName(Main_name,BaseName);
	MainSuffix := HasSuffix(BaseName, Object_suffix);
	if MainSuffix <> Nil then
	    StripSuffix(BaseName, MainSuffix^.Name);
	strcpy(ProjectLine, Dest_path);
	strcat(ProjectLine, BaseName);
	SetName(Exec_name, ProjectLine);
    end else begin
	OnlyFileName(Exec_name, BaseName);
	if (strpos(Exec_name,':') = -1) and
	   (strpos(Exec_name,'/') = -1) then begin
	    strcpy(ProjectLine, Dest_path);
	    strcat(ProjectLine, Exec_name);
	    SetName(Exec_name, ProjectLine);
	end;
    end;

    MultiLink(Main_name, External_names, BaseName, Exec_name);

    FreeString(ProjectLine);
end;

Procedure ProcessPascal(SourceName : String);
var
    Suffix   : WordListPtr;
    BaseName : String;
    FromName,
    ToName   : String;
    BaseBuffer,
    FromBuffer,
    SourceBuffer,
    ToBuffer : Array [0..255] of Char;
begin
    BaseName := String(@BaseBuffer);
    FromName := String(@FromBuffer);
    ToName   := String(@ToBuffer);

    Suffix := HasSuffix(SourceName, Pascal_suffix);

    OnlyFileName(SourceName, BaseName);
    if Suffix <> Nil then
	StripSuffix(BaseName, Suffix^.Name);

    if not ExistFile(SourceName) then begin
	if (strpos(SourceName, ':') = -1) and
	   (strpos(SourceName, '/') = -1) then begin
	    strcpy(FromName, Source_path);
	    strcat(FromName, SourceName);
	    SourceName := String(@SourceBuffer);
	    strcpy(SourceName, FromName);
	end;
	if not ExistFile(SourceName) then
	    Abort("Could not find source file");
    end;

    if (CommandSource <> src_CommandLine) and (not opt_Force) then begin
	strcpy(ToName, Dest_path);
	strcat(ToName, BaseName);
	if Object_suffix <> Nil then
	    strcat(ToName, Object_suffix^.Name);

	if ExistFile(ToName) then begin
	    if FileTime(ToName) > FileTime(SourceName) then begin
		if opt_Verbose then
		    Writeln('Skipping ', SourceName, ' (no changes)');
		if CommandSource = src_project then begin
		    if FileClass = class_main then
			SetName(Main_name, ToName)
		    else if FileClass = class_external then
			AddWord(External_names, ToName);
		end;
		return;
	    end;
	end;
    end;

    Compile(SourceName, BaseName, ToName);

    if opt_Optimize then begin
	strcpy(FromName, ToName);
	Optimize(FromName, BaseName, ToName);
	if not DeleteFile(FromName) then
	    Abort("Could not delete temporary file");
    end;

    if opt_Assemble then begin
	strcpy(FromName, ToName);
	Assemble(FromName, BaseName, ToName);
	if not DeleteFile(FromName) then
	    Abort("Could not delete temporary file");
    end else
	return;

    if opt_Link and (CommandSource = src_CommandLine) then begin
	strcpy(FromName, ToName);
	Link(FromName, BaseName, ToName);
	if not DeleteFile(FromName) then
	    Abort("Could not delete temporary file");
    end;

    if CommandSource = src_Project then begin
	if FileClass = class_main then
	    SetName(Main_name, ToName)
	else if FileClass = class_external then
	    AddWord(External_names, ToName);
    end;
end;


Procedure ProcessAssembly(SourceName : String);
var
    Suffix   : WordListPtr;
    BaseName : String;
    FromName,
    ToName   : String;
    BaseBuffer,
    FromBuffer,
    SourceBuffer,
    ToBuffer : Array [0..255] of Char;
begin
    BaseName := String(@BaseBuffer);
    FromName := String(@FromBuffer);
    ToName   := String(@ToBuffer);

    Suffix := HasSuffix(SourceName, Assembly_suffix);

    OnlyFileName(SourceName, BaseName);
    if Suffix <> Nil then
	StripSuffix(BaseName, Suffix^.Name);

    if not ExistFile(SourceName) then begin
	if (strpos(SourceName, ':') = -1) and
	   (strpos(SourceName, '/') = -1) then begin
	    strcpy(FromName, Source_path);
	    strcat(FromName, SourceName);
	    SourceName := String(@SourceBuffer);
	    strcpy(SourceName, FromName);
	end;
	if not ExistFile(SourceName) then
	    Abort("Could not find source file");
    end;

    if (CommandSource <> src_CommandLine) and (not opt_Force) then begin
	strcpy(ToName, Dest_path);
	strcat(ToName, BaseName);
	if Object_suffix <> Nil then
	    strcat(ToName, Object_suffix^.Name);

	if ExistFile(ToName) then begin
	    if FileTime(ToName) > FileTime(SourceName) then begin
		if opt_Verbose then
		    Writeln('Skipping ', SourceName, ' (no changes)');
		if CommandSource = src_project then begin
		    if FileClass = class_main then
			SetName(Main_name, ToName)
		    else if FileClass = class_external then
			AddWord(External_names, ToName);
		end;
		return;
	    end;
	end;
    end;

    Assemble(SourceName, BaseName, ToName);

    if opt_Link and (CommandSource = src_CommandLine) then begin
	strcpy(FromName, ToName);
	Link(FromName, BaseName, ToName);
	if not DeleteFile(FromName) then
	    Abort("Could not delete temporary file");
    end;

    if CommandSource = src_Project then begin
	if FileClass = class_main then
	    SetName(Main_name, ToName)
	else if FileClass = class_external then
	    AddWord(External_names, ToName);
    end;
end;


Procedure ProcessObject(ObjectName : String);
var
    Suffix   : WordListPtr;
    BaseName : String;
    ToName   : String;
    BaseBuffer,
    SourceBuffer,
    ToBuffer : Array [0..255] of Char;
begin
    BaseName := String(@BaseBuffer);
    ToName   := String(@ToBuffer);

    Suffix := HasSuffix(ObjectName, Object_suffix);

    OnlyFileName(ObjectName, BaseName);
    if Suffix <> Nil then
	StripSuffix(BaseName, Suffix^.Name);

    if not ExistFile(ObjectName) then begin
	if (strpos(ObjectName, ':') = -1) and
	   (strpos(ObjectName, '/') = -1) then begin
	    strcpy(ToName, Source_path);
	    strcat(ToName, ObjectName);
	    ObjectName := String(@SourceBuffer);
	    strcpy(ObjectName, ToName);
	end;
	if not ExistFile(ObjectName) then
	    Abort("Could not find source file");
    end;

    if CommandSource = src_Project then begin
	if FileClass = class_main then
	    SetName(Main_name, ObjectName)
	else if FileClass = class_external then
	    AddWord(External_names, ObjectName);
    end else if CommandSource = src_CommandLine then
	Link(ObjectName, BaseName, ToName);
end;


Procedure ProcessSource(Param : String);
var
    FileName : String;
    Suffix   : WordListPtr;
begin
    if HasSuffix(Param, Project_suffix) <> Nil then
	ProcessProject(Param)
    else if HasSuffix(Param, Pascal_suffix) <> Nil then
	ProcessPascal(Param)
    else if HasSuffix(Param, Assembly_suffix) <> Nil then
	ProcessAssembly(Param)
    else if HasSuffix(Param, Object_suffix) <> Nil then
	ProcessObject(Param)
    else if CommandSource <> src_CommandLine then
	Abort("Unknown parameter")
    else begin

	FileName := AllocString(256);

	Suffix := Project_suffix;
	while Suffix <> Nil do begin
	    strcpy(FileName, Param);
	    strcat(FileName, Suffix^.Name);
	    if ExistFile(FileName) then begin
		ProcessProject(FileName);
		return;
	    end;
	    Suffix := Suffix^.Next;
	end;

	Suffix := Pascal_suffix;
	while Suffix <> Nil do begin
	    strcpy(FileName, Param);
	    strcat(FileName, Suffix^.Name);
	    if ExistFile(FileName) then begin
		ProcessPascal(FileName);
		return;
	    end;
	    Suffix := Suffix^.Next;
	end;

	Suffix := Assembly_suffix;
	while Suffix <> Nil do begin
	    strcpy(FileName, Param);
	    strcat(FileName, Suffix^.Name);
	    if ExistFile(FileName) then begin
		ProcessAssembly(FileName);
		return;
	    end;
	    Suffix := Suffix^.Next;
	end;

	Suffix := Object_suffix;
	while Suffix <> Nil do begin
	    strcpy(FileName, Param);
	    strcat(FileName, Suffix^.Name);
	    if ExistFile(FileName) then begin
		ProcessObject(FileName);
		return;
	    end;
	    Suffix := Suffix^.Next;
	end;

	Abort("Unknown parameter");

	FreeString(FileName);
    end;
end;

Procedure ProcessMain(MainName : String);
begin
    if CommandSource <> src_project then
	Abort("MAIN only allowed in project files");
    if strlen(Main_name) > 0 then
	Abort("Only one MAIN file allowed per project");

    FileClass := class_main;
    ProcessSource(MainName);
    FileClass := class_unknown;
end;

Procedure ProcessExternal(FileName : String);
begin
    if CommandSource <> src_project then
	Abort("EXTERNAL only allowed in project files");

    FileClass := class_external;
    ProcessSource(FileName);
    FileClass := class_unknown;
end;

Procedure SetExecName(name : String);
begin
    if strlen(Exec_name) > 0 then
	Abort("Only one EXEC command allowed per project");
    SetName(Exec_name, name);
end;

Procedure SetLinkForm(form : String);
begin
    case toupper(Form^) of
      'A' : LinkForm := form_Alink;
      'B' : LinkForm := form_Blink;
      'D' : LinkForm := form_Dlink;
    else
	Abort("Unknown linker format");
    end;
end;

Procedure ProcessOption(OptionLine : String);
var
    Prefix  : Char;
    Command : String;
    Suffix  : String;
begin
    if CheckBreak then
	Abort("User aborted");

    if (OptionLine^ = Chr(0)) or (OptionLine^ = '*') then
	return;

    if (OptionLine[0] = '-') or (OptionLine[0] = '+') then begin
	Prefix := OptionLine[0];
	strdel(OptionLine,0,1);
    end else
	Prefix := ' ';

    SplitLine(OptionLine, Command, Suffix);

    case FindOption(Command) of
	key_a,
	key_assemble	: SetSwitch(opt_assemble, Prefix);
	key_assembler	: SetCommandPath(Assembler_Path, Suffix);
	key_assemblererror
			: SetName(AssemError_name, Suffix);
	key_assembly	: SetList(Assembly_suffix, Suffix);
	key_b,
	key_shortcircuit : SetSwitch(opt_shortcircuit, Prefix);
	key_c,
	key_ccalls	: SetSwitch(opt_CCalls, Prefix);
	key_i,
	key_checkio	: SetSwitch(opt_CheckIO, Prefix);
	key_compiler	: SetCommandPath(Compiler_path, Suffix);
	key_compilererror
			: SetName(CompError_name, Suffix);
	key_d,
	key_debug	: SetSwitch(opt_Debug, Prefix);
	key_destination : SetPath(Dest_Path, Suffix);
	key_x,
	key_discard	: SetSwitch(opt_Discard, Prefix);
	key_exec	: SetExecName(Suffix);
	key_execute	: ExecuteProgram(Suffix);
	key_external    : ProcessExternal(Suffix);
	key_f,
	key_force	: SetSwitch(opt_Force, Prefix);
	key_l,
	key_link	: SetSwitch(opt_Link, Prefix);
	key_library	: SetList(LibraryList, Suffix);
	key_linker	: SetCommandPath(Linker_path, Suffix);
	key_linkererror	: SetName(LinkError_name, Suffix);
	key_linkform	: SetLinkForm(Suffix);
	key_main	: ProcessMain(Suffix);
	key_map		: SetMapName(Prefix, Suffix);
	key_mapoptions	: SetName(MapOptions, Suffix);
	key_mathtrans,
	key_n		: SetSwitch(opt_MathTrans, Prefix);
	key_nodebug	: SetSwitch(opt_NoDebug, Prefix);
	key_o,
	key_optimize	: SetSwitch(opt_optimize, Prefix);
	key_object	: SetList(Object_suffix, Suffix);
	key_optimizer	: SetCommandPath(Optimizer_path, Suffix);
	key_optimizererror
			: SetName(OptError_name, Suffix);
	key_p,
	key_profiler	: SetSwitch(opt_Profiler, Prefix);
	key_pascal	: SetList(Pascal_suffix, Suffix);
	key_project	: SetList(Project_suffix, Suffix);
	key_r,
	key_range	: SetSwitch(opt_RangeCheck, Prefix);
	key_smallcode	: SetSwitch(opt_SmallCode, Prefix);
	key_smalldata	: SetSwitch(opt_SmallData, Prefix);
	key_s,
	key_smallinit   : SetSwitch(opt_SmallInit, Prefix);
	key_source	: SetPath(Source_Path, Suffix);
	key_temp	: SetPath(Temp_Path, Suffix);
	key_v,
	key_verbose	: SetSwitch(opt_Verbose, Prefix);
	key_xref	: SetXrefName(Prefix,Suffix);
    else begin
	     if (Prefix = ' ') and (strlen(Suffix) = 0) then
		 ProcessSource(Command)
	     else
		 Writeln('Unknown command: ', Command);
	 end;
    end;
end;


Procedure ReadCfg(FileName : String);
var
    CfgFile : Text;
    CfgLine : String;
begin
    CfgLine := AllocString(256);
    if reopen(FileName, CfgFile) then begin
	while not EOF(CfgFile) do begin
	    CommandSource := src_cfg;
	    Readln(CfgFile, CfgLine);
	    ProcessOption(CfgLine);
	end;
	Close(CfgFile);
    end;
    FreeString(CfgLine);
end;

var
    Param    : String;
    ParamNum : Integer;    
begin
    Handle := Nil;

    SetDefaults;

    if ExistFile("s:pcq.cfg") then
	ReadCfg("s:pcq.cfg");
    if ExistFile("pcq.cfg") then
	ReadCfg("pcq.cfg");

    ParamNum := 1;
    Param := AllocString(256);
    repeat
	GetParam(ParamNum,Param);
	Inc(ParamNum);

	CommandSource := src_CommandLine;

	if Param^ = Chr(0) then
	    { Nothing }
	else if (Param^ = '-') or (Param^ = '+') then
	    ProcessOption(Param)
	else
	    ProcessSource(Param);
    until Param^ = Chr(0);
    if ParamNum = 2 then begin
	Writeln('PCQ Make Utility version 1.02 (September 18, 1991)');
	Writeln('Usage: PCQ <options> <files> ...');
	Writeln('       where <options> include all the configuration commands');
	Writeln('       and <files> include project, Pascal, assembly or object files');
    end;
end.


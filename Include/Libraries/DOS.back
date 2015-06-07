{
	DOS.i for PCQ Pascal

	Standard C header for AmigaDOS
}

Const

    DOSNAME	= "dos.library";

{ Predefined Amiga DOS global constants }

    DOSTRUE	= -1;
    DOSFALSE	= 0;

{ Mode parameter to Open() }

    MODE_OLDFILE	= 1005;		{ Open existing file read/write 
					  positioned at beginning of file. }
    MODE_NEWFILE	= 1006;		{ Open freshly created file (delete 
					  old file) read/write }
    MODE_READWRITE	= 1004;		{ Open old file w/exclusive lock }

{ Relative position to Seek() }

    OFFSET_BEGINNING	= -1;		{ relative to Begining Of File }
    OFFSET_CURRENT	= 0;		{ relative to Current file position }
    OFFSET_END		= 1;		{ relative to End Of File }

    BITSPERBYTE		= 8;
    BYTESPERLONG	= 4;
    BITSPERLONG		= 32;
    MAXINT		= $7FFFFFFF;
    MININT		= $80000000;

{ Passed as type to Lock() }

    SHARED_LOCK		= -2;		{ File is readable by others }
    ACCESS_READ		= -2;		{ Synonym }
    EXCLUSIVE_LOCK	= -1;		{ No other access allowed }
    ACCESS_WRITE	= -1;		{ Synonym }

Type

    FileHandle	= Address;
    FileLock	= Address;

    DateStampRec = record
	ds_Days		: Integer;	{ Number of days since Jan. 1, 1978 }
	ds_Minute	: Integer;	{ Number of minutes past midnight }
	ds_Tick		: Integer;	{ Number of ticks past minute }
    end;
    DateStampPtr = ^DateStampRec;

Const

    TICKS_PER_SECOND	= 50;		{ Number of ticks in one second }

Type

{ Returned by Examine() and ExInfo(), must be on a 4 byte boundary }

    FileInfoBlock = record
	fib_DiskKey	: Integer;
	fib_DirEntryType : Integer;
			{ Type of Directory. If < 0, then a plain file.
			  If > 0 a directory }
	fib_FileName	: Array [0..107] of Char;
			{ Null terminated. Max 30 chars used for now }
	fib_Protection	: Integer;
			{ bit mask of protection, rwxd are 3-0. }
	fib_EntryType	: Integer;
	fib_Size	: Integer;	{ Number of bytes in file }
	fib_NumBlocks	: Integer;	{ Number of blocks in file }
	fib_Date	: DateStampRec;	{ Date file last changed }
	fib_Comment	: Array [0..79] of Char;
			{ Null terminated comment associated with file }
	fib_Reserved	: Array [0..35] of Char;
    end;
    FileInfoBlockPtr = ^FileInfoBlock;


Const

{ FIB stands for FileInfoBlock }

{ FIBB are bit definitions, FIBF are field definitions }

    FIBB_SCRIPT		= 6;	{ program is a script (execute) file }
    FIBB_PURE		= 5;	{ program is reentrant and rexecutable}
    FIBB_ARCHIVE	= 4;	{ cleared whenever file is changed }
    FIBB_READ      	= 3;	{ ignored by old filesystem }
    FIBB_WRITE		= 2;	{ ignored by old filesystem }
    FIBB_EXECUTE	= 1;	{ ignored by system, used by Shell }
    FIBB_DELETE		= 0;	{ prevent file from being deleted }
    FIBF_SCRIPT		= 64;
    FIBF_PURE		= 32;
    FIBF_ARCHIVE	= 16;
    FIBF_READ		= 8;
    FIBF_WRITE		= 4;
    FIBF_EXECUTE	= 2;
    FIBF_DELETE		= 1;


Type

{ All BCPL data must be long word aligned.  BCPL pointers are the long word
 *  address (i.e byte address divided by 4 (>>2)) }

    BPTR	= Address;	{ Long word pointer }
    BSTR	= Address;	{ Long word pointer to BCPL string }

{ returned by Info(), must be on a 4 byte boundary }

    InfoData = record
	id_NumSoftErrors	: Integer;	{ number of soft errors on disk }
	id_UnitNumber		: Integer;	{ Which unit disk is (was) mounted on }
	id_DiskState		: Integer;	{ See defines below }
	id_NumBlocks		: Integer;	{ Number of blocks on disk }
	id_NumBlocksUsed	: Integer;	{ Number of block in use }
	id_BytesPerBlock	: Integer;
	id_DiskType		: Integer;	{ Disk Type code }
	id_VolumeNode		: BPTR;		{ BCPL pointer to volume node }
	id_InUse		: Integer;	{ Flag, zero if not in use }
    end;
    InfoDataPtr = ^InfoData;

Const

{ ID stands for InfoData }

	{ Disk states }

    ID_WRITE_PROTECTED	= 80;	{ Disk is write protected }
    ID_VALIDATING	= 81;	{ Disk is currently being validated }
    ID_VALIDATED	= 82;	{ Disk is consistent and writeable }

	{ Disk types }

    ID_NO_DISK_PRESENT	= -1;
    ID_UNREADABLE_DISK	= $42414400;	{ 'BAD\0' }
    ID_DOS_DISK		= $444F5300;	{ 'DOS\0' }
    ID_NOT_REALLY_DOS	= $4E444F53;	{ 'NDOS' }
    ID_KICKSTART_DISK	= $4B49434B;	{ 'KICK' }

{ Errors from IoErr(), etc. }

    ERROR_NO_FREE_STORE			= 103;
    ERROR_TASK_TABLE_FULL		= 105;
    ERROR_LINE_TOO_LONG			= 120;
    ERROR_FILE_NOT_OBJECT		= 121;
    ERROR_INVALID_RESIDENT_LIBRARY	= 122;
    ERROR_NO_DEFAULT_DIR		= 201;
    ERROR_OBJECT_IN_USE			= 202;
    ERROR_OBJECT_EXISTS			= 203;
    ERROR_DIR_NOT_FOUND			= 204;
    ERROR_OBJECT_NOT_FOUND		= 205;
    ERROR_BAD_STREAM_NAME		= 206;
    ERROR_OBJECT_TOO_LARGE		= 207;
    ERROR_ACTION_NOT_KNOWN		= 209;
    ERROR_INVALID_COMPONENT_NAME	= 210;
    ERROR_INVALID_LOCK			= 211;
    ERROR_OBJECT_WRONG_TYPE		= 212;
    ERROR_DISK_NOT_VALIDATED		= 213;
    ERROR_DISK_WRITE_PROTECTED		= 214;
    ERROR_RENAME_ACROSS_DEVICES		= 215;
    ERROR_DIRECTORY_NOT_EMPTY		= 216;
    ERROR_TOO_MANY_LEVELS		= 217;
    ERROR_DEVICE_NOT_MOUNTED		= 218;
    ERROR_SEEK_ERROR			= 219;
    ERROR_COMMENT_TOO_BIG		= 220;
    ERROR_DISK_FULL			= 221;
    ERROR_DELETE_PROTECTED		= 222;
    ERROR_WRITE_PROTECTED		= 223;
    ERROR_READ_PROTECTED		= 224;
    ERROR_NOT_A_DOS_DISK		= 225;
    ERROR_NO_DISK			= 226;
    ERROR_NO_MORE_ENTRIES		= 232;

{ These are the return codes used by convention by AmigaDOS commands }
{ See FAILAT and IF for relvance to EXECUTE files		      }

    RETURN_OK		= 0;	{ No problems, success }
    RETURN_WARN		= 5;	{ A warning only }
    RETURN_ERROR	= 10;	{ Something wrong }
    RETURN_FAIL		= 20;	{ Complete or severe failure}

{ Bit numbers that signal you that a user has issued a break }

    SIGBREAKB_CTRL_C	= 12;
    SIGBREAKB_CTRL_D	= 13;
    SIGBREAKB_CTRL_E	= 14;
    SIGBREAKB_CTRL_F	= 15;

{ Bit fields that signal you that a user has issued a break }
{ for example:	 if (SetSignal(0,0) & BREAK_CTRL_CF) cleanup_and_exit(); }

    SIGBREAKF_CTRL_C	= $00001000;
    SIGBREAKF_CTRL_D	= $00002000;
    SIGBREAKF_CTRL_E	= $00004000;
    SIGBREAKF_CTRL_F	= $00008000;


Procedure DOSClose(filehand : FileHandle);
    External;

Function CreateDir(name : String) : FileLock;
    External;

Function CurrentDir(lock : FileLock) : FileLock;
    External;

Procedure DateStamp(var ds : DateStampRec);
    External;

Procedure Delay(ticks : Integer);
    External;

Function DeleteFile(name : String) : Boolean;
    External;

Function DupLock(lock : FileLock) : FileLock;
    External;

Function Examine(lock : FileLock; info : FileInfoBlockPtr) : Boolean;
    External;

Function Execute(command : String; InFile, OutFile : FileHandle) : Boolean;
    External;

Procedure DOSExit(code : Integer);
    External;

Function ExNext(lock : FileLock; info : FileInfoBlockPtr) : Boolean;
    External;

Function Info(lock : FileLock; params : InfoDataPtr) : Boolean;
    External;

Function IoErr : Integer;
    External;

Function DOSInput : FileHandle;
    External;

Function IsInteractive(f : FileHandle) : Boolean;
    External;

Function Lock(name : String; accessmode : Integer) : FileLock;
    External;

Function DOSOpen(name : String; accessmode : Integer) : FileHandle;
    External;

Function DOSOutput : FileHandle;
    External;

Function ParentDir(lock : FileLock) : FileLock;
    External;

Function DOSRead(f : FileHandle; buffer : Address; length : Integer) : Integer;
    External;

Function Rename(oldname, newname : String) : Boolean;
    External;

Function Seek(f : FileHandle; pos : Integer; mode : Integer) : Integer;
    External;

Function SetComment(name : String; comment : String) : Boolean;
    External;

Function SetProtection(name : String; mask : Integer) : Boolean;
    External;

Procedure UnLock(lock : FileLock);
    External;

Function WaitForChar(f : FileHandle; timeout : Integer) : Boolean;
    External;

Function DOSWrite(f : FileHandle; buffer : Address; len : Integer) : Integer;
    External;


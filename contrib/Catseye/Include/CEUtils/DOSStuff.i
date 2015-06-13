{

	DOSStuff.i -	Cat'sEye AmigaDOS routines

	Feeble they may be

}

{$I "Include:Libraries/DOS.i"}
{$I "Include:CEUtils/IFF.i"}
{$I "Include:Utils/StringLib.i"}

Type	Entry = record
		Name	: Array [0..39] of char;
		IsD	: Boolean;
		Special,
		pad1	: Short;
		next	: ^Entry;
		end;
	EntryPtr = ^Entry;

Procedure DoRead (F : FileHandle; Buffer : Address; Length : Integer);
	External;

Procedure ReadCkHead (F : FileHandle; var header : Chunk);
	External;

Procedure ReadJunk (F : FileHandle; var Header : Chunk);
	External;

Function OpenIFF (idi : Integer; fs : String) : FileHandle;
	External;

Function OpenILBM (filespec : string) : FileHandle;
	External;

Function OpenSample (filespec : string) : FileHandle;
	External;

Function OpenSMUS (filespec : string) : FileHandle;
	External;

Function ListDir (L : FileLock; Head : EntryPtr) : Integer;
	External;

Function RemoveEntry (E, head : EntryPtr) : Boolean;
	External;

Function FindEntryByName (E : string; head : EntryPtr) : EntryPtr;
	External;

Function FindEntryByNumber (E : short; head : EntryPtr) : EntryPtr;
	External;

Procedure FreeList (Head : EntryPtr);
	External;

Function Parentage (var d : string) : Boolean;
	External;

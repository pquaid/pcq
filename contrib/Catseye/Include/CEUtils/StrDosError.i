{

	StrDosError.i for PCQ Pascal

	Cat'sEye

	In a vain attempt to make the DOS error messages more
	understandable...

	E should be allocated at at least 28 characters...

}

Procedure StrDosError (Var E : String; Err : Short);

begin
case Err of
    ERROR_NO_FREE_STORE			: StrCpy (E, "No free store");
    ERROR_TASK_TABLE_FULL		: StrCpy (E, "Task table full");
    ERROR_LINE_TOO_LONG			: StrCpy (E, "Line too long");
    ERROR_FILE_NOT_OBJECT		: StrCpy (E, "File not object");
    ERROR_INVALID_RESIDENT_LIBRARY	: StrCpy (E, "Bad library");
    ERROR_NO_DEFAULT_DIR		: StrCpy (E, "No default directory");
    ERROR_OBJECT_IN_USE			: StrCpy (E, "File is in use");
    ERROR_OBJECT_EXISTS			: StrCpy (E, "File exists");
    ERROR_DIR_NOT_FOUND			: StrCpy (E, "Directory not found");
    ERROR_OBJECT_NOT_FOUND		: StrCpy (E, "File not found");
    ERROR_BAD_STREAM_NAME		: StrCpy (E, "Bad stream name");
    ERROR_OBJECT_TOO_LARGE		: StrCpy (E, "File too large");
    ERROR_ACTION_NOT_KNOWN		: StrCpy (E, "Unknown action");
    ERROR_INVALID_COMPONENT_NAME	: StrCpy (E, "Bad component name");
    ERROR_INVALID_LOCK			: StrCpy (E, "Bad lock");
    ERROR_OBJECT_WRONG_TYPE		: StrCpy (E, "File of wrong type");
    ERROR_DISK_NOT_VALIDATED		: StrCpy (E, "Disk not validated");
    ERROR_DISK_WRITE_PROTECTED		: StrCpy (E, "Disk write protected");
    ERROR_RENAME_ACROSS_DEVICES		: StrCpy (E, "Rename across devices");
    ERROR_DIRECTORY_NOT_EMPTY		: StrCpy (E, "Directory not empty");
    ERROR_TOO_MANY_LEVELS		: StrCpy (E, "Too many levels");
    ERROR_DEVICE_NOT_MOUNTED		: StrCpy (E, "Device not mounted");
    ERROR_SEEK_ERROR			: StrCpy (E, "Seek() error");
    ERROR_COMMENT_TOO_BIG		: StrCpy (E, "Comment too large");
    ERROR_DISK_FULL			: StrCpy (E, "Disk full");
    ERROR_DELETE_PROTECTED		: StrCpy (E, "File protected from deletion");
    ERROR_WRITE_PROTECTED		: StrCpy (E, "File protected from writing");
    ERROR_READ_PROTECTED		: StrCpy (E, "File protected from reading");
    ERROR_NOT_A_DOS_DISK		: StrCpy (E, "Not a DOS disk");
    ERROR_NO_DISK			: StrCpy (E, "No disk in drive");
    ERROR_NO_MORE_ENTRIES		: StrCpy (E, "No more entries");
  end;
end;

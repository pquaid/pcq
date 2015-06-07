{
	ARexxStrings.i for PCQ Pascal

	These are the string-related functions of the rexxsyslib.  Note
	that some of the functions had to be renamed in order to avoid
	conflicts with the StringLib routines.
}

{$I "Include:Rexx/Storage.i"}

Function  RexxCmpString(ss1, ss2: NexxStrPtr): Integer;
    External;

Function  CVa2i(buffer : String; VAR value : Integer) : Integer;
    External;

Function  CVc2x(out, str : String; len, mode : Integer) : Integer;
    External;

Function  CVi2a(buf: String; val, digits : Integer; VAR ptr: String): Integer;
    External;

Function  CVi2arg(val, digs: Integer) : RexxArgPtr;
    External;

Function  CVi2az(buf : String; val, digs : Integer; var ptr : String) : Integer;
    External;

Function  CVx2c(out, val : String; len, mode : Integer) : Integer;
    External;

Function  ErrorMsg(code: Integer; var ss: NexxStrPtr): Boolean;
    External;

Function  IsSymbol(str : String; var Len : Integer): Integer;
    External;

Function  LengthArgstring(arg : Address): Integer;
    External;

Function  ListNames(list: ListPtr; seperator : Char): String;
    External;

Procedure StcToken(str: String; var Quote : Char; var Len : Integer;
			var scan, token : String);
    External;

Function  StrcpyA(dest, src: String; len: Integer): Byte;
    External;

Function  StrcpyN(dest, src: String; len: Integer): Byte;
    External;

Function  StrcpyU(dest, src: String; len: Integer): Byte;
    External;

Procedure StrflipN(str: String; length: Integer);
    External;

Function  RexxStrlen(str: String): Integer;
    External;

Function  StrcmpN(str1, str2: String; len: Integer): Integer;
    External;

Function  RexxToUpper(ch : Char): Char;
    External;


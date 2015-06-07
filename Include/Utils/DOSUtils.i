{
	DOSUtils.i for PCQ Pascal

	A couple of routines to make using DOS a little easier.
	The source code for these routines is under Runtime/Extras.
}

{$I "Include:Libraries/DOS.i"}

Function APTRtoBPTR(a : Address) : BPTR;
    External;

Function BPTRtoAPTR(b : BPTR) : Address;
    External;

Function GetFileHandle(var f : Text) : FileHandle;
    External;


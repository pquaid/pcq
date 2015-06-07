{
	Icon.i for PCQ Pascal

	external declarations for workbench support library
}

Const

{*******************************************************************
*
* library structures
*
*******************************************************************}


    ICONNAME		= "icon.library";

var
    IconBase	: Address;

Function AddFreeList(free : Address; mem : Address; len : Integer) : Boolean;
    External;
	{ free is a FreeListPtr }

Procedure BumpRevision(newbuf, oldname : String);
    External;

Function FindToolType(toolTypeArray : Address; typeName : String) : String;
    External;
	{ toolTypeArray is a pointer to an array of String }

Procedure FreeDiskObject(diskobj : Address);
    External;
	{ diskobj should be a DiskObjectPtr }

Procedure FreeFreeList(free : Address);
    External;
	{ free is a FreeListPtr }

Function GetDiskObject(name : String) : Address;
    External;
	{ actually returns a DiskObjectPtr }

Function MatchToolValue(typeString, value : String) : Boolean;
    External;

Function PutDiskObject(name : String; diskobj : Address) : Boolean;
    External;
	{ diskobj should be a DiskObjectPtr }


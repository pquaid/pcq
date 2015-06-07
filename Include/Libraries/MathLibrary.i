{
	MathLibrary.i for PCQ Pascal
}


{$I "Include:Exec/Libraries.i"}

Type

    MathIEEEBase = record
	MathIEEEBase_LibNode	: Library;
	MathIEEEBase_Flags	: Byte;
	MathIEEEBase_reserved1	: Byte;
	MathIEEEBase_68881	: Address;
	MathIEEEBase_SysLib	: Address;
	MathIEEEBase_SegList	: Address;
	MathIEEEBase_Resource	: Address;   { MathResourcePtr }
	MathIEEEBase_TaskOpenLib : Address;
	MathIEEEBase_TaskCloseLib : Address;
	{	This structure may be extended in the future }
    end;
    MathIEEEBasePtr = ^MathIEEEBase;

{
* Math resources may need to know when a program opens or closes this
* library. The functions TaskOpenLib and TaskCloseLib are called when 
* a task opens or closes this library. They are initialized to point to
* local initialization pertaining to 68881 stuff if 68881 resources 
* are found. To override the default the vendor must provide appropriate 
* hooks in the MathIEEEResource. If specified, these will be called 
* when the library initializes.
}

{
	FileSysRes.i for PCQ Pascal

	FileSystem.resource description
}


{$I "Include:Exec/Nodes.i"}
{$I "Include:Exec/Lists.i"}
{$I "Include:Libraries/DOS.i"}

Const

    FSRNAME	= "FileSystem.resource";

Type

    FileSysResource = record
	fsr_Node	: Node;		{ on resource list }
	fsr_Creator	: String;	{ name of creator of this resource }
	fsr_FileSysEntries : List;	{ list of FileSysEntry structs }
    end;
    FileSysResourcePtr = ^FileSysResource;

    FileSysEntry = record
	fse_Node	: Node;		{ on fsr_FileSysEntries list }
					{ ln_Name is of creator of this entry }
	fse_DosType	: Integer;	{ DosType of this FileSys }
	fse_Version	: Integer;	{ Version of this FileSys }
	fse_PatchFlags	: Integer;	{ bits set for those of the following that }
					{   need to be substituted into a standard }
					{   device node for this file system: e.g. }
					{   0x180 for substitute SegList & GlobalVec }
	fse_Type	: Integer;	{ device node type: zero }
	fse_Task	: Address;	{ standard dos "task" field }
	fse_Lock	: BPTR;		{ not used for devices: zero }
	fse_Handler	: BSTR;		{ filename to loadseg (if SegList is null) }
	fse_StackSize	: Integer;	{ stacksize to use when starting task }
	fse_Priority	: Integer;	{ task priority when starting task }
	fse_Startup	: BPTR;		{ startup msg: FileSysStartupMsg for disks }
	fse_SegList	: BPTR;		{ code to run to start new task }
	fse_GlobalVec	: BPTR;		{ BCPL global vector when starting task }
    { no more entries need exist than those implied by fse_PatchFlags }
    end;
    FileSysEntryPtr = ^FileSysEntry;

{
	ROMBoot_Base.i for PCQ Pascal
}


{$I "Include:Exec/Nodes.i"}
{$I "Include:Exec/Lists.i"}
{$I "Include:Exec/Libraries.i"}
{$I "Include:Exec/ExecBase.i"}
{$I "Include:Exec/ExecName.i"}

Type

    RomBootBase = record
	LibNode		: Library;
	ExecBase	: ExecBasePtr;
	BootList	: List;
	Reserved	: Array [0..3] of Integer;
				{ for future expansion }
    end;
    RomBootBasePtr = ^RomBootBase;

    BootNode = record
	bn_Node		: Node;
	bn_Flags	: Short;
	bn_DeviceNode	: Address;
    end;
    BootNodePtr = ^BootNode;

Const

    ROMBOOT_NAME	= "romboot.library";

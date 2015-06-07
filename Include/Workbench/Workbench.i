{
	Workbench.i for PCQ Pascal
}

{$I "Include:Exec/Nodes.i"}
{$I "Include:Exec/Lists.i"}
{$I "Include:Exec/Tasks.i"}
{$I "Include:Intuition/Intuition.i"}

Const

    WBDISK		= 1;
    WBDRAWER		= 2;
    WBTOOL		= 3;
    WBPROJECT		= 4;
    WBGARBAGE		= 5;
    WBDEVICE		= 6;
    WBKICK		= 7;

Type

    DrawerData = record
	dd_NewWindow	: NewWindow;	{ args to open window }
	dd_CurrentX	: Integer;	{ current x coordinate of origin }
	dd_CurrentY	: Integer;	{ current y coordinate of origin }
    end;
    DrawerDataPtr = ^DrawerData;

Const

{ the amount of DrawerData actually written to disk }

    DRAWERDATAFILESIZE	= 56;  { sizeof(DrawerData) }

Type

    DiskObject = record
	do_Magic	: Short;	{ a magic number at the start of the file }
	do_Version	: Short;	{ a version number, so we can change it }
	do_Gadget	: Gadget;	{ a copy of in core gadget }
	do_Type		: Byte;
	do_DefaultTool	: String;
	do_ToolTypes	: Address;
	do_CurrentX	: Integer;
	do_CurrentY	: Integer;
	do_DrawerData	: DrawerDataPtr;
	do_ToolWindow	: String;	{ only applies to tools }
	do_StackSize	: Integer;	{ only applies to tools }
    end;
    DiskObjectPtr = ^DiskObject;

Const

    WB_DISKMAGIC	= $e310;	{ a magic number, not easily impersonated }
    WB_DISKVERSION	= 1;		{ our current version number }

Type

    FreeList = record
	fl_NumFree	: Short;
	fl_MemList	: List;
    end;
    FreeListPtr = FreeList;

Const

{ each message that comes into the WorkBenchPort must have a type field
 * in the preceeding short.  These are the defines for this type
 }

    MTYPE_PSTD		= 1;	{ a "standard Potion" message }
    MTYPE_TOOLEXIT	= 2;	{ exit message from our tools }
    MTYPE_DISKCHANGE	= 3;	{ dos telling us of a disk change }
    MTYPE_TIMER		= 4;	{ we got a timer tick }
    MTYPE_CLOSEDOWN	= 5;	{ <unimplemented> }
    MTYPE_IOPROC	= 6;	{ <unimplemented> }

{ workbench does different complement modes for its gadgets.
 * It supports separate images, complement mode, and backfill mode.
 * The first two are identical to intuitions GADGIMAGE and GADGHCOMP.
 * backfill is similar to GADGHCOMP, but the region outside of the
 * image (which normally would be color three when complemented)
 * is flood-filled to color zero.
 }

    GADGBACKFILL	= $0001;

{ if an icon does not really live anywhere, set its current position
 * to here
 }

    NO_ICON_POSITION	= $80000000;

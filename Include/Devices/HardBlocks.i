{
	HardBlocks.i for PCQ Pascal

	File System identifier blocks for hard disks
}

{--------------------------------------------------------------------
 *
 *	This file describes blocks of data that exist on a hard disk
 *	to describe that disk.  They are not generically accessable to
 *	the user as they do not appear on any DOS drive.  The blocks
 *	are tagged with a unique identifier, checksummed, and linked
 *	together.  The root of these blocks is the RigidDiskBlock.
 *
 *	The RigidDiskBlock must exist on the disk within the first
 *	RDB_LOCATION_LIMIT blocks.  This inhibits the use of the zero
 *	cylinder in an AmigaDOS partition: although it is strictly
 *	possible to store the RigidDiskBlock data in the reserved
 *	area of a partition, this practice is discouraged since the
 *	reserved blocks of a partition are overwritten by "Format",
 *	"Install", "DiskCopy", etc.  The recommended disk layout,
 *	then, is to use the first cylinder(s) to store all the drive
 *	data specified by these blocks: i.e. partition descriptions,
 *	file system load images, drive bad block maps, spare blocks,
 *	etc.
 *
 *	Though only 512 byte blocks are currently supported by the
 *	file system, this proposal tries to be forward-looking by
 *	making the block size explicit, and by using only the first
 *	256 bytes for all blocks but the LoadSeg data.
 *
 *------------------------------------------------------------------}

{
 *  NOTE
 *	optional block addresses below contain $ffffffff to indicate
 *	a NULL address, as zero is a valid address
}

type

    RigidDiskBlock = record
	rdb_ID		: Integer;	{ 4 character identifier }
	rdb_SummedLongs	: Integer;	{ size of this checksummed structure }
	rdb_ChkSum	: Integer;	{ block checksum (longword sum to zero) }
	rdb_HostID	: Integer;	{ SCSI Target ID of host }
	rdb_BlockBytes	: Integer;	{ size of disk blocks }
	rdb_Flags	: Integer;	{ see below for defines }

    { block list heads }

	rdb_BadBlockList : Integer;	{ optional bad block list }
	rdb_PartitionList : Integer;	{ optional first partition block }
	rdb_FileSysHeaderList : Integer; { optional file system header block }
	rdb_DriveInit	: Integer;	{ optional drive-specific init code }

				{ DriveInit(lun,rdb,ior): "C" stk & d0/a0/a1 }

	rdb_Reserved1	: Array [0..5] of Integer; { set to $ffffffff }

    { physical drive characteristics }

	rdb_Cylinders	: Integer;	{ number of drive cylinders }
	rdb_Sectors	: Integer;	{ sectors per track }
	rdb_Heads	: Integer;	{ number of drive heads }
	rdb_Interleave	: Integer;	{ interleave }
	rdb_Park	: Integer;	{ landing zone cylinder }
	rdb_Reserved2	: Array [0..2] of Integer;
	rdb_WritePreComp : Integer;	{ starting cylinder: write precompensation }
	rdb_ReducedWrite : Integer;	{ starting cylinder: reduced write current }
	rdb_StepRate	: Integer;	{ drive step rate }
	rdb_Reserved3	: Array [0..4] of Integer;

    { logical drive characteristics }

	rdb_RDBBlocksLo	: Integer;	{ low block of range reserved for hardblocks }
	rdb_RDBBlocksHi	: Integer;	{ high block of range for these hardblocks }
	rdb_LoCylinder	: Integer;	{ low cylinder of partitionable disk area }
	rdb_HiCylinder	: Integer;	{ high cylinder of partitionable data area }
	rdb_CylBlocks	: Integer;	{ number of blocks available per cylinder }
	rdb_AutoParkSeconds : Integer;	{ zero for no auto park }
	rdb_Reserved4	: Array [0..1] of Integer;

    { drive identification }

	rdb_DiskVendor	: Array [0..7] of Char;
	rdb_DiskProduct	: Array [0..15] of Char;
	rdb_DiskRevision : Array [0..3] of Char;
	rdb_ControllerVendor : Array [0..7] of Char;
	rdb_ControllerProduct : Array [0..15] of Char;
	rdb_ControllerRevision : Array [0..3] of Char;
	rdb_Reserved5	: Array [0..9] of Integer;
    end;
    RigidDiskBlockPtr = ^RigidDiskBlock;

const
    IDNAME_RIGIDDISK	= $5244534B;   { RDSK }

    RDB_LOCATION_LIMIT	= 16;

    RDBFB_LAST		= 0;	{ no disks exist to be configured after }
    RDBFF_LAST		= $01;	{   this one on this controller }
    RDBFB_LASTLUN	= 1;	{ no LUNs exist to be configured greater }
    RDBFF_LASTLUN	= $02;	{   than this one at this SCSI Target ID }
    RDBFB_LASTTID	= 2;	{ no Target IDs exist to be configured }
    RDBFF_LASTTID	= $04;	{   greater than this one on this SCSI bus }
    RDBFB_NORESELECT	= 3;	{ don't bother trying to perform reselection }
    RDBFF_NORESELECT	= $08;	{   when talking to this drive }
    RDBFB_DISKID	= 4;	{ rdb_Disk... identification valid }
    RDBFF_DISKID	= $10;
    RDBFB_CTRLRID	= 5;	{ rdb_Controller... identification valid }
    RDBFF_CTRLRID	= $20;

{------------------------------------------------------------------}

type

    BadBlockEntry = record
	bbe_BadBlock	: Integer;	{ block number of bad block }
	bbe_GoodBlock	: Integer;	{ block number of replacement block }
    end;
    BadBlockEntryPtr = ^BadBlockEntry;

    BadBlockBlock = record
	bbb_ID		: Integer;	{ 4 character identifier }
	bbb_SummedLongs	: Integer;	{ size of this checksummed structure }
	bbb_ChkSum	: Integer;	{ block checksum (longword sum to zero) }
	bbb_HostID	: Integer;	{ SCSI Target ID of host }
	bbb_Next	: Integer;	{ block number of the next BadBlockBlock }
	bbb_Reserved	: Integer;
	bbb_BlockPairs	: Array [0..60] of BadBlockEntry; { bad block entry pairs }
    { note [61] assumes 512 byte blocks }
    end;
    BadBlockBlockPtr = ^BadBlockBlock;

const

    IDNAME_BADBLOCK	= $42414442;   { BADB }

{------------------------------------------------------------------}

type

    PartitionBlock = record
	pb_ID		: Integer;	{ 4 character identifier }
	pb_SummedLongs	: Integer;	{ size of this checksummed structure }
	pb_ChkSum	: Integer;	{ block checksum (longword sum to zero) }
	pb_HostID	: Integer;	{ SCSI Target ID of host }
	pb_Next		: Integer;	{ block number of the next PartitionBlock }
	pb_Flags	: Integer;	{ see below for defines }
	pb_Reserved1	: Array [0..1] of Integer;
	pb_DevFlags	: Integer;	{ preferred flags for OpenDevice }
	pb_DriveName	: Array [0..31] of Char; { preferred DOS device name: BSTR form }
					{ (not used if this name is in use) }
	pb_Reserved2	: Array [0..14] of Integer; { filler to 32 longwords }
	pb_Environment	: Array [0..16] of Integer; { environment vector for this partition }
	pb_EReserved	: Array [0..14] of Integer; { reserved for future environment vector }
    end;
    PartitionBlockPtr = ^PartitionBlock;

const

    IDNAME_PARTITION	= $50415254;    { PART }

    PBFB_BOOTABLE	= 0;	{ this partition is intended to be bootable }
    PBFF_BOOTABLE	= 1;	{   (expected directories and files exist) }
    PBFB_NOMOUNT	= 1;	{ do not mount this partition (e.g. manually }
    PBFF_NOMOUNT	= 2;	{   mounted, but space reserved here) }

{------------------------------------------------------------------}

type

    FileSysHeaderBlock = record
	fhb_ID		: Integer;	{ 4 character identifier }
	fhb_SummedLongs	: Integer;	{ size of this checksummed structure }
	fhb_ChkSum	: Integer;	{ block checksum (longword sum to zero) }
	fhb_HostID	: Integer;	{ SCSI Target ID of host }
	fhb_Next	: Integer;	{ block number of next FileSysHeaderBlock }
	fhb_Flags	: Integer;	{ see below for defines }
	fhb_Reserved1	: Array [0..1] of Integer;
	fhb_DosType	: Integer;	{ file system description: match this with }
				{ partition environment's DE_DOSTYPE entry }
	fhb_Version	: Integer;	{ release version of this code }
	fhb_PatchFlags	: Integer;	{ bits set for those of the following that }
				{   need to be substituted into a standard }
				{   device node for this file system: e.g. }
				{   0x180 to substitute SegList & GlobalVec }
	fhb_Type	: Integer;	{ device node type: zero }
	fhb_Task	: Integer;	{ standard dos "task" field: zero }
	fhb_Lock	: Integer;	{ not used for devices: zero }
	fhb_Handler	: Integer;	{ filename to loadseg: zero placeholder }
	fhb_StackSize	: Integer;	{ stacksize to use when starting task }
	fhb_Priority	: Integer;	{ task priority when starting task }
	fhb_Startup	: Integer;	{ startup msg: zero placeholder }
	fhb_SegListBlocks : Integer;	{ first of linked list of LoadSegBlocks: }
				{   note that this entry requires some }
				{   processing before substitution }
	fhb_GlobalVec	: Integer;	{ BCPL global vector when starting task }
	fhb_Reserved2	: Array [0..22] of Integer; { (those reserved by PatchFlags) }
	fhb_Reserved3	: Array [0..20] of Integer;
    end;
    FileSysHeaderBlockPtr = ^FileSysHeaderBlock;

const

    IDNAME_FILESYSHEADER	= $46534844;    { FSHD }

{------------------------------------------------------------------}

Type

    LoadSegBlock = record
	lsb_ID		: Integer;	{ 4 character identifier }
	lsb_SummedLongs	: Integer;	{ size of this checksummed structure }
	lsb_ChkSum	: Integer;	{ block checksum (longword sum to zero) }
	lsb_HostID	: Integer;	{ SCSI Target ID of host }
	lsb_Next	: Integer;	{ block number of the next LoadSegBlock }
	lsb_LoadData	: Array [0..122] of Integer;	{ data for "loadseg" }
    { note [123] assumes 512 byte blocks }
    end;
    LoadSegBlockPtr = ^LoadSegBlock;

const

    IDNAME_LOADSEG	= $4C534547;	{ LSEG }


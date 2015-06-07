{
	Trackdisk.i for PCQ Pascal
}

{$I "Include:Exec/IO.i"}
{$I "Include:Exec/Devices.i"}

{
 *--------------------------------------------------------------------
 *
 * Physical drive constants
 *
 *--------------------------------------------------------------------
}

Const

    NUMSECS	= 11;
    NUMUNITS	= 4;

{
 *--------------------------------------------------------------------
 *
 * Useful constants
 *
 *--------------------------------------------------------------------
 }

{-- sizes before mfm encoding }
    TD_SECTOR	= 512;
    TD_SECSHIFT	= 9;		{ log TD_SECTOR }

{
 *--------------------------------------------------------------------
 *
 * Driver Specific Commands
 *
 *--------------------------------------------------------------------
 }

{
 *-- TD_NAME is a generic macro to get the name of the driver.	This
 *-- way if the name is ever changed you will pick up the change
 *-- automatically.
 *--
 *-- Normal usage would be:
 *--
 *-- char internalName[] = TD_NAME;
 *--
 }

    TD_NAME	= "trackdisk.device";

    TDF_EXTCOM	= $00010000;		{ for internal use only! }


    TD_MOTOR		= CMD_NONSTD + 0;	{ control the disk's motor }
    TD_SEEK		= CMD_NONSTD + 1;	{ explicit seek (for testing) }
    TD_FORMAT		= CMD_NONSTD + 2;	{ format disk }
    TD_REMOVE		= CMD_NONSTD + 3;	{ notify when disk changes }
    TD_CHANGENUM	= CMD_NONSTD + 4;	{ number of disk changes }
    TD_CHANGESTATE	= CMD_NONSTD + 5;	{ is there a disk in the drive? }
    TD_PROTSTATUS	= CMD_NONSTD + 6;	{ is the disk write protected? }
    TD_RAWREAD		= CMD_NONSTD + 7;	{ read raw bits from the disk }
    TD_RAWWRITE		= CMD_NONSTD + 8;	{ write raw bits to the disk }
    TD_GETDRIVETYPE	= CMD_NONSTD + 9;	{ get the type of the disk drive }
    TD_GETNUMTRACKS	= CMD_NONSTD + 10;	{ # of tracks for this type drive }
    TD_ADDCHANGEINT	= CMD_NONSTD + 11;	{ TD_REMOVE done right }
    TD_REMCHANGEINT	= CMD_NONSTD + 12;	{ remove softint set by ADDCHANGEINT }

    TD_LASTCOMM		= CMD_NONSTD + 13;

{
 *
 * The disk driver has an "extended command" facility.	These commands
 * take a superset of the normal IO Request block.
 *
 }

    ETD_WRITE		= CMD_WRITE + TDF_EXTCOM;
    ETD_READ		= CMD_READ + TDF_EXTCOM;
    ETD_MOTOR		= TD_MOTOR + TDF_EXTCOM;
    ETD_SEEK		= TD_SEEK + TDF_EXTCOM;
    ETD_FORMAT		= TD_FORMAT + TDF_EXTCOM;
    ETD_UPDATE		= CMD_UPDATE + TDF_EXTCOM;
    ETD_CLEAR		= CMD_CLEAR + TDF_EXTCOM;
    ETD_RAWREAD		= TD_RAWREAD + TDF_EXTCOM;
    ETD_RAWWRITE	= TD_RAWWRITE + TDF_EXTCOM;

{
 *
 * extended IO has a larger than normal io request block.
 *
 }

Type

    IOExtTD = record
	iotd_Req	: IOStdReq;
	iotd_Count	: Integer;
	iotd_SecLabel	: Integer;
    end;
    IOExtTDPtr = ^IOExtTD;


Const

{
** raw read and write can be synced with the index pulse.  This flag
** in io request's IO_FLAGS field tells the driver that you want this.
}

    IOTDB_INDEXSYNC	= 4;
    IOTDF_INDEXSYNC	= 16;


{ labels are TD_LABELSIZE bytes per sector }

    TD_LABELSIZE	= 16;

{
** This is a bit in the FLAGS field of OpenDevice.  If it is set, then
** the driver will allow you to open all the disks that the trackdisk
** driver understands.	Otherwise only 3.5" disks will succeed.
}

    TDB_ALLOW_NON_3_5	= 0;
    TDF_ALLOW_NON_3_5	= 1;

{
**  If you set the TDB_ALLOW_NON_3_5 bit in OpenDevice, then you don't
**  know what type of disk you really got.  These defines are for the
**  TD_GETDRIVETYPE command.  In addition, you can find out how many
**  tracks are supported via the TD_GETNUMTRACKS command.
}

    DRIVE3_5		= 1;
    DRIVE5_25		= 2;

{
 *--------------------------------------------------------------------
 *
 * Driver error defines
 *
 *--------------------------------------------------------------------
 }

    TDERR_NotSpecified		= 20;	{ general catchall }
    TDERR_NoSecHdr		= 21;	{ couldn't even find a sector }
    TDERR_BadSecPreamble	= 22;	{ sector looked wrong }
    TDERR_BadSecID		= 23;	{ ditto }
    TDERR_BadHdrSum		= 24;	{ header had incorrect checksum }
    TDERR_BadSecSum		= 25;	{ data had incorrect checksum }
    TDERR_TooFewSecs		= 26;	{ couldn't find enough sectors }
    TDERR_BadSecHdr		= 27;	{ another "sector looked wrong" }
    TDERR_WriteProt		= 28;	{ can't write to a protected disk }
    TDERR_DiskChanged		= 29;	{ no disk in the drive }
    TDERR_SeekError		= 30;	{ couldn't find track 0 }
    TDERR_NoMem			= 31;	{ ran out of memory }
    TDERR_BadUnitNum		= 32;	{ asked for a unit > NUMUNITS }
    TDERR_BadDriveType		= 33;	{ not a drive that trackdisk groks }
    TDERR_DriveInUse		= 34;	{ someone else allocated the drive }
    TDERR_PostReset		= 35;	{ user hit reset; awaiting doom }

{
 *--------------------------------------------------------------------
 *
 * public portion of the unit structure
 *
 *--------------------------------------------------------------------
 }

Type

    TDU_PublicUnit = record
	tdu_Unit	: Unit;		{ base message port }
	tdu_Comp01Track	: Short;	{ track for first precomp }
	tdu_Comp10Track	: Short;	{ track for second precomp }
	tdu_Comp11Track	: Short;	{ track for third precomp }
	tdu_StepDelay	: Integer;	{ time to wait after stepping }
	tdu_SettleDelay	: Integer;	{ time to wait after seeking }
	tdu_RetryCnt	: Byte;		{ # of times to retry }
    end;
    TDU_PublicUnitPtr = ^TDU_PublicUnit;


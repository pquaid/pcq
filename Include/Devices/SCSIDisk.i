{
	SCSIDisk.i for PCQ Pascal

	SCSI exec-level device command
}

{--------------------------------------------------------------------
 *
 *   SCSI Command
 *	Several Amiga SCSI controller manufacturers are converging on
 *	standard ways to talk to their controllers.  This include
 *	file describes an exec-device command (e.g. for hddisk.device)
 *	that can be used to issue SCSI commands
 *
 *   UNIT NUMBERS
 *	Unit numbers to the OpenDevice call have encoded in them which
 *	SCSI device is being referred to.  The three decimal digits of
 *	the unit number refer to the SCSI Target ID (bus address) in
 *	the 1's digit, the SCSI logical unit (LUN) in the 10's digit,
 *	and the controller board in the 100's digit.
 *
 *	Examples:
 *		  0	drive at address 0
 *		 12	LUN 1 on multiple drive controller at address 2
 *		104	second controller board, address 4
 *		 88	not valid: both logical units and addresses
 *			range from 0..7.
 *
 *   CAVEATS
 *	Original 2090 code did not support this command.
 *
 *	Commodore 2090/2090A unit numbers are different.  The SCSI
 *	logical unit is the 100's digit, and the SCSI Target ID
 *	is a permuted 1's digit: Target ID 0..6 maps to unit 3..9
 *	(7 is reserved for the controller).
 *
 *	    Examples:
 *		  3	drive at address 0
 *		109	drive at address 6, logical unit 1
 *		  1	not valid: this is not a SCSI unit.  Perhaps
 *			it's an ST506 unit.
 *
 *	Some controller boards generate a unique name (e.g. 2090A's
 *	iddisk.device) for the second controller board, instead of
 *	implementing the 100's digit.
 *
 *	There are optional restrictions on the alignment, bus
 *	accessability, and size of the data for the data phase.
 *	Be conservative to work with all manufacturer's controllers.
 *
 *------------------------------------------------------------------}

Const

    HD_SCSICMD		= 28;	{ issue a SCSI command to the unit }
				{ io_Data points to a SCSICmd }
				{ io_Length is sizeof(struct SCSICmd) }
				{ io_Actual and io_Offset are not used }

Type

    SCSICmd = record
	scsi_Data	: Address; { word aligned data for SCSI Data Phase }
				   { (optional) data need not be byte aligned }
				   { (optional) data need not be bus accessable }
	scsi_Length	: Integer; { even length of Data area }
				   { (optional) data can have odd length }
				   { (optional) data length can be > 2**24 }
	scsi_Actual	: Integer; { actual Data used }
	scsi_Command	: Address; { SCSI Command (same options as scsi_Data) }
	scsi_CmdLength	: Short;   { length of Command }
	scsi_CmdActual	: Short;   { actual Command used }
	scsi_Flags	: Byte;    { includes intended data direction }
	scsi_Status	: Byte;	   { SCSI status of command }
    end;
    SCSICmdPtr = ^SCSICmd;


Const

{----- scsi_Flags -----}
    SCSIF_WRITE		= 0;	{ intended data direction is out }
    SCSIF_READ		= 1;	{ intended data direction is in }

{----- SCSI io_Error values -----}
    HFERR_SelfUnit	= 40;	{ cannot issue SCSI command to self }
    HFERR_DMA		= 41;	{ DMA error }
    HFERR_Phase		= 42;	{ illegal or unexpected SCSI phase }
    HFERR_Parity	= 43;	{ SCSI parity error }
    HFERR_SelTimeout	= 44;	{ Select timed out }
    HFERR_BadStatus	= 45;	{ status and/or sense error }

{----- OpenDevice io_Error values -----}
    HFERR_NoBoard	= 50;	{ Open failed for non-existant board }


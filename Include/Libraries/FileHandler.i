{
	FileHandler.i for PCQ Pascal

	device and file handler specific code for AmigaDOS
}


{$I "Include:Exec/Ports.i"}
{$I "Include:Libraries/DOS.i"}


{ The disk "environment" is a longword array that describes the
 * disk geometry.  It is variable sized, with the length at the beginning.
 * Here are the constants for a standard geometry.
}

Type

    DosEnvec = record
	de_TableSize	: Integer;	{ Size of Environment vector }
	de_SizeBlock	: Integer;	{ in longwords: standard value is 128 }
	de_SecOrg	: Integer;	{ not used; must be 0 }
	de_Surfaces	: Integer;	{ # of heads (surfaces). drive specific }
	de_SectorPerBlock : Integer;	{ not used; must be 1 }
	de_BlocksPerTrack : Integer;	{ blocks per track. drive specific }
	de_Reserved	: Integer;	{ DOS reserved blocks at start of partition. }
	de_PreAlloc	: Integer;	{ DOS reserved blocks at end of partition }
	de_Interleave	: Integer;	{ usually 0 }
	de_LowCyl	: Integer;	{ starting cylinder. typically 0 }
	de_HighCyl	: Integer;	{ max cylinder. drive specific }
	de_NumBuffers	: Integer;	{ Initial # DOS of buffers.  }
	de_BufMemType	: Integer;	{ type of mem to allocate for buffers }
	de_MaxTransfer	: Integer;	{ Max number of bytes to transfer at a time }
	de_Mask		: Integer;	{ Address Mask to block out certain memory }
	de_BootPri	: Integer;	{ Boot priority for autoboot }
	de_DosType	: Integer;	{ ASCII (HEX) string showing filesystem type;
					* 0X444F5300 is old filesystem,
					* 0X444F5301 is fast file system }
    end;
    DOSEnvecPtr = ^DOSEnvec;

Const

{ these are the offsets into the array }

    DE_TABLESIZE	= 0;	{ standard value is 11 }
    DE_SIZEBLOCK	= 1;	{ in longwords: standard value is 128 }
    DE_SECORG		= 2;	{ not used; must be 0 }
    DE_NUMHEADS		= 3;	{ # of heads (surfaces). drive specific }
    DE_SECSPERBLK	= 4;	{ not used; must be 1 }
    DE_BLKSPERTRACK 	= 5;	{ blocks per track. drive specific }
    DE_RESERVEDBLKS 	= 6;	{ unavailable blocks at start.	 usually 2 }
    DE_PREFAC		= 7;	{ not used; must be 0 }
    DE_INTERLEAVE	= 8;	{ usually 0 }
    DE_LOWCYL		= 9;	{ starting cylinder. typically 0 }
    DE_UPPERCYL		= 10;	{ max cylinder.  drive specific }
    DE_NUMBUFFERS	= 11;	{ starting # of buffers.  typically 5 }
    DE_MEMBUFTYPE	= 12;	{ type of mem to allocate for buffers. }
    DE_BUFMEMTYPE	= 12;	{ same as above, better name
				 * 1 is public, 3 is chip, 5 is fast }
    DE_MAXTRANSFER	= 13;	{ Max number bytes to transfer at a time }
    DE_MASK		= 14;	{ Address Mask to block out certain memory }
    DE_BOOTPRI		= 15;	{ Boot priority for autoboot }
    DE_DOSTYPE		= 16;	{ ASCII (HEX) string showing filesystem type;
				 * 0X444F5300 is old filesystem,
				 * 0X444F5301 is fast file system }

{ The file system startup message is linked into a device node's startup
** field.  It contains a pointer to the above environment, plus the
** information needed to do an exec OpenDevice().
}

Type

    FileSysStartupMsg = record
	fssm_Unit	: Integer;	{ exec unit number for this device }
	fssm_Device	: BSTR;		{ null terminated bstring to the device name }
	fssm_Environ	: BPTR;		{ ptr to environment table (see above) }
	fssm_Flags	: Integer;	{ flags for OpenDevice() }
    end;
    FileSysStartupMsgPtr = ^FileSysStartupMsg;


{ The include file "libraries/dosextens.h" has a DeviceList structure.
 * The "device list" can have one of three different things linked onto
 * it.	Dosextens defines the structure for a volume.  DLT_DIRECTORY
 * is for an assigned directory.  The following structure is for
 * a dos "device" (DLT_DEVICE).
}

    DeviceNode = record
	dn_Next		: BPTR;		{ singly linked list }
	dn_Type		: Integer;	{ always 0 for dos "devices" }
	dn_Task		: MsgPortPtr;	{ standard dos "task" field.  If this is
					 * null when the node is accesses, a task
					 * will be started up }
	dn_Lock		: BPTR;		{ not used for devices -- leave null }
	dn_Handler	: BSTR;		{ filename to loadseg (if seglist is null) }
	dn_StackSize	: Integer;	{ stacksize to use when starting task }
	dn_Priority	: Integer;	{ task priority when starting task }
	dn_Startup	: BPTR;		{ startup msg: FileSysStartupMsg for disks }
	dn_SegList	: BPTR;		{ code to run to start new task (if necessary).
					 * if null then dn_Handler will be loaded. }
	dn_GlobalVec	: BPTR;	{ BCPL global vector to use when starting
				 * a task.  -1 means that dn_SegList is not
				 * for a bcpl program, so the dos won't
				 * try and construct one.  0 tell the
				 * dos that you obey BCPL linkage rules,
				 * and that it should construct a global
				 * vector for you.
				 }
	dn_Name		: BSTR;		{ the node name, e.g. '\3','D','F','3' }
    end;
    DeviceNodePtr = ^DeviceNode;

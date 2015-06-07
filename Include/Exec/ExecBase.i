{
    ExecBase.i for PCQ Pascal
}
{$I "Include:Exec/Lists.i"}
{$I "Include:Exec/Interrupts.i"}
{$I "Include:Exec/Libraries.i"}
{$I "Include:Exec/Tasks.i"}

type
    ExecBase = record
	LibNode	: Library;
	SoftVer	: Short;		{ kickstart release number	 }
	LowMemChkSum	: Short;
	ChkBase	: Integer;		{ system base pointer complement }
	ColdCapture 	: Address;	{ coldstart soft vector	 }
	CoolCapture	: Address;
	WarmCapture	: Address;
	SysStkUpper	: Address;	{ system stack base (upper bound) }
	SysStkLower	: Address;	{ top of system stack (lower bound) }
	MaxLocMem	: Integer;
	DebugEntry	: Address;
	DebugData	: Address;
	AlertData	: Address;
	MaxExtMem	: Address;	{ top of extended mem, or null if none }

	ChkSum		: Short;

{***** Interrupt Related **************************************}

	IntVects	: Array [0..15] of IntVector;

{***** System Variables ***************************************}

	ThisTask	: TaskPtr; { pointer to current task }
	IdleCount	: Integer;	{ idle counter }
	DispCount	: Integer;	{ dispatch counter }
	Quantum		: Short;	{ time slice quantum }
	Elapsed		: Short;	{ current quantum ticks }
	SysFlags	: Short;	{ misc system flags }
	IDNestCnt	: Byte;		{ interrupt disable nesting count }
	TDNestCnt	: Byte;		{ task disable nesting count }

	AttnFlags	: Short;	{ special attention flags }
	AttnResched	: Short;	{ rescheduling attention }

	ResModules	: Address;	{ resident module array pointer }
	TaskTrapCode	: Address;
	TaskExceptCode	: Address;
	TaskExitCode	: Address;
	TaskSigAlloc	: Integer;
	TaskTrapAlloc	: Short;


{***** System Lists *******************************************}

	MemList,
	ResourceList,
	DeviceList,
	IntrList,
	LibList,
	PortList,
	TaskReady,
	TaskWait	: List;

	SoftInts	: Array [0..4] of SoftIntList;

{***** Other Globals ******************************************}

	LastAlert	: Array [0..3] of Integer;



	{ these next two variables are provided to allow
	** system developers to have a rough idea of the
	** period of two externally controlled signals --
	** the time between vertical blank interrupts and the
	** external line rate (which is counted by CIA A's
	** "time of day" clock).  In general these values
	** will be 50 or 60, and may or may not track each
	** other.  These values replace the obsolete AFB_PAL
	** and AFB_50HZ flags.
	}

	VBlankFrequency		: Byte;
	PowerSupplyFrequency	: Byte;

	SemaphoreList		: List;

	{ these next two are to be able to kickstart into user ram.
	** KickMemPtr holds a singly linked list of MemLists which
	** will be removed from the memory list via AllocAbs.  If
	** all the AllocAbs's succeeded, then the KickTagPtr will
	** be added to the rom tag list.
	}

	KickMemPtr	: Address;	{ ptr to queue of mem lists }
	KickTagPtr	: Address;	{ ptr to rom tag queue }
	KickCheckSum	: Address;	{ checksum for mem and tags }

	ExecBaseReserved : Array [0..9] of Byte;
	ExecBaseNewReserved : Array [0..19] of Byte;
    end;
    ExecBasePtr = ^ExecBase;

{****** AttnFlags }

const

{  Processors and Co-processors: }
    AFB_68010	= 0;	{ also set for 68020 }
    AFB_68020	= 1;
    AFB_68881	= 4;

    AFF_68010	= 1;
    AFF_68020	= 2;
    AFF_68881	= 16;

{ These two bits used to be AFB_PAL and AFB_50HZ.  After some soul
** searching we realized that they were misnomers, and the information
** is now kept in VBlankFrequency and PowerSupplyFrequency above.
** To find out what sort of video conversion is done, look in the
** graphics subsytem.
}

    AFB_RESERVED8	= 8;
    AFB_RESERVED9	= 9;

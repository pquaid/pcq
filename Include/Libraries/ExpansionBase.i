{
	ExpansionBase.i for PCQ Pascal
}

{$I "Include:Exec/Libraries.i"}
{$I "Include:Exec/Interrupts.i"}
{$I "Include:Exec/Semaphores.i"}
{$I "Include:Libraries/ConfigVars.i"}

Const

    TOTALSLOTS	= 256;

Type

    ExpansionInt = record
	IntMask		: Short;
	ArrayMax	: Short;
	ArraySize	: Short;
    end;
    ExpansionIntPtr = ^ExpansionInt;


    ExpansionBaseRec = record
	LibNode		: Library;
	Flags		: Byte;
	pad		: Byte;
	ExecBase	: Address;
	SegList		: Address;
	eb_CurrentBinding	: CurrentBinding;
	BoardList	: List;
	MountList	: List;
	AllocTable	: Array [0..TOTALSLOTS-1] of Byte;
	BindSemaphore	: SignalSemaphore;
	Int2List	: Interrupt;
	Int6List	: Interrupt;
	Int7List	: Interrupt;
    end;
    ExpansionBasePtr = ^ExpansionBaseRec;

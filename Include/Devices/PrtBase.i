{
	PrtBase.i for PCQ Pascal

	printer device data definition
}

{$I "Include:Exec/Nodes.i"}
{$I "Include:Exec/Lists.i"}
{$I "Include:Exec/Ports.i"}
{$I "Include:Exec/Libraries.i"}
{$I "Include:Exec/Tasks.i"}
{$I "Include:Devices/Parallel.i"}
{$I "Include:Devices/Serial.i"}
{$I "Include:Devices/Timer.i"}
{$I "Include:Libraries/DosExtens.i"}
{$I "Include:Intuition/Intuition.i"}

Type

    DeviceData = record
	dd_Device	: Library;	{ standard library node }
	dd_Segment	: Address;	{ A0 when initialized }
	dd_ExecBase	: Address;	{ A6 for exec }
	dd_CmdVectors	: Address;	{ command table for device commands }
	dd_CmdBytes	: Address;      { bytes describing which command queue }
	dd_NumCommands	: Short;	{ the number of commands supported }
    end;
    DeviceDataPtr = ^DeviceData;

Const

    P_STKSIZE		= $0800;	{ stack size for child task }
    P_BUFSIZE		= 256;		{ size of internal buffers for text i/o }
    P_SAFESIZE		= 128;		{ safety margin for text output buffer }

Type

    PrinterData = record
	pd_Device	: DeviceData;
	pd_Unit		: MsgPort;	{ the one and only unit }
	pd_PrinterSegment : Address;	{ the printer specific segment }
	pd_PrinterType	: Short;	{ the segment printer type }
					{ the segment data structure }
	pd_SegmentData	: Address;	{ (PrinterSegmentPtr) }
	pd_PrintBuf	: Address;	{ the raster print buffer }
	pd_PWrite	: Address;	{ the write function }
	pd_PBothReady	: Address;	{ write function's done }
	pd_ior0		: IOExtPar;	{ or IOExtSer: port I/O request }
	pd_ior1		: IOExtPar;	{ or IOExtSer: for double buffering }
	pd_TIOR		: TimeRequest;	{ timer I/O request }
	pd_IORPort	: MsgPort;	{   and message reply port }
	pd_TC		: Task;		{ write task }
	pd_Stk		: Array [0..P_STKSIZE-1] of Byte;
					{   and stack space }
	pd_Flags	: Byte;		{ device flags }
	pd_pad		: Byte;
	pd_Preferences	: Preferences;	{ the latest preferences }
	pd_PWaitEnabled	: Byte;	{ wait function switch }
    end;
    PrinterDataPtr = ^PrinterData;

Const

{ Printer Class }

    PPCB_GFX		= 0;		{ graphics (bit position) }
    PPCF_GFX		= 1;		{ graphics (and/or flag) }
    PPCB_COLOR		= 1;		{ color (bit position) }
    PPCF_COLOR		= 2;		{ color (and/or flag) }

    PPC_BWALPHA		= 0;		{ black&white alphanumerics }
    PPC_BWGFX		= 1;		{ black&white graphics }
    PPC_COLORALPHA	= 2;		{ color alphanumerics }
    PPC_COLORGFX	= 3;		{ color graphics }

{ Color Class }

    PCC_BW		= 1;		{ black&white only }
    PCC_YMC		= 2;		{ yellow/magenta/cyan only }
    PCC_YMC_BW		= 3;		{ yellow/magenta/cyan or black&white }
    PCC_YMCB		= 4;		{ yellow/magenta/cyan/black }
    PCC_4COLOR		= 4;		{ a flag for YMCB and BGRW }
    PCC_ADDITIVE	= 8;		{ not ymcb but blue/green/red/white }
    PCC_WB		= 9;		{ black&white only, 0 == BLACK }
    PCC_BGR		= 10;		{ blue/green/red }
    PCC_BGR_WB		= 11;		{ blue/green/red or black&white }
    PCC_BGRW		= 12;		{ blue/green/red/white }

{
	The picture must be scanned once for each color component, as the
	printer can only define one color at a time.  ie. If 'PCC_YMC' then
	first pass sends all 'Y' info to printer, second pass sends all 'M'
	info, and third pass sends all C info to printer.  The CalComp
	PlotMaster is an example of this type of printer.
}

    PCC_MULTI_PASS	= $10;		{ see explanation above }

Type

    PrinterExtendedData = record
	ped_PrinterName	: String;	{ printer name, null terminated }
	ped_Init	: Address;	{ called after LoadSeg }
	ped_Expunge	: Address;	{ called before UnLoadSeg }
	ped_Open	: Address;	{ called at OpenDevice }
	ped_Close	: Address;	{ called at CloseDevice }
	ped_PrinterClass : Byte;	{ printer class }
	ped_ColorClass	: Byte;		{ color class }
	ped_MaxColumns	: Byte;		{ number of print columns available }
	ped_NumCharSets	: Byte;		{ number of character sets }
	ped_NumRows	: Short;	{ number of 'pins' in print head }
	ped_MaxXDots	: Integer;	{ number of dots max in a raster dump }
	ped_MaxYDots	: Integer;	{ number of dots max in a raster dump }
	ped_XDotsInch	: Short;	{ horizontal dot density }
	ped_YDotsInch	: Short;	{ vertical dot density }
	ped_Commands	: Address;	{ printer text command table }
	ped_DoSpecial	: Address;	{ special command handler }
	ped_Render	: Address;	{ raster render function }
	ped_TimeoutSecs	: Integer;	{ good write timeout }

	{ the following only exists if the segment version is >= 33 }

	ped_8BitChars	: Address;	{ conv. strings for the extended font }
	ped_PrintMode	: Integer;	{ set if text printed, otherwise 0 }

	{ the following only exists if the segment version is >= 34 }
	{ ptr to conversion function for all chars }

	ped_ConvFunc	: Address;
    end;
    PrinterExtendedDataPtr = ^PrinterExtendedData;


    PrinterSegment = record
	ps_NextSegment	: Address;	{ (actually a BPTR) }
	ps_runAlert	: Integer;	{ MOVEQ #0,D0 : RTS }
	ps_Version	: Short;	{ segment version }
	ps_Revision	: Short;	{ segment revision }
	ps_PED		: PrinterExtendedData;	{ printer extended data }
    end;
    PrinterSegmentPtr = ^PrinterSegment;


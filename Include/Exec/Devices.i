{
    Devices.i for PCQ Pascal
}

{$I "Include:Exec/Libraries.i"}
{$I "Include:Exec/Ports.i"}

{***** Device *****************************************************}

type
    Device = record
	dd_Library : Library;
    end;
    DevicePtr = ^Device;

{***** Unit *******************************************************}

    Unit = record
	unit_MsgPort	: MsgPort;	{ queue for unprocessed messages }
					{ instance of msgport is recommended }
	unit_flags	: Byte;
	unit_pad	: Byte;
	unit_OpenCnt	: Short;	{ number of active opens }
    end;
    UnitPtr = ^Unit;

const
    UNITF_ACTIVE	= 1;
    UNITF_INTASK	= 2;

Procedure AddDevice(device : DevicePtr);
    External;

Procedure CloseDevice(io : Address);	{ io is an IORequestPtr }
    External;

Function OpenDevice(devName : String; unitNumber : Integer;
			io : Address; flags : Integer) : Integer;
    External;	{ io is an IORequestPtr }

Procedure RemDevice(device : DevicePtr);
    External;


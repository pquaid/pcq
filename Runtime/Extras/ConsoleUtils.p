External;

{
	These routines just open and close the Console device without
attaching it to any window.  They update ConsoleBase, and are thus required
for RawKeyConvert and DeadKeyConvert.
}

{$I "Include:Exec/IO.i"}
{$I "Include:Devices/InputEvent.i"}
{$I "Include:Exec/Devices.i"}

var
    ConsoleBase : Address;	{ external references }
    ConsoleRequest : IOStdReq;

Procedure OpenConsoleDevice;
{
	This procedure initializes ConsoleDevice, which is required for
    CDInputHandler and RawKeyConvert.
}
var
    Error : Integer;
begin
    Error := OpenDevice("console.device", -1, Adr(ConsoleRequest), 0);
    ConsoleBase := ConsoleRequest.io_Device;
end;

Procedure CloseConsoleDevice;
begin
    CloseDevice(Adr(ConsoleRequest));
end;

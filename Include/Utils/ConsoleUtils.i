
{
	ConsoleUtils.i for PCQ Pascal

	    This file defines two functions that simply initialize and close
	the console device.  They do it by calling OpenDevice, then setting
	ConsoleBase (defined in Devices/Console.i) to io_Device.

	    Also see Utils/ConsoleIO.i, Utils/CRT.i, and of course
	Devices/Console.i.

	    The source for these two functions, which are written in
	Pascal, are in RunTime/Extras.
}

{$I "Include:Exec/IO.i"}
{$I "Include:Devices/Console.i"}

var
    ConsoleRequest : IOStdReq;

Procedure OpenConsoleDevice;
    External;
	{ Assigns a valid pointer, or Nil, to ConsoleBase.  All it
	  does, actually, is call OpenDevice and extract the
	  io_Device field.  In any case, you must get a valid pointer
	  into ConsoleBase before calling RawKeyConvert or
	  CDInputHandler. }

Procedure CloseConsoleDevice;
    External;
      {	Closes the console device }


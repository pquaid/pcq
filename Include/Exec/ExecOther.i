{
	ExecOther.i of PCQ Pascal

	This file defines the Exec routines that are not defined
	elsewhere.
}

Procedure Debug(Param : Integer);	{ Always pass zero for now }
    External;

Function GetCC : Integer;
    External;

Procedure RawDoFmt(Form : String;
		   data : Address;
		   putChProc : Address;
		   putChData : Address);
    External;

Function SetSR(newSR, mask : Integer) : Integer;
    External;


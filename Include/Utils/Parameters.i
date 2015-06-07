
{
	Parameters.i

	    This is the stuff necessary for command line work, including
	the Workbench message.
}

{$I "Include:Exec/Ports.i"}
{$I "Include:Workbench/Startup.i"}

{
    The following function just returns the Workbench message pointer.
}

Function GetStartupMsg : WBStartupPtr;
    external;

{
    This procedure copies the requested parameter into the string S.
S must already be allocated, of course.  Note that the parameters can
come from the command line or from the Workbench message.  S will be
a string of length 0 (in other words S^ = Chr(0)) if the parameter
doesn't exist.
}

Procedure GetParam(n : Short; S : String);
    external;


{
	Input.i for PCQ Pascal

	input device command definitions 
}

{$I "Include:Exec/IO.i"}

const

    IND_ADDHANDLER	= CMD_NONSTD + 0;
    IND_REMHANDLER	= CMD_NONSTD + 1;
    IND_WRITEEVENT	= CMD_NONSTD + 2;
    IND_SETTHRESH	= CMD_NONSTD + 3;
    IND_SETPERIOD	= CMD_NONSTD + 4;
    IND_SETMPORT	= CMD_NONSTD + 5;
    IND_SETMTYPE	= CMD_NONSTD + 6;
    IND_SETMTRIG	= CMD_NONSTD + 7;


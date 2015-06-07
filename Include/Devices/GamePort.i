{
	GamePort.i for PCQ Pascal

	GamePort device command definitions
}

{$I "Include:Exec/IO.i"}

const

{*****	 GamePort commands *****}

    GPD_READEVENT	= CMD_NONSTD + 0;
    GPD_ASKCTYPE	= CMD_NONSTD + 1;
    GPD_SETCTYPE	= CMD_NONSTD + 2;
    GPD_ASKTRIGGER	= CMD_NONSTD + 3;
    GPD_SETTRIGGER	= CMD_NONSTD + 4;

{*****	 GamePort structures *****}

{ gpt_Keys }

    GPTB_DOWNKEYS	= 0;
    GPTF_DOWNKEYS	= 1;
    GPTB_UPKEYS		= 1;
    GPTF_UPKEYS		= 2;

type

    GamePortTrigger = record
	gpt_Keys	: Short;	{ key transition triggers }
	gpt_Timeout	: Short;	{ time trigger (vertical blank units) }
	gpt_XDelta	: Short;	{ X distance trigger }
	gpt_YDelta	: Short;	{ Y distance trigger }
    end;


const

{***** Controller Types *****}

    GPCT_ALLOCATED	= -1;	{ allocated by another user }
    GPCT_NOCONTROLLER	= 0;

    GPCT_MOUSE		= 1;
    GPCT_RELJOYSTICK	= 2;
    GPCT_ABSJOYSTICK	= 3;


{***** Errors *****}

    GPDERR_SETCTYPE	= 1;	{ this controller not valid at this time }


{
	Audio.i for PCQ Pascal
}

{$I "Include:Exec/IO.i"}

const

    AUDIONAME		= "audio.device";

    ADHARD_CHANNELS	= 4;

    ADALLOC_MINPREC	= -128;
    ADALLOC_MAXPREC	= 127;

    ADCMD_FREE		= CMD_NONSTD + 0;
    ADCMD_SETPREC	= CMD_NONSTD + 1;
    ADCMD_FINISH	= CMD_NONSTD + 2;
    ADCMD_PERVOL	= CMD_NONSTD + 3;
    ADCMD_LOCK		= CMD_NONSTD + 4;
    ADCMD_WAITCYCLE	= CMD_NONSTD + 5;
    ADCMDB_NOUNIT	= 5;
    ADCMDF_NOUNIT	= 32;
    ADCMD_ALLOCATE	= ADCMDF_NOUNIT + 0;

    ADIOB_PERVOL	= 4;
    ADIOF_PERVOL	= 16;
    ADIOB_SYNCCYCLE	= 5;
    ADIOF_SYNCCYCLE	= 32;
    ADIOB_NOWAIT	= 6;
    ADIOF_NOWAIT	= 64;
    ADIOB_WRITEMESSAGE	= 7;
    ADIOF_WRITEMESSAGE	= 128;
 
    ADIOERR_NOALLOCATION	= -10;
    ADIOERR_ALLOCFAILED		= -11;
    ADIOERR_CHANNELSTOLEN	= -12;

type
    IOAudio = record
	ioa_Request	: IORequest;
	ioa_AllocKey	: Short;
	ioa_Data	: Address;
	ioa_Length	: Integer;
	ioa_Period	: Short;
	ioa_Volume	: Short;
	ioa_Cycles	: Short;
	ioa_WriteMsg	: Message;
    end;
    IOAudioPtr = ^IOAudio;


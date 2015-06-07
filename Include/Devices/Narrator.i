{
	Narrator.i for PCQ Pascal
}

{$I "Include:Exec/IO.i"}

Const

		{	    Error Codes		}

    ND_NoMem		= -2;	{ Can't allocate memory		}
    ND_NoAudLib		= -3;	{ Can't open audio device		}
    ND_MakeBad		= -4;	{ Error in MakeLibrary call		}
    ND_UnitErr		= -5;	{ Unit other than 0			}
    ND_CantAlloc	= -6;	{ Can't allocate audio channel(s)	}
    ND_Unimpl		= -7;	{ Unimplemented command		}
    ND_NoWrite		= -8;	{ Read for mouth without write first	}
    ND_Expunged		= -9;	{ Can't open, deferred expunge bit set }
    ND_PhonErr		= -20;	{ Phoneme code spelling error		}
    ND_RateErr		= -21;	{ Rate out of bounds			}
    ND_PitchErr		= -22;	{ Pitch out of bounds			}
    ND_SexErr		= -23;	{ Sex not valid			}
    ND_ModeErr		= -24;	{ Mode not valid			}
    ND_FreqErr		= -25;	{ Sampling frequency out of bounds	}
    ND_VolErr		= -26;	{ Volume out of bounds			}
    


		{ Input parameters and defaults }

    DEFPITCH		= 110;	{ Default pitch			}
    DEFRATE		= 150;	{ Default speaking rate (wpm)		}
    DEFVOL		= 64;	{ Default volume (full)		}
    DEFFREQ		= 22200; { Default sampling frequency (Hz)	}
    MALE		= 0;	{ Male vocal tract			}
    FEMALE		= 1;	{ Female vocal tract			}
    NATURALF0		= 0;	{ Natural pitch contours		}
    ROBOTICF0		= 1;	{ Monotone				}
    DEFSEX		= MALE;	{ Default sex				}
    DEFMODE		= NATURALF0;	{ Default mode				}



		{	Parameter bounds	}

    MINRATE		= 40;	{ Minimum speaking rate		}
    MAXRATE		= 400;	{ Maximum speaking rate		}
    MINPITCH		= 65;	{ Minimum pitch			}
    MAXPITCH		= 320;	{ Maximum pitch			}
    MINFREQ		= 5000;	{ Minimum sampling frequency		}
    MAXFREQ		= 28000; { Maximum sampling frequency		}
    MINVOL		= 0;	{ Minimum volume			}
    MAXVOL		= 64;	{ Maximum volume			}



Type

		{    Standard Write request	}

    narrator_rb = record
	message		: IOStdReq;	{ Standard IORB		}
	rate		: Short;	{ Speaking rate (words/minute) }
	pitch		: Short;	{ Baseline pitch in Hertz	}
	mode		: Short;	{ Pitch mode			}
	sex		: Short;	{ Sex of voice			}
	ch_masks	: Address;	{ Pointer to audio alloc maps	}
	nm_masks	: Short;	{ Number of audio alloc maps	}
	volume		: Short;	{ Volume. 0 (off) thru 64	}
	sampfreq	: Short;	{ Audio sampling freq		}
	mouths		: Boolean;	{ If non-zero, generate mouths }
	chanmask	: Byte;		{ Which ch mask used (internal)}
	numchan		: Byte;		{ Num ch masks used (internal) }
	pad		: Byte;		{ For alignment		}
    end;
    narrator_rbPtr = ^narrator_rb;


		{    Standard Read request	}

    mouth_rb = record
	voice	: narrator_rb;		{ Speech IORB			}
	width	: Byte;			{ Width (returned value)	}
	height	: Byte;			{ Height (returned value)	}
	shape	: Byte;			{ Internal use, do not modify	}
	pad	: Byte;			{ For alignment		}
    end;
    mouth_rbPtr = ^mouth_rb;


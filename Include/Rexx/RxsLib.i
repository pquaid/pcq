{ === rexx/rxslib.h ===================================================
 *
 * Copyright (c) 1986, 1987, 1989 by William S. Hawes (All Rights Reserved)
 *
 * =====================================================================
 * The header file for the REXX Systems Library
}

{$I "Include:Rexx/Storage.i"}

{ Some macro definitions                                               }

Const

    RXSNAME	= "rexxsyslib.library";
    RXSID	= "rexxsyslib 1.06 (07 MAR 88)\n";
    RXSDIR	= "REXX";
    RXSTNAME	= "ARexx";

{ The REXX systems library structure.  This should be considered as    }
{ semi-private and read-only, except for documented exceptions.        }

Type

    RxsLib = record
	rl_Node		: Library;	{ EXEC library node             }
	rl_Flags	: Byte;		{ global flags                  }
	rl_pad		: Byte;
	rl_SysBase	: Address;	{ EXEC library base             }
	rl_DOSBase	: Address;	{ DOS library base              }
	rl_IeeeDPBase	: Address;	{ IEEE DP math library base     }
	rl_SegList	: Address;	{ library seglist               }
	rl_NIL		: Address;	{ global NIL: filehandle        }
	rl_Chunk	: Integer;	{ allocation quantum            }
	rl_MaxNest	: Integer;	{ maximum expression nesting    }
	rl_NULL		: NexxStrPtr;	{ static string: NULL           }
	rl_FALSE	: NexxStrPtr;	{ static string: FALSE          }
	rl_TRUE		: NexxStrPtr;	{ static string: TRUE           }
	rl_REXX		: NexxStrPtr;	{ static string: REXX           }
	rl_COMMAND	: NexxStrPtr;	{ static string: COMMAND        }
	rl_STDIN	: NexxStrPtr;	{ static string: STDIN          }
	rl_STDOUT	: NexxStrPtr;	{ static string: STDOUT         }
	rl_STDERR	: NexxStrPtr;	{ static string: STDERR         }
	rl_Version	: String;	{ version/configuration string  }

	rl_TaskName	: String;	{ name string for tasks         }
	rl_TaskPri	: Integer;	{ starting priority             }
	rl_TaskSeg	: Address;	{ startup seglist               }
	rl_StackSize	: Integer;	{ stack size                    }
	rl_RexxDir	: String;	{ REXX directory                }
	rl_CTABLE	: String;	{ character attribute table     }
	rl_Notice	: NexxStrPtr;	{ copyright notice              }

	rl_RexxPort	: MsgPort;	{ REXX public port              }
	rl_ReadLock	: Short;	{ lock count                    }
	rl_TraceFH	: Address;	{ global trace console          }
	rl_TaskList	: List;		{ REXX task list                }
	rl_NumTask	: Short;	{ task count                    }
	rl_LibList	: List;		{ Library List header           }
	rl_NumLib	: Short;	{ library count                 }
	rl_ClipList	: List;		{ ClipList header               }
	rl_NumClip	: Short;	{ clip node count               }
	rl_MsgList	: List;		{ pending messages              }
	rl_NumMsg	: Short;	{ pending count                 }
	rl_PgmList	: List;		{ cached programs               }
	rl_NumPgm	: Short;	{ program count                 }

	rl_TraceCnt	: Short;	{ usage count for trace console }
	rl_avail	: Short;
    end;
    RxsLibPtr = ^RxsLib;

Const

{ Global flag bit definitions for RexxMaster                           }
    RLFB_TRACE	= RTFB_TRACE;		{ interactive tracing?          }
    RLFB_HALT	= RTFB_HALT;		{ halt execution?               }
    RLFB_SUSP	= RTFB_SUSP;		{ suspend execution?            }
    RLFB_STOP	= 6;			{ deny further invocations      }
    RLFB_CLOSE	= 7;			{ close the master              }

    RLFMASK	= 1 + 2 + 4;

{ Initialization constants                                             }

    RXSVERS	= 34;			{ main version                  }
    RXSREV	= 7;			{ revision                      }
    RXSALLOC	= $800000;		{ maximum allocation            }
    RXSCHUNK	= 1024;			{ allocation quantum            }
    RXSNEST	= 32;			{ expression nesting limit      }
    RXSTPRI	= 0;			{ task priority                 }
    RXSSTACK	= 4096;			{ stack size                    }
    RXSLISTH	= 5;			{ number of list headers        }

{ Character attribute flag bits used in REXX.                          }

    CTB_SPACE	= 0;			{ white space characters        }
    CTB_DIGIT	= 1;			{ decimal digits 0-9            }
    CTB_ALPHA	= 2;			{ alphabetic characters         }
    CTB_REXXSYM	= 3;			{ REXX symbol characters        }
    CTB_REXXOPR	= 4;			{ REXX operator characters      }
    CTB_REXXSPC	= 5;			{ REXX special symbols          }
    CTB_UPPER	= 6;			{ UPPERCASE alphabetic          }
    CTB_LOWER	= 7;			{ lowercase alphabetic          }
                                                                      
{ Attribute flags                                                      }

    CTF_SPACE	= 1;
    CTF_DIGIT	= 2;
    CTF_ALPHA	= 4;
    CTF_REXXSYM	= 8;
    CTF_REXXOPR	= 16;
    CTF_REXXSPC	= 32;
    CTF_UPPER	= 64;
    CTF_LOWER	= 128;


Procedure LockRexxBase(resource : Integer);
    External;

Procedure UnlockRexxBase(resource : Integer);
    External;


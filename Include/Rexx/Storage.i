{ === rexx/storage.h ==================================================
 *
 * Copyright (c) 1986, 1987 by William S. Hawes (All Rights Reserved)
 *
 * =====================================================================
 * Header file to define ARexx data structures.
}

{$I "Include:Exec/Nodes.i"}
{$I "Include:Exec/Lists.i"}
{$I "Include:Exec/Ports.i"}
{$I "Include:Exec/Libraries.i"}

{ The NexxStr structure is used to maintain the internal strings in REXX.
 * It includes the buffer area for the string and associated attributes.
 * This is actually a variable-length structure; it is allocated for a
 * specific length string, and the length is never modified thereafter
 * (since it's used for recycling).
 }

Type

    NexxStr = record
	ns_Ivalue	: Integer;	{ integer value                 }
	ns_Length	: Short;	{ length in bytes (excl null)   }
	ns_Flags	: Byte;		{ attribute flags               }
	ns_Hash		: Byte;		{ hash code                     }
	ns_Buff		: Array [0..7] of Byte;
					{ buffer area for strings       }
    end;				{ size: 16 bytes (minimum)      }
    NexxStrPtr = ^NexxStr;

Const

    NXADDLEN	= 9;			{ offset plus null byte         }

{ String attribute flag bit definitions                                }

    NSB_KEEP	= 0;			{ permanent string?             }
    NSB_STRING	= 1;			{ string form valid?            }
    NSB_NOTNUM	= 2;			{ non-numeric?                  }
    NSB_NUMBER	= 3;			{ a valid number?               }
    NSB_BINARY	= 4;			{ integer value saved?          }
    NSB_FLOAT	= 5;			{ floating point format?        }
    NSB_EXT	= 6;			{ an external string?           }
    NSB_SOURCE	= 7;			{ part of the program source?   }

{ The flag form of the string attributes                               }

    NSF_KEEP	= 1;
    NSF_STRING	= 2;
    NSF_NOTNUM	= 4;
    NSF_NUMBER	= 8;
    NSF_BINARY	= 16;
    NSF_FLOAT	= 32;
    NSF_EXT	= 64;
    NSF_SOURCE	= 128;

{ Combinations of flags                                                }

    NSF_INTNUM	= NSF_NUMBER + NSF_BINARY + NSF_STRING;
    NSF_DPNUM	= NSF_NUMBER + NSF_FLOAT;
    NSF_ALPHA	= NSF_NOTNUM + NSF_STRING;
    NSF_OWNED	= NSF_SOURCE + NSF_EXT    + NSF_KEEP;
    KEEPSTR	= NSF_STRING + NSF_SOURCE + NSF_NOTNUM;
    KEEPNUM	= NSF_STRING + NSF_SOURCE + NSF_NUMBER + NSF_BINARY;

{ The RexxArg structure is identical to the NexxStr structure, but
 * is allocated from system memory rather than from internal storage.
 * This structure is used for passing arguments to external programs.
 * It is usually passed as an "argstring", a pointer to the string buffer.
}

Type

    RexxArg = record
	ra_Size		: Integer;	{ total allocated length        }
	ra_Length	: Short;	{ length of string              }
	ra_Flags	: Byte;		{ attribute flags               }
	ra_Hash		: Byte;		{ hash code                     }
	ra_Buff		: Array [0..7] of Byte;
					{ buffer area                   }
    end;				{ size: 16 bytes (minimum)      }
    RexxArgPtr = ^RexxArg;

{ The RexxMsg structure is used for all communications with REXX
 * programs.  It is an EXEC message with a parameter block appended.
}

    RexxMsg = record
	rm_Node		: Message;	{ EXEC message structure        }
	rm_TaskBlock	: Address;	{ global structure (private)    }
	rm_LibBase	: Address;	{ library base (private)        }
	rm_Action	: Integer;	{ command (action) code         }
	rm_Result1	: Integer;	{ primary result (return code)  }
	rm_Result2	: Integer;	{ secondary result              }
	rm_Args		: Array [0..15] of String;
					{ argument block (ARG0-ARG15)   }

	rm_PassPort	: MsgPortPtr;	{ forwarding port               }
	rm_CommAddr	: String;	{ host address (port name)      }
	rm_FileExt	: String;	{ file extension                }
	rm_Stdin	: Address;	{ input stream (filehandle)     }
	rm_Stdout	: Address;	{ output stream (filehandle)    }
	rm_avail	: Integer;	{ future expansion              }
    end;				{ size: 128 bytes               }
    RexxMsgPtr = ^RexxMsg;

Const

    MAXRMARG		= 15;		{ maximum arguments             }

{ Command (action) codes for message packets                           }

    RXCOMM		= $01000000;	{ a command-level invocation    }
    RXFUNC		= $02000000;	{ a function call               }
    RXCLOSE		= $03000000;	{ close the REXX server         }
    RXQUERY		= $04000000;	{ query for information         }
    RXADDFH		= $07000000;	{ add a function host           }
    RXADDLIB		= $08000000;	{ add a function library        }
    RXREMLIB		= $09000000;	{ remove a function library     }
    RXADDCON		= $0A000000;	{ add/update a ClipList string  }
    RXREMCON		= $0B000000;	{ remove a ClipList string      }
    RXTCOPN		= $0C000000;	{ open the trace console        }
    RXTCCLS		= $0D000000;	{ close the trace console       }

{ Command modifier flag bits                                           }

    RXFB_NOIO		= 16;		{ suppress I/O inheritance?     }
    RXFB_RESULT		= 17;		{ result string expected?       }
    RXFB_STRING		= 18;		{ program is a "string file"?   }
    RXFB_TOKEN		= 19;		{ tokenize the command line?    }
    RXFB_NONRET		= 20;		{ a "no-return" message?        }

{ The flag form of the command modifiers                               }

    RXFF_NOIO		= $00010000;
    RXFF_RESULT		= $00020000;
    RXFF_STRING		= $00040000;
    RXFF_TOKEN		= $00080000;
    RXFF_NONRET		= $00100000;

    RXCODEMASK		= $FF000000;
    RXARGMASK		= $0000000F;

{ The RexxRsrc structure is used to manage global resources.  Each node 
 * has a name string created as a RexxArg structure, and the total size
 * of the node is saved in the "rr_Size" field.  The REXX systems library
 * provides functions to allocate and release resource nodes.  If special
 * deletion operations are required, an offset and base can be provided in
 * "rr_Func" and "rr_Base", respectively.  This "autodelete" function will
 * be called with the base in register A6 and the node in A0.
 }

Type

    RexxRsrc = record
	rr_Node		: Node;
	rr_Func		: Short;	{ "auto-delete" offset          }
	rr_Base		: Address;	{ "auto-delete" base            }
	rr_Size		: Integer;	{ total size of node            }
	rr_Arg1		: Integer;	{ available ...                 }
	rr_Arg2		: Integer;	{ available ...                 }
    end;				{ size: 32 bytes                }
    RexxRsrcPtr = ^RexxRsrc;

Const

{ Resource node types                                                  }

    RRT_ANY		= 0;		{ any node type ...             }
    RRT_LIB		= 1;		{ a function library            }
    RRT_PORT		= 2;		{ a public port                 }
    RRT_FILE		= 3;		{ a file IoBuff                 }
    RRT_HOST		= 4;		{ a function host               }
    RRT_CLIP		= 5;		{ a Clip List node              }

{ The RexxTask structure holds the fields used by REXX to communicate with
 * external processes, including the client task.  It includes the global
 * data structure (and the base environment).  The structure is passed to
 * the newly-created task in its "wake-up" message.
 }

    GLOBALSZ		= 200;		{ total size of GlobalData      }

Type

    RexxTask = record
	rt_Global	: Array [0..GLOBALSZ-1] of Byte;
					{ global data structure         }
	rt_MsgPort	: MsgPort;	{ global message port           }
	rt_Flags	: Byte;		{ task flag bits                }
	rt_SigBit	: Byte;		{ signal bit                    }

	rt_ClientID	: Address;	{ the client's task ID          }
	rt_MsgPkt	: Address;	{ the packet being processed    }
	rt_TaskID	: Address;	{ our task ID                   }
	rt_RexxPort	: Address;	{ the REXX public port          }

	rt_ErrTrap	: Address;	{ Error trap address            }
	rt_StackPtr	: Address;	{ stack pointer for traps       }

	rt_Header1	: List;		{ Environment list              }
	rt_Header2	: List;		{ Memory freelist               }
	rt_Header3	: List;		{ Memory allocation list        }
	rt_Header4	: List;		{ Files list                    }
	rt_Header5	: List;		{ Message Ports List            }
    end;
    RexxTaskPtr = ^RexxTask;

Const

{ Definitions for RexxTask flag bits                                   }

    RTFB_TRACE		= 0;		{ external trace flag           }
    RTFB_HALT		= 1;		{ external halt flag            }
    RTFB_SUSP		= 2;		{ suspend task?                 }
    RTFB_TCUSE		= 3;		{ trace console in use?         }
    RTFB_WAIT		= 6;		{ waiting for reply?            }
    RTFB_CLOSE		= 7;		{ task completed?               }

{ Definitions for memory allocation constants                          }

    MEMQUANT		= 16;		{ quantum of memory space       }
    MEMMASK		= $FFFFFFF0;	{ mask for rounding the size    }

    MEMQUICK		= 1;		{ EXEC flags: MEMF_PUBLIC       }
    MEMCLEAR		= $00010000;	{ EXEC flags: MEMF_CLEAR        }

{ The SrcNode is a temporary structure used to hold values destined for
 * a segment array.  It is also used to maintain the memory freelist.
}

Type

    SrcNode = record
	sn_Succ		: ^SrcNode;	{ next node                     }
	sn_Pred		: ^SrcNode;	{ previous node                 }
	sn_Ptr		: Address;	{ pointer value                 }
	sn_Size		: Integer;	{ size of object                }
    end;				{ size: 16 bytes                }
    SrcNodePtr = ^SrcNode;

VAR
    RexxSysBase : Address;


Function  AddClipNode(VAR lst: List; name: String; length: Integer; 
			value: Address): RexxRsrcPtr;
    External;

Function  AddRsrcNode(Lst : List; Name : String; Len : Integer): RexxRsrcPtr;
    External;

Procedure ClearMem(Add : Address; Len : Integer);
    External;

Procedure ClearRexxMsg(msg : RexxMsgPtr; Count : Integer);
    External;

Function  CreateArgstring(S : String; len : Integer): Address;
    External;

Function  CreateRexxMsg(rp : MsgPortPtr; ex, host : String) : RexxMsgPtr;
    External;

Function  CurrentEnv(rxptr: RexxTaskPtr): Address;
    External;

Procedure DeleteArgstring(As : Address);
    External;

Procedure DeleteRexxMsg(pkt: RexxMsgPtr);
    External;

Function  FillRexxMsg(mp: RexxMsgPtr; c, m : Integer): Boolean;
    External;

Function  FindRsrcNode(list: ListPtr; name: String; tp : Integer): RexxRsrcPtr;
    External;

Procedure FreePort(p : MsgPortPtr);
    External;

Procedure FreeSpace(eptr, block: Address; len : Integer);
    External;

Function  GetSpace(eptr: Address; len: Integer): Address;
    External;

Procedure InitList(list: ListPtr);
    External;

Function  InitPort(p : MsgPortPtr; name: String): Integer;
    External;

Function  IsRexxMsg(mp: RexxMsgPtr): Boolean;
    External;

Procedure RemClipNode(nd: RexxRsrcPtr);
    External;

Procedure RemRsrcList(list: RexxRsrcPtr);
    External;

Procedure RemRsrcNode(node: RexxRsrcPtr);
    External;

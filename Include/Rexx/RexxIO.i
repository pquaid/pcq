{ === rexx/rexxio.h ====================================================
 *
 * Copyright (c) 1986, 1987 by William S. Hawes.  All Rights Reserved.
 *
 * ======================================================================
 * Header file for ARexx Input/Output related structures
}

{$I "Include:Rexx/Storage.i"}

Const

    RXBUFFSZ	= 204;			{ buffer length                 }

{
 * The IoBuff is a resource node used to maintain the File List.  Nodes
 * are allocated and linked into the list whenever a file is opened.
}

Type

    IoBuff = record
	iobNode		: RexxRsrc;	{ structure for files/strings   }
	iobRpt		: Address;	{ read/write pointer            }
	iobRct		: Integer;	{ character count               }
	iobDFH		: Integer;	{ DOS filehandle                }
	iobLock		: Integer;	{ DOS lock                      }
	iobBct		: Integer;	{ buffer length                 }
	iobArea		: Array [0..RXBUFFSZ-1] of Byte;
					{ buffer area                   }
    end;				{ size: 256 bytes               }
    IoBuffPtr = ^IoBuff;

Const

{ Access mode definitions                                              }

    RXIO_EXIST		= -1;		{ an external filehandle        }
    RXIO_STRF		= 0;		{ a "string file"               }
    RXIO_READ		= 1;		{ read-only access              }
    RXIO_WRITE		= 2;		{ write mode                    }
    RXIO_APPEND		= 3;		{ append mode (existing file)   }

{
 * Offset anchors for SeekF()
}

    RXIO_BEGIN		= -1;		{ relative to start             }
    RXIO_CURR		= 0;		{ relative to current position  }
    RXIO_END		= 1;		{ relative to end               }

{
 * A message port structure, maintained as a resource node.  The ReplyList
 * holds packets that have been received but haven't been replied.
}

Type

    RexxMsgPort = record
	rmp_Node	: RexxRsrc;	{ linkage node                  }
	rmp_Port	: MsgPort;	{ the message port              }
	rmp_ReplyList	: List;		{ messages awaiting reply       }
    end;
    RexxMsgPortPtr = ^RexxMsgPort;

Const

{
 * DOS Device types
}

    DT_DEV	= 0;			{ a device                      }
    DT_DIR	= 1;			{ an ASSIGNed directory         }
    DT_VOL	= 2;			{ a volume                      }

{
 * Private DOS packet types
}

    ACTION_STACK	= 2002;		{ stack a line                  }
    ACTION_QUEUE	= 2003;		{ queue a line                  }

Function  CloseF(iob: IoBuffPtr): Boolean;
    External;

Function  CreateDOSPkt : Address;
    External;

Procedure ClosePublicPort(nod : RexxMsgPortPtr);
    External;

Procedure DeleteDOSPkt(msg : Address);
    External;

Function  OpenPublicPort(list: ListPtr; name: String): RexxMsgPortPtr;
    External;

Function  RexxDOSRead(filehandle : Address;
			buffer : Address; len : Integer): Integer;
    External;

Function  RexxDOSWrite(filehandle : Address;
			buffer : Address; len : Integer): Integer;
    External;

Function  ExistF(filename : String): Boolean;
    External;

Function  FindDevice(name: String; tp: Integer): Address;
    External;

Function  OpenF(list: ListPtr; name: String; mode: Integer; log : String) : IOBuffPtr;
    External;

Function  QueueF(iob: IoBuffPtr; buf : String; len : Integer): Integer;
    External;

Function  ReadF(iob: IoBuffPtr; buf : String; len : Integer): Integer;
    External;

Function  ReadStr(iob: IoBuffPtr; buf : Address; len: Integer;
		var ptr : Address) : Integer;
    External;

Function  SeekF(iob: IoBuffPtr; off : Integer; anchor: Integer): Integer;
    External;

Function  StackF(iob: IoBuffPtr; buf : String; len : Integer): Integer;
    External;

Function  WriteF(iob: IoBuffPtr; buf: Address; len: Integer): Integer;
    External;



{
 ************************************************************************
 *									*
 * 5/3/89	ARPbase.h	by MKSoft from ARPbase.i by SDB		*
 *									*
 ************************************************************************
 *									*
 *	AmigaDOS Resource Project -- Library Include File		*
 *				     for PCQ Pascal			*
 *									*
 ************************************************************************
 *									*
 *	Copyright (c) 1987/1988/1989 by Scott Ballantyne		*
 *									*
 *	The arp.library, and related code and files may be freely used	*
 *	by supporters of ARP.  Modules in the arp.library may not be	*
 *	extracted for use in independent code, but you are welcome to	*
 *	provide the arp.library with your work and call on it freely.	*
 *									*
 *	You are equally welcome to add new functions, improve the ones	*
 *	within, or suggest additions.					*
 *									*
 *	BCPL programs are not welcome to call on the arp.library.	*
 *	The welcome mat is out to all others.				*
 *									*
 ************************************************************************
 *									*
 * N O T E !  You MUST! have IoErr() defined as LONG to use LastTracker *
 *	      If your compiler has other defines for this, you may wish *
 *	      to remove the prototype for IoErr() from this file.	*
 *									*
 ************************************************************************
}

{
 ************************************************************************
 *	First we need to include the Amiga Standard Include files...	*
 ************************************************************************
}

{$I "Include:Exec/Lists.i"}
{$I "Include:Exec/Alerts.i"}
{$I "Include:Exec/Libraries.i"}
{$I "Include:Exec/Semaphores.i"}
{$I "Include:Exec/Ports.i"}
{$I "Include:Libraries/DOS.i"}
{$I "Include:Libraries/DOSExtens.i"}


{
 ************************************************************************
 *	Standard definitions for arp library information		*
 ************************************************************************
}

Const
    ArpName		= "arp.library";	{ Name of library...}
    ArpVersion		= 39;			{ Current version... }


{
 ************************************************************************
 *	Resident Program Support					*
 ************************************************************************
 * This is the kind of node allocated for you when you AddResidentPrg()	*
 * a code segment.  They are stored as a single linked list with the	*
 * root in ArpBase.  If you absolutely *must* wander through this list	*
 * instead of using the supplied functions, then you must first obtain	*
 * the semaphore which protects this list, and then release it		*
 * afterwards.  Do not use Forbid() and Permit() to gain exclusive	*
 * access!  Note that the supplied functions handle this locking	*
 * protocol for you.							*
 ************************************************************************
}

Type
    ResidentProgramNode	= record
	rpn_Next	: ^ResidentProgramNode;	{ next or NULL			}
	rpn_Usage	: Integer;		{ Number of current users	}
	rpn_AccessCnt	: Short;		{ Total times used...		}
	rpn_CheckSum	: Integer;		{ Checksum of code		}
	rpn_Segment	: BPTR;			{ Actual segment		}
	rpn_Flags	: Short;		{ See definitions below...	}
	rpn_Name	: Array [0..1] of Char;	{ Allocated as needed		}
    end;
    ResidentProgramNodePtr = ^ResidentProgramNode;


{
 ************************************************************************
 *	The current ARP library node...					*
 ************************************************************************
}

    ArpBase = record
	LibNode		: Library;	{ Standard library node		}
	DosRootNode	: Address;	{ Copy of dl_Root			}
	Flags		: Byte;		{ See bitdefs below			}
	ESCChar		: Byte; 	{ Character to be used for escaping	}
	ArpReserved1	: Integer;	{ ArpLib's use only!!			}
	EnvBase		: LibraryPtr; 	{ Dummy library for MANX compatibility}
	DosBase		: LibraryPtr; 	{ Cached DosBase			}
	GfxBase		: LibraryPtr; 	{ Cached GfxBase			}
	IntuiBase	: LibraryPtr;	{ Cached IntuitionBase		}
	ResLists	: MinList;	{ Resource trackers			}
	ResidentPrgList	: ResidentProgramNodePtr;
					{ Resident Programs.			}
	ResPrgProtection : SignalSemaphore;
					{ protection for above		}
	SegList		: BPTR;		{ Pointer to loaded libcode (a BPTR).	}
    end;
    ArpBasePtr = ^AprBase;


{
 ************************************************************************
 *	The following is here *ONLY* for information and for		*
 *	compatibility with MANX.  DO NOT use in new code!		*
 ************************************************************************
}

    EnvBase = record
	LibNode		: Library;	{ Standard library node for linkage	}
	EnvSpace	: Address;	{ Access only when Forbidden!		}
	EnvSize		: Integer;	{ Total allocated mem for EnvSpace	}
	ArpBase		: ArpBasePtr;	{ Added in V32 for Resource Tracking	}
    end;
    EnvBasePtr = ^EnvBase;


{
 ************************************************************************
 *	These are used in release 33.4 but not by the library code.	*
 *	Instead, individual programs check for these flags.		*
 ************************************************************************
}

Const
    ARPB_WILD_WORLD	= 0;		{ Mixed BCPL/Normal wildcards.	}
    ARPB_WILD_BCPL	= 1;		{ Pure BCPL wildcards.		}

    ARPF_WILD_WORLD	= 1 shl ARPB_WILD_WORLD;
    ARPF_WILD_BCPL	= 1 shl ARPB_WILD_BCPL;

{
 ************************************************************************
 * The alert object is what you use if you really must return an alert	*
 * to the user. You would normally OR this with another alert number	*
 * from the alerts.h file. Generally, should be NON deadend alerts.	*
 *									*
 * For example, if you can't open ArpLibrary:				*
 *	Alert( (AG_OpenLib|AO_ArpLib), 0L);				*
 ************************************************************************
}

    AO_ArpLib		= $00008036;	{ Alert object }

{
 ************************************************************************
 *	Alerts that arp.library may return...				*
 ************************************************************************
}

    AN_ArpLib		= $03600000;	{ Alert number				}
    AN_ArpNoMem		= $03610000;	{ No more memory			}
    AN_ArpInputMem	= $03610002;	{ No memory for input buffer		}
    AN_ArpNoMakeEnv	= $83610003;	{ No memory to make EnvLib		}

    AN_ArpNoDOS		= $83630001;	{ Can't open dos.library		}
    AN_ArpNoGfx		= $83630002;	{ Can't open graphics.library		}
    AN_ArpNoIntuit	= $83630003;	{ Can't open intuition			}
    AN_BadPackBlues	= $83640000;	{ Bad packet returned to SendPacket()	}
    AN_Zombie		= $83600003;	{ Zombie roaming around system		}

    AN_ArpScattered	= $83600002;	{ Scatter loading not allowed for arp	}


{
 ************************************************************************
 *	Return codes you can get from calling ARP Assign()...		*
 ************************************************************************
}
    ASSIGN_OK		= 0;	{ Everything is cool and groovey			}
    ASSIGN_NODEV	= 1;	{ "Physical" is not valid for assignment		}
    ASSIGN_FATAL	= 2;	{ Something really icky happened			}
    ASSIGN_CANCEL	= 3;	{ Tried to cancel something but it won't cancel	}

{
 ************************************************************************
 *	Size of buffer you need if you are going to call ReadLine()	*
 ************************************************************************
}

    MaxInputBuf		= 256;

{
 ************************************************************************
 *	The ARP file requester data structure...			*
 ************************************************************************
}

Type
    FileRequester = record
	fr_Hail		: String;	{ Hailing text			}
	fr_File		: Address;	{ Filename array (FCHARS + 1)	}
	fr_Dir		: Address;	{ Directory array (DSIZE + 1)	}
	fr_Window	: Address;	{ Window requesting or Nil	}
	fr_FuncFlags	: Byte;		{ Set bitdef's below		}
	fr_Flags2	: Byte;		{ New flags...			}
	fr_Function	: Address;	{ Your function, see bitdef's	}
	fr_LeftEdge	: Short;	{ To be used later...		}
	fr_TopEdge	: Short;
    end;
    FileRequesterPtr = ^FileRequester;

{
 ************************************************************************
 * The following are the defines for fr_FuncFlags.  These bits tell	*
 * FileRequest() what your fr_UserFunc is expecting, and what		*
 * FileRequest() should call it for.					*
 *									*
 * You are called like so:						*
 * fr_Function(Object : Address; Mask : Integer)			*
 *									*
 * The Mask is a copy of the flag value that caused FileRequest() to	*
 * call your function. You can use this to determine what action you	*
 * need to perform, and exactly what Object is, so you know what to do	*
 * and what to return.							*
 ************************************************************************
}

Const
    FRB_DoWildFunc	= 7;	{ Call me with a FIB and a name, ZERO return accepts.	}
    FRB_DoMsgFunc	= 6;	{ You get all IDCMP messages not for FileRequest()	}
    FRB_DoColor		= 5;	{ Set this bit for that new and different look		}
    FRB_NewIDCMP	= 4;	{ Force a new IDCMP (only if fr_Window != NULL)		}
    FRB_NewWindFunc	= 3;	{ You get to modify the newwindow structure.		}
    FRB_AddGadFunc	= 2;	{ You get to add gadgets.				}
    FRB_GEventFunc	= 1;	{ Function to call if one of your gadgets is selected.	}
    FRB_ListFunc	= 0;	{ Not implemented yet.					}

    FRF_DoWildFunc	= 1 shl FRB_DoWildFunc;
    FRF_DoMsgFunc	= 1 shl FRB_DoMsgFunc;
    FRF_DoColor		= 1 shl FRB_DoColor;
    FRF_NewIDCMP	= 1 shl FRB_NewIDCMP;
    FRF_NewWindFunc	= 1 shl FRB_NewWindFunc;
    FRF_AddGadFunc	= 1 shl FRB_AddGadFunc;
    FRF_GEventFunc	= 1 shl FRB_GEventFunc;
    FRF_ListFunc	= 1 shl FRB_ListFunc;

{
 ************************************************************************
 * The FR2B_ bits are for fr_Flags2 in the file requester structure	*
 ************************************************************************
}

    FR2B_LongPath	= 0;	{ Specify the fr_Dir buffer is 256 bytes long }
    FR2F_LongPath	= 1 shl FR2B_LongPath;

{
 ************************************************************************
 *	The sizes of the different buffers...				*
 ************************************************************************
}

    FCHARS		= 32;	{ Filename size					}
    DSIZE		= 33;	{ Directory name size if not FR2B_LongPath	}

    LONG_DSIZE		= 254;	{ If FR2B_LongPath is set, use LONG_DSIZE	}
    LONG_FSIZE		= 126;	{ For compatibility with ARPbase.i		}

    FR_FIRST_GADGET	= $7680; { User gadgetID's must be less than this value	}

{
 ************************************************************************
 * Structure used by the pattern matching functions, no need to obtain,	*
 * diddle or allocate this yourself.					*
 *									*
 * Note:  If you did, you will now break as it has changed...		*
 ************************************************************************
}

Type
    AChain = record
	an_Child	: ^AChain;
	an_Parent	: ^AChain;
	an_Lock		: FileLock;
	an_Info		: FileInfoBlockPtr;
	an_Flags	: Byte;
	an_String	: Array [0..1] of Char;	{ Just as is .i file	}
    end;					{ ??? Don't use this!	}
    AChainPtr = ^AChain;

Const
    DDB_PatternBit	= 0;
    DDB_ExaminedBit	= 1;
    DDB_Completed	= 2;
    DDB_AllBit		= 3;

    DDF_PatternBit	= 1 shl DDB_PatternBit;
    DDF_ExaminedBit	= 1 shl DDB_ExaminedBit;
    DDF_Completed	= 1 shl DDB_Completed;
    DDF_AllBit		= 1 shl DDB_AllBit;

{
 ************************************************************************
 * Structure expected by FindFirst()/FindNext()				*
 *									*
 * You need to allocate this structure and initialize it as follows:	*
 *									*
 * Set ap_BreakBits to the signal bits (CDEF) that you want to take a	*
 * break on, or 0, if you don't want to convenience the user.		*
 *									*
 * if you want to have the FULL PATH NAME of the files you found,	*
 * allocate a buffer at the END of this structure, and put the size of	*
 * it into ap_StrLen.  If you don't want the full path name, make sure	*
 * you set ap_StrLen to zero.  In this case, the name of the file, and	*
 * stats are available in the ap_Info, as per usual.			*
 *									*
 * Then call FindFirst() and then afterwards, FindNext() with this	*
 * structure.  You should check the return value each time (see below)	*
 * and take the appropriate action, ultimately calling			*
 * FreeAnchorChain() when there are no more files and you are done.	*
 * You can tell when you are done by checking for the normal AmigaDOS	*
 * return code ERROR_NO_MORE_ENTRIES.					*
 *									*
 * You will also have to check the DirEntryType variable in the ap_Info	*
 * structure to determine what exactly you have received.		*
 ************************************************************************
}

Type
    AnchorPath = record
	ap_Base		: AChainPtr;	{ Pointer to first anchor			}
	ap_Last		: AChainPtr;	{ Pointer to last anchor			}
	ap_BreakBits	: Integer;	{ Bits to break on				}
	ap_FoundBreak	: Integer;	{ Bits we broke on. Also returns ERROR_BREAK	}
	ap_Flags	: Byte;		{ New use for the extra word...		}
	ap_Reserved	: Byte;		{ To fill it out...				}
	ap_StrLen	: Short;	{ This is what used to be ap_Length		}
	ap_Info		: FileInfoBlockPtr;
	ap_Buf		: Array [0..1] of Char;	{ Allocate a buffer here, if desired		}
    end;
    AnchorPathPtr = ^AnchorPath;

{
 ************************************************************************
 *	Bit definitions for the new ap_Flags...				*
 ************************************************************************
}

Const
    APB_DoWild		= 0;	{ User option ALL				}
    APB_ItsWild		= 1;	{ Set by FindFirst, used by FindNext		}
    APB_DoDir		= 2;	{ Bit is SET if a DIR node should be entered	}
				{ Application can RESET this bit to AVOID	}
				{ entering a dir.				}
    APB_DidDir		= 3;	{ Bit is set for an "expired" dir node		}
    APB_NoMemErr	= 4;	{ Set if there was not enough memory		}
    APB_DoDot		= 5;	{ If set, '.' (DOT) will convert to CurrentDir	}

    APF_DoWild		= 1 shl APB_DoWild;
    APF_ItsWild		= 1 shl APB_ItsWild;
    APF_DoDir		= 1 shl APB_DoDir;
    APF_DidDir		= 1 shl APB_DidDir;
    APF_NoMemErr	= 1 shl APB_NoMemErr;
    APF_DoDot		= 1 shl APB_DoDot;


{
 ************************************************************************
 * This structure takes a pointer, and returns FALSE if wildcard was	*
 * not found by FindFirst()						*
 ************************************************************************
}

    Function IsWild(Ptr : Address) : Boolean;
	External;

{
 ************************************************************************
 * Constants used by wildcard routines					*
 *									*
 * These are the pre-parsed tokens referred to by pattern match.  It	*
 * is not necessary for you to do anything about these, FindFirst()	*
 * FindNext() handle all these for you.					*
 ************************************************************************
}
Const
    P_ANY		= $80;	{ Token for '*' | '#?'	}
    P_SINGLE		= $81;	{ Token for '?'	}

{
 ************************************************************************
 * No need to muck with these as they may change...			*
 ************************************************************************
}

    P_ORSTART		= $82;	{ Token for '('	}
    P_ORNEXT		= $83;	{ Token for '|'	}
    P_OREND		= $84;	{ Token for ')'	}
    P_NOT		= $85;	{ Token for '~'	}
    P_NOTCLASS		= $87;	{ Token for '^'	}
    P_CLASS		= $88;	{ Token for '[]'	}
    P_REPBEG		= $89;	{ Token for '['	}
    P_REPEND		= $8A;	{ Token for ']'	}

{
 ************************************************************************
 * Structure used by AddDANode(), AddDADevs(), FreeDAList().		*
 *									*
 * This structure is used to create lists of names, which normally	*
 * are devices, assigns, volumes, files, or directories.		*
 ************************************************************************
}

Type
    DirectoryEntry = record
	de_Next		: ^DirectoryEntry;
					{ Next in list				}
	de_Type		: Byte;		{ DLX_mumble				}
	de_Flags	: Byte;		{ For future expansion, DO NOT USE!	}
	de_Name		: Array [0..1] of Char;
					{ The name of the thing found		}
    end;
    DirectoryEntryPtr = ^DirectoryEntry;

{
 ************************************************************************
 * Defines you use to get a list of the devices you want to look at.	*
 * For example, to get a list of all directories and volumes, do:	*
 *									*
 *	AddDADevs( mydalist, (DLF_DIRS or DLF_VOLUMES) )		*
 *									*
 * After this, you can examine the de_type field of the elements added	*
 * to your list (if any) to discover specifics about the objects added.	*
 *									*
 * Note that if you want only devices which are also disks, you must	*
 * (DLF_DEVICES or DLF_DISKONLY).					*
 ************************************************************************
}

Const
    DLB_DEVICES		= 0;	{ Return devices				}
    DLB_DISKONLY	= 1;	{ Modifier for above: Return disk devices only	}
    DLB_VOLUMES		= 2;	{ Return volumes only				}
    DLB_DIRS		= 3;	{ Return assigned devices only			}

    DLF_DEVICES		= 1 shl DLB_DEVICES;
    DLF_DISKONLY	= 1 shl DLB_DISKONLY;
    DLF_VOLUMES		= 1 shl DLB_VOLUMES;
    DLF_DIRS		= 1 shl DLB_DIRS;

{
 ************************************************************************
 * Legal de_Type values, check for these after a call to AddDADevs(),	*
 * or use on your own as the ID values in AddDANode().			*
 ************************************************************************
}

    DLX_FILE		= 0;	{ AddDADevs() can't determine this	}
    DLX_DIR		= 8;	{ AddDADevs() can't determine this	}
    DLX_DEVICE		= 16;	{ It's a resident device		}

    DLX_VOLUME		= 24;	{ Device is a volume			}
    DLX_UNMOUNTED	= 32;	{ Device is not resident		}

    DLX_ASSIGN		= 40;	{ Device is a logical assignment	}

{
 ************************************************************************
 *	This macro is to check for an error return from the Atol()	*
 *	routine.  If Errno is ERRBADINT, then there was an error...	*
 *	This was done to try to remain as close to source compatible	*
 *	as possible with the older (rel 1.1) ARPbase.h			*
 ************************************************************************
}

    ERRBADINT		= 1;

    Function Errno : Integer;
	External;

{
 ************************************************************************
 *	Resource Tracking stuff...					*
 ************************************************************************
 *									*
 * There are a few things in arp.library that are only directly		*
 * acessable from assembler.  The glue routines provided by us for	*
 * all 'C' compilers use the following conventions to make these	*
 * available to C programs.  The glue for other language's should use	*
 * as similar a mechanism as possible, so that no matter what language	*
 * or compiler we speak, when talk about arp, we will know what the	*
 * other guy is saying.							*
 *									*
 * Here are the cases:							*
 *									*
 * Tracker calls...							*
 *		These calls return the Tracker pointer as a secondary	*
 *		result in the register A1.  For C, there is no clean	*
 *		way to return more than one result so the tracker	*
 *		pointer is returned in IoErr().  For ease of use,	*
 *		there is a define that typecasts IoErr() to the correct	*
 *		pointer type.  This is called LastTracker and should	*
 *		be source compatible with the earlier method of storing	*
 *		the secondary result.					*
 *									*
 * GetTracker() -							*
 *		Syntax is a bit different for C than the assembly call	*
 *		The C syntax is GetTracker(ID).  The binding routines	*
 *		will store the ID into the tracker on return.  Also,	*
 *		in an effort to remain consistant, the tracker will	*
 *		also be stored in LastTracker.				*
 *									*
 * In cases where you have allocated a tracker before you have obtained	*
 * a resource (usually the most efficient method), and the resource has	*
 * not been obtained, you will need to clear the tracker id.  The macro	*
 * CLEAR_ID() has been provided for that purpose.  It expects a pointer	*
 * to a DefaultTracker sort of struct.					*
 ************************************************************************
}

    Procedure CLEAR_ID(T : Address);
	External;

{
 ************************************************************************
 * You MUST prototype IoErr() to prevent the possible error in defining	*
 * IoErr() and thus causing LastTracker to give you trash...		*
 *									*
 * N O T E !  You MUST! have IoErr() defined as LONG to use LastTracker *
 *	      If your compiler has other defines for this, you may wish *
 *	      to remove the prototype for IoErr().			*
 ************************************************************************
}

    Function LastTracker : Address;
	External;

{
 ************************************************************************
 * The rl_FirstItem list (ResList) is a list of TrackedResource (below)	*
 * It is very important that nothing in this list depend on the task	*
 * existing at resource freeing time (i.e., RemTask(0L) type stuff,	*
 * DeletePort() and the rest).						*
 *									*
 * The tracking functions return a struct Tracker *Tracker to you, this	*
 * is a pointer to whatever follows the tr_ID variable.			*
 * The default case is reflected below, and you get it if you call	*
 * GetTracker() ( see DefaultTracker below).				*
 *									*
 * NOTE: The two user variables mentioned in an earlier version don't	*
 * exist, and never did. Sorry about that (SDB).			*
 *									*
 * However, you can still use ArpAlloc() to allocate your own tracking	*
 * nodes and they can be any size or shape you like, as long as the	*
 * base structure is preserved. They will be freed automagically just	*
 * like the default trackers.						*
 ************************************************************************
}

Type
    TrackedResource = record
	tr_Node		: MinNode;	{ Double linked pointer		}
	tr_Flags	: Byte;		{ Don't touch				}
	tr_Lock		: Byte;		{ Don't touch, for Get/FreeAccess()	}
	tr_ID		: Short;	{ Item's ID				}

{
 ************************************************************************
 * The struct DefaultTracker *Tracker portion of the structure.		*
 * The stuff below this point can conceivably vary, depending		*
 * on user needs, etc.  This reflects the default.			*
 ************************************************************************
}

	tr_Resource	: Address;	{ Whatever				}
	tg_Verify	: Integer;	{ For use during TRAK_GENERIC		}
    end;
    TrackedResourcePtr = ^TrackedResource;

{
 ************************************************************************
 * You get a pointer to a struct of the following type when you call	*
 * GetTracker().  You can change this, and use ArpAlloc() instead of	*
 * GetTracker() to do tracking. Of course, you have to take a wee bit	*
 * more responsibility if you do, as well as if you use TRAK_GENERIC	*
 * stuff.								*
 *									*
 * TRAK_GENERIC folks need to set up a task function to be called when	*
 * an item is freed.  Some care is required to set this up properly.	*
 *									*
 * Some special cases are indicated by the unions below, for		*
 * TRAK_WINDOW, if you have more than one window opened, and don't	*
 * want the IDCMP closed particularly, you need to set a ptr to the	*
 * other window in dt_Window2.  See CloseWindowSafely() for more info.	*
 * If only one window, set this to NULL.				*
 ************************************************************************
}

    DefaultTracker = record
	dt_Resource	: Address;	{ Whatever				}
	tg_Verify	: Integer;	{ For use during TRAK_GENERIC		}
    end;
    DefaultTrackerPtr = ^DefaultTracker;

{
 ************************************************************************
 *	Items the tracker knows what to do about			*
 ************************************************************************
}

Const
    TRAK_AAMEM		= 0;	{ Default (ArpAlloc) element		}
    TRAK_LOCK		= 1;	{ File lock				}
    TRAK_FILE		= 2;	{ Opened file				}
    TRAK_WINDOW		= 3;	{ Window -- see docs			}
    TRAK_SCREEN		= 4;	{ Screen				}
    TRAK_LIBRARY	= 5;	{ Opened library			}
    TRAK_DAMEM		= 6;	{ Pointer to DosAllocMem block		}
    TRAK_MEMNODE	= 7;	{ AllocEntry() node			}
    TRAK_SEGLIST	= 8;	{ Program segment			}
    TRAK_RESLIST	= 9;	{ ARP (nested) ResList			}
    TRAK_MEM		= 10;	{ Memory ptr/length			}
    TRAK_GENERIC	= 11;	{ Generic Element, your choice		}
    TRAK_DALIST		= 12;	{ DAlist ( aka file request )		}
    TRAK_ANCHOR		= 13;	{ Anchor chain (pattern matching)	}
    TRAK_FREQ		= 14;	{ FileRequest struct			}
    TRAK_FONT		= 15;	{ GfxBase CloseFont()			}
    TRAK_MAX		= 15;	{ Poof, anything higher is tossed	}

    TRB_UNLINK		= 7;	{ Free node bit			}
    TRB_RELOC		= 6;	{ This may be relocated (not used yet)	}
    TRB_MOVED		= 5;	{ Item moved				}

    TRF_UNLINK		= 1 shl TRB_UNLINK;
    TRF_RELOC		= 1 shl TRB_RELOC;
    TRF_MOVED		= 1 shl TRB_MOVED;

{
 ************************************************************************
 * Note: ResList MUST be a DosAllocMem'ed list!, this is done for	*
 * you when you call CreateTaskResList(), typically, you won't need	*
 * to access/allocate this structure.					*
 ************************************************************************
}

Type
    ResList = record
	rl_Node		: MinNode;	{ Used by arplib to link reslists	}
	rl_TaskID	: Address;	{ Owner of this list			}
	rl_FirstItem	: MinList;	{ List of Tracked Resources		}
	rl_Link		: ^ResList;	{ SyncRun's use - hide list here	}
    end;
    ResListPtr = ^ResList;

{
 ************************************************************************
 *	Returns from CompareLock()					*
 ************************************************************************
}

Const
    LCK_EQUAL		= 0;	{ The two locks refer to the same object	}
    LCK_VOLUME		= 1;	{ Locks are on the same volume			}
    LCK_DIFVOL1		= 2;	{ Locks are on different volumes		}
    LCK_DIFVOL2		= 3;	{ Locks are on different volumes		}

{
 ************************************************************************
 *	ASyncRun() stuff...						*
 ************************************************************************
 * Message sent back on your request by an exiting process.		*
 * You request this by putting the address of your message in		*
 * pcb_LastGasp, and initializing the ReplyPort variable of your	*
 * ZombieMsg to the port you wish the message posted to.		*
 ************************************************************************
}

Type
    ZombieMsg = record
	zm_ExecMessage	: Message;
	zm_TaskNum	: Integer;	{ Task ID			}
	zm_ReturnCode	: Integer;	{ Process's return code	}
	zm_Result2	: Integer;	{ System return code		}
	zm_ExitTime	: DateStamp;	{ Date stamp at time of exit	}
	zm_UserInfo	: Integer;	{ For whatever you wish	}
    end;
    ZombieMsgPtr = ^ZombieMsg;

{
 ************************************************************************
 * Structure required by ASyncRun() -- see docs for more info.		*
 ************************************************************************
}

    ProcessControlBlock	= record
	pcb_StackSize	: Integer;	{ Stacksize for new process			}
	pcb_Pri		: Byte;		{ Priority of new task				}
	pcb_Control	: Byte;		{ Control bits, see defines below		}
	pcb_TrapCode	: Address;	{ Optional Trap Code				}
	pcb_Input	: BPTR;
	pcb_Output	: BPTR;		{ Optional stdin, stdout			}
	pcb_ConName	: String;	{ CON: filename					}
	pcb_LoadedCode	: Address;	{ If not null, will not load/unload code	}
	pcb_LastGasp	: ZombieMsgPtr;	{ ReplyMsg() to be filled in by exit		}
	pcb_WBProcess	: MsgPortPtr;	{ Valid only when PRB_NOCLI			}
    end;
    ProcessControlBlockPtr = ^ProcessControlBlock;

{
 ************************************************************************
 * Formerly needed to pass NULLCMD to a child.  No longer needed.	*
 * It is being kept here for compatibility only...			*
 ************************************************************************
}

Const
    NOCMD	= "\n";

{
 ************************************************************************
 * The following control bits determine what ASyncRun() does on		*
 * Abnormal Exits and on background process termination.		*
 ************************************************************************
}

    PRB_SAVEIO		= 0;	{ Don't free/check file handles on exit	}
    PRB_CLOSESPLAT	= 1;	{ Close Splat file, must request explicitly	}
    PRB_NOCLI		= 2;	{ Don't create a CLI process			}
{	PRB_INTERACTIVE	= 3;	   This is now obsolete...			}
    PRB_CODE		= 4;	{ Dangerous yet enticing			}
    PRB_STDIO		= 5;	{ Do the stdio thing, splat = CON:Filename 	}

    PRF_SAVEIO		= 1 shl PRB_SAVEIO;
    PRF_CLOSESPLAT	= 1 shl PRB_CLOSESPLAT;
    PRF_NOCLI		= 1 shl PRB_NOCLI;
    PRF_CODE		= 1 shl PRB_CODE;
    PRF_STDIO		= 1 shl PRB_STDIO;

{
 ************************************************************************
 *	Error returns from SyncRun() and ASyncRun()			*
 ************************************************************************
}

    PR_NOFILE		= -1;	{ Could not LoadSeg() the file			}
    PR_NOMEM		= -2;	{ No memory for something			}
{	PR_NOCLI	= -3;	   This is now obsolete				}
    PR_NOSLOT		= -4;	{ No room in TaskArray				}
    PR_NOINPUT		= -5;	{ Could not open input file			}
    PR_NOOUTPUT		= -6;	{ Could not get output file			}
{	PR_NOLOCK	= -7;	   This is now obsolete				}
{	PR_ARGERR	= -8;	   This is now obsolete				}
{	PR_NOBCPL	= -9;	   This is now obsolete				}
{	PR_BADLIB	= -10;	   This is now obsolete				}
    PR_NOSTDIO		= -11;	{ Couldn't get stdio handles			}

{
 ************************************************************************
 *	Added V35 of arp.library					*
 ************************************************************************
}

    PR_WANTSMESSAGE	= -12;	{ Child wants you to report IoErr() to user	}
				{ for SyncRun() only...			}
    PR_NOSHELLPROC	= -13;	{ Can't create a shell/cli process		}
    PR_NOEXEC		= -14;	{ 'E' bit is clear				}
    PR_SCRIPT		= -15;	{ S and E are set, IoErr() contains directory	}

{
 ************************************************************************
 * Version 35 ASyncRun() allows you to create an independent		*
 * interactive or background Shell/CLI. You need this variant of the	*
 * pcb structure to do it, and you also have new values for nsh_Control,*
 * see below.								*
 *									*
 * Syntax for Interactive shell is:					*
 *									*
 * rc=ASyncRun("Optional Window Name","Optional From File",&NewShell);	*
 *									*
 * Syntax for a background shell is:					*
 *									*
 * rc=ASyncRun("Command line",0L,&NewShell);				*
 *									*
 * Same syntax for an Execute style call, but you have to be on drugs	*
 * if you want to do that.						*
 ************************************************************************
}

Type
    NewShell = record
	nsh_StackSize	: Integer;	{ stacksize shell will use for children	}
	nsh_Pri		: Byte;		{ ignored by interactive shells		}
	nsh_Control	: Byte;		{ bits/values: see above			}
	nsh_LogMsg	: Address;	{ Optional login message, if Nil, use default	}
	nsh_Input	: BPTR;		{ ignored by interactive shells, but		}
	nsh_Output	: BPTR;		{ used by background and execute options.	}
	nsh_RESERVED	: Array [0..4] of Integer;
    end;
    NewShellPtr = ^NewShell;

{
 ************************************************************************
 * Bit Values for nsh_Control, you should use them as shown below, or	*
 * just use the actual values indicated.				*
 ************************************************************************
}

Const
    PRB_CLI		= 0;	{ Do a CLI, not a shell	}
    PRB_BACKGROUND	= 1;	{ Background shell		}
    PRB_EXECUTE		= 2;	{ Do as EXECUTE...		}
    PRB_INTERACTIVE	= 3;	{ Run an interactive shell	}
    PRB_FB		= 7;	{ Alt function bit...		}

    PRF_CLI		= 1 shl PRB_CLI;
    PRF_BACKGOUND	= 1 shl PRB_BACKGROUND;
    PRF_EXECUTE		= 1 shl PRB_EXECUTE;
    PRF_INTERACTIVE	= 1 shl PRB_INTERACTIVE;
    PRF_FB		= 1 shl PRB_FB;

{
 ************************************************************************
 *	Common values for sh_Control which allow you to do usefull	*
 *	and somewhat "standard" things...				*
 ************************************************************************
}

    INTERACTIVE_SHELL	= PRF_FB or PRF_INTERACTIVE;
					{ Gimme a newshell!		}
    INTERACTIVE_CLI	= PRF_FB or PRF_INTERACTIVE or PRF_CLI;
					{ Gimme that ol newcli!	}
    BACKGROUND_SHELL	= PRF_FB or PRF_BACKGROUND;
					{ gimme a background shell	}
    EXECUTE_ME		= PRF_FB or PRF_BACKGROUND or PRF_EXECUTE;
					{ aptly named, doncha think?	}

{
 ************************************************************************
 *	Additional IoErr() returns added by ARP...			*
 ************************************************************************
}

    ERROR_BUFFER_OVERFLOW	= 303;	{ User or internal buffer overflow	}
    ERROR_BREAK			= 304;	{ A break character was received	}
    ERROR_NOT_EXECUTABLE	= 305;	{ A file has E bit cleared		}
    ERROR_NOT_CLI		= 400;	{ Program/function neeeds to be cli	}

{
 ************************************************************************
 *	Bit definitions for rpn_Flags....				*
 ************************************************************************
}

    RPNB_NOCHECK	= 0;	{ Set in rpn_Flags for no checksumming...	}
    RPNB_CACHE		= 1;	{ Private usage in v1.3...			}

    RPNF_NOCHECK	= 1 shl RPNB_NOCHECK;
    RPNF_CACHE		= 1 shl RPNB_CACHE;

{
 ************************************************************************
 * If your program starts with this structure, ASyncRun() and SyncRun()	*
 * will override a users stack request with the value in rpt_StackSize.	*
 * Furthermore, if you are actually attached to the resident list, a	*
 * memory block of size rpt_DataSize will be allocated for you, and	*
 * a pointer to this data passed to you in register A4.  You may use	*
 * this block to clone the data segment of programs, thus resulting in	*
 * one copy of text, but multiple copies of data/bss for each process	*
 * invocation.  If you are resident, your program will start at		*
 * rpt_Instruction, otherwise, it will be launched from the initial	*
 * branch.								*
 ************************************************************************
}

Type
    ResidentProgramTag = record
	rpt_NextSeg	: BPTR;	{ Provided by DOS at LoadSeg time	}

{
 ************************************************************************
 * The initial branch destination and rpt_Instruction do not have to be	*
 * the same.  This allows different actions to be taken if you are	*
 * diskloaded or resident.  DataSize memory will be allocated only if	*
 * you are resident, but StackSize will override all user stack		*
 * requests.								*
 ************************************************************************
}
	rpt_BRA		: Short;	{ Short branch to executable		}
	rpt_Magic	: Short;	{ Resident majik value			}
	rpt_StackSize	: Integer;	{ min stack for this process		}
	rpt_DataSize	: Integer;	{ Data size to allocate if resident	}
{	rpt_Instruction;	Start here if resident		}
    end;
    ResidentProgramTagPtr = ^ResidentProgramTag;

{
 ************************************************************************
 * The form of the ARP allocated node in your tasks memlist when	*
 * launched as a resident program. Note that the data portion of the	*
 * node will only exist if you have specified a nonzero value for	*
 * rpt_DataSize. Note also that this structure is READ ONLY, modify	*
 * values in this at your own risk.  The stack stuff is for tracking,	*
 * if you need actual addresses or stack size, check the normal places	*
 * for it in your process/task struct.					*
 ************************************************************************
}

    ProcessMemory = record
	pm_Node		: Node;
	pm_Num		: Short;	{ This is 1 if no data, two if data	}
	pm_Stack	: Address;
	pm_StackSize	: Integer;
	pm_Data		: Address;	{ Only here if pm_Num == 2		}
	pm_DataSize	: Integer;
    end;
    ProcessMemoryPtr = ^ProcessMemory;

{
 ************************************************************************
 * To find the above on your memlist, search for the following name.	*
 * We guarantee this will be the only arp.library allocated node on	*
 * your memlist with this name.						*
 * i.e. FindName(task^.tcb_MemEntry, PMEM_NAME);			*
 ************************************************************************
}

Const
    PMEM_NAME		= "ARP_MEM";
    RESIDENT_MAGIC	= $4AFC;	{ same as RTC_MATCHWORD (trapf) }

{
 ************************************************************************
 *	Date String/Data structures					*
 ************************************************************************
}

Type
    DateTime = record
	dat_Stamp	: DateStamp;	{ DOS Datestamp			}
	dat_Format	: Byte;		{ controls appearance ot dat_StrDate	}
	dat_Flags	: Byte;		{ See BITDEF's below			}
	dat_StrDay	: String;	{ day of the week string		}
	dat_StrDate	: String;	{ date string				}
	dat_StrTime	: String;	{ time string				}
    end;
    DateTimePtr = ^DateTime;

{
 ************************************************************************
 *	Size of buffer you need for each DateTime strings:		*
 ************************************************************************
}

Const
    LEN_DATSTRING	= 10;

{
 ************************************************************************
 *	For dat_Flags							*
 ************************************************************************
}

    DTB_SUBST		= 0;	{ Substitute "Today" "Tomorrow" where appropriate	}
    DTB_FUTURE		= 1;	{ Day of the week is in future				}

    DTF_SUBST		= 1 shl DTB_SUBST;
    DTF_FUTURE		= 1 shl DTB_FUTURE;

{
 ************************************************************************
 *	For dat_Format							*
 ************************************************************************
}

    FORMAT_DOS		= 0;	{ dd-mmm-yy AmigaDOS's own, unique style		}
    FORMAT_INT		= 1;	{ yy-mm-dd International format			}
    FORMAT_USA		= 2;	{ mm-dd-yy The good'ol'USA.				}
    FORMAT_CDN		= 3;	{ dd-mm-yy Our brothers and sisters to the north	}
    FORMAT_MAX		= FORMAT_CDN;	{ Larger than this? Defaults to AmigaDOS		}

{
 ************************************************************************
 *	Now for the stuff that only exists in arp.library...		*
 ************************************************************************
}

Procedure Printf(Format : String; Args : Address);
    External;

Procedure FPrintF(OutFile : FileHandle; Format : String; Args : Address);
    External;

Procedure Puts(Str : String);
    External;

Function ReadLine(Dest : String) : Integer;
    External;

Function GADS(CmdLine : String; CmdLen : Integer; ArgArray : Address;
		Template : String; ExtraHelp : String) : Integer;
    External;

Function Atol(ASCII : String) : Integer;
    External;

Function EscapeString(Str : String) : Integer;
    External;

Function CheckAbort(Func : Address) : Boolean;
    External;

Function CheckBreak(Mask : Integer; Func : Address) : Boolean;
    External;

Procedure Getenv(VarName : String; Buffer : String; Size : Integer);
    External;

Function Setenv(VarName : String; Buffer : String) : Boolean;
    External;

Function FileRequest(FR : FileRequesterPtr) : String;
    External;

Procedure CloseWindowSafely(Window, MoreWindows : Address);
    External;

Function CreatePort(PortName : String; Pri : Byte) : MsgPortPtr;
    External;

Procedure DeletePort(Port : MsgPortPtr);
    External;

Function SendPacket(Action : Integer; Args : Address; Handler : Address) : Integer;
    External;

Procedure InitStdPacket(Action : Integer; Args : Address;
			Packet : Address; ReplyPort : MsgPortPtr);
    External;

Function PathName(Lock : FileLock; Dest : String; Number : Integer) : Integer;
    External;

Function Assign(NewName : String; Physical : String) : Integer;
    External;

Function DosAllocMem(Size : Integer) : Address;
    External;

Procedure DosFreeMem(Block : Address);
    External;

Function BtoCStr(Dest : String; Str : BSTR; MaxLength : Integer) : Integer;
    External;

Function CtoBStr(Source : String; Dest : BSTR; MaxLength : Integer) : Integer;
    External;

Function GetDevInfo(DevInfoNode : DevInfoPtr) : DevInfoPtr;
    External;

Function FreeTaskResList : Boolean;
    External;

Procedure ArpExit(ReturnCode, Fault : Integer);
    External;

Function ArpAlloc(Size : Integer) : Address;
    External;

Function ArpAllocMem(Size : Integer) : Address;
    External;

Function ArpOpen(Name : String; AccessMode : Integer) : FileHandle;
    External;

Function ArpDupLock(Lock : FileLock) : FileLock;
    External;

Function ArpLock(Name : String; AccessMode : Integer) : FileLock;
    External;

Function RListAlloc(ResList : ResListPtr; Size : Integer) : Address;
    External;

Function FindCLI(TaskNum : Integer) : Address;
    External;

Procedure QSort(BasePtr : Address; Region_Size : Integer;
		Byte_Size : Integer; User_Function : Address);
    External;

Function PatternMatch(Pattern, Str : String) : Boolean;
    External;

Function FindFirst(Pattern : String; AnchorPath : AnchorPathPtr) : Integer;
    External;

Function FindNext(AnchorPath : AnchorPathPtr) : Integer;
    External;

Procedure FreeAnchorChain(AnchorPath : AnchorPathPtr);
    External;

Function CompareLock(Lock1, Lock2 : FileLock) : Boolean;
    External;

Function FindTaskResList : ResListPtr;
    External;

Function CreateTaskResList : ResListPtr;
    External;

Function FreeTaskResList : Boolean;
    External;

Procedure FreeTrackedItem(Tracker : Address);
    External;

Function GetTracker(ID : Integer) : DefaultTrackerPtr;
    External;

Function GetAccess(Tracker : Address) : Address;
    External;

Procedure FreeAccess(Tracker : Address);
    External;

Procedure FreeDAList(DANode : DirectoryEntryPtr);
    External;

Function AddDANode(Data : String; DALst : Address;
			Length : Integer; ID : Integer) : DirectoryEntryPtr;
    External;

Function AddDADevs(DAList : DirectoryEntryPtr; Select : Integer) : Integer;
    External;

Function Strcmp(Str1, Str2 : String) : Integer;
    External;

Function Strncmp(Str1, Str2 : String; n : Integer) : Integer;
    External;

Function Toupper(OldChar : Char) : Char;
    External;

Function SyncRun(FileName : String; Args : String;
			Input, Output : FileHandle) : Integer;
    External;

{
 ************************************************************************
 *	Added V32 of arp.library					*
 ************************************************************************
}

Function ASyncRun(Command, Arguments : String;
			PCB : ProcessControlBlockPtr) : Integer;
    External;

	LONG			SpawnShell		ARGs(	(char *, char *, struct NewShell *)			);

Function LoadPrg(Name : String) : BPTR;
    External;

Function PreParse(Source, Dest : String) : Boolean;
    External;

{
 ************************************************************************
 *	Added V33 of arp.library					*
 ************************************************************************
}

Function StamptoStr(DateTime : DateTimePtr) : Boolean;
    External;

Function StrtoStamp(DateTime : DateTimePtr) : Boolean;
    External;

Function ObtainResidentPrg(Name : String) : ResidentProgramNodePtr;
    External;

Function AddResidentPrg(Segment : BPTR; Name : String) : ResidentProgramNodePtr;
    External;

Function RemResidentPrg(Name : String) : Integer;
    External;

Procedure UnLoadPrg(Segment : BPTR);
    External;

Function LMult(x, y : Integer) : Integer;
    External;

Function LDiv(x, y : Integer) : Integer;
    External;

Function LMod(x, y : Integer) : Integer;
    External;

Function CheckSumPrg(Node : ResidentProgramNodePtr) : Integer;
    External;

Procedure TackOn(Path, FileName : String);
    External;

Function BaseName(Path : String) : String;
    External;

Function ReleaseResidentPrg(Segment : BPTR) : ResidentProgramNodePtr;
    External;

{
 ************************************************************************
 *	Added V36 of arp.library					*
 ************************************************************************
}

Procedure SPrintf(Buffer, Format : String; Args : Address);
    External;

Function GetKeywordIndex(Keyword : String; Template : String) : Integer;
    External;

Function ArpOpenLibrary(LibName : String; Version : Integer) : LibraryPtr;
    External;

Function ArpAllocFreq : FileRequesterPtr;
    External;


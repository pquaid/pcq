{
	DOSExtens.i for PCQ Pascal

	DOS structures not needed for the casual AmigaDOS user
}

{$I "Include:Exec/Tasks.i"}
{$I "Include:Exec/Ports.i"}
{$I "Include:Exec/Libraries.i"}
{$I "Include:Libraries/DOS.i"}


Type

{ All DOS processes have this structure }
{ Create and Device Proc returns pointer to the MsgPort in this structure }
{ dev_proc = Address(Integer(DeviceProc()) - SizeOf(Task)) }

    Process = record
	pr_Task		: Task;
	pr_MsgPort	: MsgPort;	{ This is BPTR address from DOS functions  }
	pr_Pad		: Short;	{ Remaining variables on 4 byte boundaries }
	pr_SegList	: BPTR;		{ Array of seg lists used by this process  }
	pr_StackSize	: Integer;	{ Size of process stack in bytes	    }
	pr_GlobVec	: Address;	{ Global vector for this process (BCPL)    }
	pr_TaskNum	: Integer;	{ CLI task number of zero if not a CLI	    }
	pr_StackBase	: BPTR;		{ Ptr to high memory end of process stack  }
	pr_Result2	: Integer;	{ Value of secondary result from last call }
	pr_CurrentDir	: BPTR;		{ Lock associated with current directory   }
	pr_CIS		: BPTR;		{ Current CLI Input Stream		    }
	pr_COS		: BPTR;		{ Current CLI Output Stream		    }
	pr_ConsoleTask	: Address;	{ Console handler process for current window}
	pr_FileSystemTask : Address;	{ File handler process for current drive   }
	pr_CLI		: BPTR;		{ pointer to ConsoleLineInterpreter	    }
	pr_ReturnAddr	: Address;	{ pointer to previous stack frame	    }
	pr_PktWait	: Address;	{ Function to be called when awaiting msg  }
	pr_WindowPtr	: Address;	{ Window for error printing }
    end;
    ProcessPtr = ^Process;


{ The long word address (BPTR) of this structure is returned by
 * Open() and other routines that return a file.  You need only worry
 * about this struct to do async io's via PutMsg() instead of
 * standard file system calls }

    FileHandleRec = record
	fh_Link		: MessagePtr;	{ EXEC message	      }   
	fh_Port		: MsgPortPtr;	{ Reply port for the packet }
	fh_Type		: MsgPortPtr;	{ Port to do PutMsg() to  
					  Address is negative if a plain file }
	fh_Buf		: Integer;
	fh_Pos		: Integer;
	fh_End		: Integer;
	fh_Func1	: Integer;
	fh_Func2	: Integer;
	fh_Func3	: Integer;
	fh_Arg1		: Integer;
	fh_Arg2		: Integer;
    end;
    FileHandlePtr = ^FileHandleRec;

{ This is the extension to EXEC Messages used by DOS }

    DOSPacket = record
	dp_Link	: MessagePtr;	{ EXEC message	      }
	dp_Port	: MsgPortPtr;	{ Reply port for the packet }
				{ Must be filled in each send. }
	dp_Type	: Integer;	{ See ACTION_... below and 
				* 'R' means Read, 'W' means Write to the
				* file system }
	dp_Res1	: Integer;	{ For file system calls this is the result
				* that would have been returned by the
				* function, e.g. Write ('W') returns actual
				* length written }
	dp_Res2	: Integer;	{ For file system calls this is what would
				* have been returned by IoErr() }
	dp_Arg1	: Integer;
	dp_Arg2	: Integer;
	dp_Arg3	: Integer;
	dp_Arg4	: Integer;
	dp_Arg5	: Integer;
	dp_Arg6	: Integer;
	dp_Arg7	: Integer;
    end;
    DOSPacketPtr = ^DOSPacket;


{ A Packet does not require the Message to be before it in memory, but
 * for convenience it is useful to associate the two. 
 * Also see the function init_std_pkt for initializing this structure }


    StandardPacket = record
	sp_Msg		: Message;
	sp_Pkt		: DOSPacket;
    end;
    StandardPacketPtr = ^StandardPacket;


Const

{ Packet types }
    ACTION_NIL			= 0;
    ACTION_GET_BLOCK		= 2;	{ OBSOLETE }
    ACTION_SET_MAP		= 4;
    ACTION_DIE			= 5;
    ACTION_EVENT		= 6;
    ACTION_CURRENT_VOLUME	= 7;
    ACTION_LOCATE_OBJECT	= 8;
    ACTION_RENAME_DISK		= 9;
    ACTION_WRITE		= $57;	{ 'W' }
    ACTION_READ			= $52;	{ 'R' }
    ACTION_FREE_LOCK		= 15;
    ACTION_DELETE_OBJECT	= 16;
    ACTION_RENAME_OBJECT	= 17;
    ACTION_MORE_CACHE		= 18;
    ACTION_COPY_DIR		= 19;
    ACTION_WAIT_CHAR		= 20;
    ACTION_SET_PROTECT		= 21;
    ACTION_CREATE_DIR		= 22;
    ACTION_EXAMINE_OBJECT	= 23;
    ACTION_EXAMINE_NEXT		= 24;
    ACTION_DISK_INFO		= 25;
    ACTION_INFO			= 26;
    ACTION_FLUSH		= 27;
    ACTION_SET_COMMENT		= 28;
    ACTION_PARENT		= 29;
    ACTION_TIMER		= 30;
    ACTION_INHIBIT		= 31;
    ACTION_DISK_TYPE		= 32;
    ACTION_DISK_CHANGE		= 33;
    ACTION_SET_DATE		= 34;

    ACTION_SCREEN_MODE		= 994;

    ACTION_READ_RETURN		= 1001;
    ACTION_WRITE_RETURN		= 1002;
    ACTION_SEEK			= 1008;
    ACTION_FINDUPDATE		= 1004;
    ACTION_FINDINPUT		= 1005;
    ACTION_FINDOUTPUT		= 1006;
    ACTION_END			= 1007;
    ACTION_TRUNCATE		= 1022;	{ fast file system only }
    ACTION_WRITE_PROTECT	= 1023;	{ fast file system only }

{ DOS library node structure.
 * This is the data at positive offsets from the library node.
 * Negative offsets from the node is the jump table to DOS functions  
 * node = (struct DosLibrary *) OpenLibrary( "dos.library" .. )	     }

Type

    DOSLibrary = record
	dl_lib		: Library;
	dl_Root		: Address;      { Pointer to RootNode, described below }
	dl_GV		: Address;      { Pointer to BCPL global vector	      }
	dl_A2		: Integer;      { Private register dump of DOS	      }
	dl_A5		: Integer;
	dl_A6		: Integer;
    end;
    DOSLibraryPtr = ^DOSLibrary;

    RootNode = record
	rn_TaskArray	: BPTR;		{ [0] is max number of CLI's
					  [1] is APTR to process id of CLI 1
					  [n] is APTR to process id of CLI n }
	rn_ConsoleSegment : BPTR;	{ SegList for the CLI }
	rn_Time		: DateStampRec;	{ Current time }
	rn_RestartSeg	: Integer;	{ SegList for the disk validator process }
	rn_Info		: BPTR;		{ Pointer ot the Info structure }
	rn_FileHandlerSegment : BPTR;	{ segment for a file handler }
    end;
    RootNodePtr = ^RootNode;

    DOSInfo = record
	di_McName	: BPTR;	{ Network name of this machine; currently 0 }
	di_DevInfo	: BPTR;	{ Device List }
	di_Devices	: BPTR;	{ Currently zero }
	di_Handlers	: BPTR;	{ Currently zero }
	di_NetHand	: Address;	{ Network handler processid; currently zero }
    end;
    DOSInfoPtr = ^DOSInfo;

{ DOS Processes started from the CLI via RUN or NEWCLI have this additional
 * set to data associated with them }

    CommandLineInterface = record
	cli_Result2	: Integer;	{ Value of IoErr from last command }
	cli_SetName	: BSTR;		{ Name of current directory }
	cli_CommandDir	: BPTR;		{ Lock associated with command directory }
	cli_ReturnCode	: Integer;	{ Return code from last command }
	cli_CommandName	: BSTR;		{ Name of current command }
	cli_FailLevel	: Integer;	{ Fail level (set by FAILAT) }
	cli_Prompt	: BSTR;		{ Current prompt (set by PROMPT) }
	cli_StandardInput : BPTR;	{ Default (terminal) CLI input }
	cli_CurrentInput : BPTR;	{ Current CLI input }
	cli_CommandFile	: BSTR;		{ Name of EXECUTE command file }
	cli_Interactive	: Integer;	{ Boolean; True if prompts required }
	cli_Background	: Integer;	{ Boolean; True if CLI created by RUN }
	cli_CurrentOutput : BPTR;	{ Current CLI output }
	cli_DefaultStack : Integer;	{ Stack size to be obtained in long words }
	cli_StandardOutput : BPTR;	{ Default (terminal) CLI output }
	cli_Module	: BPTR;		{ SegList of currently loaded command }
    end;
    CommandLineInterfacePtr = ^CommandLineInterface;

{ This structure can take on different values depending on whether it is
 * a device, an assigned directory, or a volume.  Below is the structure
 * reflecting volumes only.  Following that is the structure representing
 * only devices.
 }

{ structure representing a volume }

    DeviceList = record
	dl_Next		: BPTR;		{ bptr to next device list }
	dl_Type		: Integer;	{ see DLT below }
	dl_Task		: MsgPortPtr;	{ ptr to handler task }
	dl_Lock		: BPTR;		{ not for volumes }
	dl_VolumeDate	: DateStampRec;	{ creation date }
	dl_LockList	: BPTR;		{ outstanding locks }
	dl_DiskType	: Integer;	{ 'DOS', etc }
	dl_unused	: Integer;
	dl_Name		: BSTR;		{ bptr to bcpl name }
    end;
    DeviceListPtr = ^DeviceList;

{ device structure (same as the DeviceNode structure in filehandler.h) }

    DevInfo = record
	dvi_Next	: BPTR;
	dvi_Type	: Integer;
	dvi_Task	: Address;
	dvi_Lock	: BPTR;
	dvi_Handler	: BSTR;
	dvi_StackSize	: Integer;
	dvi_Priority	: Integer;
	dvi_Startup	: Integer;
	dvi_SegList	: BPTR;
	dvi_GlobVec	: BSTR;
	dvi_Name	: BSTR;
    end;
    DevInfoPtr = ^DevInfo;

{ combined structure for devices, assigned directories, volumes }

Const

{ definitions for dl_Type }

    DLT_DEVICE		= 0;
    DLT_DIRECTORY	= 1;
    DLT_VOLUME		= 2;

Type

{ a lock structure, as returned by Lock() or DupLock() }

    FileLockRec = record
	fl_Link		: BPTR;		{ bcpl pointer to next lock }
	fl_Key		: Integer;	{ disk block number }
	fl_Access	: Integer;	{ exclusive or shared }
	fl_Task		: MsgPortPtr;	{ handler task's port }
	fl_Volume	: BPTR;		{ bptr to a DeviceList }
    end;
    FileLockPtr = ^FileLockRec;


Function CreateProc(name : String; pri : Integer;
			segment : BPTR; stackSize : Integer) : ProcessPtr;
    External;

Function DeviceProc(name : String) : ProcessPtr;
    External;

Function LoadSeg(name : String) : BPTR;
    External;

Procedure UnLoadSeg(segment : BPTR);
    External;


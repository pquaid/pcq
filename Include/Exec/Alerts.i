{
    Alerts.i for PCQ Pascal
}

const
    SF_ALERTWACK	= 2;	{ in ExecBase.SysFlag }

{*********************************************************************
*
*  Format of the alert error number:
*
*    +-+-------------+----------------+--------------------------------+  
*    |D|  SubSysId   |	General Error |	   SubSystem Specific Error    |
*    +-+-------------+----------------+--------------------------------+
*
*		     D:	 DeadEnd alert
*	      SubSysId:	 indicates ROM subsystem number.
*	 General Error:	 roughly indicates what the error was
*	Specific Error:	 indicates more detail
*********************************************************************}

{********************************************************************
*
*  General Dead-End Alerts
*
********************************************************************}

{------ alert types }

    AT_DeadEnd	= $80000000;
    AT_Recovery	= $00000000;

{------ general purpose alert codes }

    AG_NoMemory	= $00010000;
    AG_MakeLib	= $00020000;
    AG_OpenLib	= $00030000;
    AG_OpenDev	= $00040000;
    AG_OpenRes	= $00050000;
    AG_IOError	= $00060000;
    AG_NoSignal	= $00070000;

{------ alert objects: }

    AO_ExecLib		= $00008001;
    AO_GraphicsLib	= $00008002;
    AO_LayersLib	= $00008003;
    AO_Intuition	= $00008004;
    AO_MathLib		= $00008005;
    AO_CListLib		= $00008006;
    AO_DOSLib		= $00008007;
    AO_RAMLib		= $00008008;
    AO_IconLib		= $00008009;
    AO_ExpansionLib 	= $0000800A;
    AO_AudioDev		= $00008010;
    AO_ConsoleDev	= $00008011;
    AO_GamePortDev	= $00008012;
    AO_KeyboardDev	= $00008013;
    AO_TrackDiskDev	= $00008014;
    AO_TimerDev		= $00008015;
    AO_CIARsrc		= $00008020;
    AO_DiskRsrc		= $00008021;
    AO_MiscRsrc		= $00008022;
    AO_BootStrap	= $00008030;
    AO_Workbench	= $00008031;


{********************************************************************
*
*   Specific Dead-End Alerts:
*
********************************************************************}

{------ exec.library }

    AN_ExecLib		= $01000000;
    AN_ExcptVect	= $81000001;	{ 68000 exception vector checksum }
    AN_BaseChkSum	= $81000002;	{ execbase checksum }
    AN_LibChkSum	= $81000003;	{ library checksum failure }
    AN_LibMem		= $81000004;	{ no memory to make library }
    AN_MemCorrupt	= $81000005;	{ corrupted memory list }
    AN_IntrMem		= $81000006;	{ no memory for interrupt servers }
    AN_InitAPtr		= $81000007;	{ InitStruct() of an APTR source }
    AN_SemCorrupt	= $81000008;	{ a semaphore is in illegal state }
    AN_FreeTwice	= $81000009;	{ freeing memory already freed }
    AN_BogusExcpt	= $8100000A;	{ illegal 68k exception taken }

{------ graphics.library }

    AN_GraphicsLib	= $02000000;
    AN_GfxNoMem		= $82010000;	{ graphics out of memory }
    AN_LongFrame	= $82010006;	{ long frame, no memory }
    AN_ShortFrame	= $82010007;	{ short frame, no memory }
    AN_TextTmpRas	= $02010009;	{ text, no memory for TmpRas }
    AN_BltBitMap	= $8201000A;	{ BltBitMap, no memory }
    AN_RegionMemory 	= $8201000B;	{ regions, memory not available }
    AN_MakeVPort	= $82010030;	{ MakeVPort, no memory }
    AN_GfxNoLCM		= $82011234;	{ emergency memory not available }	

{------ layers.library }

    AN_LayersLib	= $03000000;
    AN_LayersNoMem	= $83010000;	{ layers out of memory }

{------ intuition.library }

    AN_Intuition	= $04000000;
    AN_GadgetType	= $84000001;	{ unknown gadet type }
    AN_BadGadget	= $04000001;	{ Recovery form of AN_GadgetType }
    AN_CreatePort	= $84010002;	{ create port, no memory }
    AN_ItemAlloc	= $04010003;	{ item plane alloc, no memory }
    AN_SubAlloc		= $04010004;	{ sub alloc, no memory }
    AN_PlaneAlloc	= $84010005;	{ plane alloc, no memory }
    AN_ItemBoxTop	= $84000006;	{ item box top < RelZero }
    AN_OpenScreen	= $84010007;	{ open screen, no memory }
    AN_OpenScrnRast 	= $84010008;	{ open screen, raster alloc, no memory }
    AN_SysScrnType	= $84000009;	{ open sys screen, unknown type }
    AN_AddSWGadget	= $8401000A;	{ add SW gadgets, no memory }
    AN_OpenWindow	= $8401000B;	{ open window, no memory }
    AN_BadState		= $8400000C;	{ Bad State Return entering Intuition }
    AN_BadMessage	= $8400000D;	{ Bad Message received by IDCMP }
    AN_WeirdEcho	= $8400000E;	{ Weird echo causing incomprehension }
    AN_NoConsole	= $8400000F;	{ couldn't open the Console Device }


{------ math.library }

    AN_MathLib	= $05000000;

{------ clist.library }

    AN_CListLib	= $06000000;

{------ dos.library }

    AN_DOSLib		= $07000000;
    AN_StartMem		= $07010001;	{ no memory at startup }
    AN_EndTask		= $07000002;	{ EndTask didn't }
    AN_QPktFail		= $07000003;	{ Qpkt failure }
    AN_AsyncPkt		= $07000004;	{ Unexpected packet received }
    AN_FreeVec		= $07000005;	{ Freevec failed }
    AN_DiskBlkSeq	= $07000006;	{ Disk block sequence error }
    AN_BitMap		= $07000007;	{ Bitmap corrupt }
    AN_KeyFree		= $07000008;	{ Key already free }
    AN_BadChkSum	= $07000009;	{ Invalid checksum }
    AN_DiskError	= $0700000A;	{ Disk Error }
    AN_KeyRange		= $0700000B;	{ Key out of range }
    AN_BadOverlay	= $0700000C;	{ Bad overlay }

{------ ramlib.library }

    AN_RAMLib		= $08000000;
    AN_BadSegList	= $08000001;	{ no overlays in library seglists }

{------ icon.library }

    AN_IconLib	= $09000000;

{------ expansion.library }

    AN_ExpansionLib 	= $0A000000;
    AN_BadExpansionFree	= $0A000001;

{------ audio.device }

    AN_AudioDev	= $10000000;

{------ console.device }

    AN_ConsoleDev	= $11000000;

{------ gameport.device }

    AN_GamePortDev	= $12000000;

{------ keyboard.device }

    AN_KeyboardDev	= $13000000;

{------ trackdisk.device }

    AN_TrackDiskDev 	= $14000000;
    AN_TDCalibSeek	= $14000001;	{ calibrate: seek error }
    AN_TDDelay		= $14000002;	{ delay: error on timer wait }

{------ timer.device }

    AN_TimerDev		= $15000000;
    AN_TMBadReq		= $15000001;	{ bad request }
    AN_TMBadSupply	= $15000002;	{ power supply does not supply ticks }

{------ cia.resource }

    AN_CIARsrc	= $20000000;

{------ disk.resource }

    AN_DiskRsrc		= $21000000;
    AN_DRHasDisk	= $21000001;	{ get unit: already has disk }
    AN_DRIntNoAct	= $21000002;	{ interrupt: no active unit }

{------ misc.resource }

    AN_MiscRsrc	= $22000000;

{------ bootstrap }

    AN_BootStrap	= $30000000;
    AN_BootError	= $30000001;	{ boot code returned an error }

{------ Workbench }

    AN_Workbench	= $31000000;

{------ DiskCopy }

    AN_DiskCopy	= $32000000;

Procedure Alert(alertNum : Integer; parameters : Address);
    External;


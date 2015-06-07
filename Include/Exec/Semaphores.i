{
    Semaphores.i for PCQ Pascal
}

{$I "Include:Exec/Nodes.i"}
{$I "Include:Exec/Lists.i"}
{$I "Include:Exec/Ports.i"}
{$I "Include:Exec/Tasks.i"}

	{ Semaphore }
type
    Semaphore = record
	sm_MsgPort : MsgPort;
	sm_Bids    : Short;
    end;
    SemaphorePtr = ^Semaphore;

{  This is the structure used to request a signal semaphore }

    SemaphoreRequest = record
	sr_Link    : MinNode;
	sr_Waiter  : TaskPtr;
    end;
    SemaphoreRequestPtr = ^SemaphoreRequest;

{ The actual semaphore itself }

    SignalSemaphore = record
	ss_Link		: Node;
	ss_NestCount	: Short;
	ss_WaitQueue	: MinList;
	ss_MultipleLink	: SemaphoreRequest;
	ss_Owner	: TaskPtr;
	ss_QueueCount	: Short;
    end;
    SignalSemaphorePtr = ^SignalSemaphore;


Procedure AddSemaphore(sigsem : SignalSemaphorePtr);
    External;

Function AttemptSemaphore(sigsem : SignalSemaphorePtr) : Boolean;
    External;

Function FindSemaphore(name : String) : SignalSemaphorePtr;
    External;

Procedure InitSemaphore(sigsem : SignalSemaphorePtr);
    External;

Procedure ObtainSemaphore(sigsem : SignalSemaphorePtr);
    External;

Procedure ObtainSemaphoreList(semlist : ListPtr);
    External;

Function Procure(sem : SemaphorePtr; bid : MessagePtr) : Boolean;
    External;

Procedure ReleaseSemaphore(sigsem : SignalSemaphorePtr);
    External;

Procedure ReleaseSemaphoreList(siglist : ListPtr);
    External;

Procedure RemSemaphore(sigsem : SignalSemaphorePtr);
    External;

Procedure Vacate(sem : SemaphorePtr);
    External;


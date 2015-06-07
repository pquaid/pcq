Program TaskExample;

{
 *
 * Task.p - a cheap sub-task example by cs (in C)
 *   Cheap =  shared data for communication rather than MsgPorts
 *

	This was written originally by Carolyn Scheppner (of CBM) in C.
}

{$I "Include:Exec/Ports.i"}
{$I "Include:Graphics/Graphics.i"}
{$I "Include:Graphics/View.i"}
{$I "Include:Libraries/DOS.i"}
{$I "Include:Utils/TaskUtils.i"}
{$I "Include:Exec/Tasks.i"}
{$I "Include:Exec/Libraries.i"}

CONST
    subTaskName : String = "SubTask";
    subTaskPtr : TaskPtr = Nil;

{ Data shared by main and subTaskRtn }

    Counter : Integer = 0;
    PrepareToDie : Boolean = False;

Procedure CleanUp;
begin
   if subTaskPtr <> Nil then begin
	PrepareToDie := True;
	while PrepareToDie do;
	DeleteTask(SubTaskPtr);
   end;
   CloseLibrary(GfxBase);
end;


{ subTaskRtn increments Counter every 1/60 second }

Procedure SubTaskRtn;
var
    Temp : Integer;
begin
    While not PrepareToDie do begin
	WaitTOF;
	Inc(Counter);
    end;
    PrepareToDie := False;	{ signal ready to go }
    Temp := Wait(0);		{ wait while the ax falls }
end;

var
    k : Integer;
    ct : Integer;
begin
    GfxBase := OpenLibrary("graphics.library",0);
    if GfxBase = Nil then begin
	Writeln('Can\'t open the graphics.library');
	Exit(20);
    end;

    SubTaskPtr := CreateTask(subTaskName,0,Adr(subTaskRtn),2000);
    if SubTaskPtr = Nil then begin
	Writeln('Can\'t create subtask');
	CloseLibrary(GfxBase);
	Exit(10);
    end;

    for k := 0 to 9 do begin
	Delay(50);  { main is a process and can call Delay() }
	ct := Counter;
	Writeln('Counter is ', ct);
    end;
    CleanUp;
end.

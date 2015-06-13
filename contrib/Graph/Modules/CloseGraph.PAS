external;

{
    Definition for a module for GRAPH.LIB
}

{$I "INCLUDE:intuition/Intuition.i"}
{$I "INCLUDE:intuition/Screens.i"}

{$SX}
var
  scrptr  : ^screen;
  winptr  : ^window;
  winlist : array[0..3] of ^window;
  Error   : boolean;

procedure CloseGraph;
var
  n : byte;
begin
  for n:=0 to 3 do
    if winlist[n]<>nil then begin
      CloseWindow(winlist[n]);
      winlist[n]:=nil;
    end;
  winptr:=nil;
  if scrptr<>nil then begin
    CloseScreen(scrptr);
    scrptr:=nil;
  end;
  Error:=false;
end;


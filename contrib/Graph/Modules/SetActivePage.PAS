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

procedure SetActivePage(n: byte);
begin
  if n<4 then if winlist[n]<>nil then winptr:=winlist[n];
end;


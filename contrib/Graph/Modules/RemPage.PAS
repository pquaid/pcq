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

procedure RemPage(n: byte);
begin
  Error:=(n<1) or (n>3) or (winlist[n]=nil);
  if Error then return
  else begin
    winptr:=winlist[0];
    if winptr<>nil then WindowToFront(winptr);
    CloseWindow(winlist[n]);
    winlist[n]:=nil;
  end;
end;



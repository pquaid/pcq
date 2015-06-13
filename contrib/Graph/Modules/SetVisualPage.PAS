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

procedure SetVisualPage(n: byte);
var
  dummy : boolean;
begin
  if n=255 then dummy:=WBenchToFront
  else if scrptr<>nil then begin
    ScreenToFront(scrptr);
    if n<4 then if winlist[n]<>nil then
      WindowToFront(winlist[n]);
  end;
end;


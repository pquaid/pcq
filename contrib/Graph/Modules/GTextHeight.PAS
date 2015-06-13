external;

{
    Definition for a module for GRAPH.LIB
}

{$I "INCLUDE:intuition/Intuition.i"}
{$I "INCLUDE:intuition/Screens.i"}


{$SX}
var
  scrptr : ^screen;
  winptr : ^window;

function GTextHeight(txt: string): short; { txt not used! }
begin
  if scrptr<>nil then
    GTextHeight:=scrptr^.Font^.ta_YSize
  else
    GTextHeight:=0;
end;


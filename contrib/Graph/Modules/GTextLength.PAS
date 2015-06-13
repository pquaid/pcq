external;

{
    Definition for a module for GRAPH.LIB
}

{$I "INCLUDE:intuition/Intuition.i"}
{$I "INCLUDE:intuition/Screens.i"}
{$I "INCLUDE:graphics/Pens.i"}
{$I "INCLUDE:Utils/StringLib.i"}


{$SX}
var
  scrptr : ^screen;
  winptr : ^window;

function GTextLength(txt: string): short;
begin
  if winptr<>nil then
    GTextLength:=TextLength(winptr^.RPort,txt,strlen(txt))
  else
    GTextLength:=0;
end;


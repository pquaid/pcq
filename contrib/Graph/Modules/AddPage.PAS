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

{$SN}
procedure AddPage(n: byte);
const
  win	 : NewWindow = (0,0,0,0,0,0,0,$10800,nil,nil,nil,nil,nil,0,0,0,0,$f);
begin
  Error:=(n<1) or (n>3) or (scrptr=nil) or (winlist[n]<>nil);
  if Error then return
  else begin
    with win do begin
      Height:=scrptr^.Height;
      Width:=scrptr^.Width;
      Screen:=scrptr;
    end;
    winlist[n]:=OpenWindow(@win);
    Error:=winlist[n]=nil;
  end;
end;



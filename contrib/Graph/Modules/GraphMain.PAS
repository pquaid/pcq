external;

{
    Startup and termination of GRAPH
}

{$I "INCLUDE:exec/Libraries.i"}
{$I "INCLUDE:intuition/Screens.i"}
{$I "INCLUDE:intuition/Intuition.i"}
{$I "INCLUDE:graphics/Pens.i"}

{$SN}
const
  scrptr  : ^screen = nil;
  winptr  : ^window = nil;
  winlist : array[0..3] of ^window = (nil,nil,nil,nil);
  Error   : boolean = false;

var
  GfxBase : address;

{$SP}
  OldProc : address;

procedure Terminate;
var
  n : byte;
begin
  ExitProc:=OldProc;
  for n:=0 to 3 do
    if winlist[n]<>nil then CloseWindow(winlist[n]);
  if scrptr<>nil then CloseScreen(scrptr);
  CloseLibrary(GfxBase);
end;

{$SN}
procedure AttachGraph;
begin
  GfxBase:=OpenLibrary("graphics.library",0);
  if GfxBase=nil then exit(20);
  OldProc:=ExitProc;
  ExitProc:=@Terminate;
end;

procedure InitGraph(Swidth,Sheight,Sdepth,Vmodes: short);
type
  ExtNewScreen = record
    NS	: NewScreen;
    Ext : address;
  end;
  TagItem = array[0..1] of integer; { AutoScoll and Overscan for OS2.0	}

				    { Note that $1000 in scr.type      }
				    { indicates an ExtNewScreen-struct }
				    { which is supported by OS2.0 but  }
				    { ignored in older OS versions!    }
const
  Tags	 : array[0..2] of TagItem = (($80000019+32,1),
				     ($80000014+32,1),(0,0));
  scr	 : ExtNewScreen = ((0,0,0,0,0,0,0,0,$110F,nil,nil,nil,nil),@Tags);
  win	 : NewWindow = (0,0,0,0,0,0,0,$10800,nil,nil,nil,nil,nil,0,0,0,0,$f);
  colors : array[0..15] of short = (
    $000,$00a,$0a0,$0bb,$a00,$a0a,$a87,$ccc,
    $444,$00f,$0f0,$0ff,$f00,$f0f,$ff0,$fff);	{ Turbo like }
var
  n : byte;
begin
  Error:=False;
  for n:=0 to 3 do
    if winlist[n]<>nil then CloseWindow(winlist[n]);
  winptr:=nil;
  if scrptr<>nil then CloseScreen(scrptr);
  with scr.NS do begin
    Width:=Swidth;
    Height:=Sheight;
    Depth:=Sdepth;
    ViewModes:=Vmodes;
  end;
  with win do begin
    Width:=Swidth;
    Height:=Sheight;
  end;
  scrptr:=OpenScreen(@scr);
  if scrptr=nil then
    error:=true
  else begin
    win.screen:=scrptr;
    winptr:=OpenWindow(@win);
    error:=winptr=nil;
    if error then begin
      CloseScreen(scrptr);
      scrptr:=nil;
    end else begin
      winlist[0]:=winptr;
      LoadRGB4(ViewPortAddress(winptr),@colors,(Sdepth shl 2) and 31);
      SetAPen(winptr^.RPort,15);
    end;
  end;
end;


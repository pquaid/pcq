{
    GRAPH.i
}
{ colors }
const
  Black 	= 0;
  Blue		= 1;
  Green 	= 2;
  Cyan		= 3;
  Red		= 4;
  Magenta	= 5;
  Brown 	= 6;
  LightGray	= 7;
  DarkGray	= 8;
  LightBlue	= 9;
  LightGreen	= 10;
  LightCyan	= 11;
  LightRed	= 12;
  LightMagenta	= 13;
  Yellow	= 14;
  White 	= 15;

{ modes for InitGraph }
  LoRes = $0000;
  HiRes = $8000;
  Brite = $0080;
  HAM = $0800;
  Lace	 = $0004;

{ special page number for SetVisualPage }
  WBPage = 255;

type
{ used by GetArcCoords }
    ArcCoordsType = record
      X,Y,
      Xstart,Ystart,
      Xend,Yend     : short;
    end;


{ GRAPH init and termination routines }
procedure AttachGraph; external;
procedure InitGraph(Swidth,Sheight,Sdepth,Vmodes: short); external;
procedure CloseGraph; external;
function GraphResult: short; external;

{ Page routines }
procedure AddPage(num: byte); external;
procedure RemPage(num: byte); external;
procedure ClearDevice; external;
procedure SetActivePage(n: byte); external;
procedure SetVisualPage(n: byte); external;

{ pen postion control }
function GetMaxX: short; external;
function GetMaxY: short; external;
function GetX: short; external;
function GetY: short; external;
procedure MoveTo(x,y: short); external;
procedure MoveRel(x,y: short); external;

{ color routines }
function GetMaxColor: short; external;
function GetColor: byte; external;
function GetBkColor: byte; external;
procedure SetColor(num: byte); external;
procedure SetBkColor(num: byte); external;
procedure SetRGBPalette(n: short; r,g,b: byte); external;


{ pixel-oriented routines }
procedure Plot(x,y: short); external;
procedure PutPixel(x,y: short; c: byte); external;
function GetPixel(x,y: short): integer; external;

{ line-oriented routines }
procedure Line(x0,y0,x1,y1: short); external;
procedure LineTo(x,y: short); external;
procedure LineRel(x,y: short); external;

{ text-oriented routines }
procedure OutText(txt: string); external;
procedure OutTextXY(x,y: short; txt: string); external;
function GTextLength(txt: string): short; external;
function GTextHeight(txt: string): short; external;

{ more complex figures }
procedure Circle(x,y,r: short); external;
procedure Ellipse(x,y,r1,r2: short); external;
procedure Arc(x,y,w0,w1,r: short); external;
procedure GetArcCoords(var Coords: ArcCoordsType); external;
procedure Rect(x0,y0,x1,y1: short); external; { simple Rectangle }
procedure Bar(x0,y0,x1,y1: short); external;

{ GRAPH tools ect }
function GetScreenPtr: address; external;
function GetWindowPtr: address; external;
function WriteIFF(filename: string; display: address): integer; external;
procedure HardCopy(scr: address); external;

function SaveDisplay(filename: string): integer;
begin
  SaveDisplay:=WriteIFF(filename,GetScreenPtr);
end;

procedure PrintDisplay;
begin
  HardCopy(GetScreenPtr);
end;

{ often used import }
function CheckBreak: boolean; external;


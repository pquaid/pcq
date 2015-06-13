program PageTest;
{$I "INCLUDE:GRAPH.i"}
{$I "INCLUDE:Utils/Random.i"}

const
  Page0txt = " Page 0   »Random dance« ";
  Page1txt = " Page 1   » Pixel - Forest « ";
  Page2txt = " Page 2   » Chars town « ";
  Page3txt = " Page 3 - just a dummy one ";

var
  n : short;

procedure HaltError(msg: string);
begin
  writeln(msg);
  writeln("*** program halted!");
  exit(10);
end;

procedure HeadLine(txt: string);    { print a centered headline }
begin
  OutTextXY((GetMaxX-GTextLength(txt)) div 2,GTextHeight(txt),txt);
end;

begin
  AttachGraph;			    { The init stuff		}
  InitGraph(320,256,2,LoRes);
  if GraphResult<>0 then HaltError("No display - sorry!");
  AddPage(1);
  if GraphResult<>0 then HaltError("Failed to add page 1");
  AddPage(2);
  if GraphResult<>0 then HaltError("Failed to add page 2");
  AddPage(3);
  if GraphResult<>0 then HaltError("Failed to add page 3");
  SetVisualPage(WBPage);            { WorkBench is visible now  }
  write("Drawing some pictures...");
  SetActivePage(0);
  MoveTo(RangeRandom(GetMaxX),RangeRandom(GetMaxY));
  for n:=1 to 200 do LineTo(RangeRandom(GetMaxX),RangeRandom(GetMaxY));
  HeadLine(Page0txt);
  SetActivePage(1);                 { Do some drawing...        }
  SetBkColor(DarkGray);
  ClearDevice;
  for n:=1 to 1000 do
    PutPixel(RangeRandom(GetMaxX),RangeRandom(GetMaxY),
	     RangeRandom(GetMaxColor));
  HeadLine(Page1txt);
  SetActivePage(2);
  SetColor(LightMagenta);
  for n:=1 to 100 do begin
    MoveTo(RangeRandom(GetMaxX-20)+20,RangeRandom(GetMaxY-20)+20);
    OutText("*");
    MoveRel(RangeRandom(10),-RangeRandom(10));
    OutText("#");
  end;
  HeadLine(Page2txt);
  SetActivePage(3);
  HeadLine(Page3txt);
  writeln("done!");
  repeat			    { User may select or remove pages here }
    write("See page Nr (neg. to remove it, 10 to quit): ");
    readln(n);
    if n>=0 then SetVisualPage(byte(n))
    else begin
      write("Trying to remove page ",-n, " ...");
      RemPage(-n);
      if GraphResult=0 then writeln("successfull!")
      else writeln("can't do that!");
    end;
  until (n=10);
  CloseGraph;
end.



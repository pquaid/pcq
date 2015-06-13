external;

{
    Definition for a module for GRAPH.LIB
}

{$SX}
var
  Error  : boolean;

function GraphResult: short;
var
  rem : boolean;
begin
  rem:=Error;
  Error:=False;
  GraphResult:=Ord(rem);
end;


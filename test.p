program test;

{$I "Include:Intiution/Intuition.i"}


var
    w : WindowPtr;

procedure rita(d : data);
begin
    repeat until GetMsg(w^.UserPort) = Nil; 
end;

begin
    rita(sd);
end.

procedure prune (s : string; var rank : byte);

var ct2 : char;

begin
sendstring (s);
sendrank (rank);
sendstring ("\n");
sendstring (bbsdata[12]);
ct2 := readoption ('A','Z');
sendstring ("\n");
rank := getrank (toupper(ct2));
saveindex;
if curuser.xpert <> 'Y' then tapreturn;
end;

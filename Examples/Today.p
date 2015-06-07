Program Today;

{$I "Include:Utils/DateTools.i"}


Var
    TodayTime : DateDescription;

begin
    TimeDesc(TodayTime);

    with TodayTime do
	Writeln('The time is: ', Hour:2, ':', Minute:2, ':', Second:2);
end.

{$I "Include:Utils/Stringlib.i"}

Procedure CEGetParam (src : string; var dest : string; num : short);

var
	work	: string;
	cpos	: short;
	i	: short;

	Procedure Eat_Param;

	var	wpos	: short;

	begin
	wpos := 0;
	strcpy (work, "");
	while isspace (src[cpos]) do inc (cpos);
	if src[cpos] = '"' then
		begin
		inc (cpos);
		while (src[cpos] <> char(0)) and (src[cpos] <> '"') do
			begin
			work [wpos] := src [cpos];
			work [wpos + 1] := char(0);
			inc (wpos);
			inc (cpos);
			end;
		if src[cpos] = '"' then inc(cpos);
		end else
		begin
		while (not isspace(src[cpos])) and (src[cpos] <> char(0)) do
			begin
			work [wpos] := src [cpos];
			work [wpos + 1] := char(0);
			inc (wpos);
			inc (cpos);
			end;
		end;
	end;

begin
work := allocstring (90);
cpos := 0;
for i := 1 to num do Eat_Param;
StrCpy (dest, work);
freestring (work);
end;

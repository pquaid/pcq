External;

{
	SameName.p

	This include file contains only one function: SameName.
This routine implements the simplest parts of AmigaDOS pattern matching.
At this point that's just the  # and ? operators, plus the single quote ',
which you place before a # or ? meant to be matched literaly.  Check out
the AmigaDOS books for more information.
	The source for this is in Runtime/Extras, and the object code
is in PCQ.lib
}



Function SameNameInt(Mask, Target : String;
		     MaskPos, TargetPos : Short) : Boolean;

type
    CompState = (initial, two_char, char_series, any_char, star);
var
    State : CompState;
    Stay  : Boolean;
begin
    State := initial;
    while true do
	case State of
	  initial : case Mask[MaskPos] of
		      '#' : begin
				MaskPos := Succ(MaskPos);
				State := char_series;
			    end;
		      '?' : begin
				MaskPos := Succ(MaskPos);
				State := any_char;
			    end;
		     '\'' : begin
				MaskPos := Succ(MaskPos);
				State := two_char;
			    end;
		    else
			State := two_char;
		    end;
	  two_char: if Mask[MaskPos] = Target[TargetPos] then begin
			if Mask[MaskPos] = '\0' then
			    SameNameInt := True;
			MaskPos := Succ(MaskPos);
			TargetPos := Succ(TargetPos);
			State := initial;
		    end else
			SameNameInt := False;
	  char_series :
		    case Mask[MaskPos] of
		      '?' : begin
				MaskPos := Succ(MaskPos);
				State := Star;
			    end;
		     '\0' : SameNameInt := False;
		    else begin
			     while Target[TargetPos] = Mask[MaskPos] do
				 TargetPos := Succ(TargetPos);
			     MaskPos := Succ(MaskPos);
			     State := initial;
			 end;
		    end;
	  any_char: begin
			TargetPos := Succ(TargetPos);
			State := initial;
		    end;
	  star    : repeat
			Stay := True;
			while (Target[TargetPos] <> Mask[MaskPos]) and
				(Target[TargetPos] <> '\0') do
			    Inc(TargetPos);
			if Target[TargetPos] = '\0' then begin
			    Stay := False;
			    State := initial;
			end else if SameNameInt(Mask, Target, MaskPos, TargetPos) then
			    SameNameInt := True
			else
			    Inc(TargetPos);
		    until not Stay;
	end;
end;

Function SameName(Mask, Target : String) : Boolean;
begin
    SameName := SameNameInt(Mask, Target, 0, 0);
end;

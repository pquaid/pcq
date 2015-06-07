Program Sieve;

{
    This is the same old sieve program.  According to the docs for
    Sozobon-C, Manx C runs this in about 7 seconds, and ZC takes about
    five.  PCQ takes about 15 seconds.
}

const
    Size = 8190;
    SizePL = Size + 1;

Var
    Flags : Array [0..SizePL] of Boolean;
    i, prime,
    k, count,
    iter  : Integer;
begin
    Writeln('10 iterations');
    for iter := 1 to 10 do begin
	count := 0;
	for i := 0 to Size do
	    flags[i] := true;
	for i := 0 to Size do begin
	    if flags[i] then begin
		prime := i+i+3;
		k := i + prime;
		while k <= size do begin
		    flags[k] := false;
		    k := k + prime;
		end;
		Inc(count);
	    end;
	end;
    end;
    Writeln(Count, ' primes');
end.

Program MakeChange;

{
    This program simply computes the number of coins you'll get in
    change for all possible purchase prices.  The idea is that if
    prices were evenly distributed, this program would compute the
    distribution of coins in your piggy bank.  Obviously prices are
    not evenly distributed - since they are normally .95 or .99, the
    price you pay after tax is most often in the lower half of the scale.
    That's why you end up with so many quarters.
}


Procedure Changer(Amount : Integer;
		var Quarters, Dimes, Nickels, Pennies : Short);
begin
    Amount := Amount mod 100;

    Quarters := Amount div 25;
    Amount   := Amount mod 25;

    Dimes    := Amount div 10;
    Amount   := Amount mod 10;

    Nickels  := Amount div 5;
    Amount   := Amount mod 5;

    Pennies  := Amount;
end;

var
    Amount : Integer;
    TotalQuarters,Quarters : Short;
    TotalDimes,Dimes : Short;
    TotalNickels,Nickels : Short;
    TotalPennies,Pennies : Short;
begin
    Amount := 0;
    TotalQuarters := 0;
    TotalDimes := 0;
    TotalNickels := 0;
    TotalPennies := 0;

    Writeln('Amount     Quarters   Dimes    Nickels   Pennies');
    Writeln('------------------------------------------------');

    while Amount < 100 do begin
	Changer(Amount,Quarters,Dimes,Nickels,Pennies);
	Writeln(Amount / 100.0:2:2, Quarters:10, Dimes:10,
			Nickels:10, Pennies:10);

	TotalQuarters := TotalQuarters + Quarters;
	TotalDimes    := TotalDimes + Dimes;
	TotalNickels  := TotalNickels + Nickels;
	TotalPennies  := TotalPennies + Pennies;
	Inc(Amount);
    end;

    Writeln('------------------------------------------------');
    Writeln('Totals:',TotalQuarters:8,
		TotalDimes:10,TotalNickels:10,TotalPennies:10);
end.

program Square;

var 
    tal : integer;

begin 
    writeln('The program calculates the square and the square-root from an integer.');
    write('Give an integer: ');
    readln(tal);
    writeln('Square = ',sqr(tal),' or ',tal*tal,' Square-root = ',sqrt(tal));
END.
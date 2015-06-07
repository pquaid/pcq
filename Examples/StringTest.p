program StringTest;

{
	This program excersises the revised StringLib a bit.  It's not
a complete suite of tests, but does test the most obvious stuff.
}

{$I "Include:Utils/StringLib.i"}

var
    str : String;

begin
    writeln("isupper('a') = ", isupper('a'));
    writeln("isupper('A') = ", isupper('A'));
    writeln("islower('r') = ", islower('r'));
    writeln("islower('E') = ", islower('E'));
    writeln("isalpha('E') = ", isalpha('E'));
    writeln("isalpha('t') = ", isalpha('t'));
    writeln("isalpha('4') = ", isalpha('4'));
    writeln("isdigit('4') = ", isdigit('4'));
    writeln("isdigit('r') = ", isdigit('r'));
    writeln("isdigit(' ') = ", isdigit(' '));
    writeln("isalnum('2') = ", isalnum('2'));
    writeln("isalnum('e') = ", isalnum('e'));
    writeln("isalnum('R') = ", isalnum('R'));
    writeln("isalnum('%') = ", isalnum('%'));
    writeln("isspace(#10) = ", isspace(Chr(10)));
    writeln("isspace('r') = ", isspace('r'));
    writeln("toupper('r') = ", toupper('r'));
    writeln("toupper('R') = ", toupper('R'));
    writeln("toupper('#') = ", toupper('#'));
    writeln("tolower('r') = ", tolower('r'));
    writeln("tolower('R') = ", tolower('R'));
    writeln("tolower('#') = ", tolower('#'));
    writeln('streq("The string", "The string") = ', streq("The string", "The string"));
    writeln('streq("The String", "The string") = ', streq("The String", "The string"));
    writeln('streq("The strings", "The string") = ', streq("The strings", "The string"));
    writeln('strieq("The string", "The string") = ', strieq("The string", "The string"));
    writeln('strieq("The String", "The string") = ', strieq("The StrinG", "The string"));
    writeln('strieq("The Strings", "The string") = ', strieq("The Strings", "The string"));
    writeln('strnieq("The string string", "The String",10) = ', strnieq("The string string", "The String", 10));
    writeln('strnieq("The string", "The string",50) = ', strnieq("The string", "The string",50));
    writeln('strnieq("The String", "THE string", 4) = ', strnieq("The string", "THE string",4));
    writeln('strcmp("abcde", "abcde") = ', strcmp("abcde", "abcde"));
    writeln('strcmp("abcde", "abcdef") = ', strcmp("abcde", "abcdef"));
    writeln('strcmp("abcde", "abcd") = ', strcmp("abcde", "abcd"));
    writeln('strcmp("abcde", "aacde") = ', strcmp("abcde", "aacde"));
    writeln('strcmp("abcde", "accde") = ', strcmp("abcde", "accde"));
    writeln('stricmp("AbCde", "aBcdE") = ', stricmp("AbCde", "aBcdE"));
    writeln('stricmp("AbCde", "AacdE") = ', stricmp("AbCde", "AacdE"));
    writeln('stricmp("AbCde", "aCCDe") = ', stricmp("AbCde", "aCCDe"));
    writeln('strlen("The string") = ', strlen("The string"));
    writeln('strlen("") = ', strlen(""));

    str := AllocString(80);
    strcpy(str, "The string in question");
    writeln('strcpy created ', str);
    strcpy(str, "The string");
    writeln('strcpy created ', str);
    strncpy(str, "The string in", 40);
    writeln('strncpy created ', str);
    strncpy(str, "The string in", 5);
    writeln('strncpy created ', str);

    strcat(str, " question");
    writeln('strcat created ', str);
    strcat(str, "");
    writeln('strcat created ', str);
    strncat(str, " is a goose.", 40);
    writeln('strncat created ', str);
    strncat(str, " More! More!", 5);
    writeln('strncat created ', str);

    writeln('strpos("The string", e) = ', strpos("The string" ,'e'));
    writeln('strpos("The string", T) = ', strpos("The string", 'T'));
    writeln('strpos("The string", g) = ', strpos("The string", 'g'));
    writeln('strpos("The string", x) = ', strpos("The string", 'x'));
    writeln('strrpos("The string", e) = ', strrpos("The string", 'e'));
    writeln('strrpos("The string", T) = ', strrpos("The string", 'T'));
    writeln('Strrpos("The string", g) = ', strrpos("The string", 'g'));
    writeln('strrpos("The string", x) = ', strrpos("The string", 'x'));
end.

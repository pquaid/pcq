{
     These are some of the common C string functions.
}

Function isupper(c : Char) : Boolean;
    External;
{
	Returns True if the character is in A..Z
}

Function islower(c : Char) : Boolean;
    external;
{
	Returns True if the character is in a..z
}

Function isalpha(c : Char) : Boolean;
    external;
{
	Returns True if the character is in A..Z or a..z
}

Function isdigit(c : Char) : Boolean;
    external;
{
	Returns True if the character is in 0..9
}

Function isalnum(c : Char) : Boolean;
    external;
{
	Returns True if isalpha or isdigit is true
}

Function isspace(c : Char) : Boolean;
    external;
{
	Returns true if the character is "white space", like a space,
form feed, line feed, carraige return, tab, whatever.
}

Function toupper(c : Char) : Char;
    external;
{
	If the character is in a..z, the function returns the capital.
Otherwise it returns c.
}

Function tolower(c : Char) : Char;
    external;
{
	If c is in A..Z, the function returns the lower case letter.
Otherwise it returns c.
}

Function streq(s1, s2 : String) : Boolean;
    external;
{
	Returns True if s1 and s2 are the same.
}

Function strneq(s1, s2 : String; n : Short) : Boolean;
    external;
{
	Returns True if the first n characters of s1 and s2 are identical.
}

Function strieq(s1, s2 : String) : Boolean;
    external;
{
	The same as streq(), but is case insensitive.
}

Function strnieq(s1, s2 : String; n : Short) : Boolean;
    external;
{
	The same as strneq(), but case insensitive.
}

Function strcmp(s1, s2 : String) : Integer;
    external;
{
	Returns an integer < 0 if s1 < s2, zero if they are equal, and > 0
if s1 > s2.  Note that the returned values in 1.0 were always -1, 0 and 1;
in version 1.1 that is no longer the case.
}

Function stricmp(s1, s2 : String) : Integer;
    external;
{
	The same as strcmp, but not case sensitive
}

Function strncmp(s1, s2 : String; n : Short) : Integer;
    external;
{
	Same as strcmp(), but only considers the first n characters.
}

Function strnicmp(s1, s2 : String; n : Short) : Integer;
    external;
{
	Same as strncmp, but not case sensitive
}

Function strlen(s : String) : Integer;
    external;
{
	Returns the number of characters in the string.  Note that you
need strlen(s) + 1 bytes to hold the string, since the trailing zero is
not counted in the length.
}

Procedure strcpy(s1, s2 : String);
    external;
{
	Copies s2 into s1, appending a trailing zero.  This is the same
as C, but opposite from 1.0.  Sorry about that...
}

Procedure strncpy(s1, s2 : String; n : Short);
    external;
{
	Copies s2 into s1, with a maximum of n characters.  Appends a
trailing zero.
}

Procedure strcat(s1, s2 : String);
    external;
{
	Appends s2 to the end of s1.
}

Procedure strncat(s1, s2 : String; n : Short);
    external;
{
	Appends at most n characters from s2 onto s1.
}

Function strdup(s : String) : String;
    External;
{
	This allocates a copy of the string 's', and returns a ptr
}

Function strpos(s1 : String; c : Char) : Integer;
    external;
{
	Return the position, starting at zero, of the first (leftmost)
occurance of c in s1.  If there is no c, it returns -1.
}

Function strrpos(s1 : String; c : Char) : Integer;
    external;
{
	Returns the integer position of the right-most occurance of c in s1.
If c is not in s1, it returns -1.
}

Function Hash(s : String) : Short;
    external;
{
	Returns the Hash value of s, computed like the AmigaDOS hash
function.  You will have to cut this value (using AND or MOD) down to
the size you need.
}

Function IntToStr(s : String; i : Integer) : Integer;
    External;
{
	Converts i to its character representation in s.  If i is
less than zero, it will start off with a minus sign.  There will
be no extra spaces before or after the number.  IntToStr returns
the length of the string created, which will be between 1 and 11.
}

Function AllocString(l : Integer) : String;
    external;
{
	Allocates l bytes, and returns a pointer to the allocated memory.
This memory is allocated through the new() function, so it will be returned
to the system at the end of your program.  Note that the proper amount of RAM
to allocate is strlen(s) + 1.
}

Procedure FreeString(s : String);
    external;
{
	This returns memory allocated by AllocString to the system.  Since
the Amiga is a multitasking computer, you should always return memory you
don't need to the system.
}


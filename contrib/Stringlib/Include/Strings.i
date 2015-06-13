{ This library includes many useful string functions and procedures.  Note
that you usually don't have to worry about allocating anything; that kind of
stuff is taken care of in the procedures.  On the other hand, many things
that might have been functions in the best of all worlds (such as SSlice)
are procedures, because it is a little harder to make sure everything is
allocated in a function and properly disposed of.  The order of the
following is really poor for reading, at least for a human; it is, however,
more pleasant for a Pascal compiler.  If you are a Pascal compiler, have
fun.  (Of course, you're not reading this, I hope.)  Otherwise, maybe you
should also look at the enclosed doc file--assuming I ever got around to
writing one.  You should have included StringLib.i *AND* Math.i BEFORE
this!  (Math.i is used in SEvalFloat.) }

const TAB =        9;
      EOLN =      10;
      ENDSTRING =  0;
      CARRET =    13;
      SPACE =     32;
      ESC =       27;

function SLen (s1: string): short;
  { Returns number of characters, not including \0 }

  var temp: string;  { just pointer }

  begin
    temp:=s1;
    while temp^<>chr(ENDSTRING) do
      temp:=string(integer(temp)+1);
    SLen:=short(temp)-short(s1)
    end { SLen };


function SChar (s1: string; position: short): char;
  { Returns a single character from the string }

  var temp: string;

  begin
    if (position<1) or (position>SLen(s1)) then SChar:=chr(ENDSTRING);
    temp:=string(integer(s1)+position-1);
    SChar:=temp^
    end { SChar };


function SEqual (s1, s2: string): boolean;
  { Tells if s1 and s2 are exactly equal }

  var t1, t2: string;  { pointers, not strings }

  begin
    t1:=s1;
    t2:=s2;
    if SLen(s1)<>SLen(s2) then SEqual:=FALSE;
    while (t1^<>chr(ENDSTRING)) and (t2^<>chr(ENDSTRING)) and (t1^=t2^) do begin
      t1:=string(integer(t1)+1);
      t2:=string(integer(t2)+1)
      end;
    if t1^<>chr(ENDSTRING) then SEqual:=FALSE else SEqual:=TRUE
    end { SEqual };

procedure SPlaceChar (var s1: string; position: short; c: char);
  { Places a single character at a specified position in an already-existent
    string.  Assumes string has been allocated at least that far; failure to
    have allocated that far can trash random memory dangerously. }

  var temp: string;

  begin
    temp:=string(integer(s1)+position-1);
    temp^:=c
    end { SPlaceChar };


procedure SAppend (var s1: string; s2, s3: string);
  { Makes s1 out of s2 and s3 concatenated together. }

  var i: short;  { index }
      c: char;
      temp: string;  { We build the result into a temp string because it may
                       turn out that s1 and s2 are the same, and to dispose
                       s1 may cause strange results; we don't dispose of its
                       current allocated memory until done building temp. }

  begin
    temp:=AllocString (Slen(s2)+SLen(s3)+1);  { Room for \0 }
    for i:=1 to SLen(s2) do
      SPlaceChar (temp, i, SChar(s2,i));
    for i:=1 to SLen(s3) do
      SPlaceChar (temp, i+SLen(s2), SChar(s3,i));
    SPlaceChar (temp, SLen(s2)+SLen(s3)+1, chr(ENDSTRING));
    { Now we can safely dispose of s1, as it has been copied to temp }
    FreeString (s1);
    s1:=temp
    end { SAppend };


procedure SBlank (var s1: string);
  { Makes s1 a null string }
  begin
    FreeString (s1);
    s1:=AllocString (1);
    s1^:=chr(ENDSTRING)
    end { SBlank };


procedure SAssign (var s1: string; s2: string);
  { Allocates s1 and copies s2 onto it }

  var t1: string;

  begin
    FreeString (s1);
    s1:=AllocString (SLen(s2)+1);  { Room for \0 too }
    t1:=s1;
    while s2^<>chr(ENDSTRING) do begin
      t1^:=s2^;
      t1:=string(integer(t1)+1);
      s2:=string(integer(s2)+1)
      end;
    t1^:=chr(ENDSTRING);
    end { SAssign };


procedure SUpper (var s1: string);
  { Converts s1 to all upper case, leaving nonalphabetical characters
    unchanged. }

  var t1: string;

  begin
    t1:=s1;
    while t1^<>chr(ENDSTRING) do begin
      if (t1^>='a') and (t1^<='z') then
          t1^:=chr(ord(t1^)+ord('A')-ord('a'));
      t1:=string(integer(t1)+1)
      end
    end { SUpper };


procedure SLower (var s1: string);
  { Converts s1 to all lower case, leaving nonalphabetical characters
    unchanged. }

  var t1: string;

  begin
    t1:=s1;
    while t1^<>chr(ENDSTRING) do begin
      if (t1^>='A') and (t1^<='Z') then
          t1^:=chr(ord(t1^)+ord('a')-ord('A'));
      t1:=string(integer(t1)+1)
      end
    end { SLower };


function SNoCaseEqual (s1, s2: string): boolean;
  { Tells if s1 and s2 are equal, ignoring case but watching length }

  var s3, s4: string;  { We simply use these to hold UPPER equivalents }
      temp: boolean;   { which we then compare instead }

  begin
    SAssign (s3, s1);
    SUpper (s3);
    SAssign (s4, s2);
    SUpper (s4);
    temp:=SEqual (s3, s4);
    FreeString (s3);
    FreeString (s4);
    SNoCaseEqual:=temp
    end { SNoCaseEqual };


procedure SAppendChar (var s1: string; c: char);
  { Appends a single character to a string; slightly more efficient than
    SAppend }

  var temp: string;
      i: short;

  begin
    temp:=AllocString (SLen(s1)+2);
    for i:=1 to SLen(s1) do
      SPlaceChar (temp, i, SChar(s1,i));
    SPlaceChar (temp, SLen(s1)+1, c);
    SPlaceChar (temp, SLen(s1)+2, chr(ENDSTRING));
    FreeString (s1);
    s1:=temp
    end { SAppendChar };


function ___H_e_x (c1, c2: char): short;
  { Internal function used by SSpecialChars; turns two-digit hex code into
    a short integer.  Any invalid character is treated as a zero. }

  var x1, x2: short;

  begin
    if (c1>='0') and (c1<='9') then x1:=ord(c1)-ord('0')
      else if (c1>='a') and (c1<='f') then x1:=ord(c1)-ord('a')+10
      else if (c1>='A') and (c1<='F') then x1:=ord(c1)-ord('A')+10
      else x1:=0;
    if (c2>='0') and (c2<='9') then x2:=ord(c2)-ord('0')
      else if (c2>='a') and (c2<='f') then x2:=ord(c2)-ord('a')+10
      else if (c2>='A') and (c2<='F') then x2:=ord(c2)-ord('A')+10
      else x2:=0;
    ___H_e_x:=x1*16+x2
    end { ___H_e_x };


procedure SSpecialChars (var s1: string);
  { Translates a string by replacing special 'exception sequences', much
    like the backslash sequences of C and PCQ-Pascal, into their appropriate
    characters.  Why not just use PCQ-Pascal's?  Well, there are more of
    these, including one that can be used for any character.  They use the
    tilde (~) as the exception character.  More interestingly, sort of,
    if you don't call this procedure, they are untranslated.  So there.
    Here they are:
    ~t    TAB        ~n   EOLN        ~~  TILDE          ~c  CARRET
    ~e    ESC        ~f   FORMFEED    ~0  ENDSTRING      ~q  QUOTE
    ~#    follow with two-digit hex of character code; i.e. the string to
          represent the paragraph sign is ~#B6
    If you want to add any other one-character ones like ~t, just add
    another
    else if c='?' then SAppendChar (temp,'?')
    line to the appropriate part of the code below.  Replace the question
    marks by the character to be translated from and to. }

  var i,j: short;  { indices of course }
      c, c2: char;
      temp: string;

  begin
    i:=1;
    SBlank(temp);
    while SChar(s1,i)<>chr(ENDSTRING) do begin
      c:=SChar(s1,i);
      if c<>'~' then
          SAppendChar (temp, c)
        else begin
          c:=SChar(s1,i+1);
          i:=i+1;
          if c='t' then SAppendChar (temp, chr(TAB))
            else if c='n' then SAppendChar (temp, chr(EOLN))
            else if c='~' then SAppendChar (temp, '~')
            else if c='c' then SAppendChar (temp, chr(CARRET))
            else if c='f' then SAppendChar (temp, chr(12))
            else if c='e' then SAppendChar (temp, chr(ESC))
            else if c='0' then SAppendChar (temp, chr(ENDSTRING))
            else if c='q' then SAppendChar (temp, '"')
            { insert any others in here, identically to above }
            else if c='#' then begin
                j:=___H_e_x (SChar(s1,i+1),SChar(s1,i+2));
                { the ___H_e_x routine is internal and thus oddly named }
                i:=i+2;
                SAppendChar (temp, chr(j))
                end { if c='#' }
            else SAppendChar (temp, c)
          end { if c<>'~' else };
      i:=i+1
      end { while };
    SAppendChar (temp, chr(ENDSTRING));
    FreeString (s1);
    s1:=temp
    end { SSpecialChars };


function SAlpha (s1, s2: string): short;
  { Returns -1 if s1<s2, 0 if s1=s2, 1 if s1>s2 in alpha order }
  { Note: at present, it seems that it ignores case anyway, though nothing
    in the program does so; it seems PCQ Pascal does so. }

  var i: short;  { index yet again }
      temp: short;  { result to be returned }
      c1, c2: char;  { characters being compared }

  begin
    i:=1;
    temp:=0;
    while (temp=0) and (SChar(s1,i)<>chr(ENDSTRING)) and (SChar(s2,i)<>chr(ENDSTRING)) do begin
      c1:=SChar(s1,i);
      c2:=SChar(s2,i);
      if c1<c2 then temp:=-1
        else if c1>c2 then temp:=1;
      i:=i+1
      end { while };
    if temp=0 then  { If all characters compared as equal, they may still }
      if SLen(s1)<SLen(s2) then temp:=-1   { be different sizes... }
        else if SLen(s1)>SLen(s2) then temp:=1;
    SAlpha:=temp
    end { SAlpha };


function SNoCaseAlpha (s1, s2: string): short;
  { As SAlpha, but ignores case; good for alphabetizing lists of names and
    such.  See also SDictionary. }

  var s3, s4: string;  { Of course, we simply call SAlpha on SUpper of the }
      temp: short;     { data we're given }

  begin
    SAssign (s3, s1);
    SUpper (s3);
    SAssign (s4, s2);
    SUpper (s4);
    temp:=SAlpha (s3, s4);
    FreeString (s3);
    FreeString (s4);
    SNoCaseAlpha:=temp
    end { SNoCaseAlpha };


function SLonger (s1, s2: string): boolean;
  { Tells if s1 is longer than s2 }
  begin
    SLonger:=(SLen(s1)>SLen(s2))
    end { SLonger };


procedure SAlphaNumerics (var s1: string);
  { Removes everything but letters and numbers; mostly used for SDictionary }

  var temp: string;  { result-to-be }
      i: short;     { can you guess? }
      c: char;

  begin
    SBlank(temp);
    for i:=1 to SLen(s1) do begin
      c:=SChar(s1,i);
      if ((c>='a') and (c<='z')) or ((c>='A') and (c<='Z')) or ((c>='0') and (c<='9')) then
        SAppendChar (temp, c)
      end { for };
    FreeString (s1);
    s1:=temp
    end { SAlphaNumerics };


function SDictionary (s1, s2: string): short;
  { As SAlpha, but returns "dictionary order"--i.e. ignore case and all
    non-letters.  That is, "i.e." comes between "id" and "Igor"; also,
    "American Association of Antelopes" is followed by "Americanism" and
    later by "American V.P.E.".  This is perhaps the best function to sort
    lists of words by, because hundreds of years of dictionary writing has
    born out the idea that it is easiest to use to look things up; it is
    a shame other languages and databases don't make it more easily
    available. }

  var s3, s4: string;  { Did you think we wouldn't use SAlpha? }
      temp: short;

  begin
    SAssign (s3, s1);
    SAlphaNumerics (s3);
    SUpper (s3);
    SAssign (s4, s2);
    SAlphaNumerics (s4);
    SUpper (s4);
    temp:=SAlpha (s3, s4);
    FreeString (s3);
    FreeString (s4);
    SDictionary:=temp
    end { SDictionary };


procedure SSlice (s1: string; left, right: short; var s2: string);
  { Slices characters from left to right inclusive and puts them in s2
    leaving s1 unharmed. }

  var i: short;

  begin
    if right>SLen(s1) then right:=SLen(s1);
    if left<1 then left:=1;
    FreeString(s2);
    s2:=AllocString(right-left+2);
    for i:=left to right do
      SPlaceChar (s2, i-left+1, SChar (s1,i));
    SPlaceChar (s2, right-left+2, chr(ENDSTRING))
    end { SSlice };


procedure SMid (s1: string; pos, length: short; var s2: string);
  { Just like SSlice, except you use position and length rather than
    start and end to specify the substring. }
  begin
    SSlice (s1, pos, pos+length-1, s2)
    end { SMid };


procedure SReplace (var s1: string; left, right: short; s2: string);
  { Replace from left to right inclusive of s1 with s2 (need not be same
    size). }

  var temp, s3: string;

  begin
    SSlice (s1, 1, left-1, temp);
    SAppend (temp, temp, s2);
    if right<SLen(s1) then begin
      SSlice (s1, right+1, SLen(s1), s3);
      SAppend (temp, temp, s3)
      end { if };
    FreeString (s1);
    s1:=temp
    end { SReplace };


procedure SCutOut (var s1: string; left, right: short);
  { As SReplace but simply removes offending characters. }

  var temp: string;

  begin
    SBlank(temp);
    SReplace (s1, left, right, temp)
    end { SCutOut };


function SSearch (s1, s2: string; start: short): short;
  { Finds s2 in s1 starting from at or after start, or 0 if not found }

  var i: short;
      temp: string;

  begin
    if SLen(s1)-SLen(s2)+1<start then SSearch:=0;
      { Can't find a longer string in a shorter one }
    for i:=start to SLen(s1)-SLen(s2)+1 do begin
      SMid (s1, i, SLen(s2), temp);
      if SEqual (s2, temp) then SSearch:=i
      end { for };
    SSearch:=0
    end { SSearch };


function SSearchChar (s1: string; c: char; start: short): short;
  { As SSearch but searches for a single character; much more efficient. }

  var t1: string;  { pointer }

  begin
    if start>SLen(s1) then SSearchChar:=0;
    t1:=string(integer(s1)+start-1);
    while (t1^<>c) and (t1^<>chr(ENDSTRING)) do
      t1:=string(integer(t1)+1);
    if t1^=c then SSearchChar:=short(t1)-short(s1)+1
             else SSearchChar:=0
    end { SSearchChar };


procedure STrim (var s1: string);
  { Removes leading and trailing spaces, tabs, EOLNs, CARRETs }

  var i: string;
      temp: string;

  begin
    i:=s1;
    while (i^=' ') or (i^=chr(TAB)) or (i^=chr(EOLN)) or (i^=chr(CARRET)) do
      i:=string(integer(i)+1);
    SAssign (temp, i);
    i:=temp;
    while (i^<>chr(ENDSTRING)) do
      i:=string(integer(i)+1);
    i:=string(integer(i)-1);
    while (i^=' ') or (i^=chr(TAB)) or (i^=chr(EOLN)) or (i^=chr(CARRET)) do
      i:=string(integer(i)-1);
    i:=string(integer(i)+1);   { i points to first white space char at end }
    i^:=chr(ENDSTRING);
    SAssign (s1,temp);
    i^:=' ';
    FreeString(temp)
    end { STrim };


procedure SFilter (var s1: string; fromchar, tochar: char);
  { Turns all occurrences of fromchar into tochar in string.  More efficient
    than SSearch and SReplace for single character filters. }

  var t1: string;

  begin
    t1:=s1;
    while t1^<>chr(ENDSTRING) do begin
      if t1^=fromchar then t1^:=tochar;
      t1:=string(integer(t1)+1)
      end { while }
    end { SFilter };


procedure STidy (var s1: string);
  { As STrim, plus collapses all white space into a single space }

  var i: short;

  begin
    STrim (s1);
    SFilter (s1, chr(TAB), ' ');
    SFilter (s1, chr(EOLN), ' ');
    SFilter (s1, chr(CARRET), ' ');
    i:=SSearch(s1,"  ",1);
    while i<>0 do begin
      SCutOut (s1, i, i);
      i:=SSearch(s1,"  ",1)
      end { while }
    end { STidy };


procedure SArgs (var s1: string; CommandLine: array [1..128] of char);
  { Copies command line into string }

  var i: short;

  begin
    SBlank (s1);
    i:=1;
    repeat
      SAppendChar (s1, CommandLine[i]);
      i:=i+1
      until CommandLine[i-1]=chr(ENDSTRING);
    end { SArgs };


function SEval (s1: string): short;
  { Translates string representation of an integer into the integer; returns
    0 if the string was an invalid integer; see SValidNum }

  var i, result: short;
      negative: boolean;
      c: char;
      temp: string;

  begin
    SAssign (temp, s1);
    STidy (temp);
    result:=0;
    i:=1;
    negative:=FALSE;
    if SChar(temp,i)='-' then begin
        negative:=TRUE;
        i:=i+1
        end { if }
      else if SChar(temp,i)='+' then begin
        negative:=FALSE;
        i:=i+1
        end { else if };
    c:=SChar(temp,i);
    while (c>='0') and (c<='9') do begin
      result:=result*10+ord(c)-ord('0');
      i:=i+1;
      c:=SChar(temp,i)
      end { while };
    FreeString (temp);
    if negative then result:=-result;
    SEval:=result
    end { SEval };


function SValidNum (s1: string): boolean;
  { Tells if a string holds a valid integer for use with SEval.  SEval only
    reads up to the first invalid character; that is, a valid number can
    be followed with any kind of nonsense, as long as it has one or more
    digits, optionally preceded by a plus or minus sign. }

  var temp: string;
      i: short;

  begin
    SAssign (temp, s1);
    STidy (temp);
    i:=1;
    if (temp^='+') or (temp^='-') then i:=2;
    if (SChar(temp, i)<'0') or (SChar(temp, i)>'9') then SValidNum:=FALSE
                                                    else SValidNum:=TRUE
    end { SValidNum };


function SEvalFloat (s1: string): real;
  { As SEval, but creates a float instead of a short.  Valid characters
    now include a decimal point, but no exponentiation characters.  We
    will have to wait until PCQ Pascal can deal with such floats before
    we will worry about them here. Both integer and fractional part, in
    the absence of the decimal point, must be shorts or smaller. }

  var temp, temp2: string;
      intpart, fracpart: short;
      fracbase: integer;
      i: short;
      c: char;
      decimal: short;

  begin
    SAssign (temp, s1);
    STidy (temp);
    i:=1;
    if (temp^='-') or (temp^='+') then i:=2;
    c:=SChar(temp,i);
    decimal:=0;
    while ((c='.') and (decimal=0)) or ((c>='0') and (c<='9')) do begin
      if c='.' then decimal:=i;
      i:=i+1;
      c:=SChar(temp,i)
      end { while };
    { Now decimal points to the decimal point (or 0 if there was none) and
      i points to the first invalid character (possibly ENDSTRING). }
    if decimal=0 then begin
        intpart:=SEval(temp);
        fracpart:=0;
        i:=1
        end { if }
      else begin
        SSlice (temp, 1, decimal-1, temp2);
        intpart:=SEval(temp2);
        SSlice (temp, decimal+1, i-1, temp2);
        fracpart:=SEval(temp2);
        i:=SLen(temp2)
        end { else };
    fracbase:=1;    { fracbase:=10^i }
    while i>=1 do begin
      fracbase:=fracbase*10;
      i:=i-1
      end { while };
    SEvalFloat:=spadd(spfloat(intpart),spdiv(spfloat(fracpart),spfloat(fracbase)))
    end { SEvalFloat };


procedure SEnscribe (n: short; var s1: string);
  { Makes a string version of the number in n, without any leading or
    trailing spaces }

  var k, digit: short;
      c: char;

  begin
    SBlank (s1);
    if n=0 then begin
        SAppendChar (s1, '0');
        return
        end { if n=0 }
      else begin
        if n<0 then begin
            SAppendChar (s1, '-');
            n:=-n
            end { if n<0 };
        k:=1;
        while k<=n do
          k:=k*10;
        k:=k div 10;
        while k>0 do begin
          digit:=n div k;
          n:=n-digit*k;
          c:=chr(digit+ord('0'));
          SAppendChar(s1,c);
          k:=k div 10
          end { while }
        end { else }
    end { SEnscribe };


function SNumOfWords (s1: string): short;
  { Tells how many words SParse will be able to find in the string. }

  var result: short;
      i, temp: string;

  begin
    SAssign (temp, s1);
    STidy (temp);
    if temp^=chr(ENDSTRING) then SNumOfWords:=0;
    result:=1;
    i:=temp;
    while i^<>chr(ENDSTRING) do begin
      if i^=' ' then result:=result+1;
      i:=string(integer(i)+1)
      end { while };
    SNumOfWords:=result
    end { SNumOfWords };


procedure SParse (s1: string; wordnum: short; var s2: string);
  { It finds the wordnum-th word in the string, and returns it in s2.
    Words are separated by spaces.  Applies STidy to copy of string first,
    then searches that copy (so as not to disturb original). }

  var i,l,r: short;
      temp: string;

  begin
    if SNumOfWords(s1)<wordnum then begin
        SBlank(s2);
        return
        end { if... };
    SAssign (temp, s1);
    STidy (temp);
    l:=1;
    if wordnum<>1 then
        for i:=1 to wordnum-1 do
          l:=SSearchChar (temp, ' ', l)+1;
    r:=SSearchChar (temp, ' ', l);
    if r=0 then r:=SLen(temp)+1;
    r:=r-1;
    SSlice (temp, l, r, s2);
    FreeString (temp)
    end { SParse };

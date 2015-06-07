{
	Random.p

	This implements a very long cycle random number generator
	by combining three independant generators.  The technique
	was described in the March 1987 issue of Byte.

	The source code for these routines is in Runtime/Extras
}


{   RealRandom returns a real value between 0 and 1 }

Function RealRandom : Real;
    External;


{ RangeRandom returns an integer value between 0 and MaxValue, inclusive }

Function RangeRandom(MaxValue : Integer) : Integer;
    External;


{ Sets the seeds to the value provided }

Procedure UseSeed(seed : Integer);
    External;


{ Sets the seeds according to the system clock }

Procedure SelfSeed;
    External;

{
	MathFFP.i for PCQ Pascal

	general floating point declarations.  Note that PCQ Pascal
	floating point math is handled entirely independent of any
	of these declarations.  It uses a different library pointer,
	for example, and all the calls are handled in-line rather
	than by calling these routines.  This is the library that is
	used, however.
}

Var
    MathBase	: Address;

Const

    PI		= 3.141592653589793;
    TWO_PI	= 2.0 * PI;
    PI2		= PI / 2.0;
    PI4		= PI / 4.0;
    E		= 2.718281828459045;
    LOG10	= 2.302585092994046;

    FPTEN	= 10.0;
    FPONE	= 1.0;
    FPHALF	= 0.5;
    FPZERO	= 0.0;

Function SPAbs(fnum : Real) : Real;
    External;

Function SPAdd(fnum1, fnum2 : Real) : Real;
    External;

Function SPCeil(fnum : Real) : Real;
    External;

Function SPCmp(fnum1, fnum2 : Real) : Short;
    External;

Function SPDiv(fnum1, fnum2 : Real) : Real;
    External;

Function SPFix(fnum : Real) : Integer;
    External;

Function SPFloor(fnum : Real) : Real;
    External;

Function SPFlt(inum : Integer) : Real;
    External;

Function SPMul(fnum1, fnum2 : Real) : Real;
    External;

Function SPNeg(fnum : Real) : Real;
    External;

Function SPSub(fnum1, fnum2 : Real) : Real;
    External;

Function SPTst(fnum : Real) : Short;
    External;


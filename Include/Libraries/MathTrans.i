{
	MathTrans.i for PCQ Pascal

	This file defines the routines available in the mathtrans
	library.  Some of them are also available within PCQ Pascal,
	but not all of them.   Remember that you'll need to open the
	library to get a valid value for MathTransBase.
}

Var
    MathTransBase	: Address;

Function SPAcos(fnum : Real) : Real;
    External;

Function SPAsin(fnum : Real) : Real;
    External;

Function SPAtan(fnum : Real) : Real;
    External;

Function SPCos(fnum : Real) : Real;
    External;

Function SPCosh(fnum : Real) : Real;
    External;

Function SPExp(fnum : Real) : Real;
    External;

Function SPFieee(ieeenum : Real) : Real;
    External;
	{ ieeenum is a single precision IEEE floating point number,
	  incompatible with PCQ Pascal's normal FFP reals }

Function SPLog(fnum : Real) : Real;
    External;

Function SPLog10(fnum : Real) : Real;
    External;

Function SPPow(fnum1, fnum2 : Real) : Real;
    External;

Function SPSin(fnum : Real) : Real;
    External;

Function SPSincos(VAR cosine : Real; x : Real) : Real;
    External;

Function SPSinh(fnum : Real) : Real;
    External;

Function SPSqrt(fnum : Real) : Real;
    External;

Function SPTan(fnum : Real) : Real;
    External;

Function SPTieee(fnum : Real) : Real;
    External;
	{ Note: This routine returns a single precision IEEE
		floating point value that is incompatible with
		PCQ's FFP real values }



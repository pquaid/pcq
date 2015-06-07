{
	Resources.i of PCQ Pascal

	This file defines the Exec resource routines.
}

TYPE
    ResourcePtr = Address;

Procedure AddResource(resource : ResourcePtr);
    External;

Function OpenResource(resName : String) : ResourcePtr;
    External;

Procedure RemResource(resource : ResourcePtr);
    External;


{
    PCQMemory.i of PCQ Pascal

    These routines allocate and deallocate so-called PCQ memory
    from the system.  They are included for compatibility with
    Turbo Pascal, and in future versions of PCQ they'll be
    standard procedures.
}


{
    Allocate some system memory, and place the result in p.
}

Procedure GetMem(var p : Address; Size : Integer);
    External;

{
    Free some memory allocated through GetMem
}

Procedure FreePCQMem(var p : Address; Size : Integer);
    External;



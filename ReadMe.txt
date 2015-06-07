
               PCQ Pascal version 1.2d (registered)
                         by Patrick Quaid

These two disks contain the registered version of PCQ Pascal.
None of the files on the first disk should be distributed, but all
of the files on the second can be.  In particular, there is a copy
of the unregistered release of PCQ Pascal (version 1.2b) on the
second disk.

There are six archives on the first disk.  They are:


    PCQ12d.LZH      This archive contains the following files:

        Pascal          The compiler itself
        Peep            The peephole optimizer
        PCQ.lib         The runtime library
        OMake           A script to automate compilations
        Make            Another script to automate the process
        PCQ.ced         An Arexx program that compiles,
                        optimizes, assembles and links a
                        program from CygnusEd Professional.

    Include.LZH     This archive contains all the Amiga include
                    files.

    Examples.LZH    This archive contains 38 (at last count)
                    example programs that demonstrate how to
                    access Amiga features from PCQ Pascal.

    Docs.LZH        This archive contains the following files:

        Pascal.DOC      The main documentation file for the
                        compiler.
        PCQ.lib.DOC     A description of every routine defined
                        internally in PCQ Pascal or in the
                        Include:Utils directory (140 functions in
                        all).
        dme.refs        An index of PCQ.lib.DOC to use with Matt
                        Dillon's DME text editor, or any other
                        program that supports its REF format.
        PCQ.DOC         Documentation for the PCQ make utility.
        IDList          A list that shows every identifier defined
                        in the include files.  It shows the type
                        as well as the file in which it is defined.

    PCQ.LZH         This archive contains the following files:

        PCQ             A make utility that automates the compile-
                        optimize-assemble-link process.
        PCQ.p           The source code for PCQ.
        CompErrors      An error handler (an AmigaDOS batch file)
                        for errors detected during compilation.
        OptErrors       An error handler for errors detected
                        during the optimization step.
        AssemErrors     An error handler for errors detected
                        during assembly.
        LinkError       The error handler for errors detected
                        while linking.
        CED-ShowError   A more sophisticated compiler error
                        handler for users with Arexx and CygnusEd
                        Professional.
        DME-Error       Another compiler error handler for users
                        with Arexx and Matt Dillon's DME text editor.
        DME-ShowError   An Arexx program that is part of DME's
                        compiler error handler.
        QED-ShowError   An error handler for users with Arexx and
                        the QED text editor.
	EMACS-ShowError An error handler for users of Daniel
                        Lawrence's MicroEMACS (Arexx is not needed
                        for this one).
        EMACS.errors    The second part of the EMACS error handler,
                        which should be attached to the end of the
                        MicroEMACS configuration file EMACS.RC.
	MEMACS-ShowError
                        This Arexx program is the error handler
                        for users with Arexx and Commodore's own
                        MEMACS text editor.


    Runtime.LZH     This archive contains the entire source, in
                    Pascal and assembly language, of the runtime
                    library PCQ.lib.



The second disk contains files that are all freely
redistributable.  They are:


    A68k271.LZH     This archive contains version 2.71 of Charlie
                    Gibbs' assembler, with documentation.  It
                    includes the following files:

        A68k            The assembler itself.
        A68k.DOC        Documentation for the assembler.
        History.log     All the changes made to A68k.


    Blink67.LZH     This archive contains version 6.7 of the
                    Software Distillery's linker Blink.  It
                    includes the following files:

        Blink           The linker itself.
        Blink.DOC       Documentation for the linker.


    Debugger.LZH    This archive contains version 2.10 of SLADE
                    software's very useful assembly level,
                    symbolic debugger.  It includes the following
                    files:

        Debug           The debugger itself.
        DebugDoc        Documentation for the debugger.
        ChangesFrom1.0  An update history.
        Syntax          A BNF grammar for the expressions
                        acceptable to Debug.


    Mon.LZH         This archive contains an assembly-level
                    monitor.  It is similar to Debug, but does not
                    use symbolic information.  It does, however,
                    work on 68020 and 68030 machines, which Debug
                    can't.  The archive includes:

        Mon             The monitor itself.
        Mon.doc         Documentation for the monitor.
        PatchTrace      A program to fix a problem with some
                        instructions (see Mon.doc).
        POSTER          A copy of the usenet post.


    PCQ12b.LZH      This archive is the freely distributable,
                    unregistered version of the compiler.  If you
                    would like to pass around a copy of PCQ
                    Pascal, please use this file.  All of the
                    files on the other disk are for registered
                    users only.


If you would like to contact me, I can be reached at:

Patrick Quaid
2250 Clarendon Blvd, Apt 1209
Arlington, VA 22201
USA

Telephone: (703) 524-8945

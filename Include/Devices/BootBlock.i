{
	Bootblock.i for PCQ Pascal

	The Bootblock definition
}

type
    BootBlock = record
	bb_id		: Array [0..3] of Byte;	{ 4 character identifier }
	bb_chksum	: Integer;		{ boot block checksum (balance) }
	bb_dosblock	: Integer;		{ reserved for DOS patch }
    end;
    BootBlockPtr = ^BootBlock;

const
    BOOTSECTS	= 2;	{ 1K bootstrap }

    BBID_DOS	= 'DOS\0';
    BBID_KICK	= 'KICK';

    BBNAME_DOS	= $444F5300;    { DOS\0 as an Integer }
    BBNAME_KICK	= $4B49434B;	{ KICK as an Integer }


{
    ConfigVars.i for PCQ Pascal

	software structures for configuration subsystem
}

{$I "Include:Exec/Nodes.i"}
{$I "Include:Libraries/ConfigRegs.i"}


Type

    ConfigDev = record
	cd_Node		: Node;
	cd_Flags	: Byte;
	cd_Pad		: Byte;
	cd_Rom		: ExpansionRom;	{ image of expansion rom area }
	cd_BoardAddr	: Address;	{ where in memory the board is }
	cd_BoardSize	: Integer;	{ size in bytes }
	cd_SlotAddr	: Short;	{ which slot number }
	cd_SlotSize	: Short;	{ number of slots the board takes }
	cd_Driver	: Address;	{ pointer to node of driver }
	cd_NextCD	: ^ConfigDev;	{ linked list of drivers to config }
	cd_Unused	: Array [0..3] of Integer;
					{ for whatever the driver whats }
    end;
    ConfigDevPtr = ^ConfigDev;


Const

{ cd_Flags }
    CDB_SHUTUP		= 0;	{ this board has been shut up }
    CDB_CONFIGME	= 1;	{ this board needs a driver to claim it }

    CDF_SHUTUP		= $01;
    CDF_CONFIGME	= $02;

Type

{ this structure is used by GetCurrentBinding() and SetCurrentBinding() }

    CurrentBinding = record
	cb_ConfigDev	: ConfigDevPtr;		{ first configdev in chain }
	cb_FileName	: String;		{ file name of driver }
	cb_ProductString : String;		{ product # string }
	cb_ToolTypes	: Address;		{ tooltypes from disk object }
    end;
    CurrentBindingPtr = ^CurrentBinding;

Procedure AddConfigDev(configDev : ConfigDevPtr);
    External;

Function AllocConfigDev : ConfigDevPtr;
    External;

Function ConfigBoard(board : Address; configDev : ConfigDevPtr) : Boolean;
    External;

Function ConfigChain(baseAddr : Address) : Boolean;
    External;

Function FindConfigDev(oldConfigDev : ConfigDevPtr;
			manufacturer, product : Integer) : ConfigDevPtr;
    External;

Procedure FreeConfigDev(configDev : ConfigDevPtr);
    External;

Function GetCurrentBinding(currentBinding : CurrentBindingPtr;
				size : Short) : Short;
    External;

Procedure ObtainConfigBinding;
    External;

Procedure ReleaseConfigBinding;
    External;

Procedure RemConfigDev(configDev : ConfigDevPtr);
    External;

Procedure SetCurrentBinding(currentBinding : CurrentBindingPtr;
				size : Short);
    External;


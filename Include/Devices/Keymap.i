{
	Keymap.i for PCQ Pascal

	keymap.resource definitions and console.device key map definitions
}

{$I "Include:Exec/Nodes.i"}
{$I "Include:Exec/Lists.i"}

Type

    KeyMap = record
	km_LoKeyMapTypes	: Address;
	km_LoKeyMap		: Address;
	km_LoCapsable		: Address;
	km_LoRepeatable		: Address;
	km_HiKeyMapTypes	: Address;
	km_HiKeyMap		: Address;
	km_HiCapsable		: Address;
	km_HiRepeatable		: Address;
    end;
    KeyMapPtr = ^KeyMap;


    KeyMapNode = record
	kn_Node		: Node;		{ including name of keymap }
	kn_KeyMap	: KeyMap;
    end;
    KeyMapNodePtr = ^KeyMapNode;

{ the structure of keymap.resource }

    KeyMapResource = record
	kr_Node		: Node;
	kr_List		: List;		{ a list of KeyMapNodes }
    end;
    KeyMapResourcePtr = ^KeyMapResource;


Const

{ Key Map Types }

    KC_NOQUAL		= 0;
    KC_VANILLA		= 7;	{ note that SHIFT+ALT+CTRL is VANILLA }
    KCB_SHIFT		= 0;
    KCF_SHIFT		= $01;
    KCB_ALT		= 1;
    KCF_ALT		= $02;
    KCB_CONTROL		= 2;
    KCF_CONTROL		= $04;
    KCB_DOWNUP		= 3;
    KCF_DOWNUP		= $08;

    KCB_DEAD		= 5;	{ may be dead or modified by dead key:	}
    KCF_DEAD		= $20;	{   use dead prefix bytes		}

    KCB_STRING		= 6;
    KCF_STRING		= $40;

    KCB_NOP		= 7;
    KCF_NOP		= $80;


{ Dead Prefix Bytes }

    DPB_MOD		= 0;
    DPF_MOD		= $01;
    DPB_DEAD		= 3;
    DPF_DEAD		= $08;

    DP_2DINDEXMASK	= $0f;	{ mask for index for 1st of two dead keys }
    DP_2DFACSHIFT	= 4;	{ shift for factor for 1st of two dead keys }


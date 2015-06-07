{
	Layers.i for PCQ Pascal
}

{$I "Include:Exec/Lists.i"}
{$I "Include:Exec/Semaphores.i"}

var
    LayersBase	: Address;

const

    LAYERSIMPLE		= 1;
    LAYERSMART		= 2;
    LAYERSUPER		= 4;
    LAYERUPDATING	= $10;
    LAYERBACKDROP	= $40;
    LAYERREFRESH	= $80;
    LAYER_CLIPRECTS_LOST = $100;	{ during BeginUpdate }
					{ or during layerop }
					{ this happens if out of memory }
    LMN_REGION		= -1;

type

    Layer_Info = record
	top_layer	: Address;	{ LayerPtr }
	check_lp	: Address;	{ (LayerPtr) system use }
	obs		: Address;	{ (LayerPtr) system use }
	FreeClipRects	: MinList;
	Lock		: SignalSemaphore;
	gs_Head		: List;		{ system use }
	longreserved	: Integer;
	Flags		: Short;
	fatten_count	: Byte;
	LockLayersCount	: Byte;
	LayerInfo_extra_size : Short;
	blitbuff	: Address;
	LayerInfo_extra	: Address;
    end;
    Layer_InfoPtr = ^Layer_Info;

const

    NEWLAYERINFO_CALLED	= 1;
    ALERTLAYERSNOMEM	= $83010000;

Function BeginUpdate(l : LayerPtr): Boolean;
    External;

Function BehindLayer(l : LayerPtr) : Boolean;
    External;

Function CreateBehindLayer(li : Layer_InfoPtr; bm : Address;
			   x0,y0,x1,y1 : Integer; flags : Integer;
			   bm2 : Address) : LayerPtr;
    External;

Function CreateUpfrontLayer(li : Layer_InfoPtr; bm : Address;
			    x0,y0,x1,y1 : Integer; flags : Integer;
			    bm2 : Address) : LayerPtr;
    External;

Function DeleteLayer(l : LayerPtr) : Boolean;
    External;

Procedure DisposeLayerInfo(li : Layer_InfoPtr);
    External;

Procedure EndUpdate(l : LayerPtr; flag : Boolean);
    External;

Function InstallClipRegion(l : LayerPtr; region : Address) : Address;
    External;	{ both Address's are RegionPtr }

Procedure LockLayer(l : LayerPtr);
    External;

Procedure LockLayerInfo(li : Layer_InfoPtr);
    External;

Procedure LockLayers(li : Layer_InfoPtr);
    External;

Function MoveLayer(l : LayerPtr; dx, dy : Integer) : Boolean;
    External;

Function MoveLayerInFrontOf(layertomove, targetlayer : LayerPtr) : Boolean;
    External;

Function NewLayerInfo : Layer_InfoPtr;
    External;

Procedure ScrollLayer(l : LayerPtr; dx, dy : Integer);
    External;

Function SizeLayer(l : LayerPtr; dx, dy : Integer) : Boolean;
    External;

Procedure SwapBitsRastPortClipRect(rp : Address; cr : Address);
    External;	{ rp is a RastPortPtr }
		{ cr is a ClipRectPtr }

Procedure UnlockLayer(l : LayerPtr);
    External;

Procedure UnlockLayerInfo(li : Layer_InfoPtr);
    External;

Procedure UnlockLayers(li : Layer_InfoPtr);
    External;

Function UpfrontLayer(l : LayerPtr) : Boolean;
    External;

Function WhichLayer(li : Layer_InfoPtr; x, y : Integer) : LayerPtr;
    External;


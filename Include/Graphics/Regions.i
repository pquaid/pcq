{
    Regions.i for PCQ Pascal
}

{$I "Include:Graphics/GFX.i"}

type

    RegionRectangle = record
	Next,
	Prev	: ^RegionRectangle;
	bounds	: Rectangle;
    end;
    RegionRectanglePtr = ^RegionRectangle;

    Region = record
	bounds	: Rectangle;
	RegionRectangle : RegionRectanglePtr;
    end;
    RegionPtr = ^Region;

Procedure AndRectRegion(region : RegionPtr; rect : RectanglePtr);
    External;

Function AndRegionRegion(region1, region2 : RegionPtr) : Boolean;
    External;

Function ClearRectRegion(region : RegionPtr; rect : RectanglePtr) : Boolean;
    External;

Procedure ClearRegion(region : RegionPtr);
    External;

Procedure DisposeRegion(region : RegionPtr);
    External;

Function NewRegion : RegionPtr;
    External;

Function OrRectRegion(region : RegionPtr; rectangle : RectanglePtr) : Boolean;
    External;

Function OrRegionRegion(region1, region2 : RegionPtr) : Boolean;
    External;

Function XorRectRegion(region : RegionPtr; rect : RectanglePtr) : Boolean;
    External;

Function XorRegionRegion(region1, region2 : RegionPtr) : Boolean;
    External;


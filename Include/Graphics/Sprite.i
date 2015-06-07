{
    Sprite.i for PCQ Pascal
}

const

    SPRITE_ATTACHED	= $80;

type

    SimpleSprite = record
	posctldata	: Address;
	height		: Short;
	x,y		: Short;	{ current position }
	num		: Short;
    end;
    SimpleSpritePtr = ^SimpleSprite;

Procedure ChangeSprite(vp : Address; s : SimpleSpritePtr; newData : Address);
    External;	{ vp is a ViewPortPtr }

Procedure FreeSprite(pick : Short);
    External;

Function GetSprite(sprite : SimpleSpritePtr; pick : Short) : Short;
    External;

Procedure MoveSprite(vp : Address; sprite : SimpleSpritePtr; x, y : Short);
    External;	{ vp is a ViewPortPtr }


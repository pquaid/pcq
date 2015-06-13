{

	IFF.i for PCQ Pascal.

	Cat'sEye

	Any IFF reader might as well include this, as all these Types
	and Consts can't hurt.

}

{$I "Include:Libraries/DOS.i"}

	{ --- All IFF's --- }

Const
 	ID_FORM = $464f524d;
	ID_LIST = $4c495354;
	ID_PROP = $50524f50;
	ID_CAT  = $43415420;	{ my personal fave }
	ID_FILLER = $20202020;

Type
	Chunk = record
		ckID,
		ckSize		: Integer;
	end;

	{ --- ACBM --- }

Const

	ID_ACBM = $4143424d;

	ID_ABIT = $41424954;

	{ --- ILBM --- }

Const
	ID_ILBM = $494c424d;

	ID_BMHD = $424d4844;
	ID_CAMG = $43414d47;
	ID_CMAP = $434d4150;
	ID_BODY	= $424f4459;
	ID_GRAB = $47534142;
	ID_DEST = $44455354;
	ID_SPRT = $53505254;
	ID_CRNG = $43524e47;
	ID_CCRT = $43435254;

	cmpNone		= 0;
	cmpByteRun1	= 1;

	mskNone		= 0;
	mskHasMask	= 1;
	mskHasTransparentColor
			= 2;
	mskLasso	= 3;

Type
	BitMapHeader = record
		w,
		h,
		x,
		y		: Short;
		nPlanes,
		masking,
		compression,
		pad1		: Byte;
		transparentcolor
				: Short;
		xAspect,
		yAspect		: Byte;
		pageWidth,
		pageHeight	: Short;
	end;

	Point2D = record
		x, y		: Short;
	end;

	DestMerge = record
		depth,
		pad1		: Byte;
		planePick,
		PlaneOnOff,
		planeMask	: Short;
	end;

	CRange = record
		pad1,
		rate,
		flags		: Short;
		low,
		high		: Byte;
	end;

	CycleInfo = record
		direction	: Short;
		Start,
		C_End		: Byte;		{ used to be "end" }
		Seconds,
		Microseconds	: Integer;
		Pad		: Short;
	end;

	{ --- FTXT --- }

Const

	ID_FTXT = $46545854;

	ID_CHRS = $43485253;
	ID_FONS = $464f4e53;

Type

	FontSpecifier = record
		id,
		pad1,
		proportional,
		serif		: Byte;		{ name[] is omitted }
	end;

	{ --- SMUS --- }

Const

	ID_SMUS = $534d5553;

	ID_SHDR = $53484452;
	ID_TRAK = $5452414b;
	ID_INS1 = $494e5331;

	ID_NAME = $4e414d45;
	ID_copyright
		= $28632920;
	ID_AUTH = $41555448;
	ID_ANNO = $414e4e4f;


	INS1_Name	= 0;
	INS1_MIDI	= 1;

	sID_FirstNote	= 0;
	sID_Mark	= 255;

	{ Pardon my omission of noteChord et al. I need this not }

Type

	SScoreHeader = record
		tempo			: Short;
		volume,
		ctTrack			: Byte;
	end;

	RefInstrument = record
		register,
		RItype,
		data1, data2		: Byte;	{ name has been omitted }
	end;

	SEvent = record
		sID,
		Data			: Byte;
		end;

	sIDType = (sID_LastNote, 
		sID_Rest,
		sID_Instrument,
		sID_TimeSig,
		sID_KeySig,
		sID_Dynamic,
		sID_MIDI_Chnl,
		sID_MIDI_Preset,
		sID_Clef,
		sID_Tempo);

	{ adding 127 to the above list gives you various sID codes }

	{ --- 8SVX --- }

Const

	ID_8SVX = $38535658;

	ID_VHDR = $56484452;
	ID_ATAK = $4154414b;
	ID_RLSE = $524c5345;
	ID_CHAN = $4348414e;
	ID_PAN  = $50414e20;

	sCmpNone	= 0;
	sCmpFibDelta	= 1;

Type
	Voice8Header = record
		oneShotHiSamples,
		repeatHiSamples,
		samplesPerHiCycle	: Integer;
		samplesPerSec		: Short;
		ctOctave,
		sCompression		: Byte;
		volume			: Integer;
	end;

	EGPoint = record
		duration		: Short;
		dest			: Integer;
	end;
{
Procedure DoRead (F : FileHandle; Buffer : Address; Length : Integer);
	External;
Procedure ReadJunk (F : FileHandle);
	External;
}
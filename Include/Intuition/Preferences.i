{
	Preferences.i for PCQ Pascal
}

{$I "Include:Devices/Timer.i"}

{ ======================================================================== }
{ === Preferences ======================================================== }
{ ======================================================================== }

Const

{ these are the definitions for the printer configurations }
    FILENAME_SIZE	= 30;		{ Filename size }

    POINTERSIZE		= (1 + 16 + 1) * 2;	{ Size of Pointer data buffer }

{ These defines are for the default font size.	 These actually describe the
 * height of the defaults fonts.  The default font type is the topaz
 * font, which is a fixed width font that can be used in either 
 * eighty-column or sixty-column mode.	The Preferences structure reflects
 * which is currently selected by the value found in the variable FontSize,
 * which may have either of the values defined below.  These values actually
 * are used to select the height of the default font.  By changing the
 * height, the resolution of the font changes as well.
 }
    TOPAZ_EIGHTY	= 8;
    TOPAZ_SIXTY 	= 9;

Type

    Preferences = record
    { the default font height }
	FontHeight	: Byte;		{ height for system default font  }

    { constant describing what's hooked up to the port }
	PrinterPort	: Byte;		{ printer port connection     }

    { the baud rate of the port }
	BaudRate	: Short;	{ baud rate for the serial port   }
    
    { various timing rates }
	KeyRptSpeed	: timeval;	{ repeat speed for keyboard       }
	KeyRptDelay	: timeval;	{ Delay before keys repeat	       }
	DoubleClick	: timeval;	{ Interval allowed between clicks }

    { Intuition Pointer data }
	PointerMatrix	: Array [0..POINTERSIZE-1] of Short;
					{ Definition of pointer sprite	   }
	XOffset		: Byte;		{ X-Offset for active 'bit'       }
	YOffset		: Byte;		{ Y-Offset for active 'bit'       }
	color17		: Short;	{*********************************}
	color18		: Short;	{ Colours for sprite pointer      }
	color19		: Short;	{*********************************}
	PointerTicks	: Short;	{ Sensitivity of the pointer	   }

    { Workbench Screen colors }
	color0		: Short;	{*********************************}
	color1		: Short;	{   Standard default colours      }
	color2		: Short;	{   Used in the Workbench         }
	color3		: Short;	{*********************************}

    { positioning data for the Intuition View }
	ViewXOffset	: Byte;		{ Offset for top lefthand corner  }
	ViewYOffset	: Byte;		{ X and Y dimensions	       }
	ViewInitX,
	ViewInitY	: Short;	{ View initial offset values      }

	EnableCLI	: Boolean;	{ CLI availability switch }

    { printer configurations }
	PrinterType	: Short;	{ printer type			   }
	PrinterFilename	: Array [0..FILENAME_SIZE-1] of Char;
					{ file for printer	   }

    { print format and quality configurations }
	PrintPitch	: Short;	{ print pitch		   }
	PrintQuality	: Short;	{ print quality	   }
	PrintSpacing	: Short;	{ number of lines per inch    }
	PrintLeftMargin	: Short;	{ left margin in characters	   }
	PrintRightMargin : Short;	{ right margin in characters	   }
	PrintImage	: Short;	{ positive or negative	       }
	PrintAspect	: Short;	{ horizontal or vertical      }
	PrintShade	: Short;	{ b&w, half-tone, or color    }
	PrintThreshold	: Short;	{ darkness ctrl for b/w dumps	   }

    { print paper descriptors }
	PaperSize	: Short;	{ paper size		   }
	PaperLength	: Short;	{ paper length in number of lines }
	PaperType	: Short;	{ continuous or single sheet	   }

    { Serial device settings: These are six nibble-fields in three bytes }
    { (these look a little strange so the defaults will map out to zero) } 
	SerRWBits	: Byte;
			     { upper nibble = (8-number of read bits)	  }
			     { lower nibble = (8-number of write bits)	  }
	SerStopBuf	: Byte;
			     { upper nibble = (number of stop bits - 1)  }
			     { lower nibble = (table value for BufSize)  }
	SerParShk	: Byte;
			     { upper nibble = (value for Parity setting) }
			     { lower nibble = (value for Handshake mode) }
	LaceWB		: Byte;		{ if workbench is to be interlaced      }

	WorkName	: Array [0..FILENAME_SIZE-1] of Char;
					{ temp file for printer		}

	RowSizeChange	: Byte;
	ColumnSizeChange : Byte;

	PrintFlags	: Short;	{ user preference flags }
	PrintMaxWidth	: Short;	{ max width of printed picture in 10ths/inch }
	PrintMaxHeight	: Short;	{ max height of printed picture in 10ths/inch }
	PrintDensity	: Byte;		{ print density }
	PrintXOffset	: Byte;		{ offset of printed picture in 10ths/inch }

	wb_Width	: Short;	{ override default workbench width	 }
	wb_Height	: Short;	{ override default workbench height }
	wb_Depth	: Byte;		{ override default workbench depth	 }

	ext_size	: Byte;		{ extension information -- do not touch! }
			    { extension size in blocks of 64 bytes }
    end;
    PreferencesPtr = ^Preferences;

Const

{ Workbench Interlace (use one bit) }
    LACEWB		= $01;
    LW_RESERVED		= 1;	 { internal use only }

{ PrinterPort }
    PARALLEL_PRINTER 	= $00;
    SERIAL_PRINTER	= $01;

{ BaudRate }
    BAUD_110    	= $00;
    BAUD_300    	= $01;
    BAUD_1200   	= $02;
    BAUD_2400   	= $03;
    BAUD_4800   	= $04;
    BAUD_9600   	= $05;
    BAUD_19200  	= $06;
    BAUD_MIDI   	= $07;

{ PaperType }
    FANFOLD		= $00;
    SINGLE		= $80;

{ PrintPitch }
    PICA		= $000;
    ELITE		= $400;
    FINE		= $800;

{ PrintQuality }
    DRAFT		= $000;
    LETTER		= $100;

{ PrintSpacing }
    SIX_LPI		= $000;
    EIGHT_LPI		= $200;

{ Print Image }
    IMAGE_POSITIVE	= $00;
    IMAGE_NEGATIVE	= $01;

{ PrintAspect }
    ASPECT_HORIZ	= $00;
    ASPECT_VERT 	= $01;

{ PrintShade }
    SHADE_BW		= $00;
    SHADE_GREYSCALE	= $01;
    SHADE_COLOR		= $02;

{ PaperSize }
    US_LETTER		= $00;
    US_LEGAL		= $10;
    N_TRACTOR		= $20;
    W_TRACTOR		= $30;
    CUSTOM_PAPER	= $40;

{ PrinterType }
    CUSTOM_NAME		= $00;
    ALPHA_P_101		= $01;
    BROTHER_15XL	= $02;
    CBM_MPS1000		= $03;
    DIAB_630		= $04;
    DIAB_ADV_D25	= $05;
    DIAB_C_150		= $06;
    EPSON		= $07;
    EPSON_JX_80		= $08;
    OKIMATE_20		= $09;
    QUME_LP_20		= $0A;
{ new printer entries, 3 October 1985 }
    HP_LASERJET		= $0B;
    HP_LASERJET_PLUS	= $0C;

{ Serial Input Buffer Sizes }
    SBUF_512		= $00;
    SBUF_1024		= $01;
    SBUF_2048		= $02;
    SBUF_4096		= $03;
    SBUF_8000		= $04;
    SBUF_16000		= $05;

{ Serial Bit Masks }
    SREAD_BITS		= $F0;		{ for SerRWBits   }
    SWRITE_BITS		= $0F;

    SSTOP_BITS		= $F0;		{ for SerStopBuf  }
    SBUFSIZE_BITS	= $0F;

    SPARITY_BITS	= $F0;		{ for SerParShk }
    SHSHAKE_BITS	= $0F;

{ Serial Parity (upper nibble, after being shifted by
 * macro SPARNUM() )
 }
    SPARITY_NONE	= 0;
    SPARITY_EVEN	= 1;
    SPARITY_ODD		= 2;

{ Serial Handshake Mode (lower nibble, after masking using 
 * macro SHANKNUM() )
 }
    SHSHAKE_XON		= 0;
    SHSHAKE_RTS		= 1;
    SHSHAKE_NONE	= 2;

{ new defines for PrintFlags }

    CORRECT_RED		= $0001;	{ color correct red shades }
    CORRECT_GREEN	= $0002;	{ color correct green shades }
    CORRECT_BLUE	= $0004;	{ color correct blue shades }

    CENTER_IMAGE	= $0008;	{ center image on paper }

    IGNORE_DIMENSIONS	= $0000;	{ ignore max width/height settings }
    BOUNDED_DIMENSIONS	= $0010;	{ use max width/height as boundaries }
    ABSOLUTE_DIMENSIONS	= $0020;	{ use max width/height as absolutes }
    PIXEL_DIMENSIONS	= $0040;	{ use max width/height as prt pixels }
    MULTIPLY_DIMENSIONS	= $0080;	{ use max width/height as multipliers }

    INTEGER_SCALING	= $0100;	{ force integer scaling }

    ORDERED_DITHERING	= $0000;	{ ordered dithering }
    HALFTONE_DITHERING	= $0200;	{ halftone dithering }
    FLOYD_DITHERING	= $0400;	{ Floyd-Steinberg dithering }

    ANTI_ALIAS		= $0800;	{ anti-alias image }
    GREY_SCALE2		= $1000;	{ for use with hi-res monitor }

{ masks used for checking bits }

    CORRECT_RGB_MASK	= CORRECT_RED + CORRECT_GREEN + CORRECT_BLUE;
    DIMENSIONS_MASK	= BOUNDED_DIMENSIONS + ABSOLUTE_DIMENSIONS +
				PIXEL_DIMENSIONS + MULTIPLY_DIMENSIONS;
    DITHERING_MASK	= HALFTONE_DITHERING + FLOYD_DITHERING;

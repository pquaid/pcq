{ == errors.h =========================================================
 *
 * Copyright (c) 1987 by William S. Hawes.  All Rights Reserved.
 * 
 * =====================================================================
 * Definitions for ARexx error codes
}

Const

    ERRC_MSG	= 0;		{  error code offset           }
    ERR10_001	= ERRC_MSG+1;	{  program not found           }
    ERR10_002	= ERRC_MSG+2;	{  execution halted            }
    ERR10_003	= ERRC_MSG+3;	{  no memory available         }
    ERR10_004	= ERRC_MSG+4;	{  invalid character in program}
    ERR10_005	= ERRC_MSG+5;	{  unmatched quote             }
    ERR10_006	= ERRC_MSG+6;	{  unterminated comment        }
    ERR10_007	= ERRC_MSG+7;	{  clause too long             }
    ERR10_008	= ERRC_MSG+8;	{  unrecognized token          }
    ERR10_009	= ERRC_MSG+9;	{  symbol or string too long   }

    ERR10_010	= ERRC_MSG+10;	{  invalid message packet      }
    ERR10_011	= ERRC_MSG+11;	{  command string error        }
    ERR10_012	= ERRC_MSG+12;	{  error return from function  }
    ERR10_013	= ERRC_MSG+13;	{  host environment not found  }
    ERR10_014	= ERRC_MSG+14;	{  required library not found  }
    ERR10_015	= ERRC_MSG+15;	{  function not found          }
    ERR10_016	= ERRC_MSG+16;	{  no return value             }
    ERR10_017	= ERRC_MSG+17;	{  wrong number of arguments   }
    ERR10_018	= ERRC_MSG+18;	{  invalid argument to function}
    ERR10_019	= ERRC_MSG+19;	{  invalid PROCEDURE           }

    ERR10_020	= ERRC_MSG+20;	{  unexpected THEN/ELSE        }
    ERR10_021	= ERRC_MSG+21;	{  unexpected WHEN/OTHERWISE   }
    ERR10_022	= ERRC_MSG+22;	{  unexpected LEAVE or ITERATE }
    ERR10_023	= ERRC_MSG+23;	{  invalid statement in SELECT }
    ERR10_024	= ERRC_MSG+24;	{  missing THEN clauses        }
    ERR10_025	= ERRC_MSG+25;	{  missing OTHERWISE           }
    ERR10_026	= ERRC_MSG+26;	{  missing or unexpected END   }
    ERR10_027	= ERRC_MSG+27;	{  symbol mismatch on END      }
    ERR10_028	= ERRC_MSG+28;	{  invalid DO syntax           }
    ERR10_029	= ERRC_MSG+29;	{  incomplete DO/IF/SELECT     }

    ERR10_030	= ERRC_MSG+30;	{  label not found             }
    ERR10_031	= ERRC_MSG+31;	{  symbol expected             }
    ERR10_032	= ERRC_MSG+32;	{  string or symbol expected   }
    ERR10_033	= ERRC_MSG+33;	{  invalid sub-keyword         }
    ERR10_034	= ERRC_MSG+34;	{  required keyword missing    }
    ERR10_035	= ERRC_MSG+35;	{  extraneous characters       }
    ERR10_036	= ERRC_MSG+36;	{  sub-keyword conflict        }
    ERR10_037	= ERRC_MSG+37;	{  invalid template            }
    ERR10_038	= ERRC_MSG+38;	{  invalid TRACE request       }
    ERR10_039	= ERRC_MSG+39;	{  uninitialized variable      }

    ERR10_040	= ERRC_MSG+40;	{  invalid variable name       }
    ERR10_041	= ERRC_MSG+41;	{  invalid expression          }
    ERR10_042	= ERRC_MSG+42;	{  unbalanced parentheses      }
    ERR10_043	= ERRC_MSG+43;	{  nesting level exceeded      }
    ERR10_044	= ERRC_MSG+44;	{  invalid expression result   }
    ERR10_045	= ERRC_MSG+45;	{  expression required         }
    ERR10_046	= ERRC_MSG+46;	{  boolean value not 0 or 1    }
    ERR10_047	= ERRC_MSG+47;	{  arithmetic conversion error }
    ERR10_048	= ERRC_MSG+48;	{  invalid operand             }

{
 * Return Codes for general use
}

    RC_OK	= 0;		{  success                     }
    RC_WARN	= 5;		{  warning only                }
    RC_ERROR	= 10;		{  something's wrong           }
    RC_FATAL	= 20;		{  complete or severe failure  }


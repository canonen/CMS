package com.britemoon.cps;

public final class ContLoadStatus
{
	final public static int RECEIVED = 10;
	final public static int PROCESSING = 20;
	final public static int COMPLETE = 40;
	final public static int ERROR = 900;
	final public static int ERROR_PROCESSING = 920;

	
	// === === ===

	public static String getDisplayName(int iContLoadStatus)
	{
		String sDisplayName = "UNKNOWN";

		switch (iContLoadStatus)
		{
			case RECEIVED:			sDisplayName = "Received"; break;
			case PROCESSING:			sDisplayName = "Processing"; break;
			case COMPLETE:	            sDisplayName = "Complete"; break;
			case ERROR:	    sDisplayName = "Error"; break;
			case ERROR_PROCESSING:	    sDisplayName = "Error during Order processing"; break;

		}

		return sDisplayName;
	}


}

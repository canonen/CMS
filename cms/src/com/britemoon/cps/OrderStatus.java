package com.britemoon.cps;

public final class OrderStatus
{
	final public static int RECEIVED = 10;
	final public static int PROCESSING = 20;
	final public static int IMPORT_COMPLETE = 25;
	final public static int EXECUTING = 30;
	final public static int COMPLETE = 40;
	final public static int ERROR_RECEIVING = 910;
	final public static int ERROR_PROCESSING = 920;
	final public static int ERROR_EXECUTING = 930;

	
	// === === ===

	public static String getDisplayName(int iOrderStatus)
	{
		String sDisplayName = "UNKNOWN";

		switch (iOrderStatus)
		{
			case RECEIVED:			sDisplayName = "Received"; break;
			case PROCESSING:			sDisplayName = "Processing"; break;
			case IMPORT_COMPLETE:			sDisplayName = "Processing...Import has completed"; break;
			case EXECUTING:              sDisplayName = "Executing"; break;
			case COMPLETE:	            sDisplayName = "Complete"; break;
			case ERROR_RECEIVING:	    sDisplayName = "Error during Order receipt"; break;
			case ERROR_PROCESSING:	    sDisplayName = "Error during Order processing"; break;
			case ERROR_EXECUTING:	    sDisplayName = "Error during Order execution"; break;

		}

		return sDisplayName;
	}


}

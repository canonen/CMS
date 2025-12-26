package com.britemoon.cps;


final public class SyncStatus
{
	final public static int STARTED = 0;
	final public static int DATA_SENT 	= 10;
	final public static int DONE  = 50; 
	final public static int BRITEMOON_ERROR 	= 60; 
	final public static int CUST_ERROR 	= 70; 


	// === === ===

	public static String getDisplayName(int iSyncStatus)
	{
		String sDisplayName = "UNKNOWN";

		switch (iSyncStatus)
		{
			case STARTED:			          sDisplayName = "Started"; break;
			case DATA_SENT:		          sDisplayName = "Data Sent"; break;
			case DONE:	                         sDisplayName = "Done"; break;
			case BRITEMOON_ERROR:    sDisplayName = "Error on Britemoon side"; break;
			case CUST_ERROR:	               sDisplayName = "Error on Customer side"; break;

		}

		return sDisplayName;
	}
	// === === ===

}


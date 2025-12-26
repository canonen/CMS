package com.britemoon.cps;


final public class SyncType
{
	final public static int INTERNAL_DB = 10;
	final public static int EXTERNAL_DB 	= 20;
	final public static int XML  = 30; 
	final public static int WEB_SERVICE 	= 40; 


	// === === ===

	public static String getDisplayName(int iSyncType)
	{
		String sDisplayName = "UNKNOWN";

		switch (iSyncType)
		{
			case INTERNAL_DB:			sDisplayName = "Internal Db"; break;
			case EXTERNAL_DB:		sDisplayName = "External Db"; break;
			case XML:	                         sDisplayName = "XML"; break;
			case WEB_SERVICE:	     sDisplayName = "Web Service"; break;

		}

		return sDisplayName;
	}
	// === === ===

}


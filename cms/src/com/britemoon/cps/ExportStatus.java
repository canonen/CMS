package com.britemoon.cps;

final public class ExportStatus {
	final public static int QUEUED		= 10;
	final public static int PROCESSING	= 15;
	final public static int COMPLETE	= 20;
	final public static int ERROR		= 30;
	
	//Release 6.0: Added for Export Once and Re-run as needed.
	public static String getDisplayName(int iExportStatus)
	{
		String sDisplayName = "Unknown";

		switch (iExportStatus)
		{
			case QUEUED: 				sDisplayName = "Queued for Processing"; break;
			case PROCESSING:			sDisplayName = "Processing"; break;
			case COMPLETE:				sDisplayName = "Ready"; break;
			case ERROR:					sDisplayName = "Error"; break;
		}

		return sDisplayName;
	}
}



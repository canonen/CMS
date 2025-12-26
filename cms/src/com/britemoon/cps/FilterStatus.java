package com.britemoon.cps;

final public class FilterStatus
{
	final public static int NEW = 10;
	final public static int PENDING_APPROVAL = 15;
	final public static int QUEUED_FOR_PROCESSING = 20;	
	final public static int PROCESSING = 30;
	final public static int READY = 40;
	final public static int PROCESSING_ERROR = 140;
	final public static int DELETED = 900;

	// === === ===

	public static String getDisplayName(int iFilterStatus)
	{
		String sDisplayName = "Unknown";

		switch (iFilterStatus)
		{
			case NEW:					sDisplayName = "New"; break;
			case PENDING_APPROVAL:		sDisplayName = "Pending Approval"; break;
			case QUEUED_FOR_PROCESSING: sDisplayName = "Queued for Processing"; break;
			case PROCESSING:			sDisplayName = "Processing"; break;
			case READY:					sDisplayName = "Ready"; break;
			case PROCESSING_ERROR:		sDisplayName = "Processing Error"; break;	
			case DELETED:				sDisplayName = "Deleted"; break;			
		}

		return sDisplayName;
	}
}
package com.britemoon.cps;


final public class SyncObjectType
{
	final public static int CAMPAIGN             = 0;
	final public static int MESSAGE              = 1;
	final public static int LINK                 = 2;
	final public static int CLICK 	             = 3; 
    final public static int CLICK_PARAM          = 5;
    final public static int BOUNCE_BACK          = 10;
    final public static int UNSUB                = 11;
    final public static int FORM_SUBMISSION      = 12;
	final public static int RECIPIENT 	         = 100;


	// === === ===

	public static String getDisplayName(int iContStatus)
	{
		String sDisplayName = "UNKNOWN";

		switch (iContStatus)
		{
			case CAMPAIGN:			sDisplayName = "Campaign"; break;
			case MESSAGE:			sDisplayName = "Message"; break;
			case LINK:              sDisplayName = "Link"; break;
			case CLICK:	            sDisplayName = "Click"; break;
			case CLICK_PARAM:	    sDisplayName = "Click Parameter"; break;
			case BOUNCE_BACK:	    sDisplayName = "Bounce Back"; break;
			case UNSUB:	            sDisplayName = "Unsub"; break;
			case FORM_SUBMISSION:	sDisplayName = "Form Submission"; break;
			case RECIPIENT:	        sDisplayName = "Recipient"; break;

		}

		return sDisplayName;
	}
	// === === ===

}


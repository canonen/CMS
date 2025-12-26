package com.britemoon.cps;

public final class FileType
{
	final public static int ZIP = 10;
	final public static int CONTENT = 20;
	final public static int IMPORT = 30;
	final public static int CAMPAIGN = 40;
	final public static int IMAGE = 50;
	final public static int MANIFEST = 60;
	final public static int CONT_TEXT = 70;
	final public static int CONT_HTML = 80;
	final public static int RECIP_IMPORT_FILE = 90;
	final public static int ENTITY_IMPORT_FILE = 100;
	final public static int OFFER_FILE = 110;
	final public static int XML_FILE = 120;
	
	// This class references data in ccps_file_type table.

	// === === ===

	public static String getDisplayName(int iFileType)
	{
		String sDisplayName = "UNKNOWN";

		switch (iFileType)
		{
			case ZIP:				 sDisplayName = "ZIP"; break;
			case CONTENT:			 sDisplayName = "Content"; break;
			case IMPORT:             sDisplayName = "Recipient List Import"; break;
			case CAMPAIGN:	         sDisplayName = "Campaign"; break;
			case IMAGE:	    		 sDisplayName = "Image"; break;
			case MANIFEST:           sDisplayName = "Manifest"; break;
			case CONT_TEXT:          sDisplayName = "Content Text"; break;
			case CONT_HTML:          sDisplayName = "Content HTML"; break;
			case RECIP_IMPORT_FILE:  sDisplayName = "Recipient Import File"; break;
			case ENTITY_IMPORT_FILE: sDisplayName = "Entity Import File"; break;
			case OFFER_FILE:         sDisplayName = "Offer Zip File"; break;
			case XML_FILE:           sDisplayName = "XML File"; break;

		}

		return sDisplayName;
	}


}

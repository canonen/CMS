package com.britemoon.cps;

import java.io.StringWriter;

final public class CustResourceType
{
	final public static int WEB_SERVICE = 1;
	final public static int SFTP = 2;
	final public static int CLICK_SEAL_FILE = 3;
	final public static int WS_IMPORT_TEMPLATE_ID = 4;

	// === === ===

	public static String getDisplayName(int iContStatus)
	{
		String sDisplayName = "UNKNOWN";

		switch (iContStatus)
		{
			case WEB_SERVICE:		sDisplayName = "Web Service"; break;
			case SFTP:				sDisplayName = "SFTP"; break;
			case CLICK_SEAL_FILE:	sDisplayName = "Click Seal File"; break;
			case WS_IMPORT_TEMPLATE_ID:	sDisplayName = "WS Import Template Id"; break;
		}

		return sDisplayName;
	}
	// === === ===

	public static String toHtmlOptions()
	{
		return toHtmlOptions(-1);
	}

	public static String toHtmlOptions(String sSelected)
	{
		int iSelected = -1;
		try	{ iSelected = Integer.parseInt(sSelected); }
		catch(Exception ex) {}
		return toHtmlOptions(iSelected);
	}
	
	public static String toHtmlOptions(int iSelected)
	{
		StringWriter sw = new StringWriter();

		sw.write("\r\n");
		sw.write("<OPTION value=\"" + WEB_SERVICE + "\"" + ((iSelected == WEB_SERVICE)?" selected":"") + ">Web Service</OPTION>\r\n");
		sw.write("<OPTION value=\"" + SFTP + "\"" + ((iSelected == SFTP)?" selected":"") + ">SFTP</OPTION>\r\n");		
		sw.write("<OPTION value=\"" + CLICK_SEAL_FILE + "\"" + ((iSelected == CLICK_SEAL_FILE)?" selected":"") + ">Click Seal File</OPTION>\r\n");
		sw.write("<OPTION value=\"" + WS_IMPORT_TEMPLATE_ID + "\"" + ((iSelected == WS_IMPORT_TEMPLATE_ID)?" selected":"") + ">WS Import Template ID</OPTION>\r\n");

		return sw.toString();
	}
}


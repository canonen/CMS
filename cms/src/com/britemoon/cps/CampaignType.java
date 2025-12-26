package com.britemoon.cps;

import java.io.StringWriter;

final public class CampaignType
{
	final public static int TEST = 1;
	final public static int STANDARD = 2;
	final public static int SEND_TO_FRIEND = 3;
	final public static int AUTO_RESPOND = 4;
	final public static int NON_EMAIL = 5;

	// === === ===

	public static String getDisplayName(int iContStatus)
	{
		String sDisplayName = "UNKNOWN";

		switch (iContStatus)
		{
			case TEST:				sDisplayName = "Test"; break;
			case STANDARD:			sDisplayName = "Standard"; break;
			case SEND_TO_FRIEND:	sDisplayName = "Send to Friend"; break;
			case AUTO_RESPOND:		sDisplayName = "Auto-respond"; break;
			case NON_EMAIL:		    sDisplayName = "Non-Email"; break;
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
		sw.write("<OPTION value=\"" + TEST + "\"" + ((iSelected == TEST)?" selected":"") + ">Test</OPTION>\r\n");
		sw.write("<OPTION value=\"" + STANDARD + "\"" + ((iSelected == STANDARD)?" selected":"") + ">Standard</OPTION>\r\n");		
		sw.write("<OPTION value=\"" + SEND_TO_FRIEND + "\"" + ((iSelected == SEND_TO_FRIEND)?" selected":"") + ">Send to Friend</OPTION>\r\n");
		sw.write("<OPTION value=\"" + AUTO_RESPOND + "\"" + ((iSelected == AUTO_RESPOND)?" selected":"") + ">Auto-respond</OPTION>\r\n");		
		sw.write("<OPTION value=\"" + NON_EMAIL + "\"" + ((iSelected == NON_EMAIL)?" selected":"") + ">Non-Email</OPTION>\r\n");

		return sw.toString();
	}
}


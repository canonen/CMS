package com.britemoon.cps;

import java.io.StringWriter;

final public class CampaignMode
{
	final public static int TEST = 10;
	final public static int CALC_ONLY = 20;
	final public static int DELIVERABILITY_TEST = 30;
	final public static int DELIVERABILITY_SENDOUT = 40;

	// === === ===

	public static String getDisplayName(int iCampMode)
	{
		String sDisplayName = "UNKNOWN";

		switch (iCampMode)
		{
			case TEST:				sDisplayName = "Test"; break;
			case CALC_ONLY:			sDisplayName = "Calculate recip count"; break;
			case DELIVERABILITY_TEST:			sDisplayName = "Deliverability Test"; break;
			case DELIVERABILITY_SENDOUT:		sDisplayName = "Deliverability Sendout"; break;
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
		sw.write("<OPTION value=\"" + CALC_ONLY + "\"" + ((iSelected == CALC_ONLY)?" selected":"") + ">Calculate Recip Count</OPTION>\r\n");		
		sw.write("<OPTION value=\"" + DELIVERABILITY_TEST + "\"" + ((iSelected == DELIVERABILITY_TEST)?" selected":"") + ">Deliverability Test</OPTION>\r\n");
		sw.write("<OPTION value=\"" + DELIVERABILITY_SENDOUT + "\"" + ((iSelected == DELIVERABILITY_SENDOUT)?" selected":"") + ">Deliverability Sendout</OPTION>\r\n");
		return sw.toString();
	}
}


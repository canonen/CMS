package com.britemoon.cps;

import java.io.StringWriter;

final public class MediaType
{
	final public static int EMAIL = 1;
	final public static int PRINT = 2;

	// === === ===

	public static String getDisplayName(int iContStatus)
	{
		String sDisplayName = "UNKNOWN";

		switch (iContStatus)
		{
			case EMAIL:			sDisplayName = "EMail"; break;
			case PRINT:			sDisplayName = "Print"; break;
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
		sw.write("<OPTION value=\"" + EMAIL + "\"" + ((iSelected == EMAIL)?" selected":"") + ">EMail</OPTION>\r\n");
		sw.write("<OPTION value=\"" + PRINT + "\"" + ((iSelected == PRINT)?" selected":"") + ">Print</OPTION>\r\n");		

		return sw.toString();
	}
}


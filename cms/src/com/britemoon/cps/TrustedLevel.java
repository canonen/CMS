package com.britemoon.cps;

import java.io.*;

final public class TrustedLevel
{
	final public static int NON_TRUSTED = 1;
	final public static int TRUSTED = 2;

	// === === ===

	public static String getDisplayName(int iContStatus)
	{
		String sDisplayName = "UNKNOWN";

		switch (iContStatus)
		{
			case NON_TRUSTED:	sDisplayName = "NON_TRUSTED"; break;
			case TRUSTED:	sDisplayName = "TRUSTED"; break;
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
		sw.write("<OPTION value=\"" + NON_TRUSTED + "\"" + ((iSelected == NON_TRUSTED)?" selected":"") + ">NON_TRUSTED</OPTION>\r\n");
		sw.write("<OPTION value=\"" + TRUSTED + "\"" + ((iSelected == TRUSTED)?" selected":"") + ">TRUSTED</OPTION>\r\n");

		return sw.toString();
	}	
}
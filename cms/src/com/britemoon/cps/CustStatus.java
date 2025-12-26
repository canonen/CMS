package com.britemoon.cps;

import java.io.*;

final public class CustStatus
{
	final public static int DRAFT = 1;
	final public static int REVISED_DRAFT = 2;
	final public static int ACTIVATED = 3;

	// === === ===

	public static String getDisplayName(int iContStatus)
	{
		String sDisplayName = "UNKNOWN";

		switch (iContStatus)
		{
			case DRAFT:			sDisplayName = "DRAFT"; break;
			case REVISED_DRAFT:	sDisplayName = "REVISED_DRAFT"; break;
			case ACTIVATED:		sDisplayName = "ACTIVATED"; break;
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
		sw.write("<OPTION value=\"" + DRAFT + "\"" + ((iSelected == DRAFT)?" selected":"") + ">DRAFT</OPTION>\r\n");
		sw.write("<OPTION value=\"" + REVISED_DRAFT + "\"" + ((iSelected == REVISED_DRAFT)?" selected":"") + ">REVISED_DRAFT</OPTION>\r\n");
		sw.write("<OPTION value=\"" + ACTIVATED + "\"" + ((iSelected == ACTIVATED)?" selected":"") + ">ACTIVATED</OPTION>\r\n");

		return sw.toString();
	}	
}
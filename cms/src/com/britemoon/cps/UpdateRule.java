package com.britemoon.cps;

import java.io.*;

final public class UpdateRule
{
	final public static int DISCARD_DUPLICATES		= 10;
	final public static int INSERT_ONLY_NEW_FIELDS	= 20;
	final public static int OVERWRITE_IGNORE_BLANKS	= 30;
	final public static int OVERWRITE_WITH_BLANKS	= 40;
	
	// === === ===
		
	public static String getDisplayName(int iContStatus)
	{
		String sDisplayName = "UNKNOWN";

		switch (iContStatus)
		{
			case DISCARD_DUPLICATES:		sDisplayName = "DISCARD DUPLICATES"; break;
			case INSERT_ONLY_NEW_FIELDS:	sDisplayName = "INSERT ONLY NEW FIELDS"; break;
			case OVERWRITE_IGNORE_BLANKS:	sDisplayName = "OVERWRITE IGNORE BLANKS"; break;
			case OVERWRITE_WITH_BLANKS:		sDisplayName = "OVERWRITE WITH BLANKS"; break;
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
		sw.write("<OPTION value=\"" + DISCARD_DUPLICATES + "\"" + ((iSelected == DISCARD_DUPLICATES)?" selected":"") + ">DISCARD DUPLICATES</OPTION>\r\n");
		sw.write("<OPTION value=\"" + INSERT_ONLY_NEW_FIELDS + "\"" + ((iSelected == INSERT_ONLY_NEW_FIELDS)?" selected":"") + ">INSERT ONLY NEW FIELDS</OPTION>\r\n");
		sw.write("<OPTION value=\"" + OVERWRITE_IGNORE_BLANKS + "\"" + ((iSelected == OVERWRITE_IGNORE_BLANKS)?" selected":"") + ">OVERWRITE IGNORE BLANKS</OPTION>\r\n");
		sw.write("<OPTION value=\"" + OVERWRITE_WITH_BLANKS + "\"" + ((iSelected == OVERWRITE_WITH_BLANKS)?" selected":"") + ">OVERWRITE WITH BLANKS</OPTION>\r\n");

		return sw.toString();
	}	
}

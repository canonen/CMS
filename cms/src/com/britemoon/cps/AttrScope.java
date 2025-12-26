package com.britemoon.cps;

import java.io.*;

final public class AttrScope
{
	final public static int PRIVATE = 100;
	final public static int RESERVED_FOR_PROTECTED = 200;
	final public static int PUBLIC = 300;

	// === === ===

	public static String getDisplayName(int iContStatus)
	{
		String sDisplayName = "UNKNOWN";

		switch (iContStatus)
		{
			case PRIVATE:	sDisplayName = "PRIVATE"; break;
			case PUBLIC:	sDisplayName = "PUBLIC"; break;
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
		sw.write("<OPTION value=\"" + PUBLIC + "\"" + ((iSelected == PUBLIC)?" selected":"") + ">PUBLIC</OPTION>\r\n");
		sw.write("<OPTION value=\"" + PRIVATE + "\"" + ((iSelected == PRIVATE)?" selected":"") + ">PRIVATE</OPTION>\r\n");

		return sw.toString();
	}
}

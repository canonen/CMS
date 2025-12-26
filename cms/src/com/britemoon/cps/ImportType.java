package com.britemoon.cps;

import java.io.*;

final public class ImportType
{
	final public static int STANDARD		= 10;
    final public static int FTP         	= 12;
	final public static int EMAIL_CHANGE	= 15;
	
	
	// === === ===
		
	public static String getDisplayName(int iContStatus)
	{
		String sDisplayName = "UNKNOWN";

		switch (iContStatus)
		{
			case STANDARD:		sDisplayName = "STANDARD"; break;
			case FTP:			sDisplayName = "FTP"; break;
			case EMAIL_CHANGE:	sDisplayName = "EMAIL_CHANGE"; break;
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
		sw.write("<OPTION value=\"" + STANDARD + "\"" + ((iSelected == STANDARD)?" selected":"") + ">STANDARD</OPTION>\r\n");
		sw.write("<OPTION value=\"" + FTP + "\"" + ((iSelected == FTP)?" selected":"") + ">FTP</OPTION>\r\n");
		sw.write("<OPTION value=\"" + EMAIL_CHANGE + "\"" + ((iSelected == EMAIL_CHANGE)?" selected":"") + ">EMAIL_CHANGE</OPTION>\r\n");		

		return sw.toString();
	}	
}


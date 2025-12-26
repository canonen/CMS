package com.britemoon.cps;

import java.io.*;

final public class Hierarchy
{
	final public static int SINGLE	= 100;
	final public static int DOWN	= 200;
	final public static int ALL		= 300;
	
	// === === ===
		
	public static String getDisplayName(int iContStatus)
	{
		String sDisplayName = "UNKNOWN";

		switch (iContStatus)
		{
			case SINGLE:	sDisplayName = "SINGLE"; break;
			case DOWN:		sDisplayName = "DOWN"; break;
			case ALL:		sDisplayName = "ALL"; break;
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
		sw.write("<OPTION value=\"" + SINGLE + "\"" + ((iSelected == SINGLE)?" selected":"") + ">SINGLE</OPTION>\r\n");
		sw.write("<OPTION value=\"" + DOWN + "\"" + ((iSelected == DOWN)?" selected":"") + ">DOWN</OPTION>\r\n");
		sw.write("<OPTION value=\"" + ALL + "\"" + ((iSelected == ALL)?" selected":"") + ">ALL</OPTION>\r\n");

		return sw.toString();
	}	
}

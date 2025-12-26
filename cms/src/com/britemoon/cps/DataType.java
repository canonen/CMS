package com.britemoon.cps;

import java.io.*;

final public class DataType
{
	final public static int INTEGER = 10;
	final public static int VARCHAR_255 = 20;
	final public static int DATETIME = 30;
	final public static int IMAGE = 40;
	final public static int MONEY = 50;	

	// === === ===

	public static String getDisplayName(int iContStatus)
	{
		String sDisplayName = "UNKNOWN";

		switch (iContStatus)
		{
			case INTEGER:		sDisplayName = "INTEGER"; break;
			case VARCHAR_255:	sDisplayName = "VARCHAR"; break;
			case DATETIME:		sDisplayName = "DATETIME"; break;
			case IMAGE:			sDisplayName = "IMAGE"; break;
			case MONEY:			sDisplayName = "MONEY"; break;			
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
		sw.write("<OPTION value=\"" + INTEGER + "\"" + ((iSelected == INTEGER)?" selected":"") + ">INTEGER</OPTION>\r\n");
		sw.write("<OPTION value=\"" + VARCHAR_255 + "\"" + ((iSelected == VARCHAR_255)?" selected":"") + ">VARCHAR</OPTION>\r\n");
		sw.write("<OPTION value=\"" + DATETIME + "\"" + ((iSelected == DATETIME)?" selected":"") + ">DATETIME</OPTION>\r\n");
		sw.write("<OPTION value=\"" + MONEY + "\"" + ((iSelected == MONEY)?" selected":"") + ">MONEY</OPTION>\r\n");		
		sw.write("<OPTION value=\"" + IMAGE + "\"" + ((iSelected == IMAGE)?" selected":"") + ">IMAGE</OPTION>\r\n");

		return sw.toString();
	}
}

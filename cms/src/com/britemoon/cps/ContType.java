package com.britemoon.cps;

import java.io.StringWriter;

final public class ContType
{
	final public static int	CONTENT = 20;
	final public static int	LOGIC_BLOCK = 25;
	final public static int	PARAGRAPH = 30;
	final public static int	PRINT = 40;
	final public static int	PRINT_TEMPLATE = 45;

	// === === ===

	public static String getDisplayName(int iContType)
	{
		String sDisplayName = "UNKNOWN";

		switch (iContType)
		{
			case CONTENT:			sDisplayName = "Email Content"; break;
			case LOGIC_BLOCK:		sDisplayName = "Logic Block"; break;
			case PARAGRAPH:			sDisplayName = "Content Element"; break;
			case PRINT:				sDisplayName = "Print Content"; break;
			case PRINT_TEMPLATE:	sDisplayName = "Print Template"; break;
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
		sw.write("<OPTION value=\"" + CONTENT + "\"" + ((iSelected == CONTENT)?" selected":"") + ">Email Content</OPTION>\r\n");
		sw.write("<OPTION value=\"" + PRINT + "\"" + ((iSelected == PRINT)?" selected":"") + ">Print Content</OPTION>\r\n");
		sw.write("<OPTION value=\"" + PRINT_TEMPLATE + "\"" + ((iSelected == PRINT_TEMPLATE)?" selected":"") + ">Print Template</OPTION>\r\n");
		sw.write("<OPTION value=\"" + LOGIC_BLOCK + "\"" + ((iSelected == LOGIC_BLOCK)?" selected":"") + ">Logic Block</OPTION>\r\n");
		sw.write("<OPTION value=\"" + PARAGRAPH + "\"" + ((iSelected == PARAGRAPH)?" selected":"") + ">Content Element</OPTION>\r\n");

		return sw.toString();
	}
}

package com.britemoon.cps;

import java.io.*;

final public class CompareOperation
{
	final public static int EQUAL = 10; // =
	final public static int MORE = 20; // >
	final public static int MORE_OR_EQUAL = 30; // >=
	final public static int LESS = 40; // <
	final public static int LESS_OR_EQUAL = 50; // <=
	final public static int LIKE = 60; // LIKE
	final public static int BETWEEN = 70; // BETWEEN
	final public static int IN = 80; // IN

	// === === ===

	public static String getDisplayName(int iContStatus)
	{
		String sDisplayName = "UNKNOWN";

		switch (iContStatus)
		{
			case EQUAL:			sDisplayName = "EQUAL"; break;
			case MORE:			sDisplayName = "MORE"; break;
			case MORE_OR_EQUAL:	sDisplayName = "MORE OR EQUAL"; break;
			case LESS:			sDisplayName = "LESS"; break;
			case LESS_OR_EQUAL:	sDisplayName = "LESS OR EQUAL"; break;
			case LIKE:			sDisplayName = "LIKE"; break;
			case BETWEEN:		sDisplayName = "BETWEEN"; break;
			case IN:			sDisplayName = "IN"; break;
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
		sw.write("<OPTION value=\"" + EQUAL + "\"" + ((iSelected == EQUAL)?" selected":"") + ">=</OPTION>\r\n");
		sw.write("<OPTION value=\"" + MORE + "\"" + ((iSelected == MORE)?" selected":"") + ">&gt;</OPTION>\r\n");
		sw.write("<OPTION value=\"" + MORE_OR_EQUAL + "\"" + ((iSelected == MORE_OR_EQUAL)?" selected":"") + ">&gt;=</OPTION>\r\n");
		sw.write("<OPTION value=\"" + LESS + "\"" + ((iSelected == LESS)?" selected":"") + ">&lt;</OPTION>\r\n");		
		sw.write("<OPTION value=\"" + LESS_OR_EQUAL + "\"" + ((iSelected == LESS_OR_EQUAL)?" selected":"") + ">&lt;=</OPTION>\r\n");
		sw.write("<OPTION value=\"" + LIKE + "\"" + ((iSelected == LIKE)?" selected":"") + ">LIKE</OPTION>\r\n");
		sw.write("<OPTION value=\"" + BETWEEN + "\"" + ((iSelected == BETWEEN)?" selected":"") + ">BETWEEN</OPTION>\r\n");
		sw.write("<OPTION value=\"" + IN + "\"" + ((iSelected == IN)?" selected":"") + ">IN</OPTION>\r\n");		

		return sw.toString();
	}
}
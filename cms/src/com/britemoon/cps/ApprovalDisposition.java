package com.britemoon.cps;

import java.io.StringWriter;

final public class ApprovalDisposition
{
	final public static int APPROVE = 10;
	final public static int EDITING = 50;
	final public static int REJECT = 90;

	// === === ===

	public static String getDisplayName(int iDisposition)
	{
		String sDisplayName = "UNKNOWN";

		switch (iDisposition)
		{
			case APPROVE:				sDisplayName = "Approve"; break;
			case EDITING:				sDisplayName = "Editing"; break;
			case REJECT:			sDisplayName = "Reject"; break;
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
		sw.write("<OPTION value=\"" + APPROVE + "\"" + ((iSelected == APPROVE)?" selected":"") + ">Approve</OPTION>\r\n");
		sw.write("<OPTION value=\"" + EDITING + "\"" + ((iSelected == EDITING)?" selected":"") + ">Editing</OPTION>\r\n");
		sw.write("<OPTION value=\"" + REJECT + "\"" + ((iSelected == REJECT)?" selected":"") + ">Reject</OPTION>\r\n");		

		return sw.toString();
	}
}


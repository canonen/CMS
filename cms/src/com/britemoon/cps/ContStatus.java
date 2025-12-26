package com.britemoon.cps;

import java.io.StringWriter;

final public class ContStatus
{
	final public static int	DRAFT	= 10;
	final public static int	PENDING_APPROVAL	= 15;
	final public static int	READY	= 20;
	final public static int	PENDING_CAMP	= 25;
	final public static int	EXPIRED	= 30;
	final public static int	DELETED	= 90;

	// === === ===

	public static String getDisplayName(int iContStatus)
	{
		String sDisplayName = "UNKNOWN";

		switch (iContStatus)
		{
			case DRAFT:		sDisplayName = "Draft"; break;
			case PENDING_APPROVAL:		sDisplayName = "Pending Approval"; break;
			case READY:		sDisplayName = "Ready"; break;
			case PENDING_CAMP:		sDisplayName = "Ready (pending campaign approval)"; break;
			case EXPIRED:	sDisplayName = "Expired"; break;
			case DELETED:	sDisplayName = "Deleted"; break;
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
		sw.write("<OPTION value=\"" + DRAFT + "\"" + ((iSelected == DRAFT)?" selected":"") + ">Draft</OPTION>\r\n");
		sw.write("<OPTION value=\"" + READY + "\"" + ((iSelected == READY)?" selected":"") + ">Ready</OPTION>\r\n");
		sw.write("<OPTION value=\"" + EXPIRED + "\"" + ((iSelected == EXPIRED)?" selected":"") + ">Expired</OPTION>\r\n");
		sw.write("<OPTION value=\"" + DELETED + "\"" + ((iSelected == DELETED)?" selected":"") + ">Deleted</OPTION>\r\n");

		return sw.toString();
	}
}

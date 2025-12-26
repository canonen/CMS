package com.britemoon.cps;

import java.io.*;

final public class UserStatus
{
	final public static int DRAFT = 10;
	final public static int PENDING_APPROVAL = 15;
	final public static int REVISED_DRAFT = 20;
	final public static int ACTIVATED = 30;
	final public static int DELETED = 40;
	
	// === === ===
		
	public static String getDisplayName(int iContStatus)
	{
		String sDisplayName = "UNKNOWN";

		switch (iContStatus)
		{
			case DRAFT:			sDisplayName = "DRAFT"; break;
			case PENDING_APPROVAL:			sDisplayName = "PENDING_APPROVAL"; break;
			case REVISED_DRAFT:	sDisplayName = "REVISED_DRAFT"; break;
			case ACTIVATED:		sDisplayName = "ACTIVATED"; break;
			case DELETED:		sDisplayName = "DELETED"; break;
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
		// Don't show 'Pending Approval' as selectable option.  Pending Approval status is taken care of by Request Approval button.
          //sw.write("<OPTION value=\"" + PENDING_APPROVAL + "\"" + ((iSelected == PENDING_APPROVAL)?" selected":"") + ">PENDING_APPROVAL</OPTION>\r\n");
		sw.write("<OPTION value=\"" + REVISED_DRAFT + "\"" + ((iSelected == REVISED_DRAFT)?" selected":"") + ">REVISED-DRAFT</OPTION>\r\n");
		sw.write("<OPTION value=\"" + ACTIVATED + "\"" + ((iSelected == ACTIVATED)?" selected":"") + ">ACTIVATED</OPTION>\r\n");		
		// Don't show 'Deleted' as selectable option.  Delete status is taken care of by Delete button.
          //sw.write("<OPTION value=\"" + DELETED + "\"" + ((iSelected == DELETED)?" selected":"") + ">DELETED</OPTION>\r\n");

		return sw.toString();
	}
}
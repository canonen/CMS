package com.britemoon.cps;

import java.io.*;

public final class UIType
{
	public static final int	STANDARD = 100;
	public static final int	ADVANCED = 200;
	public static final int	HYATT_USER = 300;
	public static final int	HYATT_ADMIN = 310;
	
	public static String getDisplayName(int iContStatus)
	{
		String sDisplayName = "Unknown";

		switch (iContStatus)
		{
			case STANDARD:		sDisplayName = "Standard"; break;
			case ADVANCED:		sDisplayName = "Advanced"; break;
			case HYATT_USER:	sDisplayName = "Hyatt User"; break;
			case HYATT_ADMIN:	sDisplayName = "Hyatt Admin"; break;
		}

		return sDisplayName;
	}

	// === === ===

	public static String toHtmlOptions()
	{
		return toHtmlOptions(-1, 0);
	}

	public static String toHtmlOptions(String sSelected)
	{
		int iSelected = -1;
		try	{ iSelected = Integer.parseInt(sSelected); }
		catch(Exception ex) {}
		return toHtmlOptions(iSelected, 1);
	}

	public static String toHtmlOptions(String sSelected, int showOption)
	{
		int iSelected = -1;
		try	{ iSelected = Integer.parseInt(sSelected); }
		catch(Exception ex) {}
		return toHtmlOptions(iSelected, showOption);
	}
	
	public static String toHtmlOptions(int iSelected, int showOption)
	{
		//showOption = 0: SAS - show all 4
		//showOption = 1: CPS Normal - show STD/ADV
		//showOption = 2: CPS Hyatt - show Admin/User
		
		StringWriter sw = new StringWriter();

		sw.write("\r\n");
		
		if (showOption == 0)
		{
			sw.write("<OPTION value=\"" + STANDARD + "\"" + ((iSelected == STANDARD)?" selected":"") + ">Standard</OPTION>\r\n");
			sw.write("<OPTION value=\"" + ADVANCED + "\"" + ((iSelected == ADVANCED)?" selected":"") + ">Advanced</OPTION>\r\n");
			sw.write("<OPTION value=\"" + HYATT_USER + "\"" + ((iSelected == HYATT_USER)?" selected":"") + ">Hyatt User</OPTION>\r\n");
			sw.write("<OPTION value=\"" + HYATT_ADMIN + "\"" + ((iSelected == HYATT_ADMIN)?" selected":"") + ">Hyatt Admin</OPTION>\r\n");
		}
		else if (showOption == 1)
		{
			sw.write("<OPTION value=\"" + STANDARD + "\"" + ((iSelected == STANDARD)?" selected":"") + ">Standard</OPTION>\r\n");
			sw.write("<OPTION value=\"" + ADVANCED + "\"" + ((iSelected == ADVANCED)?" selected":"") + ">Advanced</OPTION>\r\n");
		}
		else
		{
			sw.write("<OPTION value=\"" + HYATT_USER + "\"" + ((iSelected == HYATT_USER)?" selected":"") + ">Hyatt User</OPTION>\r\n");
			sw.write("<OPTION value=\"" + HYATT_ADMIN + "\"" + ((iSelected == HYATT_ADMIN)?" selected":"") + ">Hyatt Admin</OPTION>\r\n");
		}

		return sw.toString();
	}
}

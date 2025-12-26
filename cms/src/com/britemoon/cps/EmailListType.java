package com.britemoon.cps;

import java.io.*;

final public class EmailListType
{
	final public static int GLOBAL_EXCLUSION_LIST = 1;
        final public static int RANDOM_TEST_LIST = 2;
        final public static int CAMPAIGN_EXCLUSION_LIST = 3;
        final public static int AUTORESPOND_NOTIFICATION_LIST_ONE_PER_SUBSCRIBER = 4;
        final public static int SPECIFIED_TEST_LIST = 5;
        final public static int AUTORESPOND_NOTIFICATION_LIST_EVERYONE_ON_LIST = 6;        
        final public static int DYNAMIC_CONTENT_TEST_LIST = 7;
        final public static int PV_SCORER_LIST = 8;
        final public static int PV_OPTIMIZER_LIST = 9;
        final public static int PV_SEED_LIST = 10;
        final public static int PV_SEED_LIST_B2B = 11;
        final public static int PV_SEED_LIST_CANADIAN = 12;
        final public static int PV_SEED_LIST_INTERNATIONAL = 13;
        final public static int PV_SEED_LIST_CUSTOM = 14;
        
        //-------------------------

	// === === ===

	public static String getDisplayName(int iContStatus)
	{
		String sDisplayName = "UNKNOWN";

		switch (iContStatus)
		{
			case GLOBAL_EXCLUSION_LIST:		sDisplayName = "Global exclusion list"; break;
			case RANDOM_TEST_LIST:			sDisplayName = "BriteTrack"; break;
			case CAMPAIGN_EXCLUSION_LIST:		sDisplayName = "Campaign exclusion list"; break;
			case AUTORESPOND_NOTIFICATION_LIST_ONE_PER_SUBSCRIBER:	sDisplayName = "Auto-respond notification list - one per subscriber"; break;
			case SPECIFIED_TEST_LIST:		sDisplayName = "Specified Test list"; break;
			case AUTORESPOND_NOTIFICATION_LIST_EVERYONE_ON_LIST:	sDisplayName = "Auto-respond notification list - everyone on list"; break;
			case DYNAMIC_CONTENT_TEST_LIST:		sDisplayName = "Dynamic Content Test list"; break;
			case PV_SCORER_LIST:		sDisplayName = "PV Scorer List"; break;
			case PV_OPTIMIZER_LIST:		sDisplayName = "PV Optimizer List"; break;
			case PV_SEED_LIST:		sDisplayName = "PV Seed List"; break;
			case PV_SEED_LIST_B2B:		sDisplayName = "PV Seed List B2B"; break;
			case PV_SEED_LIST_CANADIAN:	sDisplayName = "PV Seed List Canadian"; break;
			case PV_SEED_LIST_INTERNATIONAL:	sDisplayName = "PV Seed List International"; break;
			case PV_SEED_LIST_CUSTOM:		sDisplayName = "PV Seed List Custom"; break;
			
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
		sw.write("<OPTION value=\"" + GLOBAL_EXCLUSION_LIST + "\"" + ((iSelected == GLOBAL_EXCLUSION_LIST)?" selected":"") + ">Global exclusion list</OPTION>\r\n");
		sw.write("<OPTION value=\"" + RANDOM_TEST_LIST + "\"" + ((iSelected == RANDOM_TEST_LIST)?" selected":"") + ">Random Test list</OPTION>\r\n");
		sw.write("<OPTION value=\"" + CAMPAIGN_EXCLUSION_LIST + "\"" + ((iSelected == CAMPAIGN_EXCLUSION_LIST)?" selected":"") + ">Campaign exclusion list</OPTION>\r\n");
		sw.write("<OPTION value=\"" + AUTORESPOND_NOTIFICATION_LIST_ONE_PER_SUBSCRIBER + "\"" + ((iSelected == AUTORESPOND_NOTIFICATION_LIST_ONE_PER_SUBSCRIBER)?" selected":"") + ">Auto-respond notification list - one per subscriber</OPTION>\r\n");
		sw.write("<OPTION value=\"" + SPECIFIED_TEST_LIST + "\"" + ((iSelected == SPECIFIED_TEST_LIST)?" selected":"") + ">Specified Test list</OPTION>\r\n");
		sw.write("<OPTION value=\"" + AUTORESPOND_NOTIFICATION_LIST_EVERYONE_ON_LIST + "\"" + ((iSelected == AUTORESPOND_NOTIFICATION_LIST_EVERYONE_ON_LIST)?" selected":"") + ">Auto-respond notification list - everyone on list</OPTION>\r\n");
		sw.write("<OPTION value=\"" + DYNAMIC_CONTENT_TEST_LIST + "\"" + ((iSelected == DYNAMIC_CONTENT_TEST_LIST)?" selected":"") + ">Dynamic Content Test list</OPTION>\r\n");
		sw.write("<OPTION value=\"" + PV_SCORER_LIST + "\"" + ((iSelected == PV_SCORER_LIST)?" selected":"") + ">PV Scorer List</OPTION>\r\n");
		sw.write("<OPTION value=\"" + PV_OPTIMIZER_LIST + "\"" + ((iSelected == PV_OPTIMIZER_LIST)?" selected":"") + ">PV Optimizer List</OPTION>\r\n");
		sw.write("<OPTION value=\"" + PV_SEED_LIST + "\"" + ((iSelected == PV_SEED_LIST)?" selected":"") + ">PV Seed List</OPTION>\r\n");
		sw.write("<OPTION value=\"" + PV_SEED_LIST_B2B+ "\"" + ((iSelected == PV_SEED_LIST_B2B)?" selected":"") + ">PV Seed List B2B</OPTION>\r\n");
		sw.write("<OPTION value=\"" + PV_SEED_LIST_CANADIAN + "\"" + ((iSelected == PV_SEED_LIST_CANADIAN)?" selected":"") + ">PV Seed List Canadian</OPTION>\r\n");
		sw.write("<OPTION value=\"" + PV_SEED_LIST_INTERNATIONAL + "\"" + ((iSelected == PV_SEED_LIST_INTERNATIONAL)?" selected":"") + ">PV Seed List International</OPTION>\r\n");
		sw.write("<OPTION value=\"" + PV_SEED_LIST_CUSTOM + "\"" + ((iSelected == PV_SEED_LIST_CUSTOM)?" selected":"") + ">PV Seed List Custom</OPTION>\r\n");
		
		return sw.toString();
	}
}

        
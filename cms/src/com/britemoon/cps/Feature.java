package com.britemoon.cps;

import java.io.*;

final public class Feature
{
	final public static int BRITE_CONNECT = 10;
	final public static int BRITE_TRACK = 20;
	final public static int MS_CRM = 30;
	final public static int CHAPTER_SCRAPES = 40;
	final public static int QUICK_CAMPAIGN = 50;
	final public static int WEB_DM_CALL = 60;		// ALSO FOR HYATT
	final public static int EXPORTS = 70;			// ALSO FOR HYATT
	final public static int RECIPIENT_SEARCH = 80;	// ALSO FOR HYATT
	final public static int DYNAMIC_CONTENT = 90;	// ALSO FOR HYATT
	final public static int EXTERNAL_CONTENT = 100;	// ALSO FOR HYATT
	final public static int IMAGE_LIBRARY = 110;
	final public static int TEMPLATE_ADMIN = 120;
	final public static int GLOBAL_REPORTS = 130;
	final public static int SUPER_REPORTS = 140;
	final public static int CUSTOMIZE_REPORTS = 150;
	final public static int SUBSCRIPTION_ADMIN = 160;
	final public static int AUTO_LINK_SCAN_TEMPLATES = 170;
	final public static int PRINT_ENABLED = 180;	//USE FOR "PRINT FEATURE"
	final public static int HYATT = 200;
	final public static int PRINT_DEMO = 300;		//FOR CHOW-ANDY DEMO ONLY - NOT "PRINT" FEATURE
	final public static int RECIP_OWNERSHIP = 400;		//MONSTER.COM USER/RECIP OWNERSHIP
	//PV IQ Features integrated with Britemoon
	final public static int PV_LOGIN = 500;
	final public static int PV_DESIGN_OPTIMIZER = 510;
	final public static int PV_CONTENT_SCORER = 520;
	final public static int PV_DELIVERY_TRACKER = 530;
        final public static int PV_DELIVERY_TRACKER_SEED_LIST = 531;
        final public static int PV_DELIVERY_TRACKER_B2B = 532;
        final public static int PV_DELIVERY_TRACKER_CANADIAN = 533;
        final public static int PV_DELIVERY_TRACKER_INTERNATIONAL = 534;
        final public static int PV_DELIVERY_TRACKER_CUSTOM = 535;
	//release 5.9 auto report update feature
	final public static int UPDATE_AUTO_REPORT = 540;
	final public static int DYNAMIC_CONTENT_REPORTING = 550;
	final public static int WS_CAMPAIGN = 560;
        
        
	
	//-------------------------
	// SPECIAL HYATT FEATURES
	
	final public static int EXCLUSION_LIST = 2000;
	final public static int NOTIFICATION_LIST = 2001;
	final public static int S2F_CAMP = 2002;
	final public static int AUTO_CAMP = 2003;
	//final public static int WEB_DM_CALL = 2004;
	final public static int FROM_ADDR_PERS = 2005;
	final public static int FROM_NAME_PERS = 2006;
	final public static int FILTER_PREVIEW = 2007;
	final public static int SAMPLE_SET = 2008;
	final public static int CAMP_STEP_2 = 2009;
	final public static int CAMP_STEP_3 = 2010;
	final public static int SEED_LIST = 2011;
	final public static int LINKED_CAMPAIGN = 2012;
	final public static int FREQ_EXCLUSION = 2013;
	final public static int SUBSET_SEND_OUT = 2014;
	final public static int RECIP_THROTTLE = 2015;
	final public static int QUEUE_STEP = 2016;
	final public static int SPECIFIED_TEST = 2017;
	final public static int TESTING_HELP = 2018;
	final public static int MY_DATABASE = 2019;
	//final public static int EXPORTS = 2020;
	//final public static int RECIPIENT_SEARCH = 2021;
	final public static int MY_CONTENT = 2022;
	//final public static int DYNAMIC_CONTENT = 2023;
	//final public static int EXTERNAL_CONTENT = 2024;
	final public static int AUTO_LINK_NAMES = 2025;
	final public static int HELP_DOC = 2026;
	final public static int FAQS = 2027;
	final public static int SUPPORT_REQUEST = 2028;
	final public static int HELP_SEARCH = 2029;
	final public static int SUBJECT_PERS = 2030;
	final public static int RECOMMENDATION = 730;
	final public static int SMART_WIDGET = 740;
	final public static int CRM_ADS = 750;
	final public static int PERSONAL_SEARCH = 760;
	final public static int WEB_PUSH = 770;
	final public static int CUSTOMER_JOURNEY = 780;
	final public static int PERFORMANCE_HUB = 790;
	final public static int STORE = 800;
	final public static int ECOMMERCE_TRACKING = 810;
	final public static int PRODUCTS = 820;
	final public static int SMTP = 830;
	final public static int IYS = 840;
	final public static int CONTACT_SUPPORT = 850;
	final public static int REPORTS = 860;
	final public static int APP_PUSH = 870;
	final public static int MOBIL_DEV_IVT = 880;
	final public static int MOBIL_DEV_IVT_LITE = 890;
	final public static int FIGENSOFT = 900;
	final public static int SMARTWIDGET = 1000;
	final public static int STICKY_BAR = 1001;
	final public static int POPUP_GROW = 1002;
	final public static int POPUP_LOYALTY = 1003;
	final public static int POPUP_RECO = 1004;
	final public static int DRAWER = 1005;
	final public static int RECENTLY_VIEW = 1006;
	final public static int BLOCKED_WEBPUSH = 1007;
	final public static int EXIT_INTENT = 1008;
	final public static int NOTIFICATION_CENTER = 1009;
	final public static int STICKY_BAR_COUNTER = 1010;
	final public static int PRODUCT_ALERT = 1011;
	final public static int DRAWER_DISCOUNT = 1012;
	final public static int COUNTDOWN = 1013;
	final public static int DEAL_BOX = 1014;
	final public static int DEAL_DAY = 1015;
	final public static int UPSELL_PROGRESS = 1016;
	final public static int CART_UPSELL = 1017;
	final public static int REVOTAG = 1018;
	final public static int INTASTORY = 1019;
	final public static int SOCIAL_PROOF = 1020;
	final public static int PAGES = 1021;
	final public static int RECOMINDER = 1022;
	final public static int WHATSAPP = 1023;
	final public static int SCRIPT = 1024;
	final public static int AB_TEST = 1025;
	final public static int SCRATCH_OFF = 1026;
	final public static int BACKINSTOCK = 1027;

	// Added as a part of release 6.0 : resubscribe recipient
	final public static int RECIP_RESUBSCRIBE = 600;
	//release 6.1: Add UNSUB_EDIT feature to turn on/off
	final public static int UNSUB_EDIT = 610;
	//-------------------------

	// === === ===

	public static String getDisplayName(int iContStatus)
	{
		String sDisplayName = "UNKNOWN";

		switch (iContStatus)
		{
			case BRITE_CONNECT:			sDisplayName = "BriteConnect"; break;
			case BRITE_TRACK:			sDisplayName = "BriteTrack"; break;
			case MS_CRM:				sDisplayName = "MS CRM System"; break;
			case CHAPTER_SCRAPES:		sDisplayName = "Chapter Scrapes"; break;
			case QUICK_CAMPAIGN:		sDisplayName = "Quick Campaigns"; break;
			case WEB_DM_CALL:			sDisplayName = "Web / DM / Call Campaigns"; break;
			case EXPORTS:				sDisplayName = "Exports"; break;
			case RECIPIENT_SEARCH:		sDisplayName = "Recipient Search"; break;
			case DYNAMIC_CONTENT:		sDisplayName = "Dynamic Content"; break;
			case EXTERNAL_CONTENT:		sDisplayName = "External Content"; break;
			case IMAGE_LIBRARY:			sDisplayName = "Image Library"; break;
			case TEMPLATE_ADMIN:		sDisplayName = "Template Admin"; break;
			case GLOBAL_REPORTS:		sDisplayName = "Global Reports"; break;
			case SUPER_REPORTS:			sDisplayName = "Super Reports"; break;
			case CUSTOMIZE_REPORTS:		sDisplayName = "Customize Reports"; break;
			case PV_LOGIN:				sDisplayName = "Delivery Auditing"; break;
			case PV_DESIGN_OPTIMIZER:   sDisplayName = "eDesign Optimizer"; break;
			case PV_CONTENT_SCORER:		sDisplayName = "eContent Scorer"; break;
			case PV_DELIVERY_TRACKER: 	sDisplayName = "eDelivery Tracker"; break;
			case SUBSCRIPTION_ADMIN:	sDisplayName = "Subscription Form Admin"; break;
			case AUTO_LINK_SCAN_TEMPLATES:	sDisplayName = "Auto Link Scan Templates"; break;
			case PRINT_ENABLED:			sDisplayName = "Print Enabled"; break;
			case HYATT:					sDisplayName = "Hyatt System"; break;
			case PRINT_DEMO:			sDisplayName = "Print Demo"; break;
			case RECIP_OWNERSHIP:			sDisplayName = "Recipient Ownership"; break;
			case DYNAMIC_CONTENT_REPORTING:	sDisplayName = "Dynamic Content Reporting"; break;
			case WS_CAMPAIGN:			sDisplayName = "Web Service Campaign"; break;
			case RECOMMENDATION:			sDisplayName = "Recommendation"; break;
			case SMART_WIDGET:			sDisplayName = "Smart Widget"; break;
			case WEB_PUSH:			sDisplayName = "Web Push"; break;
			case PERSONAL_SEARCH:			sDisplayName = "Personal Search"; break;
			case CRM_ADS:			sDisplayName = "CRM Ads"; break;
			case CUSTOMER_JOURNEY:			sDisplayName = "Customer Journey"; break;
			case PERFORMANCE_HUB:			sDisplayName = "Performance HUB"; break;
			case STORE:			sDisplayName = "Store"; break;
			case ECOMMERCE_TRACKING:			sDisplayName = "Ecommerce Tracking"; break;
			case PRODUCTS:			sDisplayName = "Products"; break;
			case IYS:			sDisplayName = "IYS"; break;
			case REPORTS:			sDisplayName = "Reports"; break;
			case APP_PUSH:			sDisplayName = "App Push"; break;
			case MOBIL_DEV_IVT:			sDisplayName = "Mobil Dev IVT"; break;
			case MOBIL_DEV_IVT_LITE:			sDisplayName = "Mobil Dev IVT Lite"; break;
			case FIGENSOFT:			sDisplayName = "Figensoft"; break;
			case SMARTWIDGET:			sDisplayName = "Smartwidget"; break;
			case STICKY_BAR:			sDisplayName = "Sticky Bar"; break;
			case POPUP_GROW:			sDisplayName = "Popup Grow"; break;
			case POPUP_LOYALTY:			sDisplayName = "Popup Loyalty"; break;
			case POPUP_RECO:			sDisplayName = "Popup Reco"; break;
			case DRAWER:			sDisplayName = "Drawer"; break;
			case RECENTLY_VIEW:			sDisplayName = "Recently View"; break;
			case BLOCKED_WEBPUSH:			sDisplayName = "Blocked Webpush"; break;
			case EXIT_INTENT:			sDisplayName = "Exit Intent"; break;
			case NOTIFICATION_CENTER:			sDisplayName = "Notification Center"; break;
			case STICKY_BAR_COUNTER:			sDisplayName = "Sticky Bar Counter"; break;
			case PRODUCT_ALERT:			sDisplayName = "Product Alert"; break;
			case DRAWER_DISCOUNT:			sDisplayName = "Drawer Discount"; break;
			case COUNTDOWN:			sDisplayName = "Countdown"; break;
			case DEAL_BOX:			sDisplayName = "Deal Box"; break;
			case DEAL_DAY:			sDisplayName = "Deal Day"; break;
			case UPSELL_PROGRESS:			sDisplayName = "Upsell Progress"; break;
			case CART_UPSELL:			sDisplayName = "Cart Upsell"; break;
			case REVOTAG:			sDisplayName = "Revotag"; break;
			case INTASTORY:			sDisplayName = "Intastory"; break;
			case SOCIAL_PROOF:			sDisplayName = "Social Proof"; break;
			case PAGES:			sDisplayName = "Pages"; break;
			case RECOMINDER:			sDisplayName = "Recominder"; break;
			case WHATSAPP:			sDisplayName = "Whatsapp"; break;
			case SCRIPT:			sDisplayName = "Script"; break;
			case AB_TEST:			sDisplayName = "AB Test"; break;
			case SCRATCH_OFF:			sDisplayName = "Scratch Off"; break;
			case BACKINSTOCK:			sDisplayName = "Backinstock"; break;
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
		sw.write("<OPTION value=\"" + BRITE_CONNECT + "\"" + ((iSelected == CHAPTER_SCRAPES)?" selected":"") + ">BriteConnect</OPTION>\r\n");
		sw.write("<OPTION value=\"" + BRITE_TRACK + "\"" + ((iSelected == BRITE_TRACK)?" selected":"") + ">BriteTrack</OPTION>\r\n");
		sw.write("<OPTION value=\"" + MS_CRM + "\"" + ((iSelected == MS_CRM)?" selected":"") + ">MS CRM System</OPTION>\r\n");
		sw.write("<OPTION value=\"" + CHAPTER_SCRAPES + "\"" + ((iSelected == CHAPTER_SCRAPES)?" selected":"") + ">Chapter Scrapes</OPTION>\r\n");
		sw.write("<OPTION value=\"" + QUICK_CAMPAIGN + "\"" + ((iSelected == QUICK_CAMPAIGN)?" selected":"") + ">Quick Campaigns</OPTION>\r\n");
		sw.write("<OPTION value=\"" + WEB_DM_CALL + "\"" + ((iSelected == WEB_DM_CALL)?" selected":"") + ">Web / DM / Call Campaigns</OPTION>\r\n");
		sw.write("<OPTION value=\"" + EXPORTS + "\"" + ((iSelected == EXPORTS)?" selected":"") + ">Exports</OPTION>\r\n");
		sw.write("<OPTION value=\"" + RECIPIENT_SEARCH + "\"" + ((iSelected == RECIPIENT_SEARCH)?" selected":"") + ">Recipient Search</OPTION>\r\n");
		sw.write("<OPTION value=\"" + DYNAMIC_CONTENT + "\"" + ((iSelected == DYNAMIC_CONTENT)?" selected":"") + ">Dynamic Content</OPTION>\r\n");
		sw.write("<OPTION value=\"" + EXTERNAL_CONTENT + "\"" + ((iSelected == EXTERNAL_CONTENT)?" selected":"") + ">External Content</OPTION>\r\n");
		sw.write("<OPTION value=\"" + IMAGE_LIBRARY + "\"" + ((iSelected == IMAGE_LIBRARY)?" selected":"") + ">Image Library</OPTION>\r\n");
		sw.write("<OPTION value=\"" + TEMPLATE_ADMIN + "\"" + ((iSelected == TEMPLATE_ADMIN)?" selected":"") + ">Template Admin</OPTION>\r\n");
		sw.write("<OPTION value=\"" + GLOBAL_REPORTS + "\"" + ((iSelected == GLOBAL_REPORTS)?" selected":"") + ">Global Reports</OPTION>\r\n");
		sw.write("<OPTION value=\"" + SUPER_REPORTS + "\"" + ((iSelected == SUPER_REPORTS)?" selected":"") + ">Super Reports</OPTION>\r\n");
		sw.write("<OPTION value=\"" + CUSTOMIZE_REPORTS + "\"" + ((iSelected == CUSTOMIZE_REPORTS)?" selected":"") + ">Customize Reports</OPTION>\r\n");
		sw.write("<OPTION value=\"" + PV_LOGIN + "\"" + ((iSelected == PV_LOGIN)?" selected":"") + ">Delivery Auditing</OPTION>\r\n");
		sw.write("<OPTION value=\"" + SUBSCRIPTION_ADMIN + "\"" + ((iSelected == SUBSCRIPTION_ADMIN)?" selected":"") + ">Subscription Form Admin</OPTION>\r\n");
		sw.write("<OPTION value=\"" + AUTO_LINK_SCAN_TEMPLATES + "\"" + ((iSelected == AUTO_LINK_SCAN_TEMPLATES)?" selected":"") + ">Auto Link Scan Templates</OPTION>\r\n");
		sw.write("<OPTION value=\"" + PRINT_ENABLED + "\"" + ((iSelected == PRINT_ENABLED)?" selected":"") + ">Print Enabled</OPTION>\r\n");
		sw.write("<OPTION value=\"" + HYATT + "\"" + ((iSelected == HYATT)?" selected":"") + ">Hyatt System</OPTION>\r\n");
		sw.write("<OPTION value=\"" + PRINT_DEMO + "\"" + ((iSelected == PRINT_DEMO)?" selected":"") + ">Print Demo</OPTION>\r\n");
		sw.write("<OPTION value=\"" + RECIP_OWNERSHIP + "\"" + ((iSelected == RECIP_OWNERSHIP)?" selected":"") + ">Recipient Ownership</OPTION>\r\n");
		sw.write("<OPTION value=\"" + DYNAMIC_CONTENT_REPORTING + "\"" + ((iSelected == DYNAMIC_CONTENT_REPORTING)?" selected":"") + ">Dynamic Content Reporting</OPTION>\r\n");
		sw.write("<OPTION value=\"" + WS_CAMPAIGN + "\"" + ((iSelected == WS_CAMPAIGN)?" selected":"") + ">Web Service Campaign</OPTION>\r\n");
		sw.write("<OPTION value=\"" + RECOMMENDATION + "\"" + ((iSelected == RECOMMENDATION)?" selected":"") + ">Recommendation</OPTION>\r\n");
		sw.write("<OPTION value=\"" + SMART_WIDGET + "\"" + ((iSelected == SMART_WIDGET)?" selected":"") + ">Smart Widget</OPTION>\r\n");
		sw.write("<OPTION value=\"" + WEB_PUSH + "\"" + ((iSelected == WEB_PUSH)?" selected":"") + ">Web Push</OPTION>\r\n");
		sw.write("<OPTION value=\"" + PERSONAL_SEARCH + "\"" + ((iSelected == PERSONAL_SEARCH)?" selected":"") + ">Personal Search</OPTION>\r\n");
		sw.write("<OPTION value=\"" + CRM_ADS + "\"" + ((iSelected == CRM_ADS)?" selected":"") + ">CRM Ads</OPTION>\r\n");
		sw.write("<OPTION value=\"" + CUSTOMER_JOURNEY + "\"" + ((iSelected == CUSTOMER_JOURNEY)?" selected":"") + ">Customer Journey</OPTION>\r\n");
		sw.write("<OPTION value=\"" + STORE + "\"" + ((iSelected == STORE)?" selected":"") + ">Store</OPTION>\r\n");
		sw.write("<OPTION value=\"" + ECOMMERCE_TRACKING + "\"" + ((iSelected == ECOMMERCE_TRACKING)?" selected":"") + ">Ecommerce Tracking</OPTION>\r\n");
		sw.write("<OPTION value=\"" + PRODUCTS + "\"" + ((iSelected == PRODUCTS)?" selected":"") + ">Products</OPTION>\r\n");
		sw.write("<OPTION value=\"" + SMTP + "\"" + ((iSelected == SMTP)?" selected":"") + ">SMTP</OPTION>\r\n");
		sw.write("<OPTION value=\"" + IYS + "\"" + ((iSelected == IYS)?" selected":"") + ">IYS</OPTION>\r\n");
		sw.write("<OPTION value=\"" + CONTACT_SUPPORT + "\"" + ((iSelected == CONTACT_SUPPORT)?" selected":"") + ">Contact Support</OPTION>\r\n");
		sw.write("<OPTION value=\"" + REPORTS + "\"" + ((iSelected == REPORTS)?" selected":"") + ">Reports</OPTION>\r\n");
		sw.write("<OPTION value=\"" + APP_PUSH + "\"" + ((iSelected == APP_PUSH)?" selected":"") + ">App Push</OPTION>\r\n");
		sw.write("<OPTION value=\"" + MOBIL_DEV_IVT + "\"" + ((iSelected == MOBIL_DEV_IVT)?" selected":"") + ">Mobil Dev IVT</OPTION>\r\n");
		sw.write("<OPTION value=\"" + MOBIL_DEV_IVT_LITE + "\"" + ((iSelected == MOBIL_DEV_IVT_LITE)?" selected":"") + ">Mobil Dev IVT Lite</OPTION>\r\n");
		sw.write("<OPTION value=\"" + FIGENSOFT + "\"" + ((iSelected == FIGENSOFT)?" selected":"") + ">Figensoft</OPTION>\r\n");
		sw.write("<OPTION value=\"" + SMARTWIDGET + "\"" + ((iSelected == SMARTWIDGET)?" selected":"") + ">Smartwidget</OPTION>\r\n");
		sw.write("<OPTION value=\"" + STICKY_BAR + "\"" + ((iSelected == STICKY_BAR)?" selected":"") + ">Sticky Bar</OPTION>\r\n");
		sw.write("<OPTION value=\"" + POPUP_GROW + "\"" + ((iSelected == POPUP_GROW)?" selected":"") + ">Popup Grow</OPTION>\r\n");
		sw.write("<OPTION value=\"" + POPUP_LOYALTY + "\"" + ((iSelected == POPUP_LOYALTY)?" selected":"") + ">Popup Loyalty</OPTION>\r\n");
		sw.write("<OPTION value=\"" + POPUP_RECO + "\"" + ((iSelected == POPUP_RECO)?" selected":"") + ">Popup Reco</OPTION>\r\n");
		sw.write("<OPTION value=\"" + DRAWER + "\"" + ((iSelected == DRAWER)?" selected":"") + ">Drawer</OPTION>\r\n");
		sw.write("<OPTION value=\"" + RECENTLY_VIEW + "\"" + ((iSelected == RECENTLY_VIEW)?" selected":"") + ">Recently View</OPTION>\r\n");
		sw.write("<OPTION value=\"" + BLOCKED_WEBPUSH + "\"" + ((iSelected == BLOCKED_WEBPUSH)?" selected":"") + ">Blocked Webpush</OPTION>\r\n");
		sw.write("<OPTION value=\"" + EXIT_INTENT + "\"" + ((iSelected == EXIT_INTENT)?" selected":"") + ">Exit Intent</OPTION>\r\n");
		sw.write("<OPTION value=\"" + NOTIFICATION_CENTER + "\"" + ((iSelected == NOTIFICATION_CENTER)?" selected":"") + ">Notification Center</OPTION>\r\n");
		sw.write("<OPTION value=\"" + STICKY_BAR_COUNTER + "\"" + ((iSelected == STICKY_BAR_COUNTER)?" selected":"") + ">Sticky Bar Counter</OPTION>\r\n");
		sw.write("<OPTION value=\"" + PRODUCT_ALERT + "\"" + ((iSelected == PRODUCT_ALERT)?" selected":"") + ">Product Alert</OPTION>\r\n");
		sw.write("<OPTION value=\"" + DRAWER_DISCOUNT + "\"" + ((iSelected == DRAWER_DISCOUNT)?" selected":"") + ">Drawer Discount</OPTION>\r\n");
		sw.write("<OPTION value=\"" + COUNTDOWN + "\"" + ((iSelected == COUNTDOWN)?" selected":"") + ">Countdown</OPTION>\r\n");
		sw.write("<OPTION value=\"" + DEAL_BOX + "\"" + ((iSelected == DEAL_BOX)?" selected":"") + ">Deal Box</OPTION>\r\n");
		sw.write("<OPTION value=\"" + DEAL_DAY + "\"" + ((iSelected == DEAL_DAY)?" selected":"") + ">Deal Day</OPTION>\r\n");
		sw.write("<OPTION value=\"" + UPSELL_PROGRESS + "\"" + ((iSelected == UPSELL_PROGRESS)?" selected":"") + ">Upsell Progress</OPTION>\r\n");
		sw.write("<OPTION value=\"" + CART_UPSELL + "\"" + ((iSelected == CART_UPSELL)?" selected":"") + ">Cart Upsell</OPTION>\r\n");
		sw.write("<OPTION value=\"" + REVOTAG + "\"" + ((iSelected == REVOTAG)?" selected":"") + ">Revotag</OPTION>\r\n");
		sw.write("<OPTION value=\"" + INTASTORY + "\"" + ((iSelected == INTASTORY)?" selected":"") + ">Intastory</OPTION>\r\n");
		sw.write("<OPTION value=\"" + SOCIAL_PROOF + "\"" + ((iSelected == SOCIAL_PROOF)?" selected":"") + ">Social Proof</OPTION>\r\n");
		sw.write("<OPTION value=\"" + PAGES + "\"" + ((iSelected == PAGES)?" selected":"") + ">Pages</OPTION>\r\n");
		sw.write("<OPTION value=\"" + RECOMINDER + "\"" + ((iSelected == RECOMINDER)?" selected":"") + ">Recominder</OPTION>\r\n");
		sw.write("<OPTION value=\"" + WHATSAPP + "\"" + ((iSelected == WHATSAPP)?" selected":"") + ">Whatsapp</OPTION>\r\n");
		sw.write("<OPTION value=\"" + SCRIPT + "\"" + ((iSelected == SCRIPT)?" selected":"") + ">Script</OPTION>\r\n");
		sw.write("<OPTION value=\"" + AB_TEST + "\"" + ((iSelected == AB_TEST)?" selected":"") + ">AB Test</OPTION>\r\n");
		sw.write("<OPTION value=\"" + SCRATCH_OFF + "\"" + ((iSelected == SCRATCH_OFF)?" selected":"") + ">Scratch Off</OPTION>\r\n");
		sw.write("<OPTION value=\"" + BACKINSTOCK + "\"" + ((iSelected == BACKINSTOCK)?" selected":"") + ">Backinstock</OPTION>\r\n");

		return sw.toString();
	}
}

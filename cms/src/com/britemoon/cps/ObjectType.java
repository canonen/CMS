package com.britemoon.cps;

public final class ObjectType
{
//	final public static int CUSTOMER = 100; 
	final public static int RECIPIENT = 110;
	final public static int RECIPIENT_ATTRIBUTE = 120;
	final public static int LINK_ID = 130;
	final public static int FORM = 140;
	final public static int BATCH = 150;
	final public static int IMPORT = 160;
	final public static int CONTENT = 170;
//	final public static int PARAGRAPH = 180;
	final public static int CAMPAIGN = 190;
	final public static int CAMPAIGN_APPROVAL = 195;
	final public static int FILTER = 200;
	final public static int FORMULA = 210;
	final public static int USER = 220;
	final public static int CAMPAIGN_REPORT = 230;
	final public static int CATEGORY = 240;
	final public static int EXPORT = 250;
	final public static int LOGIC_BLOCK = 260;	
	final public static int IMAGE = 270;
	final public static int USER_NOTES = 300;
	// added for release 5.9 , pviq reporting changes
	final public static int PV_DESIGN_OPTIMIZER = 310;
	final public static int PV_CONTENT_SCORER = 320;
	final public static int PV_DELIVERY_TRACKER = 330;
	
	// added as a part of release 6.0 : Resubscribe recipient
	final public static int RECIP_RESUBSCRIBE = 340;
	// release 6.1: Unsubscribe messages
	final public static int UNSUB_EDIT = 350;
	final public static int OFFER = 360;
	
	public static String getDisplayName(int iObjectType)
	{
		String sDisplayName = "UNKNOWN";

		switch (iObjectType)
		{
               case RECIPIENT:			                    sDisplayName = "Recipient"; break;
               case RECIPIENT_ATTRIBUTE:			sDisplayName = "Recipient Attribute"; break;
               case LINK_ID:			                         sDisplayName = "Link ID"; break;
               case FORM:			                         sDisplayName = "Form"; break;
               case BATCH:			                         sDisplayName = "Batch"; break;
               case IMPORT:			                         sDisplayName = "Import"; break;
               case CONTENT:			                    sDisplayName = "Content"; break;
               case CAMPAIGN:			                    sDisplayName = "Campaign"; break;
               case CAMPAIGN_APPROVAL:			sDisplayName = "Campaign Approval"; break;
               case FILTER:			                         sDisplayName = "Target Group"; break;
               case FORMULA:			                    sDisplayName = "Formula"; break;
               case USER:			                              sDisplayName = "User"; break;
               case CAMPAIGN_REPORT:			     sDisplayName = "Campaign Report"; break;
               //added for release 5.9 , pv reporting changes
               case PV_DESIGN_OPTIMIZER:				sDisplayName = "eDesign Optimizer"; break;
               case PV_CONTENT_SCORER:				sDisplayName = "eContent Scorer"; break;
               case PV_DELIVERY_TRACKER:				sDisplayName = "eDelivery Tracker"; break;
               case CATEGORY:			               sDisplayName = "Category"; break;
               case EXPORT:			                         sDisplayName = "Export"; break;
               case LOGIC_BLOCK:			          sDisplayName = "Logic Block"; break;
               case IMAGE:			                         sDisplayName = "Image"; break;
               case USER_NOTES:			               sDisplayName = "User Note"; break;
               case OFFER:			               sDisplayName = "Offer"; break;
		}

		return sDisplayName;
	}
	// === === ===

     
}

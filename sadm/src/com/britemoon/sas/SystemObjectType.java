package com.britemoon.sas;

import com.britemoon.*;

public final class SystemObjectType
{
	final public static int CUSTOMER = 100;
	final public static int CUSTOMER_USER = 110;
	final public static int ENTITY = 150;
	final public static int SERVER = 200;
	final public static int HELP_DOC = 310;
	final public static int FAQ = 320;
	final public static int SUPPORT_TICKET = 330;
	final public static int BILLING = 400;
	final public static int SYSTEM_USER = 510;
	final public static int PARTNER = 520;
	final public static int SYSTEM_NOTE = 530;
	final public static int HOST_MONITOR = 540;
	final public static int REGISTRY = 550;
	final public static int DELIVERY_MONITOR = 560;

	public static String getDisplayName(int iObjectType)
	{
		String sDisplayName = "UNKNOWN";

		switch (iObjectType)
		{
               case CUSTOMER:		sDisplayName = "Customer"; break;
               case CUSTOMER_USER:	sDisplayName = "Customer Users"; break;
               case ENTITY:			sDisplayName = "System Entities"; break;
               case SERVER:			sDisplayName = "Servers"; break;
               case HELP_DOC:		sDisplayName = "Help Document"; break;
               case FAQ:			sDisplayName = "FAQs"; break;
               case SUPPORT_TICKET:	sDisplayName = "Support Tickets"; break;
               case BILLING:		sDisplayName = "Billing"; break;
               case SYSTEM_USER:	sDisplayName = "System Users"; break;
               case PARTNER:		sDisplayName = "Partners"; break;
               case SYSTEM_NOTE:	sDisplayName = "System Notes"; break;
               case HOST_MONITOR:	sDisplayName = "Host Monitor"; break;
               case REGISTRY:		sDisplayName = "Registry"; break;
               case DELIVERY_MONITOR:	sDisplayName = "Delivery Monitor"; break;
		}

		return sDisplayName;
	}
	// === === ===

     
}
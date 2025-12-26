package com.britemoon.sas;

import com.britemoon.*;

public final class SystemUserActivityType
{
	final public static int USER_LOGIN = 10;
	final public static int SYSTEM_ADMIN = 20;
	
	public static String getDisplayName(int iObjectType)
	{
		String sDisplayName = "UNKNOWN";

		switch (iObjectType)
		{
               case USER_LOGIN:		sDisplayName = "User Login"; break;
               case SYSTEM_ADMIN:	sDisplayName = "System Admin Page"; break;
		}

		return sDisplayName;
	}
	// === === ===

     
}
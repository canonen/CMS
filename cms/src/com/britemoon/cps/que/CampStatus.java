package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CampStatus
{
	String s_camp_id = null;
	String s_status_id = null;
	private static Logger logger = Logger.getLogger(CampStatus.class.getName());
	
	// === === ===

	public CampStatus()
	{
	}
		
	public CampStatus (Element e) throws Exception
	{
		fromXml(e);
	}

	// === === ===
	
	private void fromXml(Element e) throws Exception
	{
		if(!e.getNodeName().equals("camp_status"))
			throw new Exception("Malformed camp_stat xml.");

		s_camp_id = XmlUtil.getChildTextValue(e, "camp_id");
		s_status_id = XmlUtil.getChildTextValue(e, "status_id");
	}

	// === === ===
	
	public void save() throws SQLException
	{
		String sSql =
				" UPDATE cque_campaign" +
				" SET status_id = " + s_status_id +
				" WHERE camp_id = " + s_camp_id +
				" AND" +
				" (status_id = " + CampaignStatus.WAITING +
				" OR status_id < " + s_status_id + ")";

		BriteUpdate.executeUpdate(sSql);
	}
}
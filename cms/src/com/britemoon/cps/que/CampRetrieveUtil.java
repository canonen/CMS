package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.cnt.*;
import com.britemoon.cps.tgt.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CampRetrieveUtil
{
	private static Logger logger = Logger.getLogger(CampRetrieveUtil.class.getName());
	public static void retrieve4UI(Campaign campaign) throws Exception
	{
		if(campaign.s_camp_id == null) return;
		if(campaign.retrieve() < 1) return;
	
		retrieveCampList(campaign);
		retrieveCampSendParam(campaign);
		retrieveSchedule(campaign);
		retrieveCampEditInfo(campaign);
		retrieveMsgHeader(campaign);
	}
	
	public static void retrieve4Rcp(Campaign campaign) throws Exception
	{
		if(campaign.s_camp_id == null) return;
		if(campaign.retrieve() < 1) return;
		
		retrieveContent4Rcp(campaign);
		retrieveFilter4Rcp(campaign);
		retrieveSeedList4Rcp(campaign);		
		retrieveCampList(campaign);
		retrieveCampSendParam(campaign);
		retrieveSchedule(campaign);
		retrieveCampSampleset(campaign);		
	}
	
	public static void retrieveContent4Rcp(Campaign campaign) throws Exception
	{
		if (campaign.s_cont_id == null) return;
		Content content = new Content();
		content.s_cont_id = campaign.s_cont_id;
		ContRetrieveUtil.retrieve4Rcp(content);
		campaign.m_Content = content;
	}
	
	public static void retrieveFilter4Rcp(Campaign campaign) throws Exception
	{
		if (campaign.s_filter_id == null) return;
		Filter filter = new Filter();
		filter.s_filter_id = campaign.s_filter_id;
		FilterRetrieveUtil.retrieve4Rcp(filter);
		campaign.m_Filter = filter;
	}

	public static void retrieveSeedList4Rcp(Campaign campaign) throws Exception
	{
		if (campaign.s_seed_list_id == null) return;
		SeedList seed_list = new SeedList();
		seed_list.s_filter_id = campaign.s_seed_list_id;
		FilterRetrieveUtil.retrieve4Rcp(seed_list);
		campaign.m_SeedList = seed_list;
	}
	
	// === === ===

	public static void retrieveCampList(Campaign campaign) throws Exception
	{
		if(campaign.s_camp_id == null) return;
		campaign.m_CampList = new CampList(campaign.s_camp_id);
	}
	
	public static void retrieveCampSendParam(Campaign campaign) throws Exception
	{
		if(campaign.s_camp_id == null) return;
		campaign.m_CampSendParam = new CampSendParam(campaign.s_camp_id);
	}

	public static void retrieveSchedule(Campaign campaign) throws Exception
	{
		if(campaign.s_camp_id == null) return;
		campaign.m_Schedule = new Schedule(campaign.s_camp_id);
	}

	public static void retrieveCampSampleset(Campaign campaign) throws Exception
	{
		if(campaign.s_origin_camp_id == null) return;
		CampSampleset cs = new CampSampleset();
		cs.s_camp_id = campaign.s_origin_camp_id;
		if(cs.retrieve() < 1 ) return;
		campaign.m_CampSampleset = cs;
	}

	// === === ===

	public static void retrieveCampEditInfo(Campaign campaign) throws Exception
	{
		if(campaign.s_camp_id == null) return;
		campaign.m_CampEditInfo = new CampEditInfo(campaign.s_camp_id);
	}

	public static void retrieveMsgHeader(Campaign campaign) throws Exception
	{
		if(campaign.s_camp_id == null) return;
		campaign.m_MsgHeader = new MsgHeader(campaign.s_camp_id);
	}
}

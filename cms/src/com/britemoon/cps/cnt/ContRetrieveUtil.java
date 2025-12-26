package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.tgt.*;
import com.britemoon.cps.jtk.*;
import org.apache.log4j.*;

import java.util.*;

public class ContRetrieveUtil
{
	private static Logger logger = Logger.getLogger(ContRetrieveUtil.class.getName());
	public static void retrieve4UI(Content content) throws Exception
	{
		if(content.s_cont_id == null) return;
		content.retrieve();
		
		// === === ===
		
		retriveContTree(content, true, true, false);
		retriveContSendParam(content);
		retriveContEditInfo(content);
		retriveLinks(content);
	}
	
	// === === ===

	public static void retrieve4Rcp(Content content) throws Exception
	{
		if(content.s_cont_id == null) return;
		retriveContTree(content, false, true, true);
		retriveLinks(content);
	}

	// === === ===

	public static void retriveContTree
		(Content content, boolean bIncludeContentBody, boolean bIncludeContentParts, boolean bIncludeFilters)
			throws Exception
	{
		retriveContTree(content, bIncludeContentBody, bIncludeContentParts, bIncludeFilters, false);
	}

	public static void retriveContTree
		(Content content, boolean bIncludeContentBody, boolean bIncludeContentParts, boolean bIncludeFilters, boolean bIncludeContSendParam)
			throws Exception
	{
		if (content.s_cont_id == null) return;
		if (content.retrieve() < 1)  return;
		if (bIncludeContentParts) retriveContParts(content, bIncludeContentBody, bIncludeContentParts, bIncludeFilters, bIncludeContSendParam);
		if (bIncludeContentBody) retrieveContBody(content);	
		if (bIncludeContSendParam) retriveContSendParam(content);	
	}
	
	public static void retriveContSendParam(Content content) throws Exception
	{
		if(content.s_cont_id == null) return;

		ContSendParam cont_send_param = new ContSendParam();
		cont_send_param.s_cont_id = content.s_cont_id;
		if(cont_send_param.retrieve() > 0) content.m_ContSendParam = cont_send_param;
	}

	public static void retriveContEditInfo(Content content) throws Exception
	{
		if(content.s_cont_id == null) return;

		ContEditInfo cont_edit_info = new ContEditInfo();
		cont_edit_info.s_cont_id = content.s_cont_id;
		if(cont_edit_info.retrieve() > 0) content.m_ContEditInfo = cont_edit_info;
	}

	public static void retrieveContBody(Content content) throws Exception
	{
		if(content.s_cont_id == null) return;
			
		ContBody cont_body = new ContBody();
		cont_body.s_cont_id = content.s_cont_id;
		if(cont_body.retrieve() > 0) content.m_ContBody = cont_body;
	}

	// === === ===
	
	public static void retriveContParts
		(Content content, boolean bIncludeContentBody, boolean bIncludeContentParts, boolean bIncludeFilters)
			throws Exception
	{
		retriveContParts(content, bIncludeContentBody, bIncludeContentParts, bIncludeFilters, false);

	}

	public static void retriveContParts
		(Content content, boolean bIncludeContentBody, boolean bIncludeContentParts, boolean bIncludeFilters, boolean bIncludeContSendParam)
			throws Exception
	{
		if(content.s_cont_id == null) return;

		ContParts cont_parts = new ContParts();
		cont_parts.s_parent_cont_id = content.s_cont_id;
		if(cont_parts.retrieve() > 0)
		{
			ContPart cont_part = null;
			for (Enumeration e = cont_parts.elements() ; e.hasMoreElements() ;)
			{
				cont_part = (ContPart) e.nextElement();
				retriveContPartChildContent(cont_part,  bIncludeContentBody, bIncludeContentParts, bIncludeFilters, bIncludeContSendParam);
				if (bIncludeFilters) retrieveContPartFilter(cont_part);				
			}
		}
		content.m_ContParts = cont_parts;
	}

	public static void retriveContPartChildContent
		(ContPart cont_part, boolean bIncludeContentBody, boolean bIncludeContentParts, boolean bIncludeFilters)
			throws Exception
	{
		retriveContPartChildContent (cont_part, bIncludeContentBody, bIncludeContentParts, bIncludeFilters, false);
	}

	public static void retriveContPartChildContent
		(ContPart cont_part, boolean bIncludeContentBody, boolean bIncludeContentParts, boolean bIncludeFilters, boolean bIncludeContSendParam)
			throws Exception
	{
		if(cont_part.s_child_cont_id == null) return;
		Content child_content = new Content();
		child_content.s_cont_id = cont_part.s_child_cont_id;
		retriveContTree(child_content, bIncludeContentBody, bIncludeContentParts, bIncludeFilters, bIncludeContSendParam);
		cont_part.m_ChildContent = child_content;
	}
	
	public static void retrieveContPartFilter(ContPart cont_part) throws Exception
	{
		if(cont_part.s_filter_id == null) return;
		Filter filter = new Filter();
		filter.s_filter_id = cont_part.s_filter_id;
		FilterRetrieveUtil.retrieve4Rcp(filter);
		cont_part.m_Filter = filter;		
	}
	
	// === === ===
	
	public static void retriveLinks(Content content) throws Exception
	{
		if(content.s_cont_id == null) return;

		Links links = new Links();
		links.s_cont_id = content.s_cont_id;
		links.retrieve();
		content.m_Links = links;
	}
}

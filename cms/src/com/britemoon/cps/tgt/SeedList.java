package com.britemoon.cps.tgt;

import org.w3c.dom.*;

public class SeedList extends Filter
{
	{
		m_sMainElementName = "seed_list";
	}
	
	public SeedList()
	{
	}
	
	public SeedList(String sFilterId) throws Exception
	{
		s_filter_id = sFilterId;
		retrieve();
	}

	public SeedList(Element e) throws Exception
	{
		fromXml(e);
	}
}


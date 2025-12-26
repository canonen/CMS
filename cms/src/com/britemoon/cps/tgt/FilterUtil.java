package com.britemoon.cps.tgt;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.imc.*;

import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class FilterUtil
{
	private static Logger logger = Logger.getLogger(FilterUtil.class.getName());
	public static void sendFilterUpdateRequestToRcp(String sFilterId) throws Exception
	{
		if( sFilterId == null)
			throw new Exception ("Invalid filter id");

		com.britemoon.cps.tgt.Filter f = new com.britemoon.cps.tgt.Filter();
		f.s_filter_id = sFilterId;
		FilterRetrieveUtil.retrieve4Rcp(f);
		f.s_status_id = String.valueOf(FilterStatus.QUEUED_FOR_PROCESSING);

		// === === ===

		String sRcpResponse = Service.communicate(ServiceType.RTGT_FILTER_SETUP, f.s_cust_id, f.toXml());

		//Just validate response
		XmlUtil.getRootElement(sRcpResponse);

		// === === ===
		
		FilterStatistic fs = new FilterStatistic();
		fs.s_filter_id = f.s_filter_id;
		fs.delete();

		// === === ===

		f.setStatus(FilterStatus.QUEUED_FOR_PROCESSING);
	}
	
	public static Filter createIpmortFilter
		(String sCustId, String sImportId, String sImportName)
			throws Exception
	{
		Filter childFilter = new com.britemoon.cps.tgt.Filter();

		childFilter.s_cust_id = sCustId;
		childFilter.s_filter_name = "(IMPORT) " + sImportName;
		childFilter.s_type_id = String.valueOf(FilterType.IMPORT);
		childFilter.s_status_id = String.valueOf(FilterStatus.NEW);
		childFilter.s_usage_type_id = String.valueOf(FilterUsageType.HIDDEN);			

		// === === ===
		
		FilterParams params = null;
		FilterParam param = null;

		param = new FilterParam();
		param.s_param_name = "import_id";
		param.s_integer_value = String.valueOf(sImportId);

		params = new FilterParams();
		params.add(param);

		childFilter.m_FilterParams = params;

		// === === ===
		
		Filter parentFilter = new Filter();

		parentFilter.s_cust_id = sCustId;
		parentFilter.s_filter_name = sImportName;
		parentFilter.s_type_id = String.valueOf(FilterType.MULTIPART);
		parentFilter.s_status_id = String.valueOf(FilterStatus.NEW);
		parentFilter.s_usage_type_id = String.valueOf(FilterUsageType.REGULAR);

		// === === ===

		param = new FilterParam();
		param.s_param_name = "BOOLEAN OPERATION";
		param.s_string_value = "NOP"; //"NOP" - NO OPERATION

		params = new FilterParams();
		params.add(param);
		
		parentFilter.m_FilterParams = params;
		
		// === === ===
				
		FilterPart part = new FilterPart();
		part.m_ChildFilter = childFilter;

		FilterParts parts = new FilterParts();
		parts.add(part);
		
		parentFilter.m_FilterParts = parts;
		
		// === === ===
								
		parentFilter.save();
		
		return parentFilter; 
	}
	public static Filter createCampContReportFilter(String sCustId, String sCampId, String sCampName, String sContId, String sContName) throws Exception
	{
		FilterParams params = null;
		FilterParam param = null;
		
		// filter part 1
		Filter childFilter1 = new com.britemoon.cps.tgt.Filter();
		childFilter1.s_cust_id = sCustId;
		childFilter1.s_filter_name = "(CONTENT BLOCK) " + sContName;
		childFilter1.s_type_id = String.valueOf(FilterType.CONTENT_BLOCK);
		childFilter1.s_status_id = String.valueOf(FilterStatus.NEW);
		childFilter1.s_usage_type_id = String.valueOf(FilterUsageType.HIDDEN);			
		param = new FilterParam();
		param.s_param_name = "cont_id";
		param.s_integer_value = String.valueOf(sContId);
		params = new FilterParams();
		params.add(param);
		childFilter1.m_FilterParams = params;
		
		// filter part 2
		Filter childFilter2 = new com.britemoon.cps.tgt.Filter();
		childFilter2.s_cust_id = sCustId;
		childFilter2.s_filter_name = "(CAMPAIGN) " + sCampName;
		childFilter2.s_type_id = String.valueOf(FilterType.CAMPAIGN);
		childFilter2.s_status_id = String.valueOf(FilterStatus.NEW);
		childFilter2.s_usage_type_id = String.valueOf(FilterUsageType.HIDDEN);			
		param = new FilterParam();
		param.s_param_name = "camp_id";
		param.s_integer_value = String.valueOf(sCampId);
		params = new FilterParams();
		params.add(param);
		childFilter2.m_FilterParams = params;

		// parent filter
		Filter parentFilter = new Filter();
		parentFilter.s_cust_id = sCustId;
		parentFilter.s_filter_name = "Received Content Block (" + sContName + ") from Campaign (" + sCampName + ")";
		parentFilter.s_type_id = String.valueOf(FilterType.MULTIPART);
		parentFilter.s_status_id = String.valueOf(FilterStatus.NEW);
		parentFilter.s_usage_type_id = String.valueOf(FilterUsageType.REPORT);
		param = new FilterParam();
		param.s_param_name = "BOOLEAN OPERATION";
		param.s_string_value = "AND";
		params = new FilterParams();
		params.add(param);
		parentFilter.m_FilterParams = params;
		
		// add child filters and save
		FilterPart part1 = new FilterPart();
		part1.m_ChildFilter = childFilter1;
		FilterPart part2 = new FilterPart();
		part2.m_ChildFilter = childFilter2;
		FilterParts parts = new FilterParts();
		parts.add(part1);
		parts.add(part2);
		parentFilter.m_FilterParts = parts;
								
		parentFilter.save();
		
		return parentFilter; 
	}

}
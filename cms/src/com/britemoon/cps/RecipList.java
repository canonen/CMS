package com.britemoon.cps;

import java.util.*;

import org.w3c.dom.Element;

import com.britemoon.*;
import com.britemoon.cps.tgt.*;
import com.britemoon.cps.exp.Export;
import com.britemoon.cps.exp.ExportParam;
import com.britemoon.cps.exp.ExportParams;
import org.apache.log4j.Logger;
public class RecipList extends RecipListGeneric
{

/* DEFINED IN RecipListGeneric

	public String s_cust_id = null;
	public String s_recip_id = null;
	public String s_camp_id = null;
	public String s_link_id = null;
	public String s_content_type = null;
	public String s_form_id = null;
	public String s_filter_id = null;
	public String s_batch_id = null;
	public String s_bback_category = null;
	public String s_pnmfamily = null;
	public String s_email_821 = null;
	public String s_num_recips = null;
	public String s_attr_list = null;
	public String s_delimiter = null;
	
	public int n_total_recips = 0;
	public int n_total_returned = 0;

	public String sAction = null;
	public String sQuery = null;

	// === === ===

	public void fromRecipRequestXml(e);
	public String toRecipRequestXml();
	public String toRecipRequestXml(StringWriter sw);
	
	public int getType();
	public static int getType(RecipListGeneric rlg);	
*/
	public RecipList(){}
	
	//Release 6.0: Added for Export Once and Re-run as needed.
	public RecipList (Export exp) throws Exception
	{
		s_cust_id = exp.s_cust_id;
		s_num_recips = "all";
		s_attr_list = exp.s_attr_list;
		s_delimiter = exp.s_delimiter;
		sAction = exp.s_action;

		ExportParams eps = new ExportParams();
		eps.s_file_id = exp.s_file_id;
		eps.s_cust_id = exp.s_cust_id;
		eps.retrieve();

		ExportParam ep = null;
		for (Enumeration e = eps.elements(); e.hasMoreElements() ;)
		{
			ep = (ExportParam)e.nextElement();
			if (ep.s_param_name.equals("camp_id")) s_camp_id = ep.s_param_value;
			else if (ep.s_param_name.equals("chunk_id")) s_chunk_id = ep.s_param_value;
			else if (ep.s_param_name.equals("link_id")) s_link_id = ep.s_param_value;
			else if (ep.s_param_name.equals("content_type")) s_content_type = ep.s_param_value;
			else if (ep.s_param_name.equals("form_id")) s_form_id = ep.s_param_value;
			else if (ep.s_param_name.equals("filter_id")) s_filter_id = ep.s_param_value;
			else if (ep.s_param_name.equals("batch_id")) s_batch_id = ep.s_param_value;
			else if (ep.s_param_name.equals("bback_category")) s_bback_category = ep.s_param_value;
            //	Release 6.1: Spam Complaints 
			else if (ep.s_param_name.equals("unsub_level")) s_unsub_level = ep.s_param_value;
			else if (ep.s_param_name.equals("domain")) s_domain = ep.s_param_value;
			else if (ep.s_param_name.equals("newsletter_id")) s_newsletter_id = ep.s_param_value;
			else if (ep.s_param_name.equals("cache_id")) s_cache_id = ep.s_param_value;
			else if (ep.s_param_name.equals("cache_start_date")) s_cache_start_date = ep.s_param_value;
			else if (ep.s_param_name.equals("cache_end_date")) s_cache_end_date = ep.s_param_value;
			else if (ep.s_param_name.equals("cache_attr_id")) s_cache_attr_id = ep.s_param_value;
			else if (ep.s_param_name.equals("cache_attr_value1")) s_cache_attr_value1 = ep.s_param_value;
			else if (ep.s_param_name.equals("cache_attr_value2")) s_cache_attr_value2 = ep.s_param_value;
			else if (ep.s_param_name.equals("cache_attr_operator")) s_cache_attr_operator = ep.s_param_value;
			else if (ep.s_param_name.equals("cache_user_id")) s_cache_user_id = ep.s_param_value;
		}
	}
	
	public RecipList (Element e) throws Exception
	{
		fromRecipRequestXml(e);
	}
	
	private static Logger logger = Logger.getLogger(RecipList.class.getName());
	// === === ===

	public Filter createFilter(String sFilterName) throws Exception
	{
		return createFilter(sFilterName, this);
	}

	public static Filter createFilter(String sFilterName, RecipList rl) throws Exception
	{
		Filter childFilter = createSimpleFilter(sFilterName, rl);
		Filter formulaFilterAttr = createFormulaFilterAttr(rl);
		Filter formulaFilterUser = createFormulaFilterUser(rl);

		Filter parentFilter = createFilter(sFilterName, childFilter, formulaFilterAttr, formulaFilterUser);

		if ((rl.s_attr_list != null) && (rl.s_attr_list.length() > 0)) {
			PreviewAttrs attrs = new PreviewAttrs();
			
			StringTokenizer st = new StringTokenizer(rl.s_attr_list, ",");
			int i = 0;
			while (st.hasMoreTokens()) {
				String sAttrID = st.nextToken();
				PreviewAttr attr = new PreviewAttr();
				attr.s_attr_id = sAttrID;
				attr.s_display_seq = String.valueOf(i++);
				
				attrs.add(attr);
			}
			parentFilter.m_PreviewAttrs = attrs;
			
			parentFilter.save();
		}

		return parentFilter;
	}

	public static Filter createFilter(String sFilterName, Filter childFilter) throws Exception
	{
		return createFilter(sFilterName, childFilter, null, null);
	}

	public static Filter createFilter(String sFilterName, Filter childFilter, Filter formulaFilterAttr, Filter formulaFilterUser) throws Exception
	{
		Filter parentFilter = new Filter();

		parentFilter.s_type_id = String.valueOf(FilterType.MULTIPART);
		parentFilter.s_filter_name = sFilterName;
		parentFilter.s_cust_id = childFilter.s_cust_id;
		parentFilter.s_status_id = String.valueOf(FilterStatus.NEW);

		// === === ===

		FilterParam param = new FilterParam();
		param.s_param_name = "BOOLEAN OPERATION";
		if (formulaFilterAttr != null || formulaFilterUser != null) {
			param.s_string_value = "AND";
		} else {
			param.s_string_value = "NOP"; //"NOP" - NO OPERATION
		}
		
		FilterParams params = new FilterParams();
		params.add(param);
		
		parentFilter.m_FilterParams = params;
		
		// === === ===

		FilterPart part = new FilterPart();
		part.m_ChildFilter = childFilter;

		FilterParts parts = new FilterParts();
		parts.add(part);

		if (formulaFilterAttr != null) {
			FilterPart formulaPart = new FilterPart();
			formulaPart.m_ChildFilter = formulaFilterAttr;
			parts.add(formulaPart);
		}

		if (formulaFilterUser != null) {
			FilterPart formulaPart = new FilterPart();
			formulaPart.m_ChildFilter = formulaFilterUser;
			parts.add(formulaPart);
		}
		
		parentFilter.m_FilterParts = parts;
						
		// === === ===		
		
		parentFilter.save();
		
		return parentFilter;
	}
	
	public static Filter createFormulaFilterAttr(RecipList rl) throws Exception
	{
		Filter filter = null;
		if (rl.s_cache_attr_id != null) {
			filter = new Filter();
			filter.s_filter_name = "formula";
			filter.s_cust_id = rl.s_cust_id;		
			filter.s_status_id = String.valueOf(FilterStatus.NEW);
			filter.s_type_id = String.valueOf(FilterType.FORMULA);

			Formula formula = new Formula();
			filter.m_Formula = formula;
			formula.s_attr_id = rl.s_cache_attr_id;
			formula.s_operation_id = String.valueOf(rl.s_cache_attr_operator);
			formula.s_positive_flag = "1";
			formula.s_value1 = rl.s_cache_attr_value1;
			
			if (rl.s_cache_attr_value2 != null) {
				formula.s_value2 = rl.s_cache_attr_value2;
			}
			
			filter.save();
		}
		return filter;
	}
	
	public static Filter createFormulaFilterUser(RecipList rl) throws Exception
	{
		Filter filter = null;
			
		String s_attr_id = null;
		Attributes attrs = new Attributes();
		Attribute attr = null;
		attrs.s_cust_id = rl.s_cust_id;
		attrs.s_attr_name = "owning_user_id";
		
		if (attrs.retrieve() > 0)
		{
			for (Enumeration e = attrs.elements();e.hasMoreElements();)
			{
				attr = (Attribute) e.nextElement();
				s_attr_id = attr.s_attr_id;
			}
		}
		
		if (rl.s_cache_user_id != null && s_attr_id != null) {
			filter = new Filter();
			filter.s_filter_name = "formula";
			filter.s_cust_id = rl.s_cust_id;		
			filter.s_status_id = String.valueOf(FilterStatus.NEW);
			filter.s_type_id = String.valueOf(FilterType.FORMULA);

			Formula formula = new Formula();
			filter.m_Formula = formula;
			formula.s_attr_id = s_attr_id;
			formula.s_operation_id = String.valueOf(CompareOperation.EQUAL);
			formula.s_positive_flag = "1";
			formula.s_value1 = "'" + rl.s_cache_user_id + "'";
			
			filter.save();
		}
		
		return filter;
	}


	public static Filter createSimpleFilter(String sFilterName, RecipList rl) throws Exception
	{
		Filter filter = new Filter();
		filter.s_filter_name = "(CAMPAIGN REPORT) " + sFilterName;
		filter.s_cust_id = rl.s_cust_id;		
		filter.s_status_id = String.valueOf(FilterStatus.NEW);

		FilterParams params = new FilterParams();
		filter.m_FilterParams = params;
		
		FilterParam param = null;

		// === === ===
		// FOR NOW camp_id IS USED BY EACH OF THE FOLLOWING FILTERS
		
		param = new FilterParam();
		param.s_param_name = "camp_id";
		param.s_integer_value = rl.s_camp_id;
		params.add(param);

		// === === ===
		// start and end date for cached reports

		if (rl.s_cache_start_date != null) {
			param = new FilterParam();
			param.s_param_name = "start_date";
			param.s_date_value = rl.s_cache_start_date;
			params.add(param);
		}

		if (rl.s_cache_end_date != null) {
			param = new FilterParam();
			param.s_param_name = "end_date";
			param.s_date_value = rl.s_cache_end_date;
			params.add(param);
		}

		// === === ===
				
		int nListType = getType(rl);
		switch (nListType)
		{
			case RecipListType.RLST_CAMP_BBACK:
			{
				filter.s_type_id = String.valueOf(FilterType.RLST_CAMP_BBACK);
				break;
			}
			case RecipListType.RLST_CAMP_BBACK_WITH_CATEGORY:
			{
				filter.s_type_id = String.valueOf(FilterType.RLST_CAMP_BBACK_WITH_CATEGORY);

				param = new FilterParam();
				param.s_param_name = "category_id";
				param.s_integer_value = rl.s_bback_category;
				params.add(param);
			
				break;
			}
           // Release 6.1: Spam Complaints 
			case RecipListType.RLST_CAMP_UNSUB_WITH_LEVEL:
			{
				filter.s_type_id = String.valueOf(FilterType.RLST_CAMP_UNSUB_WITH_LEVEL);

				param = new FilterParam();
				param.s_param_name = "level_id";
				param.s_integer_value = rl.s_unsub_level;
				params.add(param);
			
				break;
			}
			case RecipListType.RLST_CAMP_CLICK:
			{
				filter.s_type_id = String.valueOf(FilterType.RLST_CAMP_CLICK);

				param = new FilterParam();
				param.s_param_name = "link_id";
				param.s_integer_value = rl.s_link_id;
				params.add(param);
		
				param = new FilterParam();
				param.s_param_name = "cont_type";
				param.s_string_value = rl.s_content_type;
				params.add(param);
					
				break;
			}
			case RecipListType.RLST_CAMP_CLICK_MULTI:
			{
				filter.s_type_id = String.valueOf(FilterType.RLST_CAMP_CLICK_MULTI);

				param = new FilterParam();
				param.s_param_name = "link_id";
				param.s_integer_value = rl.s_link_id;
				params.add(param);

				break;
			}
			case RecipListType.RLST_CAMP_FORM_SUBMIT:
			{
				filter.s_type_id = String.valueOf(FilterType.RLST_CAMP_FORM_SUBMIT);

				param = new FilterParam();
				param.s_param_name = "form_id";
				param.s_integer_value = rl.s_form_id;
				params.add(param);

				break;
			}
			case RecipListType.RLST_CAMP_FORM_SUBMIT_MULTI:
			{
				filter.s_type_id = String.valueOf(FilterType.RLST_CAMP_FORM_SUBMIT_MULTI);

				param = new FilterParam();
				param.s_param_name = "form_id";
				param.s_integer_value = rl.s_form_id;
				params.add(param);

				break;
			}
			case RecipListType.RLST_CAMP_FORM_VIEW:
			{
				filter.s_type_id = String.valueOf(FilterType.RLST_CAMP_FORM_VIEW);

				param = new FilterParam();
				param.s_param_name = "form_id";
				param.s_integer_value = rl.s_form_id;
				params.add(param);

				break;
			}
			case RecipListType.RLST_CAMP_MULTILINK:
			{
				filter.s_type_id = String.valueOf(FilterType.RLST_CAMP_MULTILINK);
				break;
			}
			case RecipListType.RLST_CAMP_RCVD:
			{
				filter.s_type_id = String.valueOf(FilterType.RLST_CAMP_RCVD);
				break;
			}
			case RecipListType.RLST_CAMP_READ:
			{
				filter.s_type_id = String.valueOf(FilterType.RLST_CAMP_READ);
				break;
			}
			case RecipListType.RLST_CAMP_READ_MULTI:
			{
				filter.s_type_id = String.valueOf(FilterType.RLST_CAMP_READ_MULTI);
				break;
			}
			case RecipListType.RLST_CAMP_SENT:
			{
				filter.s_type_id = String.valueOf(FilterType.RLST_CAMP_SENT);
				break;
			}
			case RecipListType.RLST_CAMP_UNSUB:
			{
				filter.s_type_id = String.valueOf(FilterType.RLST_CAMP_UNSUB);
				break;
			}
			case RecipListType.RLST_CAMP_DOMAIN_SENT:
			{
				filter.s_type_id = String.valueOf(FilterType.RLST_CAMP_DOMAIN_SENT);

				param = new FilterParam();
				param.s_param_name = "domain";
				param.s_string_value = rl.s_domain;
				params.add(param);

				break;
			}
			case RecipListType.RLST_CAMP_DOMAIN_BBACK:
			{
				filter.s_type_id = String.valueOf(FilterType.RLST_CAMP_DOMAIN_BBACK);

				param = new FilterParam();
				param.s_param_name = "domain";
				param.s_string_value = rl.s_domain;
				params.add(param);

				break;
			}
			case RecipListType.RLST_CAMP_DOMAIN_READ:
			{
				filter.s_type_id = String.valueOf(FilterType.RLST_CAMP_DOMAIN_READ);

				param = new FilterParam();
				param.s_param_name = "domain";
				param.s_string_value = rl.s_domain;
				params.add(param);

				break;
			}
			case RecipListType.RLST_CAMP_DOMAIN_CLICK:
			{
				filter.s_type_id = String.valueOf(FilterType.RLST_CAMP_DOMAIN_CLICK);

				param = new FilterParam();
				param.s_param_name = "domain";
				param.s_string_value = rl.s_domain;
				params.add(param);

				break;
			}
			case RecipListType.RLST_CAMP_DOMAIN_UNSUB:
			{
				filter.s_type_id = String.valueOf(FilterType.RLST_CAMP_DOMAIN_UNSUB);

				param = new FilterParam();
				param.s_param_name = "domain";
				param.s_string_value = rl.s_domain;
				params.add(param);

				break;
			}
			//Release 6.1: Domain Spam Complaints 
			case RecipListType.RLST_CAMP_DOMAIN_SPAM_COMPLAINT:
			{
				filter.s_type_id = String.valueOf(FilterType.RLST_CAMP_DOMAIN_SPAM_COMPLAINT);

				param = new FilterParam();
				param.s_param_name = "domain";
				param.s_string_value = rl.s_domain;
				params.add(param);

				break;
			}
			case RecipListType.RLST_CAMP_OPTOUT:
			{
				filter.s_type_id = String.valueOf(FilterType.RLST_CAMP_OPTOUT);

				param = new FilterParam();
				param.s_param_name = "attr_id";
				param.s_integer_value = rl.s_newsletter_id;
				params.add(param);

				break;
			}
			//Release 6.0: Ability to export bounces and unsubs from a target group.
			case RecipListType.RLST_TGT_BBACK:
			case RecipListType.RLST_TGT_UNSUB:
			case RecipListType.RLST_TGT_INELIGIBLE:

			case RecipListType.RLST_EDT_DETAIL:
			case RecipListType.RLST_EDT_LIST_EMAIL_821:
			case RecipListType.RLST_EDT_LIST_PNMFAMILY:
			case RecipListType.RLST_EXP_BATCH:
			case RecipListType.RLST_EXP_BBACK:
			case RecipListType.RLST_EXP_UNSUB:
			case RecipListType.RLST_TGT_PREVIEW:
			default:
			{
				throw new Exception("RecipListUtil.createSimpleFilter() ERROR: unknown list-filter type");
			}
		}
		
		// === === ===
		
		filter.save();
		return filter;
	}
} //End of RecipList
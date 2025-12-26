package com.britemoon.cps;

import java.io.*;

import com.britemoon.cps.RecipListType;
import com.britemoon.cps.XmlUtil;
import org.w3c.dom.*;

public class RecipListGeneric
{
	public String s_cust_id = null;
	public String s_recip_id = null;
	public String s_camp_id = null;
	public String s_chunk_id = null;
	public String s_link_id = null;
	public String s_content_type = null;
	public String s_form_id = null;
	public String s_filter_id = null;
	public String s_batch_id = null;
	public String s_bback_category = null;
	//Release 6.1: spam complaints
	public String s_unsub_level = null; 
	public String s_domain = null;
	public String s_newsletter_id = null;
	public String s_pnmfamily = null;
	public String s_email_821 = null;
	public String s_cache_id = null;
	public String s_cache_start_date = null;
	public String s_cache_end_date = null;
	public String s_cache_attr_id = null;
	public String s_cache_attr_value1 = null;
	public String s_cache_attr_value2 = null;
	public String s_cache_attr_operator = null;
	public String s_cache_user_id = null;
	public String s_cache_filter_id = null;

	public String s_num_recips = null;
	public String s_attr_list = null;
	public String s_delimiter = null;

	//Release 6.0: Added for Export Once and Re-run as needed.
	public String s_export_name = null;
	public String s_file_url = null;
	public String s_params = null;
	public String s_status_id = null;

	public int n_total_recips = 0;
	public int n_total_returned = 0;

	public String sAction = null;
	public String sQuery = null;
	
	public void fromRecipRequestXml(Element e) throws Exception
	{
		if(!e.getNodeName().equals("RecipRequest"))
			throw new Exception("Malformed RecipRequest xml.");

		sAction = XmlUtil.getChildTextValue(e, "action");
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_recip_id = XmlUtil.getChildTextValue(e, "recip_id");
		s_camp_id = XmlUtil.getChildTextValue(e, "camp_id");
		s_chunk_id = XmlUtil.getChildTextValue(e, "chunk_id");
		s_link_id = XmlUtil.getChildTextValue(e, "link_id");
		s_content_type = XmlUtil.getChildTextValue(e, "content_type");
		s_form_id = XmlUtil.getChildTextValue(e, "form_id");
		s_filter_id = XmlUtil.getChildTextValue(e, "filter_id");
		s_batch_id = XmlUtil.getChildTextValue(e, "batch_id");
		s_bback_category = XmlUtil.getChildTextValue(e, "bback_category");
		// Release 6.1: Spam Complaints 
		s_unsub_level = XmlUtil.getChildTextValue(e, "unsub_level");		
		s_domain = XmlUtil.getChildCDataValue(e, "domain");
		s_newsletter_id = XmlUtil.getChildTextValue(e, "newsletter_id");
		s_pnmfamily = XmlUtil.getChildCDataValue(e, "pnmfamily");
		s_email_821 = XmlUtil.getChildCDataValue(e, "email_821");
		s_cache_id = XmlUtil.getChildTextValue(e, "cache_id");
		s_cache_start_date = XmlUtil.getChildCDataValue(e, "cache_start_date");
		s_cache_end_date = XmlUtil.getChildCDataValue(e, "cache_end_date");
		s_cache_attr_id = XmlUtil.getChildTextValue(e, "cache_attr_id");
		s_cache_attr_value1 = XmlUtil.getChildCDataValue(e, "cache_attr_value1");
		s_cache_attr_value2 = XmlUtil.getChildCDataValue(e, "cache_attr_value2");
		s_cache_attr_operator = XmlUtil.getChildTextValue(e, "cache_attr_operator");
		s_cache_user_id = XmlUtil.getChildTextValue(e, "cache_user_id");
		s_cache_filter_id = XmlUtil.getChildTextValue(e, "cache_filter_id");

		s_num_recips = XmlUtil.getChildTextValue(e, "num_recips");
		s_attr_list = XmlUtil.getChildTextValue(e, "attr_list");
		s_delimiter = XmlUtil.getChildTextValue(e, "delimiter");

		s_file_url = XmlUtil.getChildTextValue(e, "file_url");
		s_export_name = XmlUtil.getChildTextValue(e, "export_name");
		s_params = XmlUtil.getChildTextValue(e,"params");
		s_status_id = XmlUtil.getChildTextValue(e, "status_id");
	}

	public String toRecipRequestXml() throws Exception
	{
		StringWriter sw = new StringWriter();
		toRecipRequestXml(sw);
		return sw.toString();
	}

	public void toRecipRequestXml(StringWriter sw) throws Exception
	{
		sw.write("<RecipRequest>");

		if(sAction != null) sw.write("<action>" + sAction + "</action>");
		if(s_cust_id != null) sw.write("<cust_id>" + s_cust_id + "</cust_id>");
		if(s_recip_id != null) sw.write("<recip_id>" + s_recip_id + "</recip_id>");
		if(s_camp_id != null) sw.write("<camp_id>" + s_camp_id + "</camp_id>");
		if(s_chunk_id != null) sw.write("<chunk_id>" + s_chunk_id + "</chunk_id>");
		if(s_link_id != null) sw.write("<link_id>" + s_link_id + "</link_id>");
		if(s_content_type != null) sw.write("<content_type>" + s_content_type + "</content_type>");
		if(s_form_id != null) sw.write("<form_id>" + s_form_id + "</form_id>");
		if(s_filter_id != null) sw.write("<filter_id>" + s_filter_id + "</filter_id>");
		if(s_batch_id != null) sw.write("<batch_id>" + s_batch_id + "</batch_id>");
		if(s_bback_category != null) sw.write("<bback_category>" + s_bback_category + "</bback_category>");
        //		 Release 6.1: Spam Complaints 
		if(s_unsub_level != null) sw.write("<unsub_level>" + s_unsub_level + "</unsub_level>");				
		if(s_domain != null) sw.write("<domain><![CDATA[" + s_domain + "]]></domain>");
		if(s_newsletter_id != null) sw.write("<newsletter_id>" + s_newsletter_id + "</newsletter_id>");
		if(s_pnmfamily != null) sw.write("<pnmfamily><![CDATA[" + s_pnmfamily + "]]></pnmfamily>");
		if(s_email_821 != null) sw.write("<email_821><![CDATA[" + s_email_821 + "]]></email_821>");
		if(s_cache_id != null) sw.write("<cache_id>" + s_cache_id + "</cache_id>");
		if(s_cache_start_date != null) sw.write("<cache_start_date><![CDATA[" + s_cache_start_date + "]]></cache_start_date>");
		if(s_cache_end_date != null) sw.write("<cache_end_date><![CDATA[" + s_cache_end_date + "]]></cache_end_date>");
		if(s_cache_attr_id != null) sw.write("<cache_attr_id><![CDATA[" + s_cache_attr_id + "]]></cache_attr_id>");
		if(s_cache_attr_value1 != null) sw.write("<cache_attr_value1><![CDATA[" + s_cache_attr_value1 + "]]></cache_attr_value1>");
		if(s_cache_attr_value2 != null) sw.write("<cache_attr_value2><![CDATA[" + s_cache_attr_value2 + "]]></cache_attr_value2>");
		if(s_cache_attr_operator != null) sw.write("<cache_attr_operator>" + s_cache_attr_operator + "</cache_attr_operator>");
		if(s_cache_user_id != null) sw.write("<cache_user_id>" + s_cache_user_id + "</cache_user_id>");
		if(s_cache_filter_id != null) sw.write("<cache_filter_id>" + s_cache_filter_id + "</cache_filter_id>");

		if(s_num_recips != null) sw.write("<num_recips>" + s_num_recips + "</num_recips>");
		if(s_attr_list != null) sw.write("<attr_list>" + s_attr_list + "</attr_list>");
		if(s_delimiter != null) sw.write("<delimiter>" + s_delimiter + "</delimiter>");

		if(s_file_url != null) sw.write("<file_url>" + s_file_url + "</file_url>");
		if(s_export_name != null) sw.write("<export_name>" + s_export_name + "</export_name>");
		if(s_params != null) sw.write("<params>" + s_params + "</params>");
		if(s_status_id != null) sw.write("<status_id>" + s_status_id + "</status_id>");

		sw.write("</RecipRequest>");
	}

	// === ==== ====

	public int getType() throws Exception
	{
		return getType(this);
	}

	public static int getType(RecipListGeneric rl) throws Exception
	{
		int nRecipListType = -1;
		if (rl.sAction.indexOf("Camp") > -1)
		{
			if (rl.s_camp_id == null)
				throw new Exception ("No RecipRequest Campaign specified.");

			if (rl.sAction.indexOf("Sent") > -1)
			{
				if (rl.sAction.indexOf("Domain") > -1) nRecipListType = RecipListType.RLST_CAMP_DOMAIN_SENT;
				else nRecipListType = RecipListType.RLST_CAMP_SENT;
			}
			else if (rl.sAction.indexOf("Rcvd") > -1) nRecipListType = RecipListType.RLST_CAMP_RCVD;
			else if (rl.sAction.indexOf("BBack") > -1)
			{
				if (rl.sAction.indexOf("Domain") > -1) nRecipListType = RecipListType.RLST_CAMP_DOMAIN_BBACK;
				else if (rl.s_bback_category != null) nRecipListType = RecipListType.RLST_CAMP_BBACK_WITH_CATEGORY;
				else nRecipListType = RecipListType.RLST_CAMP_BBACK;
			}
			else if (rl.sAction.indexOf("Read") > -1)
			{
				if (rl.sAction.indexOf("Domain") > -1) nRecipListType = RecipListType.RLST_CAMP_DOMAIN_READ;
				else if (rl.sAction.indexOf("Multi") > -1) nRecipListType = RecipListType.RLST_CAMP_READ_MULTI;
				else nRecipListType = RecipListType.RLST_CAMP_READ;
			}
			else if (rl.sAction.indexOf("Click") > -1)
			{
				if (rl.sAction.indexOf("Domain") > -1) nRecipListType = RecipListType.RLST_CAMP_DOMAIN_CLICK;
				else if (rl.sAction.indexOf("Multi") > -1)nRecipListType = RecipListType.RLST_CAMP_CLICK_MULTI;
				else nRecipListType = RecipListType.RLST_CAMP_CLICK;
			}
			else if (rl.sAction.indexOf("Form") > -1)
			{
				if (rl.sAction.indexOf("View") > -1) nRecipListType = RecipListType.RLST_CAMP_FORM_VIEW;
				else if (rl.sAction.indexOf("Submit") > -1)
				{
					if (rl.sAction.indexOf("Multi") > -1) nRecipListType = RecipListType.RLST_CAMP_FORM_SUBMIT_MULTI;
					else nRecipListType = RecipListType.RLST_CAMP_FORM_SUBMIT;
				}
				else throw new Exception ("Unknown RecipRequest Action specified");
			}
			else if (rl.sAction.indexOf("MultiLink") > -1) nRecipListType = RecipListType.RLST_CAMP_MULTILINK;
			else if (rl.sAction.indexOf("Unsub") > -1)
			{
				if (rl.sAction.indexOf("Domain") > -1) nRecipListType = RecipListType.RLST_CAMP_DOMAIN_UNSUB;
				else nRecipListType = RecipListType.RLST_CAMP_UNSUB;
			}
			//Release 6.1: Spam Complaints
			else if (rl.sAction.indexOf("DomainSpam") > -1)
			{
				nRecipListType = RecipListType.RLST_CAMP_DOMAIN_SPAM_COMPLAINT;
			}
           //Release 6.1: Spam Complaints
			else if (rl.sAction.indexOf("Level") > -1)
			{
				nRecipListType = RecipListType.RLST_CAMP_UNSUB_WITH_LEVEL;
			}
			else if (rl.sAction.indexOf("Optout") > -1) nRecipListType = RecipListType.RLST_CAMP_OPTOUT;
			else throw new Exception ("Unknown RecipRequest Action specified");
		}
		else if (rl.sAction.indexOf("Edt") > -1)
		{
			if (rl.sAction.indexOf("List") > -1)
			{
				if ((rl.s_pnmfamily != null) && !(rl.s_pnmfamily.trim().equals("")))
				{
					if ((rl.s_pnmfamily == null) || (rl.s_pnmfamily.trim().equals("")))
						throw new Exception ("No RecipRequest Edit Search parameters specified.");

					nRecipListType = RecipListType.RLST_EDT_LIST_PNMFAMILY;
				}
				else
				if ((rl.s_email_821 != null) && !(rl.s_email_821.trim().equals("")))
				{
					if ((rl.s_email_821 == null) || (rl.s_email_821.trim().equals("")))
						throw new Exception ("No RecipRequest Edit Search parameters specified.");
						nRecipListType = RecipListType.RLST_EDT_LIST_EMAIL_821;
				}
			}
			else if (rl.sAction.indexOf("Detail") > -1)
			{
				if (rl.s_recip_id == null)
					throw new Exception ("No RecipRequest Edit Detail recip_id specified.");
				 nRecipListType = RecipListType.RLST_EDT_DETAIL;
			}
			else
				throw new Exception ("Unknown RecipRequest Action specified");
		}
		else if (rl.sAction.indexOf("Tgt") > -1)
		{

			if (rl.sAction.indexOf("Preview") > -1) nRecipListType = RecipListType.RLST_TGT_PREVIEW;
		//Release 6.0: Ability to export bounces and unsubs from a target group.
		else if (rl.sAction.indexOf("TgtBBack") > -1) nRecipListType = RecipListType.RLST_TGT_BBACK;
		else if (rl.sAction.indexOf("TgtUnsub") > -1) nRecipListType = RecipListType.RLST_TGT_UNSUB;
		else if (rl.sAction.indexOf("TgtIneligible") > -1) nRecipListType = RecipListType.RLST_TGT_INELIGIBLE;
			else if (rl.sAction.indexOf("Exp") > -1)
			{
				// Need to handle this differently, stored procedure
			}
		}
		else if (rl.sAction.indexOf("ExpBatch") > -1) nRecipListType = RecipListType.RLST_EXP_BATCH;
		else if (rl.sAction.indexOf("ExpBBack") > -1) nRecipListType = RecipListType.RLST_EXP_BBACK;
		else if (rl.sAction.indexOf("ExpUnsub") > -1) nRecipListType = RecipListType.RLST_EXP_UNSUB;
		else throw new Exception ("Unknown RecipRequest Action specified");

		return nRecipListType;
	}
}

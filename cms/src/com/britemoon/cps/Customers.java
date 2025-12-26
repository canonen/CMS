package com.britemoon.cps;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;

public class Customers extends BriteList
{
	// === Constructors ===
	public Customers()
	{
	}

	public Customers(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_cust_id = null;
	public String s_cust_name = null;
	public String s_status_id = null;
	public String s_level_id = null;
	public String s_descrip = null;
	public String s_max_bbacks = null;
	public String s_login_name = null;
	public String s_parent_cust_id = null;
	public String s_upd_rule_id = null;
	public String s_upd_hierarchy_id = null;
	public String s_unsub_hierarchy_id = null;
	public String s_max_bback_days = null;
	public String s_pass_expire_interval = null;
	public String s_pass_notify_days = null;
	public String s_cti_group_id = null;
	public String s_max_consec_bbacks = null;
	public String s_max_consec_bback_days = null;
        public String s_max_domains_on_report = null;
	
	// === For Hyatt Customer List ===
	public boolean b_is_hyatt = false;

	private void resetParams()
	{
		s_cust_id = null;
		s_cust_name = null;
		s_status_id = null;
		s_level_id = null;
		s_descrip = null;
		s_max_bbacks = null;
		s_login_name = null;
		s_parent_cust_id = null;
		s_upd_rule_id = null;
		s_upd_hierarchy_id = null;
		s_unsub_hierarchy_id = null;
		s_max_bback_days = null;
		s_pass_expire_interval = null;
		s_pass_notify_days = null;
		s_cti_group_id = null;
		b_is_hyatt = false;
		s_max_consec_bbacks = null;
		s_max_consec_bback_days = null;
                s_max_domains_on_report = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	cust_id," +
			"	cust_name," +
			"	login_name," +
			"	status_id," +
			"	level_id," +
			"	parent_cust_id," +
			"	max_bbacks," +
			"	descrip," +
			"	upd_rule_id," +
			"	upd_hierarchy_id," +
			"	unsub_hierarchy_id," +
			"	max_bback_days," +
			"	pass_expire_interval," +
			"	pass_notify_days," +
			"	cti_group_id," +
			"	max_consec_bbacks," +
			"	max_consec_bback_days," +
                        "       max_domains_on_report";

		m_sFromClause = " FROM ccps_customer ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY cust_name ASC ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = "";
		boolean bAddAnd = false;

		if (b_is_hyatt) m_sOrderByClause = " ORDER BY login_name ASC ";
		else m_sOrderByClause = " ORDER BY cust_name ASC ";

		if(s_cust_id != null) { sWhereSql += " (cust_id IN (?)) "; bAddAnd = true; }
		if(s_cust_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (cust_name IN (?)) "); bAddAnd = true; }
		if(s_status_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (status_id IN (?)) "); bAddAnd = true; }
		if(s_level_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (level_id IN (?)) "); bAddAnd = true; }
		if(s_descrip != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (descrip IN (?)) "); bAddAnd = true; }
		if(s_max_bbacks != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (max_bbacks IN (?)) "); bAddAnd = true; }
		if(s_login_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (login_name IN (?)) "); bAddAnd = true; }
		if(s_parent_cust_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (parent_cust_id IN (?)) "); bAddAnd = true; }
		if(s_upd_rule_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (upd_rule_id IN (?)) "); bAddAnd = true; }
		if(s_upd_hierarchy_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (upd_hierarchy_id IN (?)) "); bAddAnd = true; }
		if(s_unsub_hierarchy_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (unsub_hierarchy_id IN (?)) "); bAddAnd = true; }
		if(s_max_bback_days != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (max_bback_days IN (?)) "); bAddAnd = true; }
		if(s_pass_expire_interval != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (pass_expire_interval IN (?)) "); bAddAnd = true; }
		if(s_pass_notify_days != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (pass_notify_days IN (?)) "); bAddAnd = true; }
		if(s_cti_group_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (cti_group_id IN (?)) "); bAddAnd = true; }
		if(s_max_consec_bbacks != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (max_consec_bbacks IN (?)) "); bAddAnd = true; }
		if(s_max_consec_bback_days != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (max_consec_bback_days IN (?)) "); bAddAnd = true; }
                if(s_max_domains_on_report != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (max_domains_on_report IN (?)) "); bAddAnd = true; }


		if (!"".equals(sWhereSql)) sWhereSql = " WHERE " + sWhereSql;

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_cust_id != null) { pstmt.setString(i, s_cust_id); i++; }
		if(s_cust_name != null) { pstmt.setBytes(i, s_cust_name.getBytes("UTF-8")); i++; }
		if(s_status_id != null) { pstmt.setString(i, s_status_id); i++; }
		if(s_level_id != null) { pstmt.setString(i, s_level_id); i++; }
		if(s_descrip != null) { pstmt.setBytes(i, s_descrip.getBytes("UTF-8")); i++; }
		if(s_max_bbacks != null) { pstmt.setString(i, s_max_bbacks); i++; }
		if(s_login_name != null) { pstmt.setBytes(i, s_login_name.getBytes("UTF-8")); i++; }
		if(s_parent_cust_id != null) { pstmt.setString(i, s_parent_cust_id); i++; }
		if(s_upd_rule_id != null) { pstmt.setString(i, s_upd_rule_id); i++; }
		if(s_upd_hierarchy_id != null) { pstmt.setString(i, s_upd_hierarchy_id); i++; }
		if(s_unsub_hierarchy_id != null) { pstmt.setString(i, s_unsub_hierarchy_id); i++; }
		if(s_max_bback_days != null) { pstmt.setString(i, s_max_bback_days); i++; }
		if(s_pass_expire_interval != null) { pstmt.setString(i, s_pass_expire_interval); i++; }
		if(s_pass_notify_days != null) { pstmt.setString(i, s_pass_notify_days); i++; }
		if(s_cti_group_id != null) { pstmt.setString(i, s_cti_group_id); i++; }
		if(s_max_consec_bbacks != null) { pstmt.setString(i, s_max_consec_bbacks); i++; }
		if(s_max_consec_bback_days != null) { pstmt.setString(i, s_max_consec_bback_days); i++; }
                if(s_max_domains_on_report != null) { pstmt.setString(i, s_max_domains_on_report); i++; }
	}

	public void fixIds()
	{
		Customer customer = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			customer = (Customer)e.nextElement();
			if(s_parent_cust_id != null) customer.s_parent_cust_id = s_parent_cust_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		Customer customer = null;
		while (rs.next())
		{
			customer = new Customer();
			customer.getPropsFromResultSetRow(rs);
			add(customer);
			nReturnCode++;
		}
		return nReturnCode;
	}


        //
	// === XML Methods ===

	public String m_sMainElementName = "customers";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "customer";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		Customer customer = null;
		for(int i = 0; i < iLength; i++)
		{
			customer = new Customer ((Element)nl.item(i));
			v.add(customer);
		}
		return iLength;
	}

	// === Other Methods ===
}



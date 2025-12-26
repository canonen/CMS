package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class EmailListItems extends BriteList
{
	// === Constructors ===
	private static Logger logger = Logger.getLogger(EmailListItems.class.getName());
	public EmailListItems()
	{
	}

	public EmailListItems(Element e) throws Exception
	{
		fromXml(e);
	}

	// === For RCP only ===

	// override this method to return something reasonable
	// otherwise variable m_sOwnerId defined in BriteList will be returned
	// public String getOwnerId() { return s_cust_id; }

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_item_id = null;
	public String s_email_type_id = null;
	public String s_list_id = null;
	public String s_email = null;

	private void resetParams()
	{
		s_item_id = null;
		s_email_type_id = null;
		s_list_id = null;
		s_email = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	list_id," +
			"	email_type_id," +
			"	item_id," +
			"	email" ;

		m_sFromClause = " FROM cque_email_list_item ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  item_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_list_id != null) { sWhereSql += " (list_id IN (?)) "; bAddAnd = true; }
		if(s_email_type_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (email_type_id IN (?)) "); bAddAnd = true; }
		if(s_item_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (item_id IN (?)) "); bAddAnd = true; }
		if(s_email != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (email IN (?)) "); bAddAnd = true; }
		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_list_id != null) { pstmt.setString(i, s_list_id); i++; }
		if(s_email_type_id != null) { pstmt.setString(i, s_email_type_id); i++; }
		if(s_item_id != null) { pstmt.setString(i, s_item_id); i++; }
		if(s_email != null) { pstmt.setBytes(i, s_email.getBytes("UTF-8")); i++; }
	}

	public void fixIds()
	{
		EmailListItem emaillistitem = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			emaillistitem = (EmailListItem)e.nextElement();
			if(s_email_type_id != null) emaillistitem.s_email_type_id = s_email_type_id;
			if(s_list_id != null) emaillistitem.s_list_id = s_list_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		EmailListItem emaillistitem = null;
		while (rs.next())
		{
			emaillistitem = new EmailListItem();
			emaillistitem.getPropsFromResultSetRow(rs);
			add(emaillistitem);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "email_list_items";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "email_list_item";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		EmailListItem emaillistitem = null;
		for(int i = 0; i < iLength; i++)
		{
			emaillistitem = new EmailListItem ((Element)nl.item(i));
 			v.add(emaillistitem);
		}
		return iLength;
	}

	// === Other Methods ===
}

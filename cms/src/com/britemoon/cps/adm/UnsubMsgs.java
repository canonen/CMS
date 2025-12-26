package com.britemoon.cps.adm;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class UnsubMsgs extends BriteList
{
	// === Constructors ===
	private static Logger logger = Logger.getLogger(UnsubMsgs.class.getName());
	public UnsubMsgs()
	{
	}

	public UnsubMsgs(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_msg_id = null;
	public String s_msg_name = null;
	public String s_cust_id = null;
	public String s_text_msg = null;
	public String s_html_msg = null;
	
	private void resetParams()
	{
		s_msg_id = null;
		s_msg_name = null;
		s_cust_id = null;
		s_text_msg = null;
		s_html_msg = null;		
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	msg_id," +
			"	msg_name," +
			"	cust_id," +
			"	text_msg," +
			"	html_msg" ; 

		m_sFromClause = " FROM ccps_unsub_msg ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  msg_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_msg_id != null) { sWhereSql += " (msg_id IN (?)) "; bAddAnd = true; }
		if(s_msg_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (msg_name IN (?)) "); bAddAnd = true; }
		if(s_cust_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (cust_id IN (?)) "); bAddAnd = true; }
		if(s_text_msg != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (text_msg IN (?)) "); bAddAnd = true; }
		if(s_html_msg != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (html_msg IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_msg_id != null) { pstmt.setString(i, s_msg_id); i++; }
		if(s_msg_name != null) { pstmt.setBytes(i, s_msg_name.getBytes("UTF-8")); i++; }
		if(s_cust_id != null) { pstmt.setString(i, s_cust_id); i++; }
		if(s_text_msg != null) { pstmt.setBytes(i, s_text_msg.getBytes("UTF-8")); i++; }
		if(s_html_msg != null) { pstmt.setBytes(i, s_html_msg.getBytes("UTF-8")); i++; }
	}

	public void fixIds()
	{
		UnsubMsg unsubmsg = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			unsubmsg = (UnsubMsg)e.nextElement();
			if(s_cust_id != null) unsubmsg.s_cust_id = s_cust_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		UnsubMsg unsubmsg = null;
		while (rs.next())
		{
			unsubmsg = new UnsubMsg();
			unsubmsg.getPropsFromResultSetRow(rs);
			add(unsubmsg);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "unsub_msgs";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "unsub_msg";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		UnsubMsg unsubmsg = null;
		for(int i = 0; i < iLength; i++)
		{
			unsubmsg = new UnsubMsg ((Element)nl.item(i));
			v.add(unsubmsg);
		}
		return iLength;
	}

	// === Other Methods ===
}



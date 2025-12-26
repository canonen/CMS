package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;
public class CustModInstServices extends BriteList
{
	//log4j implementation
	private static Logger logger = Logger.getLogger(CustModInstServices.class.getName());
	// === Constructors ===
	public CustModInstServices()
	{
	}

	public CustModInstServices(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === Retrieve, delete & save params ===

	public String s_cust_id = null;
	public String s_mod_inst_id = null;
	public String s_service_type_id = null;
	public String s_protocol = null;
	public String s_port = null;
	public String s_path = null;

	private void resetParams()
	{
		s_cust_id = null;
		s_mod_inst_id = null;
		s_service_type_id = null;
		s_protocol = null;
		s_port = null;
		s_path = null;
	}
	
	// init sql variables
	{
		m_sRetrieveSql = null;
		m_bUseParamsForRetrieve	= true;

		m_sSelectClause = 
			" SELECT" +
			"	cust_id," +
			"	mod_inst_id," +
			"	service_type_id," +
			"	protocol," +
			"	port," +
			"	path" ;

		m_sFromClause = " FROM sadm_cust_mod_inst_service ";
		m_sWhereClause = null;
		m_sOrderByClause = " ORDER BY  cust_id, mod_inst_id, service_type_id ";
	}

	public String buildWhereClause()
	{
		String sWhereSql = " WHERE ";
		boolean bAddAnd = false;

		if(s_cust_id != null) { sWhereSql += " (cust_id IN (?)) "; bAddAnd = true; }
		if(s_mod_inst_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (mod_inst_id IN (?)) "); bAddAnd = true; }
		if(s_service_type_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (service_type_id IN (?)) "); bAddAnd = true; }
		if(s_protocol != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (protocol IN (?)) "); bAddAnd = true; }
		if(s_port != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (port IN (?)) "); bAddAnd = true; }
		if(s_path != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (path IN (?)) "); bAddAnd = true; }

		return sWhereSql;
	}
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
		int i = 1;
		if(s_cust_id != null) { pstmt.setString(i, s_cust_id); i++; }
		if(s_mod_inst_id != null) { pstmt.setString(i, s_mod_inst_id); i++; }
		if(s_service_type_id != null) { pstmt.setString(i, s_service_type_id); i++; }
		if(s_protocol != null) { pstmt.setBytes(i, s_protocol.getBytes("UTF-8")); i++; }
		if(s_port != null) { pstmt.setString(i, s_port); i++; }
		if(s_path != null) { pstmt.setBytes(i, s_path.getBytes("UTF-8")); i++; }
	}

	public void fixIds()
	{
		CustModInstService custmodinstservice = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			custmodinstservice = (CustModInstService)e.nextElement();
			if(s_cust_id != null) custmodinstservice.s_cust_id = s_cust_id;
			if(s_mod_inst_id != null) custmodinstservice.s_mod_inst_id = s_mod_inst_id;
			if(s_service_type_id != null) custmodinstservice.s_service_type_id = s_service_type_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		CustModInstService custmodinstservice = null;
		while (rs.next())
		{
			custmodinstservice = new CustModInstService();
			custmodinstservice.getPropsFromResultSetRow(rs);
			add(custmodinstservice);
			nReturnCode++;
		}
		return nReturnCode;
	}


	// === XML Methods ===

	public String m_sMainElementName = "cust_mod_inst_services";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "cust_mod_inst_service";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		CustModInstService custmodinstservice = null;
		for(int i = 0; i < iLength; i++)
		{
			custmodinstservice = new CustModInstService ((Element)nl.item(i));
			v.add(custmodinstservice);
		}
		return iLength;
	}

	// === Other Methods ===
}



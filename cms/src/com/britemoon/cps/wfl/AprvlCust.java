package com.britemoon.cps.wfl;

import com.britemoon.cps.*;
import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class AprvlCust extends BriteObject
{
	// === Properties ===

	public String s_cust_id = null;
	public String s_object_type = null;
	public String s_aprvl_workflow_flag = null;
	private static Logger logger = Logger.getLogger(AprvlCust.class.getName());
	

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public AprvlCust()
	{
	}
	
	public AprvlCust(String sCustId, String sObjectType) throws Exception
	{
		s_cust_id = sCustId;
		s_object_type = sObjectType;
		retrieve();
	}

	public AprvlCust(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	cust_id," +
		"	object_type," +
		"	aprvl_workflow_flag" +
		" FROM ccps_aprvl_cust" +
		" WHERE" +
		"	(cust_id=?) AND" +
		"	(object_type=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_object_type);

		ResultSet rs = pstmt.executeQuery();
		if (rs.next())
		{
			getPropsFromResultSetRow(rs);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	public void getPropsFromResultSetRow(ResultSet rs) throws Exception
	{
		byte[] b = null;
		s_cust_id = rs.getString(1);
		s_object_type = rs.getString(2);
		s_aprvl_workflow_flag = rs.getString(3);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccps_aprvl_cust_save" +
		"	@cust_id=?," +
		"	@object_type=?," +
		"	@aprvl_workflow_flag=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_object_type);
		pstmt.setString(3, s_aprvl_workflow_flag);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_cust_id = rs.getString(1);
			s_object_type = rs.getString(2);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccps_aprvl_cust" +
		" WHERE" +
		"	(cust_id=?) AND" +
		"	(object_type=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_object_type);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "aprvl_cust";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_object_type != null ) XmlUtil.appendTextChild(e, "object_type", s_object_type);
		if( s_aprvl_workflow_flag != null ) XmlUtil.appendTextChild(e, "aprvl_workflow_flag", s_aprvl_workflow_flag);
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_object_type = XmlUtil.getChildTextValue(e, "object_type");
		s_aprvl_workflow_flag = XmlUtil.getChildTextValue(e, "aprvl_workflow_flag");
	}

	// === Other Methods ===
}



package com.britemoon.cps.que;

import com.britemoon.cps.*;
import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class SuperCamp extends BriteObject
{
	// === Properties ===

	public String s_super_camp_id = null;
	public String s_super_camp_name = null;
	public String s_cust_id = null;
	private static Logger logger = Logger.getLogger(SuperCamp.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public SuperCamp()
	{
	}
	
	public SuperCamp(String sSuperCampId) throws Exception
	{
		s_super_camp_id = sSuperCampId;
		retrieve();
	}

	public SuperCamp(Element e) throws Exception
	{
		fromXml(e);
	}

	// === For RCP only ===

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	super_camp_id," +
		"	super_camp_name," +
		"	cust_id" +
		" FROM cque_super_camp" +
		" WHERE" +
		"	(super_camp_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_super_camp_id);

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
		s_super_camp_id = rs.getString(1);
		b = rs.getBytes(2);
		s_super_camp_name = (b == null)?null:new String(b,"UTF-8");
		s_cust_id = rs.getString(3);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cque_super_camp_save" +
		"	@super_camp_id=?," +
		"	@super_camp_name=?," +
		"	@cust_id=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_super_camp_id);
		if(s_super_camp_name == null) pstmt.setString(2, s_super_camp_name);
		else pstmt.setBytes(2, s_super_camp_name.getBytes("UTF-8"));
		pstmt.setString(3, s_cust_id);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_super_camp_id = rs.getString(1);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cque_super_camp" +
		" WHERE" +
		"	(super_camp_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_super_camp_id);

		return pstmt.executeUpdate();
	}
	
	// === XML Methods ===

	public String m_sMainElementName = "super_camp";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_super_camp_id != null ) XmlUtil.appendTextChild(e, "super_camp_id", s_super_camp_id);
		if( s_super_camp_name != null ) XmlUtil.appendCDataChild(e, "super_camp_name", s_super_camp_name);
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_super_camp_id = XmlUtil.getChildTextValue(e, "super_camp_id");
		s_super_camp_name = XmlUtil.getChildCDataValue(e, "super_camp_name");
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
	}

	// === Other Methods ===
}



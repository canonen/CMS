package com.britemoon.cps;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import java.util.logging.Logger;

import org.w3c.dom.*;

public class AccessMask extends BriteObject
{
	// === Properties ===

	public String s_user_id = null;
	public String s_type_id = null;
	public String s_mask = null;

	// === Parents ===

	// === Children ===

	// === Constructors ===
	private static Logger logger = Logger.getLogger(AccessMask.class.getName());
	
	public AccessMask()
	{
	}
	
	public AccessMask(String sUserId, String sTypeId) throws Exception
	{
		s_user_id = sUserId;
		s_type_id = sTypeId;
		retrieve();
	}

	public AccessMask(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	user_id," +
		"	type_id," +
		"	mask" +
		" FROM ccps_access_mask" +
		" WHERE" +
		"	(user_id=?) AND" +
		"	(type_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_user_id);
		pstmt.setString(2, s_type_id);

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
		s_user_id = rs.getString(1);
		s_type_id = rs.getString(2);
		s_mask = rs.getString(3);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccps_access_mask_save" +
		"	@user_id=?," +
		"	@type_id=?," +
		"	@mask=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_user_id);
		pstmt.setString(2, s_type_id);
		pstmt.setString(3, s_mask);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_user_id = rs.getString(1);
			s_type_id = rs.getString(2);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccps_access_mask" +
		" WHERE" +
		"	(user_id=?) AND" +
		"	(type_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_user_id);
		pstmt.setString(2, s_type_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "access_mask";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_user_id != null ) XmlUtil.appendTextChild(e, "user_id", s_user_id);
		if( s_type_id != null ) XmlUtil.appendTextChild(e, "type_id", s_type_id);
		if( s_mask != null ) XmlUtil.appendTextChild(e, "mask", s_mask);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_user_id = XmlUtil.getChildTextValue(e, "user_id");
		s_type_id = XmlUtil.getChildTextValue(e, "type_id");
		s_mask = XmlUtil.getChildTextValue(e, "mask");
	}

	// === Other Methods ===
}



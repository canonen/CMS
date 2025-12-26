package com.britemoon.cps.que;

import com.britemoon.cps.*;
import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class SuperCampCamp extends BriteObject
{
	// === Properties ===

	public String s_super_camp_id = null;
	public String s_camp_id = null;
	private static Logger logger = Logger.getLogger(SuperCampCamp.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public SuperCampCamp()
	{
	}
	
	public SuperCampCamp(String sSuperCampId, String sCampId) throws Exception
	{
		s_super_camp_id = sSuperCampId;
		s_camp_id = sCampId;
		retrieve();
	}

	public SuperCampCamp(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	super_camp_id," +
		"	camp_id" +
		" FROM cque_super_camp_camp" +
		" WHERE" +
		"	(super_camp_id=?) AND" +
		"	(camp_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_super_camp_id);
		pstmt.setString(2, s_camp_id);

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
		s_camp_id = rs.getString(2);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cque_super_camp_camp_save" +
		"	@super_camp_id=?," +
		"	@camp_id=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_super_camp_id);
		pstmt.setString(2, s_camp_id);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_super_camp_id = rs.getString(1);
			s_camp_id = rs.getString(2);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cque_super_camp_camp" +
		" WHERE" +
		"	(super_camp_id=?) AND" +
		"	(camp_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_super_camp_id);
		pstmt.setString(2, s_camp_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "super_camp_camp";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_super_camp_id != null ) XmlUtil.appendTextChild(e, "super_camp_id", s_super_camp_id);
		if( s_camp_id != null ) XmlUtil.appendTextChild(e, "camp_id", s_camp_id);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_super_camp_id = XmlUtil.getChildTextValue(e, "super_camp_id");
		s_camp_id = XmlUtil.getChildTextValue(e, "camp_id");
	}

	// === Other Methods ===
}



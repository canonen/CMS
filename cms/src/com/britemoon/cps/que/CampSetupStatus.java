package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CampSetupStatus extends BriteObject
{
	// === Properties ===

	public String s_camp_id = null;
	public String s_rcp_status = null;
	public String s_jtk_status = null;
	public String s_inb_status = null;
	public String s_mailer_status = null;
	private static Logger logger = Logger.getLogger(CampSetupStatus.class.getName());

	// === Constructors ===

	public CampSetupStatus()
	{
	}
	
	public CampSetupStatus(String sCampId) throws Exception
	{
		s_camp_id = sCampId;
		retrieve();
	}

	public CampSetupStatus(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	camp_id," +
		"	rcp_status," +
		"	jtk_status," +
		"	inb_status," +
		"	mailer_status" +
		" FROM cque_camp_setup_status" +
		" WHERE" +
		"	(camp_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_camp_id);

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
		s_camp_id = rs.getString(1);
		s_rcp_status = rs.getString(2);
		s_jtk_status = rs.getString(3);
		s_inb_status = rs.getString(4);
		s_mailer_status = rs.getString(5);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cque_camp_setup_status_save" +
		"	@camp_id=?," +
		"	@rcp_status=?," +
		"	@jtk_status=?," +
		"	@inb_status=?," +
		"	@mailer_status=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_camp_id);
		pstmt.setString(2, s_rcp_status);
		pstmt.setString(3, s_jtk_status);
		pstmt.setString(4, s_inb_status);
		pstmt.setString(5, s_mailer_status);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_camp_id = rs.getString(1);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cque_camp_setup_status" +
		" WHERE" +
		"	(camp_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_camp_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "camp_setup_status";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_camp_id != null ) XmlUtil.appendTextChild(e, "camp_id", s_camp_id);
		if( s_rcp_status != null ) XmlUtil.appendTextChild(e, "rcp_status", s_rcp_status);
		if( s_jtk_status != null ) XmlUtil.appendTextChild(e, "jtk_status", s_jtk_status);
		if( s_inb_status != null ) XmlUtil.appendTextChild(e, "inb_status", s_inb_status);
		if( s_mailer_status != null ) XmlUtil.appendTextChild(e, "mailer_status", s_mailer_status);
	}

	// === From XML Methods ===	


	public void getPropsFromXml(Element e)
	{
		s_camp_id = XmlUtil.getChildTextValue(e, "camp_id");
		s_rcp_status = XmlUtil.getChildTextValue(e, "rcp_status");
		s_jtk_status = XmlUtil.getChildTextValue(e, "jtk_status");
		s_inb_status = XmlUtil.getChildTextValue(e, "inb_status");
		s_mailer_status = XmlUtil.getChildTextValue(e, "mailer_status");
	}

	// === Other Methods ===
}



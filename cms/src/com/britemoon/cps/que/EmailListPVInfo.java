package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class EmailListPVInfo extends BriteObject
{
	// === Properties ===

	public String s_list_id = null;
	public String s_pv_report_group_id = null;
	private static Logger logger = Logger.getLogger(EmailListItem.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public EmailListPVInfo()
	{
	}

	public EmailListPVInfo(String sListId, String sPVReportGroupID ) throws Exception
	{
		s_list_id = sListId;
		s_pv_report_group_id = sPVReportGroupID;
		retrieve();
	}

	public EmailListPVInfo(Element e) throws Exception
	{
		fromXml(e);
	}

	// === For RCP only ===

	// override this method to return something reasonable
	// otherwise variable m_sOwnerId defined in BriteObject will be returned
	// public String getOwnerId() { return s_cust_id; }

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	list_id," +
		"	pv_report_group_id" +
		" FROM cque_email_list_pv_info" +
		" WHERE" +
		"	(list_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_list_id);

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
		s_list_id = rs.getString(1);
		s_pv_report_group_id = rs.getString(2);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cque_email_list_pv_info_save" +
		"	@list_id=?," +
		"	@pv_report_group_id=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_list_id);
		pstmt.setString(2, s_pv_report_group_id);


		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_list_id = rs.getString(1);

			nReturnCode = 1;
		}
		rs.close();

		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cque_email_list_pv_info" +
		" WHERE" +
		"	(list_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_list_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "email_list_pv_info";
	public String getMainElementName() { return m_sMainElementName; }

	// === To XML Methods ===

	public void appendPropsToXml(Element e)
	{
		if( s_list_id != null ) XmlUtil.appendTextChild(e, "list_id", s_list_id);
		if( s_pv_report_group_id != null ) XmlUtil.appendCDataChild(e, "pv_report_group_id", s_pv_report_group_id);
	}

	// === From XML Methods ===

	public void getPropsFromXml(Element e)
	{

		s_list_id = XmlUtil.getChildTextValue(e, "list_id");
		s_pv_report_group_id = XmlUtil.getChildCDataValue(e, "pv_report_group_id");
	}

	// === Other Methods ===
}



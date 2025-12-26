package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CampPVHist extends BriteObject
{
	// === Properties ===
	
	public String s_pv_hist_id = null;
	public String s_pv_test_type_id = null;
	public String s_cust_id = null;
	public String s_camp_id = null;
	public String s_pv_iq = null;
	public String s_test_date = null;
	public String s_origin_camp_id = null;
	public String s_cont_id = null;
	public String s_tester_id = null;
	
	private static Logger logger = Logger.getLogger(CampList.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public CampPVHist ()
	{
	}
	
	public CampPVHist (String val) throws Exception
	{
		s_pv_hist_id = val;
		retrieve();
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	pv_hist_id," +
		"	pv_test_type_id," +
		"	cust_id," +
		"	camp_id," +
		"	pv_iq," +
		"	test_date," +
		"	origin_camp_id," +
		"	cont_id," +
		"	tester_id" +
		" FROM cque_camp_pv_hist" +
		" WHERE" +
		"	(pv_hist_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_pv_hist_id);

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
		s_pv_hist_id = rs.getString(1);
		s_pv_test_type_id = rs.getString(2);
		s_cust_id = rs.getString(3);
		s_camp_id = rs.getString(4);
		s_pv_iq = rs.getString(5);
		s_test_date = rs.getString(6);
		s_origin_camp_id = rs.getString(7);
		s_cont_id = rs.getString(8);
		s_tester_id = rs.getString(9);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cque_camp_pv_hist_save" +
		"	@pv_hist_id=?," +
		"	@pv_test_type_id=?," +
		"	@cust_id=?," +
		"	@camp_id=?," +
		"	@pv_iq=?," +
		"	@origin_camp_id=?," +
		"	@cont_id=?," +
		"	@tester_id=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;
		pstmt.setString(1, s_pv_hist_id);
		pstmt.setString(2, s_pv_test_type_id);
		pstmt.setString(3, s_cust_id);
		pstmt.setString(4, s_camp_id);
		pstmt.setString(5, s_pv_iq);
		pstmt.setString(6, s_origin_camp_id);
		pstmt.setString(7, s_cont_id);
		pstmt.setString(8, s_tester_id);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_pv_hist_id = rs.getString(1);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cque_camp_pv_hist" +
		" WHERE" +
		"	(pv_hist_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_pv_hist_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "camp_pv_hist";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
	}

	// === From XML Methods ===	


	public void getPropsFromXml(Element e)
	{
	}

	// === Other Methods ===
}



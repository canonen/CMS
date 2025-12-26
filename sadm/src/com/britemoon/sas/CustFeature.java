package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;

import com.britemoon.cps.XmlUtil;
import org.w3c.dom.*;
import org.apache.log4j.*;
public class CustFeature extends BriteObject
{
	// === Properties ===

	public String s_cust_id = null;
	public String s_feature_id = null;
	//log4j implementation
	private static Logger logger = Logger.getLogger(CustFeature.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===
	public CustFeature()
	{
	}
	
	public CustFeature(String sCustId, String sFeatureId) throws Exception
	{
		s_cust_id = sCustId;
		s_feature_id = sFeatureId;
		retrieve();
	}

	public CustFeature(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	cust_id," +
		"	feature_id" +
		" FROM sadm_cust_feature" +
		" WHERE" +
		"	(cust_id=?) AND" +
		"	(feature_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_feature_id);

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
		s_feature_id = rs.getString(2);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_sadm_cust_feature_save" +
		"	@cust_id=?," +
		"	@feature_id=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_feature_id);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_cust_id = rs.getString(1);
			s_feature_id = rs.getString(2);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM sadm_cust_feature" +
		" WHERE" +
		"	(cust_id=?) AND" +
		"	(feature_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_feature_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "cust_feature";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_feature_id != null ) XmlUtil.appendTextChild(e, "feature_id", s_feature_id);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_feature_id = XmlUtil.getChildTextValue(e, "feature_id");
	}

	// === Other Methods ===
        
        public boolean exists() throws Exception
	{
		return exists(s_cust_id, s_feature_id);
	}
	
	public static boolean exists(String sCustId, int nFeatureId) throws Exception
	{
		return exists(sCustId, String.valueOf(nFeatureId));
	}
	
	public static boolean exists(String sCustId, String sFeatureId) throws Exception
	{
		CustFeature cf = new CustFeature();
		cf.s_cust_id = sCustId;
		cf.s_feature_id = sFeatureId;
		
		if(cf.retrieve() > 0) return true;
		else return false;
	}	
}



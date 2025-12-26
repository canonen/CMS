package com.britemoon.cps.upd;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class Batch extends BriteObject
{
	// === Properties ===

	public String s_batch_id = null;
	public String s_type_id = null;
	public String s_cust_id = null;
	public String s_batch_name = null;
	public String s_descrip = null;
	private static Logger logger = Logger.getLogger(Batch.class.getName());	

	// === Parents ===

	// === Children ===

	// public Import(s) m_Import(s) = null;

	// === Constructors ===

	public Batch()
	{
	}
	
	public Batch(String sBatchId) throws Exception
	{
		s_batch_id = sBatchId;
		retrieve();
	}

	public Batch(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	batch_id," +
		"	type_id," +
		"	cust_id," +
		"	batch_name," +
		"	descrip" +
		" FROM cupd_batch" +
		" WHERE" +
		"	(batch_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_batch_id);

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
		s_batch_id = rs.getString(1);
		s_type_id = rs.getString(2);
		s_cust_id = rs.getString(3);
		b = rs.getBytes(4);
		s_batch_name = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(5);
		s_descrip = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cupd_batch_save" +
		"	@batch_id=?," +
		"	@type_id=?," +
		"	@cust_id=?," +
		"	@batch_name=?," +
		"	@descrip=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_batch_id);
		pstmt.setString(2, s_type_id);
		pstmt.setString(3, s_cust_id);
		if(s_batch_name == null) pstmt.setString(4, s_batch_name);
		else pstmt.setBytes(4, s_batch_name.getBytes("UTF-8"));
		if(s_descrip == null) pstmt.setString(5, s_descrip);
		else pstmt.setBytes(5, s_descrip.getBytes("UTF-8"));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_batch_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cupd_batch" +
		" WHERE" +
		"	(batch_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_batch_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "batch";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_batch_id != null ) XmlUtil.appendTextChild(e, "batch_id", s_batch_id);
		if( s_type_id != null ) XmlUtil.appendTextChild(e, "type_id", s_type_id);
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_batch_name != null ) XmlUtil.appendCDataChild(e, "batch_name", s_batch_name);
		if( s_descrip != null ) XmlUtil.appendCDataChild(e, "descrip", s_descrip);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_batch_id = XmlUtil.getChildTextValue(e, "batch_id");
		s_type_id = XmlUtil.getChildTextValue(e, "type_id");
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_batch_name = XmlUtil.getChildCDataValue(e, "batch_name");
		s_descrip = XmlUtil.getChildCDataValue(e, "descrip");
	}

	// === Other Methods ===
}



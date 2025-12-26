package com.britemoon.cps.exp;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ExportParam extends BriteObject
{
	private static Logger logger = Logger.getLogger(ExportParam.class.getName());
	//	 === Properties ===
	public String s_param_id = null;
	public String s_file_id = null;
	public String s_param_name = null;
	public String s_param_value = null;
	
	public ExportParam(){}
	
	public ExportParam(String sFileId) throws Exception
	{		
		s_file_id = sFileId;
		retrieve();
	}
	
	public ExportParam(Element e) throws Exception
	{
		fromXml(e);
	}
	
//	 === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	param_id," +
		"	file_id," +
		"	param_name," +
		"	param_value" +
		" FROM cexp_export_param" +
		" WHERE" + 
		"  (file_id=?)";
	
	public String getRetrieveSql() { return m_sRetrieveSql; }
	
	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;
		
		pstmt.setString(1, s_file_id);

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
		s_param_id = rs.getString(1);
		s_file_id = rs.getString(2);
		b = rs.getBytes(3);
		s_param_name = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(4);
		s_param_value = (b == null)?null:new String(b,"UTF-8");
	}
	
//	 === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cexp_export_param_save" +
		"	@param_id=?," +
		"	@file_id=?," +
		"	@param_name=?," +
		"	@param_value=?";
	
	public String getSaveSql() { return m_sSaveSql; }
	
	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_param_id);
		pstmt.setString(2, s_file_id);
		if(s_param_name == null) pstmt.setString(3, s_param_name);
		else pstmt.setBytes(3, s_param_name.getBytes("UTF-8"));
		if(s_param_value == null) pstmt.setString(4, s_param_value);
		else pstmt.setBytes(4, s_param_value.getBytes("UTF-8"));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_param_id = rs.getString(1);
			s_file_id = rs.getString(2);
			s_param_name = rs.getString(3);
			s_param_value = rs.getString(4);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}
	
	//=== DB Method delete()===
	public String m_sDeleteSql =
		" DELETE FROM cexp_export_param" +
		" WHERE" +
		"	(file_id=?)";
	
	public String getDeleteSql() { return m_sDeleteSql; }
	
	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_file_id);
		return pstmt.executeUpdate();
	}
	
	//=== XML Methods ===
	public String m_sMainElementName = "export_param";
	public String getMainElementName() { return m_sMainElementName; }
	
	//=== To XML Methods ===	
	public void appendPropsToXml(Element e)
	{
		if( s_param_id != null ) XmlUtil.appendTextChild(e, "param_id", s_param_id);
		if( s_file_id != null ) XmlUtil.appendTextChild(e, "file_id", s_file_id);
		if( s_param_name != null ) XmlUtil.appendCDataChild(e, "param_name", s_param_name);
		if( s_param_value != null ) XmlUtil.appendCDataChild(e, "param_value", s_param_value);
	}
	
	//=== From XML Methods ===	
	public void getPropsFromXml(Element e)
	{
		s_param_id = XmlUtil.getChildTextValue(e, "param_id");
		s_file_id = XmlUtil.getChildTextValue(e, "file_id");
		s_param_name = XmlUtil.getChildCDataValue(e, "param_name");
		s_param_value = XmlUtil.getChildCDataValue(e, "param_value");
	}
}

package com.britemoon.cps.ftp;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class FtpFile extends BriteObject
{
	// === Properties ===

	public String s_file_id = null;
	public String s_task_id = null;
	public String s_file_name_remote = null;
	public String s_file_name_local = null;
	public String s_start_date = null;
	public String s_finish_date = null;
	public String s_error_msg = null;
	public String s_status_id = null;
	public String s_type_id = null;
	private static Logger logger = Logger.getLogger(FtpFile.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public FtpFile()
	{
	}
	
	public FtpFile(String sFtpFileId) throws Exception
	{
		s_file_id = sFtpFileId;
		retrieve();
	}

	public FtpFile(Element e) throws Exception
	{
		fromXml(e);
	}

	// === For RCP only ===

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	file_id," +		
		"	task_id," +
		"	file_name_remote," +
		"	file_name_local," +
		"	start_date," +
		"	finish_date," +
		"	error_msg," +
		"	status_id," +
		"	type_id" +
		" FROM cftp_ftp_file" +
		" WHERE "+
		"	(file_id=?)";

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
		s_file_id = rs.getString(1);
		s_task_id = rs.getString(2);

		b = rs.getBytes(3);
		s_file_name_remote = (b == null)?null:new String(b,"UTF-8");

		b = rs.getBytes(4);
		s_file_name_local = (b == null)?null:new String(b,"UTF-8");

		s_start_date = rs.getString(5);
		s_finish_date = rs.getString(6);

		b = rs.getBytes(7);
		s_error_msg = (b == null)?null:new String(b,"UTF-8");
		
		s_status_id = rs.getString(8);
		s_type_id = rs.getString(9);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cftp_ftp_file_save" +
		"	@file_id=?," +		
		"	@task_id=?," +
		"	@file_name_remote=?," +
		"	@file_name_local=?," +
		"	@start_date=?," +
		"	@finish_date=?," +
		"	@error_msg=?," +
		"	@status_id=?," +
		"   @type_id=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_file_id);
		pstmt.setString(2, s_task_id);

		if(s_file_name_remote == null) pstmt.setString(3, s_file_name_remote);
		else pstmt.setBytes(3, s_file_name_remote.getBytes("UTF-8"));

		if(s_file_name_local == null) pstmt.setString(4, s_file_name_local);
		else pstmt.setBytes(4, s_file_name_local.getBytes("UTF-8"));

		pstmt.setString(5, s_start_date);
		pstmt.setString(6, s_finish_date);

		if(s_error_msg == null) pstmt.setString(7, s_error_msg);
		else pstmt.setBytes(7, s_error_msg.getBytes("UTF-8"));

		pstmt.setString(8, s_status_id);
		pstmt.setString(9, s_type_id);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_file_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cftp_ftp_file" +
		" WHERE" +
		"	(file_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_file_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "ftp_file";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_file_id != null ) XmlUtil.appendTextChild(e, "file_id", s_file_id);	
		if( s_task_id != null ) XmlUtil.appendTextChild(e, "task_id", s_task_id);
		if( s_file_name_remote != null ) XmlUtil.appendCDataChild(e, "file_name_remote", s_file_name_remote);
		if( s_file_name_local != null ) XmlUtil.appendCDataChild(e, "file_name_local", s_file_name_local);
		if( s_start_date != null ) XmlUtil.appendTextChild(e, "start_date", s_start_date);
		if( s_finish_date != null ) XmlUtil.appendTextChild(e, "finish_date", s_finish_date);
		if( s_error_msg != null ) XmlUtil.appendCDataChild(e, "error_msg", s_error_msg);
		if( s_status_id != null ) XmlUtil.appendTextChild(e, "status_id", s_status_id);
		if( s_type_id != null ) XmlUtil.appendTextChild(e, "type_id", s_type_id);
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_file_id = XmlUtil.getChildTextValue(e, "file_id");	
		s_task_id = XmlUtil.getChildTextValue(e, "task_id");
		s_file_name_remote = XmlUtil.getChildCDataValue(e, "file_name_remote");
		s_file_name_local = XmlUtil.getChildCDataValue(e, "file_name_local");
		s_start_date = XmlUtil.getChildTextValue(e, "start_date");
		s_finish_date = XmlUtil.getChildTextValue(e, "finish_date");
		s_error_msg = XmlUtil.getChildCDataValue(e, "error_msg");
		s_status_id = XmlUtil.getChildTextValue(e, "status_id");
		s_type_id = XmlUtil.getChildTextValue(e, "type_id");
	}

	// === Other Methods ===
}

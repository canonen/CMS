package com.britemoon.cps.ftp;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class FtpTask extends BriteObject
{
	// === Properties ===

	public String s_task_id = null;
	public String s_task_name = null;	
	public String s_server = null;
	public String s_directory = null;
	public String s_username = null;
	public String s_password = null;
	public String s_filename_prefix = null;
	public String s_filename_suffix = null;
	public String s_date_format = null;
	public String s_pgp_flag = null;
	public String s_cust_id = null;	
	public String s_type_id = null;
	private static Logger logger = Logger.getLogger(FtpTask.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public FtpTask()
	{
	}
	
	public FtpTask(String sTaskId) throws Exception
	{
		s_task_id = sTaskId;
		retrieve();
	}

	public FtpTask(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	task_id," +
		"	task_name," +		
		"	server," +
		"	directory," +
		"	username," +
		"	password," +
		"	filename_prefix," +
		"	filename_suffix," +
		"	date_format," +
		"	pgp_flag," +
		"	cust_id, " +
		"	type_id" +
		" FROM cftp_ftp_task" +
		" WHERE" +
		"	(task_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_task_id);

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
		s_task_id = rs.getString(1);

		b = rs.getBytes(2);
		s_task_name = (b == null)?null:new String(b,"UTF-8");

		b = rs.getBytes(3);
		s_server = (b == null)?null:new String(b,"UTF-8");

		b = rs.getBytes(4);
		s_directory = (b == null)?null:new String(b,"UTF-8");

		b = rs.getBytes(5);
		s_username = (b == null)?null:new String(b,"UTF-8");

		b = rs.getBytes(6);
		s_password = (b == null)?null:new String(b,"UTF-8");

		b = rs.getBytes(7);
		s_filename_prefix = (b == null)?null:new String(b,"UTF-8");

		b = rs.getBytes(8);
		s_filename_suffix = (b == null)?null:new String(b,"UTF-8");

		b = rs.getBytes(9);
		s_date_format = (b == null)?null:new String(b,"UTF-8");

		s_pgp_flag = rs.getString(10);
		s_cust_id = rs.getString(11);
		s_type_id = rs.getString(12);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cftp_ftp_task_save" +
		"	@task_id=?," +
		"	@task_name=?," +		
		"	@server=?," +
		"	@directory=?," +
		"	@username=?," +
		"	@password=?," +
		"	@filename_prefix=?," +
		"	@filename_suffix=?," +
		"	@date_format=?," +
		"	@pgp_flag=?," +
		"	@cust_id=?," + 
		"	@type_id=?"; 

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_task_id);
		
		if(s_task_name == null) pstmt.setString(2, s_task_name);
		else pstmt.setBytes(2, s_task_name.getBytes("UTF-8"));
		
		if(s_server == null) pstmt.setString(3, s_server);
		else pstmt.setBytes(3, s_server.getBytes("UTF-8"));
		
		if(s_directory == null) pstmt.setString(4, s_directory);
		else pstmt.setBytes(4, s_directory.getBytes("UTF-8"));
		
		if(s_username == null) pstmt.setString(5, s_username);
		else pstmt.setBytes(5, s_username.getBytes("UTF-8"));
		
		if(s_password == null) pstmt.setString(6, s_password);
		else pstmt.setBytes(6, s_password.getBytes("UTF-8"));
		
		if(s_filename_prefix == null) pstmt.setString(7, s_filename_prefix);
		else pstmt.setBytes(7, s_filename_prefix.getBytes("UTF-8"));
		
		if(s_filename_suffix == null) pstmt.setString(8, s_filename_suffix);
		else pstmt.setBytes(8, s_filename_suffix.getBytes("UTF-8"));
		
		if(s_date_format == null) pstmt.setString(9, s_date_format);
		else pstmt.setBytes(9, s_date_format.getBytes("UTF-8"));
		
		pstmt.setString(10, s_pgp_flag);
		pstmt.setString(11, s_cust_id);
		pstmt.setString(12, s_type_id);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_task_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cftp_ftp_task" +
		" WHERE" +
		"	(task_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_task_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "ftp_task";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_task_id != null ) XmlUtil.appendTextChild(e, "task_id", s_task_id);
		if( s_task_name != null ) XmlUtil.appendTextChild(e, "task_name", s_task_name);		
		if( s_server != null ) XmlUtil.appendCDataChild(e, "server", s_server);
		if( s_directory != null ) XmlUtil.appendCDataChild(e, "directory", s_directory);
		if( s_username != null ) XmlUtil.appendCDataChild(e, "username", s_username);
		if( s_password != null ) XmlUtil.appendCDataChild(e, "password", s_password);
		if( s_filename_prefix != null ) XmlUtil.appendCDataChild(e, "filename_prefix", s_filename_prefix);
		if( s_filename_suffix != null ) XmlUtil.appendCDataChild(e, "filename_suffix", s_filename_suffix);
		if( s_date_format != null ) XmlUtil.appendCDataChild(e, "date_format", s_date_format);
		if( s_pgp_flag != null ) XmlUtil.appendTextChild(e, "pgp_flag", s_pgp_flag);
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);	
		if( s_type_id != null ) XmlUtil.appendTextChild(e, "type_id", s_type_id);	
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_task_id = XmlUtil.getChildTextValue(e, "task_id");
		s_task_name = XmlUtil.getChildCDataValue(e, "task_name");
		s_server = XmlUtil.getChildCDataValue(e, "server");
		s_directory = XmlUtil.getChildCDataValue(e, "directory");
		s_username = XmlUtil.getChildCDataValue(e, "username");
		s_password = XmlUtil.getChildCDataValue(e, "password");
		s_filename_prefix = XmlUtil.getChildCDataValue(e, "filename_prefix");
		s_filename_suffix = XmlUtil.getChildCDataValue(e, "filename_suffix");
		s_date_format = XmlUtil.getChildCDataValue(e, "date_format");
		s_pgp_flag = XmlUtil.getChildTextValue(e, "pgp_flag");
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_type_id = XmlUtil.getChildTextValue(e, "type_id");
	}

	// === Other Methods ===
}

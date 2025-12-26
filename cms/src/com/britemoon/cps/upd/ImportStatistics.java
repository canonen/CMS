package com.britemoon.cps.upd;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.io.*;
import java.sql.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ImportStatistics extends BriteObject
{
	// === Properties ===

	public String s_import_id = null;
	
	// === preprocessing stats ===
		
	public String s_tot_rows = null;
	public String s_bad_rows = null;
	public String s_tot_file_recips = null;
	public String s_warning_recips = null;
	
	// === staging stats ===
		
	public String s_tot_recips = null;
	public String s_file_dups = null;	
	public String s_bad_emails = null;
	public String s_bad_fingerprints = null;

	// === staging stats ===

	public String s_new_recips = null;
	public String s_dup_recips = null;
	public String s_num_committed = null;
	public String s_left_to_commit = null;

	public String s_error_message = null;
	private static Logger logger = Logger.getLogger(ImportStatistics.class.getName());	

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public ImportStatistics()
	{
	}
	
	public ImportStatistics(String sImportId) throws Exception
	{
		s_import_id = sImportId;
		retrieve();
	}

	public ImportStatistics(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	import_id," +
		"	tot_rows," +
		"	bad_rows," +
		"	tot_file_recips," +
		"	bad_emails," +
		"	warning_recips," +
		"	file_dups," +
		"	tot_recips," +
		"	new_recips," +
		"	dup_recips," +
		"	num_committed," +
		"	left_to_commit," +
		"	error_message," +
		"	bad_fingerprints" +
		" FROM cupd_import_statistics" +
		" WHERE" +
		"	(import_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_import_id);

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
		s_import_id = rs.getString(1);
		s_tot_rows = rs.getString(2);
		s_bad_rows = rs.getString(3);
		s_tot_file_recips = rs.getString(4);
		s_bad_emails = rs.getString(5);
		s_warning_recips = rs.getString(6);
		s_file_dups = rs.getString(7);
		s_tot_recips = rs.getString(8);
		s_new_recips = rs.getString(9);
		s_dup_recips = rs.getString(10);
		s_num_committed = rs.getString(11);
		s_left_to_commit = rs.getString(12);
		b = rs.getBytes(13);
		s_error_message = (b == null)?null:new String(b,"UTF-8");
		s_bad_fingerprints = rs.getString(14);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cupd_import_statistics_save" +
		"	@import_id=?," +
		"	@tot_rows=?," +
		"	@bad_rows=?," +
		"	@tot_file_recips=?," +
		"	@bad_emails=?," +
		"	@warning_recips=?," +
		"	@file_dups=?," +
		"	@tot_recips=?," +
		"	@new_recips=?," +
		"	@dup_recips=?," +
		"	@num_committed=?," +
		"	@left_to_commit=?," +
		"	@error_message=?," +
		"	@bad_fingerprints=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_import_id);
		pstmt.setString(2, s_tot_rows);
		pstmt.setString(3, s_bad_rows);
		pstmt.setString(4, s_tot_file_recips);
		pstmt.setString(5, s_bad_emails);
		pstmt.setString(6, s_warning_recips);
		pstmt.setString(7, s_file_dups);
		pstmt.setString(8, s_tot_recips);
		pstmt.setString(9, s_new_recips);
		pstmt.setString(10, s_dup_recips);
		pstmt.setString(11, s_num_committed);
		pstmt.setString(12, s_left_to_commit);
		if(s_error_message == null) pstmt.setString(13, s_error_message);
		else pstmt.setBytes(13, s_error_message.getBytes("UTF-8"));
		pstmt.setString(14, s_bad_fingerprints);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_import_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cupd_import_statistics" +
		" WHERE" +
		"	(import_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_import_id);
		return pstmt.executeUpdate();
	}
	
	// === XML Methods ===

	public String m_sMainElementName = "import_statistics";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_import_id != null ) XmlUtil.appendTextChild(e, "import_id", s_import_id);
		if( s_tot_rows != null ) XmlUtil.appendTextChild(e, "tot_rows", s_tot_rows);
		if( s_bad_rows != null ) XmlUtil.appendTextChild(e, "bad_rows", s_bad_rows);
		if( s_tot_file_recips != null ) XmlUtil.appendTextChild(e, "tot_file_recips", s_tot_file_recips);
		if( s_bad_emails != null ) XmlUtil.appendTextChild(e, "bad_emails", s_bad_emails);
		if( s_warning_recips != null ) XmlUtil.appendTextChild(e, "warning_recips", s_warning_recips);
		if( s_file_dups != null ) XmlUtil.appendTextChild(e, "file_dups", s_file_dups);
		if( s_tot_recips != null ) XmlUtil.appendTextChild(e, "tot_recips", s_tot_recips);
		if( s_new_recips != null ) XmlUtil.appendTextChild(e, "new_recips", s_new_recips);
		if( s_dup_recips != null ) XmlUtil.appendTextChild(e, "dup_recips", s_dup_recips);
		if( s_num_committed != null ) XmlUtil.appendTextChild(e, "num_committed", s_num_committed);
		if( s_left_to_commit != null ) XmlUtil.appendTextChild(e, "left_to_commit", s_left_to_commit);
		if( s_error_message != null ) XmlUtil.appendCDataChild(e, "error_message", s_error_message);
		if( s_bad_fingerprints != null ) XmlUtil.appendTextChild(e, "bad_fingerprints", s_bad_fingerprints);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_import_id = XmlUtil.getChildTextValue(e, "import_id");
		s_tot_rows = XmlUtil.getChildTextValue(e, "tot_rows");
		s_bad_rows = XmlUtil.getChildTextValue(e, "bad_rows");
		s_tot_file_recips = XmlUtil.getChildTextValue(e, "tot_file_recips");
		s_bad_emails = XmlUtil.getChildTextValue(e, "bad_emails");
		s_warning_recips = XmlUtil.getChildTextValue(e, "warning_recips");
		s_file_dups = XmlUtil.getChildTextValue(e, "file_dups");
		s_tot_recips = XmlUtil.getChildTextValue(e, "tot_recips");
		s_new_recips = XmlUtil.getChildTextValue(e, "new_recips");
		s_dup_recips = XmlUtil.getChildTextValue(e, "dup_recips");
		s_num_committed = XmlUtil.getChildTextValue(e, "num_committed");
		s_left_to_commit = XmlUtil.getChildTextValue(e, "left_to_commit");
		s_error_message = XmlUtil.getChildCDataValue(e, "error_message");
		s_bad_fingerprints = XmlUtil.getChildTextValue(e, "bad_fingerprints");
	}

	// === Other Methods ===
}



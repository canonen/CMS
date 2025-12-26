package com.britemoon.cps.upd;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ImportNewsletter extends BriteObject
{
	// === Properties ===

	public String s_import_id = null;
	public String s_attr_id = null;
	private static Logger logger = Logger.getLogger(ImportNewsletter.class.getName());	

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public ImportNewsletter()
	{
	}
	
	public ImportNewsletter(String sImportId, String sAttrId) throws Exception
	{
		s_import_id = sImportId;
		s_attr_id = sAttrId;
		retrieve();
	}

	public ImportNewsletter(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	import_id," +
		"	attr_id" +
		" FROM cupd_import_newsletter" +
		" WHERE" +
		"	(import_id=?) AND" +
		"	(attr_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_import_id);
		pstmt.setString(2, s_attr_id);

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
		s_attr_id = rs.getString(2);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cupd_import_newsletter_save" +
		"	@import_id=?," +
		"	@attr_id=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_import_id);
		pstmt.setString(2, s_attr_id);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_import_id = rs.getString(1);
			s_attr_id = rs.getString(2);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cupd_import_newsletter" +
		" WHERE" +
		"	(import_id=?) AND" +
		"	(attr_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_import_id);
		pstmt.setString(2, s_attr_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "import_newsletter";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_import_id != null ) XmlUtil.appendTextChild(e, "import_id", s_import_id);
		if( s_attr_id != null ) XmlUtil.appendTextChild(e, "attr_id", s_attr_id);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_import_id = XmlUtil.getChildTextValue(e, "import_id");
		s_attr_id = XmlUtil.getChildTextValue(e, "attr_id");
	}

	// === Other Methods ===
}



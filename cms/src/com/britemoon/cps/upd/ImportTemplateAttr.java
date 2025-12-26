package com.britemoon.cps.upd;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.io.*;
import java.sql.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ImportTemplateAttr extends BriteObject
{
	// === Properties ===

	public String s_template_id = null;
	public String s_attr_id = null;	
	public String s_seq = null;
	private static Logger logger = Logger.getLogger(ImportTemplateAttr.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public ImportTemplateAttr()
	{
	}
	
	public ImportTemplateAttr(String sTemplateId, String sSeq) throws Exception
	{
		s_template_id = sTemplateId;
		s_seq = sSeq;
		retrieve();
	}

	public ImportTemplateAttr(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	template_id," +
		"	attr_id," +
		"	seq" +
		" FROM cupd_import_template_attr" +
		" WHERE" +
		"	(template_id=?) AND" +
		"	(seq=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_template_id);
		pstmt.setString(2, s_attr_id);
		pstmt.setString(3, s_seq);

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
		s_template_id = rs.getString(1);
		s_attr_id = rs.getString(2);
		s_seq = rs.getString(3);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cupd_import_template_attr_save" +
		"	@template_id=?," +
		"	@seq=?," +
		"	@attr_id=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_template_id);
		pstmt.setString(2, s_seq);		
		pstmt.setString(3, s_attr_id);		

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_template_id = rs.getString(1);
			s_seq = rs.getString(2);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cupd_import_template_attr" +
		" WHERE" +
		"	(template_id=?) AND" +
		"	(seq=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_template_id);
		pstmt.setString(2, s_seq);

		return pstmt.executeUpdate();
	}
	
	// === XML Methods ===

	public String m_sMainElementName = "import_template_attr";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_template_id != null ) XmlUtil.appendTextChild(e, "template_id", s_template_id);
		if( s_attr_id != null ) XmlUtil.appendTextChild(e, "attr_id", s_attr_id);
		if( s_seq != null ) XmlUtil.appendTextChild(e, "seq", s_seq);
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_template_id = XmlUtil.getChildTextValue(e, "template_id");
		s_attr_id = XmlUtil.getChildTextValue(e, "attr_id");
		s_seq = XmlUtil.getChildTextValue(e, "seq");
	}

	// === Other Methods ===
}



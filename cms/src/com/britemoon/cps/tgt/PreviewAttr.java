package com.britemoon.cps.tgt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class PreviewAttr extends BriteObject
{
	// === Properties ===

	public String s_filter_id = null;
	public String s_attr_id = null;
	public String s_display_seq = null;
	private static Logger logger = Logger.getLogger(PreviewAttr.class.getName());	

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public PreviewAttr()
	{
	}
	
	public PreviewAttr(String sFilterId, String sAttrId) throws Exception
	{
		s_filter_id = sFilterId;
		s_attr_id = sAttrId;
		retrieve();
	}

	public PreviewAttr(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	filter_id," +
		"	attr_id," +
		"	display_seq" +
		" FROM ctgt_preview_attr" +
		" WHERE" +
		"	(filter_id=?) AND" +
		"	(attr_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_filter_id);
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
		s_filter_id = rs.getString(1);
		s_attr_id = rs.getString(2);
		s_display_seq = rs.getString(3);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ctgt_preview_attr_save" +
		"	@filter_id=?," +
		"	@attr_id=?," +
		"	@display_seq=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_filter_id);
		pstmt.setString(2, s_attr_id);
		pstmt.setString(3, s_display_seq);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_filter_id = rs.getString(1);
			s_attr_id = rs.getString(2);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ctgt_preview_attr" +
		" WHERE" +
		"	(filter_id=?) AND" +
		"	(attr_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_filter_id);
		pstmt.setString(2, s_attr_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "preview_attr";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_filter_id != null ) XmlUtil.appendTextChild(e, "filter_id", s_filter_id);
		if( s_attr_id != null ) XmlUtil.appendTextChild(e, "attr_id", s_attr_id);
		if( s_display_seq != null ) XmlUtil.appendTextChild(e, "display_seq", s_display_seq);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_filter_id = XmlUtil.getChildTextValue(e, "filter_id");
		s_attr_id = XmlUtil.getChildTextValue(e, "attr_id");
		s_display_seq = XmlUtil.getChildTextValue(e, "display_seq");
	}

	// === Other Methods ===
}



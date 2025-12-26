package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;

import com.britemoon.cps.XmlUtil;
import org.w3c.dom.*;

public class SystemNote extends BriteObject
{
	// === Properties ===

	public String s_note_id = null;
	public String s_subject = null;
	public String s_body = null;
	public String s_published = null;
	public String s_modify_date = null;

	// === Constructors ===

	public SystemNote()
	{
	}
	
	public SystemNote(String sNoteId) throws Exception
	{
		s_note_id = sNoteId;
		retrieve();
	}

	public SystemNote(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	n.note_id," +
		"	n.subject," +
		"	n.body," +
		"	n.published," +
        "   CONVERT(VARCHAR(32), n.modify_date, 100) as 'modify_date_txt'" +
		" FROM sadm_system_note n " +
		" WHERE" +
		"	(n.note_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_note_id);

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
		s_note_id = rs.getString(1);
        s_subject = rs.getString(2);
		b = rs.getBytes(3);
		s_body = (b == null)?null:new String(b,"UTF-8");
		s_published = rs.getString(4);
		s_modify_date = rs.getString(5);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_sadm_system_note_save" +
		"	@note_id=?," +
		"	@subject=?," +
		"	@body=?," +
		"	@published=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_note_id);
		pstmt.setString(2, s_subject);
		if(s_body == null) pstmt.setString(3, s_body);
		else pstmt.setBytes(3, s_body.getBytes("UTF-8"));
		pstmt.setString(4, s_published);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_note_id = rs.getString(1);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM sadm_system_note" +
		" WHERE" +
		"	(note_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_note_id);

		return pstmt.executeUpdate();
	}
	
	// === XML Methods ===

	public String m_sMainElementName = "system_note";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_note_id != null ) XmlUtil.appendTextChild(e, "note_id", s_note_id);
		if( s_subject != null ) XmlUtil.appendTextChild(e, "subject", s_subject);
		if( s_body != null ) XmlUtil.appendCDataChild(e, "body", s_body);
		if( s_published != null ) XmlUtil.appendTextChild(e, "published", s_published);
		if( s_modify_date != null ) XmlUtil.appendTextChild(e, "modify_date", s_modify_date);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_note_id = XmlUtil.getChildTextValue(e, "note_id");
		s_subject = XmlUtil.getChildTextValue(e, "subject");
		s_body = XmlUtil.getChildCDataValue(e, "body");
		s_published = XmlUtil.getChildTextValue(e, "published");
		s_modify_date = XmlUtil.getChildTextValue(e, "modify_date");
	}

}

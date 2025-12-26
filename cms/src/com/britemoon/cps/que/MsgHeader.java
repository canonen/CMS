package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class MsgHeader extends BriteObject
{
	// === Properties ===

	public String s_camp_id = null;
	public String s_from_name = null;
	public String s_from_address = null;
	public String s_from_address_id = null;
	public String s_subject_html = null;
	public String s_reply_to = null;
	public String s_subject_text = null;
	public String s_subject_aol = null;
	private static Logger logger = Logger.getLogger(MsgHeader.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public MsgHeader()
	{
	}
	
	public MsgHeader(String sCampId) throws Exception
	{
		s_camp_id = sCampId;
		retrieve();
	}

	public MsgHeader(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	camp_id," +
		"	from_name," +
		"	from_address," +
		"	from_address_id," +
		"	subject_html," +
		"	reply_to," +
		"	subject_text," +
		"	subject_aol" +
		" FROM cque_msg_header" +
		" WHERE" +
		"	(camp_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_camp_id);

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
		s_camp_id = rs.getString(1);
		b = rs.getBytes(2);
		s_from_name = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(3);
		s_from_address = (b == null)?null:new String(b,"UTF-8");
		s_from_address_id = rs.getString(4);
		b = rs.getBytes(5);
		s_subject_html = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(6);
		s_reply_to = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(7);
		s_subject_text = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(8);
		s_subject_aol = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cque_msg_header_save" +
		"	@camp_id=?," +
		"	@from_name=?," +
		"	@from_address=?," +
		"	@from_address_id=?," +
		"	@subject_html=?," +
		"	@reply_to=?," +
		"	@subject_text=?," +
		"	@subject_aol=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		// char replacement
		s_subject_html = CharReplacement.cleanChars(s_subject_html);
		s_subject_text = CharReplacement.cleanChars(s_subject_text);
		s_subject_aol  = CharReplacement.cleanChars(s_subject_aol);

		pstmt.setString(1, s_camp_id);
		if(s_from_name == null) pstmt.setString(2, s_from_name);
		else pstmt.setBytes(2, s_from_name.getBytes("UTF-8"));
		if(s_from_address == null) pstmt.setString(3, s_from_address);
		else pstmt.setBytes(3, s_from_address.getBytes("UTF-8"));
		pstmt.setString(4, s_from_address_id);
		if(s_subject_html == null) pstmt.setString(5, s_subject_html);
		else pstmt.setBytes(5, s_subject_html.getBytes("UTF-8"));
		if(s_reply_to == null) pstmt.setString(6, s_reply_to);
		else pstmt.setBytes(6, s_reply_to.getBytes("UTF-8"));
		if(s_subject_text == null) pstmt.setString(7, s_subject_text);
		else pstmt.setBytes(7, s_subject_text.getBytes("UTF-8"));
		if(s_subject_aol == null) pstmt.setString(8, s_subject_aol);
		else pstmt.setBytes(8, s_subject_aol.getBytes("UTF-8"));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_camp_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cque_msg_header" +
		" WHERE" +
		"	(camp_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_camp_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "msg_header";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_camp_id != null ) XmlUtil.appendTextChild(e, "camp_id", s_camp_id);
		if( s_from_name != null ) XmlUtil.appendCDataChild(e, "from_name", s_from_name);
		if( s_from_address != null ) XmlUtil.appendCDataChild(e, "from_address", s_from_address);
		if( s_from_address_id != null ) XmlUtil.appendTextChild(e, "from_address_id", s_from_address_id);
		if( s_subject_html != null ) XmlUtil.appendCDataChild(e, "subject_html", s_subject_html);
		if( s_reply_to != null ) XmlUtil.appendCDataChild(e, "reply_to", s_reply_to);
		if( s_subject_text != null ) XmlUtil.appendCDataChild(e, "subject_text", s_subject_text);
		if( s_subject_aol != null ) XmlUtil.appendCDataChild(e, "subject_aol", s_subject_aol);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_camp_id = XmlUtil.getChildTextValue(e, "camp_id");
		s_from_name = XmlUtil.getChildCDataValue(e, "from_name");
		s_from_address = XmlUtil.getChildCDataValue(e, "from_address");
		s_from_address_id = XmlUtil.getChildTextValue(e, "from_address_id");
		s_subject_html = XmlUtil.getChildCDataValue(e, "subject_html");
		s_reply_to = XmlUtil.getChildCDataValue(e, "reply_to");
		s_subject_text = XmlUtil.getChildCDataValue(e, "subject_text");
		s_subject_aol = XmlUtil.getChildCDataValue(e, "subject_aol");
	}

	// === Other Methods ===
}



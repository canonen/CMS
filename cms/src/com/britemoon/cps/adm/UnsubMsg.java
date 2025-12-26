package com.britemoon.cps.adm;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class UnsubMsg extends BriteObject
{
	// === Properties ===

	public String s_msg_id = null;
	public String s_msg_name = null;
	public String s_cust_id = null;
	public String s_text_msg = null;
	public String s_html_msg = null;
		
	private static Logger logger = Logger.getLogger(UnsubMsg.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public UnsubMsg()
	{
	}
	
	public UnsubMsg(String sMsgId) throws Exception
	{
		s_msg_id = sMsgId;
		retrieve();
	}

	public UnsubMsg(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	msg_id," +
		"	msg_name," +
		"	cust_id," +
		"	text_msg," +
		"	html_msg" +		
		" FROM ccps_unsub_msg" +
		" WHERE" +
		"	(msg_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_msg_id);

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
		s_msg_id = rs.getString(1);
		b = rs.getBytes(2);
		s_msg_name = (b == null)?null:new String(b,"UTF-8");
		s_cust_id = rs.getString(3);
		b = rs.getBytes(4);
		s_text_msg = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(5);
		s_html_msg = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccps_unsub_msg_save" +
		"	@msg_id=?," +
		"	@msg_name=?," +
		"	@cust_id=?," +
		"	@text_msg=?," +
		"	@html_msg=?"; 

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;
	
		pstmt.setString(1, s_msg_id);

		if(s_msg_name == null) pstmt.setString(2, s_msg_name);
		else pstmt.setBytes(2, s_msg_name.getBytes("UTF-8"));

		pstmt.setString(3, s_cust_id);

		if(s_text_msg == null) pstmt.setNull(4, java.sql.Types.BINARY);
		else pstmt.setBytes(4, s_text_msg.getBytes("UTF-8"));
	
		if(s_html_msg == null) pstmt.setNull(5, java.sql.Types.BINARY);
		else pstmt.setBytes(5, s_html_msg.getBytes("UTF-8"));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			int retValue = rs.getInt(1);
			s_msg_id = String.valueOf(retValue);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccps_unsub_msg" +
		" WHERE" +
		"	(msg_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_msg_id);

		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "unsub_msg";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_msg_id != null ) XmlUtil.appendTextChild(e, "msg_id", s_msg_id);
		if( s_msg_name != null ) XmlUtil.appendCDataChild(e, "msg_name", s_msg_name);
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_text_msg != null ) XmlUtil.appendCDataChild(e, "text_msg", s_text_msg);
		if( s_html_msg != null ) XmlUtil.appendCDataChild(e, "html_msg", s_html_msg);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_msg_id = XmlUtil.getChildTextValue(e, "msg_id");
		s_msg_name = XmlUtil.getChildCDataValue(e, "msg_name");
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_text_msg = XmlUtil.getChildCDataValue(e, "text_msg");
		s_html_msg = XmlUtil.getChildCDataValue(e, "html_msg");		
	}

	// === Other Methods ===
}



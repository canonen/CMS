package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class LinkRenaming extends BriteObject
{
	// === Properties ===

	public String s_link_id = null;
	public String s_link_name = null;
	public String s_cust_id = null;
	public String s_link_type_id = null;
	public String s_link_type_name = null;
	public String s_link_definition = null;
	private static Logger logger = Logger.getLogger(LinkRenaming.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public LinkRenaming()
	{
	}
	
	public LinkRenaming(String sLinkId) throws Exception
	{
		s_link_id = sLinkId;
		retrieve();
	}

	public LinkRenaming(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	l.link_id," +
		"	l.link_name," +
		"	l.cust_id," +
		"	t.type_id," +
		"	t.type_name," +
		"	l.link_definition" +
		" FROM ccnt_link_renaming l, ccnt_link_renaming_type t" +
		" WHERE (l.link_type_id = t.type_id) " +
		"	AND (l.link_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_link_id);

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
		s_link_id = rs.getString(1);
		b = rs.getBytes(2);	s_link_name = (b == null)?null:new String(b,"UTF-8");
		s_cust_id = rs.getString(3);
		s_link_type_id = rs.getString(4);
		b = rs.getBytes(5);	s_link_type_name = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(6);	s_link_definition = (b == null)?null:new String(b,"UTF-8");
	}
	
	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccnt_link_renaming_save" +
		"	@link_id=?," +
		"	@link_name=?," +
		"	@cust_id=?," +
		"	@link_type_id=?," +
		"	@link_definition=?";

	public String getSaveSql() { return m_sSaveSql; }


	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_link_id);
		if(s_link_name == null) pstmt.setString(2, s_link_name);
		else pstmt.setBytes(2, s_link_name.getBytes("UTF-8"));
		pstmt.setString(3, s_cust_id);
		pstmt.setString(4, s_link_type_id);
		if(s_link_definition == null) pstmt.setString(5, s_link_definition);
		else pstmt.setBytes(5, s_link_definition.getBytes("UTF-8"));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_link_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccnt_link_renaming" +
		" WHERE" +
		"	(link_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }


	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_link_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "link_renaming";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_link_id != null ) XmlUtil.appendTextChild(e, "link_id", s_link_id);
		if( s_link_name != null ) XmlUtil.appendCDataChild(e, "linke_name", s_link_name);
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_link_type_id != null ) XmlUtil.appendCDataChild(e, "link_type_id", s_link_type_id);
		if( s_link_type_name != null ) XmlUtil.appendCDataChild(e, "link_type_name", s_link_type_name);
		if( s_link_definition != null ) XmlUtil.appendTextChild(e, "link_definition", s_link_definition);
	}
		
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_link_id = XmlUtil.getChildTextValue(e, "link_id");
		s_link_name = XmlUtil.getChildCDataValue(e, "link_name");
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_link_type_id = XmlUtil.getChildCDataValue(e, "link_type_id");
		s_link_type_name = XmlUtil.getChildCDataValue(e, "link_type_name");
		s_link_definition = XmlUtil.getChildTextValue(e, "link_definition");
	}

	// === Other Methods ===
}



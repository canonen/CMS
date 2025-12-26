package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ContBody extends BriteObject
{
	// === Properties ===

	public String s_cont_id = null;
	public String s_html_part = null;
	public String s_text_part = null;
	public String s_aol_part = null;
	public String s_mjml_part = null;
	private static Logger logger = Logger.getLogger(ContBody.class.getName());

	// === Parents ===

	// Delete this part if you do not intend to use parents.
	// public Content m_Content = null;

	// === Children ===

	// Delete this part if you do not intend to use children.

	// === Constructors ===

	public ContBody()
	{
	}

	public ContBody(String sContId) throws Exception
	{
		s_cont_id = sContId;
		retrieve();
	}

	public ContBody(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
			" SELECT" +
					"	cont_id," +
					"	html_part," +
					"	text_part," +
					"	aol_part," +
					"   mjml_part" +
					" FROM ccnt_cont_body" +
					" WHERE" +
					"	(cont_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cont_id);

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

		ResultSetMetaData metaData = rs.getMetaData();
		int columnCount = metaData.getColumnCount();
		System.out.println("Dönen sütun sayısı: " + columnCount);


		byte[] b = null;
		s_cont_id = rs.getString(1);
		b = rs.getBytes(2);
		s_html_part = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(3);
		s_text_part = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(4);
		s_aol_part = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(5);
		s_mjml_part = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
			" EXECUTE usp_ccnt_cont_body_save" +
					"	@cont_id=?," +
					"	@html_part=?," +
					"	@text_part=?," +
					"	@aol_part=?," +
					"   @mjml_part=?";

	public String getSaveSql() { return m_sSaveSql; }

	// Methods save() and save(Connection conn) implemented in BriteObject
	// will call the following save(blah) methods like this:
	//
	//	saveParents(Connection conn);
	//	saveProps(PreparedStatement pstmt);
	//	saveChildren(Connection conn);

	// Save parents here or remove this method if you do not need it.
	// public int saveParents(Connection conn) throws Exception
	// {
	//	if(m_Parent!=null) m_Parent.save(conn);
	//
	//	//Fix ids after saving parent if needed
	//
	//	return 1;
	// }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		// char replacement
		s_html_part = CharReplacement.cleanChars(s_html_part);
		s_text_part = CharReplacement.cleanChars(s_text_part);
		s_aol_part  = CharReplacement.cleanChars(s_aol_part);
		s_mjml_part = CharReplacement.cleanChars(s_mjml_part);

		pstmt.setString(1, s_cont_id);
		if(s_html_part == null) pstmt.setNull(2, java.sql.Types.BINARY);
		else pstmt.setBytes(2, s_html_part.getBytes("UTF-8"));
		if(s_text_part == null) pstmt.setNull(3, java.sql.Types.BINARY);
		else pstmt.setBytes(3, s_text_part.getBytes("UTF-8"));
		if(s_aol_part == null) pstmt.setNull(4, java.sql.Types.BINARY);
		else pstmt.setBytes(4, s_aol_part.getBytes("UTF-8"));
		if(s_mjml_part == null) pstmt.setNull(5,java.sql.Types.BINARY);
		else pstmt.setBytes(5, s_mjml_part.getBytes("UTF-8"));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_cont_id = rs.getString(1);

			nReturnCode = 1;
		}
		rs.close();

		return nReturnCode;
	}

	// Save children here or remove this method if you do not need it.
	// public int saveChildren(Connection conn) throws Exception
	// {
	//
	//	//Fix ids before saving children if needed
	//
	//	if(m_Child!=null) m_Child.save(conn);
	//	return 1;
	// }

	// === DB Method delete()===

	public String m_sDeleteSql =
			" DELETE FROM ccnt_cont_body" +
					" WHERE" +
					"	(cont_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	// Methods delete() and delete(Connection conn) implemented in BriteObject
	// will call the following save(blah) methods like this:
	//
	//	deleteChildren(Connection conn);
	//	delete(PreparedStatement pstmt);
	//	deleteParents(Connection conn);

	// Delete children here or remove this method if you do not need it.
	// public int deleteChildren(Connection conn) throws Exception
	// {
	//	if(m_Child!=null) m_Child.delete(conn);
	//	return 1;
	// }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_cont_id);

		return pstmt.executeUpdate();
	}

	// Delete parents here or remove this method if you do not need it.
	// public int deleteParents(Connection conn) throws Exception
	// {
	//	if(m_Parent!=null) m_Parent.delete(conn);
	//	return 1;
	// }


	// === XML Methods ===

	public String m_sMainElementName = "cont_body";
	public String getMainElementName() { return m_sMainElementName; }

	// === To XML Methods ===

	public void appendPropsToXml(Element e)
	{
		if( s_cont_id != null ) XmlUtil.appendTextChild(e, "cont_id", s_cont_id);
		if( s_html_part != null ) XmlUtil.appendCDataChild(e, "html_part", s_html_part);
		if( s_text_part != null ) XmlUtil.appendCDataChild(e, "text_part", s_text_part);
		if( s_aol_part != null ) XmlUtil.appendCDataChild(e, "aol_part", s_aol_part);
		if( s_mjml_part !=null ) XmlUtil.appendCDataChild(e, "mjml_part", s_mjml_part);
	}

	// Kill these parent - child methods
	// if they are not supposed to be in use.

	public void appendParentsToXml(Element e)
	{
		// if (m_Parent != null) appendChild(e, m_Parent);
	}

	public void appendChildrenToXml(Element e)
	{
		// if (m_Child != null) appendChild(e, m_Child);
	}

	// === From XML Methods ===


	public void getPropsFromXml(Element e)
	{
		s_cont_id = XmlUtil.getChildTextValue(e, "cont_id");
		s_html_part = XmlUtil.getChildCDataValue(e, "html_part");
		s_text_part = XmlUtil.getChildCDataValue(e, "text_part");
		s_aol_part = XmlUtil.getChildCDataValue(e, "aol_part");
		s_mjml_part = XmlUtil.getChildCDataValue(e, "mjml_part");
	}

	// Kill these parent - child methods
	// if they are not supposed to be in use.

	public void getParentsFromXml(Element e) throws Exception
	{
		// Element eParent = XmlUtil.getChildByName(e, "parent_main_element_name");
		// if(eParent != null) m_Parent = new Parent(eParent);
	}

	public void getChildrenFromXml(Element e) throws Exception
	{
		// Element eChild = XmlUtil.getChildByName(e, "child_main_element_name");
		// if(eChild != null) m_Child = new Child(eChild);
	}

	// === Other Methods ===
}



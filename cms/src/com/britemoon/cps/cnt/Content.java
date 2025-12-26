package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.jtk.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class Content extends BriteObject
{
	// === Properties ===

	public String s_cont_id = null;
	public String s_cont_name = null;
	public String s_status_id = null;
	public String s_cust_id = null;
	public String s_origin_cont_id = null;
	public String s_charset_id = null;
	public String s_type_id = null;
	public String s_reusable_flag = null;
	public String s_cti_doc_id = null;
	private static Logger logger = Logger.getLogger(Content.class.getName());

	// === Parents ===

	// === Children ===

		// one to one children
		
	public ContBody m_ContBody = null;
	public ContSendParam m_ContSendParam = null;
	public ContEditInfo m_ContEditInfo = null;	
	
		// one to many children
		
	public ContParts m_ContParts = null;
	public Links m_Links = null;
	public ObjectCategories m_Categories = null;

	// === Constructors ===

	public Content()
	{
	}
	
	public Content(String sContId) throws Exception
	{
		s_cont_id = sContId;
		retrieve();
	}

	public Content(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	cont_id," +
		"	cont_name," +
		"	status_id," +
		"	cust_id," +
		"	origin_cont_id," +
		"	charset_id," +
		"	type_id," +
		"	reusable_flag," +
		"	cti_doc_id" +
		" FROM ccnt_content" +
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
		byte[] b = null;
		s_cont_id = rs.getString(1);
		b = rs.getBytes(2);
		s_cont_name = (b == null)?null:new String(b,"UTF-8");
		s_status_id = rs.getString(3);
		s_cust_id = rs.getString(4);
		s_origin_cont_id = rs.getString(5);
		s_charset_id = rs.getString(6);
		s_type_id = rs.getString(7);
		s_reusable_flag = rs.getString(8);
		s_cti_doc_id = rs.getString(9);
	}
	
	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccnt_content_save" +
		"	@cont_id=?," +
		"	@cont_name=?," +
		"	@status_id=?," +
		"	@cust_id=?," +
		"	@origin_cont_id=?," +
		"	@charset_id=?," +
		"	@type_id=?," +
		"	@reusable_flag=?," +
		"	@cti_doc_id=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveParents(Connection conn) throws Exception
	{
		// this has nothing in common with "parents" but
		// delete all old content parts		
		// (that is relations between this and child contents
		// but not child contents themselvs as they can participate other contents)
		// should be executed before saving new content parts
		// it could be done in saveChildren
		// but deleting them here will simplify cycle refernce check in content tree

		if (s_cont_id == null) return 1;
		
		if (m_ContParts != null)
		{
			ContParts cp = new ContParts();
			cp.s_parent_cont_id = s_cont_id;
			if(cp.retrieve(conn) > 0) cp.delete(conn);
		}

		if (m_Links != null)
		{
			Links links = new Links();
			links.s_cont_id = s_cont_id;
			if(links.retrieve(conn) > 0) links.delete(conn);
		}

		if (m_Categories != null)
		{
			ObjectCategories categories = new ObjectCategories();
			categories.s_cust_id = s_cust_id;
			categories.s_object_id = s_cont_id;
			categories.s_type_id = String.valueOf(ObjectType.CONTENT);
			if(categories.retrieve(conn) > 0) categories.delete(conn);
		}

		return 1;
	 }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cont_id);
		if(s_cont_name == null) pstmt.setString(2, s_cont_name);
		else pstmt.setBytes(2, s_cont_name.getBytes("UTF-8"));
		pstmt.setString(3, s_status_id);
		pstmt.setString(4, s_cust_id);
		pstmt.setString(5, s_origin_cont_id);
		pstmt.setString(6, s_charset_id);
		pstmt.setString(7, s_type_id);
		pstmt.setString(8, s_reusable_flag);
		pstmt.setString(9, s_cti_doc_id);

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

	 public int saveChildren(Connection conn) throws Exception
	 {
		if (m_ContBody!=null)
		{
		 	m_ContBody.s_cont_id = s_cont_id;
		  	m_ContBody.save(conn);
		}

		if (m_ContEditInfo!=null)
		{
		 	m_ContEditInfo.s_cont_id = s_cont_id;
		  	m_ContEditInfo.save(conn);
		}

		if (m_ContSendParam!=null)
		{
		 	m_ContSendParam.s_cont_id = s_cont_id;
		  	m_ContSendParam.save(conn);
		}

		if (m_ContParts!=null)
		{
		 	m_ContParts.s_parent_cont_id = s_cont_id;
		  	m_ContParts.save(conn);
		}

		if (m_Links!=null)
		{
			m_Links.s_cust_id = s_cust_id;		
		 	m_Links.s_cont_id = s_cont_id;
		  	m_Links.save(conn);
		}

		if (m_Categories!=null)
		{
			m_Categories.s_cust_id = s_cust_id;
			m_Categories.s_object_id = s_cont_id;
			m_Categories.s_type_id = String.valueOf(ObjectType.CONTENT);
			m_Categories.save(conn);
		}
		return 1;
	 }

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccnt_content" +
		" WHERE" +
		"	(cont_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteChildren(Connection conn) throws Exception
	{
		if (m_ContBody!=null) m_ContBody.delete(conn);
		if (m_ContEditInfo!=null) m_ContEditInfo.delete(conn);
		if (m_ContSendParam!=null) m_ContSendParam.delete(conn);
		if (m_ContParts!=null) m_ContParts.delete(conn);
		if (m_Links!=null) m_Links.delete(conn);		
		return 1;
	}

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_cont_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "content";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_cont_id != null ) XmlUtil.appendTextChild(e, "cont_id", s_cont_id);
		if( s_cont_name != null ) XmlUtil.appendCDataChild(e, "cont_name", s_cont_name);
		if( s_status_id != null ) XmlUtil.appendTextChild(e, "status_id", s_status_id);
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_origin_cont_id != null ) XmlUtil.appendTextChild(e, "origin_cont_id", s_origin_cont_id);
		if( s_charset_id != null ) XmlUtil.appendTextChild(e, "charset_id", s_charset_id);
		if( s_type_id != null ) XmlUtil.appendTextChild(e, "type_id", s_type_id);
		if( s_reusable_flag != null ) XmlUtil.appendTextChild(e, "reusable_flag", s_reusable_flag);
		if( s_cti_doc_id != null ) XmlUtil.appendTextChild(e, "cti_doc_id", s_cti_doc_id);
	}
	
	public void appendChildrenToXml(Element e)
	{
		if (m_ContBody != null) appendChild(e, m_ContBody);
		if (m_ContEditInfo != null) appendChild(e, m_ContEditInfo);
		if (m_ContSendParam != null) appendChild(e, m_ContSendParam);
		if (m_ContParts != null) appendChild(e, m_ContParts);
		if (m_Links != null) appendChild(e, m_Links);
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_cont_id = XmlUtil.getChildTextValue(e, "cont_id");
		s_cont_name = XmlUtil.getChildCDataValue(e, "cont_name");
		s_status_id = XmlUtil.getChildTextValue(e, "status_id");
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_origin_cont_id = XmlUtil.getChildTextValue(e, "origin_cont_id");
		s_charset_id = XmlUtil.getChildTextValue(e, "charset_id");
		s_type_id = XmlUtil.getChildTextValue(e, "type_id");
		s_reusable_flag = XmlUtil.getChildTextValue(e, "reusable_flag");
		s_cti_doc_id = XmlUtil.getChildTextValue(e, "cti_doc_id");
	}

	public void getChildrenFromXml(Element e) throws Exception
	{
		Element eContBody = XmlUtil.getChildByName(e, "cont_body");
		if(eContBody != null) m_ContBody = new ContBody(eContBody);

		Element eContEditInfo = XmlUtil.getChildByName(e, "cont_edit_info");
		if(eContEditInfo != null) m_ContEditInfo = new ContEditInfo(eContEditInfo);

		Element eContSendParam = XmlUtil.getChildByName(e, "cont_send_param");
		if(eContSendParam != null) m_ContSendParam = new ContSendParam(eContSendParam);

		Element eContParts = XmlUtil.getChildByName(e, "cont_parts");
		if(eContParts != null) m_ContParts = new ContParts(eContParts);

		Element eLinks = XmlUtil.getChildByName(e, "links");
		if(eLinks != null) m_Links = new Links(eLinks);
	}

	// === Other Methods ===
}



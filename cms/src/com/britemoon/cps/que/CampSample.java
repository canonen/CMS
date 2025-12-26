package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CampSample extends BriteObject
{
	// === Properties ===

	public String s_camp_id = null;
	public String s_sample_id = null;
	public String s_from_name = null;
	public String s_from_address = null;
	public String s_from_address_id = null;
	public String s_subject_html = null;
	public String s_subject_text = null;
	public String s_subject_aol = null;
	public String s_cont_id = null;
	public String s_send_date = null;
	public String s_test_list_id = null;
	public String s_reply_to = null;
	public String s_filter_id = null;
	public String s_priority = null;
	private static Logger logger = Logger.getLogger(CampSample.class.getName());

	// === Parents ===

	  // Delete this part if you do not intend to use parents.
	  // public CampSampleset m_CampSampleset = null;

	// === Children ===

	  // Delete this part if you do not intend to use children.

	// === Constructors ===

	public CampSample()
	{
	}
	
	public CampSample(String sCampId, String sSampleId) throws Exception
	{
		s_camp_id = sCampId;
		s_sample_id = sSampleId;
		retrieve();
	}

	public CampSample(Element e) throws Exception
	{
		fromXml(e);
	}

	// === For RCP only ===

	// override this method to return something reasonable
	// otherwise variable m_sOwnerId defined in BriteObject will be returned
	// public String getOwnerId() { return s_cust_id; }

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	camp_id," +
		"	sample_id," +
		"	from_name," +
		"	from_address," +
		"	from_address_id," +
		"	subject_html," +
		"	subject_text," +
		"	subject_aol," +
		"	cont_id," +
		"	send_date," +
		"	test_list_id," +
		"	reply_to," +
		"	filter_id," +
		"	priority" +
		" FROM cque_camp_sample" +
		" WHERE" +
		"	(camp_id=?) AND" +
		"	(sample_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_camp_id);
		pstmt.setString(2, s_sample_id);

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
		s_sample_id = rs.getString(2);
		b = rs.getBytes(3);
		s_from_name = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(4);
		s_from_address = (b == null)?null:new String(b,"UTF-8");
		s_from_address_id = rs.getString(5);
		b = rs.getBytes(6);
		s_subject_html = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(7);
		s_subject_text = (b == null)?null:new String(b,"UTF-8");
		b = rs.getBytes(8);
		s_subject_aol = (b == null)?null:new String(b,"UTF-8");
		s_cont_id = rs.getString(9);
		s_send_date = rs.getString(10);
		s_test_list_id = rs.getString(11);
		s_reply_to = rs.getString(12);
		s_filter_id = rs.getString(13);
		s_priority = rs.getString(14);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cque_camp_sample_save" +
		"	@camp_id=?," +
		"	@sample_id=?," +
		"	@from_name=?," +
		"	@from_address=?," +
		"	@from_address_id=?," +
		"	@subject_html=?," +
		"	@subject_text=?," +
		"	@subject_aol=?," +
		"	@cont_id=?," +
		"	@send_date=?," +
		"	@test_list_id=?," +
		"	@reply_to=?," +
		"	@filter_id=?," +
		"	@priority=?";

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
		s_subject_html = CharReplacement.cleanChars(s_subject_html);
		s_subject_text = CharReplacement.cleanChars(s_subject_text);
		s_subject_aol  = CharReplacement.cleanChars(s_subject_aol);

		pstmt.setString(1, s_camp_id);
		pstmt.setString(2, s_sample_id);
		if(s_from_name == null) pstmt.setString(3, s_from_name);
		else pstmt.setBytes(3, s_from_name.getBytes("UTF-8"));
		if(s_from_address == null) pstmt.setString(4, s_from_address);
		else pstmt.setBytes(4, s_from_address.getBytes("UTF-8"));
		pstmt.setString(5, s_from_address_id);
		if(s_subject_html == null) pstmt.setString(6, s_subject_html);
		else pstmt.setBytes(6, s_subject_html.getBytes("UTF-8"));
		if(s_subject_text == null) pstmt.setString(7, s_subject_text);
		else pstmt.setBytes(7, s_subject_text.getBytes("UTF-8"));
		if(s_subject_aol == null) pstmt.setString(8, s_subject_aol);
		else pstmt.setBytes(8, s_subject_aol.getBytes("UTF-8"));
		pstmt.setString(9, s_cont_id);
		pstmt.setString(10, s_send_date);
		pstmt.setString(11, s_test_list_id);
		pstmt.setString(12, s_reply_to);
		pstmt.setString(13, s_filter_id);
		pstmt.setString(14, s_priority);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_camp_id = rs.getString(1);
			s_sample_id = rs.getString(2);

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
		" DELETE FROM cque_camp_sample" +
		" WHERE" +
		"	(camp_id=?) AND" +
		"	(sample_id=?)";

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
		pstmt.setString(1, s_camp_id);
		pstmt.setString(2, s_sample_id);

		return pstmt.executeUpdate();
	}

	// Delete parents here or remove this method if you do not need it.
	// public int deleteParents(Connection conn) throws Exception
	// {
	//	if(m_Parent!=null) m_Parent.delete(conn);
	//	return 1;
	// }

	
	// === XML Methods ===

	public String m_sMainElementName = "camp_sample";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_camp_id != null ) XmlUtil.appendTextChild(e, "camp_id", s_camp_id);
		if( s_sample_id != null ) XmlUtil.appendTextChild(e, "sample_id", s_sample_id);
		if( s_from_name != null ) XmlUtil.appendCDataChild(e, "from_name", s_from_name);
		if( s_from_address != null ) XmlUtil.appendCDataChild(e, "from_address", s_from_address);
		if( s_from_address_id != null ) XmlUtil.appendTextChild(e, "from_address_id", s_from_address_id);
		if( s_subject_html != null ) XmlUtil.appendCDataChild(e, "subject_html", s_subject_html);
		if( s_subject_text != null ) XmlUtil.appendCDataChild(e, "subject_text", s_subject_text);
		if( s_subject_aol != null ) XmlUtil.appendCDataChild(e, "subject_aol", s_subject_aol);
		if( s_cont_id != null ) XmlUtil.appendTextChild(e, "cont_id", s_cont_id);
		if( s_send_date != null ) XmlUtil.appendTextChild(e, "send_date", s_send_date);
		if( s_test_list_id != null ) XmlUtil.appendTextChild(e, "test_list_id", s_test_list_id);
		if( s_reply_to != null ) XmlUtil.appendTextChild(e, "reply_to", s_reply_to);
		if( s_filter_id != null ) XmlUtil.appendTextChild(e, "filter_id", s_filter_id);
		if( s_priority != null ) XmlUtil.appendTextChild(e, "priority", s_priority);
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
		s_camp_id = XmlUtil.getChildTextValue(e, "camp_id");
		s_sample_id = XmlUtil.getChildTextValue(e, "sample_id");
		s_from_name = XmlUtil.getChildCDataValue(e, "from_name");
		s_from_address = XmlUtil.getChildCDataValue(e, "from_address");
		s_from_address_id = XmlUtil.getChildTextValue(e, "from_address_id");
		s_subject_html = XmlUtil.getChildCDataValue(e, "subject_html");
		s_subject_text = XmlUtil.getChildCDataValue(e, "subject_text");
		s_subject_aol = XmlUtil.getChildCDataValue(e, "subject_aol");
		s_cont_id = XmlUtil.getChildTextValue(e, "cont_id");
		s_send_date = XmlUtil.getChildTextValue(e, "send_date");
		s_test_list_id = XmlUtil.getChildTextValue(e, "test_list_id");
		s_reply_to = XmlUtil.getChildTextValue(e, "reply_to");
		s_filter_id = XmlUtil.getChildTextValue(e, "filter_id");
		s_priority = XmlUtil.getChildTextValue(e, "priority");
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

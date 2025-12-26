package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CampSampleset extends BriteObject
{
	// === Properties ===

	public String s_camp_id = null;
	public String s_camp_qty = null;
	public String s_final_camp_flag = null;
	public String s_from_name_flag = null;
	public String s_from_address_flag = null;
	public String s_subject_flag = null;
	public String s_cont_flag = null;
	public String s_send_date_flag = null;
	public String s_recip_qty = null;
	public String s_recip_percentage = null;
	public String s_reply_to_flag = null;
	public String s_filter_flag = null;
	private static Logger logger = Logger.getLogger(CampSampleset.class.getName());

	// === Parents ===

	  // Delete this part if you do not intend to use parents.
	  // public Campaign m_Campaign = null;

	// === Children ===

	  // Delete this part if you do not intend to use children.
	  // public CampSample(s) m_CampSample(s) = null;

	// === Constructors ===

	public CampSampleset()
	{
	}
	
	public CampSampleset(String sCampId) throws Exception
	{
		s_camp_id = sCampId;
		retrieve();
	}

	public CampSampleset(Element e) throws Exception
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
		"	camp_qty," +
		"	final_camp_flag," +
		"	from_name_flag," +
		"	from_address_flag," +
		"	subject_flag," +
		"	cont_flag," +
		"	send_date_flag," +
		"	recip_qty," +
		"	recip_percentage," +
		"	reply_to_flag," +
		"	filter_flag" +
		" FROM cque_camp_sampleset" +
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
		s_camp_qty = rs.getString(2);
		s_final_camp_flag = rs.getString(3);
		s_from_name_flag = rs.getString(4);
		s_from_address_flag = rs.getString(5);
		s_subject_flag = rs.getString(6);
		s_cont_flag = rs.getString(7);
		s_send_date_flag = rs.getString(8);
		s_recip_qty = rs.getString(9);
		s_recip_percentage = rs.getString(10);
		s_reply_to_flag = rs.getString(11);
		s_filter_flag = rs.getString(12);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cque_camp_sampleset_save" +
		"	@camp_id=?," +
		"	@camp_qty=?," +
		"	@final_camp_flag=?," +
		"	@from_name_flag=?," +
		"	@from_address_flag=?," +
		"	@subject_flag=?," +
		"	@cont_flag=?," +
		"	@send_date_flag=?," +
		"	@recip_qty=?," +
		"	@recip_percentage=?," +
		"	@reply_to_flag=?," +
		"	@filter_flag=?";


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

		pstmt.setString(1, s_camp_id);
		pstmt.setString(2, s_camp_qty);
		pstmt.setString(3, s_final_camp_flag);
		pstmt.setString(4, s_from_name_flag);
		pstmt.setString(5, s_from_address_flag);
		pstmt.setString(6, s_subject_flag);
		pstmt.setString(7, s_cont_flag);
		pstmt.setString(8, s_send_date_flag);
		pstmt.setString(9, s_recip_qty);
		pstmt.setString(10, s_recip_percentage);
		pstmt.setString(11, s_reply_to_flag);
		pstmt.setString(12, s_filter_flag);

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
		" DELETE FROM cque_camp_sampleset" +
		" WHERE" +
		"	(camp_id=?)";

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

		return pstmt.executeUpdate();
	}

	// Delete parents here or remove this method if you do not need it.
	// public int deleteParents(Connection conn) throws Exception
	// {
	//	if(m_Parent!=null) m_Parent.delete(conn);
	//	return 1;
	// }

	
	// === XML Methods ===

	public String m_sMainElementName = "camp_sampleset";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_camp_id != null ) XmlUtil.appendTextChild(e, "camp_id", s_camp_id);
		if( s_camp_qty != null ) XmlUtil.appendTextChild(e, "camp_qty", s_camp_qty);
		if( s_final_camp_flag != null ) XmlUtil.appendTextChild(e, "final_camp_flag", s_final_camp_flag);
		if( s_from_name_flag != null ) XmlUtil.appendTextChild(e, "from_name_flag", s_from_name_flag);
		if( s_from_address_flag != null ) XmlUtil.appendTextChild(e, "from_address_flag", s_from_address_flag);
		if( s_subject_flag != null ) XmlUtil.appendTextChild(e, "subject_flag", s_subject_flag);
		if( s_cont_flag != null ) XmlUtil.appendTextChild(e, "cont_flag", s_cont_flag);
		if( s_send_date_flag != null ) XmlUtil.appendTextChild(e, "send_date_flag", s_send_date_flag);
		if( s_recip_qty != null ) XmlUtil.appendTextChild(e, "recip_qty", s_recip_qty);
		if( s_recip_percentage != null ) XmlUtil.appendTextChild(e, "recip_percentage", s_recip_percentage);
		if( s_reply_to_flag != null ) XmlUtil.appendTextChild(e, "reply_to_flag", s_reply_to_flag);
		if( s_filter_flag != null ) XmlUtil.appendTextChild(e, "filter_flag", s_filter_flag);
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
		s_camp_qty = XmlUtil.getChildTextValue(e, "camp_qty");
		s_final_camp_flag = XmlUtil.getChildTextValue(e, "final_camp_flag");
		s_from_name_flag = XmlUtil.getChildTextValue(e, "from_name_flag");
		s_from_address_flag = XmlUtil.getChildTextValue(e, "from_address_flag");
		s_subject_flag = XmlUtil.getChildTextValue(e, "subject_flag");
		s_cont_flag = XmlUtil.getChildTextValue(e, "cont_flag");
		s_send_date_flag = XmlUtil.getChildTextValue(e, "send_date_flag");
		s_recip_qty = XmlUtil.getChildTextValue(e, "recip_qty");
		s_recip_percentage = XmlUtil.getChildTextValue(e, "recip_percentage");
		s_reply_to_flag = XmlUtil.getChildTextValue(e, "reply_to_flag");
		s_filter_flag = XmlUtil.getChildTextValue(e, "filter_flag");
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

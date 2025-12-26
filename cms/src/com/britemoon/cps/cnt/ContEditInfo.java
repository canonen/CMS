package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ContEditInfo extends BriteObject
{
	// === Properties ===

	public String s_cont_id = null;
	public String s_wizard_id = null;
	public String s_creator_id = null;
	public String s_create_date = null;
	public String s_modify_date = null;
	public String s_modifier_id = null;
	private static Logger logger = Logger.getLogger(ContEditInfo.class.getName());

	// === Parents ===

	  // Delete this part if you do not intend to use parents.
	  // public Content m_Content = null;

	// === Children ===

	  // Delete this part if you do not intend to use children.

	// === Constructors ===

	public ContEditInfo()
	{
	}
	
	public ContEditInfo(String sContId) throws Exception
	{
		s_cont_id = sContId;
		retrieve();
	}

	public ContEditInfo(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	cont_id," +
		"	wizard_id," +
		"	creator_id," +
		"	CONVERT(varchar(255),create_date,100)," +
		"	CONVERT(varchar(255),modify_date,100)," +
		"	modifier_id" +
		" FROM ccnt_cont_edit_info" +
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
		s_wizard_id = rs.getString(2);
		s_creator_id = rs.getString(3);
		s_create_date = rs.getString(4);
		s_modify_date = rs.getString(5);
		s_modifier_id = rs.getString(6);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccnt_cont_edit_info_save" +
		"	@cont_id=?," +
		"	@wizard_id=?," +
		"	@creator_id=?," +
		"	@create_date=?," +
		"	@modify_date=?," +
		"	@modifier_id=?";

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

		pstmt.setString(1, s_cont_id);
		pstmt.setString(2, s_wizard_id);
		pstmt.setString(3, s_creator_id);
		pstmt.setString(4, s_create_date);
		pstmt.setString(5, s_modify_date);
		pstmt.setString(6, s_modifier_id);

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
		" DELETE FROM ccnt_cont_edit_info" +
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

	public String m_sMainElementName = "cont_edit_info";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_cont_id != null ) XmlUtil.appendTextChild(e, "cont_id", s_cont_id);
		if( s_wizard_id != null ) XmlUtil.appendTextChild(e, "wizard_id", s_wizard_id);
		if( s_creator_id != null ) XmlUtil.appendTextChild(e, "creator_id", s_creator_id);
		if( s_create_date != null ) XmlUtil.appendTextChild(e, "create_date", s_create_date);
		if( s_modify_date != null ) XmlUtil.appendTextChild(e, "modify_date", s_modify_date);
		if( s_modifier_id != null ) XmlUtil.appendTextChild(e, "modifier_id", s_modifier_id);
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
		s_wizard_id = XmlUtil.getChildTextValue(e, "wizard_id");
		s_creator_id = XmlUtil.getChildTextValue(e, "creator_id");
		s_create_date = XmlUtil.getChildTextValue(e, "create_date");
		s_modify_date = XmlUtil.getChildTextValue(e, "modify_date");
		s_modifier_id = XmlUtil.getChildTextValue(e, "modifier_id");
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



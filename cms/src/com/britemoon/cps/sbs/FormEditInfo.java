package com.britemoon.cps.sbs;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class FormEditInfo extends BriteObject
{
	// === Properties ===

	public String s_form_id = null;
	public String s_create_date = null;
	public String s_modify_date = null;
	public String s_creator_id = null;
	public String s_modifier_id = null;
	private static Logger logger = Logger.getLogger(FormEditInfo.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public FormEditInfo()
	{
	}
	
	public FormEditInfo(String sFormId) throws Exception
	{
		s_form_id = sFormId;
		retrieve();
	}

	public FormEditInfo(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	form_id," +
		"	create_date," +
		"	modify_date," +
		"	creator_id," +
		"	modifier_id" +
		" FROM csbs_form_edit_info" +
		" WHERE" +
		"	(form_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_form_id);

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
		s_form_id = rs.getString(1);
		s_create_date = rs.getString(2);
		s_modify_date = rs.getString(3);
		s_creator_id = rs.getString(4);
		s_modifier_id = rs.getString(5);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_csbs_form_edit_info_save" +
		"	@form_id=?," +
		"	@creator_id=?," +		
		"	@create_date=?," +
		"	@modifier_id=?," +		
		"	@modify_date=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_form_id);
		pstmt.setString(2, s_creator_id);		
		pstmt.setString(3, s_create_date);
		pstmt.setString(4, s_modifier_id);		
		pstmt.setString(5, s_modify_date);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_form_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM csbs_form_edit_info" +
		" WHERE" +
		"	(form_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_form_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "form_edit_info";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_form_id != null ) XmlUtil.appendTextChild(e, "form_id", s_form_id);
		if( s_create_date != null ) XmlUtil.appendTextChild(e, "create_date", s_create_date);
		if( s_modify_date != null ) XmlUtil.appendTextChild(e, "modify_date", s_modify_date);
		if( s_creator_id != null ) XmlUtil.appendTextChild(e, "creator_id", s_creator_id);
		if( s_modifier_id != null ) XmlUtil.appendTextChild(e, "modifier_id", s_modifier_id);
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_form_id = XmlUtil.getChildTextValue(e, "form_id");
		s_create_date = XmlUtil.getChildTextValue(e, "create_date");
		s_modify_date = XmlUtil.getChildTextValue(e, "modify_date");
		s_creator_id = XmlUtil.getChildTextValue(e, "creator_id");
		s_modifier_id = XmlUtil.getChildTextValue(e, "modifier_id");
	}

	// === Other Methods ===
}



package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class LinkedCamp extends BriteObject
{
	// === Properties ===

	public String s_camp_id = null;
	public String s_linked_camp_id = null;
	public String s_form_id = null;
	private static Logger logger = Logger.getLogger(LinkedCamp.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public LinkedCamp()
	{
	}
	
	public LinkedCamp(String sCampId) throws Exception
	{
		s_camp_id = sCampId;
		retrieve();
	}

	public LinkedCamp(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	camp_id," +
		"	linked_camp_id," +
		"	form_id" +
		" FROM cque_linked_camp" +
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
		s_linked_camp_id = rs.getString(2);
		s_form_id = rs.getString(3);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cque_linked_camp_save" +
		"	@camp_id=?," +
		"	@linked_camp_id=?," +
		"	@form_id=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_camp_id);
		pstmt.setString(2, s_linked_camp_id);
		pstmt.setString(3, s_form_id);

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
		" DELETE FROM cque_linked_camp" +
		" WHERE" +
		"	(camp_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_camp_id);

		return pstmt.executeUpdate();
	}
	
	// === XML Methods ===

	public String m_sMainElementName = "linked_camp";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_camp_id != null ) XmlUtil.appendTextChild(e, "camp_id", s_camp_id);
		if( s_linked_camp_id != null ) XmlUtil.appendTextChild(e, "linked_camp_id", s_linked_camp_id);
		if( s_form_id != null ) XmlUtil.appendTextChild(e, "form_id", s_form_id);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_camp_id = XmlUtil.getChildTextValue(e, "camp_id");
		s_linked_camp_id = XmlUtil.getChildTextValue(e, "linked_camp_id");
		s_form_id = XmlUtil.getChildTextValue(e, "form_id");
	}

	// === Other Methods ===
}



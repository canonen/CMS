package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;

import com.britemoon.cps.XmlUtil;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class EmailListItem extends BriteObject
{
	// === Properties ===

	public String s_item_id = null;
	public String s_email_type_id = null;
	public String s_list_id = null;
	public String s_email = null;
	private static Logger logger = Logger.getLogger(EmailListItem.class.getName());

	// === Parents ===

	// === Children ===

	// === Constructors ===

	public EmailListItem()
	{
	}
	
	public EmailListItem(String sItemId) throws Exception
	{
		s_item_id = sItemId;
		retrieve();
	}

	public EmailListItem(Element e) throws Exception
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
		"	list_id," +
		"	email_type_id," +
		"	item_id," +
		"	email" +
		" FROM sadm_email_list_item" +
		" WHERE" +
		"	(list_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;
		pstmt.setString(1, s_list_id);

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
		s_list_id = rs.getString(1);
		s_email_type_id = rs.getString(2);
		s_item_id = rs.getString(3);
		b = rs.getBytes(4);
		s_email = (b == null)?null:new String(b,"UTF-8");
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_sadm_email_list_item_save" +
		"	@item_id=?," +
		"	@email_type_id=?," +
		"	@list_id=?," +
		"	@email=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_item_id);
		pstmt.setString(2, s_email_type_id);
		pstmt.setString(3, s_list_id);
		if(s_email == null) pstmt.setString(4, s_email);
		else pstmt.setBytes(4, s_email.getBytes("UTF-8"));

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_item_id = rs.getString(1);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM sadm_email_list_item" +
		" WHERE" +
		"	(item_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_item_id);
		return pstmt.executeUpdate();
	}
	
	// === XML Methods ===

	public String m_sMainElementName = "email_list_item";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
            // Because we are synching Pivotal Veracity Seed list from ADM to CPS, and the master list id in ADM is not going to be 
            // the same as the customer's email seed list, we need to null out the list id in the xml.
		if( s_list_id != null ) XmlUtil.appendTextChild(e, "list_id", s_list_id);
		if( s_email_type_id != null ) XmlUtil.appendTextChild(e, "email_type_id", s_email_type_id);
		if( s_item_id != null ) XmlUtil.appendTextChild(e, "item_id", s_item_id );
		if( s_email != null ) XmlUtil.appendCDataChild(e, "email", s_email);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_list_id = XmlUtil.getChildTextValue(e, "list_id");
		s_email_type_id = XmlUtil.getChildTextValue(e, "email_type_id");
		s_item_id = XmlUtil.getChildTextValue(e, "item_id");
		s_email = XmlUtil.getChildCDataValue(e, "email");
	}

	// === Other Methods ===
}



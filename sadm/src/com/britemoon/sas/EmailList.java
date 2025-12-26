package com.britemoon.sas;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;

import com.britemoon.cps.EmailListStatus;
import com.britemoon.cps.XmlUtil;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class EmailList extends BriteObject
{
	// === Properties ===

	public String s_list_id = null;
	public String s_cust_id = null;
	public String s_list_name = null;
	public String s_type_id = null;
	public String s_status_id = null;
	private static Logger logger = Logger.getLogger(EmailList.class.getName()); 

	// === Parents ===

	// === Children ===

	public EmailListItems m_EmailListItems = null;
        public EmailListPVInfo m_EmailListPVInfo = null;

	// === Constructors ===

	public EmailList()
	{
	}
	
	public EmailList(String sListId) throws Exception
	{
		s_list_id = sListId;
		retrieve();
	}

	public EmailList(Element e) throws Exception
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
		"	cust_id," +
		"	list_name," +
		"	type_id," +
		"	status_id" +
		" FROM sadm_email_list" +
		" WHERE" +
		"	(type_id=?) AND (cust_id=?)";

	public String getRetrieveSql() { 
            return m_sRetrieveSql; 
        }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_type_id);
                pstmt.setString(2, s_cust_id);

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
		s_cust_id = rs.getString(2);
                b = rs.getBytes(3);
		s_list_name = (b == null)?null:new String(b,"UTF-8");
		s_type_id = rs.getString(4);
		s_status_id = rs.getString(5);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_sadm_email_list_save" +
		"	@list_id=?," +
		"	@cust_id=?," +
		"	@list_name=?," +
		"	@type_id=?," +
		"	@status_id=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveParents(Connection conn) throws Exception
	{
		// === === ===
		
		if (s_list_id == null) return 1;

		if (m_EmailListItems!=null)
		{
			String sSql = "DELETE sadm_email_list_item WHERE list_id = " + s_list_id;
			BriteUpdate.executeUpdate(sSql,conn);
		}
                
                if (m_EmailListPVInfo != null) {
                    String sSql = "DELETE sadm_email_list_pv_info WHERE list_id = " + s_list_id;
                    BriteUpdate.executeUpdate(sSql, conn);
                }

		return 1;
	}

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_list_id);
		pstmt.setString(2, s_cust_id);
		if(s_list_name == null) pstmt.setString(3, s_list_name);
		else pstmt.setBytes(3, s_list_name.getBytes("UTF-8"));
		pstmt.setString(4, s_type_id);
		pstmt.setString(5, s_status_id);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_list_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	public int saveChildren(Connection conn) throws Exception
	{
		if (m_EmailListItems!=null)
		{
			m_EmailListItems.s_list_id = s_list_id;
			m_EmailListItems.save(conn);
		}
                
                if (m_EmailListPVInfo != null){
                    m_EmailListPVInfo.s_list_id = s_list_id;
                    m_EmailListPVInfo.save(conn);
                }
		return 1;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" UPDATE sadm_email_list SET status_id = " + EmailListStatus.DELETED +
		" WHERE" +
		"	(list_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteChildren(Connection conn) throws Exception
	{
		if(m_EmailListItems!=null) m_EmailListItems.delete(conn);
                if(m_EmailListPVInfo != null) m_EmailListPVInfo.delete(conn);
		return 1;
	}

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_list_id);
		return pstmt.executeUpdate();
	}

	// === XML Methods ===

	public String m_sMainElementName = "email_list";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
            // Because we are synching Pivotal Veracity Seed list from ADM to CPS, and the master list id in ADM is not going to be 
            // the same as the customer's email seed list, we need to null out the list id in the xml.
		if( s_list_id != null ) XmlUtil.appendTextChild(e, "list_id",s_list_id);
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_list_name != null ) XmlUtil.appendCDataChild(e, "list_name", s_list_name);
		if( s_type_id != null ) XmlUtil.appendTextChild(e, "type_id", s_type_id);
		if( s_status_id != null ) XmlUtil.appendTextChild(e, "status_id", s_status_id);
	}

	public void appendChildrenToXml(Element e)
	{
		if (m_EmailListItems != null) appendChild(e, m_EmailListItems);
                if (m_EmailListPVInfo != null) appendChild(e, m_EmailListPVInfo);
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_list_id = XmlUtil.getChildTextValue(e, "list_id");
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_list_name = XmlUtil.getChildCDataValue(e, "list_name");
		s_type_id = XmlUtil.getChildTextValue(e, "type_id");
		s_status_id = XmlUtil.getChildTextValue(e, "status_id");
	}

	public void getChildrenFromXml(Element e) throws Exception
	{
		Element eEmailListItems = XmlUtil.getChildByName(e, "email_list_items");
		if(eEmailListItems != null) m_EmailListItems = new EmailListItems(eEmailListItems);
                Element eEmailListPVInfo = XmlUtil.getChildByName(e, "email_list_pv_info");
                if(eEmailListPVInfo != null) m_EmailListPVInfo = new EmailListPVInfo(eEmailListPVInfo);  
	}

	// === Other Methods ===
}

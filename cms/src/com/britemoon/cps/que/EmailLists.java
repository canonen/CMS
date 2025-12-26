package com.britemoon.cps.que;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;
public class EmailLists extends BriteList
        
{
	//log4j implementation
	private static Logger logger = Logger.getLogger(EmailLists.class.getName());
	// === Constructors ===
	public EmailLists()
	{
	}

	public EmailLists(Element e) throws Exception
	{
		fromXml(e);
	}
        
        // === Attributes of Class
        
        public String s_list_id = null;
	public String s_cust_id = null;
	public String s_list_name = null;
	public String s_type_id = null;
	public String s_status_id = null;

	// === DB Methods ===

	// === Retrieve, delete & save params ===
        // init sql variables - overridden from AbstractBriteList
         {
            m_bUseParamsForRetrieve	= true;

            m_sRetrieveSql = null;

            m_sSelectClause = 
                            " SELECT" +
                    "	list_id," +
                    "	cust_id," +
                    "	list_name," +
                    "	type_id," +
                    "	status_id";

            m_sFromClause = " FROM cque_email_list ";
            m_sWhereClause = null;
            m_sOrderByClause = " ORDER BY  list_id ";
         }

//        public String getRetrieveSql() { 
//            //return m_sRetrieveSql; 
//            return m_sSelectClause;
//        }
		

        public String buildWhereClause() {
            String sWhereSql = "WHERE ";
            boolean bAddAnd = false;
                                  
           if(s_list_id != null)   { sWhereSql += " (list_id IN (?)) "; bAddAnd = true; }
           if(s_cust_id != null)   { sWhereSql += (((bAddAnd)?" AND ":"") + " (cust_id IN (?)) "); bAddAnd = true; } 
           if(s_list_name != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (list_name IN (?)) "); bAddAnd = true; }
           if(s_type_id != null)   { sWhereSql += (((bAddAnd)?" AND ":"") + " (type_id IN (?)) "); bAddAnd = true; }
           if(s_status_id != null) { sWhereSql += (((bAddAnd)?" AND ":"") + " (status_id IN (?)) "); bAddAnd = true; } 
           return sWhereSql;
        }
	
	public void setParams(PreparedStatement pstmt) throws Exception
	{
            
		int i = 1;
		if(s_cust_id != null) { pstmt.setString(i, s_cust_id); i++; }
                if(s_list_id != null) { pstmt.setString(i, s_list_id); i++; }
		if(s_list_name != null) { pstmt.setBytes(i, s_list_name.getBytes("UTF-8")); i++; }
		if(s_type_id != null) { pstmt.setString(i, s_type_id); i++; }
		if(s_status_id != null) { pstmt.setString(i, s_status_id); i++; }
 
	}
        
        private void resetParams()
	{
		s_list_id = null;
		s_cust_id = null;
		s_list_name = null;
		s_type_id = null;
		s_status_id = null;
        }

	public void fixIds()
	{
		EmailList emailList = null;
		for (Enumeration e = v.elements() ; e.hasMoreElements() ;)
		{
			emailList = (EmailList)e.nextElement();
			if(s_list_id != null) emailList.s_list_id = s_list_id;
			if(s_cust_id != null) emailList.s_cust_id = s_cust_id;
		}
	}

	// === === ===

	public int getListFromResultSet(ResultSet rs) throws Exception
	{
		int nReturnCode = 0;
		EmailList emailList = null;
		while (rs.next())
		{
			emailList = new EmailList();
			emailList.getPropsFromResultSetRow(rs);
			add(emailList);
			nReturnCode++;
		}
		return nReturnCode;
	}

	// === XML Methods ===

	public String m_sMainElementName = "email_lists";
	public String getMainElementName() { return m_sMainElementName; }
		
	public String m_sSubElementName = "email_list";
	public String getSubElementName() { return m_sSubElementName; }

	// === XML stuff ===

	public int getPartsFromXml(NodeList nl) throws Exception
	{
		int iLength = nl.getLength();
		EmailList emailList = null;
		for(int i = 0; i < iLength; i++)
		{
			emailList = new EmailList ((Element)nl.item(i));
			v.add(emailList);
		}
		return iLength;
	}

	// === Other Methods ===
}



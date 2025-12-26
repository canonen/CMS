package com.britemoon.cps.adm;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class CustModInst extends BriteObject
{
	// === Properties ===

	public String s_cust_id = null;
	public String s_mod_inst_id = null;
	private static Logger logger = Logger.getLogger(CustModInst.class.getName());

	// === Parents ===

	public ModInst m_ModInst = null;

	// === Children ===

	public CustModInstServices m_CustModInstServices = null;
	public VanityDomains m_VanityDomains = null;

	// === Constructors ===

	public CustModInst()
	{
	}
	
	public CustModInst(String sCustId, String sModInstId) throws Exception
	{
		s_cust_id = sCustId;
		s_mod_inst_id = sModInstId;
		retrieve();
	}

	public CustModInst(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	cust_id," +
		"	mod_inst_id" +
		" FROM cadm_cust_mod_inst" +
		" WHERE" +
		"	(cust_id=?) AND" +
		"	(mod_inst_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_mod_inst_id);

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
		s_cust_id = rs.getString(1);
		s_mod_inst_id = rs.getString(2);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cadm_cust_mod_inst_save" +
		"	@cust_id=?," +
		"	@mod_inst_id=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveParents(Connection conn) throws Exception
	{
		if (m_ModInst!=null)
		{
			m_ModInst.save(conn);
			s_mod_inst_id = m_ModInst.s_mod_inst_id;
		}
		return 1;
	}

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_mod_inst_id);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_cust_id = rs.getString(1);
			s_mod_inst_id = rs.getString(2);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	public int saveChildren(Connection conn) throws Exception
	{
		if (m_CustModInstServices!=null)
		{
			m_CustModInstServices.s_cust_id = s_cust_id;
			m_CustModInstServices.s_mod_inst_id = s_mod_inst_id;
			m_CustModInstServices.save(conn);
		}
		if (m_VanityDomains!=null)
		{
			m_VanityDomains.s_cust_id = s_cust_id;
			m_VanityDomains.s_mod_inst_id = s_mod_inst_id;
			m_VanityDomains.save(conn);
		}
		return 1;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cadm_cust_mod_inst" +
		" WHERE" +
		"	(cust_id=?) AND" +
		"	(mod_inst_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteChildren(Connection conn) throws Exception
	{
		if(m_CustModInstServices!=null) m_CustModInstServices.delete(conn);
		if(m_VanityDomains!=null) m_VanityDomains.delete(conn);		
		return 1;
	}

	// === Children ===

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_cust_id);
		pstmt.setString(2, s_mod_inst_id);
		return pstmt.executeUpdate();
	}

	public int deleteParents(Connection conn) throws Exception
	{
		if(m_ModInst!=null) m_ModInst.delete(conn);
		return 1;
	}
	
	// === XML Methods ===

	public String m_sMainElementName = "cust_mod_inst";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_mod_inst_id != null ) XmlUtil.appendTextChild(e, "mod_inst_id", s_mod_inst_id);
	}

	public void appendParentsToXml(Element e)
	{
		if (m_ModInst != null) appendChild(e, m_ModInst);
	}
	
	public void appendChildrenToXml(Element e)
	{
		if (m_CustModInstServices != null) appendChild(e, m_CustModInstServices);
		if (m_VanityDomains != null) appendChild(e, m_VanityDomains);		
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_mod_inst_id = XmlUtil.getChildTextValue(e, "mod_inst_id");
	}

	public void getParentsFromXml(Element e) throws Exception
	{
		Element eModInst = XmlUtil.getChildByName(e, "mod_inst");
		if(eModInst != null) m_ModInst = new ModInst(eModInst);
	}
	
	public void getChildrenFromXml(Element e) throws Exception
	{
		Element eCustModInstServices = XmlUtil.getChildByName(e, "cust_mod_inst_services");
		if(eCustModInstServices != null) m_CustModInstServices = new CustModInstServices(eCustModInstServices);

		Element eVanityDomains = XmlUtil.getChildByName(e, "vanity_domains");
		if(eVanityDomains != null) m_VanityDomains = new VanityDomains(eVanityDomains);
	}

	// === Other Methods ===
}



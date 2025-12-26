package com.britemoon.cps.adm;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ModInst extends BriteObject
{
	// === Properties ===

	public String s_mod_inst_id = null;
	public String s_machine_id = null;
	public String s_mod_id = null;
	public String s_version = null;
	private static Logger logger = Logger.getLogger(ModInst.class.getName());

	// === Parents ===

	public Machine m_Machine = null;

	// === Children ===

	public ModInstServices m_ModInstServices = null;
	
	// === Constructors ===

	public ModInst()
	{
	}
	
	public ModInst(String sModInstId) throws Exception
	{
		s_mod_inst_id = sModInstId;
		retrieve();
	}

	public ModInst(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	mod_inst_id," +
		"	machine_id," +
		"	mod_id," +
		"	version" +
		" FROM cadm_mod_inst" +
		" WHERE" +
		"	(mod_inst_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_mod_inst_id);

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
		s_mod_inst_id = rs.getString(1);
		s_machine_id = rs.getString(2);
		s_mod_id = rs.getString(3);
		s_version = rs.getString(4);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_cadm_mod_inst_save" +
		"	@mod_inst_id=?," +
		"	@machine_id=?," +
		"	@mod_id=?," +
		"	@version=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveParents(Connection conn) throws Exception
	{
		if (m_Machine!=null)
		{
			m_Machine.save(conn);
			s_machine_id = m_Machine.s_machine_id;
		}
		return 1;
	 }

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_mod_inst_id);
		pstmt.setString(2, s_machine_id);
		pstmt.setString(3, s_mod_id);
		pstmt.setString(4, s_version);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_mod_inst_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	public int saveChildren(Connection conn) throws Exception
	{
		if (m_ModInstServices!=null)
		{
			m_ModInstServices.s_mod_inst_id = s_mod_inst_id;
			m_ModInstServices.save(conn);
		}
		return 1;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM cadm_mod_inst" +
		" WHERE" +
		"	(mod_inst_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteChildren(Connection conn) throws Exception
	{
		if(m_ModInstServices!=null) m_ModInstServices.delete(conn);
		return 1;
	}

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_mod_inst_id);
		return pstmt.executeUpdate();
	}

	public int deleteParents(Connection conn) throws Exception
	{
		if(m_Machine!=null) m_Machine.delete(conn);
		return 1;
	}

	// === XML Methods ===

	public String m_sMainElementName = "mod_inst";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_mod_inst_id != null ) XmlUtil.appendTextChild(e, "mod_inst_id", s_mod_inst_id);
		if( s_machine_id != null ) XmlUtil.appendTextChild(e, "machine_id", s_machine_id);
		if( s_mod_id != null ) XmlUtil.appendTextChild(e, "mod_id", s_mod_id);
		if( s_version != null ) XmlUtil.appendTextChild(e, "version", s_version);
	}

	public void appendParentsToXml(Element e)
	{
		if (m_Machine != null) appendChild(e, m_Machine);
	}

	public void appendChildrenToXml(Element e)
	{
		if (m_ModInstServices != null) appendChild(e, m_ModInstServices);
	}

	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_mod_inst_id = XmlUtil.getChildTextValue(e, "mod_inst_id");
		s_machine_id = XmlUtil.getChildTextValue(e, "machine_id");
		s_mod_id = XmlUtil.getChildTextValue(e, "mod_id");
		s_version = XmlUtil.getChildTextValue(e, "version");
	}

	public void getParentsFromXml(Element e) throws Exception
	{
		Element eMachine = XmlUtil.getChildByName(e, "machine");
		if(eMachine != null) m_Machine = new Machine(eMachine);
	}

	public void getChildrenFromXml(Element e) throws Exception
	{
		Element eModInstServices = XmlUtil.getChildByName(e, "mod_inst_services");
		if(eModInstServices != null) m_ModInstServices = new ModInstServices(eModInstServices);
	}

	// === Other Methods ===
}



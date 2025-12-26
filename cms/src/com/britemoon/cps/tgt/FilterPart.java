package com.britemoon.cps.tgt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class FilterPart extends BriteObject
{
	// === Properties ===

	public String s_parent_filter_id = null;
	public String s_child_filter_id = null;
	public String s_display_seq = null;
	private static Logger logger = Logger.getLogger(FilterPart.class.getName()); 
	// === Parents ===

		public Filter m_ChildFilter = null;

	// === Constructors ===

	public FilterPart()
	{
	}
	
	public FilterPart(String sParentFilterId, String sChildFilterId) throws Exception
	{
		s_parent_filter_id = sParentFilterId;
		s_child_filter_id = sChildFilterId;
		retrieve();
	}

	public FilterPart(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	private String m_sRetrieveSql =
		" SELECT" +
		"	parent_filter_id," +
		"	child_filter_id," +
		"	display_seq" +
		" FROM ctgt_filter_part" +
		" WHERE" +
		"	(parent_filter_id=?) AND" +
		"	(child_filter_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_parent_filter_id);
		pstmt.setString(2, s_child_filter_id);

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
		s_parent_filter_id = rs.getString(1);
		s_child_filter_id = rs.getString(2);
		s_display_seq = rs.getString(3);
	}

	// === DB Method save()===

	private String m_sSaveSql =
		" EXECUTE usp_ctgt_filter_part_save" +
		"	@parent_filter_id=?," +
		"	@child_filter_id=?," +
		"	@display_seq=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveParents(Connection conn) throws Exception
	{
		if (m_ChildFilter!=null)
		{
			m_ChildFilter.save(conn);
			s_child_filter_id = m_ChildFilter.s_filter_id;
		}
		return 1;
	}

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_parent_filter_id);
		pstmt.setString(2, s_child_filter_id);
		pstmt.setString(3, s_display_seq);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_parent_filter_id = rs.getString(1);
			s_child_filter_id = rs.getString(2);

			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	// === DB Method delete()===

	private String m_sDeleteSql =
		" DELETE FROM ctgt_filter_part" +
		" WHERE" +
		"	(parent_filter_id=?) AND" +
		"	(child_filter_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_parent_filter_id);
		pstmt.setString(2, s_child_filter_id);

		return pstmt.executeUpdate();
	}

	public int deleteParents(Connection conn) throws Exception
	{
		if(m_ChildFilter!=null) m_ChildFilter.delete(conn);
		return 1;
	}
	
	// === XML Methods ===

	public String m_sMainElementName = "filter_part";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_parent_filter_id != null ) XmlUtil.appendTextChild(e, "parent_filter_id", s_parent_filter_id);
		if( s_child_filter_id != null ) XmlUtil.appendTextChild(e, "child_filter_id", s_child_filter_id);
		if( s_display_seq != null ) XmlUtil.appendTextChild(e, "display_seq", s_display_seq);
	}

	public void appendParentsToXml(Element e)
	{
		if (m_ChildFilter != null) appendChild(e, m_ChildFilter);
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_parent_filter_id = XmlUtil.getChildTextValue(e, "parent_filter_id");
		s_child_filter_id = XmlUtil.getChildTextValue(e, "child_filter_id");
		s_display_seq = XmlUtil.getChildTextValue(e, "display_seq");
	}

	public void getParentsFromXml(Element e) throws Exception
	{
		Element eChildFilter = XmlUtil.getChildByName(e, "filter");
		if(eChildFilter != null) m_ChildFilter = new Filter(eChildFilter);
	}
	
	// === Other Methods ===
}



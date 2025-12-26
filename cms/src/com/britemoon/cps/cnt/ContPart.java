package com.britemoon.cps.cnt;

import com.britemoon.*;
import com.britemoon.cps.*;
import com.britemoon.cps.tgt.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class ContPart extends BriteObject
{
	// === Properties ===

	public String s_parent_cont_id = null;
	public String s_seq = null;
	public String s_child_cont_id = null;
	public String s_filter_id = null;
	public String s_default_flag = null;
        public String s_max_elements_in_logic_block = null;
	private static Logger logger = Logger.getLogger(ContPart.class.getName());

	// === Parents ===

		public Content m_ChildContent = null;
		public Filter m_Filter = null;

	// === Constructors ===

	public ContPart()
	{
	}

	public ContPart(String sParentContId, String sSeq) throws Exception
	{
		s_parent_cont_id = sParentContId;
		s_seq = sSeq;
		retrieve();
	}

	public ContPart(Element e) throws Exception
	{
		fromXml(e);
	}

	// === DB Methods ===

	// === DB Method retrieve()===

	public String m_sRetrieveSql =
		" SELECT" +
		"	parent_cont_id," +
		"	seq," +
		"	child_cont_id," +
		"	filter_id," +
		"	default_flag," +
                "       max_elements_in_logic_block" +
		" FROM ccnt_cont_part" +
		" WHERE" +
		"	(parent_cont_id=?) AND" +
		"	(seq=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_parent_cont_id);
		pstmt.setString(2, s_seq);

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
		s_parent_cont_id = rs.getString(1);
		s_seq = rs.getString(2);
		s_child_cont_id = rs.getString(3);
		s_filter_id = rs.getString(4);
		s_default_flag = rs.getString(5);
                s_max_elements_in_logic_block = rs.getString(6);
	}

	// === DB Method save()===

	public String m_sSaveSql =
		" EXECUTE usp_ccnt_cont_part_save" +
		"	@parent_cont_id=?," +
		"	@seq=?," +
		"	@child_cont_id=?," +
		"	@filter_id=?," +
		"	@default_flag=?," +
                "       @max_elements_in_logic_block=?";


	public String getSaveSql() { return m_sSaveSql; }

	public int saveParents(Connection conn) throws Exception
	{
		if (m_ChildContent!=null)
		{
			m_ChildContent.save(conn);
			s_child_cont_id = m_ChildContent.s_cont_id;
		}
		if (m_Filter!=null)
		{
			m_Filter.save(conn);
			s_filter_id = m_Filter.s_filter_id;
		}
		return 1;
	}

	public int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_parent_cont_id);
		pstmt.setString(2, s_seq);
		pstmt.setString(3, s_child_cont_id);
		pstmt.setString(4, s_filter_id);
		pstmt.setString(5, s_default_flag);
                pstmt.setString(6, s_max_elements_in_logic_block);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_parent_cont_id = rs.getString(1);
			s_seq = rs.getString(2);

			nReturnCode = 1;
		}
		rs.close();

		return nReturnCode;
	}

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ccnt_cont_part" +
		" WHERE" +
		"	(parent_cont_id=?) AND" +
		"	(seq=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_parent_cont_id);
		pstmt.setString(2, s_seq);

		return pstmt.executeUpdate();
	}

	public int deleteParents(Connection conn) throws Exception
	{
		if(m_ChildContent!=null) m_ChildContent.delete(conn);
		if(m_Filter!=null) m_Filter.delete(conn);
		return 1;
	}

	// === XML Methods ===

	public String m_sMainElementName = "cont_part";
	public String getMainElementName() { return m_sMainElementName; }

	// === To XML Methods ===

	public void appendPropsToXml(Element e)
	{
		if( s_parent_cont_id != null ) XmlUtil.appendTextChild(e, "parent_cont_id", s_parent_cont_id);
		if( s_seq != null ) XmlUtil.appendTextChild(e, "seq", s_seq);
		if( s_child_cont_id != null ) XmlUtil.appendTextChild(e, "child_cont_id", s_child_cont_id);
		if( s_filter_id != null ) XmlUtil.appendTextChild(e, "filter_id", s_filter_id);
		if( s_default_flag != null ) XmlUtil.appendTextChild(e, "default_flag", s_default_flag);
        if( s_max_elements_in_logic_block != null ) XmlUtil.appendTextChild(e, "max_elements_in_logic_block", s_max_elements_in_logic_block);

	}

	public void appendParentsToXml(Element e)
	{
		if (m_ChildContent != null) appendChild(e, m_ChildContent);
		if (m_Filter != null) appendChild(e, m_Filter);
	}

	// === From XML Methods ===

	public void getPropsFromXml(Element e)
	{
		s_parent_cont_id = XmlUtil.getChildTextValue(e, "parent_cont_id");
		s_seq = XmlUtil.getChildTextValue(e, "seq");
		s_child_cont_id = XmlUtil.getChildTextValue(e, "child_cont_id");
		s_filter_id = XmlUtil.getChildTextValue(e, "filter_id");
		s_default_flag = XmlUtil.getChildTextValue(e, "default_flag");
        s_max_elements_in_logic_block = XmlUtil.getChildTextValue(e, "max_elements_in_logic_block");

	}

	public void getParentsFromXml(Element e) throws Exception
	{
		Element eChildContent = XmlUtil.getChildByName(e, "content");
		if(eChildContent != null) m_ChildContent = new Content(eChildContent);

		Element eFilter = XmlUtil.getChildByName(e, "filter");
		if(eFilter != null) m_Filter = new Filter(eFilter);
	}

	// === Other Methods ===
}



package com.britemoon.cps.tgt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import org.apache.log4j.*;

public class Filter extends BriteObject
{
	// === Properties ===

	public String s_filter_id = null;
	public String s_filter_name = null;
	public String s_type_id = null;
	public String s_cust_id = null;
	public String s_status_id = null;
	public String s_origin_filter_id = null;
	public String s_usage_type_id = null;
	public String s_aprvl_status_flag = null;
	private static Logger logger = Logger.getLogger(Filter.class.getName());

	// === Parents ===

	public Filter()
	{
	}
	
	public Filter(String sFilterId) throws Exception
	{
		s_filter_id = sFilterId;
		retrieve();
	}

	public Filter(Element e) throws Exception
	{
		fromXml(e);
	}

	// === Children ===

	// one to one children

	public Formula m_Formula = null;
	public FilterStatistic m_FilterStatistic = null;
	public FilterEditInfo m_FilterEditInfo = null;
		
	// one to many children

	public FilterParams m_FilterParams = null;
	public FilterParts m_FilterParts = null;
	public PreviewAttrs m_PreviewAttrs = null;
	public CustomFormula m_CustomFormula = null;

	//public FilterScopes m_FilterScopes = null;

	// === Constructors ===

	// === DB Methods ===

	// === DB Method retrieve()===

	private String m_sRetrieveSql =
		" SELECT" +
		"	filter_id," +
		"	filter_name," +
		"	type_id," +
		"	cust_id," +
		"	status_id," +
		"	origin_filter_id," +
		"	usage_type_id," +
		"	aprvl_status_flag" +
		" FROM ctgt_filter" +
		" WHERE" +
		"	(filter_id=?)";

	public String getRetrieveSql() { return m_sRetrieveSql; }

	public int retrieveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_filter_id);

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
		s_filter_id = rs.getString(1);
		b = rs.getBytes(2);
		s_filter_name = (b == null)?null:new String(b,"UTF-8");
		s_type_id = rs.getString(3);
		s_cust_id = rs.getString(4);
		s_status_id = rs.getString(5);
		s_origin_filter_id = rs.getString(6);
		s_usage_type_id = rs.getString(7);
		s_aprvl_status_flag = rs.getString(8);
	}

	// === DB Method save()===

	private String m_sSaveSql =
		" EXECUTE usp_ctgt_filter_save" +
		"	@filter_id=?," +
		"	@filter_name=?," +
		"	@type_id=?," +
		"	@cust_id=?," +
		"	@status_id=?," +
		"	@origin_filter_id=?," +
		"	@usage_type_id=?," +
          "    @aprvl_status_flag=?";

	public String getSaveSql() { return m_sSaveSql; }

	public int saveParents(Connection conn) throws Exception
	{
		// this has nothing in common with "parents" but
		// delete all old filter parts		
		// (that is relations between this and child filters
		// but not child filters themselvs as they can participate other filters)
		// should be executed before saving new filter parts
		// it could be done in saveChildren
		// but deleting them here will simplify cycle refernce check in filter tree

		if (s_filter_id == null) return 1;
		
		if (m_FilterParts != null)
		{
			FilterParts fp = new FilterParts();
			fp.s_parent_filter_id = s_filter_id;
			if(fp.retrieve(conn) > 0) fp.delete(conn);
		}

		if (m_FilterParams != null)
		{
			FilterParams fp = new FilterParams();
			fp.s_filter_id = s_filter_id;
			if(fp.retrieve(conn) > 0) fp.delete(conn);
		}

		if (m_PreviewAttrs!=null)
		{
			PreviewAttrs pa = new PreviewAttrs();
			pa.s_filter_id = s_filter_id;
			if(pa.retrieve(conn) > 0) pa.delete(conn);
		}
		
		return 1;
	}
	
	protected int saveProps(PreparedStatement pstmt) throws Exception
	{
		int nReturnCode = 0;

		pstmt.setString(1, s_filter_id);
		if(s_filter_name == null) pstmt.setString(2, s_filter_name);
		else pstmt.setBytes(2, s_filter_name.getBytes("UTF-8"));
		pstmt.setString(3, s_type_id);
		pstmt.setString(4, s_cust_id);
		pstmt.setString(5, s_status_id);
		pstmt.setString(6, s_origin_filter_id);
		pstmt.setString(7, s_usage_type_id);
		pstmt.setString(8, s_aprvl_status_flag);

		ResultSet rs = pstmt.executeQuery();

		byte[] b = null;
		if (rs.next())
		{
			s_filter_id = rs.getString(1);
			nReturnCode = 1;
		}
		rs.close();
		
		return nReturnCode;
	}

	 public int saveChildren(Connection conn) throws Exception
	 {
		if (m_Formula!=null)
		{
			m_Formula.s_filter_id = s_filter_id;
			m_Formula.save(conn);
		}

		if (m_FilterStatistic!=null)
		{
			m_FilterStatistic.s_filter_id = s_filter_id;
			m_FilterStatistic.save(conn);
		}

		if (m_FilterEditInfo!=null)
		{
		 	m_FilterEditInfo.s_filter_id = s_filter_id;
		  	m_FilterEditInfo.save(conn);
		}

		if (m_FilterParams!=null)
		{
	 		m_FilterParams.s_filter_id = s_filter_id;
		 	m_FilterParams.save(conn);
		}
	 
		if (m_FilterParts!=null)
		{
			m_FilterParts.s_parent_filter_id = s_filter_id;
			m_FilterParts.save(conn);			
		}			

		if (m_PreviewAttrs!=null)
		{
			m_PreviewAttrs.s_filter_id = s_filter_id;
			m_PreviewAttrs.save(conn);			
		}

//		if (m_FilterScopes!=null)
//		{
//			m_FilterScopes.s_filter_id = s_filter_id;
//			m_FilterScopes.save(conn);			
//		}			

		return 1;
	 }

	// === DB Method delete()===

	public String m_sDeleteSql =
		" DELETE FROM ctgt_filter" +
		" WHERE" +
		"	(filter_id=?)";

	public String getDeleteSql() { return m_sDeleteSql; }

	public int deleteChildren(Connection conn) throws Exception
	{
		if (m_Formula!=null) m_Formula.delete(conn);
		if (m_FilterStatistic!=null) m_FilterStatistic.delete(conn);
		if (m_FilterEditInfo!=null) m_FilterEditInfo.delete(conn);
		if (m_FilterParams!=null) m_FilterParams.delete(conn);
		if (m_FilterParts!=null) m_FilterParts.delete(conn);
		if (m_PreviewAttrs!=null) m_PreviewAttrs.delete(conn);
//		if (m_FilterScopes!=null) m_FilterScopes.delete(conn);
		return 1;
	}

	public int deleteProps(PreparedStatement pstmt) throws Exception
	{
		pstmt.setString(1, s_filter_id);
		return pstmt.executeUpdate();
	}
	
	// === XML Methods ===
	
	public String m_sMainElementName = "filter";
	public String getMainElementName() { return m_sMainElementName; }
		
	// === To XML Methods ===	

	public void appendPropsToXml(Element e)
	{
		if( s_filter_id != null ) XmlUtil.appendTextChild(e, "filter_id", s_filter_id);
		if( s_filter_name != null ) XmlUtil.appendCDataChild(e, "filter_name", s_filter_name);
		if( s_type_id != null ) XmlUtil.appendTextChild(e, "type_id", s_type_id);
		if( s_cust_id != null ) XmlUtil.appendTextChild(e, "cust_id", s_cust_id);
		if( s_status_id != null ) XmlUtil.appendTextChild(e, "status_id", s_status_id);
		if( s_origin_filter_id != null ) XmlUtil.appendTextChild(e, "origin_filter_id", s_origin_filter_id);
		if( s_usage_type_id != null ) XmlUtil.appendTextChild(e, "usage_type_id", s_usage_type_id);
		if( s_aprvl_status_flag != null ) XmlUtil.appendTextChild(e, "aprvl_status_flag", s_aprvl_status_flag);
	}

	public void appendChildrenToXml(Element e)
	{
		if (m_Formula != null) appendChild(e, m_Formula);
		if (m_FilterStatistic != null) appendChild(e, m_FilterStatistic);
		if (m_FilterEditInfo!=null) appendChild(e, m_FilterEditInfo);
		if (m_FilterParams != null) appendChild(e, m_FilterParams);
		if (m_FilterParts != null) appendChild(e, m_FilterParts);
		if (m_PreviewAttrs != null) appendChild(e, m_PreviewAttrs);
//		if (m_FilterScopes != null) appendChild(e, m_FilterScopes);		
	}
	
	// === From XML Methods ===	

	public void getPropsFromXml(Element e)
	{
		s_filter_id = XmlUtil.getChildTextValue(e, "filter_id");
		s_filter_name = XmlUtil.getChildCDataValue(e, "filter_name");
		s_type_id = XmlUtil.getChildTextValue(e, "type_id");
		s_cust_id = XmlUtil.getChildTextValue(e, "cust_id");
		s_status_id = XmlUtil.getChildTextValue(e, "status_id");
		s_origin_filter_id = XmlUtil.getChildTextValue(e, "origin_filter_id");
		s_usage_type_id = XmlUtil.getChildTextValue(e, "usage_type_id");		
		s_aprvl_status_flag = XmlUtil.getChildTextValue(e, "aprvl_status_flag");		
	}

	public void getChildrenFromXml(Element e) throws Exception
	{
		Element eFormula = XmlUtil.getChildByName(e, "formula");
		if(eFormula != null) m_Formula = new Formula(eFormula);

		Element eFilterStatistic = XmlUtil.getChildByName(e, "filter_statistic");
		if(eFilterStatistic != null) m_FilterStatistic = new FilterStatistic(eFilterStatistic);

		Element eFilterEditInfo = XmlUtil.getChildByName(e, "filter_edit_info");
		if(eFilterEditInfo != null) m_FilterEditInfo = new FilterEditInfo(eFilterEditInfo);

		Element eFilterParams = XmlUtil.getChildByName(e, "filter_params");
		if(eFilterParams != null) m_FilterParams = new FilterParams(eFilterParams);

		Element eFilterParts = XmlUtil.getChildByName(e, "filter_parts");
		if (eFilterParts != null) { m_FilterParts = new FilterParts(eFilterParts); }
			
		Element ePreviewAttrs = XmlUtil.getChildByName(e, "preview_attrs");
		if(ePreviewAttrs != null) m_PreviewAttrs = new PreviewAttrs(ePreviewAttrs);

//		Element eFilterScopes = XmlUtil.getChildByName(e, "filter_scopes");
//		if(eFilterScopes != null) m_FilterScopes = new FilterScopes(eFilterScopes);
	}

	// === Other Methods ===

	public int setStatus(int nStatusId) throws Exception
	{
		String sSql	=
			" UPDATE ctgt_filter" +
			" SET status_id = " + nStatusId +
			" WHERE filter_id = " + s_filter_id;
		return BriteUpdate.executeUpdate(sSql);
	}

	public int setAprvlStatusFlag(int nAprvlStatusFlag) throws Exception
	{
		String sSql	=
			" UPDATE ctgt_filter" +
			" SET aprvl_status_flag = " + nAprvlStatusFlag +
			" WHERE filter_id = " + s_filter_id;
		return BriteUpdate.executeUpdate(sSql);
	}
}

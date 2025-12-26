package com.britemoon.cps.tgt;

import com.britemoon.*;
import com.britemoon.cps.*;

import java.util.*;
import java.sql.*;
import java.io.StringWriter;
import org.apache.log4j.*;

public class FilterRetrieveUtil
{
	private static Logger logger = Logger.getLogger(FilterRetrieveUtil.class.getName());
	public static void retrieve4UI(Filter filter) throws Exception
	{
		if(filter.s_filter_id == null) return;
		retrieveFilterTree(filter);
		retrieveFilterStatistic(filter); //???
		retrievePreviewAttrs(filter);
	}
	
	public static void retrieve4Rcp(Filter filter) throws Exception
	{
		if(filter.s_filter_id == null) return;	
		retrieveFilterTree(filter);
	}

	// === === ===
	
	public static void retrieveFilterTree(Filter filter) throws Exception
	{
		if(filter.s_filter_id == null) return;
		filter.retrieve();
		retrieveFilterParts(filter);
		int nTypeId = Integer.parseInt(filter.s_type_id);
		if(nTypeId == FilterType.FORMULA) retrieveFormula(filter);
		else retrieveFilterParams(filter);
	}
		
	public static void retrieveFormula(Filter filter) throws Exception
	{
		if( filter.s_filter_id == null ) return;
		Formula formula = new Formula();
		formula.s_filter_id = filter.s_filter_id;
		if (formula.retrieve() > 0) { filter.m_Formula = formula; }
	}

	public static void retrieveFilterStatistic(Filter filter) throws Exception
	{
		if( filter.s_filter_id == null ) return;	
		FilterStatistic filter_statistic = new FilterStatistic();
		filter_statistic.s_filter_id = filter.s_filter_id;
		if(filter_statistic.retrieve() > 0) filter.m_FilterStatistic = filter_statistic;
	}

	// === === ===

	public static void retrieveFilterParams(Filter filter) throws Exception
	{
		FilterParams filter_params = new FilterParams();
		filter_params.s_filter_id = filter.s_filter_id;
		filter_params.retrieve();
		filter.m_FilterParams = filter_params;
	}
	
	public static void retrievePreviewAttrs(Filter filter) throws Exception
	{
		PreviewAttrs filter_attrs = new PreviewAttrs();
		filter_attrs.s_filter_id = filter.s_filter_id;
		filter_attrs.retrieve();
		filter.m_PreviewAttrs = filter_attrs;
	}

	// === === ===
		
	public static void retrieveFilterParts(Filter filter) throws Exception
	{
		FilterParts filter_parts = new FilterParts();
		filter_parts.s_parent_filter_id = filter.s_filter_id;
		if(filter_parts.retrieve() > 0)
		{
			FilterPart filter_part = null;
			com.britemoon.cps.tgt.Filter child_filter = null;
			for (Enumeration e = filter_parts.elements() ; e.hasMoreElements() ;)
			{
				filter_part = (FilterPart) e.nextElement();
				retrieveFilterPartChildFilter(filter_part);
			}
		}
		filter.m_FilterParts = filter_parts;
	}

	public static void retrieveFilterPartChildFilter(FilterPart filter_part) throws Exception
	{
		if ( filter_part.s_child_filter_id == null ) return;
		Filter child_filter = new Filter();
		child_filter.s_filter_id = filter_part.s_child_filter_id;
		if(child_filter.retrieve() < 1) return;
		retrieveFilterTree(child_filter);
		filter_part.m_ChildFilter = child_filter;
	}

     public static String getOptionsHtml(String sCustId, String sSelectedFilterId, String sSelectedCategoryId)
          throws Exception
     {
          StringWriter sw = new StringWriter();

          String sSql = null;
		ConnectionPool cp = null;
		Connection conn = null;
          Statement stmt = null;
          ResultSet rs = null;

		try
		{
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("FilterRetrieveUtil.getFilterOptionsHtml()");
               stmt = conn.createStatement();

               if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) )
               {
                    sSql =
                         " SELECT filter_id, CASE status_id WHEN " + FilterStatus.DELETED + " THEN '*Deleted* ' + filter_name ELSE filter_name END," +
                         " CASE status_id WHEN " + FilterStatus.DELETED + " THEN '1' ELSE '0' END" +
                         " FROM ctgt_filter" +
                         " WHERE cust_id = " + sCustId +
                         " AND origin_filter_id IS NULL" +
                         " AND filter_name IS NOT NULL" +
                         " AND type_id=" + FilterType.MULTIPART +
                         " AND usage_type_id=" + FilterUsageType.REGULAR +
                         " AND status_id <> " + FilterStatus.DELETED +      // Don't display DELETED Filters
                         ((sSelectedFilterId!=null)?" OR filter_id = " + sSelectedFilterId:"") +
                         " ORDER BY 1 DESC";
               }
               else
               {
                    sSql =
                         " SELECT DISTINCT f.filter_id, CASE status_id WHEN " + FilterStatus.DELETED + " THEN '*Deleted* ' + f.filter_name ELSE f.filter_name END," +
                         " CASE status_id WHEN " + FilterStatus.DELETED + " THEN '1' ELSE '0' END" +
                         " FROM ctgt_filter f, ccps_object_category oc" +
                         " WHERE (f.cust_id = " + sCustId +
                         " AND f.origin_filter_id IS NULL" +
                         " AND f.filter_name IS NOT NULL" +
                         " AND f.type_id=" + FilterType.MULTIPART +
                         " AND f.filter_id = oc.object_id" +
                         " AND f.usage_type_id=" + FilterUsageType.REGULAR +
                         " AND f.status_id <> " + FilterStatus.DELETED +      // Don't display DELETED Filters
                         " AND oc.type_id = " + ObjectType.FILTER +
                         " AND oc.cust_id = " + sCustId +
                         " AND oc.category_id = " + sSelectedCategoryId + ")" +
                         ((sSelectedFilterId!=null)?" OR f.filter_id = " + sSelectedFilterId:"") +
                         " ORDER BY 1 DESC";	
               }

               String sFilterId = "";
               String sFilterName = "";
               String sDeleted = "0";
               rs = stmt.executeQuery(sSql);		
               while( rs.next() )
               {
                    sFilterId = rs.getString(1);
                    sFilterName = new String(rs.getBytes(2),"UTF-8");
                    sDeleted = rs.getString(3);
                    sw.write("<OPTION value=\"" + ((sDeleted.equals("1"))?"":sFilterId) + "\"" + ((sFilterId.equals(sSelectedFilterId))?" selected":"") + ">");
                    sw.write(HtmlUtil.escape(sFilterName));
                    sw.write("</OPTION>\r\n");
               }
          } catch (Exception e) {
               throw e;
          } finally {
               if (rs != null)
                    rs.close();
               if (stmt != null)
                    stmt.close();
               cp.free(conn);
          }
          return sw.toString();
     }

		
//		FilterScopes filter_scopes = new FilterScopes();
//		filter_scopes.s_filter_id = filter.s_filter_id;
//		filter_scopes.retrieve();
//		filter.m_FilterScopes = filter_scopes;
}

package com.britemoon.cps;

import com.britemoon.*;

import java.sql.*;
import java.io.*;
import java.util.*;
import java.util.logging.Logger;

import org.w3c.dom.*;

public class CustAttrsUtil
{
	private static Logger logger = Logger.getLogger(CustAttrsUtil.class.getName());
	private static String attribList = null;

	public static CustAttrs retrieve4filter(String sCustId, String sFilterId) throws Exception
	{
		return retrieve4filter(sCustId, sFilterId, null);
	}
	
	public static CustAttrs retrieve4filter(String sCustId, String sFilterId, int nAttrType) throws Exception
	{
		return retrieve4filter(sCustId, sFilterId, String.valueOf(nAttrType));
	}
		
	public static CustAttrs retrieve4filter(String sCustId, String sFilterId, String sAttrType) throws Exception
	{
		CustAttrs cas = new CustAttrs();
		cas.m_sRetrieveSql =
			" EXEC usp_ctgt_filter_attrs_get" +
			" @cust_id = " + sCustId +
			", @filter_id = " + sFilterId +
			", @type_id = " + sAttrType;
		cas.retrieve();
		return cas;
	}
		
	// this is not good, but there is no time ...
	public static CustAttrs retrieve4filter_preview(String sCustId, String sFilterId) throws Exception
	{
		CustAttrs cas = new CustAttrs();
		cas.m_sRetrieveSql =
			" EXEC usp_ctgt_filter_preview_attrs_get" +
			" @cust_id = " + sCustId +
			", @filter_id = " + sFilterId;
		cas.retrieve();
		return cas;
	}
	
	public static CustAttrs retrieveDateAttrs(String sCustId, String sFilterId) throws Exception
	{
		CustAttrs cas = new CustAttrs();
		cas.m_sRetrieveSql =
			" EXEC usp_ctgt_filter_preview_attrs_get" +
			" @cust_id = " + sCustId +
			", @filter_id = " + sFilterId;
		cas.retrieve();
		return cas;
	}
	
	public static String toHtmlOptions(CustAttrs cas)
	{
		return toHtmlOptions(cas, null);
	}

	public static String toHtmlOptions(CustAttrs cas, String sSelectedId)
	{
		StringWriter sw = new StringWriter();

		CustAttr ca = null;
		for(Enumeration e = cas.elements(); e.hasMoreElements(); )
		{
			ca = (CustAttr) e.nextElement();
			sw.write(
				"<OPTION value=\"" + ca.s_attr_id + "\"" +
				(ca.s_attr_id.equals(sSelectedId)?" selected":"")  + ">" +
				HtmlUtil.escape(ca.s_display_name) + "</OPTION>\r\n");
		}
		return sw.toString();
	}
	// TT 5688: Added method to order the attribute list
	public static String toHtmlOptionsExport(CustAttrs cas)
	{
		return toHtmlOptionsExport(cas, null);
	}
	
	public static String toHtmlOptionsExport(CustAttrs cas, String sSelectedId)
	{
		StringWriter sw = new StringWriter();
		CustAttr ca = null;
		if (attribList != null) {			
		    StringTokenizer st = new StringTokenizer(attribList,",");
			Vector vec = new Vector();
			
			while (st.hasMoreTokens()){
				vec.add(new Integer(st.nextToken()));
			}

			try
			{
				if (vec.size() > 0)
				{
					for(int i=0; i< vec.size(); i++)
					{
						Enumeration e = cas.elements();	
						while(e.hasMoreElements()){					
							ca = (CustAttr) e.nextElement();
							if(Integer.parseInt(ca.s_attr_id) == (Integer)vec.elementAt(i)){
							sw.write(
									"<OPTION value=\"" + ca.s_attr_id + "\"" +
									(ca.s_attr_id.equals(sSelectedId)?" selected":"")  + ">" +
									HtmlUtil.escape(ca.s_display_name) + "</OPTION>\r\n");
								break;
							}
						}
					}
				}
			}
			catch(Exception e)
			{e.printStackTrace();}
		}
		return sw.toString();
	}
	
	//	Release 6.0: Added for Export Once and Re-run as needed.
	public static CustAttrs retrieve4Export(String sCustId) throws Exception
	{
		CustAttrs cas = new CustAttrs();
		cas.m_sRetrieveSql =
				" EXEC usp_cexp_export_attrs_get" +
				" @cust_id = " + sCustId ;
		cas.retrieve();
		return cas;
	}
	
	public static CustAttrs retrieve4Export_preview(String sCustId, String sAttribList) throws Exception
	{
		attribList = sAttribList;
		CustAttrs cas = new CustAttrs();
		cas.m_sRetrieveSql =
			" EXEC usp_cexp_export_preview_attrs_get" +
			" @cust_id = " + sCustId +
			", @attr_list = '" + sAttribList + "'";
		cas.retrieve();
		return cas;
	}

    public static String toHtmlOptions(CustAttrs cas, String sSelectedId, String selectedCustomId, String selectedCustomTypeId, boolean includeCustoms) {
        StringWriter sw = new StringWriter();
        CustAttr ca = null;
        for (Enumeration<CustAttr> e = cas.elements(); e.hasMoreElements(); ) {
            ca = e.nextElement();
            sw.write(
                    "<OPTION value=\"" + ca.s_attr_id + "\"" + ((
                            ca.s_attr_id.equals(sSelectedId) && selectedCustomId == null) ? " selected" : "") + ">" +
                            HtmlUtil.escape(ca.s_display_name) + "</OPTION>\r\n");
        }
        ConnectionPool cp = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        if (includeCustoms)
            try {
                cp = ConnectionPool.getInstance();
                conn = cp.getConnection("CustAttrsUtil");
                Map<Long, String> idList = new HashMap<>();
                String sql = "select type_id,name from ctgt_web_formula_type with(nolock)";
                pstmt = conn.prepareStatement(sql);
                ResultSet rs = pstmt.executeQuery();
                while (rs.next())
                    idList.put(Long.valueOf(rs.getLong(1)), rs.getString(2));
                rs.close();
                pstmt.close();
                for (Map.Entry<Long, String> pair : idList.entrySet()) {
                    sql = "select id, column_name, display_name from " + (String)pair.getValue() + " with(nolock)";
                    pstmt = conn.prepareStatement(sql);
                    rs = pstmt.executeQuery();
                    while (rs.next())
                        sw.write(
                                "<OPTION custom_formula_type=\"" + pair.getKey() + "\" value=\"" + rs.getString(1) + "\"" + ((
                                        selectedCustomId != null && rs.getString(1).equals(selectedCustomId) && selectedCustomTypeId.equals(((Long)pair.getKey()).toString())) ? " selected" : "") +
                                        ">" + HtmlUtil.escape(rs.getString(3)) + "</OPTION>\r\n");
                    rs.close();
                }
            } catch (Exception exception) {
                exception.printStackTrace();
            } finally {
                try {
                    if (pstmt != null)
                        pstmt.close();
                } catch (Exception exception) {}
                if (conn != null)
                    cp.free(conn);
            }
        return sw.toString();
    }

}
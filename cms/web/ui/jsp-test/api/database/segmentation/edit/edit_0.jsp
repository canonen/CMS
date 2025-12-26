<%@ page
	language="java"
	import="com.britemoon.*,
			 com.britemoon.cps.*,
			 com.britemoon.cps.tgt.*,
			 java.io.*,java.sql.*,
			 java.util.*,org.w3c.dom.*,
			 org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="../../../../utilities/validator.jsp"%>
<%@ include file="../../header.jsp"%>
<%! static Logger logger = null; %>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

	JsonObject data =new JsonObject();
	JsonArray array = new JsonArray();
//KU: Added for content logic ui
String sUsageTypeId = BriteRequest.getParameter(request, "usage_type_id");

String sTargetGroupDisplay = "Target Group";
if(String.valueOf(FilterUsageType.CONTENT).equals(sUsageTypeId))
{
	sTargetGroupDisplay = "Logic Element";
}
else if(String.valueOf(FilterUsageType.REPORT).equals(sUsageTypeId))
{
	sTargetGroupDisplay = "Report Filter";
}
else
{
	sUsageTypeId = String.valueOf(FilterUsageType.REGULAR);
}

	String sFilterId = request.getParameter("filter_id");	
	
	String sCategoryId = request.getParameter("category_id");
	if ((sCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id))) sCategoryId = ui.s_category_id;
	if("0".equals(sCategoryId)) sCategoryId = null;

	String sImportId = null;
	String sFilterName = null;
	if(sFilterId != null)
	{
		com.britemoon.cps.tgt.Filter f = new com.britemoon.cps.tgt.Filter(sFilterId);
		sFilterName = f.s_filter_name;
		data.put("filterName",f.s_filter_name);
		data.put("filterId",sFilterId);
	}

	String sSql = null;
	
	if (sCategoryId == null)
	{
		sSql  =
			" SELECT distinct filter_id, filter_name" +
			" FROM ctgt_filter" +
			" WHERE" +
			" ("+
			" origin_filter_id IS NULL" +
			" AND len(filter_name) > 0" +
			" AND type_id = " + FilterType.MULTIPART +
			" AND cust_id = " + cust.s_cust_id +
			" AND status_id != " + FilterStatus.DELETED +
			" AND ISNULL(usage_type_id,500) = " + FilterUsageType.REGULAR +
			" ) OR ( filter_id = " + sFilterId + " )"+
			" ORDER BY filter_name";
	}
	else
	{
		sSql  =
			" SELECT distinct f.filter_id, f.filter_name" +
			" FROM ctgt_filter f, ccps_object_category oc" +
			" WHERE" +
			" ("+
			" f.origin_filter_id IS NULL" +
			" AND len(filter_name) > 0" +			
			" AND f.type_id = " + FilterType.MULTIPART +
			" AND f.cust_id = " + cust.s_cust_id +
			" AND f.status_id != " + FilterStatus.DELETED +
			" AND ISNULL(f.usage_type_id,500) = " + FilterUsageType.REGULAR +
			" AND f.filter_id = oc.object_id" +
			" AND oc.type_id = " + ObjectType.FILTER +
			" AND oc.cust_id = " + cust.s_cust_id +
			" AND oc.category_id = " + sCategoryId +
			" ) OR ( filter_id = " + sFilterId + " )"+
			" ORDER BY f.filter_name";
	}

	ConnectionPool cp = null;
	Connection conn = null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);

		PreparedStatement pstmt = null;
		try
		{
			pstmt = conn.prepareStatement(sSql);
			ResultSet rs = pstmt.executeQuery();

			String sId = null;
			String sName = null;

			byte[] b = null;

			while (rs.next())
			{
				data = new JsonObject();
				sId = rs.getString(1);
				b = rs.getBytes(2);
				sName = (b==null)?null:new String(b, "UTF-8");

				if(sId.equals(sFilterId)) data.put("isSelected","selected");
				else data.put("isSelected","");
				data.put("filterId",sId);
				data.put("filterName",sName);
				data.put("FilterType",FilterType.MULTIPART);
				array.put(data);
			}
			rs.close();
		out.println(array);
		}
		catch(Exception ex) { throw ex; }
		finally { if(pstmt != null) pstmt.close(); }
	}
	catch(Exception ex) { throw new Exception(sSql+"\r\n"+ex.getMessage()); }
	finally { if(conn != null) cp.free(conn); }
	%>

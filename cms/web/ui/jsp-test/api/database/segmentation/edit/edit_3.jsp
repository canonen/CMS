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

String sBatchId = null;
String sFilterName = null;
if(sFilterId != null)
{
	com.britemoon.cps.tgt.Filter f = new com.britemoon.cps.tgt.Filter(sFilterId);
	sFilterName = f.s_filter_name;
	FilterParams fps = new FilterParams();
	fps.s_filter_id = sFilterId;
	fps.retrieve();
	sBatchId = fps.getIntegerValue("batch_id");

}
String sSql = null;
if (sCategoryId == null)
{
	sSql =
		" SELECT b.batch_id, b.batch_name" +
		" FROM cupd_batch b" + 
		" WHERE ( (b.type_id = 1" + 
		" AND b.batch_id IN" +
			" (SELECT DISTINCT i.batch_id" +
			" FROM cupd_import i, cupd_batch b" +
			" WHERE i.status_id = "+ UpdateStatus.COMMIT_COMPLETE +
			" AND i.batch_id = b.batch_id" +
			" AND b.cust_id = " + cust.s_cust_id + "))" +
		" OR (b.type_id > 1) )" +
		" AND b.cust_id = " + cust.s_cust_id +
		" ORDER BY type_id, batch_name";
}
else
{
	sSql =
		" SELECT b.batch_id, b.batch_name" +
		" FROM cupd_batch b" + 
		" WHERE ( (b.type_id = 1" + 
		" AND b.batch_id IN" +
			" (SELECT DISTINCT i.batch_id" +
			" FROM cupd_import i, cupd_batch b, ccps_object_category oc" +
			" WHERE i.status_id = "+ UpdateStatus.COMMIT_COMPLETE +
			" AND i.batch_id = b.batch_id" +
			" AND b.cust_id = " + cust.s_cust_id + 
			" AND oc.object_id = i.import_id" +
			" AND oc.type_id = " + ObjectType.IMPORT +
			" AND oc.cust_id = " + cust.s_cust_id +
			" AND oc.category_id = "+sCategoryId + "))" +
		" OR (b.type_id > 1) )" +
		" AND b.cust_id = " + cust.s_cust_id +
		" ORDER BY type_id, batch_name";
}

ConnectionPool cp = null;
Connection conn = null;

try
{
	JsonObject data = new JsonObject();
	JsonArray array = new JsonArray();
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
							if(sId.equals(sBatchId)) data.put("isSelected","selected");
							else data.put("isSelected","");
							data.put("batchId",sId);
							data.put("batchName",sName);
							data.put("batchType",FilterType.BATCH);
							data.put("targetName",sTargetGroupDisplay);
							array.put(data);
						}
						out.println(array);
						rs.close();

	}
	catch(Exception ex) { throw ex; }
	finally { if(pstmt != null) pstmt.close(); }
}
catch(Exception ex) { throw new Exception(sSql+ " "+ex.getMessage()); }
finally { if(conn != null) cp.free(conn); }
%>

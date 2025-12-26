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
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

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

	String sContId = null;
	String sFilterName = null;
	JsonObject data = new JsonObject();
	JsonArray array = new JsonArray();
	if(sFilterId != null)
	{
		com.britemoon.cps.tgt.Filter f = new com.britemoon.cps.tgt.Filter(sFilterId);
		sFilterName = f.s_filter_name;
		FilterParams fps = new FilterParams();
		fps.s_filter_id = sFilterId;
		fps.retrieve();
		sContId = fps.getIntegerValue("cont_id");

	}

	String sSql = null;
	if (sCategoryId == null)
	{
		sSql  =
			" SELECT cont_id, cont_name" +
			" FROM ccnt_content" +
			" WHERE origin_cont_id IS NULL" +
			" AND cust_id = " + cust.s_cust_id +
			" AND type_id = " + ContType.PARAGRAPH +
			" ORDER BY cont_name";
	}
	else
	{
		sSql  =
			" SELECT c.contid, c.cont_name" +
			" FROM ccnt_content c, ccps_object_category oc" +
			" WHERE c.origin_cont_id IS NULL" +
			" AND c.cust_id = " + cust.s_cust_id +
			" AND type_id = " + ContType.PARAGRAPH +
			" AND c.cont_id = oc.object_id" +
			" AND oc.type_id = " + ObjectType.CONTENT +
			" AND oc.cust_id = " + cust.s_cust_id +
			" AND oc.category_id = " + sCategoryId +
			" ORDER BY c.cont_name";
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
							data.put("contId",sId);
							data.put("contName",sName);
							data.put("sfilterId",sFilterId);
							data.put("filterType",FilterType.CONTENT_BLOCK);
							if(sId.equals(sContId)) data.put("isSelected","selected");
							else data.put("isSelected","");
							data.put("TargetName",sTargetGroupDisplay);
							array.put(data);
						}
						out.println(array);
						rs.close();

		}
		catch(Exception ex) { throw ex; }
		finally { if(pstmt != null) pstmt.close(); }
	}
	catch(Exception ex) { throw new Exception(sSql+" "+ex.getMessage()); }
	finally { if(conn != null) cp.free(conn); }
	%>

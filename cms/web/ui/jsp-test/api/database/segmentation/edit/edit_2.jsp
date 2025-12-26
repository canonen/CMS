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
	JsonObject data = new JsonObject();
	JsonObject formData = new JsonObject();
	JsonObject campData = new JsonObject();
	JsonArray array = new JsonArray();
	JsonArray arrayData = new JsonArray();

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

	String sCampId = null;
	String sFormId = null;	
	String sFilterName = null;
	if(sFilterId != null)
	{
		com.britemoon.cps.tgt.Filter f = new com.britemoon.cps.tgt.Filter(sFilterId);
		sFilterName = f.s_filter_name;
		FilterParams fps = new FilterParams();
		fps.s_filter_id = sFilterId;
		fps.retrieve();
		sCampId = fps.getIntegerValue("camp_id");
		sFormId = fps.getIntegerValue("form_id");

	}
	String sSql = null;

	ConnectionPool cp = null;
	Connection conn = null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);

		PreparedStatement pstmt = null;
		
		// === === ===
		
		try
		{
			sSql =
				" SELECT form_id, form_name" +
				" FROM csbs_form" +
				" WHERE cust_id = " + cust.s_cust_id +
				" ORDER BY form_name";

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
							data.put("formId",sId);
							data.put("formName",sName);
							data.put("sFilterId",sFilterId);
							data.put("filterType",FilterType.CAMPAIGN_FORM);
							if(sId.equals(sFormId)) data.put("isSelected","selected");
							else data.put("isSelected","");
							array.put(data);
						}
						formData.put("formData",array);
						array= new JsonArray();
						rs.close();


		}
		catch(Exception ex) { throw ex; }
		finally { if(pstmt != null) pstmt.close(); }

		
		try
		{
			if (sCategoryId == null)
			{
				sSql  =
					" SELECT camp_id, camp_name" +
					" FROM cque_campaign" +
					" WHERE origin_camp_id IS NULL" +
					" AND cust_id = " + cust.s_cust_id +
					" ORDER BY camp_name";
			}
			else
			{
				sSql  =
					" SELECT c.camp_id, c.camp_name" +
					" FROM cque_campaign c, ccps_object_category oc" +
					" WHERE c.origin_camp_id IS NULL" +
					" AND c.cust_id = " + cust.s_cust_id +
					" AND c.camp_id = oc.object_id" +
					" AND oc.type_id = " + ObjectType.CAMPAIGN +
					" AND oc.cust_id = " + cust.s_cust_id +
					" AND oc.category_id = " + sCategoryId +
					" ORDER BY c.camp_name";
			}

			pstmt = conn.prepareStatement(sSql);
			ResultSet rs = pstmt.executeQuery();

			String sId = null;
			String sName = null;

			byte[] b = null;

						while (rs.next())
						{
							data= new JsonObject();
							sId = rs.getString(1);
							b = rs.getBytes(2);
							sName = (b==null)?null:new String(b, "UTF-8");
							data.put("campId",sId);
							data.put("campName",sName);
							data.put("sFilterId",sFilterId);
							data.put("filterType",FilterType.CAMPAIGN_FORM);
							if(sId.equals(sFormId)) data.put("isSelected","selected");
							else data.put("isSelected","");
							array.put(data);
						}
						campData.put("campData",array);
						JsonObject targetData = new JsonObject();
						data = new JsonObject();
						array= new JsonArray();
						data.put("targetName",sTargetGroupDisplay);
						array.put(data);
						targetData.put("targetData",array);

						rs.close();

						arrayData.put(campData);
						arrayData.put(formData);
						arrayData.put(targetData);
						out.println(arrayData);


		}
		catch(Exception ex) { throw ex; }
		finally { if(pstmt != null) pstmt.close(); }
	}
	catch(Exception ex) { throw new Exception(sSql+"\r\n"+ex.getMessage()); }
	finally { if(conn != null) cp.free(conn); }
	%>

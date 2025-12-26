<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.tgt.*,
			java.io.*,java.sql.*,
			java.util.*,org.w3c.dom.*,
			org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="../../header.jsp" %>
<%@ include file="../../../utilities/validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.FILTER);
JsonObject data = new JsonObject();
JsonArray array = new JsonArray();
JsonArray arrayOptions = new JsonArray();
JsonObject dataBatch = new JsonObject();

if(!can.bWrite)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}

String sSaved = request.getParameter("saved");
if (sSaved == null) sSaved = "false";

String sCategoryId = request.getParameter("category_id");
if ((sCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id))) sCategoryId = ui.s_category_id;
if("0".equals(sCategoryId)) sCategoryId = null;

String sUsageTypeId = BriteRequest.getParameter(request, "usage_type_id");

//KU: Added for content logic ui
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
if (sSaved.equals("true")) {

data.put("sTargetGroupDisplay",sTargetGroupDisplay);
}
can = user.getAccessPermission(ObjectType.IMPORT);
can = user.getAccessPermission(ObjectType.BATCH);
if (can.bRead) {
	data.put("filterTypeImport",FileType.IMPORT);
	arrayOptions.put(buildImportOptionsHtml(cust.s_cust_id, sCategoryId));
	arrayOptions.put(buildBatchOptionsHtml(cust.s_cust_id, sCategoryId));

}

can = user.getAccessPermission(ObjectType.CAMPAIGN);
if (can.bRead) {

data.put("filterTypeCampaign",FileType.CAMPAIGN);
	arrayOptions.put(buildCampOptionsHtml(cust.s_cust_id, sCategoryId));
 }

can = user.getAccessPermission(ObjectType.FORM);
if (can.bRead) {

	//arrayOptions.put(buildFormOptionsHtml(cust.s_cust_id, sCategoryId));

 }
	data.put("filterTypeNewsletter",FilterType.NEWSLETTER);
	//arrayOptions.put(buildNewsletterOptionsHtml(cust.s_cust_id, sCategoryId));

	data.put("filterTypeContentBlock",FilterType.CONTENT_BLOCK);
	arrayOptions.put(buildContentBlockOptionsHtml(cust.s_cust_id, sCategoryId));



	can = user.getAccessPermission(ObjectType.CAMPAIGN);
	if (can.bRead) {

		//arrayOptions.put(buildCampOptionsHtml(cust.s_cust_id, sCategoryId));
		data.put("filterTypeCampaign",FilterType.CAMPAIGN);
		data.put("filterTypeLinkRead",FilterType.LINK_READ);
		data.put("filterTypeBback",FilterType.BBACK_FROM_CAMPAIGN);

		data.put("filterTypeLinkClick",FilterType.LINK_CLICK);
		arrayOptions.put(buildLinkOptionsHtml(cust.s_cust_id, sCategoryId));

	}
				can = user.getAccessPermission(ObjectType.FILTER);
				if (can.bRead) {

				data.put("filterTypeMultipart",FilterType.MULTIPART);
				arrayOptions.put(buildFilterOptionsHtml(cust.s_cust_id, sCategoryId));

				}
				can = user.getAccessPermission(ObjectType.IMPORT);
				if (can.bRead) {

				data.put("filterTypeImport",FilterType.IMPORT);
				//arrayOptions.put(buildImportOptionsHtml(cust.s_cust_id, sCategoryId));
				data.put("filterTypeBatch",FilterType.BATCH);
			//	arrayOptions.put(buildBatchOptionsHtml(cust.s_cust_id, sCategoryId));




				}
				data.put("filterTypeNewsletter",FilterType.NEWSLETTER);
				arrayOptions.put(buildNewsletterOptionsHtml(cust.s_cust_id, sCategoryId));

	can = user.getAccessPermission(ObjectType.FORM);
	if (can.bRead) {
		data.put("filterTypeFormSubmit",FilterType.FORM_SUBMIT);
		arrayOptions.put(buildFormOptionsHtml(cust.s_cust_id, sCategoryId));
	}

	array.put(data);
	arrayOptions.put(buildEntityOptionsHtml(cust.s_cust_id));
	arrayOptions.put(array);
	out.println(arrayOptions);
%>
<%!
private static JsonArray buildImportOptionsHtml(String sCustId, String sCategoryId) throws Exception
{
	String sSql = null;
	if (sCategoryId == null)
	{
		sSql =
			" SELECT i.import_id, i.import_name" +
			" FROM cupd_import i WITH(NOLOCK), cupd_batch b WITH(NOLOCK)" +
			" WHERE i.batch_id = b.batch_id" +
			" AND b.cust_id = " + sCustId +
			" AND i.status_id = " + ImportStatus.COMMIT_COMPLETE +
			" ORDER BY i.import_name";
	}
	else
	{
		sSql =
			" SELECT i.import_id, i.import_name" +
			" FROM cupd_import i WITH(NOLOCK), cupd_batch b WITH(NOLOCK), ccps_object_category oc WITH(NOLOCK)" +
			" WHERE i.batch_id = b.batch_id" +
			" AND b.cust_id = " + sCustId +
			" AND i.status_id = " + ImportStatus.COMMIT_COMPLETE +
			" AND oc.object_id = i.import_id" +
			" AND oc.type_id = " + ObjectType.IMPORT +
			" AND oc.cust_id = " + sCustId +
			" AND oc.category_id = "+sCategoryId + 
			" ORDER BY i.import_name";
	}
	return buildOptionsHtml(sSql);
}

private static JsonArray buildBatchOptionsHtml(String sCustId, String sCategoryId) throws Exception
{
	String sSql = null;
	if (sCategoryId == null)
	{
		sSql =
			" SELECT b.batch_id, b.batch_name" +
			" FROM cupd_batch b WITH(NOLOCK)" + 
			" WHERE ( (b.type_id = 1" + 
			" AND b.batch_id IN" +
				" (SELECT DISTINCT i.batch_id" +
				" FROM cupd_import i WITH(NOLOCK), cupd_batch b WITH(NOLOCK)" +
				" WHERE i.status_id = "+ UpdateStatus.COMMIT_COMPLETE +
				" AND i.batch_id = b.batch_id" +
				" AND b.cust_id = " + sCustId + "))" +
			" OR (b.type_id > 1) )" +
			" AND b.cust_id = " + sCustId +
			" ORDER BY b.type_id, b.batch_name";
	}
	else
	{
		sSql =
			" SELECT b.batch_id, b.batch_name" +
			" FROM cupd_batch b WITH(NOLOCK)" + 
			" WHERE ( (b.type_id = 1" + 
			" AND b.batch_id IN" +
				" (SELECT DISTINCT i.batch_id" +
				" FROM cupd_import i WITH(NOLOCK), cupd_batch b WITH(NOLOCK), ccps_object_category oc WITH(NOLOCK)" +
				" WHERE i.status_id = "+ UpdateStatus.COMMIT_COMPLETE +
				" AND i.batch_id = b.batch_id" +
				" AND b.cust_id = " + sCustId + 
				" AND oc.object_id = i.import_id" +
				" AND oc.type_id = " + ObjectType.IMPORT +
				" AND oc.cust_id = " + sCustId +
				" AND oc.category_id = "+sCategoryId + "))" +
			" OR (b.type_id > 1) )" +
			" AND b.cust_id = " + sCustId +
			" ORDER BY b.type_id, b.batch_name";
	}
	return buildOptionsHtml(sSql);
}

private static JsonArray buildCampOptionsHtml(String sCustId, String sCategoryId) throws Exception
{
	String sSql = null;
	if (sCategoryId == null)
	{
		sSql  =
			" SELECT camp_id, camp_name" +
			" FROM cque_campaign WITH(NOLOCK)" +
			" WHERE origin_camp_id IS NULL" +
			" AND cust_id = " + sCustId +
			" AND status_id <> " + CampaignStatus.DELETED +
			" ORDER BY camp_name";
	}
	else
	{
		sSql  =
			" SELECT c.camp_id, c.camp_name" +
			" FROM cque_campaign c WITH(NOLOCK), ccps_object_category oc WITH(NOLOCK)" +
			" WHERE c.origin_camp_id IS NULL" +
			" AND c.cust_id = " + sCustId +
			" AND c.status_id <> " + CampaignStatus.DELETED +
			" AND c.camp_id = oc.object_id" +
			" AND oc.type_id = " + ObjectType.CAMPAIGN +
			" AND oc.cust_id = " + sCustId +
			" AND oc.category_id = " + sCategoryId +
			" ORDER BY c.camp_name";
	}
	return buildOptionsHtml(sSql);	
}

private static JsonArray buildFormOptionsHtml(String sCustId, String sCategoryId) throws Exception
{
	String sSql =
		" SELECT form_id, form_name" +
		" FROM csbs_form WITH(NOLOCK)" +
		" WHERE cust_id = " + sCustId +
		" ORDER BY form_name";
	return buildOptionsHtml(sSql);	
}

private static JsonArray buildNewsletterOptionsHtml(String sCustId, String sCategoryId) throws Exception
{
	String sSql =
		" SELECT attr_id, display_name" +
		" FROM ccps_cust_attr WITH(NOLOCK)" +
		" WHERE cust_id = " + sCustId +
		" AND newsletter_flag IS NOT NULL" +
		" ORDER BY display_seq";
	
	return buildOptionsHtml(sSql);	
}

private static JsonArray buildContentBlockOptionsHtml(String sCustId, String sCategoryId) throws Exception
{
	String sSql = null;
	if (sCategoryId == null)
	{
		sSql  =
			" SELECT cont_id, cont_name" +
			" FROM ccnt_content WITH(NOLOCK)" +
			" WHERE origin_cont_id IS NULL" +
			" AND cust_id = " + sCustId +
			" AND type_id = " + ContType.PARAGRAPH +
			" AND status_id <> " + ContStatus.DELETED +
			" ORDER BY cont_name";
	}
	else
	{
		sSql  =
			" SELECT c.cont_id, c.cont_name" +
			" FROM ccnt_content c WITH(NOLOCK), ccps_object_category oc WITH(NOLOCK)" +
			" WHERE c.origin_cont_id IS NULL" +
			" AND c.cust_id = " + sCustId +
			" AND c.type_id = " + ContType.PARAGRAPH +
			" AND c.status_id <> " + ContStatus.DELETED +
			" AND c.cont_id = oc.object_id" +
			" AND oc.type_id = " + ObjectType.CONTENT +
			" AND oc.cust_id = " + sCustId +
			" AND oc.category_id = " + sCategoryId +
			" ORDER BY c.cont_name";
	}
 	return buildOptionsHtml(sSql);	
}

private static JsonArray buildLinkOptionsHtml(String sCustId, String sCategoryId) throws Exception
{
	String sSql = null;
						
	if (sCategoryId == null)
	{
		sSql =
			" SELECT link_id, '[' + c.camp_name + '] ' + link_name" +
			" FROM cjtk_link l WITH(NOLOCK), cque_campaign c WITH(NOLOCK)" +
			" WHERE" +
			//" (l.origin_link_id IS NULL) AND" +
			" l.href IS NOT NULL AND" +
			" l.cust_id = " + sCustId + " AND" +
			" l.cont_id = c.cont_id AND" +
			" c.origin_camp_id IS NOT NULL AND" +
			" c.type_id != 1" +
			" ORDER BY '[' + c.camp_name + '] ' + link_name";
	}
	else
	{
		sSql =
			" SELECT link_id, '[' + c.camp_name + '] ' + link_name" +
			" FROM cjtk_link l WITH(NOLOCK), cque_campaign c WITH(NOLOCK), ccps_object_category oc WITH(NOLOCK)" +
			" WHERE" +
			//" l.parent_link_id IS NULL AND" +
			" l.href IS NOT NULL" +
			" AND l.cust_id = " + sCustId +
			" AND l.cont_id = c.cont_id" +
			" AND c.origin_camp_id IS NOT NULL" +
			" AND c.type_id != 1" +
			" AND c.camp_id = oc.object_id" +
			" AND oc.type_id = " + ObjectType.CAMPAIGN +
			" AND oc.cust_id = " + sCustId +
			" AND oc.category_id = " + sCategoryId +
			" ORDER BY '[' + c.camp_name + '] ' + link_name";
	}
	return buildOptionsHtml(sSql);	
}

private static JsonArray buildFilterOptionsHtml(String sCustId, String sCategoryId) throws Exception
{
	String sSql = null;

	if (sCategoryId == null)
	{
		sSql  =
			" SELECT filter_id, filter_name" +
			" FROM ctgt_filter WITH(NOLOCK)" +
			" WHERE origin_filter_id IS NULL" +
			" AND len(filter_name) > 0" +
			" AND type_id = " + FilterType.MULTIPART +
			" AND cust_id = " + sCustId +
			" AND status_id != " + FilterStatus.DELETED +
			" AND ISNULL(usage_type_id,500) = " + FilterUsageType.REGULAR +
			" ORDER BY filter_name";
	}
	else
	{
		sSql  =
			" SELECT f.filter_id, f.filter_name" +
			" FROM ctgt_filter f WITH(NOLOCK), ccps_object_category oc WITH(NOLOCK)" +
			" WHERE f.origin_filter_id IS NULL" +
			" AND len(filter_name) > 0" +			
			" AND f.type_id = " + FilterType.MULTIPART +
			" AND f.cust_id = " + sCustId +
			" AND f.status_id != " + FilterStatus.DELETED +
			" AND ISNULL(f.usage_type_id,500) = " + FilterUsageType.REGULAR +
			" AND f.filter_id = oc.object_id" +
			" AND oc.type_id = " + ObjectType.FILTER +
			" AND oc.cust_id = " + sCustId +
			" AND oc.category_id = " + sCategoryId +
			" ORDER BY f.filter_name";
	}
	return buildOptionsHtml(sSql);	
}

private static JsonArray buildEntityOptionsHtml(String sCustId) throws Exception
{
	String sSql  =
			" SELECT e.entity_id, e.entity_name" +
			" FROM" +
			"	cntt_entity e," +
			"	cntt_entity_attr ea" +
			" WHERE e.cust_id = " + sCustId +
			" AND e.entity_id = ea.entity_id" +
			" AND ea.type_id = 1000";
        
	return buildOptionsHtml(sSql);	
}

private static JsonArray buildOptionsHtml(String sSql) throws Exception
{

	ConnectionPool cp = null;
	Connection conn = null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("select.jsp.buildOptionsHtml()");
		Statement stmt = null;
		try
		{
			stmt = conn.createStatement();
			return buildOptionsHtml(sSql,stmt);
		}
		catch(Exception ex) { throw ex; }
		finally { if(stmt != null) stmt.close(); }
	}
	catch(Exception ex) { throw ex; }
	finally { if(conn != null) cp.free(conn); }
}

private static JsonArray buildOptionsHtml(String sSql, Statement stmt) throws Exception
{
	JsonObject data = new JsonObject();
	JsonArray array = new JsonArray();
	
	String sId = null;
	byte[] b = null;	
	String sName = null;

	ResultSet rs = stmt.executeQuery(sSql);
	while (rs.next())
	{
		data = new JsonObject();
		sId = rs.getString(1);
		b = rs.getBytes(2);
		sName = (b==null)?null:new String(b, "UTF-8");

		data.put("id",sId);
		data.put("name",sName);
		array.put(data);
	}
	rs.close();

	if(array.length()==0) array.put("No data!");
	return array;

}
%>

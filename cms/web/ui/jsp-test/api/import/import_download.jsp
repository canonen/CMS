<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.upd.*,
			java.io.*,java.util.*,
			java.sql.*,java.net.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../../utilities/validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
    System.out.println("my test");
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.IMPORT);
/*
if(!can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
*/


ServletInputStream in = request.getInputStream();
HashMap aImportParameters = ImportUtil.downloadImport(in, cust.s_cust_id);
String sImportName = request.getParameter("import_name").toString().trim();
String sBatchId = request.getParameter("batch_id").toString().trim();
if ("null".equals(sBatchId)) sBatchId = null;

String sFieldSeparator = request.getParameter("delimiter").toString().trim();

String sFirstRow = request.getParameter("row").toString().trim();
String sImportFile = aImportParameters.get("server_file_name").toString().trim();
String sUpdRuleId = request.getParameter("upd_rule_id").toString().trim ();
String sFullNameFlag = request.getParameter("full_name_flag").toString().trim();
String sEmailTypeFlag = request.getParameter("email_type_flag").toString().trim ();
String sUpdHierarchyId = request.getParameter("upd_hierarchy_id").toString().trim();
String sMultiValueFieldSeparator = request.getParameter("multi_value_delimiter").toString().trim();
if("null".equals(sMultiValueFieldSeparator)) sMultiValueFieldSeparator = null;
if("".equals(sMultiValueFieldSeparator)) sMultiValueFieldSeparator = null;


String sBatchName = request.getParameter("batch_name").toString().trim();
String sBatchTypeId = request.getParameter("batch_type").toString().trim();


String sNewsletters = request.getParameter("newsletters").toString();
sNewsletters = (((sNewsletters!=null) && !sNewsletters.equals("null"))?sNewsletters.trim():"");



String sCategories = request.getParameter("category_temp").toString().trim();
String sSelectedCategoryId = null;
try
{
	sSelectedCategoryId = request.getParameter("category_id").toString().trim();
	if("null".equals(sSelectedCategoryId)) sSelectedCategoryId = null;
}
catch(Exception ex) {}

FieldsMappings fmFieldsMappings = new FieldsMappings();

String sFields = request.getParameter("fields").toString().trim ();

{
	String sFld;
	int nBegin=0, nEnd;
	for (int ind=0 ; ; ind ++ )
	{
		nEnd = sFields.indexOf (",", nBegin);
		if (nEnd == -1) sFld = sFields.substring (nBegin);
		else sFld = sFields.substring (nBegin, nEnd);

		if (sFld.trim().equals("")) break;

		FieldsMapping fm = new FieldsMapping();
		fm.s_attr_id = sFld;
		fm.s_seq = String.valueOf(ind);
		fmFieldsMappings.add(fm);

		if (nEnd == -1) break;
		nBegin = nEnd + 1;
	}
}
%>
<%@ include file="import_save_common.inc" %>

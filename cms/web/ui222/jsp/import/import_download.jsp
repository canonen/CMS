<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.upd.*,
			java.io.*,java.util.*,
			java.sql.*,java.net.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.IMPORT);

if(!can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

// === === ===

ServletInputStream in = request.getInputStream();
HashMap aImportParameters = ImportUtil.downloadImport(in, cust.s_cust_id);

%>
<!-- === === === -->
<%
String sImportName = aImportParameters.get("import_name").toString().trim();

String sBatchId = aImportParameters.get("batch_id").toString().trim();
if ("null".equals(sBatchId)) sBatchId = null;

String sFieldSeparator = aImportParameters.get("delimiter").toString().trim();

String sFirstRow = aImportParameters.get("row").toString().trim();
String sImportFile = aImportParameters.get("server_file_name").toString().trim();
String sUpdRuleId = aImportParameters.get("upd_rule_id").toString().trim ();
String sFullNameFlag = aImportParameters.get("full_name_flag").toString().trim();
String sEmailTypeFlag = aImportParameters.get("email_type_flag").toString().trim ();
String sUpdHierarchyId = aImportParameters.get("upd_hierarchy_id").toString().trim();
String sMultiValueFieldSeparator = aImportParameters.get("multi_value_delimiter").toString().trim();
if("null".equals(sMultiValueFieldSeparator)) sMultiValueFieldSeparator = null;
if("".equals(sMultiValueFieldSeparator)) sMultiValueFieldSeparator = null;

// === === ===

String sBatchName = aImportParameters.get("batch_name").toString().trim();
String sBatchTypeId = aImportParameters.get("batch_type").toString().trim();

// === === ===

String sNewsletters = aImportParameters.get("newsletters").toString();
sNewsletters = (((sNewsletters!=null) && !sNewsletters.equals("null"))?sNewsletters.trim():"");

// === === ===

String sCategories = aImportParameters.get("categorytemp").toString().trim();
String sSelectedCategoryId = null;
try
{
	sSelectedCategoryId = aImportParameters.get("category_id").toString().trim();
	if("null".equals(sSelectedCategoryId)) sSelectedCategoryId = null;
}
catch(Exception ex) {}
%>
<!-- === === === -->
<%

FieldsMappings fmFieldsMappings = new FieldsMappings();

String sFields = aImportParameters.get("fields").toString().trim ();

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
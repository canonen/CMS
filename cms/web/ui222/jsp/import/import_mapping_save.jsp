<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.upd.*,
			com.britemoon.cps.imc.*,
			java.io.*,java.util.*,
			java.sql.*,java.net.*,
			javax.servlet.http.*,
			javax.servlet.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
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

String sImportName = BriteRequest.getParameter(request,"import_name");

String sBatchId = BriteRequest.getParameter(request,"batch_id");
if ("null".equals(sBatchId)) sBatchId = null;

String sFieldSeparator = BriteRequest.getParameter(request,"delimiter");

String sFirstRow = BriteRequest.getParameter(request,"row");
String sImportFile = BriteRequest.getParameter(request,"server_file_name");
String sUpdRuleId = BriteRequest.getParameter(request,"upd_rule_id");
String sFullNameFlag = BriteRequest.getParameter(request,"full_name_flag");
String sEmailTypeFlag = BriteRequest.getParameter(request,"email_type_flag");
String sUpdHierarchyId = BriteRequest.getParameter(request,"upd_hierarchy_id");
String sMultiValueFieldSeparator =  BriteRequest.getParameter(request,"multi_value_delimiter");
if("null".equals(sMultiValueFieldSeparator)) sMultiValueFieldSeparator = null;

// === === ===

String sBatchName = BriteRequest.getParameter(request,"batch_name");
String sBatchTypeId = BriteRequest.getParameter(request,"batch_type");

// === === ===

String sNewsletters = BriteRequest.getParameter(request,"newsletters");
sNewsletters = (((sNewsletters!=null) && !sNewsletters.equals("null"))?sNewsletters.trim():"");

// === === ===

String sCategories = BriteRequest.getParameter(request,"categorytemp");
String sSelectedCategoryId = null;
try
{
	sSelectedCategoryId = BriteRequest.getParameter(request,"category_id");
	if("null".equals(sSelectedCategoryId)) sSelectedCategoryId = null;
}
catch(Exception ex) {}

// === === ===

FieldsMappings fmFieldsMappings = new FieldsMappings();

String sNumCols = BriteRequest.getParameter(request,"num_fields");
int nCols = Integer.parseInt(sNumCols);
String sFields = "";

for (int j=1; j <= nCols; j++)
{
	FieldsMapping fm = new FieldsMapping();
	fm.s_attr_id = BriteRequest.getParameter(request,"attr"+j);
	fm.s_seq = String.valueOf(j);
	fmFieldsMappings.add(fm);
		
	sFields += ( (sFields.length() > 0)?",":"" ) + fm.s_attr_id;
}
%>
<%@ include file="import_save_common.inc" %>
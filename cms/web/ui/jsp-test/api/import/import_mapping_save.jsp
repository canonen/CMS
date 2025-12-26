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
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}


//System.out.println(session.getAttribute("cust")+"my cust id");

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

String sNumCols = BriteRequest.getParameter(request,"nums_fields");
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

Import imp = new Import();

imp.s_import_id = null;
imp.s_import_name = sImportName;
imp.s_batch_id = sBatchId;

imp.s_status_id = String.valueOf(ImportStatus.DOWNLOADED);
imp.s_import_date = null;
if(sFieldSeparator.equals("tab")){
    sFieldSeparator = "\\t";
}
if(sFieldSeparator.equals("pipe")){
    sFieldSeparator = "|";
}
if(sFieldSeparator.equals("semicolon")){
    sFieldSeparator = ";";
}
if(sFieldSeparator.equals("comma")){
    sFieldSeparator = ",";
}
imp.s_field_separator = sFieldSeparator;
imp.s_first_row = sFirstRow;
imp.s_import_file = sImportFile;
imp.s_upd_rule_id = sUpdRuleId;
imp.s_import_url = Registry.getKey("import_url_dir");
imp.s_full_name_flag = sFullNameFlag;
imp.s_email_type_flag = sEmailTypeFlag;
imp.s_type_id = null;
imp.s_upd_hierarchy_id = sUpdHierarchyId;
imp.s_auto_commit_flag = null;
imp.s_multi_value_field_separator = sMultiValueFieldSeparator;


if( imp.s_batch_id == null )
{
	Batch batch = new Batch();

	batch.s_batch_id = null;
	batch.s_batch_name = sBatchName;
	batch.s_cust_id = request.getParameter("cust_id");
	batch.s_type_id = sBatchTypeId;
	batch.s_descrip = null;

	imp.m_Batch = batch;
}

imp.m_FieldsMappings = fmFieldsMappings;


{
	String sFld = null;

	int nBegin = 0;
	int nEnd = 0;
	if (sNewsletters.length() > 0)
	{
		ImportNewsletters inls = new ImportNewsletters();
		for (int ind=0 ; ; ind ++ )
		{
			nEnd = sNewsletters.indexOf (",", nBegin);

			if (nEnd == -1) sFld = sNewsletters.substring (nBegin);
			else sFld = sNewsletters.substring(nBegin, nEnd);

			sFld = sFld.trim();
			if ("".equals(sFld)) break;

			ImportNewsletter inl = new ImportNewsletter();
			inl.s_attr_id = sFld;
			inls.add(inl);

			if (nEnd == -1) break;
			nBegin = nEnd + 1;
		}

		imp.m_ImportNewsletters = inls;
	}
}


try
{
	imp.save();
	ImportUtil.setupRCP(imp.s_import_id);
	out.print("success");
}
catch(Exception ex)
{
	if(imp.s_import_id != null)
	{
		String sSql =
			" UPDATE cupd_import" +
			" SET status_id = " + ImportStatus.ERROR +
			" WHERE import_id = " + imp.s_import_id;

		BriteUpdate.executeUpdate(sSql);
	}

	throw ex;
}

saveCategories(request.getParameter("cust_id"), imp.s_import_id, sCategories);

%>
<%!
private static void saveCategories(String sCustId, String sImportId, String sCategories)
{
	if(sCategories == null) return;
	if(sCategories.trim().equals("")) return;

	String[] sCatsArray = sCategories.split(",");
	if(sCatsArray == null) return;

	int l = sCatsArray.length;
	if(l <= 0) return;

	// === === ===

	ConnectionPool cp = null;
	Connection conn = null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("import_save.jsp");

		String sSql =
			" INSERT ccps_object_category (cust_id,  object_id, type_id, category_id)" +
			" VALUES (?, ?, ?, ?)";

		PreparedStatement pstmt = null;

		for(int i=0; i<l ;i++)
		{
			try
			{
				pstmt = conn.prepareStatement(sSql);
				pstmt.setString(1, sCustId);
				pstmt.setString(2, sImportId);
				pstmt.setString(3, String.valueOf(ObjectType.IMPORT));
				pstmt.setString(4, sCatsArray[i]);
				pstmt.executeUpdate();
			}
			catch(Exception exx) { throw exx; }
			finally { if(pstmt != null) pstmt.close(); }
		}
	}
	catch(Exception ex) { logger.error("Exception",ex); }
	finally { if(conn != null) cp.free(conn); }
}
%>

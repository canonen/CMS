<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.upd.*, 
			com.britemoon.cps.ftp.*, 
			java.io.*, 
			java.text.*, 
			java.sql.*, 
			java.util.*, 
			org.w3c.dom.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
%>
<%@ include file="../header.jsp"%>
<%
	String sTemplateId = BriteRequest.getParameter(request,"template_id");
	String sCustId = BriteRequest.getParameter(request,"cust_id");

	// === === ===

	ImportTemplate it = new ImportTemplate();

	it.s_template_id = BriteRequest.getParameter(request,"template_id");
	it.s_template_name = BriteRequest.getParameter(request,"template_name");	
	it.s_type_id = BriteRequest.getParameter(request,"import_type_id");
	it.s_batch_id = BriteRequest.getParameter(request,"batch_id");
	it.s_first_row = BriteRequest.getParameter(request,"first_row");
	it.s_field_separator = BriteRequest.getParameter(request,"field_separator");
	it.s_upd_rule_id = BriteRequest.getParameter(request,"upd_rule_id");
	it.s_full_name_flag = BriteRequest.getParameter(request,"full_name_flag");
	it.s_email_type_flag = BriteRequest.getParameter(request,"email_type_flag");
	it.s_upd_hierarchy_id = BriteRequest.getParameter(request,"upd_hierarchy_id");
	it.s_auto_commit_flag = BriteRequest.getParameter(request,"auto_commit_flag");
	it.s_multi_value_field_separator = BriteRequest.getParameter(request,"multi_value_field_separator");
	it.s_name_import_as_file_flag = BriteRequest.getParameter(request,"name_import_as_file_flag");
	it.s_filter_per_import_flag = BriteRequest.getParameter(request,"filter_per_import_flag");

	// === === ===
	
	if( it.s_batch_id == null )
	{
		Batch b = new Batch();

		b.s_batch_id = BriteRequest.getParameter(request,"batch_id");
		b.s_type_id = BriteRequest.getParameter(request,"batch_type_id");
		if(	b.s_type_id == null ) b.s_type_id = "1";
		b.s_cust_id = BriteRequest.getParameter(request,"cust_id");
		b.s_batch_name = BriteRequest.getParameter(request,"batch_name");
		b.s_descrip = BriteRequest.getParameter(request,"descrip");

		it.m_Batch = b;
	}

	// === === ===
	
	String[] sImportTemplateAttrs = BriteRequest.getParameterValues(request,"import_template_attrs");
	
	if(sImportTemplateAttrs != null)
	{
		ImportTemplateAttrs itas = new ImportTemplateAttrs();
	
		for(int i=0; i < sImportTemplateAttrs.length; i++)
		{
			ImportTemplateAttr ita = new ImportTemplateAttr();
			ita.s_attr_id = sImportTemplateAttrs[i];
			ita.s_seq = String.valueOf(i);
			itas.add(ita);
		}
		
		it.m_ImportTemplateAttrs = itas;
	}
	
	// === === ===
	
	it.save();
%>
<%@ include file="../header.jsp"%>
<HTML>
<HEAD>
<title>FTP Imports</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>
<BODY>
<BR><BR>
<A href="import_template_edit.jsp?template_id=<%=it.s_template_id%>">Edit saved Import Template</A>
<BR><BR>
<A href="import_template_list.jsp">Import Template List</A>
</BODY>
</HTML>
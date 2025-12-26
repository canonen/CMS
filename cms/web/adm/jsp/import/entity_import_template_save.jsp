<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.ntt.*, 
			java.io.*, 
			java.text.*, 
			java.sql.*, 
			java.util.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp"%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	
	String sTemplateId = BriteRequest.getParameter(request,"template_id");
	String sEntityId = BriteRequest.getParameter(request,"entity_id");

	// === === ===

	Entity e = new Entity(sEntityId);
	EntityImportTemplate eit = new EntityImportTemplate();

	eit.s_template_id = BriteRequest.getParameter(request,"template_id");
	eit.s_template_name = BriteRequest.getParameter(request,"template_name");	

	eit.s_cust_id = e.s_cust_id;
	eit.s_entity_id = e.s_entity_id;

	eit.s_first_row = BriteRequest.getParameter(request,"first_row");
	eit.s_field_separator = BriteRequest.getParameter(request,"field_separator");

	// === === ===
	
	String[] sEntityImportTemplateAttrs = BriteRequest.getParameterValues(request,"entity_import_template_attrs");
	
	if(sEntityImportTemplateAttrs != null)
	{
		EntityImportTemplateAttrs eitas = new EntityImportTemplateAttrs();
	
		for(int i=0; i < sEntityImportTemplateAttrs.length; i++)
		{
			EntityImportTemplateAttr eita = new EntityImportTemplateAttr();
			eita.s_attr_id = sEntityImportTemplateAttrs[i];
			eita.s_seq = String.valueOf(i);
			eitas.add(eita);
		}
		
		eit.m_EntityImportTemplateAttrs = eitas;
	}
	
	// === === ===
	
	eit.save();
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
<A href="entity_import_template_edit.jsp?template_id=<%=eit.s_template_id%>">Edit saved Entity Import Template</A>
<BR><BR>
<A href="entity_import_template_list.jsp">Entity Import Template List</A>
</BODY>
</HTML>
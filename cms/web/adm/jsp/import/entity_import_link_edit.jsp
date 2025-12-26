<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.jtk.*, 
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
	String sLinkId = BriteRequest.getParameter(request,"link_id");
	String sEntityId = BriteRequest.getParameter(request,"entity_id");

	if((sLinkId == null)&&(sEntityId == null)) return;

	Link link = null;

	if(sLinkId != null)
	{
		link = new Link(sLinkId);
	}
	else
	{
		link = new Link();
		link.s_entity_id = sEntityId;
	}

	Entity e = new Entity(link.s_entity_id);
	Customer cust = new Customer(e.s_cust_id);
%>
<HTML>
<HEAD>
<title>Entity Import Link Edit</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>
<BODY>
<FORM action='entity_import_link_save.jsp' method=POST>
<INPUT type='hidden' name='link_id' value='<%=HtmlUtil.escape(link.s_link_id)%>'>
<INPUT type='hidden' name='entity_id' value='<%=HtmlUtil.escape(e.s_entity_id)%>'>
<INPUT type='submit' value='Save'>
<H4>Customer: <%=cust.s_cust_name%> (ID = <%=cust.s_cust_id%>)</H4>
<H4>Entity: <%=e.s_entity_name%> (ID = <%=e.s_entity_id%>)</H4>
<H4>Link name: <INPUT type="text" name="link_name" value="<%=HtmlUtil.escape(link.s_link_name)%>"> (ID = <%=link.s_link_id%>)</H4>		
<BR><BR>
<PRE>
Predefined POS parameter names provided by :
	BrLk - this link id
	BrCs - customer id
	BrCg - campaign id
	BrRc - recipient id
	Referer - referer
</PRE>
<TABLE cellpadding=1 cellspacing=0 border=1>
<%

	EntityAttrs eas = new EntityAttrs();
	eas.m_sRetrieveSql = "EXEC usp_cntt_entity_attrs_4_import_get @entity_id=" + e.s_entity_id;
	eas.retrieve();
	
	EntityAttr ea = null;
	EntityImportLinkAttr eila = null;	
	for(Enumeration en = eas.elements(); en.hasMoreElements(); )
	{
		ea = (EntityAttr) en.nextElement();
		eila = new EntityImportLinkAttr(link.s_link_id, ea.s_attr_id);
%>
	
	<TR>
		<TD>Attribute</TD>
		<TD><INPUT type="text" name="attr_id" size="5" readonly value="<%=HtmlUtil.escape(ea.s_attr_id)%>"></TD>
		<TD><INPUT type="text" name="attr_name" readonly value="<%=HtmlUtil.escape(ea.s_attr_name)%>"></TD>
		<TD>Link parameter name:</TD>
		<TD><INPUT type="text" name="param_name" value="<%=HtmlUtil.escape(eila.s_param_name)%>"></TD>
	</TR>
<%
	}
%>
</TABLE>
</FORM>

</BODY>
</HTML>

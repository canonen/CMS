<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.ntt.*, 
			com.britemoon.cps.jtk.*, 
			com.britemoon.cps.imc.*, 
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

	// === === ===

	Entity e = new Entity(sEntityId);
	Link link = new Link();

	link.s_link_id = BriteRequest.getParameter(request,"link_id");
	link.s_link_name = BriteRequest.getParameter(request,"link_name");	

	link.s_cust_id = e.s_cust_id;
	link.s_entity_id = e.s_entity_id;

	// === === ===
	
	String[] sAttrIds = BriteRequest.getParameterValues(request,"attr_id");
	String[] sParamNames = BriteRequest.getParameterValues(request,"param_name");	
	
	EntityImportLinkAttrs eilas = new EntityImportLinkAttrs();

	for(int i=0; i < sAttrIds.length; i++)
	{
		if(sParamNames[i] == null) continue;
		 
		EntityImportLinkAttr eila = new EntityImportLinkAttr();
		eila.s_attr_id = sAttrIds[i];
		eila.s_param_name = sParamNames[i];
		eilas.add(eila);
	}
	
	link.m_EntityImportLinkAttrs = eilas;
	link.save();
	
	// === === ===

	Links links = new Links();
	links.add(link);
	
	Service.notify(ServiceType.RJTK_CAMP_LINK_SETUP, e.s_cust_id, links.toXml());
	
	// === === ===

	link.m_EntityImportLinkAttrs = null;

	String sJtkResponse = Service.communicate(ServiceType.AJTK_CONTENT_LINK_SETUP, e.s_cust_id, links.toXml());
	String sErrorMsg = XmlUtil.getChildCDataValue(XmlUtil.getRootElement(sJtkResponse), "error");
	if(sErrorMsg != null) throw new Exception(sErrorMsg);
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
<A href="entity_import_link_edit.jsp?link_id=<%=link.s_link_id%>">Edit saved Entity Import Link</A>
<BR><BR>
<A href="entity_import_link_list.jsp">Entity Import Link List</A>
</BODY>
</HTML>
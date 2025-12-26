<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="com.britemoon.sas.imc.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.w3c.dom.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.britemoon.cps.BriteRequest" %>
<%@ page import="com.britemoon.cps.Module" %>
<%@ page import="com.britemoon.cps.ServiceType" %>
<%@ page import="com.britemoon.cps.XmlUtil" %>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../../header.jsp"%>
<HTML>
<HEAD>
	<%@ include file="../../header.html" %>
	<TITLE>Module Synchronization</TITLE>
	<META http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<link rel="stylesheet" type="text/css" href="../../../css/style.css">
</HEAD>
<BODY>
<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
	<col>
	<tr height="125">
		<td valign="top">
			<table cellspacing="0" cellpadding="0" border="0" width="100%">
				<tr>
					<td valign="top">
<%
try
{
	String sCustId = BriteRequest.getParameter(request, "cust_id");
	String sModInstId = BriteRequest.getParameter(request, "mod_inst_id");	//104 and 138

	if((sCustId == null) || (sModInstId == null))
	{
		out.println("No cust_id or mod_inst_id in request");
		return;
	}

	Customer cust = new Customer(sCustId);
	%>
						<table cellpadding="3" cellspacing="0" border="0" class="listTable" width="100%">
							<tr>
								<th colspan="2">Customer</th>
							</tr>
							<tr>
								<td class="listItem_Data"><b>ID: </b></td>
								<td class="listItem_Data"><%= cust.s_cust_id %></td>
							</tr>
							<tr>
								<td class="listItem_Data"><b>Name: </b></td>
								<td class="listItem_Data"><%= cust.s_cust_name %></td>
							</tr>
						</table>
					</td>
					<td>&nbsp;&nbsp;&nbsp;</td>
	<%
	out.flush();
	
	ModInst mi = new ModInst(sModInstId);
	if      (Integer.parseInt(mi.s_mod_id) == Module.AINB) CustRetrieveUtil.retrieve4inb(cust);
	else if (Integer.parseInt(mi.s_mod_id) == Module.CCPS) CustRetrieveUtil.retrieve4cps(cust);
        else                                                   CustRetrieveUtil.retrieveFull(cust);
		
	Vector services = Services.get(ServiceType.CUST_SETUP, sModInstId, cust.s_cust_id);
	Service service = (Service) services.get(0);
%>
					<td valign="top">
						<table cellpadding="3" cellspacing="0" border="0" class="listTable" width="100%">
							<tr>
								<th colspan="2">Remote Service Requested</th>
							</tr>
							<tr>
								<td class="listItem_Data"><b>Type ID: </b></td>
								<td class="listItem_Data"><%= service.s_type_id %></td>
							</tr>
							<tr>
								<td class="listItem_Data"><b>Module Instance ID: </b></td>
								<td class="listItem_Data"><%= service.s_mod_inst_id %></td>
							</tr>
							<tr>
								<td class="listItem_Data"><b>Cust ID: </b></td>
								<td class="listItem_Data"><%= service.s_cust_id %> (null if not customer specific)</td>
							</tr>
							<tr>
								<td class="listItem_Data"><b>URL: </b></td>
								<td class="listItem_Data"><%= service.getURL() %></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
<%
	out.flush();
	
	String sRequest = null;
	String sResponse = null;
	Exception ex = null;

	try
	{
		sRequest = cust.toXml();
		service.connect();
		service.send(sRequest);
		sResponse = service.receive();
		
		Element eResponse = XmlUtil.getRootElement(sResponse);

		if(Integer.parseInt(mi.s_mod_id) == Module.CCPS)
		{
			cust = new Customer(eResponse);
			sResponse = cust.toXml();
		}
	}
	catch(Exception e) {ex = e;}
	finally { service.disconnect();}
%>
	<tr>
		<td>
			<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
				<col>
				<col width="5">
				<col>
				<tr height="22">
					<th>Sent</th>
					<td></td>
					<th>Received</th>
				</tr>
				<tr>
					<td>
						<TEXTAREA id=request rows=24 style="width:100%; height:100%;"><%=(sRequest==null)?sRequest:BriteObject.toXmlNice(sRequest)%></TEXTAREA>
					</td>
					<td></td>
					<td>
						<TEXTAREA id=response rows=24 style="width:100%; height:100%;"><%=(sResponse==null)?sResponse:BriteObject.toXmlNice(sResponse)%></TEXTAREA>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<%
	out.flush();
	if(ex != null) throw ex;
}
catch(Exception e)
{
	out.flush();
	out.println("<PRE>");
	e.printStackTrace(new PrintWriter(out));
	out.println("</PRE>");
	out.flush();
	throw e;
}
%>
</BODY>
</HTML>

<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.io.*,java.sql.*,
			java.util.*,java.sql.*,
			org.w3c.dom.*,org.apache.log4j.*"
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

	String sCustId = request.getParameter("cust_id");

	Customer cSuper = ui.getSuperiorCustomer();
	Customer cActive = ui.getActiveCustomer();

	boolean bDoRefresh = false;
	if(sCustId != null)
	{
		cActive = ui.setActiveCustomer(session, sCustId);
		bDoRefresh = true;
	}
	
	boolean isHyatt = ui.getFeatureAccess(Feature.HYATT);
%>
<HTML>
<HEAD>
<TITLE>Switch Customer</TITLE>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%= ui.s_css_filename %>" TYPE="text/css">
</HEAD>
<BODY style="padding:0px;" onload="parent.isReady = true;">
<%
if(bDoRefresh)
{
	%>
	<SCRIPT>
		if(opener!=null) opener.parent.parent.location.reload();
		window.close();
	</SCRIPT>	
	<%
}
else
{
	%>
<table cellspacing="1" cellpadding="0" border="0" class="main layout" style="width;100%; height:100%;">
	<col>
	<tr height="24">
		<th align="center" valign="middle">
			Click on the name of a system to log in. The current system is in bold.
		</th>
	</tr>
	<tr>
		<td>
			<div style="width:100%; height:100%; overflow:auto;">
			<table cellspacing=0 cellpadding=2 border=0 style="width:100%;" id="folderTable" class="layout">
				<col width="10">
				<col>
				<%= drawCustTree(cSuper, cActive, 0, isHyatt) %>
			</table>
			</div>
		</td>
	</tr>
</table>
	<%
}
%>
</BODY>
</HTML>
<%!
private String drawCustTree(Customer c, Customer cSelected, int iIndent, boolean isHyatt) throws Exception
{
	String sCustHTML = "";
	
	int tmpStatus = Integer.parseInt(c.s_status_id);
	
	if (tmpStatus == CustStatus.ACTIVATED)
	{
		sCustHTML += "<tr height=22>\n";
		sCustHTML += "<td align=left valign=middle>&nbsp;</td>\n";
		sCustHTML += "<td cust_id=\"" + c.s_cust_id + "\"";// onmouseover=\"on();\" onmouseout=\"off();\"";
		sCustHTML += " class=listItem_Data align=left valign=middle";
		sCustHTML += " style=\"cursor:hand; padding-left:3px;";

		if (c == cSelected)
		{
			sCustHTML += " font-weight:bold;";
		}

		sCustHTML += "\">";// onclick=\"switchCust();\">";

		if (isHyatt) sCustHTML += c.s_login_name;
		else sCustHTML += c.s_cust_name;

		sCustHTML += "</td>\n";
		sCustHTML += "</tr>\n";

		Customers custs = c.m_Customers;
		if(custs != null)
		{
			iIndent++;
			sCustHTML += "<tr>\n";
			sCustHTML += "<td align=left valign=middle>&nbsp;</td>\n";
			sCustHTML += "<td align=left valign=top>\n";
			sCustHTML += "<table cellspacing=0 cellpadding=0 border=0 class=\"layout\" style=\"width: 100%;\">\n";
			sCustHTML += "<col width=10>\n";
			sCustHTML += "<col>\n";

			Enumeration e = custs.elements();
			while(e.hasMoreElements())
			{
				sCustHTML += drawCustTree((Customer) e.nextElement(), cSelected, iIndent, isHyatt);
			}

			sCustHTML += "</table>\n</td>\n</tr>\n";

			return sCustHTML;
		}
		else
		{
			return sCustHTML;
		}
	}
	else
	{
		return sCustHTML;
	}
}
%>


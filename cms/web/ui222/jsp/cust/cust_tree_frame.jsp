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
	String sAction = request.getParameter("action");

	Customer cSuper = ui.getSuperiorCustomer();
	Customer cActive = ui.getActiveCustomer();
	Customer cDestination = ui.getDestinationCustomer();

	boolean bDoRefresh = false;
	if((sCustId != null)&&(sAction != null))
	{
		if(("active".equals(sAction))&&(!sCustId.equals(cActive.s_cust_id)))
		{
			cActive = ui.setActiveCustomer(session, sCustId);
			bDoRefresh = true;
		}


		if(("destination".equals(sAction))&&(!sCustId.equals(cDestination.s_cust_id)))
			cDestination = ui.setDestinationCustomer(session, sCustId);
	}
%>

<HTML>

<HEAD>
<TITLE>Customer Tree</TITLE>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>

<BODY leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<%
if(bDoRefresh)
{
	%>
	<SCRIPT> if(parent!=null) parent.location.href = parent.location.href; </SCRIPT>
	<%
}
else
{
	%>
<table border=0 cellspacing=3 cellpadding=0 align=center>
	<tr>
		<td align=center valign=middle>
			You are currently logged into: <b><%= cActive.s_cust_name %></b><br>
			Using the "Clone to Destination" feature will clone an item to: <b><%= cDestination.s_cust_name %></b>
		</td>
	</tr>
	<tr>
		<%
		drawCustTree(cSuper, out, cActive, cDestination);
		%>
	</tr>
</table>
	<%
}
%>
</BODY>
</HTML>

<%!
private void drawCustTree(Customer c, JspWriter out, Customer cActive, Customer cDestination) throws Exception
{

	out.println("<td align=center valign=top class=" + ((c==cActive)?"active_":"") + ((c==cDestination)?"destination_":"") + "customer>");
	out.println("	<table border=0 cellspacing=0 cellpadding=0 align=center>");
	out.println("		<tr>");
	out.println("			<td align=center nowrap>");
	out.println("				<input type=radio name=clone2dest" + ((c==cDestination)?" checked=true":"") + " onclick=\"location.href='cust_tree_frame.jsp?action=destination&cust_id=" + c.s_cust_id + "'\">");
	out.println("			</td>");
	out.println("			<td align=left>" + c.s_cust_name +"</td>");
	out.println("		</tr>");
	out.println("		<tr" + ((c==cActive)?" style=\"display:none;\"":"") + ">");
	out.println("			<td colspan=2 align=center nowrap>");
	out.println("				<a class=subactionbutton href=\"cust_tree_frame.jsp?action=active&cust_id=" + c.s_cust_id + "\">LogIn</a>");
	out.println("			</td>");
	out.println("		</tr>");
	out.println("	</table>");

	Customers custs = c.m_Customers;
	if(custs != null)
	{
		out.println("<table border=0 cellspacing=3 cellpadding=0 align=center>");
		out.println("	<tr>");
			
		Enumeration e = custs.elements();
		while(e.hasMoreElements())
		{
			drawCustTree((Customer) e.nextElement(), out, cActive, cDestination);
		}
				
		out.println("	</tr>");
		out.println("</table>");
	}

	out.println("</td>");

}
%>



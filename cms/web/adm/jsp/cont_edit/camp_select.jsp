<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			java.sql.*, 
			java.util.*, 
			org.w3c.dom.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<%@ include file="../header.jsp"%>

<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>
<BODY>

<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	String sCustId = request.getParameter("cust_id");
	Customer cust = new Customer(sCustId);
%>
<H3>Customer: <%=cust.s_cust_name%> (<%=cust.s_cust_id%>)</H3>

<FORM ACTION="cont_compare.jsp" METHOD="POST">
<TABLE>
	<TR>
		<TD>
<%
String sSql =
	" SELECT camp_id, camp_name" +
	" FROM cque_campaign WITH(NOLOCK)" +
	" WHERE type_id = 1 AND status_id = 60" +
	" AND origin_camp_id IS NOT NULL AND cust_id = " + cust.s_cust_id +
	" ORDER BY camp_name, camp_id";	
%>
			<SELECT name="s_camp_id">
				<OPTION>Select test SAAB campaign to take content FROM ...</OPTION>
<%@ include file="camp_list.inc" %>
			</SELECT>
			<BR><BR>
<%
sSql =
	" SELECT camp_id, camp_name" +
	" FROM cque_campaign WITH(NOLOCK)" +
	" WHERE type_id != 1 AND status_id < 60" +
	" AND origin_camp_id IS NOT NULL AND cust_id = " + cust.s_cust_id +
	" ORDER BY camp_name, camp_id";
%>
			<SELECT name="d_camp_id">
				<OPTION>Select running SAAB campaign to make replacements IN ...</OPTION>
<%@ include file="camp_list.inc" %>
			</SELECT>
		</TD>
		<TD>
			<INPUT type="submit" value="Next >>">
		</TD>		
	</TR>
</TABLE>
</FORM>

</BODY>
</HTML>
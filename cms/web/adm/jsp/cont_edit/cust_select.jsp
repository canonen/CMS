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
<%! static Logger logger = null;%>
<%@ include file="../header.jsp"%>

<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>
<BODY>

<H3>Select customer:</H3>

<FORM ACTION="camp_select.jsp" METHOD="POST">
	<SELECT name="cust_id">
		<OPTION>Select SAAB customer</OPTION>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
	ConnectionPool cp = null;
	Connection conn = null;
	Statement stmt = null;

	try
	{
		String sSql =
			" SELECT cust_id, cust_name" +
			" FROM ccps_customer WITH(NOLOCK)" +
			" WHERE cust_id != 0" +
			" ORDER BY cust_name, cust_id";	

		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();

		ResultSet rs = stmt.executeQuery(sSql);
		
		String sCustId = null;
		String sCustName = null;	
		while(rs.next())
		{
			sCustId = rs.getString(1);
			sCustName = rs.getString(2);		
%>
<OPTION value="<%=sCustId%>"> <%=HtmlUtil.escape(sCustName)%> ( <%=sCustId%> ) </OPTION>	
<%
		}
		rs.close();
	}
	catch(Exception ex) { throw ex; }
	finally
	{
		try { if (stmt != null) stmt.close(); }
		catch(Exception exx) 
		{ 
			logger.error("Exception: ",exx); 
		}
		if (conn != null) cp.free(conn);
	}
%>
	</SELECT>
	<INPUT type="submit" value="Next >>">	
</FORM>

</BODY>
</HTML>
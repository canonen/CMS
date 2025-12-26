<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.upd.*, 
			java.io.*, 
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
<title>FTP Imports</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>
<BODY>

<FORM action="entity_import_link_edit.jsp">
	Create new Entity Import Link:
	<SELECT name="entity_id">
		<OPTION></OPTION>
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
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();
	
	String sSql =
		" SELECT c.cust_id, c.cust_name, e.entity_id, e.entity_name" +
		" FROM ccps_customer c, cntt_entity e" +
		" WHERE c.cust_id != 0 AND" +
		" e.cust_id = c.cust_id" +
		" ORDER BY cust_name, entity_name";
		
	ResultSet rs = stmt.executeQuery(sSql);	
	
	String sCustId = null;
	String sCustName = null;
	String sEntityId = null;
	String sEntityName = null;
	String sLabel = null;	
	while(rs.next())
	{
		sCustId = rs.getString(1);
		sCustName = rs.getString(2);
		sEntityId = rs.getString(3);
		sEntityName = rs.getString(4);
		
		sLabel = sCustName + " (" + sCustId + ") . " + sEntityName + " (" + sEntityId + ")";
%>
	<OPTION value="<%=sEntityId%>"><%=HtmlUtil.escape(sLabel)%></OPTION>
<%	
	}
	rs.close();
%>
	</SELECT>
	<INPUT type="submit" value="GO ..."%>
</FORM>
<BR>
<TABLE border=1 cellspacing=0 cellpadding=1>
	<TR>
		<TH>Edit</TH>
		<TH>link_id</TH>
		<TH>link_name</TH>		
		<TH>cust_id</TH>
		<TH>cust_name</TH>
		<TH>entity_id</TH>
		<TH>entity_name</TH>
	</TR>
<%
	String sql =
		" SELECT" +
		"	l.link_id,"+		
		"	l.link_name,"+		
		"	c.cust_id," + 
		"	c.cust_name," +
		" 	e.entity_id," +
		" 	e.entity_name" +
		" FROM" +
		" 	ccps_customer c," +		
		" 	cntt_entity e," +				
		" 	cjtk_link l" +
		" WHERE" +
		" 	c.cust_id = l.cust_id AND" +
		"	e.entity_id = l.entity_id" +
		" ORDER BY l.link_id";

		rs = stmt.executeQuery(sql);
		String sLinkId = null;
		String sData = null;		
		while(rs.next())
		{
			sLinkId = rs.getString(1);
%>
	<TR>
		<TD><A href="entity_import_link_edit.jsp?link_id=<%=sLinkId%>">Edit</A></TD>
		<TD><%=sLinkId%></TD>
<%
			for(int i=2; i < 7; i++)
			{
				sData = rs.getString(i);
				if(sData == null) sData = "null";
%>
		<TD nowrap><%=HtmlUtil.escape(sData)%></TD>
<%
			}
%>
	</TR>
<%
		}
		rs.close();
	}
	catch (Exception ex)
	{
		logger.error("Exception: ", ex);
		out.println("<PRE>");
		ex.printStackTrace(new PrintWriter(out));
		out.println("</PRE>");
	}
	finally
	{
		if (stmt!=null) stmt.close();
		if (conn!=null) cp.free(conn);			
	}
%>
</TABLE>
</BODY>
</HTML>

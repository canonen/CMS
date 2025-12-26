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

<FORM action="ftp_task_edit.jsp">
	Create new FTP task for customer:
	<SELECT name="cust_id">
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
		" SELECT cust_id, cust_name" +
		" FROM ccps_customer" +
		" WHERE cust_id != 0";
		
	ResultSet rs = stmt.executeQuery(sSql);	
	
	String sCustId = null;
	String sCustName = null;	
	while(rs.next())
	{
		sCustId = rs.getString(1);
		sCustName = rs.getString(2);
%>
	<OPTION value="<%=sCustId%>"><%=HtmlUtil.escape(sCustName)%> (<%=sCustId%>)</OPTION>
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
		<TH>History</TH>
		<TH>Edit</TH>
		<TH>task_id</TH>
		<TH>task_name</TH>
		<TH>server</TH>
		<TH>directory</TH>
		<TH>username</TH>
		<TH>password</TH>
		<TH>filename_prefix</TH>
		<TH>filename_suffix</TH>
		<TH>date_format</TH>
		<TH>pgp_flag</TH>
		<TH>next_start_date</TH>
		<TH>next_start_interval</TH>
		<TH>linked_task_id</TH>		
	</TR>
<%
	String sql =
		" SELECT" +
		" 	ft.task_id," +
		" 	ft.task_name," +		
		" 	ft.server," +
		" 	ft.directory," +
		" 	ft.username," +
		" 	ft.password," +
		" 	ft.filename_prefix," +
		" 	ft.filename_suffix," +
		" 	ft.date_format," +
		" 	ft.pgp_flag," +
		" 	fts.next_start_date,"+
		" 	fts.next_start_interval,"+
		" 	fts.linked_task_id"+		
		" FROM" +
		" 	cftp_ftp_task ft," +
		" 	cftp_ftp_task_schedule fts" +
		" WHERE" +
		"	ft.task_id = fts.task_id" +
		" ORDER BY ft.task_id";

		rs = stmt.executeQuery(sql);
		String sTaskId = null;
		String sData = null;		
		while(rs.next())
		{
			sTaskId = rs.getString(1);
%>
	<TR>
		<TD><A href="ftp_task_history.jsp?task_id=<%=sTaskId%>">History</A></TD>
		<TD><A href="ftp_task_edit.jsp?task_id=<%=sTaskId%>">Edit</A></TD>
		<TD><%=sTaskId%></TD>		
<%
			for(int i=2; i < 14; i++)
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
		logger.error("Exception: ",ex);
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

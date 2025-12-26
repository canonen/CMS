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
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp" %>

<HTML>

<HEAD>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>

<BODY>

<%
	String sServer = BriteRequest.getParameter(request, "server");
	if(sServer == null ) sServer = "l.revotas.com:1433";
	
	String sUser = BriteRequest.getParameter(request, "user");
	String sPass = BriteRequest.getParameter(request, "pass");

	if(sUser == null) sUser = "revotasadm";
	if(sPass == null) sPass = "abs0lut";
	
	String sDatabase = "msdb";
	
	String sDriver = "com.microsoft.sqlserver.jdbc.SQLServerDriver";	
	String sUrl =
			"jdbc:sqlserver://" +
			sServer + ";" +
			"databaseName=" + sDatabase + ";" +
			"User=" + sUser + ";" +
			"Password=" + sPass;

	// === === ===
	
	Connection conn = null;
	
	try
	{
		Class.forName(sDriver);
		conn = DriverManager.getConnection(sUrl);
		
		Statement stmt = null;
		
		try
		{
			stmt = conn.createStatement();
			
			String sSql =
				" SELECT" +
				" 	sj.job_id," +
				" 	sj.name," +
				" 	sj.enabled," +
				" 	sj.description," +
				" 	sjs.last_run_outcome," +
				" 	sjs.last_outcome_message," +
				" 	sjs.last_run_date," +
				" 	sjs.last_run_time," +
				" 	sjs.last_run_duration" +
				" FROM" +
				" 	sysjobs sj WITH(NOLOCK)," +
				" 	sysjobservers sjs WITH(NOLOCK)" +
				" WHERE" +
				" 	sj.job_id = sjs.job_id";

			String sJobId = null;
			String sName = null;
			int nEnabled = -1;
			String sDescription = null;
			int nLastRunOutcome = -1;
			String sLastOutcomeMessage = null;
			int nLastRunDate = -1;
			int nLastRunTime = -1;
			int nLastRunDuration = -1;
%>
<TABLE border="1" cellspacing="1" cellpadding="1">
	<TR>
		<TH>&nbsp;</TH>	
		<TH>sJobId</TH>
		<TH>sName</TH>
		<TH>nEnabled</TH>
		<TH>sDescription</TH>
		<TH>nLastRunOutcome</TH>
		<TH>sLastOutcomeMessage</TH>
		<TH>nLastRunDate</TH>
		<TH>nLastRunTime</TH>
		<TH>nLastRunDuration</TH>
	</TR>
<%
			ResultSet rs = stmt.executeQuery(sSql);
						
			while(rs.next())
			{
				sJobId = rs.getString(1);
				sName = rs.getString(2);
				nEnabled = rs.getInt(3);
				sDescription = rs.getString(4);
				nLastRunOutcome = rs.getInt(5);
				sLastOutcomeMessage = rs.getString(6);
				nLastRunDate = rs.getInt(7);
				nLastRunTime = rs.getInt(8);
				nLastRunDuration = rs.getInt(9);
%>
	<TR>
		<TD><%=((nEnabled > 0)&&(nLastRunOutcome != 1)&&(sLastOutcomeMessage != null))?"<B><FONT color=\"#FF0000\"> ALERT </FONT></B>":" OK "%></TD>
		<TD><%=sJobId%></TD>
		<TD><%=sName%></TD>
		<TD><%=nEnabled%></TD>
		<TD><%=sDescription%></TD>
		<TD><%=nLastRunOutcome%></TD>
		<TD><%=sLastOutcomeMessage%></TD>
		<TD><%=nLastRunDate%></TD>
		<TD><%=nLastRunTime%></TD>
		<TD><%=nLastRunDuration%></TD>
	</TR>
<%			
			}
			rs.close();
%>
</TABLE>
<%
		}
		catch(Exception ex) { throw ex; }
		finally { if(stmt!=null) stmt.close(); }
	}
	catch(Exception ex)
	{
		out.println("<B><FONT color=\"#FF0000\"> ALERT </FONT></B>");
		out.println("<PRE>");
		out.println(sUrl);
		ex.printStackTrace(new PrintWriter(out));
		out.println("</PRE>");		
	}
	finally { if(conn!=null) conn.close(); }
%>

</BODY>

</HTML>

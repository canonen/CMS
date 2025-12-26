<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.w3c.dom.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%
	String sShowBusy = request.getParameter("busy");
	String sShowFree = request.getParameter("free");
	String sShowDirty = request.getParameter("dirty");
%>

<HTML>
<HEAD>
	<link rel="stylesheet" href="../css/style.css" TYPE="text/css">
</HEAD>
<BODY>

<H3>Connection Pool</H3>
Current Time: <%=new java.util.Date()%>
<FORM method=GET action="connection_pool.jsp">
	&nbsp;<INPUT type="checkbox" name="busy" <%=(sShowBusy!=null)?"checked":""%>> Show Busy
	&nbsp;<INPUT type="checkbox" name="free" <%=(sShowFree!=null)?"checked":""%>> Show Free
	&nbsp;<INPUT type="checkbox" name="dirty" <%=(sShowDirty!=null)?"checked":""%>> Show Dirty
	&nbsp;<INPUT type="submit" value=" Refresh ">
</FORM>

<HR>

<%
	String sCustId = null;
	ConnectionPool cp = null;
	cp = ConnectionPool.getInstance();
%>
Driver = <%=cp.m_sDriver%><BR>
Url = <%=cp.m_sUrl%><BR>
User Name = <%=cp.m_sUserName%><BR>
Minimum Connections = <%=cp.m_nMinConns%><BR>
Maximum Connections = <%=cp.m_nMaxConns%><BR>
Busy Connections = <%=cp.m_vBusyConns.size()%><BR>
Free Connections = <%=cp.m_vFreeConns.size()%><BR>
Dirty Connections = <%=cp.m_vDirtyConns.size()%><BR>

<!-- Busy Connections -->

<%
		if((sShowBusy!=null))
		{
%>
<BLOCKQUOTE>
<H5>Busy Connections</H5>
<TABLE border="1" cellspacing="0">
	<TR>
		<TH>Connection</TH>
		<TH>Last Requestor @ Request Time</TH>
	</TR>
<%
			Connection conn = null;
			String sRequestor = null;
			for(Enumeration en = cp.m_vBusyConns.elements() ; en.hasMoreElements() ;)
			{
				conn = (Connection) en.nextElement();
				sRequestor = (String) cp.m_htConnRequestors.get(conn);
%>
	<TR>
		<TD><%=conn%></TD>
		<TD><%=sRequestor%></TD>
	</TR>
<%
			}
%>
</TABLE>
</BLOCKQUOTE>
<%
		}
%>

<!-- Free Connections -->

<%
		if((sShowFree!=null))
		{
%>
<BLOCKQUOTE>
<H5>Free Connections</H5>
<TABLE border="1" cellspacing="0">
	<TR>
		<TH>Connection</TH>
		<TH>Last Requestor @ Request Time</TH>
	</TR>
<%
			Connection conn = null;
			String sRequestor = null;
			for(Enumeration en = cp.m_vFreeConns.elements() ; en.hasMoreElements() ;)
			{
				conn = (Connection) en.nextElement();
				sRequestor = (String) cp.m_htConnRequestors.get(conn);
%>
	<TR>
		<TD><%=conn%></TD>
		<TD><%=sRequestor%></TD>
	</TR>
<%
			}
%>
</TABLE>
</BLOCKQUOTE>
<%
		}
%>

<!-- Dirty Connections -->

<%
		if((sShowDirty!=null))
		{
%>
<BLOCKQUOTE>
<H5>Dirty Connections</H5>
<TABLE border="1" cellspacing="0">
	<TR>
		<TH>Connection</TH>
		<TH>Last Requestor @ Request Time</TH>
	</TR>
<%
			Connection conn = null;
			String sRequestor = null;
			for(Enumeration en = cp.m_vDirtyConns.elements() ; en.hasMoreElements() ;)
			{
				conn = (Connection) en.nextElement();
				sRequestor = (String) cp.m_htConnRequestors.get(conn);
%>
	<TR>
		<TD><%=conn%></TD>
		<TD><%=sRequestor%></TD>
	</TR>
<%
			}
%>
</TABLE>
</BLOCKQUOTE>
<%
		}
%>

<HR>
</BODY>
</HTML>
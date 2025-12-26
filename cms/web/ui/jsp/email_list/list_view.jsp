<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		java.util.*,java.sql.*,
		java.net.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

String listID = request.getParameter("list_id");

Statement			stmt			= null;
ConnectionPool		connectionPool	= null;
Connection			srvConnection 	= null;

try
{
	connectionPool = ConnectionPool.getInstance();
	srvConnection = connectionPool.getConnection("list_edit.jsp");
	stmt = srvConnection.createStatement();

	String listTypeID = "2", listType = "QA Test";
	String listName = "";

	String sSql = 
		" SELECT list_name, type_id FROM cque_email_list" +
		" WHERE cust_id = "+cust.s_cust_id+" AND list_id = "+listID;

	ResultSet rs = stmt.executeQuery(sSql);
	if( rs.next() )
	{
		listName = new String(rs.getBytes(1),"UTF-8");
		listTypeID = rs.getString(2);
	}
	else
	{
		out.print("List not found.");
		return;
	}
	rs.close();

	if (listTypeID.equals("1")) listType = "Global Exclusion";
	if (listTypeID.equals("3")) listType = "Exclusion";
	if (listTypeID.equals("4") || listTypeID.equals("6")) listType = "Auto-Respond Notification";

	String sFingerSeq = "";
	if (listTypeID.equals("5"))
	{ 
		listType = "Specified Test Recipient";

		sSql = 
			" SELECT isnull(display_name,attr_name)" +
			" FROM ccps_attribute WHERE cust_id = " + cust.s_cust_id +
			" AND fingerprint_seq IS NOT NULL" +
			" ORDER BY fingerprint_seq";
		rs = stmt.executeQuery(sSql);
		while (rs.next()) sFingerSeq += ((sFingerSeq.length() > 0)?" + ":"")+rs.getString(1);
		rs.close();
	}
%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>
<BODY>
<PRE>
<%
		out.print(listName + " " + listType + " List\r\n");
		out.print(listTypeID.equals("4")?"One email on list chosen at random for each subscriber\r\n":"");
		out.print(listTypeID.equals("6")?"Everyone on list is sent to for each subscriber\r\n":"");
		out.print("\r\n");
		
		sSql = "SELECT email FROM cque_email_list_item WHERE list_id = "+listID;
	  	rs = stmt.executeQuery(sSql);
		for(int i=1; rs.next(); i++)
			out.print(i + " : " + rs.getString(1) + "\r\n");
		rs.close();
%>
</PRE>
</BODY>
</HTML>
<%
}
catch(Exception ex)
{ 
	ErrLog.put(this,ex,"list_view.jsp",out,1);
}
finally
{
	if (stmt != null) stmt.close();
	if (srvConnection != null ) connectionPool.free(srvConnection); 
}
%>

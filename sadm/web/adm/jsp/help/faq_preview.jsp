<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.w3c.dom.*"
	import="org.apache.log4j.*"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp" %>
<%
String sFAQID = request.getParameter("faq_id");
String findCriteria = request.getParameter("findCriteria");

ConnectionPool cp = null;
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
String sSql = null;

String sParentFAQID = "0";
String sTypeID = null;
String sDisplayHeading = "Welcome";	
String sAskQuestion = "Browse the Help navigation to the left or search for Help topics in the search bar above.";
String sGivenAnswer = null;
String sFAQOrder = null;
String sApprovedFlag = null;

String sParentID = null;
String sParentLabel = null;

try
{
	cp = ConnectionPool.getInstance();	
	conn = cp.getConnection(this);
	
	sSql = "select faq_id, parent_faq_id, type_id," +
		" REPLACE(display_heading, '" + findCriteria + "', '<span style=\"background-color:yellow;\">" + findCriteria + "</span>') As 'DisplayHeading'," +
		" REPLACE(ask_question, '" + findCriteria + "', '<span style=\"background-color:yellow;\">" + findCriteria + "</span>') As 'AskQuestion'," +
		" REPLACE(given_answer, '" + findCriteria + "', '<span style=\"background-color:yellow;\">" + findCriteria + "</span>') As 'GivenAnswer'," +
		" faq_order, approved_flag" +
		" from shlp_faq with(nolock) where faq_id = " + sFAQID;
	
	try
	{
		if (sFAQID != null && sFAQID != "null")
		{
			pstmt = conn.prepareStatement(sSql);
			rs = pstmt.executeQuery();
	
			byte[] b = null;
			while (rs.next())
			{
				sParentFAQID = rs.getString(2);
				
				sTypeID = rs.getString(3);
				
				b = rs.getBytes(4);
				sDisplayHeading = (b==null)?null:new String(b, "ISO-8859-1");
				
				b = rs.getBytes(5);
				sAskQuestion = (b==null)?null:new String(b, "ISO-8859-1");
				
				b = rs.getBytes(6);
				sGivenAnswer = (b==null)?null:new String(b, "ISO-8859-1");
				
				sFAQOrder = rs.getString(7);
				
				sApprovedFlag = rs.getString(8);
			}
			rs.close();			
		}
	}
	catch(Exception ex)
	{
		throw new Exception(sSql+"\r\n"+ex.getMessage());
	}
	finally
	{
		if(pstmt != null) pstmt.close();
	}
%>
<html>
<head>
<title><%= sDisplayHeading %></title>
<%@ include file="../header.html" %>
<link rel="stylesheet" type="text/css" href="../../css/style.css">
<style type="text/css">
	
	BODY
	{
		line-height: 160%;
	}
	
	.tip
	{
		border: 1px solid #FFBB77;
		background-color: #FFFFEE;
		padding: 3px;
	}
	
</style>
</head>
<body>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left" nowrap>
			<a class="subactionbutton" href="faq_edit.jsp?faq_id=<%= sFAQID %>">Edit</a>&nbsp;&nbsp;&nbsp;
		</td>
	</tr>
</table>
<br>
	<div class="HelpHeading"><%= sDisplayHeading %></div>
	<div class="HelpContent">
		<%= sAskQuestion %>
	</div>
	<div class="HelpContent">
		<%= sGivenAnswer %>
	</div>
	<br><br>
</body>
</html>
<%
}
catch(Exception ex)
{
	throw ex;
}
finally
{
	if(conn != null) cp.free(conn);
}
%>







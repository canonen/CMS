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
String sHelpDocID = request.getParameter("help_doc_id");
String findCriteria = request.getParameter("findCriteria");

ConnectionPool cp = null;
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
String sSql = null;

String sParentHelpDocID = "0";
String sTypeID = null;
String sInternalHeading = null;	
String sDisplayHeading = "Welcome";
String sContentText = "Browse the Help navigation to the left or search for Help topics in the search bar above.";
String sHelpOrder = null;
String sApprovedFlag = null;

String sParentID = null;
String sParentLabel = null;
													
sSql = "select help_doc_id, parent_help_doc_id, type_id, internal_heading, " +
		" REPLACE(display_heading, '" + findCriteria + "', '<span style=\"background-color:yellow;\">" + findCriteria + "</span>')," +
		" REPLACE(content_text, '" + findCriteria + "', '<span style=\"background-color:yellow;\">" + findCriteria + "</span>')," +
		" help_order, approved_flag" +
		" from shlp_help_doc with(nolock) where help_doc_id = " + sHelpDocID;

try
{
	cp = ConnectionPool.getInstance();	
	conn = cp.getConnection(this);	
	
	try
	{
		if (sHelpDocID != null && sHelpDocID != "null")
		{
			pstmt = conn.prepareStatement(sSql);
			rs = pstmt.executeQuery();
	
			byte[] b = null;
			while (rs.next())
			{
				sParentHelpDocID = rs.getString(2);
				
				sTypeID = rs.getString(3);
				
				b = rs.getBytes(4);
				sInternalHeading = (b==null)?null:new String(b, "ISO-8859-1");
				
				b = rs.getBytes(5);
				sDisplayHeading = (b==null)?null:new String(b, "ISO-8859-1");
				
				b = rs.getBytes(6);
				sContentText = (b==null)?null:new String(b, "ISO-8859-1");
				
				sHelpOrder = rs.getString(7);
				
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
			<a class="subactionbutton" href="help_edit.jsp?help_doc_id=<%= sHelpDocID %>">Edit</a>&nbsp;&nbsp;&nbsp;
		</td>
	</tr>
</table>
<br>
	<div class="HelpHeading"><%= sDisplayHeading %></div>
	<div class="HelpContent">
		<%= sContentText %>
	</div>
	<br><br>
		<%
		try
		{
			if (sHelpDocID != null && sHelpDocID != "null")
			{
			
			String sChildID = null;
			String sChildHeading = null;
			
			String iCount = "0";
			
			sSql = "select help_doc_id, display_heading from shlp_help_doc with(nolock) where approved_flag = 1 and type_id = 103 and (parent_help_doc_id = '" + sHelpDocID + "' or parent_help_doc_id = '" + sParentHelpDocID + "') order by help_order";
			pstmt = conn.prepareStatement(sSql);
			rs = pstmt.executeQuery();
			while (rs.next())
			{
				if (iCount.compareTo("0") == 0)
				{
					%>
					<div class="HelpSubHeading">Topics:</div>
					<div style="padding:10px;">
					<%
				}
				
				sChildID = rs.getString(1);
				sChildHeading = rs.getString(2);
			%>
				<%=((sHelpDocID != null) && (sHelpDocID.equals(sChildID)))?"<li>" + sChildHeading + "</li>":"<li><a href=\"help_preview.jsp?help_doc_id=" + sChildID + "\">" + sChildHeading + "</a></li>"%>
				
			<%
				iCount += 1;
			}
			if (iCount.compareTo("0") != 0)
			{
				%>
					</div>
				<%
			}
			rs.close();
			}
		}
		catch(SQLException sqlex)
		{
			throw sqlex;
		}
		finally
		{
			if(pstmt != null) pstmt.close();
		}
		%>
		<br><br>
	</div>
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







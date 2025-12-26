<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			java.io.*,java.sql.*,
			java.util.*,java.util.*,
			java.sql.*,org.w3c.dom.*,
			org.apache.log4j.*"
%>
<%@ include file="../../header.jsp" %>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

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
		" from chlp_faq with(nolock) where faq_id = " + sFAQID;
	
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
<link rel="stylesheet" type="text/css" href="../help.css">
<script language="JavaScript" src="../help.js"></script>
<%@ include file="../../header.html" %>
<meta name="keywords" content="">
</head>
<body>
	<div class="heading"><%= sDisplayHeading %></div>
	<div class="content">
		<%= sAskQuestion %>
	</div>
	<div class="content">
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







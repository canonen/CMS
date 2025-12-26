<%@ page

	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
%>

<%@ include file="../../header.jsp" %>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	ConnectionPool cp = null;
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	
	String sFAQSaveSql = "";
	
	String s_faq_id = "";
	String s_parent_faq_id = null;
	String s_type_id = null;
	String s_display_heading = null;
	String s_ask_question = null;
	String s_given_answer = null;
	String s_britemoon_process = null;
	String s_faq_order = null;
	String s_approved_flag = null;
	
	sFAQSaveSql = " EXECUTE usp_chlp_faq_save" +
						" @faq_id=?, @parent_faq_id=?, @type_id=?, @display_heading=?, @ask_question=?," +
						" @given_answer=?, @britemoon_process=?, @faq_order=?, @approved_flag=?";

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);

		try
		{
			pstmt = conn.prepareStatement(sFAQSaveSql);
		
			s_faq_id				= request.getParameter("faq_id");
			s_parent_faq_id			= request.getParameter("parent_faq_id");
			s_type_id				= request.getParameter("type_id");
			s_display_heading		= request.getParameter("display_heading");
			s_ask_question			= request.getParameter("ask_question");
			s_given_answer			= request.getParameter("given_answer");
			s_britemoon_process		= request.getParameter("britemoon_process").replaceAll("\n", "<br>");
			s_faq_order				= request.getParameter("faq_order");
			s_approved_flag			= request.getParameter("approved_flag");
			
			if (s_faq_id == null || s_faq_id == "null")
			{
				s_faq_id = "0";
			}
			
			if (s_parent_faq_id == null || s_parent_faq_id == "null")
			{
				s_parent_faq_id = "0";
			}

			pstmt.setString(1, s_faq_id);
			
			pstmt.setString(2, s_parent_faq_id);
	
			pstmt.setString(3, s_type_id);
		
			if(s_display_heading == null) pstmt.setString(4, s_display_heading);
			else pstmt.setBytes(4, s_display_heading.getBytes("ISO-8859-1"));
		
			if(s_ask_question == null) pstmt.setString(5, s_ask_question);
			else pstmt.setBytes(5, s_ask_question.getBytes("ISO-8859-1"));
	
			if(s_given_answer == null) pstmt.setString(6, s_given_answer);
			else pstmt.setBytes(6, s_given_answer.getBytes("ISO-8859-1"));
	
			if(s_britemoon_process == null) pstmt.setString(7, "");
			else pstmt.setString(7, s_britemoon_process);
			
			pstmt.setString(8, s_faq_order);	
	
			pstmt.setString(9, s_approved_flag);
			
			rs = pstmt.executeQuery();	

			while (rs.next())
			{
				s_faq_id = rs.getString(1);
			}
			rs.close();
		}
		catch(Exception ex)
		{
			throw new Exception(sFAQSaveSql+"\r\n"+ex.getMessage());
		}
		finally
		{
			if(pstmt != null) pstmt.close();
		}
	}
	catch(Exception ex)
	{
		//throw ex;
		String errMsg = "s_faq_id: " + s_faq_id + "<br>" +
						"s_parent_faq_id: " + s_parent_faq_id + "<br>" +
						"s_type_id: " + s_type_id + "<br>" +
						"s_display_heading: " + s_display_heading + "<br>" +
						"s_ask_question: " + s_ask_question + "<br>" +
						"s_given_answer: " + s_given_answer + "<br>" +
						"s_britemoon_process: " + s_britemoon_process + "<br>" +
						"s_faq_order: " + s_faq_order + "<br>" +
						"s_approved_flag: " + s_approved_flag + "<br>";
						
		throw new Exception(errMsg+"\r\n"+ex.getMessage());
	}
	finally
	{
		if(conn != null) cp.free(conn);
	}
%>
<html>
<head>
	<title>FAQ Edit</title>
	<%@ include file="../../header.html" %>
	<style type="text/css">
	<!--
		a:link,a:visited
		{
			font-family: Arial, Helvetica;
			font-size: 10px;
			color:#990000;
			text-decoration: underline;
		}
		
		td.sectionheader
		{
			font-family: Arial, Helvetica;
			color: #ffffff;
			background-color=#000040;
			font-size: 12px
		}
		
		table
		{
			font-size:8pt;
			color:#000000;
			font-family:Verdana;
		}
				
		td
		{
			font-size:8pt;
			color:#000000;
			font-family:Verdana;
		}
		
		b.sectionheader
		{
			font-family: Arial, Helvetica;
			color:#ffcc00;
			text-decoration: none;
		}
		
		input,textarea,option,select
		{
			font-family: arial;
			font-size: 9pt;
		}
		
		select.smallDDL
		{
			font-family: arial;
			font-size: 8pt;
		}
	
	//-->
	</style>
	<script language="javascript">
				
		var curPopupWindow = null;
		var faqWindow = null;
		
		function refreshParent()
		{
			//parent.location.href = "faq_list.jsp?faq_id=<%= s_faq_id %>";
		}
		
	</script>
</head>
<body topmargin="0" leftmargin="0" onload="refreshParent();">
<table cellspacing="0" cellpadding="0" border="0" width="100%" id="Table3">
	<tr>
		<td align="left" valign="top"><img src="../../../images/blank.gif" width="25" height="1" border="0"></td>
		<td align="left" valign="top" width="100%">
			<div align="center">
			<br><br><br>
			<h3>Saved Changes</h3>
			<br>
			<a href="faq_edit.jsp?faq_id=<%= s_faq_id %>">Back to edit</a>
			</div>
		</td>
		<td align="left" valign="top"><img src="../../../images/blank.gif" width="25" height="1" border="0"></td>
	</tr>
</table>
</body>
</html>
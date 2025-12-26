<%@ page

	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.apache.log4j.*"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp" %>
<%

	ConnectionPool cp = null;
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	
	String sHelpDocSaveSql = "";
	
	String s_help_doc_id = null;
	String s_parent_help_doc_id = null;
	String s_type_id = null;
	String s_internal_heading = null;
	String s_display_heading = null;
	String s_content_text = null;
	String s_help_order = null;
	String s_approved_flag = null;
	
	sHelpDocSaveSql = " EXECUTE usp_shlp_help_doc_save" +
						" @help_doc_id=?, @parent_help_doc_id=?, @type_id=?," +
						" @internal_heading=?, @display_heading=?, @content_text=?, @help_order=?, @approved_flag=?";

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);

		try
		{
			pstmt = conn.prepareStatement(sHelpDocSaveSql);
		
			s_help_doc_id = request.getParameter("help_doc_id");
			s_parent_help_doc_id = request.getParameter("parent_help_doc_id");
			s_type_id = request.getParameter("type_id");
			s_internal_heading = request.getParameter("internal_heading");
			s_display_heading = request.getParameter("display_heading");
			s_content_text = request.getParameter("content_text");
			s_help_order = request.getParameter("help_order");
			s_approved_flag = request.getParameter("approved_flag");

			pstmt.setString(1, s_help_doc_id);
	
			pstmt.setString(2, s_parent_help_doc_id);
	
			pstmt.setString(3, s_type_id);
	
			if(s_internal_heading == null) pstmt.setString(4, s_internal_heading);
			else pstmt.setBytes(4, s_internal_heading.getBytes("ISO-8859-1"));
	
			if(s_display_heading == null) pstmt.setString(5, s_display_heading);
			else pstmt.setBytes(5, s_display_heading.getBytes("ISO-8859-1"));
	
			if(s_content_text == null) pstmt.setString(6, s_content_text);
			else pstmt.setBytes(6, s_content_text.getBytes("ISO-8859-1"));
	
			pstmt.setString(7, s_help_order);	
	
			pstmt.setString(8, s_approved_flag);
			
			rs = pstmt.executeQuery();	

			while (rs.next())
			{
				s_help_doc_id = rs.getString(1);
			}
			rs.close();
		}
		catch(Exception ex)
		{
			throw new Exception(sHelpDocSaveSql+"\r\n"+ex.getMessage());
		}
		finally
		{
			if(pstmt != null) pstmt.close();
		}
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
<html>
<head>
	<title>Help Doc Edit</title>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" type="text/css" href="../../css/style.css">
	<script language="javascript">
				
		function refreshParent()
		{
			parent.frames("left_01").location.href = "help_list.jsp?help_doc_id=<%=s_help_doc_id%>";
		}
		
	</script>
</head>
<body onload="refreshParent();">
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Changes Saved</b></td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class=main cellspacing=1 cellpadding=2 width="625">
				<tr>
					<td align="left" valign="middle" style="padding:10px;">
						<a href="help_edit.jsp?help_doc_id=<%=s_help_doc_id%>">Back to Edit</a><br><br>
						<a href="help_preview.jsp?help_doc_id=<%=s_help_doc_id%>">Back to Preview</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</body>
</html>
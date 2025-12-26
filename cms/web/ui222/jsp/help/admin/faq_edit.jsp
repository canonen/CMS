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

ConnectionPool cp = null;
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
String sSql = null;

String sParentFAQID = null;
String sTypeID = null;
String sDisplayHeading = null;
String sAskQuestion = null;
String sGivenAnswer = null;
String sBritemoonProcess = null;
String sFAQOrder = null;
String sApprovedFlag = null;

String sParentID = null;
String sParentLabel = null;

try
{
	cp = ConnectionPool.getInstance();	
	conn = cp.getConnection(this);

	sSql = "select faq_id, parent_faq_id, type_id, display_heading, ask_question, given_answer, britemoon_process, faq_order, approved_flag" +
		" from chlp_faq with(nolock) where faq_id = " + sFAQID;
	
	try
	{
		if (sFAQID != null)
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
				
				b = rs.getBytes(7);
				sBritemoonProcess = (b==null)?null:new String(b, "ISO-8859-1");
				
				sBritemoonProcess = sBritemoonProcess.replaceAll("<br>", "\n");
				
				sFAQOrder = rs.getString(8);
				
				sApprovedFlag = rs.getString(9);
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
	<SCRIPT LANGUAGE="JAVASCRIPT">
	
	function SubmitCheck(){
	// Check the text
		var selType = document.faqEdit.type_id[document.faqEdit.type_id.selectedIndex].value
		
		if (document.faqEdit.faq_id.value == "" || document.faqEdit.faq_id.value == "null")
		{
			document.faqEdit.faq_id.value = "0";
		}
		
		if (document.faqEdit.display_heading.value.length == 0) {
			alert("You have to enter a Heading");
			return;
		}
		if (document.faqEdit.ask_question.value.length == 0) {
			alert("You have to enter the Question");
			return;
		}
		if (document.faqEdit.given_answer.value.length == 0) {
			alert("You have to enter the Answer given to customers");
			return;
		}
		if (document.faqEdit.faq_order.value.length == 0) {
			alert("You have to enter an order");
			return;
		}
	
		document.faqEdit.submit();
	}
	
	function loadParentOptions()
	{
		
		var selType = document.faqEdit.type_id[document.faqEdit.type_id.selectedIndex].value;
		var parentSel = document.faqEdit.parent_faq_id;
		
		for (i=1; i < parentSel.length; i++)
		{
			parentSel.remove(i)
		}
		
		if (selType == "201")
		{
			//hide the list
		}
		else if (selType == "202")
		{
			//show 201s
			var oOption;			
			<%
			try
			{
				sSql = "select faq_id, display_heading from chlp_faq where type_id = 201 order by faq_order";
				pstmt = conn.prepareStatement(sSql);
				rs = pstmt.executeQuery();
				while (rs.next())
				{
					sParentID = rs.getString(1);
					sParentLabel = rs.getString(2);
				%>
					oOption = document.createElement("OPTION");
					parentSel.options.add(oOption);
					oOption.innerText = "<%= sParentLabel %>";
					oOption.value = "<%= sParentID %>";
					oOption.selected = <%=((sParentFAQID != null) && (sParentFAQID.equals(sParentID)))?"true":"false"%>;
				<%
				}
				rs.close();
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
		}
		else if (selType == "203")
		{
			<%
			try
			{
				sSql = "select c.faq_id, v.display_heading + ': ' + c.display_heading as 'DisplayHeading'" +
						" from chlp_faq c with(nolock)" +
						" inner join chlp_faq v with(nolock) on c.parent_faq_id = v.faq_id" +
						" where c.type_id = 202" +
						" order by v.faq_order, c.faq_order";
				pstmt = conn.prepareStatement(sSql);
				rs = pstmt.executeQuery();
				while (rs.next())
				{
					sParentID = rs.getString(1);
					sParentLabel = rs.getString(2);
				%>
					oOption = document.createElement("OPTION");
					parentSel.options.add(oOption);
					oOption.innerText = "<%= sParentLabel %>";
					oOption.value = "<%= sParentID %>";
					oOption.selected = <%=((sParentFAQID != null) && (sParentFAQID.equals(sParentID)))?"true":"false"%>;
				<%
				}
				rs.close();
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
		}
		else
		{
			//unknown
		}
		
	}

	</SCRIPT>
</head>
<body topmargin="0" leftmargin="0" onload="loadParentOptions()">
<form method="post" action="faq_edit_save.jsp" name="faqEdit">
<input type="hidden" name="faq_id" value="<%=(sFAQID==null)?"0":sFAQID%>">
<table cellspacing="0" cellpadding="0" border="0" width="100%" height="100%">
	<tr>
		<td align="left" valign="top" width="100%">
			<table cellspacing="0" cellpadding="0" border="0" width="100%">
				<tr>
					<td align="left" valign="top" width="100%">
						<TABLE cellspacing="0" cellpadding="1" class="main" width="100%">
							<TR>
								<TD nowrap>
									<IMG STYLE="cursor:hand" SRC="../../../images/savebutton.gif" onClick="SubmitCheck();">
								</TD>
							</TR>
						</TABLE>
						<BR>
						<TABLE cellpadding="0" cellspacing="0" class="main" width="100%">
							<TR>
								<TD class="sectionheader"><B class="sectionheader"> Step 1:</B> Enter Information</TD>
							</TR>
						</TABLE>
						<BR>
						<TABLE cellpadding="1" cellspacing="1" border="0" width="100%">
							<TR>
								<TD align="left" valign="bottom" nowrap><b>Heading</b></TD>
								<TD align="left" valign="bottom" nowrap><b>Order</b></TD>
								<TD align="left" valign="bottom" width="100%"><b>Approved?</b></TD>
							</TR>
							<tr>
								<TD align="left" valign="top" nowrap><INPUT type="text" name="display_heading" size="50" value="<%=(sDisplayHeading==null)?"":sDisplayHeading%>"></TD>
								<TD align="left" valign="top" nowrap><INPUT type="text" name="faq_order" size="8" value="<%=(sFAQOrder==null)?"":sFAQOrder%>"></TD>
								<TD align="left" valign="top" width="100%">
									<select name="approved_flag">
										<option value="0"<% if((sApprovedFlag!= null) && (sApprovedFlag.compareTo("0") == 0)){%> selected<% } %>>No</option>
										<option value="1"<% if((sApprovedFlag!= null) && (sApprovedFlag.compareTo("1") == 0)){%> selected<% } %>>Yes</option>
									</select>
								</TD>
							</TR>
						</TABLE>
						<table cellpadding="1" cellspacing="1" border="0" width="100%">
							<TR>
								<TD align="left" valign="bottom" nowrap><b>Item Type</b></TD>
								<TD align="left" valign="bottom" width="100%" colspan="2"><b>Parent FAQ Item</b></TD>
							</TR>
							<tr>
								<TD align="left" valign="top" nowrap>
									<select name="type_id" onchange="loadParentOptions();">
										<option value="201"<% if((sTypeID!= null) && (sTypeID.compareTo("201") == 0)){%> selected<% } %>>FAQ: Volume</option>
										<option value="202"<% if((sTypeID!= null) && (sTypeID.compareTo("202") == 0)){%> selected<% } %>>FAQ: Chapter</option>
										<option value="203"<% if((sTypeID!= null) && (sTypeID.compareTo("203") == 0)){%> selected<% } %>>FAQ: Page</option>
										<option value="204"<% if((sTypeID!= null) && (sTypeID.compareTo("204") == 0)){%> selected<% } %>>Revotas Only - Internal Process</option>
									</select>
								</TD>
								<TD align="left" valign="top" width="100%" colspan="2">
									<SELECT size="1" name="parent_faq_id">
										<OPTION value="0">-- Choose a Parent --</OPTION>
										<OPTION value="0" <%=((sParentFAQID != null) && (sParentFAQID.equals("0")))?"selected":""%>>-- Has No Parent --</OPTION>
									</SELECT>
								</TD>
							</TR>
						</table>
						<table cellpadding="1" cellspacing="1" border="0" width="100%">
							<TR>
								<TD align="left" valign="bottom" width="100%"><b>Question</b></TD>
							</TR>
							<tr>
								<TD align="left" valign="top" width="100%">
									<textarea name="ask_question" rows="4" cols="100" style="width:100%;"><%= (sAskQuestion==null)?"":sAskQuestion %></textarea>
								</TD>
							</TR>
						</table>
						<table cellpadding="1" cellspacing="1" border="0" width="100%">
							<TR>
								<TD align="left" valign="bottom" width="100%"><b>Given Answer</b></TD>
							</TR>
							<tr>
								<TD align="left" valign="top" width="100%">
									<textarea name="given_answer" rows="18" cols="125" style="width:100%;"><%= (sGivenAnswer==null)?"":sGivenAnswer %></textarea>
								</TD>
							</TR>
						</table>
						<table cellpadding="1" cellspacing="1" border="0" width="100%">
							<TR>
								<TD align="left" valign="bottom" width="100%"><b>Revotas Process (seen internally only)</b></TD>
							</TR>
							<tr>
								<TD align="left" valign="top" width="100%">
									<textarea name="britemoon_process" rows="18" cols="125" style="width:100%;"><%= (sBritemoonProcess==null)?"":sBritemoonProcess %></textarea>
								</TD>
							</TR>
						</table>
						<BR><BR>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</form>
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
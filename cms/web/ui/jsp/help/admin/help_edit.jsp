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

String sHelpDocID = request.getParameter("help_doc_id");

ConnectionPool cp = null;
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
String sSql = null;

String sParentHelpDocID = null;
String sTypeID = null;
String sInternalHeading = null;	
String sDisplayHeading = null;
String sContentText = null;
String sHelpOrder = null;
String sApprovedFlag = null;

String sParentID = null;
String sParentLabel = null;
													
sSql = "select help_doc_id, parent_help_doc_id, type_id, internal_heading, display_heading, content_text, help_order, approved_flag" +
		" from chlp_help_doc with(nolock) where help_doc_id = " + sHelpDocID;

try
{
	cp = ConnectionPool.getInstance();	
	conn = cp.getConnection(this);	
	
	try
	{
		if (sHelpDocID != null)
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
	<title>Help Doc Edit</title>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" type="text/css" href="../../../css/style.css">
	<SCRIPT LANGUAGE="JAVASCRIPT">
	
	function SubmitCheck(){
	// Check the text
		var selType = document.HelpEdit.type_id[document.HelpEdit.type_id.selectedIndex].value
		
		document.HelpEdit.internal_heading.value = document.HelpEdit.display_heading.value;
		
		if (document.HelpEdit.display_heading.value.length == 0) {
			alert("You have to enter a Heading");
			return;
		}
		if (document.HelpEdit.content_text.value.length == 0 && selType == "103") {
			alert("You have to enter HTML Content");
			return;
		}
		if (document.HelpEdit.help_order.value.length == 0) {
			alert("You have to enter an order");
			return;
		}
	
		document.HelpEdit.submit();
	}
	
	function loadParentOptions()
	{
		
		var selType = document.HelpEdit.type_id[document.HelpEdit.type_id.selectedIndex].value;
		var parentSel = document.HelpEdit.parent_help_doc_id;
		var i = 0;
		
		if (selType == "101")
		{
			//remove the current list
			for (i=0; i < parentSel.options.length; i++)
			{
				parentSel.options.remove[i];
			}
			
			var oOption;
			
			oOption = document.createElement("OPTION");
			parentSel.options.add(oOption);
			oOption.innerText = "-- Has No Parent --";
			oOption.value = "0";
			oOption.selected = true;
		}
		else if (selType == "102")
		{
			//remove the current list
			for (i=0; i < parentSel.options.length; i++)
			{
				parentSel.options.remove[i];
			}
			
			//show 101s
			var oOption;			
			<%
			try
			{
				sSql = "select help_doc_id, internal_heading from chlp_help_doc where type_id = 101 order by help_order";
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
					oOption.selected = <%=((sParentHelpDocID != null) && (sParentHelpDocID.equals(sParentID)))?"true":"false"%>;
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
		else if (selType == "103")
		{
			//remove the current list
			for (i=0; i < parentSel.options.length; i++)
			{
				parentSel.options.remove[i];
			}
			
			//show 103s
			var oOption;
			
			<%
			try
			{
				sSql = "select c.help_doc_id, v.internal_heading + ': ' + c.internal_heading as 'InternalHeading'" +
						" from chlp_help_doc c with(nolock)" +
						" inner join chlp_help_doc v with(nolock) on c.parent_help_doc_id = v.help_doc_id" +
						" where c.type_id = 102" +
						" order by v.help_order, c.help_order";
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
					oOption.selected = <%=((sParentHelpDocID != null) && (sParentHelpDocID.equals(sParentID)))?"true":"false"%>;
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
<body onload="loadParentOptions()">
<form method="post" action="help_edit_save.jsp" name="HelpEdit" style="display:inline;">
<input type="hidden" name="help_doc_id" value="<%=(sHelpDocID==null)?"":sHelpDocID%>">
<input type="hidden" name="internal_heading" value="<%=(sInternalHeading==null)?"":sInternalHeading%>">
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left" nowrap>
			<a class="newbutton" href="javascript:SubmitCheck();">Save</a>&nbsp;&nbsp;&nbsp;
		</td>
		<td vAlign="middle" align="left" nowrap>
			<a class="subactionbutton" href="help_preview.jsp?help_doc_id=<%= sHelpDocID %>">Preview</a>&nbsp;&nbsp;&nbsp;
		</td>
	</tr>
</table>
<br>
<table cellpadding="0" cellspacing="0" class="main" width="95%">
	<tr>
		<td class="sectionheader"><b class="sectionheader">Step 1:</b> Enter Information</td>
	</tr>
</table>
<BR>
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=95% border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=100%>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="left" valign="middle" nowrap>Heading</td>
					<td align="left" valign="middle" nowrap colspan="3" width="100%"><INPUT type="text" name="display_heading" size="50" value="<%=(sDisplayHeading==null)?"":sDisplayHeading%>"></td>
				</tr>
				<tr>
					<td align="left" valign="middle" nowrap>Order</td>
					<td align="left" valign="middle" nowrap><INPUT type="text" name="help_order" size="8" value="<%=(sHelpOrder==null)?"":sHelpOrder%>"></td>
					<td align="left" valign="middle" nowrap>Approved?<br>(show in online help)</td>
					<td align="left" valign="middle" nowrap width="75%">
						<select name="approved_flag">
							<option value="0"<% if((sApprovedFlag!= null) && (sApprovedFlag.compareTo("0") == 0)){%> selected<% } %>>No</option>
							<option value="1"<% if((sApprovedFlag!= null) && (sApprovedFlag.compareTo("1") == 0)){%> selected<% } %>>Yes</option>
						</select>
					</td>
				</tr>
				<tr>
					<td align="left" valign="middle" nowrap>Item Type</td>
					<td align="left" valign="middle" nowrap colspan="3" width="100%">
						<select name="type_id" onchange="loadParentOptions();">
							<option value="101"<% if((sTypeID!= null) && (sTypeID.compareTo("101") == 0)){%> selected<% } %>>Volume</option>
							<option value="102"<% if((sTypeID!= null) && (sTypeID.compareTo("102") == 0)){%> selected<% } %>>Chapter</option>
							<option value="103"<% if((sTypeID!= null) && (sTypeID.compareTo("103") == 0)){%> selected<% } %>>Page</option>
						</select>
					</td>
				</tr>
				<tr>
					<td align="left" valign="middle" nowrap>Parent Help Item</td>
					<td align="left" valign="middle" nowrap colspan="3" width="100%">
						<select size="1" name="parent_help_doc_id">
							<option value="0">-- Choose a Parent --</option>
							<option value="0" <%=((sParentHelpDocID != null) && (sParentHelpDocID.equals("0")))?"selected":""%>>-- Has No Parent --</option>
						</select>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br>
<table cellpadding="0" cellspacing="0" class="main" width="95%">
	<tr>
		<td class="sectionheader"><b class="sectionheader">Step 2:</b> Enter HTML</td>
	</tr>
</table>
<BR>
<table id="Tabs_Table2" cellspacing=0 cellpadding=0 width=95% border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block2_Step1>
	<tr>
		<td class=fillTab valign=top align=left width=100% colspan=3>
			<table width="100%" class="main" cellpadding="2" cellspacing="1">
				<tr>
					<td colspan="2">
						<textarea name="content_text" style="width:100%; height:250px;"><%= (sContentText==null)?"":sContentText %></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
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
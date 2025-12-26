<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			java.util.*,java.sql.*,
			java.net.*,java.text.*,
			org.apache.log4j.*"
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

AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

if(!can.bRead) {
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>

<%
String sLinkId = request.getParameter("link_id");

LinkRenaming link = new LinkRenaming();

if (sLinkId != null) {
	  link.s_link_id = sLinkId;
	  int nRetrieve = link.retrieve();
	  if ((nRetrieve > 0) && !(cust.s_cust_id.equals(link.s_cust_id))) link = new LinkRenaming();
}

%>
<HTML>
<HEAD>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<script language="javascript">
		function launchURL()
		{
			if (!FT.link_type_id1[0].checked) {
				alert("Preview is allowed for exact match only");
				return;
			}
    		var newURL = FT.link_definition1.value;
    		CheckURLWin = window.open(newURL, "CheckURL","scrollbars=yes,resizable=yes,location=yes,toolbar=yes,status=yes,menubar=yes,height=400,width=600");
		}	
		function saveLink()
		{
			FT.submit();
		}		
	</script>
</HEAD>
<BODY>
<FORM METHOD="POST" NAME="FT" ACTION="link_renaming_save.jsp" TARGET="_self">
<input type="hidden" name="num_links" value="1">
<%
if( can.bWrite || can.bDelete)
{
	%>
	<table cellspacing="0" cellpadding="4" border="0">
		<tr>
			<td align="left" valign="middle">
				<a class="savebutton" href="javascript:saveLink();">Save</a>
			</td>
            <% if(can.bDelete && (sLinkId != null)) { %>
		    <td align="left" valign="middle">
			    <a class="deletebutton" href="#" onClick="if( confirm('Are you sure?') ) location.href='link_renaming_delete.jsp?link_id=<%=link.s_link_id%>'" TARGET="_self">Delete</a>
		    </td>
            <% } %>
		</tr>
	</table>
	<br>
	<%
}
%>
<INPUT TYPE="hidden" NAME="link_id1" value="<%=HtmlUtil.escape(link.s_link_id)%>">
<div style="display:none;" id="hiddenInputs">
</div>

<!--- Step 1 Header----->
<table width="650" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 1:</b> Auto Link Name Information</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class="EditBlock" id="block1_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="650">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<!-- Name -->
				<tr>
					<td align="left" valign="middle" width="100" nowrap>Link Name: </td>
					<td align="left" valign="middle">
						<table cellspacing="1" cellpadding="2" width="100%">
							<tr>
								<td align="left" valign="middle"><input type="text" size="40" name="link_name1" value="<%= HtmlUtil.escape(link.s_link_name) %>"></td>
								<td align="left" valign="middle">
									Enter the name of the link to auto-name during Scan for Links
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<!-- Link Type -->
				<tr>
					<td align="left" valign="middle" width="100" nowrap>Match Criteria: </td>
					<td align="left" valign="middle">
						<table cellspacing="1" cellpadding="2" width="100%">
							<tr>
								<td align="left" valign="middle" width="20"><input type="radio" name="link_type_id1" value="1" <%=((link.s_link_type_id == null || link.s_link_type_id.equals("1"))?"checked":"")%>></td>
								<td align="left" valign="middle">
									<label for="chkExact">Exact Match - URL in content must match exactly what is entered</label>
								</td>
							</tr>
							<tr>
								<td align="left" valign="middle" width="20"><input type="radio" name="link_type_id1" value="2" <%=((link.s_link_type_id != null && link.s_link_type_id.equals("2"))?"checked":"")%>></td>
								<td align="left" valign="middle">
									<label for="chkPartial">Partial Match - URL in content must contain what is entered<br>
									(i.e. http://www.mycompany.com/about in the content will match if link entered below is just www.mycompany.com)</label>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<!-- Base Url -->
				<tr>
					<td align="left" valign="middle" width="100" nowrap>Link Definition: </td>
					<td align="left" valign="middle">
						<input type="text" size="80" name="link_definition1" value="<%= HtmlUtil.escape(link.s_link_definition) %>">
						&nbsp;
						<a class="subactionbutton" href="javascript:void(0);" onclick="launchURL();">Preview Link</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
</FORM>
</BODY>
</HTML>

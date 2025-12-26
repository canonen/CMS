<%@ page contentType="text/html;charset=UTF-8" 
		 import="java.util.*" 
		 import="java.io.*"
		 import="java.sql.*"
 		 import="com.britemoon.*"
		 import="com.britemoon.cps.*"
 		 import="com.britemoon.cps.ctm.*"
 		 import="com.britemoon.cps.adm.CustFeature"
		 import="org.w3c.dom.*"
		 import="org.apache.log4j.*"
 %>
<%! static Logger logger = null; %>
<%  if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%
int custID = Integer.parseInt(cust.s_cust_id);

String tName, tCategory, tCustID, tChildCustList, pageTitle, buttonTitle;
boolean isGlobal;
boolean isApproval;
String templateID = request.getParameter("templateID");
if (templateID == null) {
	templateID = "0";
	tName = "";
	tCategory = "";
	tCustID = "0";
	tChildCustList = "";
	pageTitle = ""; //New Master Template";
	buttonTitle = "Save";
	isGlobal = false;
	isApproval = false;	
} else {
	Hashtable tbeans = (Hashtable)application.getAttribute("tbeans");
	TemplateBean tbean = (TemplateBean)tbeans.get(new Integer(templateID));
	tName = tbean.getTemplateName();
	tCategory = tbean.getCategory();
	tCustID = String.valueOf(tbean.getCustID());
	tChildCustList = tbean.getChildCustList();
	pageTitle = ""; //Editing Master Template: "+tName;
	buttonTitle = "Save";
	isGlobal = tbean.isGlobal();
	isApproval = tbean.isApproval();
}
// don't know why tbean.getChildCustList() would return "null", but cleanse it anyway
if (tChildCustList == null) {
	tChildCustList = "";
} 
String searchChildCustList = "," + tChildCustList + ",";
boolean isAdmin = false;
boolean isParent = false;
if (request.getParameter("admin") != null) {
	isAdmin = true;
}
else if (request.getParameter("parent") != null) {
	isParent = true;
}
boolean bIsHyattCustomer = false;
cust = new Customer(cust.s_cust_id);
bIsHyattCustomer  =  CustFeature.exists(cust.s_cust_id, Feature.HYATT);

%>

<!-- This page displays the form to create a new template -->

<html>
<head>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>

<script language="javascript">

function updateList()
{
	var childList="";
	var checkboxes = document.getElementsByName('childCust');
	for (var n=0; n < checkboxes.length; n++) {
		if (checkboxes[n].checked == true) {
			childList += "," + checkboxes[n].value;
		}
	}
	if (childList.length > 0) {
		childList = childList.substring(1);
		FT.childList.value = childList;
	}
	else {
		FT.childList.value = "";
	}
	// clear global checkbox
	document.getElementsByName('allCust')[0].checked = false;
}	

function updateAll()
{
	var childList="";
	if (document.getElementsByName('allCust')[0].checked == true) {
		//set childList=0
		FT.childList.value = "0";
		// uncheck all child custs
		var checkboxes = document.getElementsByName('childCust');
		for (var n=0; n < checkboxes.length; n++) {
			checkboxes[n].checked = false;
		}
	}
	else {
		updateList();		
	}
}	

function updateApprovalFlag()
{
	if (document.getElementsByName('approval')[0].checked == true) {		
		FT.approval_flag.value = "1";
	}
	else {
		FT.approval_flag.value = "0";	
	}
}

function doSubmit()
{
	updateApprovalFlag();
	FT.submit();
}

</script>

<body>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left">
			<a class="savebutton" href="#" onClick="doSubmit()"><%= buttonTitle %></a>
		</td>
	</tr>
</table>
<br>
<form name="FT" method="POST" action="templatenew2.jsp" enctype="multipart/form-data">
<input type="hidden" name="templateID" value="<%= templateID %>">

<table cellpadding="0" cellspacing="0" class="main" width="650">
	<tr>
		<td class="sectionheader"><b class="sectionheader">Step 1:</b> Master Template Info</td>
	</tr>
</table>
<br>
<table cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650 colspan=2><img height=2 src="../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTab>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td width="100">Name: </td>
					<td><input size="30" style="width:100%;" type="text" name="templateName" value="<%= WebUtils.htmlEncode(tName) %>"></td>
				</tr>
				<%--
				<tr>
				<th>Category:</th>
				<td>
				<select name=category>
				<option value=0>-- Select Category --

				<%
				StringTokenizer allCategories = new StringTokenizer(application.getInitParameter("CategoryList"), ";");
				String val;
				while (allCategories.hasMoreTokens()) {
					val = allCategories.nextToken();
					if (val.equals(tCategory)) {
						%>
						<option selected><%= val %></option>
						<%
					} else {
						%>
						<option><%= val %></option>
						<%
					}
				}

				</select>

				</td>
				</tr>
				--%>
				<input type="hidden" name="category" value="Newsletter">
				<input type="hidden" name="parent" value="<%=(isParent?"true":"false")%>">
				<% 
				if (isAdmin) {
				%>
				<tr>
					<td width="100">Customer ID:<br>(Zero for Public)</td>
					<td><input type="text" name="custID" value="<%= tCustID %>" size="10"></td>
						<input type="hidden" name="childList" value="">
				</tr>
				<% 
				} else { 
				%>
					<input type="hidden" name="custID" value="<%= custID %>">
					<input type="hidden" name="childList" value="<%=(isGlobal?"0":tChildCustList)%>">
				<% } %>
				<input type="hidden" name=approval_flag id=approval_flag value="<%=(isApproval?"1":"0")%>">
			</table>
		</td>
	</tr>
</table>
<br><br>

<table cellpadding="0" cellspacing="0" class="main" width="650">
	<tr>
		<td class="sectionheader"><b class="sectionheader">Step 2:</b> Upload Template Files &amp; Images</td>
	</tr>
</table>
<br>
<table cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650 colspan=2><img height=2 src="../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTab>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td width="100">HTML File:</td>
					<td><input type="file" name="htmlFile" style="width:100%;"></td>
				</tr>
				<tr>
					<td width="100">Text File:</td>
					<td><input type="file" name="txtFile" style="width:100%;"></td>
				</tr>
				<tr>
					<td width="100">Mjml File:</td>
					<td><input type="file" name="mjmlFile" style="width:100%;"></td>
				</tr>
				<tr>
					<td width="100">Small Image:</td>
					<td><input type="file" name="smallImage" style="width:100%;"></td>
				</tr>
				<tr>
					<td width="100">Large Image:</td>
					<td><input type="file" name="largeImage" style="width:100%;"></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<br><br>
<% 
if (isParent) {
	// get child cust for parent
	ConnectionPool connPool = null;
	Connection conn = null;
	Statement stmt = null;		
	String sResponse = null;
	try {
		connPool = ConnectionPool.getInstance();
		conn = connPool.getConnection("templatenew.jsp");
		stmt = conn.createStatement();
		String sql = null;
		sql =
			"SELECT c.cust_id, c.cust_name " + 
			"  FROM ccps_customer c" +
			" WHERE c.parent_cust_id = " + custID;	
		ResultSet rs = stmt.executeQuery(sql);
		String children_xml = "";
		while (rs.next()) {
			String child_id = rs.getString(1);
			byte[] bVal = new byte[255];
			bVal = rs.getBytes(2);
			children_xml += "  <child>\n";
			children_xml += "    <cust_id>"+child_id+"</cust_id>\n";
			children_xml += "    <cust_name><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></cust_name>\n";
			children_xml += "  </child>\n";
		}
		rs.close();
		if (children_xml != null) {
			sResponse = "<children>\n" + children_xml + "</children>\n";
		}
	}
	catch (Exception e) {
		out.println("database error in templatenew.jsp =>" + e.getMessage());
		return;
	}
	finally {
		try { if (stmt != null) stmt.close(); }	catch (Exception ex) {};
		if (conn != null) connPool.free(conn);
	}

	Element eRoot = null;
	XmlElementList xelItems = null;
	Element eItem = null;
	String child_cust_id = null;
	String child_cust_name = null;
	String sSelectHtml = "";
	sSelectHtml += "<table cellpadding=0 cellspacing=0 class=main width=650>";
	sSelectHtml += "	<tr>";
	sSelectHtml += "		<td class=sectionheader><b class=sectionheader>Step 3:</b> Template Replication</td>";
	sSelectHtml += "	</tr>";
	sSelectHtml += "</table>";
	sSelectHtml += "<br>";
	sSelectHtml += "<table cellspacing=0 cellpadding=0 width=650 border=0>";
	sSelectHtml += "	<tr>";
	sSelectHtml += "		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src=../images/blank.gif width=1></td>";
	sSelectHtml += "	</tr>";
	sSelectHtml += "	<tr>";
	sSelectHtml += "		<td class=fillTabbuffer valign=top align=left width=650 colspan=2><img height=2 src=../images/blank.gif width=1></td>";
	sSelectHtml += "	</tr>";
	sSelectHtml += "	<tr>";
	sSelectHtml += "		<td class=fillTab>";
	sSelectHtml += "			<table class=main cellspacing=1 width=100% cellpadding=2>";
	sSelectHtml += "				<tr>";
	sSelectHtml += "					<td colspan=3><input type=checkbox name=allCust id=allCust value=0 onClick=\"updateAll()\" " + (isGlobal?"checked":"")+ "><label for=allCust>Global (accessible to all current and future child customers)</label></td>";
	sSelectHtml += "				</tr>";
	try {
		int td_max = 3;
		int td_left = td_max;
		eRoot = XmlUtil.getRootElement(sResponse);
		xelItems = XmlUtil.getChildrenByName(eRoot, "child");
		for (int n=0; n < xelItems.getLength(); n++) {
			eItem = (Element)xelItems.item(n);
			child_cust_id = XmlUtil.getChildTextValue(eItem, "cust_id");
			child_cust_name = XmlUtil.getChildCDataValue(eItem, "cust_name");
			String checkOrNo = "";
			if (searchChildCustList.indexOf("," + child_cust_id + ",") >= 0) {
				checkOrNo = "checked";
			}
			if (td_left == td_max) {
				sSelectHtml += "<tr>";
			}
			sSelectHtml += "<td><input type=checkbox name=childCust id=chk_"+child_cust_id+" value="+child_cust_id+" onClick=\"updateList();\" " + checkOrNo +"><label for=chk_"+child_cust_id+">"+child_cust_name+"</label></td>";
			td_left--;
			if (td_left == 0) {
				sSelectHtml += "</tr>";
				td_left = td_max;
			}
		}
		if (td_left < td_max) {
			while (td_left > 0) {
				sSelectHtml += "<td>&nbsp;</td>";
				td_left--;
			}
			sSelectHtml += "</tr>";
		}
		sSelectHtml += "</table>";
		sSelectHtml += "</td></tr></table>";
		sSelectHtml += "<br><br>";
	}
	catch(Exception ex) { 
		logger.error("exception=>",ex);
		return;
	}
%>
<%= sSelectHtml %>
<%
}
%>

<table cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650 colspan=2><img height=2 src="../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTab>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
			<% if (bIsHyattCustomer){ %>
				<tr>
					<td width="100">Require Approval:</td>
					<td><input type=checkbox name=approval id=approval value=1 CHECKED onClick="updateApprovalFlag()" <%=(isApproval?"checked":"")%>></td>
				</tr>
			<% } else { %>
				<tr>
					<td width="100">Require Approval:</td>
					<td><input type=checkbox name=approval id=approval value=0 onClick="updateApprovalFlag()" <%=(isApproval?"checked":"")%>></td>
				</tr>
			<% } %>
			</table>
		</td>
	</tr>
</table>
<br><br>
</form>
</body>
</html>

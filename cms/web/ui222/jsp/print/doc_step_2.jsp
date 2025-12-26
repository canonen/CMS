<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.util.*,java.sql.*,
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

String sectionID = request.getParameter("id");
if (sectionID == null) sectionID = "1";
int secID = Integer.parseInt(sectionID);

String sideSectionID = "0";
String sectionName = "";
String showOptions = "";

switch (secID)
{
	case 1:
		sectionName = "Offer Masthead";
		showOptions = " style=\"display:none;\"";
		break;
		
	case 2:
		sectionName = "Offer Image";
		showOptions = " style=\"display:none;\"";
		break;
		
	case 3:
		sectionName = "Intro Text";
		break;
		
	case 4:
		sectionName = "Salutation";
		break;
		
	case 5:
		sectionName = "Offer Body";
		showOptions = " style=\"display:none;\"";
		break;
		
	case 6:
		sectionName = "Body of PostCard";
		break;
		
	case 7:
		sectionName = "Address Info";
		break;
}

ConnectionPool cp	= null;
Connection conn		= null;
Statement stmt		= null;
ResultSet rs		= null;

String htmlPersonals="", firstPers="";


try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();
	
	//Personalization
	String attrID="", attrName="", attrDisplayName="";

	rs = stmt.executeQuery(""+
		"SELECT c.attr_id, a.attr_name, c.display_name " +
		"FROM ccps_cust_attr c, ccps_attribute a " +
		"WHERE c.cust_id = "+cust.s_cust_id+" AND c.display_seq IS NOT NULL " +
		"AND c.attr_id = a.attr_id " +
		"ORDER BY display_seq");
	while (rs.next()) {
		attrID = rs.getString(1);
		attrName = rs.getString(2);
		attrDisplayName = new String(rs.getBytes(3),"UTF-8");
		if (firstPers.length() == 0) firstPers = attrName;
		htmlPersonals += "<option value="+attrName+">"+attrDisplayName+"</option>\n";
	}
	
} catch(Exception ex)	{
	ErrLog.put(this,ex,"doc_step_2.jsp",out,1);
	return;
} finally {
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn);
}

%>
<html>
<head>
<title>Edit Section</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%= ui.s_css_filename %>" TYPE="text/css">
<script language="javascript">
	
	
	
</script>
<script language="javascript" src="../../js/tab_script.js"></script>
</head>
<body>
<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
	<tr height="30">
		<td>
			<table cellpadding="4" cellspacing="0" border="0">
				<tr>
					<td vAlign="middle" align="left">
						<a class="savebutton" href="#" onclick="self.close();">Save</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr height="100">
		<td>
			<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=100% border=0>
				<tr>
					<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tr>
					<td class=fillTabbuffer valign=top align=left width=100%><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tbody class=EditBlock id=block1_Step1>
				<tr>
					<td class=fillTab valign=top align=center width=100%>
						<table class="main" cellspacing="1" cellpadding="3" border="0" width="100%">
							<tr>
								<td align="center" valign="middle" style="padding:10px;">
									<b><%= sectionName %></b><br><br>
									Edit the section(s) below, then click the Save button above to commit the changes to the content.
								</td>
							</tr>
						</table>
					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table id="Tabs_Table2" cellspacing=0 cellpadding=0 border=0 style="width:100%; height:100%;">
				<tr height="22">
					<td class=EditTabOn id=tab2_Step1 width="150" onclick="switchSteps('Tabs_Table2', 'tab2_Step1', 'block2_Step1');" valign=center nowrap align=middle>Edit Content</td>
					<td class=EditTabOff id=tab2_Step2 width="150"<%= showOptions %> onclick="switchSteps('Tabs_Table2', 'tab2_Step2', 'block2_Step2');" valign=center nowrap align=middle>Personalization Options</td>
					<td class=EmptyTab valign=center nowrap align=middle width="100%"><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tr height="2">
					<td class=fillTabbuffer valign=top align=left width=650 colspan=3><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tbody class=EditBlock id=block2_Step1>
				<tr>
					<td class=fillTab valign=top align=center width=100% colspan=3>
						<table cellspacing="1" cellpadding="3" border="0" class="main layout" style="width:100%; height:100%;">
							<col>
							<tr>
								<td align="left" valign="top">
									<iframe src="doc_step_3_edit.jsp?id=<%= sectionID %>" name="Step2_Edit" style="width:100%; height:100%;" frameborder="0" border="0" scroll="auto"></iframe>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				</tbody>
				<tbody class=EditBlock id=block2_Step2 style="display:none;">
				<tr>
					<td class=fillTab valign=top align=center width=100% colspan=3>
						<form name="FT">
						<table class="main" cellpadding="2" cellspacing="1" width="100%">
							<tr>
								<td width="100%" align="left" valign="middle">
									Personalization Field:<br>
									<select name=PerzFields size=1 onchange="FT.MergeSymbol.value='!*'+this.value+';'+FT.DefaultValue.value+'*!';">
										<%= htmlPersonals %>		
									</select>
								</td>
							</tr>
							<tr>
								<td width="100%" align="left" valign="middle">
									Default Value:<br>
									<!-- Default value -->
									<input type=text name="DefaultValue" size=22 onkeyup="FT.MergeSymbol.value='!*'+FT.PerzFields.options[FT.PerzFields.selectedIndex].value+';'+this.value+'*!';">
								</td>
							</tr>
							<tr>
								<td width="100%" align="left" valign="middle">
									Merge Symbol:<br>
									<!-- PickUp value -->
									<input type=text name=MergeSymbol size=34 disabled value="!*<%= firstPers %>;*!"><br>
									(copy and paste this into your content)
								</td>
							</tr>
						</table>
						</form>
					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
</table>
</body>
</html>

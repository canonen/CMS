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


Statement			stmt			= null;
ResultSet			rs				= null; 
ConnectionPool		cp				= null;
Connection			conn 			= null;

String firstPers = "";
String htmlPersonals = "";

try	{

	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("camp_pers.jsp");
	stmt = conn.createStatement();

	//Personalization
	String attrName,attrDisplayName,tmp,defaultValue,attrID;
	int i,j;
	rs = stmt.executeQuery(""+
		" SELECT a.attr_id, a.attr_name, ca.display_name " +
		" FROM ccps_attribute a, ccps_cust_attr ca" +
		" WHERE ca.cust_id = "+cust.s_cust_id+
		" AND a.attr_id = ca.attr_id" +
		" AND ca.display_seq IS NOT NULL " +
		" ORDER BY ca.display_seq");
	while (rs.next())
	{
		attrID = rs.getString(1);
		attrName = rs.getString(2);
		attrDisplayName = new String(rs.getBytes(3),"ISO-8859-1");
		if (firstPers.length() == 0) firstPers = attrName;
		htmlPersonals += "<option value="+attrName+">"+attrDisplayName+"</option>\n";
	}

}
catch(Exception ex) { throw ex; }
finally
{
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn);
}

%>
<html>
<head>
<title>Personalization Options</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="javascript">
	
	function window.onload()
	{
		window.resizeTo(500,275);
	}

	function copySymbol()
	{
		var theSymbol;
		var theSelect;
		var theRange;

		FT.MergeSymbol.select();
		theSelect = document.selection;
		theRange = theSelect.createRange();

		if (theRange.text.length > 0)
		{
			theRange.execCommand("Copy");

			document.selection.empty();

			alert("The merge symbol has been copied.  Paste the symbol in the appropriate campaign section.");
		}
	}
	
</script>
</head>
<body>
<form  name="FT" TARGET="_self">
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
					<td align="right" valign="top" width="35%">
						<b>Custom Field</b><br>
						The database field to personalize with.
					</td>
					<td align="left" valign="top" width="65%">
						<select name="PerzFields" size="1" onchange="FT.MergeSymbol.value='!*'+this.value+';'+FT.DefaultValue.value+'*!';">
							<%= htmlPersonals %>
						</select>
					</td>
				</tr>
				<tr>
					<td align="right" valign="top" width="35%">
						<b>Default Value</b><br>
						If no value in the database, provide a default.
					</td>
					<td align="left" valign="top" width="65%">
						<input type="text" name="DefaultValue" size="22" style="width:100%;" onkeyup="FT.MergeSymbol.value='!*'+FT.PerzFields.options[FT.PerzFields.selectedIndex].value+';'+this.value+'*!';">
					</td>
				</tr>
				<tr>
					<td align="right" valign="top" width="35%">
						<b>Merge Symbol</b><br>
						Copy and paste the personalization merge symbol.<br><br>
						<a class="resourcebutton" href="javascript:copySymbol();">Copy Symbol</a><br>
					</td>
					<td align="left" valign="top" width="65%">
						<input type="text" name="MergeSymbol" size="34" style="width:100%;" value="!*<%= firstPers %>;*!">
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
</form>
</body>
</html>

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

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>

<%
String sFormatId = request.getParameter("format_id");
String sScrapeId = request.getParameter("scrape_id");

ScrapeFormat format = new ScrapeFormat();

format.s_format_id = sFormatId;
if (format.retrieve() < 1) {
	format.s_scrape_id = sScrapeId;
}

Scrape scrape = new Scrape();
scrape.s_scrape_id = format.s_scrape_id;
if ((scrape.retrieve() > 0) && !(cust.s_cust_id.equals(scrape.s_cust_id))) return;
	
ConnectionPool cp	= null;
Connection conn		= null;
Statement stmt		= null;
ResultSet rs		= null;
Connection conn2	= null;
Statement stmt2		= null;
ResultSet rs2		= null;
String strOptions	= "";

try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("scrape_format_edit");
	stmt = conn.createStatement();
	conn2 = cp.getConnection("scrape_format_edit 2");
	stmt2 = conn2.createStatement();

%>
<HTML>
<HEAD>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<script language="javascript" src="../../js/tab_script.js"></script>
	<script language="javascript">
		
		function switchTags(obj)
		{
			var dTags = document.getElementById("tagName");
			var dEntries = document.getElementById("entryNum");
			var tSymbol = document.getElementById("mergesymbol");
			
			var t = 0;
			var es = 0;
			var i = 0;
			
			t = dTags.options.length;
						
			for (i = t; i >= 0; i--)
			{
				dTags.options.remove(i);
			}
			
			i = 0;
			es = dEntries.options.length;
			
			for (i = es; i >= 0; i--)
			{
				dEntries.options.remove(i);
			}
			
			var scrape_id = obj[obj.selectedIndex].value;
			var newTags = document.getElementById("tags_" + scrape_id);
			
			i = 0;
			t = newTags.options.length;
			
			if (t > 0)
			{
				for (i=0; i < t; i++)
				{
					dTags.options[dTags.length] = new Option(newTags.options[i].text, newTags.options[i].value);
				}
			}
			
			dTags.options[dTags.length] = new Option("Header Text", "scr_title_text");
			dTags.options[dTags.length] = new Option("Header HTML", "scr_title_html");
			
			var numEntries = obj[obj.selectedIndex].entries;
			
			for (i=1; i <= numEntries; i++)
			{
				dEntries.options[dEntries.length] = new Option(i, i);
			}
			
			generateMerge();
			
		}
		
		function loadPage()
		{
			var obj = document.getElementById("scrape_id");
			switchTags(obj);
		}
		
		function generateMerge()
		{
			var dTags = document.getElementById("tagName");
			var dEntries = document.getElementById("entryNum");
			var tSymbol = document.getElementById("mergesymbol");
			
			var selTag = dTags[dTags.selectedIndex].value;
			var selEntry = dEntries[dEntries.selectedIndex].value;
			
			var sMerge = "";
			
			if ((selTag == "") && (selEntry == ""))
			{
				sMerge = "";
			}
			else if (!(selTag == "scr_title_text") && !(selTag == "scr_title_html"))
			{
				sMerge = "!*" + selTag + ":" + selEntry + ";*!";
			}
			else
			{
				sMerge = "!*" + selTag + ";*!";
			}
			
			tSymbol.value = sMerge;
		}
		
	</script>
</HEAD>
<BODY onload="loadPage();">
<FORM METHOD="POST" NAME="FT" ACTION="scrape_format_save.jsp" TARGET="_self">
<INPUT TYPE="hidden" NAME="format_id" value="<%=HtmlUtil.escape(format.s_format_id)%>">

<%
if( can.bWrite)
{
	%>
	<table cellspacing="0" cellpadding="4" border="0">
		<tr>
			<td align="left" valign="middle">
				<a class="savebutton" href="javascript:FT.submit();">Save</a>
			</td>
		</tr>
	</table>
	<br>
	<%
}
%>

<!--- Step 1 Header----->
<table width="650" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 1:</b> Format Information</td>
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
					<td align="left" valign="middle" width="150" nowrap>Format name: </td>
					<td align="left" valign="middle">
						<input type="text" size="25" name="format_name" value="<%= HtmlUtil.escape(format.s_format_name) %>">
					</td>
				</tr>
				<!-- Scrape -->
				<tr>
					<td align="left" valign="middle" width="150" nowrap>Scrape: </td>
					<td align="left" valign="middle">
						<select name="scrape_id" id="scrape_id" size="1" onchange="switchTags(this);">
						<%
							String tmpScrapeID = "";
							String tmpScrapeName = "";
							String tmpScrapeEntries = "";
							
							String tagName = "";
							
							rs = stmt.executeQuery("SELECT scrape_id, scrape_name, num_entries FROM ccnt_scrape WHERE cust_id = "+cust.s_cust_id);
							
							while (rs.next())
							{
								tmpScrapeID = rs.getString(1);			
								byte [] b = rs.getBytes(2);
								tmpScrapeName = (b!=null)?new String(b, "UTF-8"):"";
								tmpScrapeEntries = rs.getString(3);	
								if (tmpScrapeID.equals(format.s_scrape_id))
									out.print("<option selected value="+tmpScrapeID+" entries="+tmpScrapeEntries+">"+tmpScrapeName+"</option>\n");
								else
									out.print("<option value="+tmpScrapeID+" entries="+tmpScrapeEntries+">"+tmpScrapeName+"</option>\n");
									
								strOptions += "<select id=tags_" + tmpScrapeID + ">";
								
								tagName = "";
								
								rs2 = stmt2.executeQuery("SELECT tag_name FROM ccnt_scrape_tag WHERE scrape_id = "+tmpScrapeID);
								while (rs2.next())
								{
									tagName = rs2.getString(1);
									strOptions += "<option value=" + tagName + ">" + tagName + "</option>";
								}
								rs2.close();
								
								strOptions += "</select>";
							}
							rs.close();
							
						%>
						</select>
					</td>
				</tr>
				<!-- Charset -->
				<tr>
					<td align="left" valign="middle" width="150" nowrap>Send Type: </td>
					<td align="left" valign="middle">
						<select name="charset_id" size="1">
						<%
							String tmpCharsetID = "";
							rs = stmt.executeQuery("SELECT charset_id, display_name FROM ccnt_charset");
							while (rs.next())
							{
								tmpCharsetID = rs.getString(1);			
								if (tmpCharsetID.equals(format.s_charset_id))
									out.print("<option selected value="+tmpCharsetID+">"+rs.getString(2)+"</option>\n");
								else
									out.print("<option value="+tmpCharsetID+">"+rs.getString(2)+"</option>\n");			
							}
							rs.close();
						%>
						</select>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<!--- Step 2 Header----->
<table width="650" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 2:</b> Personalization Information</td>
	</tr>
</table>
<br>
<!---- Step 2 Info----->
<table id="Tabs_Table2" cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="650"><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class="EditBlock" id="block2_Step1">
	<tr>
		<td class="fillTab" valign="top" align="center" width="650">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td align="left" valign="middle" width="150" nowrap>Tag Name: </td>
					<td align="left" valign="middle">
						<select name="tagName" id="tagName" onchange="generateMerge();">
							<option value=""></option>
						</select>
					</td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="150" nowrap>Entry Number: </td>
					<td align="left" valign="middle">
						<select name="entryNum" id="entryNum" onchange="generateMerge();">
							<option value=""></option>
						</select>
					</td>
				</tr>
				<tr>
					<td align="left" valign="middle" width="150" nowrap>Merge Symbol: </td>
					<td align="left" valign="middle">
						<input type="text" name="mergesymbol" id="mergesymbol" value="" disabled="true">
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<!--- Step 3 Header----->
<table width="650" class="main" cellspacing="0" cellpadding="0">
	<tr>
		<td class="sectionheader">&nbsp;<b class="sectionheader">Step 3:</b> Enter Your Format</td>
	</tr>
</table>
<br>
<!---- Step 3 Info----->
<table id="Tabs_Table3" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EditTabOn id=tab3_Step1 width=200 onclick="switchSteps('Tabs_Table3', 'tab3_Step1', 'block3_Step1');" valign=center nowrap align=middle>Text</td>
		<td class=EditTabOff id=tab3_Step2 width=200 onclick="switchSteps('Tabs_Table3', 'tab3_Step2', 'block3_Step2');" valign=center nowrap align=middle>HTML</td>
		<td class=EmptyTab valign=center nowrap align=middle width=250><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650 colspan=4><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block3_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650 colspan=4>
			<table class=main cellspacing=1 cellpadding=2 width=100%>
				<tr>
					<td align="center">
						<br>Enter Text Format Here<br>
						<textarea rows="11" name="cont_text" cols="60" style="width: 505; height: 231"><%= HtmlUtil.escape(format.s_cont_text) %></textarea>
						<br>
						<br>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
	<tbody class=EditBlock id=block3_Step2 style="display:none;">
	<tr>
		<td class=fillTab valign=top align=center width=650 colspan=4>
			<table class=main cellspacing=1 cellpadding=2 width=100%>
				<tr>
					<td align="center">
						<br>Enter HTML Format Here<br>
						<textarea rows="11" name="cont_html" cols="60" style="width: 505; height: 231"><%= HtmlUtil.escape(format.s_cont_html) %></textarea>
						<br>
						<br>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
<div style="display:none;">
<%= strOptions %>
</div>
<%
} catch(Exception ex)	{
	throw ex;
} finally {
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn);
	if (stmt2 != null) stmt2.close();
	if (conn2 != null) cp.free(conn2);
}
%>
</FORM>
</BODY>
</HTML>

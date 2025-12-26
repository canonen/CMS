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
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

String findCriteria = null;
findCriteria = request.getParameter("findCriteria");

String searchCriteria = null;

if (findCriteria != null && findCriteria != "0" && findCriteria != "null")
{
	searchCriteria = findCriteria.toLowerCase();
	searchCriteria = searchCriteria.replaceAll("\'", "''");
	searchCriteria = searchCriteria.replaceAll("\"", "\"\"");
}
%>
<html>
<link rel="stylesheet" href="<%= ui.s_css_filename %>" TYPE="text/css">
<script language="JavaScript" src="help.js"></script>
<body leftmargin="0" topmargin="0" marginheight="0" marginwidth="0" style="padding:0px;">
<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
	<col>
	<tr height="35">
		<td style="padding:5px;"><div class="HelpHeading">Search Results</div></td>
	</tr>
	<tr height="35">
		<td style="font-weight:normal; padding:8px;">
			That matched the query: <b><%= findCriteria %></b>
		</td>
	</tr>
	<tr>
		<td>
			<div class="HelpContent">
				<table cellspacing="0" cellpadding="3" border="0">
<%
String sRequest = null;

sRequest = new String("<request><action>faqsearch</action><criteria><![CDATA[" + searchCriteria + "]]></criteria></request>");

try
{
	String sResponse = Service.communicate(ServiceType.SADM_HELP_DOC_INFO, cust.s_cust_id, sRequest);      
	Element eRoot = XmlUtil.getRootElement(sResponse);
	//System.out.println("xml=" + sResponse);
	if (eRoot != null && !eRoot.getTagName().toUpperCase().equals("ERROR"))
	{		
		XmlElementList xelDocs = null;
		Element eDoc = null;
		int nCount = 0;
		
		String sVolumeID = null;
		String sVolumeHeading = null;
		String sChapterID = null;
		String sChapterHeading = null;
		String sPageID = null;
		String sPageHeading = null;
				
		xelDocs = XmlUtil.getChildrenByName(eRoot, "resultItem");
		eDoc = null;
		nCount = xelDocs.getLength();
		
		if (nCount > 0)
		{
			for (int n=0; n < nCount; n++)
			{
				eDoc = (Element) xelDocs.item(n);
				
				sVolumeID = XmlUtil.getChildCDataValue(eDoc, "VolumeID");
				sVolumeHeading = XmlUtil.getChildCDataValue(eDoc, "VolumeHeading");
				
				sChapterID = XmlUtil.getChildCDataValue(eDoc, "ChapterID");
				sChapterHeading = XmlUtil.getChildCDataValue(eDoc, "ChapterHeading");
				
				sPageID = XmlUtil.getChildCDataValue(eDoc, "PageID");
				sPageHeading = XmlUtil.getChildCDataValue(eDoc, "PageHeading");
				%>
					<tr>
						<td colspan="2" align="left" valign="middle"><img src="../../images/blank.gif" width="1" height="3" border="0"></td>
					</tr>
					<tr>
						<td colspan="2" align="left" valign="middle" style="padding:4px;"><a target="_parent" href="faq_frame.jsp?topic=vl<%= sVolumeID %>-ch<%= sChapterID %>-pg<%= sPageID %>&faq_id=<%= sPageID %>&findCriteria=<%= findCriteria %>"><img src="imgs/16_helpDoc.gif" border="0" align="left"><%= sPageHeading %></a></td>
					</tr>
					<tr>
						<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
						<td align="left" valign="middle" style="color:#676767;"><i><%= sChapterHeading %></i></td>
					</tr>
					<tr>
						<td colspan="2" align="left" valign="middle" bgcolor="#333399"><img src="../../images/blank.gif" width="1" height="1" border="0"></td>
					</tr>
				<%
			
			}
		}
		else
		{
			%>
					<tr>
						<td colspan="2" style="font-weight:normal;">
							No results were found that matched the query <b><%= findCriteria %></b>.<br><br>
							Try the following to improve your search:
							<br>
							<br>
								<table width="100%" cellspacing="0" cellpadding="0">
									<tr><td><li></td><td style="padding-bottom:5px;">Type a more specific search word or phrase.</td></tr>
									<tr><td><li></td><td style="padding-bottom:5px;">Check your spelling.</td></tr>
									<tr><td><li></td><td style="padding-bottom:5px;">Wrap your query in quotes. For example: "Import a file"</td></tr>
								</table>
							</span>
						</td>
					</tr>
			<%
		}
	}
	else
	{
		%>
					<tr>
						<td colspan="2" style="font-weight:normal;">
							No results were found that matched the query <b><%= findCriteria %></b>.<br><br>
							Try the following to improve your search:
							<br>
							<br>
								<table width="100%" cellspacing="0" cellpadding="0">
									<tr><td><li></td><td style="padding-bottom:5px;">Type a more specific search word or phrase.</td></tr>
									<tr><td><li></td><td style="padding-bottom:5px;">Check your spelling.</td></tr>
									<tr><td><li></td><td style="padding-bottom:5px;">Wrap your query in quotes. For example: "Import a file"</td></tr>
								</table>
							</span>
						</td>
					</tr>
		<%
	}
}
catch(Exception ex)
{
	%>
					<tr>
						<td colspan="2" style="font-weight:normal;padding:4px;">
							No results were found.<br><br>
							<span class="err">
							The query <b><%= findCriteria %></b> was not specific enough to search on. Try the following to improve your search:
							<br>
							<br>
								<table width="100%" cellspacing="0" cellpadding="0" class="err">
									<tr><td><li></td><td style="padding-bottom:5px;">Type a more specific search word or phrase.</td></tr>
									<tr><td><li></td><td style="padding-bottom:5px;">Check your spelling.</td></tr>
									<tr><td><li></td><td style="padding-bottom:5px;">Wrap your query in quotes. For example: "Import a file"</td></tr>
								</table>
							</span>
						</td>
					</tr>
	<%
}
finally
{
	//nothing
}
%>
				</table>
			</div>
		</td>
	</tr>
</table>		
</body>
</html>	
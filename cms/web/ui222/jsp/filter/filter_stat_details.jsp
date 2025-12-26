<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.tgt.*,
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

AccessPermission can = user.getAccessPermission(ObjectType.FILTER);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>

<%
String sAction = BriteRequest.getParameter(request, "a");
if(sAction == null) sAction = "queue";

String sFilterId = BriteRequest.getParameter(request, "filter_id");
if(sFilterId == null) return;

FilterStatDetails csds = new FilterStatDetails();
csds.s_filter_id = sFilterId;
csds.retrieve();

String sRecipType = "";
String stepDesc = "";

if ("queue".equals(sAction))
{
	stepDesc = "Queued Count Details";
}
else
{
	stepDesc = "Calculated Recipient Statistics";
}
%>
<HTML>
<HEAD>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<title>Filter: <%= stepDesc %></title>
	<script language="javascript">
		
		function window.onload()
		{
			window.resizeTo(450, 450);
		}
	</script>
</HEAD>
<BODY>
<br>
<!--- Header----->
<table width=100% class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Filter:</b> <%= stepDesc %></td>
	</tr>
</table>
<br>
<!---- Info----->
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
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
					<%
					if(csds.size() == 0)
					{
						%>
						A detailed break down of the number of queued recipients is unavailable.
						<%
					}
					else
					{
						%>
						<table class="main" cellspacing=0 cellpadding=3 border=0>
						<%
						String sClassAppend = "";
						int iCount = 0;
						
						String sName = "";
						String sValue = "";
						
						String oldName = "";
						String oldValue = "";
						String appExp = "Export";
						boolean showExp = false;
						
						FilterStatDetail csd = null;
						for (Enumeration e = csds.elements() ; e.hasMoreElements() ;)
						{
							csd = (FilterStatDetail)e.nextElement();
							
							if (iCount % 2 != 0) sClassAppend = "_Alt";
							else sClassAppend = "";
							
							iCount++;
							
							oldName = sName;
							oldValue = sValue;
							
							sName = HtmlUtil.escape(csd.s_detail_name);
							sValue = HtmlUtil.escape(csd.s_integer_value);
							%>
							<tr>
								<td class="listItem_Data<%= sClassAppend %>" align=left><%= (sName.indexOf("Count") >= 1)?"<b>" + sName + "</b>":sName %></td>
							<%
								if ( (sName.equals("Unsubscribe Exclusions")) || (sName.equals("Ineligible Recipients")) || (sName.equals("Bounceback Exclusions"))  )
								{ 
									if (sName.equals("Bounceback Exclusions"))
										sRecipType = "TgtBBack";
									if (sName.equals("Unsubscribe Exclusions"))
										sRecipType = "TgtUnsub";										
									if (sName.equals("Ineligible Recipients"))
										sRecipType = "TgtIneligible";										
							%>
									<td class="listItem_Data<%= sClassAppend %>" align=right><nobr><a href="filter_stat_export_new.jsp?filter_id=<%= sFilterId %>&sRecipType=<%=sRecipType%>"><%=sValue%></a></nobr></td>
							<%	} else { %>
									<td class="listItem_Data<%= sClassAppend %>" align=right><nobr><%= sValue %></nobr></td>
							<%	} sRecipType = ""; %>							
							</tr>
								<%
						
						}
						%>
						</table>
						<%
					}
					%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>

</BODY>
</HTML>

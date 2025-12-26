<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.util.*,
			java.net.*,org.w3c.dom.*,
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

Statement	stmt;
ResultSet	rs; 
ConnectionPool 	cp 	= null;
Connection 	conn 	= null;
int	nStep = 1;

try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("super_link_scan.jsp");
	stmt  = conn.createStatement();
} catch(Exception ex) {
	cp.free(conn);
	out.println("<BR>Connection error ... !<BR><BR>"); 
	return;
}

String superCampID = request.getParameter("super_camp_id");
String sSql = null;
int nLinks = 0;

String sSelectedCategoryId = request.getParameter("category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;

try {
	if (superCampID == null) 
		throw new Exception ("No Super Campaign specified!");

%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left">
			<a class="savebutton" href="#" onclick="Try_Submit();">Save</a>&nbsp;&nbsp;&nbsp;
		</td>
		<td vAlign="middle" align="left">
			&nbsp;&nbsp;&nbsp;<a class="subactionbutton" href="super_camp_object.jsp?super_camp_id=<%= superCampID %>">Cancel &amp; Go Back</a>
		</td>
	</tr>
</table>
<br>

<FORM  METHOD="POST" NAME="FT" ACTION="super_link_scan_save.jsp" TARGET="_self">
<input type=hidden name=super_camp_id value=<%= superCampID %>>
<%=(sSelectedCategoryId!=null)?"<INPUT type=\"hidden\" name=\"category_id\" value=\""+sSelectedCategoryId+"\">":""%>

<%
String sCampList = "";

sSql = "SELECT c.camp_id FROM cque_campaign c, cque_super_camp_camp s"
	+ " WHERE c.origin_camp_id = s.camp_id"
	+ " AND c.type_id > "+CampaignType.TEST
	+ " AND s.super_camp_id = "+superCampID;
	
rs = stmt.executeQuery(sSql);

while (rs.next())
{
	sCampList += ((sCampList.length() > 0)?",":"")+rs.getString(1);
}

out.print("<!-- "+sCampList+" -->");

boolean bAllCampsSent = false;

if (sCampList.length() > 0)
{

	sSql = "SELECT count(s.camp_id) FROM cque_super_camp_camp s"
		+ " WHERE s.super_camp_id = "+superCampID
		+ " AND s.camp_id NOT IN (SELECT c.origin_camp_id FROM cque_campaign c"
				+" WHERE c.camp_id IN ("+ sCampList +"))";

	int nCampsNotSent = 0;
	rs = stmt.executeQuery(sSql);
	
	if (rs.next())
	{
		nCampsNotSent = rs.getInt(1);
	}

	bAllCampsSent = (nCampsNotSent == 0);

	%>
	<table width=650 class=main cellspacing=0 cellpadding=0>
		<tr>
			<td class=sectionheader>&nbsp;<B>Links Grouped by Name</B></td>
		</tr>
	</table>
	<br>
	<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
		<tr>
			<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
		</tr>
		<tr>
			<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
		</tr>
		<tbody class=EditBlock id=block1_Step1>
		<tr>
			<td class=fillTab valign=top align=left width=650>
	<%
	int nHrefLinks = nLinks;
	
	String sLastLinkName = "";
	
	sSql = "SELECT l.link_id, l.link_name, l.href, c.camp_name" +
			" FROM cque_campaign c, cjtk_link l" +
			" WHERE c.camp_id IN (" + sCampList + ") " +
			" AND l.cont_id = c.cont_id" +
			" AND l.href IS NOT NULL" +
			" ORDER BY l.link_name, c.camp_id";
			
	rs = stmt.executeQuery(sSql);
	
	while (rs.next())
	{

		String sLinkID = rs.getString(1);
		String sLinkName = rs.getString(2);
		String sLinkHref = rs.getString(3);
		String sCampName = rs.getString(4);

		if (!sLinkName.equals(sLastLinkName))
		{
			nLinks++;
			
			if (nLinks > (nHrefLinks+1))
			{
				%>
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
				<br>
				<%
			}
			%>
				<table class=main cellspacing=1 cellpadding=2 width="100%">
					<tr>
						<td align="center" valign="top"><INPUT type="checkbox" name="super_link_id" value="<%=nLinks%>"></td>
						<td align="left valign="top" width="100%">
							Super campaign link name: 
							<input type="text" name="sl<%=nLinks%>_super_link_name" size="30" maxlength="50" value="<%= sLinkName %>">
							<br>
							<table width=100% cellpadding=2 cellspacing=0 border=0>
								<tr>
									<td>
			<%
		}
		sLastLinkName = sLinkName;
		%>
										<input type="checkbox" name="sl<%=nLinks%>_link_id" value="<%=sLinkID%>" checked>
										<%=sLinkName%> : <a href="<%=sLinkHref%>" target="_new"><%=sLinkHref%></a> (<%=sCampName%>)<BR>
		<%
	}
	%>
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		</tbody>
	</table>
	<br><br>

	<table width=650 class=main cellspacing=0 cellpadding=0>
		<tr>
			<td class=sectionheader>&nbsp;<B>Links Grouped by URL</B></td>
		</tr>
	</table>
	<br>
	<table id="Tabs_Table2" cellspacing=0 cellpadding=0 width=650 border=0>
		<tr>
			<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
		</tr>
		<tr>
			<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
		</tr>
		<tbody class=EditBlock id=block2_Step1>
		<tr>
			<td class=fillTab valign=top align=left width=650>
		<%
		int nNameLinks = nLinks;
		
		String sLastLinkHref = "";
		
		sSql = "SELECT l.link_id, l.link_name, l.href, c.camp_name" +
				" FROM cque_campaign c, cjtk_link l" +
				" WHERE c.camp_id IN (" + sCampList + ") " +
				" AND l.cont_id = c.cont_id" +
				" AND l.href IS NOT NULL" +
				" ORDER BY l.href, c.camp_id";
				
		rs = stmt.executeQuery(sSql);
		
		while (rs.next())
		{

			String sLinkID = rs.getString(1);
			String sLinkName = rs.getString(2);
			String sLinkHref = rs.getString(3);
			String sCampName = rs.getString(4);

			if (!sLinkHref.equals(sLastLinkHref))
			{
				nLinks++;
				
				if (nLinks > (nNameLinks+1))
				{
					%>
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
				<br>
					<%
				}
				%>
				<table class=main cellspacing=1 cellpadding=2 width="100%">
					<tr>
						<td align="center" valign="top"><INPUT type="checkbox" name="super_link_id" value="<%=nLinks%>"></td>
						<td align="left valign="top" width="100%">
							Super campaign link name: 
							<input type="text" name="sl<%=nLinks%>_super_link_name" size="30" maxlength="50" value="<%= sLinkName %>">
							<br>
							<table width=100% cellpadding=2 cellspacing=0 border=0>
								<tr>
									<td>
				<%
			}
			sLastLinkHref = sLinkHref;
			
			%>
										<INPUT type="checkbox" name="sl<%=nLinks%>_link_id" value="<%=sLinkID%>" checked>
										<%=sLinkName%> : <a href="<%=sLinkHref%>" target="_new"><%=sLinkHref%></a> (<%=sCampName%>)<BR>
			<%
		}
		%>
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		</tbody>
	</table>
	<br><br>


<INPUT type="hidden" name="num_links" value="<%=nLinks%>">
<%
	}
%>
</FORM>
<SCRIPT>

function Try_Submit ()
{

	var nChecked = 0;
	var nLinks = 0;
	if (<%=nLinks%> == 1) {
		 if (FT.super_link_id.checked == true) {
		 	nChecked++;

			nLinks = 0;			
			if (eval("FT.sl"+FT.super_link_id.value+"_link_id.length") == undefined) {
				if (eval("FT.sl"+FT.super_link_id.value+"_link_id.checked") == true) nLinks++;
			} else {
				for (var j=0; j<eval("FT.sl"+FT.super_link_id.value+"_link_id.length"); j++) {
					if (eval("FT.sl"+FT.super_link_id.value+"_link_id["+j+"].checked") == true) nLinks++;
				}
			}

			if (nLinks < 1) { 
				alert("You must choose at least one component link for \""+eval("FT.sl"+FT.super_link_id.value+"_super_link_name.value")+"\""); 
				eval("FT.sl"+FT.super_link_id.value+"_super_link_name.focus()");
				return false; 
			}		
		}
	} else {
		for (var i=0; i<<%=nLinks%>; i++) {
			 if (FT.super_link_id[i].checked == true) {
			 	nChecked++;

				nLinks = 0;			
				if (eval("FT.sl"+FT.super_link_id[i].value+"_link_id.length") == undefined) {
					if (eval("FT.sl"+FT.super_link_id[i].value+"_link_id.checked") == true) nLinks++;
				} else {
					for (var j=0; j<eval("FT.sl"+FT.super_link_id[i].value+"_link_id.length"); j++) {
						if (eval("FT.sl"+FT.super_link_id[i].value+"_link_id["+j+"].checked") == true) nLinks++;
					}
				}

				if (nLinks < 1) { 
					alert("You must choose at least one component link for \""+eval("FT.sl"+FT.super_link_id[i].value+"_super_link_name.value")+"\""); 
					eval("FT.sl"+FT.super_link_id[i].value+"_super_link_name.focus()");
					return false; 
				}		
			}
		}
	}
	if (nChecked < 1) { alert("You must choose at least one link"); return false; }

	FT.submit();

}


</SCRIPT>

<%=(!bAllCampsSent?"*** Links can only be selected for campaigns that have been sent ***":"")%>

</HTML>
<%
	} catch(Exception ex) {
		ErrLog.put(this,ex,"super_camp_edit.jsp",out,1);
		return;
	} finally {
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}
%>

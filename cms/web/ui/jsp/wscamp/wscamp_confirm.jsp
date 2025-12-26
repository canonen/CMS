<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.xcs.*,
			com.britemoon.cps.xcs.dts.*,
			com.britemoon.cps.xcs.dts.ws.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.wfl.*,
			org.w3c.dom.*,java.util.*,
			java.sql.*,java.net.*,java.text.*,
			java.io.*,java.text.DateFormat,
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

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

// Get all component objects needed to display all Campaign data from web services
String sCampId = request.getParameter("camp_id");
String sWsCampId = request.getParameter("ws_camp_id");

// run WS to get campaign info
logger.info("calling web service to retrieve datran campaign info for id = " + sWsCampId);
CampaignInfoListCode campInfoListCode = null;
CustResource res = new CustResource(cust.s_cust_id, String.valueOf(CustResourceType.WEB_SERVICE));
try {

	GetCampaignInfoListCodeWS ws = new GetCampaignInfoListCodeWS();
	campInfoListCode = ws.getCampaignInfoListCode(cust.s_cust_id, sWsCampId, res);
}
catch (Exception ex) {
	logger.error("Got web service exception: " + ex.getMessage());
	throw ex;
}

if (campInfoListCode == null) {
	logger.error("Unexpected error in wscamp_confirm.jsp");
	throw new Exception("Unexpected error in wscamp_confirm.jsp");
}

// required campaign variables
String sCampName = campInfoListCode.getCampaignName();
String sSubject = campInfoListCode.getHeaders().getSubject();
String sFromName = campInfoListCode.getHeaders().getFromAlias();
String sFromAddress = campInfoListCode.getHeaders().getFromAddress();
String sResponseFrwdAddr = campInfoListCode.getHeaders().getFromAddress();
String sContentName = campInfoListCode.getContentID();
String sTextBody = campInfoListCode.getTextBody();
String sHtmlBody = campInfoListCode.getHtmlBody();
String sWsSealId = campInfoListCode.getClickSeal(); 
String sFromAddressId = "";
String sStartDate = "";

// fix campaign variables
String sFromAddressDisplay = sFromAddress;
DateFormat fmt = new SimpleDateFormat("MMddyy");
java.util.Date startDate = fmt.parse(campInfoListCode.getLaunchDate());
sStartDate =  DateFormat.getDateTimeInstance().format(startDate);

ConnectionPool	cp   = null;
Connection		conn = null;
Statement		stmt = null;
ResultSet       rs   = null;
String          sql  = null;
try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();
	
	// look up from address id
	String sFromPrefix = sFromAddress.substring(0, sFromAddress.indexOf('@'));
	String sFromDomain = sFromAddress.substring(1 + sFromAddress.indexOf('@'));
	sql =
		"SELECT fa.from_address_id, fa.prefix, fa.domain" +
		"  FROM ccps_from_address fa" +
		" WHERE fa.cust_id="+cust.s_cust_id +
		"   AND lower(fa.domain) = lower('" + sFromDomain + "')" +
		"   AND lower(fa.prefix) = lower('" + sFromPrefix + "')";
	rs = stmt.executeQuery(sql);
	if (rs.next()) {
		sFromAddressId = rs.getString(1);
		sFromPrefix = rs.getString(2);
		sFromDomain = rs.getString(3);
		sFromAddressDisplay = sFromPrefix + "@" + sFromDomain;
		sFromAddress = "";
	}
	rs.close();
	if (sFromAddressId == null || sFromAddressId.equals("")) {
		// try closest match
		sql =
			"SELECT fa.from_address_id, fa.prefix, fa.domain" +
			"  FROM ccps_from_address fa" +
			" WHERE fa.cust_id="+cust.s_cust_id +
			"   AND lower(fa.domain) like lower('%." + sFromDomain + "')" +
			"   AND lower(fa.prefix) = lower('" + sFromPrefix + "')";
		rs = stmt.executeQuery(sql);
		if (rs.next()) {
			sFromAddressId = rs.getString(1);
			sFromPrefix = rs.getString(2);
			sFromDomain = rs.getString(3);
			sFromAddressDisplay = sFromPrefix + "@" + sFromDomain;
			sFromAddress = "";
		}
		rs.close();
	}

	logger.info("from address prefix = " + sFromPrefix);
	logger.info("from address domain = " + sFromDomain);
	logger.info("from address id = " + sFromAddressId);
		
%>
<HTML>
<HEAD>
	<BASE target="_self">
	<%@ include file="../header.html"%>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>
<BODY>

<FORM METHOD="POST" NAME="FT" ACTION="wscamp_save.jsp" TARGET="_self">
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Campaign:</b> Save Confirmation</td>
	</tr>
</table>
<br>
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTab valign=top align=center width=100%>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px; font-size:14pt;">
						Please confirm all Campaign details before saving
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<br>

<table id="Tabs_Table2" cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="EmptyTab" valign="center" nowrap align="middle" width="100%"><img height="2" src="../../images/blank.gif" width="1"></td>
	</tr>
	<tr>
		<td class="fillTabbuffer" valign="top" align="left" width="100%"><img height="2" src="../../images/blank.gif" width="1"></td>
	</tr>
	<tr>
		<td class="fillTab" valign="top" align="center" width="100%">
			<table class="main" cellspacing="1" cellpadding="2" width="100%">
				<tr>
					<td width="125" height="25" align="left" valign="middle">Campaign Name: </td>
					<td width="425" height="25" align="left" valign="middle"><%=HtmlUtil.escape(sCampName)%></td>
					<input type="hidden" name="camp_name" value="<%=HtmlUtil.escape(sCampName)%>" />
					<input type="hidden" name="ws_camp_id" value="<%=HtmlUtil.escape(sWsCampId)%>" />
					<input type="hidden" name="ws_seal_id" value="<%=HtmlUtil.escape(sWsSealId)%>" />
				</tr>
				<tr>
					<td width="125" height="25" align="left" valign="middle">Subject: </td>
					<td width="425" height="25" align="left" valign="middle"><%=HtmlUtil.escape(sSubject)%> </td>
					<input type="hidden" name="subj_html" value="<%=HtmlUtil.escape(sSubject)%>" />
					<input type="hidden" name="subj_text" value="<%=HtmlUtil.escape(sSubject)%>" />
				</tr>
				<tr>
					<td width="125" height="25">From Name: </td>
					<td width="425" height="25"><%= HtmlUtil.escape(sFromName) %> </td>
					<input type="hidden" name="from_name" value="<%= HtmlUtil.escape(sFromName) %>" />
				</tr>
				<tr>
					<td width="125" height="25">From Address: </td>
					<td width="425" height="25"><%= HtmlUtil.escape(sFromAddressDisplay) %> </td>
					<input type="hidden" name="from_address" value="<%= HtmlUtil.escape(sFromAddress) %>" />
					<input type="hidden" name="from_address_id" value="<%= HtmlUtil.escape(sFromAddressId) %>" />
				</tr>
				<tr>
					<td width="125" height="25">Content: </td>
					<td width="425" height="25">
						<%= HtmlUtil.escape(sContentName) %>
					</td>
					<input type="hidden" name="content_name" value="<%= HtmlUtil.escape(sContentName) %>" />
					<input type="hidden" name="text_body" value="<%= HtmlUtil.escape(sTextBody) %>" />
					<input type="hidden" name="html_body" value="<%= HtmlUtil.escape(sHtmlBody) %>" />
				</tr>
				<tr>
					<td width="150">Target Group</td>
					<td>
						<select name="filter_id" size="1">
						<option value="">-----  Choose Target Group  -----</option>
						<%=getFilterOptionsHtml(stmt, cust.s_cust_id, (String) null, (String) null)%>
						</select>
					</td>
				</tr>
				<tr>
					<td width="125" height="25">Response Forwarding: </td>
					<td width="425" height="25"><%= HtmlUtil.escape(sResponseFrwdAddr) %></td>
					<input type="hidden" name="response_frwd_addr" value="<%= HtmlUtil.escape(sResponseFrwdAddr) %>" />
				</tr>
				<tr>
					<td width="125" height="25">Send Start Date: </td>
					<td width="425" height="25"><%= (sStartDate == null)?"NOW":HtmlUtil.escape(sStartDate) %> </td>
					<input type="hidden" name="start_date" value="" />
					<input type="hidden" name="launch_date" value="<%= HtmlUtil.escape(sStartDate) %>" />
				</tr>
			</table>
		</td>
	</tr>
</table>
<br>


<table id="Tabs_Table3" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=100%><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTab valign=top align=center width=100%>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" width="50%" style="padding:5px;">
						<table cellspacing="0" cellpadding="3" border="0">
							<tr>
								<td align="center" width="50%">
									<a class="subactionbutton" href="javascript:doEdit();"><< Go Back To Edit</a>
								</td>
								<td align="center" width="50%">
									<a class="actionbutton" href="javascript:doSave();">Confirm >> Save Campaign</a>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</FORM>

<SCRIPT>

function doSave()
{
	FT.action="wscamp_save.jsp";
	FT.submit();
}

function doEdit()
{
	FT.action = "wscamp_edit.jsp?ws_camp_id=<%=sWsCampId%>";
	FT.submit();
}

</SCRIPT>


</BODY>
</HTML>

<%
}
catch(Exception ex)
{ 
	ErrLog.put(this,ex, "Problem with WS Campaign.",out,1);
}
finally
{
	if ( stmt != null ) stmt.close();
	if ( conn  != null ) cp.free(conn); 
}
%>
<%@ include file="../camp/camp_edit/functions.jsp"%>
<%@ include file="../camp/camp_edit/calendar.jsp"%>


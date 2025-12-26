<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.upd.*,
			com.britemoon.cps.xcs.*,
			com.britemoon.cps.xcs.dts.*,
			com.britemoon.cps.xcs.dts.ws.*,
			java.util.*,
			java.sql.*,
			java.net.*,
			java.text.*,
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

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>

<%

String sAction = BriteRequest.getParameter(request, "a");
if(sAction == null) sAction = "queue";

String sCampId = BriteRequest.getParameter(request, "camp_id");
String sWsSentCountFlag = BriteRequest.getParameter(request, "ws_sent_count_flag");

if(sCampId == null) return;

//Connection
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

    boolean bDomainCount = false;
    Vector vDomainCount = new Vector();

    CampStatDetails csds = new CampStatDetails();
    csds.s_camp_id = sCampId;
    csds.retrieve();

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
	<title>Campaign: <%= stepDesc %></title>
	<script language="javascript">
		
		function window.onload()
		{
			window.resizeTo(450, 700);
		}
		
		function doSendCountWS()
		{
			FT.submit();
		}
	</script>
</HEAD>
<BODY>
<FORM METHOD="POST" NAME="FT" ACTION="camp_stat_details.jsp" TARGET="_self">
<!--- Header----->
<table width=100% class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Campaign:</b> <%= stepDesc %></td>
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
						<!--<p>The number of recipients queued for this campaign is the result of numerous processes which remove unsubscribed recipients, append Seed Lists, etc. 
						The Queued Count Details below illustrate how the number of records was calculated for this campaign.</p>//-->
					<%
					if(csds.size() == 0)
					{
						%>
						A detailed break down of the number of queued recipients is unavailable for this campaign.
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
						
						CampStatDetail csd = null;
						for (Enumeration e = csds.elements() ; e.hasMoreElements() ;)
						{
							csd = (CampStatDetail)e.nextElement();
							
							if (iCount % 2 != 0) sClassAppend = "_Alt";
							else sClassAppend = "";
							
							iCount++;
							
							oldName = sName;
							oldValue = sValue;
							
							sName = HtmlUtil.escape(csd.s_detail_name);
							sValue = HtmlUtil.escape(csd.s_integer_value);
							
							if ("Step".equals(sName.substring(0, 4)))
							{
								if ("Step 1".equals(sName))
								{
									sName = "Step 1: Target Group Calculations";
								}
								else if ("Step 2".equals(sName))
								{
									sName = "Step 2: Campaign Calculations";
								}
								else if ("Step 3".equals(sName))
								{
									sName = "Step 3: Final Campaign Count (including Seed List)";
								}
								else if ("Step Misc".equals(sName))
								{
									sName = "Misc: Campaign Calculations By Domain";
									bDomainCount = true;
								}								
								if (iCount != 1)
								{
									%>
							<tr>
								<td class="listItem_Data" colspan="2">&nbsp;</td>
							</tr>
									<%
								}
								%>
							<tr>
								<th colspan="2"><%= sName %></th>
							</tr>
								<%
								if (!("".equals(oldName)))
								{
									%>
							<tr>
								<td class="listItem_Data_Alt" align=left><%= oldName %></td>
								<td class="listItem_Data_Alt" align=right><%= oldValue %></td>
							</tr>
								<%
								}
								
								iCount = 0;
							}
							else
							{
								if (bDomainCount) {
									logger.info("Found: '" + csd.s_detail_name.substring(10) + "' => '" + csd.s_integer_value + "'");
									SentInfo si = new SentInfo();
									si.setDomain(csd.s_detail_name.substring(10));
									try {
										si.setCount(Integer.parseInt(csd.s_integer_value));
									}
									catch (Exception ex) {
										si.setCount(0);
									}
									vDomainCount.add(si);
									logger.info("Domain Sent Count for: " + si.getDomain() + " => " + si.getCount());
								}
								%>
							<tr>
								<td class="listItem_Data<%= sClassAppend %>" align=left><%= (sName.indexOf("Count") >= 1)?"<b>" + sName + "</b>":sName %></td>
								<td class="listItem_Data<%= sClassAppend %>" align=right><nobr><%= sValue %></nobr></td>
							</tr>
								<%
							}
						}
						if (bDomainCount) {
							%>
							<tr>
								<td class="listItem_Data<%= sClassAppend %>" align=middle colspan=2>
									<input type=hidden name="camp_id" value="<%= sCampId %>"/>
									<input type=hidden name="ws_sent_count_flag" value="1"/>
									<a class="actionbutton" href="javascript:doSendCountWS();">Send Domain Count via WS</a>
								</td>
							</tr>
							<%
						}
						//run WS to sent domain count
						if (sWsSentCountFlag != null && sWsSentCountFlag.equals("1")) {
							
							// find associated ws camp id for this campaign (using origin_camp_id)
							String sWsCampId = null;
							Campaign camp = new Campaign(sCampId);
							sql = "SELECT ws_camp_id from cxcs_ws_campaign WHERE cust_id = " + camp.s_cust_id + " AND camp_id = " + camp.s_origin_camp_id;
							rs = stmt.executeQuery(sql);
							if (rs.next()) {
				   				sWsCampId = rs.getString(1);
				   				logger.info("Found ws_camp_id " + sWsCampId + " for camp_id = " + camp.s_camp_id);
							}
							else {
								logger.info("didn't find ws_camp_id using " + sql);
							}
				    		rs.close();
							logger.info("calling web service to update send count for id = " + sWsCampId);
							
							// use campaign start date as sentDate
							java.util.Date campStartDate = null;
							rs = stmt.executeQuery("SELECT start_date FROM cque_schedule WHERE camp_id = " + sCampId);
							if (rs.next()) {
								campStartDate = rs.getDate(1);
							}
							rs.close();
							logger.info("sentDate [campStartDate] = " + campStartDate);

							try {
								UpdateSentCountWS ws = new UpdateSentCountWS();
								Calendar sentDate = Calendar.getInstance();
								sentDate.setTime(campStartDate);
								SentInfo[] sentInfo = new SentInfo[vDomainCount.size()];
								vDomainCount.copyInto(sentInfo);
								String confirmationEmail = Registry.getKey("datran_confirmation_email");
								logger.info("confirmation email = " + confirmationEmail);
								for (int n=0; n < sentInfo.length; n++) {
									logger.info("sentInfo[" + n + "] " + sentInfo[n].getDomain() + " = " + sentInfo[n].getCount());
								}
								CustResource res = new CustResource(cust.s_cust_id, String.valueOf(CustResourceType.WEB_SERVICE));
								ws.updateSentCount(cust.s_cust_id, sWsCampId, res, sentDate, sentInfo, confirmationEmail);
							}
							catch (Exception ex) {
								logger.error("Got web service exception: " + ex.getMessage());
								throw ex;
							}
							%>
							<tr>
								<td class="listItem_Data<%= sClassAppend %>" align=middle colspan=2>
									<font color="red">
										<b>Domain Count has been sent via Web Service</b>
									</font>
								</td>
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
</FORM>
</BODY>
</HTML>
<%
}
catch(Exception ex)
{ 
	ErrLog.put(this,ex, "Problem with camp_stat_details.",out,1);
}
finally
{
	if ( stmt != null ) stmt.close();
	if ( conn  != null ) cp.free(conn); 
}
%>

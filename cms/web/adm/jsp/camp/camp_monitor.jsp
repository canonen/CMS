<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.imc.*" 
	import="java.sql.*"
	import="java.util.*" 
	import="org.w3c.dom.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp"%>

<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

String wantXmlFlag = request.getParameter("want_xml");
boolean wantXml = (wantXmlFlag != null && wantXmlFlag.equals("1"));
StringBuffer xml = new StringBuffer();

Statement 		stmt	= null;
ResultSet 		rs		= null; 
ConnectionPool 	cp		= null;
Connection 		conn	= null;

try {
	String sql = "";

	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("camp_monitor.jsp");
	stmt = conn.createStatement();
	
	String custID = request.getParameter("cust_id");
	if (custID == null) custID = "0";
	String typeID = request.getParameter("type_id");
	if (typeID == null) typeID = "0";

	String sAction = request.getParameter("action");
	if (sAction != null)
	{
		String cID = request.getParameter("camp_id");
	
		if (sAction.equals("approve"))
		{
			sql = "UPDATE cque_campaign SET approval_flag = 1 WHERE camp_id = "+cID;
		}
		else if (sAction.equals("suspend"))
		{
			sql = "UPDATE cque_campaign SET approval_flag = null WHERE camp_id = "+cID;
		}
		
		if (sql.length() > 0) stmt.executeUpdate(sql);
	}
	
	if (!wantXml) {
%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>
<BODY>
	
<FORM  METHOD="GET" NAME="FT" ACTION="camp_monitor.jsp" TARGET="_self">
Customer ID: (0 for all) <INPUT name="cust_id" size=10 type="text" value="<%= custID %>">
Campaign Type:
<SELECT name="type_id">
<OPTION value=0>All</OPTION>
<OPTION value=1 <%= (typeID.equals("1")?"selected":"") %>>Test</OPTION>
<OPTION value=2 <%= (typeID.equals("2")?"selected":"") %>>Standard</OPTION>
<OPTION value=3 <%= (typeID.equals("3")?"selected":"") %>>Send to friend</OPTION>
<OPTION value=4 <%= (typeID.equals("4")?"selected":"") %>>Auto-respond</OPTION>
</SELECT>
<INPUT TYPE=submit>
</FORM>
<% 
	}
	//Get a list of current campaigns that are not done and not errorred
	String campID;
	String campIDs = "";
	Vector vCamps = new Vector();
	String[] campInfo;

	sql =
		" SELECT c.camp_id, c.status_id, c.type_id, c.cust_id, c.camp_name," +
			" t.display_name, s.display_name, cei.create_date, cc.cust_name," +
			" c.approval_flag, p.queue_date, e.start_date, cn.cont_name, f.filter_name," +
			" cs.recip_sent_qty, cs.recip_queued_qty, cei.modify_date, e.end_date" +
		" FROM cque_campaign c WITH(NOLOCK)" +
			" INNER JOIN cque_camp_edit_info cei WITH(NOLOCK)" +
				" ON cei.camp_id = c.camp_id" +
			" INNER JOIN cque_camp_status s WITH(NOLOCK)" +
				" ON s.status_id = c.status_id" +
			" INNER JOIN cque_camp_type t WITH(NOLOCK)" +
				" ON t.type_id = c.type_id" +
			" INNER JOIN ccps_customer cc WITH(NOLOCK)" +
				" ON cc.cust_id = c.cust_id" +
			" INNER JOIN cque_camp_send_param p WITH(NOLOCK)" +
				" ON p.camp_id = c.camp_id" +
			" INNER JOIN cque_schedule e WITH(NOLOCK)" +
				" ON e.camp_id = c.camp_id" +
			" INNER JOIN ccnt_content cn WITH(NOLOCK)" +
				" ON cn.cont_id = c.cont_id" +
			" INNER JOIN ctgt_filter f WITH(NOLOCK)" +
				" ON f.filter_id = c.filter_id" +
			" LEFT OUTER JOIN cque_camp_statistic cs WITH(NOLOCK)" +
				" ON c.camp_id = cs.camp_id" +
		" WHERE c.status_id < 60" +
			" AND c.cust_id <> 619 " +
			" AND c.status_id > 0" +
			(!"0".equals(custID)?" AND c.cust_id = "+custID:"") +
			(!"0".equals(typeID)?" AND c.type_id = "+typeID:"") +
		" ORDER BY c.type_id, c.cust_id, cei.create_date";

	rs = stmt.executeQuery(sql);
	while (rs.next()) {
		campInfo = new String[18];
		campID = rs.getString(1);
		campInfo[0] = campID;
		campInfo[1] = rs.getString(2);
		campInfo[2] = rs.getString(3);
		campInfo[3] = rs.getString(4);
		campInfo[4] = rs.getString(5);
		campInfo[5] = rs.getString(6);
		campInfo[6] = rs.getString(7);
		campInfo[7] = rs.getString(8);
		campInfo[8] = rs.getString(9);
		campInfo[9] = rs.getString(10);
		campInfo[10] = rs.getString(11);
		campInfo[11] = rs.getString(12);
		campInfo[12] = rs.getString(13);
		campInfo[13] = rs.getString(14);
		campInfo[14] = rs.getString(15);
		campInfo[15] = rs.getString(16);
		campInfo[16] = rs.getString(17);
		campInfo[17] = rs.getString(18);
		

		vCamps.add(campInfo);
		campIDs += ","+campID;
	}

	if (campIDs.length() > 0) campIDs = campIDs.substring(1);

	//Request camp info from rcp
	Vector services = Services.getByType(ServiceType.RQUE_CAMP_MONITOR);

	if (services.size() == 0)
	{
		if (!wantXml) {
%>
Must setup the RQUE_CAMP_MONITOR service
<%
		}
		else {
			out.println("<error>Must setup the RQUE_CAMP_MONITOR service</error>");
		}
		return;
	}
	Service service = (Service) services.get(0);

	String rcpURL = service.s_protocol+"://"+service.s_host+":"+service.s_port+"/rrcp/adm/jsp/chunk_monitor.jsp?camp_id=";

	service.connect();
	service.send("camp_ids="+campIDs);

	String res = service.receive();
	service.disconnect();
	
	Element e = XmlUtil.getRootElement(res);

	XmlElementList el = XmlUtil.getChildrenByName(e,"campaign");
	String statusID, schedPriority;
	Element oneCamp;
	Hashtable hCamps = new Hashtable();
	
	for (int i=0; i < el.getLength(); i++) {
		oneCamp = (Element)el.item(i);
		campID = XmlUtil.getChildTextValue(oneCamp, "camp_id");
		statusID = XmlUtil.getChildTextValue(oneCamp, "status_id");
		schedPriority = XmlUtil.getChildTextValue(oneCamp, "sched_priority");

		hCamps.put(campID+"s",statusID);
		hCamps.put(campID+"p",schedPriority);
		
	}

	if (!wantXml) {
%>

*** Note: Priority is only used for those campaigns in the <b><i>(10)Sent to RCP</i></b> status.
1 will be first, 10 will be last.  Default is 5. ***
<br>
<table border=1>
<tr>
<th>Customer</th><th>Camp Name</th><th>Camp ID</th>
<th>Type</th><th>Priority</th><th>Approved</th><th>Actual Status</th><th>CPS Status</th><th>RCP Status</th>
<th>Problem?</th><th>Executed Date</th><th>Queue Date</th><th>Schedule Start Date</th>
</tr>

<%
	}
	//Go through all of the camps in the vector
	String noString = "no";
	String yesString = "yes";
	
	String rcpStatusID, rcpStatusDisplay = "", problem = "", actualStatus;
	int iRcp, iCps;
	for (int i=0; i < vCamps.size(); ++i) {
		campInfo = (String[])vCamps.get(i);
		campID = campInfo[0];
		
		rcpStatusID = (String)hCamps.get(campID+"s");
		schedPriority = (String)hCamps.get(campID+"p");

		if (rcpStatusID != null) {
			rs = stmt.executeQuery("SELECT display_name FROM cque_camp_status WHERE status_id = "+rcpStatusID);
			rs.next();
			rcpStatusDisplay = rs.getString(1);
		} else {
			rcpStatusDisplay = "Not on RCP";
			schedPriority = "null";
		}
		
		//Figure out if there is a problem with the campaign statuses
		problem = "none";
		actualStatus = campInfo[6];
		if (rcpStatusID == null) {
			problem = "Campaign never got setup in RCP";
		} else {
			iRcp = Integer.parseInt(rcpStatusID);
			iCps = Integer.parseInt(campInfo[1]);
		
			if (iRcp != iCps) {
				if (iRcp == 30 && (iCps < 30 || iCps == 57)) {
					problem = "Campaign is stuck";	
					actualStatus = rcpStatusDisplay;
				} else if (iRcp >= 70) {
					actualStatus = rcpStatusDisplay;
				} else if (iRcp < 30) {
					actualStatus = rcpStatusDisplay;
				}
			}
		}
		if (!wantXml) {
			noString = "no <a href=?action=approve&camp_id="+campID+"&type_id="+typeID+"&cust_id="+custID+">approve</a>";
			yesString = "yes <a href=?action=suspend&camp_id="+campID+"&type_id="+typeID+"&cust_id="+custID+">suspend</a>";
		%>
		<tr>
		<td>(<%= campInfo[3] %>)<%= campInfo[8] %></td>
		<td><%= campInfo[4] %></td>		
		<td><a href="<%= rcpURL %><%= campID %>"><%= campID %></a></td>
		<td><%= campInfo[5] %></td>
		<td><%= schedPriority %></td>
		<td><%= (campInfo[9] == null || campInfo[9].equals("0")?noString:yesString) %></td>
		<td><%= actualStatus %></td>
		<td>(<%= campInfo[1] %>)<%= campInfo[6] %></td>
		<td>(<%= rcpStatusID %>)<%= rcpStatusDisplay %></td>
		<td><%= (problem.equals("none")?problem:"<font color=red>"+problem+"</font>") %></td>
		<td><%= campInfo[7] %></td>
		<td><%= campInfo[10] %></td>
		<td><%= campInfo[11] %></td>
		
		</tr>
		<%
		}
		else {
			noString = "no";
			yesString = "yes";
			xml.append("<campaign>\n");
			xml.append("<cust_id>"+ campInfo[3]+"</cust_id>\n");
			xml.append("<cust_name><![CDATA["+ campInfo[8]+"]]></cust_name>\n");
			xml.append("<camp_name><![CDATA["+ campInfo[4]+"]]></camp_name>\n");
			xml.append("<camp_id>"+ campID+"</camp_id>\n");
			xml.append("<camp_type>"+ campInfo[5]+"</camp_type>\n");
			xml.append("<priority>"+ schedPriority+"</priority>\n");
			xml.append("<approved><![CDATA["+ (campInfo[9] == null || campInfo[9].equals("0")?noString:yesString)+"]]></approved>\n");
			xml.append("<actual_status>"+ actualStatus+"</actual_status>\n");
			xml.append("<cps_status_id>"+ campInfo[1]+"</cps_status_id>\n");
			xml.append("<cps_status_name><![CDATA["+ campInfo[6]+"]]></cps_status_name>\n");
			xml.append("<rcp_status_id>"+ rcpStatusID+"</rcp_status_id>\n");
			xml.append("<rcp_status_name>"+ rcpStatusDisplay+"</rcp_status_name>\n");
			xml.append("<problem><![CDATA["+ problem+"]]></problem>\n");
			xml.append("<execute_date>"+ campInfo[7]+"</execute_date>\n");
			xml.append("<queue_date>"+ campInfo[10]+"</queue_date>\n");
			xml.append("<start_date>"+ campInfo[11]+"</start_date>\n");
			xml.append("<cont_name>"+ campInfo[12]+"</cont_name>\n");
			xml.append("<filter_name>"+ campInfo[13]+"</filter_name>\n");
			xml.append("<qty_queued>"+ campInfo[14]+"</qty_queued>\n");
			xml.append("<qty_sent>"+ campInfo[15]+"</qty_sent>\n");
			xml.append("<modify_date>"+ campInfo[16]+"</modify_date>\n");
			xml.append("<end_date>"+ campInfo[17]+"</end_date>\n");
			xml.append("</campaign>\n");
		}
	}
	if (!wantXml) {
%>
</table>

<%
	}
	} catch(Exception ex) {
	ErrLog.put(this,ex,"camp_monitor.jsp",out,1);
	return;
	} finally {
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn);
}
	if (!wantXml) {
%>
</BODY>
</HTML>
<% }
   else {
	   out.println("<campaigns>\n" + xml.toString() + "</campaigns>\n");
   }
%>
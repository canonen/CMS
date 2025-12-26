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
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="../../utilities/header.jsp"%>
<%@ include file="../../utilities/validator.jsp"%>
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

JsonObject object = new JsonObject();
JsonArray array = new JsonArray();

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



		String sClassAppend = "";
		int iCount = 0;

		String sName = "";
		String sValue = "";
		String oldName = "";
		String oldValue = "";

		CampStatDetail csd = null;
		for (Enumeration e = csds.elements() ; e.hasMoreElements() ;){
			csd = (CampStatDetail)e.nextElement();
            iCount++;

			oldName = sName;
			oldValue = sValue;

			sName = HtmlUtil.escape(csd.s_detail_name);
			sValue = HtmlUtil.escape(csd.s_integer_value);

			if ("Step".equals(sName.substring(0, 4))){
				if ("Step 1".equals(sName)){
					object.put("step1","Target Group Calculations");
					array.put(object);
				}
				else if ("Step 2".equals(sName)){
					object.put("step2","Campaign Calculations");
					array.put(object);
				}
				else if ("Step 3".equals(sName)){
					object.put("step3","Final Campaign Count (including Seed List)");
					array.put(object);
				}
				else if ("Step Misc".equals(sName)){
					object.put("Step Misc","Misc: Campaign Calculations By Domain");
					array.put(object);
					bDomainCount = true;
				}
				if (!("".equals(oldName))){
					object.put("oldName",oldName);
					object.put("oldValue",oldValue);
					array.put(object);
				}

				iCount = 0;
			}
			else{
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

				object.put("sName",sName);
				object.put("sValue",sValue);
				array.put(object);
            }
		}
		if (sWsSentCountFlag != null && sWsSentCountFlag.equals("1")) {


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


			java.util.Date campStartDate = null;
			rs = stmt.executeQuery("SELECT start_date FROM cque_schedule WHERE camp_id = " + sCampId);
			if (rs.next()) {
				campStartDate = rs.getDate(1);
			}
			rs.close();
			logger.info("sentDate [campStartDate] = " + campStartDate);

		}
    out.print(array);
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

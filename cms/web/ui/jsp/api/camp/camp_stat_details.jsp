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
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

    if (!can.bRead) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }

    JsonArray jsonArray = new JsonArray();
    JsonObject dataObject = new JsonObject();

    String sAction = BriteRequest.getParameter(request, "a");
    if (sAction == null) sAction = "queue";

    String sCampId = BriteRequest.getParameter(request, "camp_id");
    String sWsSentCountFlag = BriteRequest.getParameter(request, "ws_sent_count_flag");

    if (sCampId == null) return;

    //Connection
    ConnectionPool cp = null;
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    String sql = null;
    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        boolean bDomainCount = false;
        Vector vDomainCount = new Vector();

        CampStatDetails csds = new CampStatDetails();
        csds.s_camp_id = sCampId;
        csds.retrieve();

        String stepDesc = "";

        if ("queue".equals(sAction)) {
            stepDesc = "Queued Count Details";
        } else {
            stepDesc = "Calculated Recipient Statistics";
        }

        if (csds.size() != 0) {

            String sClassAppend = "";
            int iCount = 0;

            String sName = "";
            String sValue = "";

            String oldName = "";
            String oldValue = "";

            CampStatDetail csd = null;
            for (Enumeration e = csds.elements(); e.hasMoreElements(); ) {
                dataObject = new JsonObject();
                csd = (CampStatDetail) e.nextElement();

                if (iCount % 2 != 0) sClassAppend = "_Alt";
                else sClassAppend = "";

                iCount++;

                oldName = sName;
                oldValue = sValue;

                sName = csd.s_detail_name;
                sValue = csd.s_integer_value;


                if ("Step".equals(sName.substring(0, 4))) {
                    if ("Step 1".equals(sName)) {
                        sName = "Step 1: Target Group Calculations";
                    } else if ("Step 2".equals(sName)) {
                        sName = "Step 2: Campaign Calculations";
                    } else if ("Step 3".equals(sName)) {
                        sName = "Step 3: Final Campaign Count (including Seed List)";
                    } else if ("Step Misc".equals(sName)) {
                        sName = "Misc: Campaign Calculations By Domain";
                        bDomainCount = true;
                    }
                    if (iCount != 1) {

                    }
                    if (!("".equals(oldName))) {

                    }
                    iCount = 0;
                } else {
                    if (bDomainCount) {
                        logger.info("Found: '" + csd.s_detail_name.substring(10) + "' => '" + csd.s_integer_value + "'");
                        SentInfo si = new SentInfo();
                        si.setDomain(csd.s_detail_name.substring(10));
                        try {
                            si.setCount(Integer.parseInt(csd.s_integer_value));
                        } catch (Exception ex) {
                            si.setCount(0);
                        }
                        vDomainCount.add(si);
                        logger.info("Domain Sent Count for: " + si.getDomain() + " => " + si.getCount());
                    }
                }
                dataObject.put("sName", sName);
                dataObject.put("sValue", sValue);
                dataObject.put("oldName", oldName);
                dataObject.put("oldValue", oldValue);
                
                jsonArray.put(dataObject);
            }
            if (bDomainCount) {

            }
            if (sWsSentCountFlag != null && sWsSentCountFlag.equals("1")) {

                // find associated ws camp id for this campaign (using origin_camp_id)
                String sWsCampId = null;
                Campaign camp = new Campaign(sCampId);
                sql = "SELECT ws_camp_id from cxcs_ws_campaign WHERE cust_id = " + camp.s_cust_id + " AND camp_id = " + camp.s_origin_camp_id;
                rs = stmt.executeQuery(sql);
                if (rs.next()) {
                    sWsCampId = rs.getString(1);
                    logger.info("Found ws_camp_id " + sWsCampId + " for camp_id = " + camp.s_camp_id);
                } else {
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
            }
            out.print(jsonArray);
            rs.close();
        }
        rs.close();
    } catch (Exception ex) {
        ErrLog.put(this, ex, "Problem with camp_stat_details.", out, 1);
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) cp.free(conn);
    }
%>

<%@ page
        language="java"
        import="com.britemoon.*,
        		com.britemoon.cps.*,
        		com.britemoon.cps.imc.*,
        		com.britemoon.cps.rpt.*,
        		java.sql.*,
        		java.net.*,
        		java.io.*,
        		java.util.*,
        		org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../../utilities/validator.jsp" %>
<%@ include file="functions.jsp" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }

    AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

    if (!can.bRead) {
        response.sendRedirect("../access_denied.jsp");
        return;
    }
    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();
    String sCampID = request.getParameter("Q");
    String sCache = request.getParameter("Z");
    sCache = ("1".equals(sCache)) ? sCache : "0";

    boolean DURUM = false;
    String Link_TR = "";
    String showTrackerRptTR = "";


    ConnectionPool cp = null;
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    String reportName = "";
    String reportDate = "";

    String tReceived = "";
    String tRead = "";
    String tClicks = "";
    int readPerct = 0;
    int clickPerct = 0;

    String sLinkID = "";
    String sCurCampID = "";
    String sHref = "";
    String sDistClicks = "";
    String sDistClickPct = "";
    String sTotClicks = "";
    String sTotClickPct = "";
    String sMbsReportDetailsUrl = "";
    MbsRevenueReport mbsRevenueReport = new MbsRevenueReport();
    StringBuilder RETURN_TR = new StringBuilder();

    boolean displayPurchOnChart = false;
    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        int nPos = 0;
        int numRecs = 0;

        //Customize deliveryTracker report Feature (part of release 5.9)
        int showTrackerRpt = 0;
        boolean bFeat = ui.getFeatureAccess(Feature.PV_DELIVERY_TRACKER);
        if (bFeat) {
            int nCount = getSeedListCount(stmt, cust.s_cust_id, sCampID);
            if (nCount > 0)
                showTrackerRpt = 1;
        }
        // end release 5.9

        if ((sCampID != null)) {
            String sSql =
                    " SELECT count(camp_id)" +
                            " FROM cque_campaign c with(nolock)" +
                            " WHERE c.cust_id = " + cust.s_cust_id +
                            " AND c.camp_id = " + sCampID;

            rs = stmt.executeQuery(sSql);
            if (rs.next()) numRecs = rs.getInt(1);
            jsonObject.put("numRecs",numRecs);
            rs.close();

            // === === ===		

            sSql =
                    " SELECT count(*)" +
                            " FROM crpt_camp_pos with(nolock)" +
                            " WHERE camp_id IN (" + sCampID + ")";

            rs = stmt.executeQuery(sSql);
            if (rs.next()) nPos = rs.getInt(1);
            jsonObject.put("nPos",nPos);
            rs.close();

            // === === ===				

            sSql =
                    " EXEC usp_crpt_camp_list" +
                            "  @camp_id=" + sCampID +
                            ", @cust_id=" + cust.s_cust_id +
                            ", @cache=0";

            rs = stmt.executeQuery(sSql);

            while (rs.next()) {
                byte[] bVal = rs.getBytes("CampName");
                
                reportName = (bVal != null ? new String(bVal, "UTF-8") : "");
                reportDate = rs.getString("StartDate");
            }
            jsonObject.put("reportName",reportName);
            jsonObject.put("StartDate",reportDate);

            rs.close();
        }

        if ((sCampID == null) || ("".equals(sCampID)) || (numRecs < 1)) {
            DURUM = true;
        } 
        else {
            mbsRevenueReport.s_camp_id = sCampID;
            if (mbsRevenueReport.retrieve() > 0) {
                displayPurchOnChart = true;


                Service service = null;
                Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id);
                service = (Service) services.get(0);
                sMbsReportDetailsUrl =
                        "http://" + service.getURL().getHost() + "/rrcp/imc/rpt/mbs_revenue_report_details.jsp" +
                                "?cust_id=" + cust.s_cust_id + "&camp_id=" + sCampID;


                String campSummarySql = "select * from crpt_camp_summary with(nolock) where camp_id = " + sCampID;
                rs = stmt.executeQuery(campSummarySql);
                while (rs.next()) {
                    tReceived = rs.getString(7);
                    tRead = rs.getString(8);
                    tClicks = rs.getString(10);
                    
                }
                 jsonObject.put("tReceived",tReceived);
                 jsonObject.put("tRead",tRead);
                 jsonObject.put("tClicks",tClicks);
                rs.close();

                String xmlData = "<graph baseFontSize='12' isSliced='1' decimalPrecision='0'>";
                if (displayPurchOnChart) {
                    //int purchAmount = Math.round(Integer.parseInt(mbsRevenueReport.s_total));
                    //String purchAmountStr = Integer.toString(purchAmount);
                    //xmlData += "<set name='Purchases' value='"+HtmlUtil.escape(purchAmountStr)+"' />";
                }

                xmlData += "<set name='Clicks' value='" + tClicks + "' /><set name='Reads' value='" + tRead + "' /><set name='Received' value='" + tReceived + "' /></graph>";

                readPerct = ((Integer.parseInt(tRead) * 100) / Integer.parseInt(tReceived));
                clickPerct = ((Integer.parseInt(tClicks) * 100) / Integer.parseInt(tReceived));

            }

            //	<!-- Revenue Report End -->


            int iCount = 0;
            String sClassAppend = "_other";

            String sSql =
                    " EXEC usp_crpt_camp_pos_list" +
                            " @camp_id = " + sCampID +
                            ",@cache = " + sCache;

            rs = stmt.executeQuery(sSql);

            while (rs.next()) {
                if (iCount % 2 != 0) sClassAppend = "_other";
                else sClassAppend = "";

                iCount++;

                sLinkID = rs.getString(1);
                sCurCampID = rs.getString(2);
                sHref = rs.getString(3);
                sDistClicks = rs.getString(4);
                sDistClickPct = rs.getString(5);
                sTotClicks = rs.getString(6);
                sTotClickPct = rs.getString(7);

                String TR = "<tr> <td class='list_link'>"
                        + "	<a class='tablelink' href='report_track_connect.jsp?Q=" + sCurCampID + "&amp;P=" + sLinkID + "&amp;Z=" + sCache + "'>"
                        + sHref
                        + "	</a>"
                        + "</td>"
                        + "	<td class='list_row'>"
                        + "	<b>" + sDistClicks + "</b> visits "
                        + "	<div style='position:relative;margin-top:5px;width:100%;height:25px;border:1px solid #cccccc;border-radius:3px;background-color:#ffffff;'>"
                        + "		<div  style='background-color:#59C8E6 ;height:23px;width:" + sDistClickPct + "%'>"
                        + "						<span style='position:absolute;top:1;height:23px;right:2px;font-size:12px;'>" + sDistClickPct + "%</span> "
                        + "					</div>"
                        + "				</div>"
                        + "</td>	"
                        + "	<td class='list_row'> "
                        + "	<b>" + sTotClicks + "</b> visits  "
                        + "	<div style='position:relative;margin-top:5px;width:100%;height:25px;border:1px solid #cccccc;border-radius:3px;background-color:#ffffff;'> "
                        + "				<div  style='background-color:#59C8E6 ;height:23px;width:" + sTotClickPct + "%'> "
                        + "					<span style='position:absolute;top:1;height:23px;right:2px;font-size:12px;'>" + sTotClickPct + "%</span> "
                        + "	</div>"
                        + "	</div>"
                        + "	</td>"
                        + "</tr>";

                RETURN_TR.append(TR);

            }
                jsonObject.put("sLinkID",sLinkID);
                jsonObject.put("sCurCampID",sCurCampID);
                jsonObject.put("sHref",sHref);
                jsonObject.put("sDistClicks",sDistClicks);
                jsonObject.put("sDistClickPct",sDistClickPct);
                jsonObject.put("sTotClicks",sTotClicks);
                jsonObject.put("sTotClickPct",sTotClickPct);
            rs.close();
            if (DURUM) { 	 
            jsonObject.put("Durum","No Campaign for that ID");
            }
            else {
                jsonObject.put("reportName",reportName);
                   if (displayPurchOnChart) {
                 jsonObject.put("tReceived",tReceived);
                 jsonObject.put("tRead",tRead);
                 jsonObject.put("tClicks",tClicks);
                 jsonObject.put("clickPerct",clickPerct+0.1);
                 jsonObject.put("s_purchasers",HtmlUtil.escape(mbsRevenueReport.s_purchasers));
                 jsonObject.put("s_delivered",HtmlUtil.escape(mbsRevenueReport.s_delivered));
                 jsonObject.put("s_purchases",HtmlUtil.escape(mbsRevenueReport.s_purchases));
                 jsonObject.put("s_total",HtmlUtil.escape(mbsRevenueReport.s_total));
                }
                }
            jsonArray.put(jsonObject);
            out.print(jsonArray);   
    } 
    }
     catch (Exception ex) {
        throw ex;
    } finally {
        try {
            if (stmt != null) stmt.close();
            if (conn != null) cp.free(conn);
        } 
        catch (SQLException ex) {
        }
    }
%>

















 
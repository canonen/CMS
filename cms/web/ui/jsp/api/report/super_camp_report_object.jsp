<%@ page
        language="java"
        import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.io.*,
			java.util.*,org.xml.sax.*,
			javax.xml.transform.*,
			javax.xml.transform.stream.*,org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="../validator.jsp" %>
<%@ include file="../header.jsp" %>


<%!
    static Logger logger = null;

    private JsonArray createJSON(String sCampID, HttpServletRequest request, Customer cust) throws Exception {
        JsonObject result = new JsonObject();
        JsonArray resultArr = new JsonArray();
        JsonArray campaignsArray = new JsonArray();
        JsonArray linksArray = new JsonArray();
        JsonArray subCampaignsArray = new JsonArray();

        ConnectionPool cp = null;
        Connection conn = null;
        Connection conn2 = null;
        Statement stmt = null;
        Statement stmt2 = null;
        ResultSet rs = null;
        ResultSet rs2 = null;

        try {
            cp = ConnectionPool.getInstance();
            conn = cp.getConnection("report_object.jsp");
            stmt = conn.createStatement();
            conn2 = cp.getConnection("report_object.jsp 2");
            stmt2 = conn2.createStatement();

            if (sCampID != null) {
                // Fetch campaign details
                rs = stmt.executeQuery("Exec usp_crpt_super_camp_list @super_camp_id=" + sCampID + ", @cust_id=" + cust.s_cust_id);
                while (rs.next()) {
                    JsonObject campaign = new JsonObject();
                    campaign.put("Id", rs.getString("Id"));
                    campaign.put("Name", new String(rs.getBytes("CampName"), "UTF-8"));
                    campaign.put("Size", rs.getString("Sent"));
                    campaign.put("BBacks", rs.getString("BBacks"));
                    campaign.put("Reaching", rs.getString("Reaching"));
                    campaign.put("DistinctReads", rs.getString("DistinctReads"));
                    campaign.put("TotalReads", rs.getString("TotalReads"));
                    campaign.put("MultiReaders", rs.getString("MultiReaders"));
                    campaign.put("Unsubs", rs.getString("Unsubs"));
                    campaign.put("TotalLinks", rs.getString("TotalLinks"));
                    campaign.put("TotalClicks", rs.getString("TotalClicks"));
                    campaign.put("TotalText", rs.getString("TotalText"));
                    campaign.put("TotalHTML", rs.getString("TotalHTML"));
                    campaign.put("TotalAOL", rs.getString("TotalAOL"));
                    campaign.put("DistinctClicks", rs.getString("DistinctClicks"));
                    campaign.put("DistinctText", rs.getString("DistinctText"));
                    campaign.put("DistinctHTML", rs.getString("DistinctHTML"));
                    campaign.put("DistinctAOL", rs.getString("DistinctAOL"));
                    campaign.put("OneLinkMultiClickers", rs.getString("OneLinkMultiClickers"));
                    campaign.put("MultiLinkClickers", rs.getString("MultiLinkClickers"));
                    campaign.put("BBackPrc", rs.getString("BBackPrc"));
                    campaign.put("ReachingPrc", rs.getString("ReachingPrc"));
                    campaign.put("DistinctReadPrc", rs.getString("DistinctReadPrc"));
                    campaign.put("UnsubPrc", rs.getString("UnsubPrc"));
                    campaign.put("DistinctClickPrc", rs.getString("DistinctClickPrc"));
                    campaign.put("TotalTextPrc", rs.getString("TotalTextPrc"));
                    campaign.put("TotalHTMLPrc", rs.getString("TotalHTMLPrc"));
                    campaign.put("TotalAOLPrc", rs.getString("TotalAOLPrc"));
                    campaign.put("DistinctTextPrc", rs.getString("DistinctTextPrc"));
                    campaign.put("DistinctHTMLPrc", rs.getString("DistinctHTMLPrc"));
                    campaign.put("DistinctAOLPrc", rs.getString("DistinctAOLPrc"));

                    campaignsArray.put(campaign);
                }
                rs.close();


                rs = stmt.executeQuery("Exec usp_crpt_super_camp_links @super_camp_id=" + sCampID);
                while (rs.next()) {
                    JsonObject link = new JsonObject();
                    link.put("SuperCampID", sCampID);
                    link.put("SuperLinkID", rs.getString("Id"));
                    link.put("SuperLinkName", new String(rs.getBytes("SuperLinkName"), "UTF-8"));
                    link.put("TotalClicks", rs.getString("TotalClicks"));
                    link.put("TotalText", rs.getString("TotalText"));
                    link.put("TotalHTML", rs.getString("TotalHTML"));
                    link.put("TotalAOL", rs.getString("TotalAOL"));
                    link.put("DistinctClicks", rs.getString("DistinctClicks"));
                    link.put("DistinctText", rs.getString("DistinctText"));
                    link.put("DistinctHTML", rs.getString("DistinctHTML"));
                    link.put("DistinctAOL", rs.getString("DistinctAOL"));
                    link.put("TotalClickPrc", rs.getString("TotalClickPrc"));
                    link.put("TotalTextPrc", rs.getString("TotalTextPrc"));
                    link.put("TotalHTMLPrc", rs.getString("TotalHTMLPrc"));
                    link.put("TotalAOLPrc", rs.getString("TotalAOLPrc"));
                    link.put("DistinctClickPrc", rs.getString("DistinctClickPrc"));
                    link.put("DistinctTextPrc", rs.getString("DistinctTextPrc"));
                    link.put("DistinctHTMLPrc", rs.getString("DistinctHTMLPrc"));
                    link.put("DistinctAOLPrc", rs.getString("DistinctAOLPrc"));


                    int nNonLinkCamps = 0;
                    rs2 = stmt2.executeQuery("SELECT count(c.camp_id) FROM cque_campaign c, cque_super_camp_camp s"
                            + " WHERE c.origin_camp_id = s.camp_id"
                            + " AND c.type_id > " + CampaignType.TEST
                            + " AND s.super_camp_id = " + sCampID
                            + " AND c.camp_id NOT IN (SELECT cc.camp_id"
                            + " FROM cque_campaign cc, cjtk_link l, crpt_super_link_link sl"
                            + " WHERE cc.cont_id = l.cont_id AND l.link_id = sl.link_id"
                            + " AND sl.super_link_id = " + rs.getString("Id") + " AND sl.super_camp_id = " + sCampID + ")");
                    if (rs2.next()) {
                        nNonLinkCamps = rs2.getInt(1);
                    }
                    rs2.close();
                    link.put("NonLinkCamps", nNonLinkCamps);

                    linksArray.put(link);
                }
                rs.close();


                rs = stmt.executeQuery("Exec usp_crpt_super_camp_camp_list @super_camp_id=" + sCampID);
                while (rs.next()) {
                    JsonObject subCampaign = new JsonObject();
                    String subCampID = rs.getString("CampID");
                    subCampaign.put("CampID", subCampID);
                    subCampaign.put("CampName", new String(rs.getBytes("CampName"), "UTF-8"));
                    rs2 = stmt2.executeQuery("Exec usp_crpt_camp_list @camp_id=" + subCampID + ", @cust_id=" + cust.s_cust_id);
                    if (rs2.next()) {
                        subCampaign.put("StartDate", rs2.getString("StartDate"));
                        subCampaign.put("Size", rs2.getString("Sent"));
                        subCampaign.put("BBacks", rs2.getString("BBacks"));
                        subCampaign.put("Unsubs", rs2.getString("Unsubs"));
                        subCampaign.put("Clicks", rs2.getString("DistinctClicks"));
                        subCampaign.put("BBackPrc", rs2.getString("BBackPrc"));
                        subCampaign.put("UnsubPrc", rs2.getString("UnsubPrc"));
                        subCampaign.put("ClickPrc", rs2.getString("DistinctClickPrc"));
                    }
                    rs2.close();
                    subCampaignsArray.put(subCampaign);
                }
                rs.close();

                result.put("Campaigns", campaignsArray);
                result.put("Links", linksArray);
                result.put("SubCampaigns", subCampaignsArray);
                resultArr.put(result);
            }
        } catch (Exception ex) {
            logger.error("Error in createJSON: " + ex.getMessage(), ex);
            throw ex;
        } finally {
            try { if (stmt2 != null) stmt2.close(); } catch (Exception ignore) { }
            if (conn2 != null) cp.free(conn2);
            try { if (stmt != null) stmt.close(); } catch (Exception ignore) { }
            if (conn != null) cp.free(conn);
        }
        return resultArr;
    }
%>



<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
    System.out.println("Super Camp Report Object");
    JsonArray superCampReportObjectData = new JsonArray();
    try {
        String sCampList = request.getParameter("id");

        if (sCampList != null) {
            while (sCampList.indexOf(",") != -1) {
                superCampReportObjectData.put(createJSON(sCampList.substring(0, sCampList.indexOf(",")), request, cust));
                sCampList = sCampList.substring(sCampList.indexOf(",") + 1);
            }


            superCampReportObjectData.put(createJSON(sCampList, request, cust));
        }


        out.print(superCampReportObjectData.toString());
    } catch (Exception ex) {
        ErrLog.put(this, ex, "Error: " + ex.getMessage(), out, 1);
    } finally {
        out.flush();
    }
%>

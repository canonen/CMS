<%--
  Created by IntelliJ IDEA.
  User: Emre Kursat OZER
  Date: 19.12.2024
  Time: 15:27
  To change this template use File | Settings | File Templates.
--%>
<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.imc.*,
                com.britemoon.cps.que.*,
                java.sql.*,
                java.io.*,
                java.util.*,
                org.w3c.dom.*"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%
    response.setHeader("Access-Control-Allow-Origin", "*");
    response.setHeader("Access-Control-Allow-Methods", " GET, POST, PATCH, PUT, DELETE, OPTIONS");
    response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");
%>

<%

    String custId = cust.s_cust_id;

    String title = request.getParameter("title");
    String body = request.getParameter("body");
    String campaignName = request.getParameter("campaign_name");
    String campaignTpye = request.getParameter("campaign_type");
    String segment = request.getParameter("segment");
    String url = request.getParameter("url");
    String image = request.getParameter("img");
    String icon = request.getParameter("icn");
    String statusId = request.getParameter("status_id");
    String approvelId = request.getParameter("approvelid");
    String sendDate = request.getParameter("send_date");
    String filterType= request.getParameter("filter_type");
    String queueDate = request.getParameter("queue_date");
    String campTempType = request.getParameter("camp_temp_type");
    String trigerTimeType = request.getParameter("triger_time_type");
    String trigerTtimeParameter = request.getParameter("triger_time_parameter");
    String startTimeType = request.getParameter("start_time_type");
    String excludeTime = request.getParameter("exclude_time");
    String personalize = request.getParameter("personalize");
    String dailyWeekdayMask = request.getParameter("daily_weekday_mask");
    String queueWeekdayMask = request.getParameter("queue_weekday_mask");
    String startDailyTime = request.getParameter("start_daily_time");
    String qStartDailyTime = request.getParameter("q_start_daily_time");
    String all = request.getParameter("allow_recipients");
    String endDate = request.getParameter("end_date");
    String endDailyTime = request.getParameter("end_daily_time");
    if (endDate == null) {
        endDate = "2099-04-18 13:27:00";
    }

    int allowRecipients = 0;
    if(all.equals("true")|| all.equals("1")) {
        allowRecipients = 1;
    }

    JsonArray array = new JsonArray();
    JsonObject data = new JsonObject();

    ConnectionPool connectionPool   =null;
    Connection connection       =null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    String appPushCampaignSql  = null;

    Connection rcpConnection =null;
    PreparedStatement rcpPs = null;
    ResultSet rcpRs = null;

    Integer currentCampaignId = null;

    try {
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);

        appPushCampaignSql = "INSERT INTO cque_app_push_campaign (cust_id,type_id,status_id,camp_name,filter_id,camp_code,approval_flag,camp_temp_type,title,img,url,msg,icon,personalize) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        ps = connection.prepareStatement(appPushCampaignSql , Statement.RETURN_GENERATED_KEYS);
        ps.setInt(1, Integer.parseInt(custId));
        ps.setInt(2, Integer.parseInt(campaignTpye));
        ps.setInt(3, Integer.parseInt(statusId));
        ps.setString(4, campaignName);
        ps.setInt(5, Integer.parseInt(segment));
        ps.setString(6, null);
        ps.setInt(7, Integer.parseInt(approvelId));
        ps.setString(8, campTempType);
        ps.setString(9, title);
        ps.setString(10, image);
        ps.setString(11, url);
        ps.setString(12, null);
        ps.setString(13, icon);
        ps.setInt(14, Integer.parseInt(personalize));
        ps.executeUpdate();

        data.put("Campaign Insert Operations", "success");

        rs = ps.getGeneratedKeys();
        if (rs.next()) {
            currentCampaignId = rs.getInt(1);
        }

        rs.close();
        ps.close();


    }catch (SQLException e) {
        out.println("Campaign Insert Error : " + e.getMessage());
        System.out.println("Campaign Insert Error : " + e.getMessage());
        array.put(data);
        out.print(array);
        throw new RuntimeException(e);
    }

    if (currentCampaignId != null) {
        try {
            appPushCampaignSql = "INSERT INTO cque_app_push_camp_send_param (camp_id,recip_qty_limit,queue_date,queue_daily_time,queue_daily_weekday_mask) VALUES (?,?,?,?,?)";
            ps = connection.prepareStatement(appPushCampaignSql);
            ps.setInt(1, currentCampaignId);
            ps.setInt(2, allowRecipients);
            ps.setString(3, queueDate);
            if (qStartDailyTime == null || qStartDailyTime.isEmpty()) {
                ps.setNull(4, Types.DATE);
            } else {
                ps.setString(4, qStartDailyTime);
            }
            if (dailyWeekdayMask == null || dailyWeekdayMask.isEmpty()) {
                ps.setNull(5, Types.INTEGER);
            } else {
                ps.setString(5, queueWeekdayMask);
            }
            ps.executeUpdate();
            ps.close();

            data.put("Campaign Param Insert Operations", "success");

        }catch (Exception e) {
            data.put("Campaign Send Param Insert Error : " , e.getMessage());
            out.println("Campaign Send Param Insert Error : " + e.getMessage());
            System.out.println("Campaign Send Param Insert Error : " + e.getMessage());
            
        }

        try {
            appPushCampaignSql = "INSERT INTO cque_app_push_schedule (camp_id,start_date,end_date,start_daily_time,end_daily_time,trgr_time_type,trgr_time_parameter,start_time_type,exclude_time) VALUES (?,?,?,?,?,?,?,?,?)";
            ps = connection.prepareStatement(appPushCampaignSql);
            ps.setInt(1, currentCampaignId);
            if (sendDate == null ||sendDate.equals("")) {
                ps.setNull(2, Types.DATE);
            } else {
                ps.setString(2, sendDate);
            }
            ps.setString(3, endDate);
            if (startDailyTime == null) {
                ps.setNull(4, Types.DATE);
            } else {
                ps.setString(4, startDailyTime);
            }
            ps.setString(5, endDailyTime);
            ps.setString(6, trigerTimeType);
            ps.setString(7, trigerTtimeParameter);
            ps.setString(8, startTimeType);
            if (excludeTime == null || excludeTime.isEmpty()) {
                ps.setNull(9, Types.INTEGER);
            } else {
                ps.setInt(9, Integer.parseInt(excludeTime));
            }
            ps.executeUpdate();

            data.put("Campaign Schedule Insert Operations", "success");
            ps.close();

        }catch (Exception e) {
            data.put("Campaign Schedule Insert Error : " , e.getMessage());
            out.println("Campaign Schedule Insert Error : " + e.getMessage());
            System.out.println("Campaign Schedule Insert Error : " + e.getMessage());
            
        }

        array.put(data);
        out.print(array);

    }
%>
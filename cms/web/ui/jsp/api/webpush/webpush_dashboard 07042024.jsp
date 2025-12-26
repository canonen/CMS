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
        contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%
    String sCustId = cust.s_cust_id;
    String firstDate = request.getParameter("first_date");
    String lastDate = request.getParameter("last_date");

    JsonArray array = new JsonArray();
    JsonObject data = new JsonObject();


    Statement stmt = null;
    ResultSet rs = null;
    ConnectionPool cp = null;
    Connection conn = null;
    String sql = "";

    try {

        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        sql = "select * from ccps_webpush_browser with(nolock) where cust_id= " + sCustId;

        rs = stmt.executeQuery(sql);
        JsonArray subBrowserMobileData = new JsonArray();
        JsonArray unsubBrowserMobileData = new JsonArray();
        JsonObject unsubObject = new JsonObject();
        JsonObject subObject = new JsonObject();
        while (rs.next()) {
            // Opera
            unsubObject = new JsonObject();
            subObject = new JsonObject();
            unsubObject.put("unsubBrowser", "Opera");
            unsubObject.put("unsubCount", rs.getString("opera_passive_count"));
            unsubBrowserMobileData.put(unsubObject);

            subObject.put("subBrowser", "Opera");
            subObject.put("subCount", rs.getString("opera_active_count"));
            subBrowserMobileData.put(subObject);

            // Edge
            unsubObject = new JsonObject();
            subObject = new JsonObject();
            unsubObject.put("unsubBrowser", "Edge");
            unsubObject.put("unsubCount", rs.getString("edge_passive_count"));
            unsubBrowserMobileData.put(unsubObject);

            subObject.put("subBrowser", "Edge");
            subObject.put("subCount", rs.getString("edge_active_count"));
            subBrowserMobileData.put(subObject);

            // Firefox
            unsubObject = new JsonObject();
            subObject = new JsonObject();
            unsubObject.put("unsubBrowser", "Firefox");
            unsubObject.put("unsubCount", rs.getString("firefox_passive_count"));
            unsubBrowserMobileData.put(unsubObject);

            subObject.put("subBrowser", "Firefox");
            subObject.put("subCount", rs.getString("firefox_active_count"));
            subBrowserMobileData.put(subObject);

            // Chrome
            unsubObject = new JsonObject();
            subObject = new JsonObject();
            unsubObject.put("unsubBrowser", "Chrome");
            unsubObject.put("unsubCount", rs.getString("chrome_passive_count"));
            unsubBrowserMobileData.put(unsubObject);

            subObject.put("subBrowser", "Chrome");
            subObject.put("subCount", rs.getString("chrome_active_count"));
            subBrowserMobileData.put(subObject);

            // Safari
            unsubObject = new JsonObject();
            subObject = new JsonObject();
            unsubObject.put("unsubBrowser", "Safari");
            unsubObject.put("unsubCount", rs.getString("safari_passive_count"));
            unsubBrowserMobileData.put(unsubObject);

            subObject.put("subBrowser", "Safari");
            subObject.put("subCount", rs.getString("safari_active_count"));
            subBrowserMobileData.put(subObject);

            // Unknown
            unsubObject = new JsonObject();
            subObject = new JsonObject();
            unsubObject.put("unsubBrowser", "Unknown");
            unsubObject.put("unsubCount", rs.getString("unknown_passive_count"));
            unsubBrowserMobileData.put(unsubObject);

            subObject.put("subBrowser", "Unknown");
            subObject.put("subCount", rs.getString("unknown_active_count"));
            subBrowserMobileData.put(subObject);

        }
        data.put("subBrowserMobileData", subBrowserMobileData);
        data.put("unsubBrowserMobileData", unsubBrowserMobileData);

        sql = "select * from ccps_webpush_device_type with(nolock) where cust_id= " + sCustId;
        //sql = "select * from crpt_cust_webpush_summary with(nolock) where cust_id= \" + sCustId ";

        rs = stmt.executeQuery(sql);
        JsonArray unsubDeviceData = new JsonArray();
        JsonArray subDeviceData = new JsonArray();
        JsonObject unsubDeviceObj = new JsonObject();
        JsonObject subDeviceObj = new JsonObject();
        JsonArray totalDeviceData = new JsonArray();
        JsonObject totalDeviceObj = new JsonObject();

        while (rs.next()) {

            unsubDeviceObj = new JsonObject();
            subDeviceObj = new JsonObject();
           /* int passiveTabletSub = rs.getInt("tablet_passive_count");
            int activeTabletSub = rs.getInt("tablet_active_count");
            int passiveMobileSub = rs.getInt("mobile_passive_count");
            int activeMobileSub = rs.getInt("mobile_active_count");
            int passiveDesktopSub = rs.getInt("desktop_passive_count");
            int activeDesktopSub = rs.getInt("desktop_active_count");*/

            int passiveTabletSub = rs.getInt("tablet_passive_count");
            int activeTabletSub = rs.getInt("tablet_active_count");
            int passiveMobileSub = rs.getInt("mobile_passive_count");
            int activeMobileSub = rs.getInt("mobile_active_count");
            int passiveDesktopSub = rs.getInt("desktop_passive_count");
            int activeDesktopSub = rs.getInt("desktop_active_count");

            unsubDeviceObj.put("counts", passiveTabletSub);
            unsubDeviceObj.put("device", "Tablet");
            unsubDeviceData.put(unsubDeviceObj);

            subDeviceObj.put("counts", activeTabletSub);
            subDeviceObj.put("device", "Tablet");
            subDeviceData.put(subDeviceObj);

            unsubDeviceObj = new JsonObject();
            subDeviceObj = new JsonObject();

            unsubDeviceObj.put("counts", passiveMobileSub);
            unsubDeviceObj.put("device", "Mobile");
            unsubDeviceData.put(unsubDeviceObj);

            subDeviceObj.put("counts", activeMobileSub);
            subDeviceObj.put("device", "Mobile");
            subDeviceData.put(subDeviceObj);


            unsubDeviceObj = new JsonObject();
            subDeviceObj = new JsonObject();

            unsubDeviceObj.put("counts", passiveDesktopSub);
            unsubDeviceObj.put("device", "Desktop");
            unsubDeviceData.put(unsubDeviceObj);

            subDeviceObj.put("counts", activeDesktopSub);
            subDeviceObj.put("device", "Desktop");
            subDeviceData.put(subDeviceObj);

            totalDeviceObj.put("totalMobileSub", passiveMobileSub + activeMobileSub);
            totalDeviceObj.put("totalActiveSub", activeDesktopSub + activeMobileSub + activeTabletSub);
            totalDeviceObj.put("activeMobileSub", activeMobileSub);
            totalDeviceObj.put("inactiveMobileSub", passiveMobileSub);
            totalDeviceObj.put("totalInActiveSub", passiveDesktopSub + passiveMobileSub + passiveTabletSub);

            totalDeviceData.put(totalDeviceObj);

        }
        data.put("subDevice", subDeviceData);
        data.put("unsubDevice", unsubDeviceData);
        data.put("totalData", totalDeviceData);

        sql = "select * from ccps_webpush_geo with(nolock) where cust_id=" + sCustId;
        rs = stmt.executeQuery(sql);
        JsonArray cityArray = new JsonArray();
        JsonArray countryArray = new JsonArray();
        HashMap<String, Integer> countryData = new HashMap<String, Integer>();

        while (rs.next()) {
            String cities = rs.getString(2);
            cities = cities.replaceAll("\\\\", "");
            cities = cities.substring(1, cities.length() - 1);
            String[] cityData = cities.split("\\},");
            for (String city : cityData) {
                city = city.trim();
                if (!city.isEmpty()) {
                    city = city + "}";
                    JsonObject cityObject = new JsonObject(city);
                    cityArray.put(cityObject);

                    // ?lke adini alip count degerini toplama
                    String country = cityObject.getString("region");
                    int count = cityObject.getInt("count");
                    if (countryData.containsKey(country)) {
                        count += countryData.get(country);
                    }
                    countryData.put(country, count);
                }
            }
        }
        data.put("city", cityArray);

        for (String country : countryData.keySet()) {
            JsonObject countryObject = new JsonObject();
            countryObject.put("country", country);
            countryObject.put("count", countryData.get(country));
            countryArray.put(countryObject);
        }
        data.put("country", countryArray);


        sql = "select * from ccps_webpush_recipient_day with(nolock) where cust_id= " + sCustId + " and day between '" + firstDate + "' and '" + lastDate + "'";

        rs = stmt.executeQuery(sql);
        JsonArray subDayData = new JsonArray();
        JsonArray unsubDayData = new JsonArray();
        JsonObject subDayObj = new JsonObject();
        JsonObject unsubDayObj = new JsonObject();
        while (rs.next()) {
            subDayObj = new JsonObject();
            unsubDayObj = new JsonObject();
            String datetime = rs.getString("day");
            String[] datetimeParts = datetime.split(" ");
            String date = datetimeParts[0];
            int sub = rs.getInt("sub_count");
            int unsub =rs.getInt("unsub_count");

                    subDayObj.put("date", date);
            subDayObj.put("sub",sub<1 ? 0 : sub);
            subDayData.put(subDayObj);

            unsubDayObj.put("date", date);
            unsubDayObj.put("unsub",unsub <1 ? 0: unsub);
            unsubDayData.put(unsubDayObj);
        }
        data.put("subOverview", subDayData);
        data.put("unsubOverview", unsubDayData);

        sql = "select sum(sent) as total_sent, CONVERT(varchar, activity_date, 23) " +
                "from ccps_webpush_activity_day where cust_id = " + sCustId + "and " +
                "activity_date>= '" + firstDate + " 00:00:00 ' and activity_date<= '" + lastDate + " 23:59:59' " +
                "group by CONVERT(varchar, activity_date, 23) order by CONVERT(varchar, activity_date, 23) asc";

        rs = stmt.executeQuery(sql);
        JsonArray sentDayData = new JsonArray();
        JsonObject sentDayObj = new JsonObject();

        while (rs.next()) {
            sentDayObj = new JsonObject();
            String totalSent = rs.getString(1);
            String activityTime = rs.getString(2);

            String[] activityTimeArr = activityTime.split("-");
            String year = activityTimeArr[0];
            String month = activityTimeArr[1];
            String day = activityTimeArr[2];

            sentDayObj.put("count", totalSent);
            sentDayObj.put("year", year);
            sentDayObj.put("month", month);
            sentDayObj.put("day", day);

            sentDayData.put(sentDayObj);
        }
        data.put("webPushData", sentDayData);

        out.print(data);

    } catch (Exception exception) {
        exception.printStackTrace();
    } finally {
        if (rs != null) {
            rs.close();
        }
        if (conn != null) {
            cp.free(conn);
        }
    }

%>
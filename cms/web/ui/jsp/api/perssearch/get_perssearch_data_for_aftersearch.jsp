<%--
  Created by IntelliJ IDEA.
  User: Emre CERRAH
  Date: 2.09.2025
  Time: 15:11
  To change this template use File | Settings | File Templates.
--%>
<%@  page language="java"
          import="java.net.*,
                  com.britemoon.*,
                  java.sql.*,
                  com.britemoon.cps.*,
                  java.io.*,
                  java.util.*,
                  java.io.*,
                  org.apache.log4j.Logger,
                  org.w3c.dom.*"
%>

<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %><%@ page import="java.util.Date"%><%@ page import="java.text.SimpleDateFormat"%><%@ page import="java.text.DecimalFormat"%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%@ include file="../fixTurkishCharacters.jsp"%>
<%
    ConnectionPool cp = null;
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
    JsonObject resultObject = new JsonObject();
    String date_between = request.getParameter("date_between");

    String oldValueStartDate = null;
	String oldValueEndDate = null;
	String currentValueStartDate = null;
	String currentValueEndDate = null;
	int total_count = 0;
	int total_conversion = 0;
	double total_revenue = 0.0;
	String search_keyword = "";
    DecimalFormat formatter = new DecimalFormat("###,###");

	long dayDifference = 0;

    if (date_between == null) {
		// date_between parametresi belirtilmediginde
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(new Date());

		// currentValue tarih araligi (bug�n - 7 g�n �ncesi)
		currentValueEndDate = formatDate(calendar.getTime()); // Bug�n�n tarihi
		calendar.add(Calendar.DATE, -7); // 7 g�n �ncesine git
		currentValueStartDate = formatDate(calendar.getTime()); // 7 g�n �nceki tarih

		// oldValue tarih araligi (currentValueStartDate - 7 g�n �ncesi)
		oldValueEndDate = formatDate(calendar.getTime()); // 7 g�n �nceki tarih
		calendar.add(Calendar.DATE, -7); // 14 g�n �ncesine git
		oldValueStartDate = formatDate(calendar.getTime()); // 14 g�n �nceki tarih
		dayDifference = 6;

	} else {
		// date_between parametresi belirtildiginde
		String[] parts = date_between.split("-");
		currentValueStartDate = parts[0].trim() + " 00:00:00";
		currentValueEndDate = parts[1].trim() + " 23:59:59";

		// Date araliklarini hesapla
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd");
		Date startDate = dateFormat.parse(currentValueStartDate);
		Date endDate = dateFormat.parse(currentValueEndDate);

		// G�n farkini hesapla
		dayDifference = (endDate.getTime() - startDate.getTime()) / (24 * 60 * 60 * 1000);

		// oldValue tarih araligini hesapla
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(startDate);
		calendar.add(Calendar.DATE, -(int) dayDifference);
		oldValueStartDate = formatDate(calendar.getTime()); // currentValueStartDate'dan g�n farki kadar �nceki tarih
		oldValueEndDate = currentValueStartDate.replace("00:00:00", "23:59:59");; // oldValueEndDate her zaman currentValueStartDate'a esit olmali

		oldValueStartDate += " 00:00:00";
	}
    try {

		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);


     String sql = "SELECT TOP 30\n" +
            "    search_keyword,\n" +
            "    SUM(count) AS total_count,\n" +
            "    SUM(conversion) AS total_conversion\n" +
            "FROM ccps_pers_search_activity_day WITH (NOLOCK)\n" +
            "WHERE cust_id = '12345' AND activity_date >= ? AND activity_date <= ?\n" +
            "GROUP BY search_keyword\n" +
            "ORDER BY total_count DESC;";

    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, currentValueStartDate);
    pstmt.setString(2, currentValueEndDate);
    rs = pstmt.executeQuery();
        JsonArray currentDataArray = new JsonArray();

    while (rs.next()) {
        JsonObject currentDataObject = new JsonObject();
        total_count = rs.getInt("total_count");
        total_conversion = rs.getInt("total_conversion");
        search_keyword = rs.getString("search_keyword");
        currentDataObject.put("search_keyword",fixTurkishCharacters(search_keyword));
        currentDataObject.put("total_count",formatter.format(total_count));
        currentDataObject.put("total_conversion", total_conversion);
        currentDataArray.put(currentDataObject);
    }

    resultObject.put("currentPopularQueries", currentDataArray);
    rs.close();

    out.print(resultObject);

	} catch (Exception e) {
		throw e;
	} finally {

		try {
			if (pstmt != null) pstmt.close();
		} catch (Exception ignore) {
		}

		if (conn != null) {
			cp.free(conn);
		}

	}
%>

<%!
	public String formatDate(Date date) {
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(date);
		int year = calendar.get(Calendar.YEAR);
		int month = calendar.get(Calendar.MONTH) + 1; // Ay değeri 0-11 aralığında olduğu için 1 ekliyoruz
		int day = calendar.get(Calendar.DAY_OF_MONTH);

		return String.format("%04d-%02d-%02d", year, month, day);
	}
%>
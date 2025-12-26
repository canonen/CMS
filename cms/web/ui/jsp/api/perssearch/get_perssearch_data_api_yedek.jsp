<%@  page language="java"
		  import="java.net.*,
                  com.britemoon.*,
                  java.sql.*,
                  com.britemoon.cps.*,
                  java.util.Calendar,
                  java.util.Date,
                  java.io.*,
                  java.math.BigDecimal,
                  java.text.DecimalFormat,
                  java.text.NumberFormat,
                  java.util.Locale,
                  java.util.*,
                  java.io.*,
                  org.apache.log4j.Logger,
                  org.w3c.dom.*"
%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%

	String[] encodings = {
			"UTF-8",
			"ISO-8859-1",
			"windows-1252",
			"windows-1254",
			"ISO-8859-9"
	};

	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	String date_between = request.getParameter("date_between");
	String oldValueStartDate = null;
	String oldValueEndDate = null;
	String currentValueStartDate = null;
	String currentValueEndDate = null;
	int total_count = 0;
	int total_conversion = 0;
	double total_revenue = 0.0;
	String search_keyword = "";

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

	ConnectionPool cp = null;
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	JsonObject resultObject = new JsonObject();
	JsonArray currentDataArray = new JsonArray();
	JsonObject currentDataObject = new JsonObject();
	JsonArray oldDataArray = new JsonArray();
	JsonObject oldDataObject = new JsonObject();
	DecimalFormat formatter = new DecimalFormat("###,###");
	DecimalFormat formatter2 = new DecimalFormat("#,###.## TL");
	try {

		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		String sql = "";

		//Statistics
		sql = "select sum(count) as total_count, sum(conversion) as total_conversion, sum(revenue) as total_revenue " +
				"from ccps_pers_search_activity_day with(nolock) " +
				"where cust_id = '"+cust.s_cust_id+"' AND activity_date >= ? and activity_date <= ?";

		pstmt = conn.prepareStatement(sql);
		pstmt.setString(1, currentValueStartDate);
		pstmt.setString(2, currentValueEndDate);
		rs = pstmt.executeQuery();
		currentDataArray = new JsonArray();
		while (rs.next()) {
			currentDataObject = new JsonObject();
			total_count = rs.getInt("total_count");
			total_conversion = rs.getInt("total_conversion");
			total_revenue = rs.getDouble("total_revenue");
			currentDataObject.put("total_count",total_count );
			currentDataObject.put("total_conversion",total_conversion );
			currentDataObject.put("total_revenue", total_revenue);
			currentDataArray.put(currentDataObject);
		}

		resultObject.put("currentStatistics", currentDataArray);

		rs.close();
		pstmt.setString(1, oldValueStartDate);
		pstmt.setString(2, oldValueEndDate);
		rs = pstmt.executeQuery();
		oldDataArray = new JsonArray();

		while (rs.next()) {
			oldDataObject = new JsonObject();
			total_count = rs.getInt("total_count");
			total_conversion = rs.getInt("total_conversion");
			total_revenue = rs.getDouble("total_revenue");
			oldDataObject.put("total_count",total_count);
			oldDataObject.put("total_conversion", total_conversion);
			oldDataObject.put("total_revenue", total_revenue);
			oldDataArray.put(oldDataObject);
		}
		rs.close();

		resultObject.put("oldStatistics", oldDataArray);


		// Popular Queries
		sql = "SELECT TOP 30 search_keyword, SUM(count) AS total_count, SUM(conversion) AS total_conversion \n" +
				"INTO #tempTable\n" +
				"FROM ccps_pers_search_activity_day WITH (NOLOCK)\n" +
				"WHERE cust_id = '"+cust.s_cust_id+"' AND activity_date >= ? AND activity_date <= ?\n" +
				"GROUP BY search_keyword\n" +
				"ORDER BY total_count DESC;\n" +
				"\n" +
				"SELECT search_keyword, total_count, total_conversion\n" +
				"FROM #tempTable;\n" +
				"\n" +
				"DROP TABLE #tempTable;";

		pstmt = conn.prepareStatement(sql);
		pstmt.setString(1, currentValueStartDate);
		pstmt.setString(2, currentValueEndDate);
		rs = pstmt.executeQuery();
		currentDataArray = new JsonArray();

		while (rs.next()) {
			currentDataObject = new JsonObject();
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

		pstmt.setString(1, oldValueStartDate);
		pstmt.setString(2, oldValueEndDate);
		rs = pstmt.executeQuery();
		oldDataArray = new JsonArray();

		while (rs.next()) {
			oldDataObject = new JsonObject();
			total_count = rs.getInt("total_count");
			total_conversion = rs.getInt("total_conversion");

			String searchKeyword = rs.getString("search_keyword");
			oldDataObject.put("search_keyword", fixTurkishCharacters(searchKeyword));
			oldDataObject.put("total_count", total_count);
			oldDataObject.put("total_conversion", total_conversion);
			oldDataArray.put(oldDataObject);
		}

		rs.close();
		pstmt.close();

		resultObject.put("oldPopularQueries", oldDataArray);


		//Failed Search Queries
		sql = "SELECT DISTINCT search_keyword\n" +
				"INTO #tempDistinctKeywords\n" +
				"FROM ccps_pers_search_activity_day WITH (NOLOCK)\n" +
				"WHERE  cust_id = '"+cust.s_cust_id+"' AND search_result_count > 0\n" +
				"    AND activity_date >= ?\n" +
				"    AND activity_date <= ?;\n" +
				"\n" +
				"SELECT TOP 30 search_keyword, SUM(count) AS total_count\n" +
				"INTO #tempTable\n" +
				"FROM ccps_pers_search_activity_day WITH (NOLOCK)\n" +
				"WHERE cust_id = '"+cust.s_cust_id+"' AND search_result_count = '0'\n" +
				"    AND search_keyword NOT IN (\n" +
				"        SELECT search_keyword\n" +
				"        FROM #tempDistinctKeywords\n" +
				"    )\n" +
				"    AND activity_date >= ?\n" +
				"    AND activity_date <= ?\n" +
				"GROUP BY search_keyword\n" +
				"ORDER BY total_count DESC;\n" +
				"\n" +
				"SELECT search_keyword, total_count\n" +
				"FROM #tempTable;\n" +
				"\n" +
				"DROP TABLE #tempTable;\n" +
				"DROP TABLE #tempDistinctKeywords;";

		pstmt = conn.prepareStatement(sql);
		pstmt.setString(1, currentValueStartDate);
		pstmt.setString(2, currentValueEndDate);
		pstmt.setString(3, currentValueStartDate);
		pstmt.setString(4, currentValueEndDate);
		rs = pstmt.executeQuery();
		currentDataArray = new JsonArray();

		while (rs.next()) {
			currentDataObject = new JsonObject();
			total_count = rs.getInt("total_count");
			search_keyword =rs.getString("search_keyword");
			currentDataObject.put("search_keyword", fixTurkishCharacters(search_keyword));
			currentDataObject.put("total_count",formatter.format(total_count));
			currentDataArray.put(currentDataObject);
		}

		resultObject.put("currentFailedSearchQueries", currentDataArray);
		rs.close();

		pstmt.setString(1, oldValueStartDate);
		pstmt.setString(2, oldValueEndDate);
		pstmt.setString(3, oldValueStartDate);
		pstmt.setString(4, oldValueEndDate);
		rs = pstmt.executeQuery();
		oldDataArray = new JsonArray();

		while (rs.next()) {
			oldDataObject = new JsonObject();
			total_count = rs.getInt("total_count");
			search_keyword =rs.getString("search_keyword");
			oldDataObject.put("search_keyword", total_count);
			oldDataObject.put("total_count", search_keyword);
			oldDataArray.put(oldDataObject);
		}

		rs.close();

		resultObject.put("oldFailedSearchQueries", oldDataArray);


		//Top Performing Queries
		sql = "SELECT TOP 30 search_keyword, SUM(count) AS total_count, SUM(revenue) AS total_revenue\n" +
				"INTO #tempTable\n" +
				"FROM ccps_pers_search_activity_day WITH (NOLOCK)\n" +
				"WHERE cust_id = '"+cust.s_cust_id+"' AND activity_date >= ? AND activity_date <= ?\n" +
				"GROUP BY search_keyword\n" +
				"HAVING SUM(revenue) <> 0\n" +
				"ORDER BY total_count DESC;\n" +
				"\n" +
				"SELECT search_keyword, total_count, total_revenue\n" +
				"FROM #tempTable;\n" +
				"\n" +
				"DROP TABLE #tempTable;";

		pstmt = conn.prepareStatement(sql);
		pstmt.setString(1, currentValueStartDate);
		pstmt.setString(2, currentValueEndDate);
		rs = pstmt.executeQuery();
		currentDataArray = new JsonArray();

		while (rs.next()) {
			currentDataObject = new JsonObject();

			search_keyword = new String(rs.getString("search_keyword").getBytes("WINDOWS-1252"), StandardCharsets.UTF_8);
			total_count = rs.getInt("total_count");
			total_revenue = rs.getDouble("total_revenue");

			currentDataObject.put("search_keyword",fixTurkishCharacters(rs.getString("search_keyword")));
			currentDataObject.put("total_count",formatter.format(total_count));
			currentDataObject.put("total_revenue",formatter2.format(total_revenue));

			currentDataArray.put(currentDataObject);
		}

		resultObject.put("currentTopPerformingQueries", currentDataArray);

		rs.close();
		pstmt.setString(1, oldValueStartDate);
		pstmt.setString(2, oldValueEndDate);
		rs = pstmt.executeQuery();
		oldDataArray = new JsonArray();

		while (rs.next()) {
			oldDataObject = new JsonObject();
			search_keyword =  rs.getString("search_keyword");
			total_count =rs.getInt("total_count");
			total_revenue =rs.getDouble("total_revenue");
			oldDataObject.put("search_keyword",fixTurkishCharacters(search_keyword));
			oldDataObject.put("total_count", formatter.format(total_count));
			oldDataObject.put("total_revenue",formatter2.format(total_revenue));
			oldDataArray.put(oldDataObject);
		}

		rs.close();

		resultObject.put("oldTopPerformingQueries", oldDataArray);


		//Top queries without Purchases
		sql = "SELECT search_keyword\n" +
				"INTO #tempTable1\n" +
				"FROM ccps_pers_search_activity_day WITH (NOLOCK)\n" +
				"WHERE cust_id = '"+cust.s_cust_id+"' AND conversion > 0 AND activity_date >= ? AND activity_date <= ?;\n" +
				"\n" +
				"SELECT TOP 30 search_keyword, SUM(count) AS total_count, SUM(revenue) AS total_revenue\n" +
				"INTO #tempTable2\n" +
				"FROM ccps_pers_search_activity_day WITH (NOLOCK)\n" +
				"WHERE cust_id = '"+cust.s_cust_id+"' AND activity_date >= ? AND activity_date <= ?\n" +
				"  AND search_keyword NOT IN (\n" +
				"    SELECT search_keyword\n" +
				"    FROM #tempTable1\n" +
				"  )\n" +
				"GROUP BY search_keyword\n" +
				"ORDER BY total_count DESC;\n" +
				"\n" +
				"SELECT search_keyword, total_count\n" +
				"FROM #tempTable2;\n" +
				"\n" +
				"DROP TABLE #tempTable1;\n" +
				"DROP TABLE #tempTable2;\n";

		pstmt = conn.prepareStatement(sql);
		pstmt.setString(1, currentValueStartDate);
		pstmt.setString(2, currentValueEndDate);
		pstmt.setString(3, currentValueStartDate);
		pstmt.setString(4, currentValueEndDate);
		rs = pstmt.executeQuery();
		currentDataArray = new JsonArray();

		while (rs.next()) {
			currentDataObject = new JsonObject();
			search_keyword =  rs.getString("search_keyword");
			total_count =rs.getInt("total_count");
			currentDataObject.put("search_keyword", fixTurkishCharacters(search_keyword));
			currentDataObject.put("total_count", formatter.format(total_count));
			currentDataArray.put(currentDataObject);
		}

		resultObject.put("currentTopQueriesWithoutPurchases", currentDataArray);

		rs.close();
		pstmt.setString(1, oldValueStartDate);
		pstmt.setString(2, oldValueEndDate);
		pstmt.setString(3, oldValueStartDate);
		pstmt.setString(4, oldValueEndDate);
		rs = pstmt.executeQuery();
		oldDataArray = new JsonArray();
		while (rs.next()) {
			oldDataObject = new JsonObject();
			search_keyword =  rs.getString("search_keyword");
			total_count =rs.getInt("total_count");
			oldDataObject.put("search_keyword", fixTurkishCharacters(search_keyword));
			oldDataObject.put("total_count", total_count);
			oldDataArray.put(oldDataObject);
		}

		rs.close();
		pstmt.close();

		resultObject.put("oldTopQueriesWithoutPurchases", oldDataArray);

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


	public  String fixTurkishCharacters(String input) {
		if (input == null) {
			return null;
		}

		String s = input;


		s = s.replace("Ã„Â±", "ı");
		s = s.replace("Ã„ÂŸ", "ğ");
		s = s.replace("Ã„Âž", "Ğ");
		s = s.replace("Ã…ÅŸ", "ş");
		s = s.replace("Ã…Åž", "Ş");
		s = s.replace("ÃƒÂ¼", "ü");
		s = s.replace("ÃƒÂ–", "Ö");
		s = s.replace("ÃƒÂœ", "Ü");
		s = s.replace("ÃƒÂ§", "ç");
		s = s.replace("Ãƒâ€¹", "Ç");

		s = s.replace("Ä±", "ı");
		s = s.replace("Ä°", "İ");
		s = s.replace("ÄŸ", "ğ");
		s = s.replace("Äž", "Ğ");
		s = s.replace("ÅŸ", "ş");
		s = s.replace("Åž", "Ş");
		s = s.replace("Ã¼", "ü");
		s = s.replace("Ãœ", "Ü");
		s = s.replace("Ã§", "ç");
		s = s.replace("Ã‡", "Ç");
		s = s.replace("Ã¶", "ö");
		s = s.replace("Ã–", "Ö");

		return s;
	}

%>
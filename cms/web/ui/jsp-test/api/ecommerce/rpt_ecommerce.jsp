<%@ page
		language="java"
		import="com.britemoon.*,
			com.britemoon.cps.rpt.*,
			com.britemoon.cps.*,
			java.sql.*,
			java.util.Calendar,
			java.util.Date,java.io.*,
			java.math.BigDecimal,
			java.text.NumberFormat,
			java.util.Locale,
			java.io.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*"
		contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
%>
<%@ include file="../header.jsp" %>
<%@ include file="../../utilities/validator.jsp"%>


<%

	String sCustId = cust.s_cust_id;

	String firstDate = request.getParameter("firstDate");
	String lastDate = request.getParameter("lastDate");
	System.out.println("Revotrack start for cust: "+sCustId);

	String date1 = "";
	String date2 = "";
	String date3 = "";


	Statement statement = null;
	ResultSet resultSet = null;
	ConnectionPool connectionPool = null;
	Connection connection = null;

	String sTotalClicks =null;
	Double sTotalClicksINT =null;

	String sPurchases		=null;
	BigDecimal sTotalSales =BigDecimal.ZERO;
	String zTotalSales =null;

	String sTotalPurchasers =null;
	Double sTotalPurchasersInt =null;

	Double sAverageSales =null;
	String sCampCount =null;

	Double sConversionRate;

	String sConversionFormated = null;

	Double nConversion;
	String nConversionFormatted = null;

	String sAverageSalesFormatted = null;


	StringBuilder Revotrack_TR = new StringBuilder();
	String SQL="";





	try{
		JsonObject data = new JsonObject();
		JsonArray dataArray = new JsonArray();
		JsonArray ecommerce = new JsonArray();

		connectionPool = ConnectionPool.getInstance();
		connection = connectionPool.getConnection(this);
		statement = connection.createStatement();

		Locale turkish = new Locale("tr", "TR");
		NumberFormat turkishFormat = NumberFormat.getCurrencyInstance(turkish);
		DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

		Calendar calendarLast7Day= Calendar.getInstance();
		calendarLast7Day.add(Calendar.DATE, -6);

		date3 = dateFormat.format(calendarLast7Day.getTime());

		if(request.getParameter("date1")==null && request.getParameter("date2")==null ){
			date1 = date3;

			date2 = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));

		}
		else if(firstDate==null && lastDate!=null ) {
			SQL=   	" SELECT MIN(CONVERT(VARCHAR(10),DATEADD (day, -1,mbs.date), 111)) FROM untt_mbs_order_date as mbs WHERE   cust_id = " +sCustId ;

			resultSet = statement.executeQuery(SQL);

			while(resultSet.next()){
				date1= resultSet.getString(1);
			}


			date2 = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
		}
		else {

			date1 = firstDate;
			date2 = lastDate;

		}



		SQL=      " IF OBJECT_ID('tempdb..#camp_id') IS NOT NULL DROP TABLE #camp_id "
				+" 		SELECT camp_id into #camp_id FROM cque_campaign with(nolock) "
				+"			WHERE cust_id = " +sCustId+ " and  type_id in (2,4) and camp_id in ( "
				+"				SELECT DISTINCT camp_id FROM untt_mbs_order_date with(nolock) "
				+" 				WHERE cust_id = " +sCustId+" and  amount_sum is not null "
				+" 				and  date BETWEEN '"+date1+" 00:00:00' AND '"+date2+" 23:59:59' "
				+"		)  " ;



		statement.executeUpdate(SQL);


		SQL =    " IF OBJECT_ID('tempdb..#temp_activity') IS NOT NULL DROP TABLE #temp_activity " +
				" select rjtk.camp_id as camp_id, rjtk.rjtk_count as clicks  into #temp_activity from ccps_rjtk_link_activity as rjtk\n" +
				" where rjtk.camp_id in ( SELECT * FROM #camp_id )  and rjtk.type_id = 2 and rjtk.cust_id = " +sCustId +
				" and rjtk.click_time BETWEEN '"+date1+" 00:00:00' AND '"+date2+" 23:59:59'   " ;



		statement.executeUpdate(SQL);



		SQL = "SELECT sum(clicks) FROM  #temp_activity ";

		resultSet = statement.executeQuery(SQL);
		dataArray = new JsonArray();
		while(resultSet.next()){

			data = new JsonObject();
			sTotalClicks = (resultSet.getString(1)==null) ? "0" : resultSet.getString(1);
			sTotalClicksINT = Double.parseDouble(sTotalClicks);
			data.put("click", sTotalClicksINT);

			dataArray.put(data);

		}
		ecommerce.put(dataArray);
		resultSet.close();


		SQL=       " SELECT  sum(orders) as purchases FROM untt_mbs_order_date  with(nolock) "
				+" WHERE cust_id = " +sCustId+ " and camp_id in (select * from #camp_id)"
				+" AND  date BETWEEN '"+date1+" 00:00:00' AND '"+date2+" 23:59:59' " ;

		resultSet = statement.executeQuery(SQL);
		dataArray = new JsonArray();
		while(resultSet.next()){
			data = new JsonObject();
			sPurchases		=(resultSet.getString(1)==null) ? "0" : resultSet.getString(1);
			data.put("purchases",sPurchases);

			dataArray.put(data);

		}
		ecommerce.put(dataArray);
		resultSet.close();





		SQL=	"  SELECT  sum(customers) as purchases "
				+" FROM untt_mbs_order_date "
				+" WHERE cust_id = " +sCustId+ " and camp_id in (select * from #camp_id)"
				+" AND  date BETWEEN '"+date1+" 00:00:00' AND '"+date2+" 23:59:59' " ;

		resultSet = statement.executeQuery(SQL);
		dataArray = new JsonArray();
		while(resultSet.next()){
			data = new JsonObject();


			sTotalPurchasers = (resultSet.getString(1)==null) ? "0" : resultSet.getString(1);
			sTotalPurchasersInt = Double.parseDouble(sTotalPurchasers);

			data.put("Purchasers", sTotalPurchasersInt);

			dataArray.put(data);
		}
		ecommerce.put(dataArray);
		resultSet.close();


		SQL="select count(camp_id) FROM #camp_id";

		resultSet = statement.executeQuery(SQL);
		dataArray = new JsonArray();
		while(resultSet.next()){
			data = new JsonObject();
			sCampCount =(resultSet.getString(1)==null) ? "0" : resultSet.getString(1);

			data.put("campCount", sCampCount);
			dataArray.put(data);
		}
		ecommerce.put(dataArray);
		resultSet.close();



		SQL= "SELECT cc.camp_name,sum(mbs.orders) as purchasers ,sum(mbs.customers) as purchases ,sum(mbs.amount_sum) total ,  "
				+"	mbs.camp_id, resultSet.start_date, "
				+"  (select CASE WHEN sum(clicks)>0 THEN sum(clicks) ELSE 1 END  from #temp_activity  where  camp_id=mbs.camp_id  )  as clicks ,"
				+"	cc.type_id,rcs.queue_daily_flag,cc.camp_code  "
				+" FROM untt_mbs_order_date as mbs with(nolock)\n"
				+"	INNER JOIN cque_campaign cc with(nolock) on mbs.camp_id=cc.camp_id\n"
				+"	INNER JOIN cque_schedule resultSet with(nolock) on mbs.camp_id=resultSet.camp_id\n"
				+"	INNER JOIN cque_camp_send_param rcs with(nolock) on mbs.camp_id=rcs.camp_id\n"

				+"WHERE "
				+"	mbs.amount_sum is not null "
				+"	and cc.type_id in (2,4) "
				+"	and cc.cust_id=" +sCustId
				+"	and mbs.camp_id in ( select * from #camp_id ) "
				+"	and mbs.date BETWEEN '"+date1+" 00:00:00' AND '"+date2+" 23:59:59'"

				+" GROUP BY  mbs.camp_id,cc.camp_name,resultSet.start_date,rcs.queue_daily_flag,cc.type_id,cc.camp_code  "
				+" ORDER by  mbs.camp_id DESC ";





		resultSet = statement.executeQuery(SQL);
		int iCount = 0;
		String sClassAppend = "_other";


		String sCampName			=null;
		String sCampPurchasers		=null;
		String sCampPurchases		=null;
		BigDecimal sCampSales		=BigDecimal.ZERO;
		String zCampSales			=null;
		String sCampID				=null;
		String zCampStartDate		=null;
		String sClicks				=null;
		String sTypeID				=null;
		String sDailyFlag			=null;
		String sDisplayType		=null;
		String sCampCode			=null;



		dataArray = new JsonArray();
		while(resultSet.next()){
			data = new JsonObject();
			if (iCount % 2 != 0) sClassAppend = "_other";
			else sClassAppend = "";
			iCount++;

			sCampName 	 			= new String(resultSet.getBytes(1),"UTF-8");
			data.put("campName",sCampName);

			sCampPurchasers		=(resultSet.getString(2)==null) ? "0.0" : resultSet.getString(2);
			data.put("campPurchasers",sCampPurchasers);
			sCampPurchases			= (resultSet.getString(3)==null) ? "0.0" : resultSet.getString(3);
			data.put("campPurchases",sCampPurchases);

			sCampSales 			= resultSet.getBigDecimal(4).equals("null") ? BigDecimal.ZERO : resultSet.getBigDecimal(4);
			data.put("campSales",sCampSales);
			sCampSales 				= sCampSales.setScale(2, BigDecimal.ROUND_HALF_EVEN);
			data.put("campSales",sCampSales);

		/*while (sCamp_Sales.compareTo(new BigDecimal("10000"))==1) {
			sCamp_Sales = sCamp_Sales.movePointLeft(1);
		}*/
			zCampSales				= turkishFormat.format(sCampSales);
			data.put("zCampSales",zCampSales);

			sTotalSales = sTotalSales.add( sCampSales);
			data.put("totalSales", sTotalSales);

			sCampID	 			= resultSet.getString(5);
			zCampStartDate	 	= resultSet.getString(6);
			sClicks	 				= resultSet.getString(7);
			sTypeID	 			= resultSet.getString(8);
			sDailyFlag	 			= resultSet.getString(9);
			sCampCode	 			= resultSet.getString(10);
			data.put("campId",sCampID);
			data.put("campStartDate",zCampStartDate);
			data.put("clicks",sClicks);
			data.put("typeId",sTypeID);
			data.put("dailyFlag",sDailyFlag);
			data.put("campCode",sCampCode);


			int intPurchases = Integer.parseInt(sCampPurchases);
			data.put("intPurchases",intPurchases);
			int intClicks = Integer.parseInt(sClicks);

			data.put("intClicks",intClicks);

			nConversion=(100.0 * intPurchases) /  intClicks;
			nConversionFormatted = String.format("%.2f", nConversion);
			data.put("nConversionFormatted", nConversionFormatted);


			if(sCampCode ==null){
				sCampCode ="-";
				data.put("sCamp_Code",sCampCode);
			}


			if(sTypeID.equals("4")) {
				//out.print("ssss");
				sDisplayType ="Automated";
				data.put("displayType",sDisplayType);
			}

			if(sTypeID.equals("2")) {
				sDisplayType ="Standard";
				data.put("displayType",sDisplayType);
			}


			//if(sType_ID.equals("2") && sDaily_Flag.equals("1")) {
			if (sTypeID.equals("2") ){
				if(sDailyFlag !=null){
					sDisplayType ="Check Daily";
					data.put("displayType",sDisplayType);
				}
			}



			dataArray.put(data);
		}
		ecommerce.put(dataArray);
		resultSet.close();

		SQL= "DROP TABLE #temp_activity  DROP TABLE #camp_id";
		statement.executeUpdate(SQL);


		dataArray = new JsonArray();
		data = new JsonObject();

		int iPurchases = Integer.parseInt(sPurchases);
		sAverageSales = sTotalSales.doubleValue() / iPurchases ;
		sAverageSalesFormatted = String.format("%.2f", sAverageSales);
		data.put("averageSalesFormated", sAverageSalesFormatted);


		sConversionRate = (100 * sTotalPurchasersInt)/ sTotalClicksINT;
		sConversionFormated = String.format("%.2f", sConversionRate);
		data.put("conversionFormated", sConversionFormated);

		zTotalSales = (turkishFormat.format(sTotalSales)==null)?"0,0TL":turkishFormat.format(sTotalSales);
		data.put("totalSales", zTotalSales);


		dataArray.put(data);

		ecommerce.put(dataArray);
		out.print(ecommerce.toString());


	}
	catch(Exception e){
		logger.error("rpt_ecommerce error for cust:"+sCustId+ e);
	}
	finally{
		try	{if (statement != null) statement.close();if (connection != null) connectionPool.free(connection);}
		catch (SQLException e)	{logger.error("Could not clean db statement or connection", e);	}
	}



%>

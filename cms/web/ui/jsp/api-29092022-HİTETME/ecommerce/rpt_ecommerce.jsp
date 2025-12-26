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

<%
	//String sCustId = cust.s_cust_id;
	String sCustId = request.getParameter("custId");
	String firstDate = request.getParameter("firstDate");
	String lastDate = request.getParameter("lastDate");


	System.out.println("Revotrack start for cust: "+sCustId);

	String date1 = "";
	String date2 = "";
	String date3 = "";


	Statement		stmt	= null;
	ResultSet		rs		= null;
	ConnectionPool	cp		= null;
	Connection		conn	= null;

	String sTotal_Clicks		=null;
	Double sTotal_Clicks_Int	=null;

	String sPurchases		=null;
	BigDecimal sTotal_Sales		=BigDecimal.ZERO;
	String zTotal_Sales		=null;

	String sTotal_Purchasers			=null;
	Double sTotal_Purchasers_Int		=null;

	Double sAverage_Sales		=null;
	String sCamp_Count			=null;

	Double sConversion_Rate;

	String sConversion_Formated = null;

	Double nConversion;
	String nConversion_Formated = null;

	String sAverage_Sales_Formated = null;


	StringBuilder Revotrack_TR = new StringBuilder();
	String SQL="";





	try{
		JsonObject data = new JsonObject();
		JsonArray dataArray = new JsonArray();
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();

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

			rs = stmt.executeQuery(SQL);

			while(rs.next()){
				date1=rs.getString(1);
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



		stmt.executeUpdate(SQL);


		SQL =    " IF OBJECT_ID('tempdb..#temp_activity') IS NOT NULL DROP TABLE #temp_activity " +
				" select rjtk.camp_id as camp_id, rjtk.rjtk_count as clicks  into #temp_activity from ccps_rjtk_link_activity as rjtk\n" +
				" where rjtk.camp_id in ( SELECT * FROM #camp_id )  and rjtk.type_id = 2 and rjtk.cust_id = " +sCustId +
				" and rjtk.click_time BETWEEN '"+date1+" 00:00:00' AND '"+date2+" 23:59:59'   " ;



		stmt.executeUpdate(SQL);



		SQL = "SELECT sum(clicks) FROM  #temp_activity ";

		rs = stmt.executeQuery(SQL);
		while(rs.next()){

			data = new JsonObject();
			sTotal_Clicks		= (rs.getString(1)==null) ? "0" : rs.getString(1);
			sTotal_Clicks_Int	= Double.parseDouble(sTotal_Clicks);
			data.put("click",sTotal_Clicks_Int);

			dataArray.put(data);

		}
		rs.close();


		SQL=       " SELECT  sum(orders) as purchases FROM untt_mbs_order_date  with(nolock) "
				+" WHERE cust_id = " +sCustId+ " and camp_id in (select * from #camp_id)"
				+" AND  date BETWEEN '"+date1+" 00:00:00' AND '"+date2+" 23:59:59' " ;

		rs = stmt.executeQuery(SQL);
		while(rs.next()){
			data = new JsonObject();
			sPurchases		=(rs.getString(1)==null) ? "0" : rs.getString(1);
			data.put("purchases",sPurchases);
			dataArray.put(data);

		}

		rs.close();





		SQL=	"  SELECT  sum(customers) as purchases "
				+" FROM untt_mbs_order_date "
				+" WHERE cust_id = " +sCustId+ " and camp_id in (select * from #camp_id)"
				+" AND  date BETWEEN '"+date1+" 00:00:00' AND '"+date2+" 23:59:59' " ;

		rs = stmt.executeQuery(SQL);
		while(rs.next()){
			data = new JsonObject();

			sTotal_Purchasers		= (rs.getString(1)==null) ? "0" : rs.getString(1);
			sTotal_Purchasers_Int	= Double.parseDouble(sTotal_Purchasers);

			data.put("Purchasers",sTotal_Purchasers_Int);
			dataArray.put(data);
		}
		rs.close();


		SQL="select count(camp_id) FROM #camp_id";

		rs = stmt.executeQuery(SQL);
		while(rs.next()){
			data = new JsonObject();
			sCamp_Count		=(rs.getString(1)==null) ? "0" : rs.getString(1);

			data.put("campCount",sCamp_Count);
			dataArray.put(data);
		}
		rs.close();



		SQL= "SELECT cc.camp_name,sum(mbs.orders) as purchasers ,sum(mbs.customers) as purchases ,sum(mbs.amount_sum) total ,  "
				+"	mbs.camp_id, rs.start_date, "
				+"  (select CASE WHEN sum(clicks)>0 THEN sum(clicks) ELSE 1 END  from #temp_activity  where  camp_id=mbs.camp_id  )  as clicks ,"
				+"	cc.type_id,rcs.queue_daily_flag,cc.camp_code  "
				+" FROM untt_mbs_order_date as mbs with(nolock)\n"
				+"	INNER JOIN cque_campaign cc with(nolock) on mbs.camp_id=cc.camp_id\n"
				+"	INNER JOIN cque_schedule rs with(nolock) on mbs.camp_id=rs.camp_id\n"
				+"	INNER JOIN cque_camp_send_param rcs with(nolock) on mbs.camp_id=rcs.camp_id\n"

				+"WHERE "
				+"	mbs.amount_sum is not null "
				+"	and cc.type_id in (2,4) "
				+"	and cc.cust_id=" +sCustId
				+"	and mbs.camp_id in ( select * from #camp_id ) "
				+"	and mbs.date BETWEEN '"+date1+" 00:00:00' AND '"+date2+" 23:59:59'"

				+" GROUP BY  mbs.camp_id,cc.camp_name,rs.start_date,rcs.queue_daily_flag,cc.type_id,cc.camp_code  "
				+" ORDER by  mbs.camp_id DESC ";





		rs = stmt.executeQuery(SQL);
		int iCount = 0;
		String sClassAppend = "_other";


		String sCamp_Name			=null;
		String sCamp_Purchasers		=null;
		String sCamp_Purchases		=null;
		BigDecimal sCamp_Sales		=BigDecimal.ZERO;
		String zCamp_Sales			=null;
		String sCamp_ID				=null;
		String zCamp_Start_Date		=null;
		String sClicks				=null;
		String sType_ID				=null;
		String sDaily_Flag			=null;
		String sDisplay_Type		=null;
		String sCamp_Code			=null;



		while(rs.next()){
			data = new JsonObject();
			if (iCount % 2 != 0) sClassAppend = "_other";
			else sClassAppend = "";
			iCount++;

			sCamp_Name 	 			= new String(rs.getBytes(1),"UTF-8");
			data.put("campName",sCamp_Name);

			sCamp_Purchasers		=(rs.getString(2)==null) ? "0.0" : rs.getString(2);
			data.put("campPurchasers",sCamp_Purchasers);
			sCamp_Purchases			= (rs.getString(3)==null) ? "0.0" : rs.getString(3);
			data.put("campPurchases",sCamp_Purchases);

			sCamp_Sales 			= rs.getBigDecimal(4).equals("null") ? BigDecimal.ZERO : rs.getBigDecimal(4);
			data.put("campSales",sCamp_Sales);
			sCamp_Sales 				= sCamp_Sales.setScale(2, BigDecimal.ROUND_HALF_EVEN);
			data.put("campSales",sCamp_Sales);

		/*while (sCamp_Sales.compareTo(new BigDecimal("10000"))==1) {
			sCamp_Sales = sCamp_Sales.movePointLeft(1);
		}*/
			zCamp_Sales				= turkishFormat.format(sCamp_Sales);
			data.put("zCampSales",zCamp_Sales);

			sTotal_Sales			= sTotal_Sales.add( sCamp_Sales);
			data.put("totalSales",sTotal_Sales);

			sCamp_ID	 			= rs.getString(5);
			zCamp_Start_Date	 	= rs.getString(6);
			sClicks	 				= rs.getString(7);
			sType_ID	 			= rs.getString(8);
			sDaily_Flag	 			= rs.getString(9);
			sCamp_Code	 			= rs.getString(10);
			data.put("campId",sCamp_ID);
			data.put("campStartDate",zCamp_Start_Date);
			data.put("clicks",sClicks);
			data.put("typeId",sType_ID);
			data.put("dailyFlag",sDaily_Flag);
			data.put("campCode",sCamp_Code);


			int intPurchases = Integer.parseInt(sCamp_Purchases);
			data.put("intPurchases",intPurchases);
			int intClicks = Integer.parseInt(sClicks);

			data.put("intClicks",intClicks);

			nConversion=(100.0 * intPurchases) /  intClicks;
			nConversion_Formated= String.format("%.2f", nConversion);
			data.put("nConversion_Formated",nConversion_Formated);


			if(sCamp_Code ==null){
				sCamp_Code ="-";
				data.put("sCamp_Code",sCamp_Code);
			}


			if(sType_ID.equals("4")) {
				//out.print("ssss");
				sDisplay_Type ="Automated";
				data.put("displayType",sDisplay_Type);
			}

			if(sType_ID.equals("2")) {
				sDisplay_Type ="Standard";
				data.put("displayType",sDisplay_Type);
			}


			//if(sType_ID.equals("2") && sDaily_Flag.equals("1")) {
			if (sType_ID.equals("2") ){
				if(sDaily_Flag !=null){
					sDisplay_Type ="Check Daily";
					data.put("displayType",sDisplay_Type);
				}
			}



			dataArray.put(data);
		}
		rs.close();

		SQL= "DROP TABLE #temp_activity  DROP TABLE #camp_id";
		stmt.executeUpdate(SQL);



		int iPurchases = Integer.parseInt(sPurchases);
		sAverage_Sales= sTotal_Sales.doubleValue() / iPurchases ;
		sAverage_Sales_Formated = String.format("%.2f", sAverage_Sales);
		data.put("averageSalesFormated",sAverage_Sales_Formated);


		sConversion_Rate = (100 * sTotal_Purchasers_Int)/sTotal_Clicks_Int;
		sConversion_Formated= String.format("%.2f", sConversion_Rate);
		data.put("conversionFormated",sConversion_Formated);

		zTotal_Sales 	= (turkishFormat.format(sTotal_Sales)==null)?"0,0TL":turkishFormat.format(sTotal_Sales);
		data.put("totalSales",zTotal_Sales);


		dataArray.put(data);
		out.print(dataArray.toString());


	}
	catch(Exception e){
		logger.error("rpt_ecommerce error for cust:"+sCustId+ e);
	}
	finally{
		try	{if (stmt != null) stmt.close();if (conn != null) cp.free(conn);}
		catch (SQLException e)	{logger.error("Could not clean db statement or connection", e);	}
	}


	response.setContentType("application/json");
	response.setCharacterEncoding("UTF-8");
	response.setHeader("Access-Control-Allow-Origin", "*");

%>

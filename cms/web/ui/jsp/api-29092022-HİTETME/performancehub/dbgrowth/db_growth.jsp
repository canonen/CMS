<%@ page
	language="java"
	import="com.britemoon.cps.rpt.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			com.britemoon.rcp.*, 
			com.britemoon.rcp.imc.*,
			com.britemoon.rcp.que.*,
			java.sql.*,
			java.util.Calendar,
			java.io.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*"
	contentType="text/html;charset=UTF-8"
%>
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

	response.setContentType("application/json");
	response.setCharacterEncoding("UTF-8");
	response.setHeader("Access-Control-Allow-Origin", "*");
	
//String sCustId =  cust.s_cust_id;
//Campaign camp = new Campaign();
//camp.s_cust_id = sCustId;

String	d_startdate = null;
String	d_enddate = null;

String sCustId = request.getParameter("custId");
String tarih_aralik  = request.getParameter("tarih_aralik");
String MonthlyGrowth = request.getParameter("MonthlyGrowth");
 if(tarih_aralik!=null){
 		String[] parts = tarih_aralik.split("-");
		d_startdate = parts[0];  
		d_enddate = parts[1];  
}  

Calendar calendar = Calendar.getInstance();

	JsonObject data = new JsonObject();
	JsonArray arrayData = new JsonArray();
	JsonArray dbGrotwthArray = new JsonArray();
	JsonObject dbGrotwthObject = new JsonObject();
	

         

int  current_year;
int  current_month;
int  current_month_cal;
int  current_day;

current_year = calendar.get(Calendar.YEAR); 
current_month = calendar.get(Calendar.MONTH); 
current_month_cal = current_month + 1;
current_day = calendar.get(Calendar.DAY_OF_MONTH); 
 
 
	Statement				stmt	= null;
	ResultSet				rs		= null; 
	ConnectionPool			cp		= null;
	Connection				conn	= null;

	String NewUsers ="";

	String Labelday ="";
	String UnsubUser ="";

	String WeekUser ="";
	String WeekUnsub ="";
	String Labelweek ="";

	String YearUser ="";
	String YearUnsub ="";
	String Labelyear ="";

	String YearOption="";

try{

	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

	String sSql_day = "";
  
	if(d_startdate!=null){
	
		sSql_day = "SELECT DAY(summary_date) DAY, sum(sub_count) COUNT FROM ccps_db_growth_summary with(nolock) WHERE summary_date >='"+d_startdate+"' AND summary_date<='"+d_enddate+"' AND cust_id = " + sCustId + " GROUP BY DAY(summary_date) ORDER BY 1 ";
	
	}else{
		sSql_day = "SELECT DAY(summary_date) DAY, sum(sub_count) COUNT FROM ccps_db_growth_summary with(nolock) WHERE MONTH(summary_date)="+current_month_cal+" AND YEAR(summary_date)="+current_year+" AND cust_id = " + sCustId + " GROUP BY DAY(summary_date) ORDER BY 1 ";
	
	}
	  
	rs = stmt.executeQuery(sSql_day);

	int iCount_D = 0;
	String sDay_D		=null;
	String sTotal_D		=null;
	String graph_cat_d 	= "";
	String graph_val1_d 	= "";
	arrayData = new JsonArray();
	while (rs.next())
	{
		data = new JsonObject();
		sDay_D 		= rs.getString(1);
		sTotal_D 	= rs.getString(2);

		data.put("day",sDay_D);
		data.put("total",sTotal_D);

		 
	//	NewUsers +="['"+ sDay_D +"',"+sTotal_D+"],";
	//		Labelday +="['"+ sDay_D +"',"+sDay_D+"],";
		iCount_D++;
		data.put("count",iCount_D);
		arrayData.put(data);
		
	}
	dbGrotwthObject.put("dayCount",arrayData);
	rs.close();
	
	String sSql_unsubday = "";
 
 	if(d_startdate!=null){
	
		sSql_unsubday = "SELECT DAY(summary_date) DAY, sum(unsub_count) COUNT FROM ccps_db_growth_summary with(nolock) WHERE summary_date >='"+d_startdate+"' AND summary_date<='"+d_enddate+"' AND cust_id = " + sCustId + " GROUP BY DAY(summary_date) ORDER BY 1 ";
	
	}else{
		sSql_unsubday = "SELECT DAY(summary_date) DAY, sum(unsub_count) COUNT FROM ccps_db_growth_summary with(nolock) WHERE MONTH(summary_date)="+current_month_cal+" AND YEAR(summary_date)="+current_year+" AND cust_id = " + sCustId + " GROUP BY DAY(summary_date) ORDER BY 1 ";
	
	}
	 
	rs = stmt.executeQuery(sSql_unsubday);
 	
	int iCount_unsub = 0;
	String sTotal_unsub 	= "";
	String sTotal_day 	= ""; 
	String graph_value_unsub 	= "";
	arrayData = new JsonArray();
	while (rs.next())
	{
		data = new JsonObject();
		sTotal_day 	= rs.getString(1);
		sTotal_unsub 	= rs.getString(2);

       data.put("day",sTotal_day);
	   data.put("totalUnsub",sTotal_unsub);


		UnsubUser +="['"+ sTotal_day +"',"+sTotal_unsub+"],";

		iCount_unsub++;
		data.put("countUnsub",iCount_unsub);

		arrayData.put(data);

	}
	dbGrotwthObject.put("dayCountSub",arrayData);
 
 rs.close();
 
int YearCount=1; 
 
 if(MonthlyGrowth==null){
	 MonthlyGrowth = new Integer(current_year).toString();
 } 
String sSql_UserYear="SELECT YEAR(summary_date)  FROM ccps_db_growth_summary with(nolock) WHERE cust_id = " + sCustId + "  GROUP BY YEAR(summary_date) ORDER BY 1 ";
rs = stmt.executeQuery(sSql_UserYear);

String select="";
arrayData = new JsonArray();
while (rs.next())
{
	data = new JsonObject();

	String x=rs.getString(1);

	data.put("year", x);
	
	if(x.equals(MonthlyGrowth)){
	 
	  select="selected" ;
 	}else{
		 select="";
	 }

  YearOption+="<option "+select +"  value='"+x+"'>"+x+"</option>";

	data.put("yearOption", YearOption);
	data.put("select",select);

	arrayData.put(data);
}
	dbGrotwthObject.put("yearSelect",arrayData);
rs.close();
 

String sSql_User_Week = "";
   			sSql_User_Week="IF Object_ID('TempDB..#MONTH_RECIP') IS NOT NULL  DROP TABLE #MONTH_RECIP "
									+"CREATE TABLE #MONTH_RECIP(  MONTH VARCHAR (100),  COUNT VARCHAR (100) )   "  
									+" INSERT INTO #MONTH_RECIP "
									+" SELECT '01', sum(sub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=01 and YEAR(summary_date)="+MonthlyGrowth+"  AND cust_id = " + sCustId + " UNION ALL "
									+" SELECT '02', sum(sub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=02 and YEAR(summary_date)="+MonthlyGrowth+"  AND cust_id = " + sCustId + " UNION ALL "
									+" SELECT '03', sum(sub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=03 and YEAR(summary_date)="+MonthlyGrowth+"  AND cust_id = " + sCustId + " UNION ALL "
									+" SELECT '04', sum(sub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=04 and YEAR(summary_date)="+MonthlyGrowth+"  AND cust_id = " + sCustId + " UNION ALL "
									+" SELECT '05', sum(sub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=05 and YEAR(summary_date)="+MonthlyGrowth+"  AND cust_id = " + sCustId + " UNION ALL "
									+" SELECT '06', sum(sub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=06 and YEAR(summary_date)="+MonthlyGrowth+"  AND cust_id = " + sCustId + " UNION ALL "
									+" SELECT '07', sum(sub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=07 and YEAR(summary_date)="+MonthlyGrowth+"  AND cust_id = " + sCustId + " UNION ALL "
									+" SELECT '08', sum(sub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=08 and YEAR(summary_date)="+MonthlyGrowth+"  AND cust_id = " + sCustId + " UNION ALL "
									+" SELECT '09', sum(sub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=09 and YEAR(summary_date)="+MonthlyGrowth+"  AND cust_id = " + sCustId + " UNION ALL "
									+" SELECT '10', sum(sub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=10 and YEAR(summary_date)="+MonthlyGrowth+"  AND cust_id = " + sCustId + " UNION ALL "
									+" SELECT '11', sum(sub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=11 and YEAR(summary_date)="+MonthlyGrowth+"  AND cust_id = " + sCustId + " UNION ALL "
									+" SELECT '12', sum(sub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=12 and YEAR(summary_date)="+MonthlyGrowth+"  AND cust_id = " + sCustId
					+" SELECT * FROM #MONTH_RECIP";

String sSql_Unsub_Week = "";
					sSql_Unsub_Week= "	IF Object_ID('TempDB..#MONTH_UNSUB') IS NOT NULL  DROP TABLE #MONTH_UNSUB "
											+"CREATE TABLE #MONTH_UNSUB(  MONTH VARCHAR (100),  COUNT VARCHAR (100) )  "
											+"INSERT INTO #MONTH_UNSUB "
											+"SELECT '01', sum(unsub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=01 and YEAR(summary_date)="+MonthlyGrowth+"  AND cust_id = " + sCustId + " UNION ALL "
											+"SELECT '02', sum(unsub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=02 and YEAR(summary_date)="+MonthlyGrowth+"  AND cust_id = " + sCustId + " UNION ALL "
											+"SELECT '03', sum(unsub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=03 and YEAR(summary_date)="+MonthlyGrowth+"  AND cust_id = " + sCustId + " UNION ALL "
											+"SELECT '04', sum(unsub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=04 and YEAR(summary_date)="+MonthlyGrowth+"  AND cust_id = " + sCustId + " UNION ALL "
											+"SELECT '05', sum(unsub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=05 and YEAR(summary_date)="+MonthlyGrowth+"  AND cust_id = " + sCustId + " UNION ALL "
											+"SELECT '06', sum(unsub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=06 and YEAR(summary_date)="+MonthlyGrowth+"  AND cust_id = " + sCustId + " UNION ALL "
											+"SELECT '07', sum(unsub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=07 and YEAR(summary_date)="+MonthlyGrowth+"  AND cust_id = " + sCustId + " UNION ALL "
											+"SELECT '08', sum(unsub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=08 and YEAR(summary_date)="+MonthlyGrowth+"  AND cust_id = " + sCustId + " UNION ALL "
											+"SELECT '09', sum(unsub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=09 and YEAR(summary_date)="+MonthlyGrowth+"  AND cust_id = " + sCustId + " UNION ALL "
											+"SELECT '10', sum(unsub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=10 and YEAR(summary_date)="+MonthlyGrowth+"  AND cust_id = " + sCustId + " UNION ALL "
											+"SELECT '11', sum(unsub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=11 and YEAR(summary_date)="+MonthlyGrowth+"  AND cust_id = " + sCustId + " UNION ALL "
											+"SELECT '12', sum(unsub_count)  from  ccps_db_growth_summary where MONTH(summary_date)=12 and YEAR(summary_date)="+MonthlyGrowth+"  AND cust_id = " + sCustId
							+"SELECT * FROM #MONTH_UNSUB ";
		 
rs = stmt.executeQuery(sSql_User_Week);

int iCount2 = 0;
String sDate_w		=null;
String sTotal_w		=null;
String graph_cat_w 	= "";
String graph_val1_w 	= "";
arrayData = new JsonArray();

while (rs.next())
{
	data = new JsonObject();
	
	sDate_w 		= rs.getString(1);
	sTotal_w 		= rs.getString(2);

	data.put("weekUser",sDate_w);
	data.put("totalWeek",sTotal_w);

	//WeekUser +="['"+ sDate_w +"',"+sTotal_w+"],";
 
	//Labelweek +="['"+ sDate_w +"',"+sDate_w+"],";

	iCount2++;
	data.put("count",iCount2);
	arrayData.put(data);
}
	dbGrotwthObject.put("weekCount",arrayData);
rs.close();

rs = stmt.executeQuery(sSql_Unsub_Week);
arrayData = new JsonArray();
while (rs.next())
{
	data = new JsonObject();
	sDate_w 		= rs.getString(1);
	sTotal_w 		= rs.getString(2);

	data.put("weekUser", sDate_w);
	data.put("weekUnsubTotal",sTotal_w);

	//WeekUnsub +="['"+sDate_w +"',"+sTotal_w+"],";

	iCount2++;
	data.put("count", iCount2);

	arrayData.put(data);


} 
dbGrotwthObject.put("weekCountSub",arrayData);
rs.close(); 


 
	
	String sSql_years = "SELECT sum(sub_count) as Total_Recipient, YEAR(summary_date) as R_Year FROM ccps_db_growth_summary with(nolock) WHERE cust_id = " + sCustId + " GROUP BY YEAR(summary_date)  ORDER BY YEAR(summary_date) ";
		rs = stmt.executeQuery(sSql_years);
		arrayData = new JsonArray();
 
		while (rs.next()) {
			data = new JsonObject();
			
			sDate_w 		= rs.getString(1);
			sTotal_w 		= rs.getString(2);

			data.put("yeaar",sDate_w);
			data.put("total",sTotal_w);
			
		//	YearUser +="['"+ sTotal_w +"',"+sDate_w+"],";
		
		//	Labelyear +="['"+ sTotal_w +"',"+sTotal_w+"],";
			iCount2++;

			data.put("count",iCount2);

			arrayData.put(data);
		}
	dbGrotwthObject.put("yearCount",arrayData);
	rs.close();


	String 	sSql_unsub_years= "SELECT YEAR(summary_date) YEAR, sum(unsub_count) COUNT FROM ccps_db_growth_summary with(nolock) WHERE cust_id = " + sCustId + " GROUP BY YEAR(summary_date) ORDER BY 1";
	   rs = stmt.executeQuery(sSql_unsub_years);
	   arrayData = new JsonArray();
		while (rs.next()) {
			data = new JsonObject();

			sDate_w 		= rs.getString(1);
			sTotal_w 		= rs.getString(2);
			data.put("unSubYear",sDate_w);
			data.put("total",sTotal_w);
			iCount2++;
			data.put("count",iCount2);
			arrayData.put(data);
		}
	dbGrotwthObject.put("yearCountSub",arrayData);
	dbGrotwthArray.put(dbGrotwthObject);
	rs.close();


}
catch(Exception ex)
{ 
	ErrLog.put(this, ex, "Error in " + this.getClass().getName(), out, 1);
}
finally
{
	try
	{
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}
	catch (SQLException e)
	{
		logger.error("Could not clean db statement or connection", e);
	}
}


out.print(dbGrotwthArray.toString());


	

%>

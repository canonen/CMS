<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.rpt.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.*,
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
<% if(logger == null) 	{ 	logger = Logger.getLogger(this.getClass().getName()); } %>

<%
	Calendar calendar = Calendar.getInstance();

//String sCustId = cust.s_cust_id;
//Campaign camp = new Campaign();
//camp.s_cust_id = sCustId

String	d_startdate = null;
String	d_enddate = null;

	Integer MonthlyGrowth =0;
String sCustId = request.getParameter("custId");
String firstDate = request.getParameter("firstDate");
String lastDate = request.getParameter("lastDate");
String MonthlyGrowth1 = request.getParameter("monthlyGrowth");



        

int  current_year;
int  current_month;
int  current_month_cal;
int  current_day;

current_year = calendar.get(Calendar.YEAR); 
current_month = calendar.get(Calendar.MONTH); 
current_month_cal = current_month + 1;
current_day = calendar.get(Calendar.DAY_OF_MONTH); 
 
 

ConnectionPool	cp		= null;
Connection 		conn	= null;
Statement		stmt	= null;
ResultSet 		rs		= null;



String YearOption =null;



	if (MonthlyGrowth1 != null && !MonthlyGrowth1.equals(null) ) {
		MonthlyGrowth = Integer.parseInt(MonthlyGrowth1);
	}else {
		MonthlyGrowth = calendar.get(Calendar.YEAR);
	}


try{


	JsonObject data = new JsonObject();
	JsonArray dataArray = new JsonArray();

	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

	String sSql_day = "";


		sSql_day = "SELECT DAY(date) DAY, SUM(amount_sum) FROM untt_mbs_order_date with(nolock)WHERE cust_id = "+sCustId+" AND date >='"+firstDate+"' AND date<='"+lastDate+"' GROUP BY DAY(date) ORDER BY 1 ;";
	

	rs = stmt.executeQuery(sSql_day);

	int iCount_D = 0;
	String sDay_D			=null;
	String sTotal_D			=null;
	String graph_cat_d 		= "";
	String graph_val1_d 	= "";
	String daily_rev 		="";


	while (rs.next())
	{
		data = new JsonObject();

		sDay_D 		= rs.getString(1);
		sTotal_D 	= rs.getString(2);

		data.put("day",sDay_D);
		data.put("sum",sTotal_D);
		iCount_D++;
		data.put("icountD",iCount_D);

		dataArray.put(data);
	} 

	rs.close();



	String sSql_UserYear= "select YEAR(date)  from untt_mbs_order_date with(nolock) \n" +
			"where cust_id = "+sCustId+" and  camp_id in (select camp_id from cque_campaign with(nolock) where cust_id = "+sCustId+" and type_id in (2,4)) and YEAR(date) is not null \n" +
			"GROUP BY YEAR(date) ORDER BY 1;";
	rs = stmt.executeQuery(sSql_UserYear);

	String select="";
	while (rs.next())
	{
		data = new JsonObject();
		String x=rs.getString(1);
		data.put("year",x);


		dataArray.put(data);



	}  
	rs.close();


	
	String sSql = "";
	sSql = "select sum(amount_sum) as Total, CONVERT(VARCHAR(7), date, 111) as 'Date ' \n" +
			"from untt_mbs_order_date with(nolock) where cust_id = "+sCustId+" and  camp_id in (select camp_id from cque_campaign with(nolock) \n" +
			"where type_id in (2,4)) and cust_id = "+sCustId+"  and amount_sum is not null and date BETWEEN  '"+MonthlyGrowth+"-01-01' AND '"+MonthlyGrowth+"-12-31' " +
			"group by CONVERT(VARCHAR(7), date, 111) order by 2 ;" ;
	rs = stmt.executeQuery(sSql);

	int iCount = 0;
	String sDate		=null;
	String sTotal		=null;
	String graph_cat 	= "";
	String graph_val1 	= "";
	String m_xxx 	= "";

	while (rs.next())
	{
		data = new JsonObject();
		sDate 		= rs.getString(1);
		sTotal 		= rs.getString(2);

		data.put("year",sDate);
		data.put("totalYear",sTotal);
		iCount++;
		data.put("iCount",iCount);
		dataArray.put(data);
	} 
	rs.close();
 
	String sSql_Week = "";
	sSql_Week ="SELECT sum(amount_sum) as 'Amount' , DATENAME(dw, date)  as 'days', DATEPART(dw, date) as 'Number' \n" +
			"FROM untt_mbs_order_date with(nolock) \n" +
			"WHERE amount_sum is not null and cust_id= "+sCustId+" and camp_id in (select camp_id from cque_campaign with(nolock) \n" +
			"where type_id in (2,4)and cust_id= "+sCustId+" )  GROUP BY DATENAME(dw, date), DATEPART(dw, date) ORDER BY 3 asc ; ";
	//sSql_Week = "select sum(_amount) as Total, CONVERT(VARCHAR(7), _order_date_time, 111) as 'Date ' from untt_mbs_order with(nolock) where _amount is not null group by CONVERT(VARCHAR(7), _order_date_time, 111) order by 1 ";
	rs = stmt.executeQuery(sSql_Week);

	int iCount2 = 0;
	String sDate_w		=null;
	String sTotal_w		=null;
	String graph_cat_w 	= "";
	String graph_val1_w 	= "";
	String xxx ="";

	while (rs.next()){
		data = new JsonObject();
		sDate_w 		= rs.getString(2);
		sTotal_w 		= rs.getString(1);
		data.put("date",sDate_w);
		data.put("total",sTotal_w);
		iCount2++;
		data.put("icount",iCount2);

		dataArray.put(data);
	} 
	rs.close();

	out.print(dataArray.toString());






}
catch(Exception ex){	ErrLog.put(this, ex, "Error in " + this.getClass().getName(), out, 1);}
finally{
	try	{if (stmt != null) stmt.close();if (conn != null) cp.free(conn);}
	catch (SQLException e)	{logger.error("Could not clean db statement or connection", e);	}

}

	response.setContentType("application/json");
	response.setCharacterEncoding("UTF-8");
	response.setHeader("Access-Control-Allow-Origin", "*");

%>

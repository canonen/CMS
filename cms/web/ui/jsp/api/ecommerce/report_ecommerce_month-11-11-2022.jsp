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

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%
	String sCustId = cust.s_cust_id;
	Campaign camp = new Campaign();
	camp.s_cust_id = sCustId;


	String	d_startdate = null;
	String	d_enddate = null;

	String firstDate  = request.getParameter("firstDate");
	String lastDate  = request.getParameter("lastDate");
	String MonthlyGrowth = request.getParameter("MonthlyGrowth");
	if(firstDate!=null){
		d_startdate = firstDate;
	}
	if(lastDate!=null){
		d_enddate = lastDate;
	}

	Calendar calendar = Calendar.getInstance();


	int  current_year;
	int  current_month;
	int  current_month_cal;
	int  current_day;

	current_year = calendar.get(Calendar.YEAR);
	current_month = calendar.get(Calendar.MONTH);
	current_month_cal = current_month + 1;
	current_day = calendar.get(Calendar.DAY_OF_MONTH);



	ConnectionPool	connectionPool		= null;
	Connection 		connection	= null;
	Statement		statement	= null;
	ResultSet 		resultSet		= null;


	if(MonthlyGrowth==null){
		MonthlyGrowth = new Integer(current_year).toString();
	}

	try{


	JsonObject data = new JsonObject();
	JsonArray dataArray = new JsonArray();
	JsonArray ecommerceMonth = new JsonArray();

	connectionPool = ConnectionPool.getInstance();
	connection = connectionPool.getConnection(this);
	statement = connection.createStatement();

	String sSql_day = "";


		sSql_day = "SELECT DAY(date) DAY, SUM(amount_sum) FROM untt_mbs_order_date with(nolock)WHERE cust_id = "+sCustId+" AND date >='"+firstDate+"' AND date<='"+lastDate+"' GROUP BY DAY(date) ORDER BY 1 ;";
	

	resultSet = statement.executeQuery(sSql_day);

	int iCount_D = 0;
	String sDay_D			=null;
	String sTotal_D			=null;


		dataArray = new JsonArray();
	while (resultSet.next())
	{
		data = new JsonObject();

		sDay_D 		= resultSet.getString(1);
		sTotal_D 	= resultSet.getString(2);

		data.put("day",sDay_D);
		data.put("sum",sTotal_D);

		dataArray.put(data);
	}
	ecommerceMonth.put(dataArray);
	resultSet.close();



	String sSql_UserYear= "select YEAR(date)  from untt_mbs_order_date with(nolock) \n" +
			"where cust_id = "+sCustId+" and  camp_id in (select camp_id from cque_campaign with(nolock) where cust_id = "+sCustId+" and type_id in (2,4)) and YEAR(date) is not null \n" +
			"GROUP BY YEAR(date) ORDER BY 1;";
	resultSet = statement.executeQuery(sSql_UserYear);

	dataArray = new JsonArray();
	while (resultSet.next())
	{
		data = new JsonObject();
		String x=resultSet.getString(1);
		data.put("year",x);

		dataArray.put(data);


	}
	ecommerceMonth.put(dataArray);
	resultSet.close();


	
	String sSql = "";
	sSql = "select sum(amount_sum) as Total, CONVERT(VARCHAR(7), date, 111) as 'Date ' \n" +
			"from untt_mbs_order_date with(nolock) where cust_id = "+sCustId+" and  camp_id in (select camp_id from cque_campaign with(nolock) \n" +
			"where type_id in (2,4)) and cust_id = "+sCustId+"  and amount_sum is not null and date BETWEEN  '"+MonthlyGrowth+"-01-01' AND '"+MonthlyGrowth+"-12-31' " +
			"group by CONVERT(VARCHAR(7), date, 111) order by 2 ;" ;
	resultSet = statement.executeQuery(sSql);


	String sDate		=null;
	String sTotal		=null;
		dataArray = new JsonArray();
	while (resultSet.next())
	{
		data = new JsonObject();
		sDate 		= resultSet.getString(1);
		sTotal 		= resultSet.getString(2);

		data.put("year",sDate);
		data.put("totalYear",sTotal);

		dataArray.put(data);
	}
	ecommerceMonth.put(dataArray);
	resultSet.close();
 
	String sSql_Week = "";
	sSql_Week ="SELECT sum(amount_sum) as 'Amount' , DATENAME(dw, date)  as 'days', DATEPART(dw, date) as 'Number' \n" +
			"FROM untt_mbs_order_date with(nolock) \n" +
			"WHERE amount_sum is not null and cust_id= "+sCustId+" and camp_id in (select camp_id from cque_campaign with(nolock) \n" +
			"where type_id in (2,4)and cust_id= "+sCustId+" )  GROUP BY DATENAME(dw, date), DATEPART(dw, date) ORDER BY 3 asc ; ";
	//sSql_Week = "select sum(_amount) as Total, CONVERT(VARCHAR(7), _order_date_time, 111) as 'Date ' from untt_mbs_order with(nolock) where _amount is not null group by CONVERT(VARCHAR(7), _order_date_time, 111) order by 1 ";
	resultSet = statement.executeQuery(sSql_Week);


	String sDate_w		=null;
	String sTotal_w		=null;


		dataArray = new JsonArray();
	while (resultSet.next()){
		data = new JsonObject();

		sDate_w 		= resultSet.getString(2);
		sTotal_w 		= resultSet.getString(1);

		data.put("date",sDate_w);
		data.put("total",sTotal_w);


		dataArray.put(data);
	}
	ecommerceMonth.put(dataArray);
	resultSet.close();

	out.print(ecommerceMonth.toString());


}
catch(Exception ex){	ErrLog.put(this, ex, "Error in " + this.getClass().getName(), out, 1);}
finally{
	try	{
		if (resultSet != null) resultSet.close();
		if (statement != null) statement.close();
		if (connection != null) connectionPool.free(connection);
		}
	catch (SQLException e)	{logger.error("Could not clean db statement or connection", e);	}

}

%>

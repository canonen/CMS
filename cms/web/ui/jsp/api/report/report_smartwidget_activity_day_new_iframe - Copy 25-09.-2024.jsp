<%@ page
        language="java"
        import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.que.*,
			java.sql.*,
			java.util.Calendar,
			java.io.*,
			org.apache.log4j.Logger,
			java.text.DateFormat,
			java.sql.Timestamp,
			java.text.SimpleDateFormat,
			org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.util.Vector" %>
<%@ page import="java.text.ParseException" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>

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
  response.setHeader("Access-Control-Allow-Headers", "x-requested-with, content-type");
  response.setHeader("Access-Control-Allow-Origin", "https://cms.revotas.com:3001");
  response.setHeader("Access-Control-Allow-Credentials", "true");
  response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
%>

<%@ include file = "../validator.jsp"%>

<%

  System.out.println("--------------SMARTWIDGETACTIVITY----------");
  String sCustId = cust.s_cust_id;
  Service service = null;
  Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, sCustId);
  service = (Service) services.get(0);
  String rcpLink = service.getURL().getHost();
  String popupId = request.getParameter("popup_id");
  Campaign camp = new Campaign();
  camp.s_cust_id = sCustId;

  Timestamp d_startdate = null;
  Timestamp d_enddate = null;


  String date_between = request.getParameter("date_between");

  JsonObject activityObj = new JsonObject();
  JsonArray activityArr = new JsonArray();
  JsonObject configObj = new JsonObject();
  JsonArray configArr = new JsonArray();
  JsonObject totalObj = new JsonObject();
  JsonArray totalArr = new JsonArray();
  JsonObject jsonObj = new JsonObject();


  if (date_between != null) {
    String[] parts = date_between.split("-");

    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");

    try {
      d_startdate = new Timestamp(dateFormat.parse(parts[0] + " 00:00:00").getTime());

      d_enddate = new Timestamp(dateFormat.parse(parts[1] + " 23:59:59").getTime());
    } catch (ParseException e) {
      e.printStackTrace();
    }

  }
  Statement				stmt	= null;
  ResultSet				rs		= null;
  ConnectionPool			cp		= null;
  Connection				conn	= null;
  System.out.println("d_startdate 33"+d_startdate);
  System.out.println("d_enddate 33"+d_enddate);

  try{
    cp = ConnectionPool.getInstance();
    conn = cp.getConnection(this);
    stmt = conn.createStatement();

    String sSql_day = "";
    String sSql_total = "";

    if(d_startdate!=null){

      sSql_total = "SELECT SUM(CASE WHEN type_name = 1 THEN activity ELSE 0 END) AS total_click_activity," +
              " SUM(CASE WHEN type_name = 2 THEN activity ELSE 0 END) AS total_submit_activity," +
              " SUM(impression) AS total_impression," +
              " SUM(revenue) AS total_revenue " +
              " FROM " +
              " ccps_smart_widget_activity_day WITH (NOLOCK) WHERE " +
              " cust_id="+sCustId+" AND activity_date >='"
              +d_startdate+"' AND activity_date<='"
              +d_enddate+"' AND popup_id ='"+popupId+"' ";

    }else{

      sSql_total = "SELECT SUM(CASE WHEN type_name = 1 THEN activity ELSE 0 END) AS total_click_activity," +
              " SUM(CASE WHEN type_name = 2 THEN activity ELSE 0 END) AS total_submit_activity," +
              " SUM(impression) AS total_impression," +
              " SUM(revenue) AS total_revenue " +
              " FROM " +
              " ccps_smart_widget_activity_day WITH (NOLOCK) WHERE "
              +"cust_id="+sCustId+" AND popup_id ='"+popupId+"' AND activity_date >= DATEADD(day, -30, getdate()) ";

    }

    rs = stmt.executeQuery(sSql_total);

    while(rs.next()) {
      totalObj = new JsonObject();

      String total_click_activity = rs.getString(1);
      String total_submit_activity = rs.getString(2);
      String total_impression = rs.getString(3);
      String total_revenue = rs.getString(4);

      totalObj.put("total_click_activity",total_click_activity );
      totalObj.put("total_submit_activity",total_submit_activity );
      totalObj.put("total_impression",total_impression );
      totalObj.put("total_revenue",total_revenue);


      totalArr.put(totalObj);
    }
    //out.println("totalData: "+ totalArr);
    jsonObj.put("totalArr", totalArr);
    rs.close();


    if(d_startdate!=null){

      sSql_day = "SELECT \n" +
              "    CONVERT(VARCHAR(10), activity_date, 120) AS DAY,\n" +
              "    popup_id,\n" +
              "    form_id,\n" +
              "    type_name,\n" +
              "    CASE \n" +
              "        WHEN type_name = 1 THEN activity\n" +
              "        ELSE 0 " +
              "    END AS click,\n" +
              "    CASE \n" +
              "        WHEN type_name = 2 THEN activity\n" +
              "        ELSE 0 " +
              "    END AS submit," +
              "impression, revenue from ccps_smart_widget_activity_day with(nolock) WHERE "
              +"cust_id="+sCustId+" AND activity_date >='"
              +d_startdate+"' AND activity_date<='"
              +d_enddate+"' AND popup_id ='"+popupId+"' " +
              "GROUP BY CONVERT(VARCHAR(10), activity_date, 120), popup_id, form_id, type_name, activity, impression, revenue ORDER BY 1";
    }else{

      sSql_day = "SELECT \n" +
              "    CONVERT(VARCHAR(10), activity_date, 120) AS DAY,\n" +
              "    popup_id,\n" +
              "    form_id,\n" +
              "    type_name,\n" +
              "    CASE \n" +
              "        WHEN type_name = 1 THEN activity\n" +
              "        ELSE 0 " +
              "    END AS click,\n" +
              "    CASE \n" +
              "        WHEN type_name = 2 THEN activity\n" +
              "        ELSE 0 " +
              "    END AS submit," +
              "impression, revenue from ccps_smart_widget_activity_day with(nolock) WHERE "
              +"cust_id="+sCustId+" AND popup_id ='"+popupId+"' AND activity_date >= DATEADD(day, -30, getdate()) GROUP BY CONVERT(VARCHAR(10), activity_date, 120), popup_id, form_id, type_name, activity, impression, revenue ORDER BY 1";
    }

    rs = stmt.executeQuery(sSql_day);

    while (rs.next())
    {
      activityObj = new JsonObject();

      String day = rs.getString(1);
      String popup_id = rs.getString(2);
      String form_id = rs.getString(3);
      String type_name = rs.getString(4);
      String click = rs.getString(5);
      String submit = rs.getString(6);
      String impression = rs.getString(7);
      String revenue = rs.getString(8);

      activityObj.put("day",day );
      activityObj.put("submit", submit);
      activityObj.put("popup_id",popup_id );
      activityObj.put("form_id",form_id );
      activityObj.put("type_name",type_name );
      activityObj.put("click",click );
      activityObj.put("impression",impression );
      activityObj.put("revenue", revenue);

      activityArr.put(activityObj);
    }
    //out.println("activityData: " + activityArr);
    jsonObj.put("activityArr",activityArr);
    out.println(jsonObj);
    rs.close();


	 /*String sql = "select popup_id, popup_name, config_param, form_id, create_date, modify_date from c_smart_widget_config where cust_id= "+sCustId;

	 rs = stmt.executeQuery(sql);

	 while(rs.next()) {
		 configObj = new JsonObject();

			String popup_id = rs.getString(1);
			String popup_name = rs.getString(2);
		 	String config_param = rs.getString(3);
			String form_id = rs.getString(4);
			String create_date = DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp(5));
			String modify_date = DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(rs.getTimestamp(6));


		 configObj.put("popup_id",popup_id );
		 configObj.put("popup_name",popup_name );
		 configObj.put("configParam",config_param);
		 configObj.put("form_id",form_id );
		 configObj.put("create_date",create_date);
		 configObj.put("modify_date", modify_date);

		 configArr.put(configObj);
	 }
	 out.println("Config Data: "+ configArr);
	rs.close();
*/
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

%>

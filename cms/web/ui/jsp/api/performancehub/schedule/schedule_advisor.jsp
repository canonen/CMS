<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.rcp.*,
                com.britemoon.rcp.que.*,
                java.io.*,
                java.sql.*,
                java.util.*,
                org.w3c.dom.*,
                javax.mail.*,
                org.apache.log4j.Logger,
                com.britemoon.cps.rpt.*,
                com.britemoon.cps.tgt.*,
                com.britemoon.cps.que.*,
                com.britemoon.cps.cnt.*,
                com.britemoon.cps.*,
                com.britemoon.*,
                com.britemoon.rcp.imc.*,
                java.util.Calendar"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%
  if (logger == null) {
    logger = Logger.getLogger(this.getClass().getName());
  }
%>
<%@ include file="../../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%

  boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

  String sCustId = cust.s_cust_id;
  Campaign camp = new Campaign();
  camp.s_cust_id = sCustId;


  ConnectionPool cp = null;
  Connection conn = null;
  Statement stmt = null;
  ResultSet rs = null;


  JsonObject data = new JsonObject();
  JsonArray arrayData = new JsonArray();
  JsonArray schuleAdvisorArrayData = new JsonArray();


  try {

    cp = ConnectionPool.getInstance();
    conn = cp.getConnection(this);
    stmt = conn.createStatement();

    String sSql_ard = "select opens,days,days_num from ccps_schedule_advisor_day_report where cust_id = " + sCustId + " order by days_num";
    rs = stmt.executeQuery(sSql_ard);


    String opens = "";
    String days = "";
    String daysNum = "";


    while (rs.next()) {

      data = new JsonObject();
      opens = rs.getString(1);
      days = rs.getString(2);
      daysNum = rs.getString(3);

      data.put("open", opens);
      data.put("days", days);
      data.put("daysNum", daysNum);

      arrayData.put(data);

    }
    schuleAdvisorArrayData.put(arrayData);
    rs.close();

    String sSql = "select hours,opens1,clicks,pct from ccps_schedule_advisor_report where cust_id = " + sCustId + " order by hours";
    rs = stmt.executeQuery(sSql);

    String hours = "";
    String opens1 = "";
    String clicks = "";
    String pct = "";


    arrayData = new JsonArray();
    while (rs.next()) {
      data = new JsonObject();

      hours = rs.getString(1);
      opens1 = rs.getString(2);
      clicks = rs.getString(3);
      pct = rs.getString(4);

      pct = "%" + pct;

      data.put("hours", hours);
      data.put("open", opens1);
      data.put("clicks", clicks);
      data.put("pct", pct);

      arrayData.put(data);
    }
    schuleAdvisorArrayData.put(arrayData);
    out.println(schuleAdvisorArrayData);
    rs.close();

  } catch (Exception ex) {
    ex.printStackTrace(new PrintWriter(out));
  } finally {
    if (stmt != null) stmt.close();
    if (conn != null) cp.free(conn);
  }


%>
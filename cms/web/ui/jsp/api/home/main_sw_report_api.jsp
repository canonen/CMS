<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.*,
                com.britemoon.cps.imc.*,
                com.britemoon.cps.que.*,
                java.text.DecimalFormat,
                java.sql.*,
                java.io.*,
                org.apache.log4j.Logger,
                org.w3c.dom.*"
%>
<%@ page import="java.util.Vector" %>
<%! static Logger logger = null;%>
<%
  if (logger == null) {
    logger = Logger.getLogger(this.getClass().getName());
  }
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<% response.setContentType("application/json;charset=UTF-8"); %>
<%
  String sCustId = cust.s_cust_id;
  Service service = null;
  Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, sCustId);
  service = (Service) services.get(0);
  String rcpLink = service.getURL().getHost();
  Campaign camp = new Campaign();
  camp.s_cust_id = sCustId;
  String firstDate = request.getParameter("firstDate");
  String lastDate = request.getParameter("lastDate");
  Statement stmt = null;
  ResultSet rs = null;
  ConnectionPool cp = null;
  Connection conn = null;

  JsonObject object = new JsonObject();
  JsonArray array = new JsonArray();
  DecimalFormat formatter = new DecimalFormat("#,###.## TL");
  try {
    cp = ConnectionPool.getInstance();
    conn = cp.getConnection(this);
    stmt = conn.createStatement();


    String sSql_day = "";
    sSql_day = "select c.popup_id, c.popup_name, c.status , sum(a.activity) as activity, sum(a.impression) as impression, a.revenue " +
            " from c_smart_widget_config AS c LEFT JOIN ccps_smart_widget_activity_day AS a ON c.popup_id = a.popup_id " +
            " WHERE c.status<>90  and " + "a.cust_id=" + sCustId + " AND a.activity_date >='" + firstDate + "' " +
            " AND a.activity_date<='" + lastDate + "' group by c.popup_id,  a.revenue, c.popup_name,c.status  ORDER BY 3 DESC";
    rs = stmt.executeQuery(sSql_day);

    while (rs.next()) {
      object = new JsonObject();
      String popup_id = rs.getString(1);
      String popup_name = rs.getString(2);
      String status = rs.getString(3);
      String click = rs.getString(4);
      String view = rs.getString(5);
      double revenue = rs.getDouble(6);
      object.put("click", click);
      object.put("view", view);
      object.put("revenue", formatter.format(revenue));
      object.put("popupName", popup_name);
      object.put("poup_id",popup_id);
      object.put("status",status);
      array.put(object);
    }
    rs.close();
    out.print(array);
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

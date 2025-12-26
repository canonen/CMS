<%@ page
        language="java"
        import="com.britemoon.*,
            com.britemoon.cps.*,
            java.util.*,java.sql.*,
            java.net.*,org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>

<%@ page import="java.util.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>

<%
  if (logger == null) {
    logger = Logger.getLogger(this.getClass().getName());
  }

  Statement stmt = null;
  ResultSet rs = null;
  ConnectionPool cp = null;
  Connection conn = null;

  JsonObject responseJson = new JsonObject();
  JsonArray summaryArray = new JsonArray();


  try {
    cp = ConnectionPool.getInstance();
    conn = cp.getConnection(this);
    stmt = conn.createStatement();

    String sCustId = cust.s_cust_id;
    String begin_date = request.getParameter("begin_date");
    String end_date = request.getParameter("end_date");

    String sSql = "select * from crpt_camp_summary where cust_id= "+sCustId+" AND start_date between '"+begin_date+" 00:00:00' AND '"+end_date+" 23:59:59' order by start_date";
    rs=stmt.executeQuery(sSql);
    while (rs.next()){
      JsonObject obj = new JsonObject();
      obj.put("camp_id",rs.getString(1));
      obj.put("cust_id",rs.getString(2));
      obj.put("camp_name",new String(rs.getBytes(3), "UTF-8"));
      obj.put("sent",rs.getString(4));
      obj.put("start_date",rs.getString(5));
      obj.put("bback",rs.getString(6));
      obj.put("reaching",rs.getString(7));
      obj.put("dist_reads",rs.getString(8));
      obj.put("tot_reads",rs.getString(9));
      obj.put("dist_clicks",rs.getString(10));
      obj.put("unsubs",rs.getString(11));
      obj.put("tot_click",rs.getString(12));
      obj.put("tot_text_clicks",rs.getString(13));
      obj.put("tot_html_clicks",rs.getString(14));
      obj.put("tot_aol_clicks",rs.getString(15));
      obj.put("tot_links",rs.getString(16));
      obj.put("last_update_date",rs.getString(17));
      obj.put("dist_text_clicks",rs.getString(18));
      obj.put("dist_html_clicks",rs.getString(19));
      obj.put("dist_aol_clicks",rs.getString(20));
      obj.put("multi_readers",rs.getString(21));
      obj.put("link_multi_clickers",rs.getString(22));
      obj.put("multi_link_clickers",rs.getString(23));
      obj.put("status_id",rs.getString(24));
      obj.put("update_job_id",rs.getString(25));
      summaryArray.put(obj);

    }

    out.println(summaryArray.toString());


  } catch (Exception ex) {
    responseJson.put("error", ex.getMessage());
    out.print(responseJson.toString());
  } finally {
    if (rs != null) rs.close();
    if (stmt != null) stmt.close();
    if (conn != null) cp.free(conn);
  }
%>
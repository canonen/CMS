<%@ page
        language="java"
        import="com.britemoon.*,
		        t.*,
		        com.britemoon.cps.*,
		        java.sql.*,
		        java.text.DecimalFormat,
		        org.apache.log4j.Logger"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="org.w3c.dom.NodeList" %>
<%@ page import="org.w3c.dom.Element" %>
<%@ page import="org.w3c.dom.Node" %>
<%@ page import="javax.xml.parsers.DocumentBuilder" %>
<%@ page import="org.w3c.dom.Document" %>
<%@ page import="java.io.StringWriter" %>
<%@ page import="javax.xml.parsers.DocumentBuilderFactory" %>
<%@ page import="org.xml.sax.InputSource" %>
<%@ page import="java.io.ByteArrayInputStream" %>
<%@ page import="com.britemoon.cps.imc.*" %>
<%@ page import="com.britemoon.cps.imc.Service" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%! static Logger logger = null;%>
<%
  if (logger == null) {
    logger = Logger.getLogger(this.getClass().getName());
  }
%>

<%!
  public class XmlParse {        //++++

    public String productId = null;
    public String productName = null;
    public String link = null;
    public String source = null;
    public String rvsSource = null;
    public String rvsMedium = null;
    public String insertDate = null;
    public String qty = null;
    public String sumAmt = null;
    public String avgAmt = null;
    public String avgQty = null;


    public XmlParse(Element element) {

      productId = Deger(element.getElementsByTagName("productId")).equals("null") ? null : Deger(element.getElementsByTagName("productId"));
      productName = Deger(element.getElementsByTagName("productName")).equals("null") ? null : Deger(element.getElementsByTagName("productName"));
      link = Deger(element.getElementsByTagName("link")).equals("null") ? null : Deger(element.getElementsByTagName("link"));
      source = Deger(element.getElementsByTagName("source")).equals("null") ? null : Deger(element.getElementsByTagName("source"));
      rvsSource = Deger(element.getElementsByTagName("rvsSource")).equals("null") ? null : Deger(element.getElementsByTagName("rvsSource"));
      rvsMedium = Deger(element.getElementsByTagName("rvsMedium")).equals("null") ? null : Deger(element.getElementsByTagName("rvsMedium"));
      insertDate = Deger(element.getElementsByTagName("insertDate")).equals("null") ? null : Deger(element.getElementsByTagName("insertDate"));
      qty = Deger(element.getElementsByTagName("qty")).equals("null") ? "0" : Deger(element.getElementsByTagName("qty"));
      sumAmt = Deger(element.getElementsByTagName("sumAmt")).equals("null") ? "0" : Deger(element.getElementsByTagName("sumAmt"));
      avgAmt = Deger(element.getElementsByTagName("avgAmt")).equals("null") ? "0" : Deger(element.getElementsByTagName("avgAmt"));
      avgQty = Deger(element.getElementsByTagName("avgQty")).equals("null") ? "0" : Deger(element.getElementsByTagName("avgQty"));

    }


    public String Deger(NodeList g1) {

      String deger = null;

      if (g1.getLength() > 0) {
        Element g1_Element = (Element) g1.item(0);
        NodeList text_g1 = g1_Element.getChildNodes();
        if (text_g1.item(0) != null) {
          deger = ((Node) text_g1.item(0)).getNodeValue().trim();
        }
      }

      return MysqlRealScapeString(deger);
    }

    public String MysqlRealScapeString(String str) {
      String data = "";
      if (str != null && str.length() > 0) {
        str = str.replace("\\", "\\\\");
        str = str.replace("'", "");
        str = str.replace("\0", "\\0");
        str = str.replace("\n", "\\n");
        str = str.replace("\r", "\\r");
        str = str.replace("\"", "\\\"");
        str = str.replace("\\x1a", "\\Z");
        data = str;
      }
      return data;
    }
  }
%>


<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%


  String sCustId = cust.s_cust_id;
  Service service = null;
  Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, sCustId);
  service = (Service) services.get(0);
  String rcpUrl = service.getURL().getHost();

  JsonArray salesPerformance = new JsonArray();

  JsonArray productData = new JsonArray();
  JsonArray arrayTotalData = new JsonArray();
  JsonObject data = new JsonObject();
  JsonObject totalData = new JsonObject();
  JsonArray arrayData = new JsonArray();


  Calendar calendar = Calendar.getInstance();
  calendar.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);

  int current_year;
  int current_month;
  int current_month_cal;
  int current_day;
  String last_week;


  calendar.add(Calendar.DATE, +4);
  current_year = calendar.get(Calendar.YEAR);
  current_month = calendar.get(Calendar.MONTH);
  current_month_cal = current_month + 1;
  current_day = calendar.get(Calendar.DAY_OF_MONTH);
  calendar.add(Calendar.DATE, -6);
  Date lastWeekNotFormat = calendar.getTime();
  last_week = new SimpleDateFormat("yyyy-MM-dd").format(lastWeekNotFormat);

  String today = current_year + "-" + current_month_cal + "-" + current_day;
  String firstDate = last_week;


  String date1 = (request.getParameter("firstDate") != null) ? request.getParameter("firstDate") : firstDate;
  String date2 = (request.getParameter("lastDate") != null) ? request.getParameter("lastDate") : today;
  String productFlag = request.getParameter("productFlag");

  Statement statement = null;
  ResultSet resultSet = null;
  ConnectionPool connectionPool = null;
  Connection connection = null;
  int totalQty = 0;
  int totalAmt = 0;
  int totalAvgAmt = 0;
  int totalAvgQty = 0;
  int totalAvgQtyDom = 0;

  try {

    connectionPool = ConnectionPool.getInstance();


    connection = connectionPool.getConnection(this);
    statement = connection.createStatement();


    NodeList nodeList = null;

    StringWriter sw = new StringWriter();

    sw.write("<root>");
    sw.write("<ccps_product_performance>\r\n");
    sw.write("<cust_id><![CDATA[" + sCustId + "]]></cust_id>\r\n");
    sw.write("<date1><![CDATA[" + date1 + "]]></date1>\r\n");
    sw.write("<date2><![CDATA[" + date2 + "]]></date2>\r\n");
    sw.write("<productFlag><![CDATA[" + productFlag + "]]></productFlag>\r\n");
    sw.write("</ccps_product_performance>\r\n");
    sw.write("</root>");

    String sResponse = Service.communicate(128, sCustId, sw.toString());

    DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
    Document document = builder.parse(new InputSource(new ByteArrayInputStream(sResponse.getBytes("UTF-8"))));

    nodeList = document.getElementsByTagName("rrcp_product_performance");
    if (nodeList != null) {
      int rowCount = 0;
      if (productFlag != null) {
        for (int i = 0; i < nodeList.getLength(); i++) {
          data = new JsonObject();
          XmlParse report = new XmlParse((Element) nodeList.item(i));
          rowCount++;

          String productName = report.productName;
          String insertDate = report.insertDate;
          double qty = Double.parseDouble(report.qty);
          double sumAmt = Double.parseDouble(report.sumAmt);
          double avgAmt = Double.parseDouble(report.avgAmt);
          double avgQty = Double.parseDouble(report.avgQty);

          totalQty += qty;
          totalAmt += sumAmt;
          totalAvgAmt += avgAmt;
          totalAvgQty += avgQty;

          DecimalFormat formatter = new DecimalFormat("#,###.## TL");
          String fotmatTotAmt = formatter.format(totalAmt);
          data.put("totalAmt", fotmatTotAmt);

          String formatToTavgAmt = formatter.format(avgAmt);
          
          data.put("productName", productName);
          data.put("insertDate", insertDate);
          data.put("quantity", qty);
          data.put("avgAmt", formatToTavgAmt);
          data.put("avgQuantity", avgQty);
          productData.put(data);

        }
      } else {
        for (int i = 0; i < nodeList.getLength(); i++) {
          data = new JsonObject();

          XmlParse report = new XmlParse((Element) nodeList.item(i));

          rowCount++;

          String productId = report.productId;
          String productName = report.productName;
          String link = report.link;
          String source = report.source;
          String rvsSource = report.rvsSource;
          String rvsMedium = report.rvsMedium;
          String insertDate = report.insertDate;

          double qty = Double.parseDouble(report.qty);
          double sumAmt = Double.parseDouble(report.sumAmt);
          double avgAmt = Double.parseDouble(report.avgAmt);
          double avgQty = Double.parseDouble(report.avgQty);

          totalQty += qty;
          totalAmt += sumAmt;
          totalAvgAmt += avgAmt;
          totalAvgQty += avgQty;

          DecimalFormat formatter = new DecimalFormat("#,###.## TL");
          String fotmatTotAmt = formatter.format(totalAmt);
          data.put("totalAmt", fotmatTotAmt);

          String formatToTavgAmt = formatter.format(avgAmt);

          data.put("productId", productId);
          data.put("productName", productName);
          data.put("link", link);
          data.put("source", source);
          data.put("rvsSource", rvsSource);
          data.put("rvsMedium", rvsMedium);
          data.put("insertDate", insertDate);
          data.put("quantity", qty);

          data.put("avgAmt", formatToTavgAmt);
          data.put("avgQuantity", avgQty);


          productData.put(data);


        }
      }
      if (rowCount != 0) {
        if (totalAvgAmt != 0) {
          totalAvgAmt = totalAvgAmt / rowCount;
        }

        totalData.put("totalAvgAmt", totalAvgAmt);

        if (totalAvgQty != 0) {
          totalAvgQtyDom = totalAvgQty / rowCount;
        }

        totalData.put("totalAvgQtyDom", totalAvgQtyDom);
      }
      totalData.put("totalQty", totalQty);
      totalData.put("totalAmt", totalAmt);
      totalData.put("totalAvgAmt", totalAvgAmt);
      //  totalData.put("totalAvgQty",totalAvgQty);

      arrayTotalData.put(totalData);
      productData.put(data);

    }
    arrayData.put(arrayTotalData);
    arrayData.put(productData);

    statement.close();

    out.print(arrayData.toString());


  } catch (Exception ex) {

    System.out.println("prodduct_performance error for cust:" + sCustId + ex);
  } finally {
    try {
      if (statement != null) statement.close();
      if (connection != null) connectionPool.free(connection);
    } catch (SQLException e) {
      logger.error("Could not clean db statement or connection", e);
    }
  }


%>

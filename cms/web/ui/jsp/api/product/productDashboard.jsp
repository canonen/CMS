<%@ page
        language="java"
        import="com.britemoon.cps.rpt.*,
                com.britemoon.cps.tgt.*,
                com.britemoon.cps.que.*,
                com.britemoon.cps.cnt.*,
                com.britemoon.cps.*,
                com.britemoon.*,
                java.sql.*,
                java.io.*,
                org.apache.log4j.Logger,
                org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.Statement" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.URL" %>
<%@ page import="com.britemoon.cps.imc.Service" %>
<%@ page import="com.britemoon.cps.imc.Services" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%
   // boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

    class AttributeModel {
        int attr_id;
        String attr_name;
        String attr_tag_name;
        int type_id;
        int cust_id;
        int is_list;

        public int getAttr_id() {
            return attr_id;
        }

        public void setAttr_id(int attr_id) {
            this.attr_id = attr_id;
        }

        public String getAttr_name() {
            return attr_name;
        }

        public void setAttr_name(String attr_name) {
            this.attr_name = attr_name;
        }

        public String getAttr_tag_name() {
            return attr_tag_name;
        }

        public void setAttr_tag_name(String attr_tag_name) {
            this.attr_tag_name = attr_tag_name;
        }

        public int getType_id() {
            return type_id;
        }

        public void setType_id(int type_id) {
            this.type_id = type_id;
        }

        public int getCust_id() {
            return cust_id;
        }

        public void setCust_id(int cust_id) {
            this.cust_id = cust_id;
        }

        public int getIs_list() {
            return is_list;
        }

        public void setIs_list(int is_list) {
            this.is_list = is_list;
        }
    }
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%

    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }


    JsonObject data = new JsonObject();
    JsonArray arrayData = new JsonArray();

    String sCustId = cust.s_cust_id;


    Service service = null;
    Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, sCustId);
    service = (Service) services.get(0);


    String refresh_url = "http://" + service.getURL().getHost() + "/rrcp/imc/xml/AttributeXMLParse.jsp?cust_id=" + sCustId;
    String refresh_search_url = "http://" + service.getURL().getHost() + "/rrcp/imc/perssearch/index.jsp?cust_id=" + sCustId;
    Statement stmt = null;
    ResultSet rs = null;
    ConnectionPool cp = null;
    Connection conn = null;
    List<AttributeModel> attributeModelList = new ArrayList<AttributeModel>();
    String sslCheck = "";
    int i = 0;
    boolean isNotEmpty = true;

    try {
        System.out.println("ProductDashBoard is loading...");
        cp = ConnectionPool.getInstance();

        if (cp == null) {
            out.println("Cust ID Bulunmamadi");
        }

        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        String isExist = ("SELECT attr_id,attr_name,attr_tag_name FROM ccps_product_attribute where cust_id = " + sCustId + " order by attr_id");


        rs = stmt.executeQuery(isExist);
        while (rs.next()) {
            data = new JsonObject();
            AttributeModel attr = new AttributeModel();
            attr.setAttr_id(rs.getInt(1));
            attr.setAttr_name(rs.getString(2));
            attr.setAttr_tag_name(rs.getString(3));


            data.put("attributeId", rs.getInt(1));

            data.put(rs.getString(2), rs.getString(3));


            arrayData.put(data);
            attributeModelList.add(attr);


        }
        rs.close();

        isNotEmpty = attributeModelList.size() > 0;

        sslCheck = isNotEmpty ? attributeModelList.get(35).getAttr_tag_name() : "";

        out.print(arrayData.toString());

    } catch (Exception e) {
        out.println("hata var" + e);
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) cp.free(conn);

    }

%>

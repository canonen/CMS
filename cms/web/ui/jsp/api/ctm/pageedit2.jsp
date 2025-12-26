<%@ page
        import="com.britemoon.*"
        import="com.britemoon.cps.*"
        import="com.britemoon.cps.ctm.*"
        import="org.apache.log4j.*"
        import="java.sql.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.util.logging.Logger" %>
<%! static Logger logger = null; %>
<% if (logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "http://dev.revotas.com:3002");
    response.setHeader("Access-Control-Allow-Credentials", "true");
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../validator.jsp" %>
<%

        PageBean pbean = (PageBean) session.getAttribute("pbean");

        int custID = Integer.parseInt(cust.s_cust_id);
        JsonObject jsonObject = new JsonObject();
        JsonArray jsonArray = new JsonArray();
        ConnectionPool connPool = null;
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        String status = null;
        try {
            connPool = ConnectionPool.getInstance();
            conn = connPool.getConnection(this);
            stmt = conn.createStatement();

            rs = stmt.executeQuery(
                    "SELECT status" +
                            " FROM ctm_pages p" +
                            " WHERE p.template_id = " + (pbean.getTemplateBean()).getTemplateID() +
                            " AND p.content_id = " + pbean.getContentID() +
                            " AND p.customer_id = " + custID);

            if (rs.next()) {
                status = rs.getString(1);
                jsonObject.put("status", status);
            }
            rs.close();
        } catch (SQLException e) {
            throw e;
        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) connPool.free(conn);
        }

        boolean isEdit = (Boolean.valueOf(request.getParameter("isEdit")).booleanValue() && (!"locked".equals(status)));
        jsonObject.put("isEdit", isEdit);
        String imageURL = application.getInitParameter("ImageURL");
        String previewType = request.getParameter("previewType");
        if (previewType.equals("txt")) {
			pbean = WebUtils.removeHTMLtags2(pbean.createTemplateForm(previewType, "sectionedit.jsp", imageURL, isEdit));
			jsonObject.put("pbean", pbean);
        } else {
			pbean = pbean.createTemplateForm(previewType, "sectionedit.jsp", imageURL, isEdit);
			jsonObject.put("pbean", pbean);
        }
       jsonArray.put(jsonObject);
	   out.println(jsonArray);
%>
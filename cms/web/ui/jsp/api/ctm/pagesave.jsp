<%@ page
        language="java"
        import="com.britemoon.*"
        import="com.britemoon.cps.*"
        import="com.britemoon.cps.ctm.*"
        import="org.apache.log4j.*"
        import="java.sql.*"
        import="java.util.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.util.logging.Logger" %>
<%! static Logger logger = null; %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../validator.jsp" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "http://dev.revotas.com:3002");
    response.setHeader("Access-Control-Allow-Credentials", "true");
%>
<%
    JsonObject jsonObject = new JsonObject();
    JsonArray jsonArray = new JsonArray();
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
    PageBean pbean = (PageBean) session.getAttribute("pbean");

    int custID = Integer.parseInt(cust.s_cust_id);
    int userID = Integer.parseInt(user.s_user_id);

    String returnURL = request.getParameter("returnURL");
    if (returnURL == null) {
        returnURL = "pageedit.jsp?templateID=" + pbean.getTemplateBean().getTemplateID();
    }

    String pageName = request.getParameter("pageName");
    String sendType = request.getParameter("sendType");
    String rename = request.getParameter("rename");

    if ((pbean.getPageName().length() != 0 || (pageName != null && pageName.length() != 0)) && rename == null) {
        if (pageName != null && pageName.length() != 0) {
            pbean.setPageNameAndType(pageName, Integer.parseInt(sendType));
        }
        pbean.save(userID, (String) session.getAttribute("userName"), -1);
        String oldContentID = request.getParameter("oldContentID");
        if (oldContentID != null) {
            WebUtils.copyImages(application.getInitParameter("ImagePath") + pbean.getCustID() + "\\", Integer.parseInt(oldContentID), pbean.getContentID());
        }

        response.sendRedirect(returnURL);
        return;
    }

    String nameValue = "";
    if (rename != null) {
        nameValue = WebUtils.htmlEncode(pbean.getPageName());
    }

    String oldContentID = request.getParameter("oldContentID");

    ConnectionPool connPool = null;
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    connPool = ConnectionPool.getInstance();
    conn = connPool.getConnection("pagesave.jsp");
    stmt = conn.createStatement();


    rs = stmt.executeQuery("SELECT send_type_id, send_type_name FROM ctm_send_type");

    String sendTypeSelectBox = "";
    String isSelected = "";
    int curID;
    while (rs.next()) {
        curID = rs.getInt(1);
        if (curID == pbean.getSendType()) {
            isSelected = " selected";
        }
        else isSelected = "";
        sendTypeSelectBox += "<option value=\"" + curID + "\"" + isSelected + ">" + rs.getString(2) + "</option>\n";
        jsonObject.put("sendTypeSelectBox",sendTypeSelectBox);
        jsonArray.put(jsonArray);

    }
    out.println(jsonArray);
    rs.close();
    stmt.close();
    if (conn != null) {
        connPool.free(conn);
    }

%>


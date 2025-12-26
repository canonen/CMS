<%@ page
        language="java"
        import="com.britemoon.*,
                com.britemoon.cps.rpt.*,
                com.britemoon.cps.tgt.*,
                com.britemoon.cps.que.*,
                com.britemoon.cps.cnt.*,
                com.britemoon.cps.*,
                com.britemoon.rcp.*,
                java.sql.*,
                java.io.*,
                java.util.*,
                com.britemoon.rcp.*,
                com.britemoon.rcp.que.*,
                java.util.Calendar,
                java.math.BigDecimal,
                org.apache.log4j.Logger,
                javax.mail.*,
                org.w3c.dom.*"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="net.sourceforge.jtds.jdbc.DateTime" %>
<%@ page import="java.sql.Date" %>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>


<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
    AccessPermission can = user.getAccessPermission(ObjectType.CATEGORY);
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);


        if(!can.bRead)
        {
            response.sendRedirect("../../access_denied.jsp");
            return;
        }

        boolean bCanDefault = ((user.s_cust_id).equals(cust.s_cust_id) && can.bExecute);

%>

<%
    String sCustId = cust.s_cust_id;
    Campaign camp = new Campaign();
    camp.s_cust_id = sCustId;


    ConnectionPool connectionPool = null;
    Connection connection = null;
    Statement statement = null;
    ResultSet resultSet = null;
    String sSql = "";




    String campId = null;
    String campName = null;




    try {
        connectionPool = ConnectionPool.getInstance();
        connection = connectionPool.getConnection(this);
        statement = connection.createStatement();


        sSql = " select * from  cque_campaign  where  cust_id=" + sCustId + "and  type_id=4 and status_id=60";
        resultSet = statement.executeQuery(sSql);

        JsonArray arrayData = new JsonArray();
        while (resultSet.next()) {
            JsonObject jsonObject = new JsonObject();
            campId = resultSet.getString(1);
            campName = resultSet.getString(4);

            jsonObject.put("campName",campName);
            jsonObject.put("campId",campId);

            arrayData.put(jsonObject);
        }
        /*
        JsonObject newObj = new JsonObject();
        JsonArray newA = new JsonArray();

        newObj.put(arrayData);
        newA.put("campaign",newObj);
*/
        resultSet.close();
        out.println(arrayData);
    } catch (Exception exception) {
        System.out.println(exception.getMessage());
        exception.printStackTrace();
    }



%>
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

<%@ include file="../../validator.jsp" %>
<%@ include file="../../header.jsp" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
%>

<%
        boolean bSTANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
        AccessPermission can = user.getAccessPermission(ObjectType.FORM);
		ConnectionPool connectionPool = null;
		Connection connection = null;
		Statement statement = null;
		ResultSet resultSet = null;
		String sSql = "";
		JsonObject jsonObject = new JsonObject();

		JsonArray arrayData = new JsonArray();

		try {
			connectionPool = ConnectionPool.getInstance();
			connection = connectionPool.getConnection(this);
			statement = connection.createStatement();

            sSql = " SELECT form_id, form_name FROM csbs_form WHERE cust_id ="+cust.s_cust_id+"  AND type_id = 3 ORDER BY form_id";


			resultSet = statement.executeQuery(sSql);
			while (resultSet.next()){

				jsonObject = new JsonObject();


                jsonObject.put("formId",resultSet.getInt(1));
                jsonObject.put("formName", resultSet.getString(2));

				arrayData.put(jsonObject);


			}
			resultSet.close();
			out.print(arrayData.toString());



		}catch (Exception exception){
			System.out.println(exception.getMessage());
			exception.printStackTrace();
		}
        finally {
            if (resultSet != null) {
                try {
                    resultSet.close();
                } catch (Exception exception) {
                }
            }
        }

%>


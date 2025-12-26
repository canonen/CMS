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
        AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);
		ConnectionPool connectionPool = null;
		Connection connection = null;
		Statement statement = null;
		ResultSet resultSet = null;
		String sSql = "";
		JsonObject jsonObject = new JsonObject();

		JsonArray arrayData = new JsonArray();

        Integer contentId = null;
        String contentName = null;
        Integer typeId = null;
        String displayName = null;
        String lastUpdate = null;
        Integer statusId = null;
        String status = null;
        String editor = null;
        String modifyDate = null;

        String category = request.getParameter("category_id");

		try {
			connectionPool = ConnectionPool.getInstance();
			connection = connectionPool.getConnection(this);
			statement = connection.createStatement();
            if(category != null){
                sSql = "Exec dbo.usp_ccnt_list_get @type_id=30, @CustomerId="+cust.s_cust_id+" , @category_id="+category;
            }else{
                sSql = "Exec dbo.usp_ccnt_list_get @type_id=30, @CustomerId="+cust.s_cust_id;
            }

			resultSet = statement.executeQuery(sSql);
			while (resultSet.next()){

				jsonObject = new JsonObject();

                contentId = resultSet.getInt(1);
                contentName = resultSet.getString(2);
                typeId = resultSet.getInt(4);
                displayName = resultSet.getString(5);
                lastUpdate = resultSet.getString(6);
                statusId = resultSet.getInt(7);
                status = resultSet.getString(8);
                editor = resultSet.getString(9);
                modifyDate = resultSet.getString(10);


                jsonObject.put("contentId",contentId);
                jsonObject.put("contentName", contentName);
                jsonObject.put("typeId",typeId);
                jsonObject.put("displayName",displayName);
                jsonObject.put("lastUpdate",lastUpdate);
                jsonObject.put("statusId",statusId);
                jsonObject.put("status",status);
                jsonObject.put("editor",editor);
                jsonObject.put("modifyDate",modifyDate);


				arrayData.put(jsonObject);


			}
			resultSet.close();
			out.print(arrayData.toString());



		}catch (Exception exception){
			System.out.println(exception.getMessage());
			exception.printStackTrace();
		}
        finally {
            if(resultSet != null) {
                try { resultSet.close(); } catch (Exception e) {
                    logger.error(e.getMessage(), e);
                }
            }
        }

%>


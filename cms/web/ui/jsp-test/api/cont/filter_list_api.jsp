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

<%@ include file="../../utilities/validator.jsp" %>
<%@ include file="../header.jsp" %>
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

        Integer filterId = null;
        String filterName = null;
        String modifyDate = null;
        Integer statusId = null;
        String status = null;

        String category = request.getParameter("category_id");


		try {
			connectionPool = ConnectionPool.getInstance();
			connection = connectionPool.getConnection(this);
			statement = connection.createStatement();
            if(category != null){
                sSql = "EXEC usp_ctgt_filter_list_get_logic  @start_record=1, @page_size=1, @orderby=date,@cust_id="+cust.s_cust_id+" , @category_id="+category;
            }else{
                sSql = "EXEC usp_ctgt_filter_list_get_logic  @category_id=0, @start_record=1, @page_size=1, @orderby=date,@cust_id="+cust.s_cust_id;
            }

			resultSet = statement.executeQuery(sSql);
			while (resultSet.next()){

				jsonObject = new JsonObject();

                filterId = resultSet.getInt(1);
                filterName = resultSet.getString(2);
                modifyDate = resultSet.getString(3);
                statusId = resultSet.getInt(4);
                status = resultSet.getString(5);



                jsonObject.put("filterId",filterId);
                jsonObject.put("filterName", filterName);
                jsonObject.put("modifyDate",modifyDate);
                jsonObject.put("statusId",statusId);
                jsonObject.put("status",status);
                jsonObject.put("isLink",true);


				arrayData.put(jsonObject);


			}
			resultSet.close();
			out.print(arrayData.toString());



		}catch (Exception exception){
			System.out.println(exception.getMessage());
			exception.printStackTrace();
		}

%>


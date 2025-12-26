
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

<%@ include file="../validator.jsp" %>
<%@ include file="../header.jsp" %>
<%! static Logger logger = null;%>
<%
    if (logger == null) {
        logger = Logger.getLogger(this.getClass().getName());
    }
%>

<%
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

		ConnectionPool connectionPool = null;
		Connection connection = null;
		Statement statement = null;
		ResultSet resultSet = null;
		String sSql = "";
		JsonObject jsonObject = new JsonObject();
		JsonArray arrayData = new JsonArray();

		String   camp_id = request.getParameter("campId");
		String   cache_id = request.getParameter("cacheId");
		String   sCache = request.getParameter("sCache");


		Integer campId = null;
        Integer id = null;
        String  linkName = null;
        Integer totalClick = null;
        Integer totalText = null;
        Integer totalHtml = null;
        Integer totalAol = null;
        Integer distinctClicks = null;
        Integer distinctText = null;
        Integer distinctHTML = null;
        Integer distinctAOL = null;
        Integer multiClickers = null;
        Double totalClickPrc = null;
        Double totalTextPrc = null;
        Double totalHtmlPrc = null;
        Double distinctClickPrc = null;
        Double distinctHtmlPrc = null;


		try {
			connectionPool = ConnectionPool.getInstance();
			connection = connectionPool.getConnection(this);
			statement = connection.createStatement();

			sSql = "Exec usp_crpt_camp_links @camp_id="+camp_id+", @cache_id="+cache_id+", @cache="+sCache+"";
			resultSet = statement.executeQuery(sSql);
			while (resultSet.next()){

				jsonObject = new JsonObject();

				campId = resultSet.getInt(1);
                id = resultSet.getInt(2);
                //linkName = resultSet.getString(3);
                byte[] bytesLinkName = resultSet.getBytes(3);
                linkName = new String(bytesLinkName,"UTF-8");
                totalClick = resultSet.getInt(4);
                totalText = resultSet.getInt(5);
                totalHtml = resultSet.getInt(6);
                totalAol = resultSet.getInt(7);
                distinctClicks = resultSet.getInt(8);
                distinctText = resultSet.getInt(9);
                distinctHTML = resultSet.getInt(10);
                distinctAOL = resultSet.getInt(11);
                multiClickers = resultSet.getInt(12);
                totalClickPrc = resultSet.getDouble(13);
                distinctClickPrc = resultSet.getDouble(14);
                totalHtmlPrc = resultSet.getDouble(15);
                distinctClickPrc = resultSet.getDouble(17);
                distinctHtmlPrc = resultSet.getDouble(19);

				jsonObject.put("campId",campId);
                jsonObject.put("id",id);
                jsonObject.put("linkName",linkName);
                jsonObject.put("totalClick",totalClick);
                jsonObject.put("totalText",totalText);
                jsonObject.put("totalHtml",totalHtml);
                jsonObject.put("totalAol",totalAol);
                jsonObject.put("distinctClicks",distinctClicks);
                jsonObject.put("distinctText",distinctText);
                jsonObject.put("distinctHTML",distinctHTML);
                jsonObject.put("distinctAOL",distinctAOL);
                jsonObject.put("multiClickers",multiClickers);
                jsonObject.put("totalClickPrc",totalClickPrc);
                jsonObject.put("totalTextPrc",totalTextPrc);
                jsonObject.put("totalHtmlPrc",totalHtmlPrc);
                jsonObject.put("distinctClickPrc",distinctClickPrc+"%");
                jsonObject.put("distinctHtmlPrc",distinctHtmlPrc);
				arrayData.put(jsonObject);


			}
			resultSet.close();
			out.print(arrayData.toString());



		}catch (Exception exception){
			System.out.println(exception.getMessage());
			exception.printStackTrace();
		}
        finally {
            if(resultSet != null){
                try {
                    resultSet.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }

%>


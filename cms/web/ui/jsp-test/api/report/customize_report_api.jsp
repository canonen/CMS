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
		ConnectionPool connectionPool = null;
		Connection connection = null;
		Statement statement = null;
		ResultSet resultSet = null;
		String sSql = "";
		JsonObject jsonObject = new JsonObject();
        AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);
		JsonArray arrayData = new JsonArray();

        Integer header = null;
        Integer generalCampStatus = null;
        Integer bBack = null;
        Integer recipAction = null;
        Integer detailedDistinct = null;
        Integer detailedAggerate = null;
        Integer formSubmissions = null;
        Integer totalHtmlEmail = null;
        Integer openedHtmlEmail = null;
        Integer aggerateClick = null;
        Integer clickedMoreOneLink = null;
        Integer clickedLinkMultipleTime = null;
        Integer domainDelivery = null;
        Integer newsletterOpt = null;



		try {
			connectionPool = ConnectionPool.getInstance();
			connection = connectionPool.getConnection(this);
			statement = connection.createStatement();

			sSql = "EXEC usp_crpt_report_settings_get @cust_id = "+cust.s_cust_id;
			resultSet = statement.executeQuery(sSql);
			while (resultSet.next()){

				jsonObject = new JsonObject();

                header = resultSet.getInt(1);
                generalCampStatus = resultSet.getInt(2);
                bBack = resultSet.getInt(3);
                recipAction = resultSet.getInt(4);
                detailedDistinct = resultSet.getInt(5);
                detailedAggerate = resultSet.getInt(6);
                formSubmissions = resultSet.getInt(7);
                totalHtmlEmail = resultSet.getInt(8);
                openedHtmlEmail = resultSet.getInt(9);
                aggerateClick = resultSet.getInt(10);
                clickedMoreOneLink = resultSet.getInt(11);
                clickedLinkMultipleTime = resultSet.getInt(12);
                domainDelivery = resultSet.getInt(13);
                newsletterOpt = resultSet.getInt(14);

                if (header == 1)  jsonObject.put("header",true);
                else jsonObject.put("header",false);
                if (generalCampStatus == 1)  jsonObject.put("generalCampStatus",true);
                else jsonObject.put("generalCampStatus",false);
                if (bBack == 1)  jsonObject.put("bBack",true);
                else jsonObject.put("bBack",false);
                if (recipAction == 1)  jsonObject.put("recipAction",true);
                else jsonObject.put("recipAction",false);
                if (detailedDistinct == 1)  jsonObject.put("detailedDistinct",true);
                else jsonObject.put("detailedDistinct",false);
                if (detailedAggerate == 1)  jsonObject.put("detailedAggerate",true);
                else jsonObject.put("detailedAggerate",false);
                if (formSubmissions == 1)  jsonObject.put("formSubmissions",true);
                else jsonObject.put("formSubmissions",false);
                if (totalHtmlEmail == 1)  jsonObject.put("totalHtmlEmail",true);
                else jsonObject.put("totalHtmlEmail",false);
                if (openedHtmlEmail == 1)  jsonObject.put("openedHtmlEmail",true);
                else jsonObject.put("openedHtmlEmail",false);
                if (aggerateClick == 1)  jsonObject.put("aggerateClick",true);
                else jsonObject.put("aggerateClick",false);
                if (clickedMoreOneLink == 1)  jsonObject.put("clickedMoreOneLink",true);
                else jsonObject.put("clickedMoreOneLink",false);
                if (clickedLinkMultipleTime == 1)  jsonObject.put("clickedLinkMultipleTime",true);
                else jsonObject.put("clickedLinkMultipleTime",false);
                if (domainDelivery == 1)  jsonObject.put("domainDelivery",true);
                else jsonObject.put("domainDelivery",false);
                if (newsletterOpt == 1)  jsonObject.put("newsletterOpt",true);
                else jsonObject.put("newsletterOpt",false);


				arrayData.put(jsonObject);


			}
			resultSet.close();
			out.print(arrayData.toString());



		}catch (Exception exception){
			System.out.println(exception.getMessage());
			exception.printStackTrace();
		}

%>

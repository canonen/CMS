<%@ page
		language="java"
		import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.que.*,
			java.sql.*,
			java.io.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*"
		contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.util.Vector" %>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
%>
<%@ include file="../header.jsp"%>
<%@ include file="../../utilities/validator.jsp"%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%
    String sCustId= cust.s_cust_id;
    Service service = null;
    Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, sCustId);
    service = (Service) services.get(0);
    String rcpLink = service.getURL().getHost();
    Campaign camp = new Campaign();
	camp.s_cust_id = sCustId;
    String firstDate = request.getParameter("firstDate");
    String lastDate = request.getParameter("lastDate");
    Statement		stmt= null;
	ResultSet		rs= null;
	ConnectionPool	cp= null;
	Connection		conn= null;

    JsonObject object = new JsonObject();
    JsonArray array = new JsonArray();

    try{
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        String sSql_day = "";
        sSql_day = "select top 6 CONVERT(VARCHAR(10), activity_date, 120) DAY, count(6), popup_id, form_id, type_name, activity, impression, revenue, popup_name from ccps_smart_widget_activity_day with(nolock) WHERE "+"cust_id="+sCustId+" AND activity_date >='"+firstDate+"' AND activity_date<='"+lastDate+"' GROUP BY CONVERT(VARCHAR(10), activity_date, 120), popup_id, form_id, type_name, activity, impression, revenue, popup_name ORDER BY 1";
        rs = stmt.executeQuery(sSql_day);

        while (rs.next())
        {
            object = new JsonObject();
            String click = rs.getString(6);
            String view = rs.getString(7);
            String revenue = rs.getString(8);
            String popup_name = rs.getString(9);
            object.put("popupName",popup_name);
            object.put("click",click);
            object.put("view",view);
            object.put("revenue",revenue);

            array.put(object);
        }
        rs.close();
        out.print(array);
    }catch (Exception exception){
    	exception.printStackTrace();
    }
%>

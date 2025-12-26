<%@ page
		language="java"
		import="com.britemoon.*,
			com.britemoon.cps.*,
            com.britemoon.cps.imc.*,
			java.sql.*,java.net.*,
			java.io.*,java.util.*,
			java.text.DateFormat,org.apache.log4j.*"
		errorPage="../error_page.jsp"
		contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ include file="../../utilities/validator.jsp"%>
<%@ include file="../header.jsp" %>
<%
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
	ConnectionPool cp = null;
	Connection conn = null;
	Statement stmt =null;



		 String custId = cust.s_cust_id;
		 JsonObject data = new JsonObject();


            cp = null;
            conn = null;
            stmt =null;

            try
            {
                cp = ConnectionPool.getInstance();
                conn = cp.getConnection(this);

                stmt = conn.createStatement();

                String sSql = "SELECT web_page, register_page, cart_page, order_page FROM c_smart_widget_settings WHERE cust_id =" + cust.s_cust_id;

                ResultSet rs = stmt.executeQuery(sSql);
                if (rs.next())
                {
	String web_page = rs.getString(1);
	String register_page =rs.getString(2);
	String cart_page = rs.getString(3);
	String order_page = rs.getString(4);

	data.put("webPage",web_page);
	data.put("register_page",register_page);
	data.put("cart_page",cart_page);
	data.put("order_page",order_page);
	
	}
    rs.close();

				
}
catch(Exception ex)
{
    throw ex;
}
finally
{
    if (stmt!=null) stmt.close();
    if (conn!=null) cp.free(conn);
}
out.print(data.toString());
%>

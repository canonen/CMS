<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>

<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.USER);

if(!can.bRead)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}
%>

			<%
				JsonArray arrayData= new JsonArray();
				JsonObject data =new JsonObject();
			ConnectionPool cp = null;
			Connection conn = null;
			Statement	stmt = null;
			ResultSet	rs = null; 
			String sSQL = null;

			try {
				cp = ConnectionPool.getInstance();
				conn = cp.getConnection(this);
				stmt = conn.createStatement();

				sSQL =
						" SELECT user_id, user_name + ' ' + ISNull(last_name,''), phone, email" +
								" FROM ccps_user" +
								" WHERE cust_id=" + cust.s_cust_id +
								" AND status_id!=" + UserStatus.DELETED +
								" ORDER BY user_name";

				rs = stmt.executeQuery(sSQL);
				String sUserId = null;
				String sUserName = null;
				String sPhone = null;
				String sEmail = null;

				String sClassAppend = "";
				int i = 0;

				while (rs.next()) {
					if (i % 2 != 0) {
						sClassAppend = "_other";
					} else {
						sClassAppend = "";
					}

					i++;

					data=new JsonObject();

					sUserId = rs.getString(1);
					sUserName = new String(rs.getBytes(2), "UTF-8");
					sPhone = new String(rs.getBytes(3), "UTF-8");
					sEmail = new String(rs.getBytes(4), "UTF-8");

					data.put("sUserId",sUserId);
					data.put("sUserName",sUserName);
					data.put("sPhone",sPhone);
					data.put("sEmail",sEmail);

					arrayData.put(data);

				}
				rs.close();
				out.println(arrayData);
			}


			catch(Exception ex)
			{
				ex.printStackTrace(new PrintWriter(out));
			}
			finally
			{
				if(conn!=null) cp.free(conn);
			}

			%>
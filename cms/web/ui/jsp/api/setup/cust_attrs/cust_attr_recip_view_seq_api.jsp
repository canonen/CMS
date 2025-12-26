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
<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp"%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.RECIPIENT_ATTRIBUTE);

if(!can.bWrite)
{
	response.sendRedirect("../../access_denied.jsp");
	return;
}
%>


<%
String sSql =
	" SELECT ca.attr_id, ca.display_name, dt.type_name" +
	" FROM ccps_attribute a, ccps_cust_attr ca, ccps_data_type dt" +
	" WHERE" +
	" ca.cust_id=? AND" +
	" a.attr_id = ca.attr_id AND" +
	" a.type_id = dt.type_id AND" +
	" ISNULL(ca.display_seq, 0) > 0 AND" +
	" ISNULL(ca.recip_view_seq, 0) > 0 AND" +
	" ISNULL(a.internal_flag,0) <= 0" +
	" ORDER BY ca.recip_view_seq, ca.display_name";

ConnectionPool cp = null;
Connection conn = null;
JsonArray array=new JsonArray();
try
{
	cp = ConnectionPool.getInstance();			
	conn = cp.getConnection(this);
	
	PreparedStatement pstmt = null;
	try
	{
		pstmt = conn.prepareStatement(sSql);
		pstmt.setString(1, cust.s_cust_id);
		ResultSet rs = pstmt.executeQuery();

		String sAttrId = null;
		String sDisplayName = null;
		String sTypeName = null;

		while (rs.next())
		{
			JsonObject data=new JsonObject();
			sAttrId = rs.getString(1);
			data.put("sAttrId",sAttrId);
			sDisplayName = new String(rs.getBytes(2), "UTF-8");
			data.put("sDisplayName",sDisplayName);
			sTypeName = rs.getString(3);
			data.put("sTypeName",sTypeName);
			array.put(data);
		}
		out.print(array);
		rs.close();
	}
	catch(Exception ex)	{ throw ex;	}
	finally { if(pstmt != null) pstmt.close(); }
}
catch(Exception ex) { throw ex; }
finally { if(conn != null) cp.free(conn); }
%>
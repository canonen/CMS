<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.net.*,java.sql.*,
			java.util.*,java.io.*,
			org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../../header.jsp"%>
<%@ include file="../../validator.jsp"%>
<%@ include file="../../fixTurkishCharacters.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	JsonArray jsonArray = new JsonArray();
	String scurPage = request.getParameter("curPage");

	int	curPage	= 1;
	int contCount = 0;

	curPage	= (scurPage	== null) ? 1 : Integer.parseInt(scurPage);

	String samount = request.getParameter("amount");
	int amount = 0;
	
	if (samount == null) samount = ui.getSessionProperty("unsub_msgs_list_page_size");
	if ((samount == null)||("".equals(samount))) samount = "25";
	try { amount = Integer.parseInt(samount); }
	catch (Exception ex) { samount = "25"; amount = 25; }
	ui.setSessionProperty("unsub_msgs_list_page_size", samount);
	
	String htmlContentRow = "";
	String htmlContent = "";
	
	ConnectionPool cp	= null;
	Connection 	conn	= null;
	Statement 	stmt	= null;			
	ResultSet 	rs		= null;
	
	try
	{

		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("unsub_msg_list");
		stmt = conn.createStatement();		
		
		String sSql =
			"SELECT u.msg_id, u.msg_name " +
			" FROM ccps_unsub_msg u" +
			" WHERE cust_id=" + cust.s_cust_id +
			" ORDER BY msg_id desc";
			
		rs = stmt.executeQuery(sSql);
		
		String sMsgId = null;
		String sMsgName = null;
		int iCount = 0;
		String sClassAppend = "";
		byte[] b = null;
		while(rs.next())
		{
			if (iCount % 2 != 0) sClassAppend = "_Alt";
			else sClassAppend = "";
		
			++iCount;
		
			sMsgId = rs.getString(1);
			b = rs.getBytes(2);
			sMsgName = (b==null)?null:new String(b, "UTF-8");

			JsonObject jsonObject = new JsonObject();
			jsonObject.put("msg_id", sMsgId);
			jsonObject.put("msg_name", fixTurkishCharacters(sMsgName));
			jsonObject.put("sClassAppend", sClassAppend);
			jsonArray.put(jsonObject);
						
//			htmlContentRow += "<tr><td class=\"listItem_Title" + sClassAppend + "\"><a href=\"unsub_msg_edit_api.jsp?msg_id=" + sMsgId + "\">" + sMsgName + "</a>&nbsp;</td></tr>";
//			htmlContent += htmlContentRow;
//			htmlContentRow = "";
		}
		rs.close();

		out.println(jsonArray);
//		if (iCount == 0)
//		{
//			htmlContent += "<tr><td colspan=\"5\" class=\"listItem_Data\">There are currently no Unsubscribe Messages</td></tr>\n";
//		}
	}
	catch(Exception ex) { throw ex; }
	finally
	{
		try
		{
			if (stmt!=null) stmt.close();
		}
		catch (SQLException ignore) {}		
		if (conn!=null) cp.free(conn);
	}
%>
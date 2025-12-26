<%@ page
		language="java"
		import="com.britemoon.*"
		import="com.britemoon.sas.*"
		import="java.io.*"
		import="java.sql.*"
		import="java.util.*"
		import="org.apache.log4j.*"
		contentType="text/html;charset=UTF-8"
%>
<%@include file="../header.jsp" %>
<%@include file="../validator.jsp" %>

<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%
/*	String		scurPage	= request.getParameter("curPage");
	String		samount		= request.getParameter("amount");*/
	String sCustId = cust.s_cust_id;


	int			curPage			= 1;
	int			amount			= 0;

	curPage		= (scurPage		== null) ? 1 : Integer.parseInt(scurPage);

	if ((samount == null)||("".equals(samount))) samount = "25";
	try { amount = Integer.parseInt(samount); }
	catch (Exception ex) { samount = "25"; amount = 25; }

	ConnectionPool cp = null;
	Connection conn = null;
	Statement	stmt = null;
	ResultSet	rs = null;
	String sSQL = null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("support_list_test.jsp");
		stmt = conn.createStatement();

		sSQL = " SELECT s.ticket_id, \n" +
				"\ts.cust_id, \n" +
				"\tc.cust_name, \n" +
				"\ts.user_id, \n" +
				"\tu.user_name + ' ' + u.last_name as 'user_name', \n" +
				"\ts.status_id, \n" +
				"\tst.display_name, \n" +
				"\ts.level_id, \n" +
				"\ts.source_id, \n" +
				"\ts.subject, \n" +
				"\ts.original_issue, \n" +
				"\ts.further_info, \n" +
				"\ts.support_diary, \n" +
				"\ts.issue_type, \n" +
				"\ts.resolution_time, \n" +
				"\ts.resolution_what, \n" +
				"\ts.resolution_solve, \n" +
				"\ts.resolution_prevent, \n" +
				"\ts.create_date, \n" +
				"\tCONVERT(varchar(100), s.create_date, 100) as 'create_date_txt', \n" +
				"\ts.modify_date, \n" +
				"\tCONVERT(varchar(100), s.modify_date, 100) as 'modify_date_txt'\n" +
				"FROM shlp_support_ticket s with(nolock)\n" +
				"LEFT OUTER JOIN sadm_customer c ON s.cust_id = c.cust_id\n" +
				"LEFT OUTER JOIN scps_user u ON s.user_id = u.user_id\n" +
				"LEFT OUTER JOIN shlp_support_status st ON s.status_id = st.status_id\n" +
				"WHERE s.cust_id=" +sCustId;

		rs = stmt.executeQuery(sSQL);

		String sTicketId = null;
		String sCustName = null;
		String sUserId = null;
		String sUserName = null;
		String sStatusId =null;
		String sDisplayName = null;
		String sLevelId = null;
		String sSourceId=null;
		String sSubject = null;
		String sOriginalIsue = null;
		String sFurtherInfo = null;
		String sSupportDiary = null;
		String sIsueType = null;
		String sResolutionTime = null;
		String sResolutionWhat = null;
		String sResolutionSolve = null;
		String sResolutionPrevent = null;
		String sCreateDate = null;
		String sModifyDate = null;

		while(rs.next())
		{
			JsonObject json = new JsonObject();
			JsonArray arr = new JsonArray();

			sTicketId = rs.getString(1);
			sCustId = rs.getString(2);
			sCustName = new String(rs.getBytes(3),"UTF-8");
			sUserId = (rs.getString(4) != null) ? rs.getString(4) : "null";
			sUserName = (rs.getBytes(5) != null) ? new String(rs.getBytes(5), "UTF-8") : "null";
			sStatusId = (rs.getString(6) != null) ? rs.getString(6) : "null";
			sDisplayName = (rs.getBytes(7) != null) ? new String(rs.getBytes(7), "UTF-8") : "null";
			sLevelId = (rs.getString(8) != null) ? rs.getString(8) : "null";
			sSourceId = (rs.getString(9) != null) ? rs.getString(9) : "null";
			sSubject = (rs.getBytes(10) != null) ? new String(rs.getBytes(10), "UTF-8") : "null";
			sOriginalIsue = (rs.getString(11) != null) ? rs.getString(11) : "null";
			sFurtherInfo = (rs.getString(12) != null) ? rs.getString(12) : "null";
			sSupportDiary = (rs.getString(13) != null) ? rs.getString(13) : "null";
			sIsueType = (rs.getString(14) != null) ? rs.getString(14) : "null";
			sResolutionTime = (rs.getString(15) != null) ? rs.getString(15) : "null";
			sResolutionWhat = (rs.getString(16) != null) ? rs.getString(16) : "null";
			sResolutionSolve = (rs.getString(17) != null) ? rs.getString(17) : "null";
			sResolutionPrevent = (rs.getBytes(18) != null) ? new String(rs.getBytes(18), "UTF-8") : "null";
			sCreateDate = (rs.getString(19) != null) ? rs.getString(19) : "null";
			sModifyDate = (rs.getString(20) != null) ? rs.getString(20) : "null";

			json.put("sTicketId",sTicketId);
			json.put("sCustId",sCustId);
			json.put("sCustName",sCustName);
			json.put("sUserId",sUserId);
			json.put("sUserName",sUserName);
			json.put("sStatusId",sStatusId);
			json.put("sDisplayName",sDisplayName);
			json.put("sLevelId",sLevelId);
			json.put("sSourceId",sSourceId);
			json.put("sSubject",sSubject);
			json.put("sOriginalIsue",sOriginalIsue);
			json.put("sFurtherInfo",sFurtherInfo);
			json.put("sSupportDiary",sSupportDiary);
			json.put("sIsueType",sIsueType);
			json.put("sResolutionTime",sResolutionTime);
			json.put("sResolutionWhat",sResolutionWhat);
			json.put("sResolutionSolve",sResolutionSolve);
			json.put("sResolutionPrevent",sResolutionPrevent);
			json.put("sDisplayName",sDisplayName);
			json.put("sCreateDate",sCreateDate);
			json.put("sModifyDate",sModifyDate);

			arr.put(json);
			out.print(arr);
		}
	}catch(Exception ex) {
		out.println("Hata: " + ex.getMessage());
	}
%>
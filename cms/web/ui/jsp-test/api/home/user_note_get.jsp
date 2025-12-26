<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.cnt.*,
		com.britemoon.cps.hom.*,
		java.util.*,java.sql.*,
		java.net.*,java.text.*,
		org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../header.jsp"%>
<%@ include file="../../utilities/validator.jsp"%>
<%

if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
	JsonObject data =new JsonObject();
	JsonArray array = new JsonArray();
String sNoteId = request.getParameter("note_id");

if (sNoteId != null) {
	//nothing
} else {

	ConnectionPool		cp				= null;
	Connection			conn 			= null;
	Statement			stmt			= null;
	ResultSet			rs				= null; 

	try {
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("welcome.jsp");
		stmt = conn.createStatement();
		String sSql = "SELECT TOP 1 note_id FROM chom_user_note WHERE cust_id = " + cust.s_cust_id + " AND admin=0 AND published = 1 ORDER BY modify_date DESC";
		rs = stmt.executeQuery(sSql);
		if (rs.next()) {
			sNoteId = rs.getString(1);
		}
		rs.close();
		
	}
	catch(Exception ex)	{ 
		ErrLog.put(this,ex,"user_note_get.jsp",out,1);	
	}
	finally {
		try { if (stmt != null) stmt.close(); }
		catch(Exception e) {}
		if (conn != null) cp.free(conn);
	}

}
	UserNote note = new UserNote();
//System.out.println("retrieving " + sNoteId);
	if (sNoteId != null && !sNoteId.equals("null")) {
		note.s_note_id = sNoteId;
		int nRetrieve = note.retrieve();
		data.put("note_s_note_id",note.s_note_id);
		data.put("note_s_subject",note.s_subject);
		data.put("note_s_user_name",note.s_user_name);
		data.put("note_s_modify_date",note.s_modify_date);
		data.put("note_s_body",note.s_body);
	}
	else {

		String noPastUserNotesMessage="There are currently no user notes";
		data.put("no past user notes message",noPastUserNotesMessage);
	}
	array.put(data);
	out.println(array);

%>


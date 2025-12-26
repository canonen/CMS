<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="com.britemoon.sas.imc.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.w3c.dom.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp" %>
<%
ConnectionPool cp = null;
Connection conn = null;
Statement stmt = null;
ResultSet rs = null;
String sql = null;
try
{
	Element eNote = XmlUtil.getRootElement(request);   
	//Element eNote = XmlUtil.getRootElement("<root></root>");   
    if (eNote == null) {
		out.println("<ERROR>Error retrieving XML in ADM->system_note_info.jsp.  XML sent to ADM did not parse correctly.</ERROR>");
    }
    else {
		String note_id = XmlUtil.getChildTextValue(eNote,"note_id");
	    //System.out.println("note_id="+note_id);
	    //System.out.println("request="+request);
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("system_note_info.jsp");
		stmt = conn.createStatement();		
        if (note_id == null || note_id.equals("")) {
			// if note id is not passed in, then we're returning the most recent note id plus subject for previous 5 notes
        	sql = "SELECT TOP 1 note_id FROM sadm_system_note WHERE published = 1 ORDER BY modify_date DESC";
	        rs = stmt.executeQuery(sql);
	        if (rs.next()) {
				out.println("<SystemNoteList>");
                note_id = rs.getString(1);
				out.println("    <note_id>" + note_id + "</note_id>");
				rs.close();
				// get the previous 5 notes
				sql = 
					"SELECT TOP 5 note_id, subject, CONVERT(VARCHAR(32), modify_date, 100) " +
					"  FROM sadm_system_note " +
					" WHERE published = 1 " +
					"   AND note_id != " + note_id +
					" ORDER BY modify_date DESC";
				rs = stmt.executeQuery(sql);
				while (rs.next()) {
					out.println("  <PreviousNote>");
					out.println("    <note_id>" + rs.getString(1) + "</note_id>");
					out.println("    <subject>" + rs.getString(2) + "</subject>");
					out.println("    <modify_date>" + rs.getString(3) + "</modify_date>");
					out.println("  </PreviousNote>");                
				}
				out.println("</SystemNoteList>");
				rs.close();
	        }
			else {
				out.println("<ERROR>No system note available</ERROR>");
				rs.close();
			}
        }
		else {
			// if note id is passed, send back the details for the note
			sql = 
				"SELECT note_id, subject, body, CONVERT(VARCHAR(32), modify_date, 100) " +
				"  FROM sadm_system_note " +
				" WHERE note_id = " + note_id;
			rs = stmt.executeQuery(sql);
			if (rs.next()) {
				out.println("<SystemNote>");
				out.println("  <note_id>" + rs.getString(1) + "</note_id>");
				out.println("  <subject>" + rs.getString(2) + "</subject>");
				byte[] b = null;
				b = rs.getBytes(3);
				String body = (b == null)?null:new String(b,"UTF-8");
				out.println("  <body><![CDATA[" + body + "]]></body>");
				out.println("  <modify_date>" + rs.getString(4) + "</modify_date>");
				out.println("</SystemNote>");
			}
			else {
				out.println("<ERROR>No data found for note id "+note_id+"</ERROR>");
			}
			rs.close();
		}
        
    }
}
catch(Exception ex)
{ 
	logger.error("Exception: ",ex);
	ex.printStackTrace(new PrintWriter(out));
}
finally
{
	if (conn != null) cp.free(conn);
	out.flush();
}
%>

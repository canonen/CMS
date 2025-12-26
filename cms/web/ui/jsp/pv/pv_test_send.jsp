<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.que.*"
	import="com.britemoon.cps.cnt.*"
	import="com.britemoon.cps.adm.*"
	import="java.util.*"
	import="java.sql.*"
	import="java.io.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
	errorPage="../error_page.jsp"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);
	boolean HYATTUSER = (ui.n_ui_type_id == UIType.HYATT_USER);

	if(!can.bRead && !HYATTUSER)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}
    String pv_test_type_id = request.getParameter("pv_test_type_id");
    String pv_test_format_id = request.getParameter("pv_test_format_id");
    String pv_test_list_ids = request.getParameter("pv_test_list_ids");
	String originCampID = request.getParameter("origin_camp_id");
	String contId = request.getParameter("cont_id");
	String filterIDs = request.getParameter("filter_ids");
	String from = request.getParameter("from");
 	String subj = request.getParameter("subj");
    String textBody = request.getParameter("textBody");
    String htmlBody = request.getParameter("htmlBody");
	
    String pv_cust_id = "";
    String to = "";
    Hashtable pv_report_group = new Hashtable();
	String msg = "";
	String scriptlet = "";
	ConnectionPool cp	= null;
	Connection conn		= null;
	Statement stmt		= null;
	ResultSet rs        = null;
 	String sql          = null;
	try	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();
			
		// get email for test list for scorer and optimizer
		if (!pv_test_type_id.equals("1")) {
			sql = "SELECT TOP 1 email" +
				  "  FROM cque_email_list_item" +
			  	  " WHERE list_id in (" + pv_test_list_ids + ")";
			rs = stmt.executeQuery(sql);
			if (rs.next()) {
				to = rs.getString(1);
			}
			rs.close();
		}
		
	    String pviq = "";
	    boolean ok = false;
		if (!pv_test_type_id.equals("1")) {
			System.out.println("from: " + from + " , to: " + to);
			// get pv iq	
			String list_id = pv_test_list_ids; // we should have passed in only 1 test list id
			String camp_id = NextId.get(cust.s_cust_id, ObjectType.CAMPAIGN);
			sql = "EXEC usp_ccps_next_pv_id_get @cust_id=" + cust.s_cust_id + ", @list_id = " + list_id + ", @camp_id=" + camp_id;
			rs = stmt.executeQuery(sql);
			if (rs.next()) {
				pviq = rs.getString(1);
			}
			rs.close();
						
		    SimpleMailer mailer = new SimpleMailer();
			if (pv_test_format_id.equals("1")) {
		    	ok = mailer.sendText(from, to, subj, textBody, pviq);
			}
			else if (!pv_test_format_id.equals("2")) {
		    	ok = mailer.sendHtml(from, to, subj, htmlBody, pviq);
			}
			else {
		    	ok = mailer.sendBoth(from, to, subj, textBody, htmlBody, pviq);
			}
			if (ok) {
				scriptlet = "<script>opener.send_pv_receipt("+ pv_test_type_id + ",'" + pviq +"'); close();</script>";
			}
			else {
				scriptlet = "<h2>There was a problem sending out the PV test. Please make sure the " + "</h2>";
			}
		}
		else {
			System.out.println("pv_test_list_ids=" + pv_test_list_ids);
			scriptlet = "<script>opener.send_pv_test('" + pv_test_list_ids + "'); close();</script>";
		}
	}
	catch (Exception ex) {
		throw ex; 
	}
	finally {
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}

    out.println("<html><body>" + scriptlet + "</body></html>");

%>	
 

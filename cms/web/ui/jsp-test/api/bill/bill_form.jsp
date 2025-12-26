<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%@ include file="../header.jsp"%>
<%@ include file="../../utilities/validator.jsp"%>

<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

	String last_week="";

    Calendar calendar = Calendar.getInstance();
    int todayDay   = calendar.get (Calendar.DAY_OF_MONTH);
    int todayMonth = calendar.get (Calendar.MONTH) + 1;
    int todayYear  = calendar.get (Calendar.YEAR);
	calendar.add(Calendar.DATE, -6);
	Date lastWeekNotFormat = calendar.getTime();
	last_week = new SimpleDateFormat("yyyy-MM-dd").format(lastWeekNotFormat);

	String today = todayYear + "-" + todayMonth + "-" + todayDay;
	String firstDate = last_week;

	String customerID = cust.s_cust_id;
	String date1 = (request.getParameter("firstDate") != null) ? request.getParameter("firstDate") : firstDate;
	String date2 = (request.getParameter("lastDate") != null) ? request.getParameter("lastDate") : today;
	String delimeter = request.getParameter("delim");
	String partner = request.getParameter("partner");
	String export = request.getParameter("export_name");

	ConnectionPool cp = null;
	Connection conn = null;
	Statement	stmt = null;
	ResultSet	rs = null; 
	String sClassAppend = "";
    String sSQL = null;

    try {
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("mod_customer.jsp");
		stmt = conn.createStatement();

  }
	catch(Exception ex) {
	    ex.printStackTrace(response.getWriter());
	    logger.error("Exception: ",ex);
    }
    finally {
	    if(conn!=null) cp.free(conn);
    }
%>


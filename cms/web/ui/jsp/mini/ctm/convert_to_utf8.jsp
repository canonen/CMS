<%@ page
	import="java.net.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.ctm.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<%  if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%
String doit = request.getParameter("go");
if (doit == null || !doit.equals("britemoon")) {
	%>
		You must enter the secret password to do the convert...	
	<%
	return;
}
System.out.println("Converting ctm_templates and ctm_page_values to UTF-8");
//Get db connection
ConnectionPool connPool = null;
Connection conn         = null;
Statement stmt          = null;
ResultSet rs            = null;
Connection pconn        = null;
PreparedStatement pstmt = null;

try 
{
	connPool = ConnectionPool.getInstance();
	conn = connPool.getConnection("convert_to_utf8.jsp 1");
	stmt = conn.createStatement();
	pconn = connPool.getConnection("convert_to_utf8.jsp 2");
	
	// make sure it's safe to convert
	int rows = 0;
	rs = stmt.executeQuery("SELECT count(*) FROM ctm_templates");
	if (rs.next())
	{
		rows = rs.getInt(1);
	}
	rs.close();
	if (rows > 0)
	{
		System.out.println("Found " + rows + " rows of data from ctm_templates");
		out.println("error: ctm_templates table is not empty");
		return;
	}

	
	rs = stmt.executeQuery("SELECT count(*) FROM ctm_templates_old");
	if (rs.next())
	{
		rows = rs.getInt(1);
	}
	rs.close();
	if (rows <= 0)
	{
		out.println("error: ctm_templates_old table is empty");
		return;
	}
	System.out.println("Found " + rows + " rows of data from ctm_templates_old");
	
	rs = stmt.executeQuery("SELECT count(*) FROM ctm_page_values");
	if (rs.next())
	{
		rows = rs.getInt(1);
	}
	rs.close();
	if (rows > 0)
	{
		System.out.println("Found " + rows + " rows of data from ctm_page_values");
		out.println("error: ctm_page_values table is not empty");
		return;
	}

	
	rs = stmt.executeQuery("SELECT count(*) FROM ctm_page_values_old");
	if (rs.next())
	{
		rows = rs.getInt(1);
	}
	rs.close();
	if (rows <= 0)
	{
		out.println("error: ctm_page_values_old table is empty");
		return;
	}
	System.out.println("Found " + rows + " rows of data from page_values_old");
	
	//Convert templates
	rows = 0;
	System.out.println("Converting ctm_templates");
	String sql = 
		"SELECT template_id, name, customer_id, category, sections_n," +
		" template_html, template_txt, small_image, large_image, global_flag, active" +
		" FROM ctm_templates_old";
	rs = stmt.executeQuery(sql);
	String psql = 
		"INSERT INTO ctm_templates (template_id, name, customer_id, category, sections_n,"+
		" template_html, template_txt, small_image, large_image, global_flag, active)" +
		" VALUES (?,?,?,?,?,?,?,?,?,?,?)";
	pstmt = pconn.prepareStatement(psql);
	while (rs.next()) {
		pstmt.setInt(1,  rs.getInt(1));
		pstmt.setString(2,  rs.getString(2));
		pstmt.setInt(3,  rs.getInt(3));
		pstmt.setString(4,  rs.getString(4));
		pstmt.setInt(5,  rs.getInt(5));
		pstmt.setBytes(6,  convertToCharSequence(rs.getString(6)).getBytes("UTF-8"));
		pstmt.setBytes(7,  convertToCharSequence(rs.getString(7)).getBytes("UTF-8"));
		pstmt.setString(8,  rs.getString(8));
		pstmt.setString(9,  rs.getString(9));
		pstmt.setInt(10, rs.getInt(10));
		pstmt.setInt(11, rs.getInt(11));
		int rc = pstmt.executeUpdate();
		rows++;
	}
	rs.close();
	System.out.println("Converted " + rows + " rows of ctm_templates");
	
	//Convert page values
	rows = 0;
	System.out.println("Converting ctm_page_values");
	sql = "SELECT value_id, content_id, input_id, i_value FROM ctm_page_values_old";
	rs = stmt.executeQuery(sql);
	psql = "INSERT INTO ctm_page_values (value_id, content_id, input_id, i_value) VALUES (?,?,?,?)";
	pstmt = pconn.prepareStatement(psql);
	while (rs.next()) {	
		pstmt.setInt(1,  rs.getInt(1));
		pstmt.setInt(2,  rs.getInt(2));
		pstmt.setInt(3,  rs.getInt(3));
		pstmt.setBytes(4,  convertToCharSequence(rs.getString(4)).getBytes("UTF-8"));
		int rc = pstmt.executeUpdate();
		rows++;
	}
	rs.close();
	System.out.println("Converted " + rows + " rows of ctm_page_values");
}
catch (Exception ex) {
	System.out.println("exception: " + ex.getMessage());
	throw ex; 
}
finally
{
	if (stmt != null) stmt.close();
	if (conn != null) connPool.free(conn);
	if (pconn != null) connPool.free(pconn);
};

%>
Successfully converted ctm_templates and ctm_page_values to UTF-8!!!
<%!
//Converts a num; sequence to chars (db -> java)
private String convertToCharSequence(String strSource) throws Exception
{
	if (strSource.trim().length() > 0)
	{
		StringWriter strwRow = new StringWriter();
		StringTokenizer stSource=new StringTokenizer(strSource, ";");
		String strToken;
		while (stSource.hasMoreTokens()) 
		{
	        strToken=stSource.nextToken();
	        try
	        {
	        	strwRow.write((char) Integer.parseInt(strToken));
	        }
	        catch (Exception ex)
	        {
	        	//System.out.println("invalid input string: " + strToken);
	        }
		};
		return strwRow.toString();
	}
	else
	{
		return "";
	}
};
%>

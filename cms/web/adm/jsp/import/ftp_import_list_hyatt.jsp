<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.upd.*, 
			java.io.*, 
			java.sql.*, 
			java.util.*, 
			org.w3c.dom.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp"%>
<HTML>
<HEAD>
<title>FTP Imports</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>
<BODY>

<FORM action="ftp_import_edit_hyatt.jsp">
	Create new FTP Import Template for Hyatt Property Customer:
	<SELECT name="cust_id">
		<OPTION></OPTION>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
ConnectionPool cp = null;
Connection conn = null;
Statement stmt = null; 

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();
	
	
	// LW change the selection criteria so that it opens up the edit window if a customer has more than one
	// import template, allowing hyatt to have different attributes for Hotel Template from the different 
	// attributes in the Reservation template.
	String sSql =
		" SELECT cust_id, cust_name" +
		" FROM ccps_customer" +
		" WHERE cust_id != 0" +
		" ORDER BY cust_name";
		//" AND ISNULL(parent_cust_id,0) > 0"; //+
		//" AND cust_id NOT IN" +
		//" (SELECT b.cust_id FROM cupd_import_template_hyatt ith, cupd_batch b WHERE ith.batch_id = b.batch_id)";
		
	ResultSet rs = stmt.executeQuery(sSql);	
	
	String sCustId = null;
	String sCustName = null;	
	while(rs.next())
	{
		sCustId = rs.getString(1);
		sCustName = rs.getString(2);
%>
	<OPTION value="<%=sCustId%>"><%=HtmlUtil.escape(sCustName)%> (<%=sCustId%>)</OPTION>
<%	
	}
	rs.close();
%>
	</SELECT>
	<INPUT type="submit" value="GO ..."%>
</FORM>
<BR>
<TABLE border=1 cellspacing=0 cellpadding=1>
	<TR>
		<TH>Edit</TH>
		<TH>template_id</TH>
		<TH>template_name</TH>
		<TH>hotel_id</TH>
		<TH>cust_id</TH>
		<TH>cust_name</TH>
		<TH>batch_id</TH>
		<TH>batch_name</TH>
	</TR>
<%
	String sql =
		" SELECT" +
		" 	ith.template_id," +
		" 	it.template_name," +
		"	ith.hotel_id," +
		"	c.cust_id," + 
		"	c.cust_name," +
		"	b.batch_id," +
		"	b.batch_name" +		
		" FROM" +
		" 	ccps_customer c," +		
		" 	cupd_batch b," +
		" 	cupd_import_template it," +
		" 	cupd_import_template_hyatt ith" +		
		" WHERE" +
		" 	c.cust_id = b.cust_id AND" +
		" 	b.batch_id = ith.batch_id AND" +
		" 	ith.template_id = it.template_id" +
		" ORDER BY c.cust_name, ith.template_id";

		rs = stmt.executeQuery(sql);
		String sTemplateId = null;
		String sTemplateName= null;
		String sHotelId = null;
		String sData = null;		
		while(rs.next())
		{
			sTemplateId = rs.getString(1);
			sTemplateName = rs.getString(2);
			sHotelId = rs.getString(3);
%>
	<TR>
		<TD><A href="ftp_import_edit_hyatt.jsp?template_id=<%=sTemplateId%>&hotel_id=<%=sHotelId%>">Edit</A></TD>		
		<TD><%=sTemplateId%></TD>
		<TD><%=sTemplateName%></TD>
		<TD><%=sHotelId%></TD>		
<%
			for(int i=4; i < 8; i++)
			{
				sData = rs.getString(i);
				if(sData == null) sData = "null";
%>
		<TD nowrap><%=HtmlUtil.escape(sData)%></TD>
<%
			}
%>
	</TR>
<%
		}
		rs.close();
	}
	catch (Exception ex)
	{
		throw ex;
		
//		ex.printStackTrace();
//		out.println("<PRE>");
//		ex.printStackTrace(new PrintWriter(out));
//		out.println("</PRE>");
	}
	finally
	{
		if (stmt!=null) stmt.close();
		if (conn!=null) cp.free(conn);			
	}
%>
</TABLE>
</BODY>
</HTML>

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

<FORM action="import_template_edit.jsp">
	Create new Import Template for customer:
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
	
	String sSql =
		" SELECT cust_id, cust_name" +
		" FROM ccps_customer" +
		" WHERE cust_id != 0";
		
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
		<TH>cust_id</TH>
		<TH>cust_name</TH>
		<TH>batch_id</TH>
		<TH>batch_name</TH>
		<TH>type_id</TH>
		<TH>first_row</TH>
		<TH>field_separator</TH>
		<TH>multi_value_field_separator</TH>
		<TH>auto_commit_flag</TH>
		<TH>upd_rule_id</TH>
		<TH>upd_hierarchy_id</TH>		
		<TH>full_name_flag</TH>
		<TH>email_type_flag</TH>
		<TH>name_import_as_file_flag</TH>
		<TH>filter_per_import_flag</TH>
	</TR>
<%
	String sql =
		" SELECT" +
		"	it.template_id,"+		
		"	it.template_name,"+		
		"	c.cust_id," + 
		"	c.cust_name," +
		"	b.batch_id," +
		"	b.batch_name," +		
		" 	it.type_id," +
		" 	it.first_row," +
		" 	it.field_separator," +
		" 	it.multi_value_field_separator," +
		" 	it.auto_commit_flag," +		
		" 	it.upd_rule_id," +
		" 	it.upd_hierarchy_id," +		
		" 	it.full_name_flag," +
		" 	it.email_type_flag," +
		" 	it.name_import_as_file_flag," +
		" 	it.filter_per_import_flag" +		
		" FROM" +
		" 	ccps_customer c," +		
		" 	cupd_batch b," +
		" 	cupd_import_template it" +
		" WHERE" +
		" 	c.cust_id = b.cust_id AND" +
		" 	b.batch_id = it.batch_id" +
		" ORDER BY it.template_id";

		rs = stmt.executeQuery(sql);
		String sTemplateId = null;
		String sData = null;		
		while(rs.next())
		{
			sTemplateId = rs.getString(1);
%>
	<TR>
		<TD><A href="import_template_edit.jsp?template_id=<%=sTemplateId%>">Edit</A></TD>
		<TD><%=sTemplateId%></TD>		
<%
			for(int i=2; i < 18; i++)
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
		logger.error("Exception: ", ex);
		out.println("<PRE>");
		ex.printStackTrace(new PrintWriter(out));
		out.println("</PRE>");
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

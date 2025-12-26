<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.rcp.*, 
			com.britemoon.rcp.imc.*,
			com.britemoon.rcp.que.*,
			java.sql.*,
			java.util.Calendar,
			java.io.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
%>
<%@ include file="../header.jsp" %>
<%
String sCustId = request.getParameter("cust_id");
Campaign camp = new Campaign();
camp.s_cust_id = sCustId;

%>

<%

	ResultSet	rs	= null; 
	ConnectionPool	cp_w	= null;
	Connection 	conn_w	= null;
	Statement	stmt_w	= null;
	JsonObject data=new JsonObject();
	JsonArray array = new JsonArray();

try
{
	cp_w = ConnectionPool.getInstance(sCustId);
	conn_w = cp_w.getConnection(this);
	stmt_w = conn_w.createStatement();
	

	String s_active = null;
	rs = stmt_w.executeQuery("select count(*) from rrcp_cust_recip with(nolock) where status_id=110");
	while(rs.next())
	{
	    data=new JsonObject();
	    s_active = rs.getString(1);
        data.put("s_active", s_active);
        array.put(data);
	}
	rs.close();

	String s_gender =null;
	rs = stmt_w.executeQuery("select count(rc.recip_id) from rrcp_attr_string ras with(nolock) left join rrcp_attribute ra with(nolock) on ra.attr_id=ras.attr_id left join rrcp_cust_recip rc with(nolock) on ras.recip_id=rc.recip_id where ra.attr_name='pnmgiven' and ras.attr_value like '%%' and rc.status_id=110");
	while(rs.next())
	{
	    data=new JsonObject();
	    s_gender = rs.getString(1);
	    data.put("s_gender",s_gender);
	    array.put(data);
	}
	rs.close();

	String s_birthdate =null;
	rs = stmt_w.executeQuery("select count(rc.recip_id) from rrcp_attr_date ras with(nolock) left join rrcp_attribute ra with(nolock) on ra.attr_id=ras.attr_id left join rrcp_cust_recip rc with(nolock) on ras.recip_id=rc.recip_id where ra.attr_name='birthdate' and ras.attr_value like '%%' and rc.status_id=110");
	while(rs.next())
	{
	    data=new JsonObject();
	    s_birthdate = rs.getString(1);
	    data.put("s_birthdate"),s_birthdate;
	    array.put(data);
	}
	rs.close();
	
	String s_location =null;
	rs = stmt_w.executeQuery("select count(rc.recip_id) from rrcp_attr_string ras with(nolock) left join rrcp_attribute ra with(nolock) on ra.attr_id=ras.attr_id left join rrcp_cust_recip rc with(nolock) on ras.recip_id=rc.recip_id where ra.attr_name='location' and ras.attr_value like '%%' and rc.status_id=110");
	while(rs.next())
	{
	    data=new JsonObject();
	    s_location = rs.getString(1);
	    data.put("s_location",s_location);
	    array.put(data);
	}
	rs.close();	

	String s_pers =null;
	rs = stmt_w.executeQuery("select count(rc.recip_id) from rrcp_attr_string ras with(nolock) left join rrcp_attribute ra with(nolock) on ra.attr_id=ras.attr_id left join rrcp_cust_recip rc with(nolock) on ras.recip_id=rc.recip_id where ra.attr_name='pnmgiven' and ras.attr_value like '%%' and rc.status_id=110");
	while(rs.next())
	{
	    data = new JsonObject();
	    s_pers = rs.getString(1);
	    data.put("s_pers", s_pers);
	    array.put(data);
	}
	rs.close();	

	String s_gender_count ="";
	String s_gender_source ="";	
	String gender_count ="";
	
	
	rs = stmt_w.executeQuery("select count(rc.recip_id), ras.attr_value from rrcp_attr_string ras with(nolock)  left join rrcp_attribute ra with(nolock) on ra.attr_id=ras.attr_id left join rrcp_cust_recip rc with(nolock) on ras.recip_id=rc.recip_id where ra.attr_name='gender' and ras.attr_value like '%%' and rc.status_id=110 group by ras.attr_value	");	
	while(rs.next()){

	    data=new JsonObject();
		s_gender_count = rs.getString(1);
		s_gender_source = rs.getString(2);
		data.put("s_gender_count",s_gender_count);
		data.put("s_gender_source",s_gender_source);
		array.put(data);

		//g_leadby_source 	+= "{\"label\":\""+s_leadby_source+"\"},";
		//g_leadby_source_count 	+= "{\"value\":\""+s_leadby_source_count+"\"},";
		
		gender_count += "{\"label\":\""+s_gender_source+"\",\"value\":\""+s_gender_count+"\"},";
	}	
	rs.close();



int s_unknown_gender = 0;
s_unknown_gender = Integer.parseInt(s_active) - Integer.parseInt(s_gender);

int s_unknown_birthdate = 0;
s_unknown_birthdate = Integer.parseInt(s_active) - Integer.parseInt(s_birthdate);

int s_unknown_location = 0;
s_unknown_location = Integer.parseInt(s_active) - Integer.parseInt(s_location);

int s_unknown_pers = 0;
s_unknown_pers = Integer.parseInt(s_active) - Integer.parseInt(s_pers);


%>
<%
}
catch(Exception ex)
{ 
	ErrLog.put(this, ex, "Error in " + this.getClass().getName(), out, 1);
}
finally
{
	try
	{
		if (stmt_w!=null) stmt_w.close();
		if (conn_w!=null) cp_w.free(conn_w);
	}
	catch (SQLException e)
	{
		logger.error("Could not clean db statement or connection", e);
	}
}

%>
</BODY>
<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.util.*,java.sql.*,
			java.net.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="../header.jsp"%>
<%@ include file="../../utilities/validator.jsp"%>
<%! static Logger logger = null;%> 
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
	
}

String superCampID = request.getParameter("super_camp_id");
String superCampName = request.getParameter("super_camp_name");
String sCampIDs = request.getParameter("super_camps");
String sSelectedCategoryId = request.getParameter("category_id");

// Connection
Statement			stmt	= null;
ResultSet			rs		= null; 
ConnectionPool		cp 		= null;
Connection			conn 	= null;

JsonObject data= new JsonObject();
JsonArray array= new JsonArray();

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("super_camp_save.jsp");
	stmt = conn.createStatement();

	String sSql;
	if (superCampID.equals("null"))
	{
		//New Super Camp
		data = new JsonObject();
		sSql = "INSERT cque_super_camp (super_camp_name, cust_id) VALUES (?,"+cust.s_cust_id+")";
		rs= stmt.executeQuery(sSql);
		data.put("super_camp_name",rs.getString(1));
		data.put("cust_id",rs.getString(2));
		//rs.executeUpdate();	
		rs = stmt.executeQuery("SELECT @@IDENTITY");
		rs.next();

		array.put(data);
		
		//Insert rows into cque_super_camp_camp
		sSql = "INSERT cque_super_camp_camp (super_camp_id, camp_id) VALUES ("+superCampID+",?)";
		String campIDs[] = sCampIDs.split(",");
		for (int x=0;x<campIDs.length;++x) {
			data = new JsonObject();
			rs =  stmt.executeQuery(sSql);
			data.put("super_camp_id",rs.getString(1));
			data.put("camp_id",rs.getString(2));
			//rs.executeUpdate();
			array.put(data);
		}
	}
	else
	{
		data= new JsonObject();
		//Update Super Camp
		sSql = "UPDATE cque_super_camp SET super_camp_name = ? " +
			   "WHERE cust_id = "+cust.s_cust_id+" AND super_camp_id = "+superCampID;
		rs = stmt.executeQuery(sSql);
        data.put("super_camp_name",rs.getString(1));
		//Delete existing mappings
	    stmt.executeUpdate("DELETE cque_super_camp_camp WHERE super_camp_id = "+superCampID);
		
		//Insert rows into cque_super_camp_camp
		sSql = "INSERT cque_super_camp_camp (super_camp_id, camp_id) VALUES ("+superCampID+",?)";
		String campIDs[] = sCampIDs.split(",");
		for (int x=0;x<campIDs.length;++x) {
			rs =stmt.executeQuery(sSql);
			data.put("super_camp_id",rs.getString(1));
			data.put("camp_id",rs.getString(2));
			array.put(data);
		}
	}
	
	
	//Delete super links that no longer belong to campaigns in the super campaign
	sSql = "DELETE crpt_super_link_link"
		+ " FROM crpt_super_link_link sl, cjtk_link l, cque_campaign c"
		+ " WHERE sl.link_id = l.link_id AND l.cont_id = c.cont_id"
		+ " AND sl.super_camp_id = "+superCampID
		+ " AND c.origin_camp_id NOT IN (SELECT camp_id FROM cque_super_camp_camp"
			+ " WHERE super_camp_id = "+superCampID+")";
	stmt.executeUpdate(sSql);
}
catch(Exception ex) { throw ex;}
finally
{
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn);
}
%>

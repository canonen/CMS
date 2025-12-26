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
<%@ include file="../validator.jsp"%>
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
//PreparedStatement	rs	= null;
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
		rs = conn.executeQuery(sSql);
		data.put("super_camp_name",rs.setBytes(1, superCampName.getBytes("ISO-8859-1")));
		//rs.executeUpdate();
		
		rs = stmt.executeQuery("SELECT @@IDENTITY");
		rs.next();
		data.put("super_camp_id",rs.getString(1));
		array.put(data);
		conn.close();
		//Insert rows into cque_super_camp_camp
		sSql = "INSERT cque_super_camp_camp (super_camp_id, camp_id) VALUES ("+superCampID+",?)";
		String campIDs[] = sCampIDs.split(",");
		for (int x=0;x<campIDs.length;++x) {
			data = new JsonObject();
			rs = conn.executeQuery(sSql);
			data.put("super_camp_id",rs.setString(1, campIDs[x]));
			//rs.setString(1, campIDs[x]);
			//rs.executeUpdate();
			array.put(data);
		}
		conn.close();
	}
	else
	{
		data = new JsonObject();
		//Update Super Camp
		sSql = "UPDATE cque_super_camp SET super_camp_name = ? " +
			   "WHERE cust_id = "+cust.s_cust_id+" AND super_camp_id = "+superCampID;
		rs = conn.executeQuery(sSql);
		data.put("super_camp_name",rs.setBytes(1, superCampName.getBytes("ISO-8859-1")));
		//rs.executeUpdate();
		array.put(data);
		conn.close();

		//Delete existing mappings
		stmt.executeUpdate("DELETE cque_super_camp_camp WHERE super_camp_id = "+superCampID);
		
		//Insert rows into cque_super_camp_camp
		sSql = "INSERT cque_super_camp_camp (super_camp_id, camp_id) VALUES ("+superCampID+",?)";
		String campIDs[] = sCampIDs.split(",");
		for (int x=0;x<campIDs.length;++x) {
			data = new JsonObject();
			rs = conn.executeQuery(sSql);
			data.put("super_camp_id",rs.setString(1, campIDs[x]));
			//rs.executeUpdate();
			array.put(data);
		}
		conn.close();
	}
	
	
	//Delete super links that no longer belong to campaigns in the super campaign
	sSql = "DELETE crpt_super_link_link"
		+ " FROM crpt_super_link_link sl, cjtk_link l, cque_campaign c"
		+ " WHERE sl.link_id = l.link_id AND l.cont_id = c.cont_id"
		+ " AND sl.super_camp_id = "+superCampID
		+ " AND c.origin_camp_id NOT IN (SELECT camp_id FROM cque_super_camp_camp"
			+ " WHERE super_camp_id = "+superCampID+")";
	stmt.executeUpdate(sSql);
	conn.close();
}
catch(Exception ex) { throw ex;}
finally
{
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn);
}
%>

<HTML>
<HEAD>
	<LINK rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>
<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Super Campaign:</b> Saved</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<b>The super campaign was saved.</b>
						<P align="center"><a href="super_camp_report_list.jsp<%=(sSelectedCategoryId!=null)?"?CategoryID="+sSelectedCategoryId:""%>">Back to List</a></P>
						<P align="center"><a href="super_camp_object.jsp?super_camp_id=<%= superCampID %><%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>">Back to Edit</a></P>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</BODY>
</HTML>

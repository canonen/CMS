<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.adm.*,
		com.britemoon.cps.tgt.*,
		com.britemoon.cps.xcs.cti.*,
		com.britemoon.cps.imc.*,
		java.io.*,java.sql.*,
		java.util.*,org.w3c.dom.*,
		org.json.JSONArray,
        org.json.JSONObject,
		org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
String sAttrIdList = request.getParameter("attr_id_list");
String sContIdList = request.getParameter("cont_id_list");
String sCampId = request.getParameter("camp_id");
String sPrintFlag = request.getParameter("print_flag");

boolean isPrintCampaign = false;
if (sPrintFlag != null && sPrintFlag.equals("1") ) {
	isPrintCampaign = true;
}

ConnectionPool	cp		= null;
Connection		conn	= null;
Statement		stmt	= null;
ResultSet		rs		= null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("mapper_attr.jsp");
	stmt = conn.createStatement();
	String sSql = null;
    JSONArray newArray = new JSONArray();
    JSONObject obj = new JSONObject();



	boolean canEditCamp = true;

		int count = 0;
		rs = stmt.executeQuery("SELECT c.display_name, c.attr_id, 1"+
                               						   "FROM ccps_cust_attr c "+
                               						    "WHERE c.cust_id =" + cust.s_cust_id +""+
                               						    "ORDER BY ISNULL(c.display_seq,9999)");
		while(rs.next()){
		    obj = new JSONObject();
		    obj.put("name",rs.getString(1));
		    obj.put("id",rs.getString(2));
            newArray.put(obj);
		}
		rs.close();
		out.print(newArray);

}
catch(Exception ex) { throw ex; }
finally
{   if(rs != null) rs.close();
	if (stmt != null) stmt.close();
	if (conn != null) cp.free(conn);
}
%>

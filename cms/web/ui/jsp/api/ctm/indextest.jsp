<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.ctm.*"
	import="org.apache.log4j.*"
	import="java.util.*"
	import="java.sql.*"
	import="java.net.*"
	import="java.text.DateFormat"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.ctl.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.rpt.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.*,
			com.britemoon.rcp.*,
			java.sql.*,java.util.Vector,
			org.w3c.dom.*,org.apache.log4j.*"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
	AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);
	String		sOrderBy	= request.getParameter("sort_by");

/*
//Make sure these are gone
session.removeAttribute("pbean");
session.removeAttribute("tbean");

String		scurPage	= request.getParameter("curPage");
String		samount		= request.getParameter("amount");

int			curPage			= 1;
int			amount			= 0;

curPage		= (scurPage		== null) ? 1 : Integer.parseInt(scurPage);

if ((samount == null)||("".equals(samount))) samount = "25";
try { amount = Integer.parseInt(samount); }
catch (Exception ex) 
{ 
	samount = "25"; 
	amount = 25;
}
*/
if ((sOrderBy == null)||("".equals(sOrderBy))) sOrderBy = "mod_date desc";

//Grab this customer's pages from the db
ConnectionPool cp 		= null;
Connection conn         = null;
Statement stmt          = null;
ResultSet rs            = null;
	JsonObject data = new JsonObject();
	JsonArray arrayData = new JsonArray();
	String custid = cust.s_cust_id;

int templateID, contentID;
String t_image, pageName, templateName, status;
Timestamp modDate;

	/*
String isAdmin = (String)session.getAttribute("isAdmin");
String isHyatt = (String)session.getAttribute("isHyatt");
String isWizard = (String)session.getAttribute("isWizard");
String isParent = "0";



StringBuilder TABLE_TR = new StringBuilder();

if (isAdmin == null || isAdmin.length() == 0) {
    isAdmin = "0";
}


if (isHyatt == null || isHyatt.length() == 0) {
    isHyatt = "0";
}


if (isWizard == null || isWizard.length() == 0) {
    isWizard = "0";
}


if (isAdmin.equals("1") && isHyatt.equals("1")) {
    isParent = "1";
}
int iCount = 0;
String sClassAppend = null;
*/
					try {
						cp = ConnectionPool.getInstance();
						conn = cp.getConnection("index.jsp");
						stmt = conn.createStatement();

						rs = stmt.executeQuery("" +
							"select distinct content_id, category, p.template_id, p.name, mod_date, t.name as template_name, " +
							"status, mod_by, creation_date, user_name, t.small_image " +
							"from ctm_pages p with(nolock), ctm_templates t with(nolock) " +
							"where p.template_id = t.template_id " +
							"and p.customer_id = " + custid + " " +
							"and status <> 'deleted' "
							 );

						if(rs !=null){
							while (rs.next())
							{
								contentID = rs.getInt(1);


								templateID = rs.getInt(3);
								pageName = new String(rs.getBytes(4), "UTF-8");
								modDate = rs.getTimestamp(5);

								templateName = rs.getString(6);
								status = rs.getString(7);
								t_image = rs.getString(11);

								data = new JsonObject();
								data.put("contentID", contentID);
								data.put("templateID", templateID);
								data.put("pageName", pageName);
								data.put("modDate", modDate);
								data.put("templateName", templateName);
								data.put("status", status);
								data.put("t_image", t_image);
								arrayData.put(data);
							}
							rs.close();
							out.println(arrayData.toString());
						}
							else out.println(arrayData.toString());



							
								}catch(Exception ex){	ErrLog.put(this, ex, "Error in " + this.getClass().getName(), out, 1);}
								finally{
								if (rs != null) rs.close();
								if (stmt != null) stmt.close();
								if (conn  != null) cp.free(conn);
							}
							%>


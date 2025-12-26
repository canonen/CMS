<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.exp.*,
		com.britemoon.cps.ctl.*,
		java.sql.*,java.util.*,
		java.net.*,org.w3c.dom.*,
		org.apache.log4j.*"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="java.util.Date" %>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>

<%! 
   	static Logger logger = null;
    public class qParm 
    { 
    	String  offset;
        String	id; 
        String	name; 
        
        public qParm(String a, String b) { id = a; name = b; offset = b; } 
    }
%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
AccessPermission can = user.getAccessPermission(ObjectType.EXPORT);
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

String sfile_id = request.getParameter("file_id");

String sSelectedCategoryId = request.getParameter("category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;

JsonObject data = new JsonObject();
JsonArray array = new JsonArray();
JsonArray array1 = new JsonArray();
JsonArray array2 = new JsonArray();
JsonArray array3 = new JsonArray();
JsonArray array4 = new JsonArray();
JsonArray array5 = new JsonArray();
JsonArray array6 = new JsonArray();
Statement	stmt;
ResultSet	rs; 
ConnectionPool 	connectionPool 	= null;
Connection 	srvConnection 	= null;
Connection 	srvConnection2 	= null;
Statement	stmt2;
ResultSet	rs_2; 
int		nStep		= 1;
try {
	connectionPool = ConnectionPool.getInstance();
	srvConnection = connectionPool.getConnection("export_new.jsp");
	stmt  = srvConnection.createStatement();
	srvConnection2 = connectionPool.getConnection("export_new.jsp 2");
	stmt2  = srvConnection2.createStatement();
} catch(Exception ex) {
	connectionPool.free(srvConnection);
	out.println("<BR>Connection error ... !<BR><BR>"); 
	return;
}

String sSql  = null;
String		CUSTOMER_ID	= cust.s_cust_id;
String campName ="";
String typeName ="";
String		QUERY_NAME	= "";
String[]	tmp		= new String[8];
Enumeration	e;
qParm		sqlE;
Vector		parm		= new Vector();
int		FLAG = 0;

boolean 	isDisable = false;
boolean 	isInUse = false;

try {

	tmp[0] = "null";
	tmp[1] = "New target group"; 
	tmp[2] = ""; 
	tmp[3] = ""; 
	tmp[4] = ""; 
	tmp[5] = ""; 
	tmp[6] = ""; 

	int		kCamp		= -1;
	int		kTarg		= -1;
	int		kBat		= -1;
	int		kClick		= -1;
	String		kCamp0 = "0", kClick0 = "0", kTarg0 = "0", kBat0 = "0";
	String		id		= "";
	String		id2		= "";

	boolean		isChangeable 	= true;
	String		isChecked;

	if(sSelectedCategoryId!=null){
		data.put("sSelectedCategoryId",sSelectedCategoryId);
	}
	else data.put("sSelectedCategoryId","");


	if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) ) {
		sSql  =
			"SELECT c.camp_id, c.camp_name, t.type_name" +
			" FROM cque_campaign c, cque_camp_type t" +
			" WHERE c.origin_camp_id IS NOT NULL" +
			" AND c.type_id != " + CampaignType.TEST+
			" AND (c.status_id = " + CampaignStatus.DONE +
			" OR (c.type_id IN ("+CampaignType.SEND_TO_FRIEND+","+CampaignType.AUTO_RESPOND+")" +
			" AND c.status_id > "+CampaignStatus.DRAFT+" AND c.status_id <= "+CampaignStatus.DONE+") )" +
			" AND c.cust_id = " + cust.s_cust_id +
			" AND c.type_id = t.type_id" +
			" ORDER BY c.camp_id";
	} else {
		sSql  =
			"SELECT c.camp_id, c.camp_name, t.type_name" +
			" FROM cque_campaign c, cque_camp_type t, ccps_object_category oc" +
			" WHERE c.origin_camp_id IS NOT NULL" +
			" AND c.type_id != " + CampaignType.TEST+
			" AND (c.status_id = " + CampaignStatus.DONE +
			" OR (c.type_id IN ("+CampaignType.SEND_TO_FRIEND+","+CampaignType.AUTO_RESPOND+")" +
			" AND c.status_id > "+CampaignStatus.DRAFT+" AND c.status_id <= "+CampaignStatus.DONE+") )" +
			" AND c.cust_id = " + cust.s_cust_id +
			" AND c.type_id = t.type_id" +
			" AND c.origin_camp_id = oc.object_id" +
			" AND oc.type_id = " + ObjectType.CAMPAIGN +
			" AND oc.cust_id = " + cust.s_cust_id +
			" AND oc.category_id = " + sSelectedCategoryId +
			" ORDER BY c.camp_id";
	}

	rs = stmt.executeQuery(sSql);
	while(rs.next()) {
		data = new JsonObject();
		id = rs.getString(1);
		campName = new String(rs.getBytes(2),"ISO-8859-1");
		typeName = rs.getString(3);
		data.put("campId",id);
		data.put("campName",campName);
		data.put("typeName",typeName);
		kCamp ++; 
		isChecked = (kCamp == 0)? "SELECTED" : "";
		if(kCamp==0) data.put("isChecked","SELECTED");
		else data.put("isChecked","");

		if (kCamp == 0)		kCamp0 = id;
		array1.put(data);
	}  
	rs.close();


	if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) ) {
		sSql  =
			"SELECT c.camp_id, c.camp_name" +
			" FROM cque_campaign c" +
			" WHERE c.origin_camp_id IS NOT NULL" +
			" AND c.type_id != 1" +
			" AND c.status_id = " + CampaignStatus.DONE +
			" AND c.cust_id = " + cust.s_cust_id +
			" ORDER BY c.camp_id";
	} else {
		sSql  =
			"SELECT c.camp_id, c.camp_name" +
			" FROM cque_campaign c, ccps_object_category oc" +
			" WHERE c.origin_camp_id IS NOT NULL" +
			" AND c.type_id != 1" +
			" AND c.status_id = " + CampaignStatus.DONE +
			" AND c.cust_id = " + cust.s_cust_id +
			" AND c.origin_camp_id = oc.object_id" +
			" AND oc.type_id = " + ObjectType.CAMPAIGN +
			" AND oc.cust_id = " + cust.s_cust_id +
			" AND oc.category_id = " + sSelectedCategoryId +
			" ORDER BY c.camp_id";
	}

	rs = stmt.executeQuery(sSql);
	String	sName = null;
	while (rs.next()) {
		data = new JsonObject();
		id = rs.getString(1);
		sName = new String(rs.getBytes(2),"ISO-8859-1");
		data.put("camp_id",id);
		data.put("campName",campName);

		rs_2 = stmt2.executeQuery("SELECT DISTINCT link_id, link_name"
			+ " FROM cjtk_link l, cque_campaign c"
			+ " WHERE l.cont_id = c.cont_id AND c.camp_id = " + id);

		while(rs_2.next()) {
			data = new JsonObject();
			id2 = id + ":" + rs_2.getString(1);
			++kClick;
			if(kClick==0) data.put("isChecked","SELECTED");
			else data.put("isChecked","");
			if (kClick == 0)		kClick0 = id2;
			data.put("linkID",id);


			sName=new String(rs_2.getBytes(2),"ISO-8859-1");
			data.put("linkName",sName);

		}
		rs_2.close();
		array2.put(data);
	}
	rs.close();


	if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) ) {
		sSql  =
			"SELECT filter_id, filter_name" +
			" FROM ctgt_filter" +
			" WHERE filter_name IS NOT NULL AND origin_filter_id IS NULL" +
			" AND type_id = " + FilterType.MULTIPART +
			" AND status_id != " + FilterStatus.DELETED +
			" AND cust_id = " + cust.s_cust_id +
			" ORDER BY filter_name";
	} else {
		sSql  =
			"SELECT f.filter_id, f.filter_name" +
			" FROM ctgt_filter f, ccps_object_category oc" +
			" WHERE f.filter_name IS NOT NULL AND f.origin_filter_id IS NULL" +
			" AND f.type_id = " + FilterType.MULTIPART +
			" AND f.status_id != " + FilterStatus.DELETED +
			" AND f.cust_id = " + cust.s_cust_id +
			" AND f.filter_id = oc.object_id" +
			" AND oc.type_id = " + ObjectType.FILTER +
			" AND oc.cust_id = " + cust.s_cust_id +
			" AND oc.category_id = " + sSelectedCategoryId +
			" ORDER BY f.filter_name";
	}

	rs = stmt.executeQuery(sSql);
	while(rs.next()) {
		data = new JsonObject();
		id = rs.getString(1);
		sName = new String(rs.getBytes(2),"ISO-8859-1");
		++kTarg;
		if(kTarg==0) data.put("isChecked","SELECTED");
		else data.put("isChecked","");
		if (kTarg == 0)		kTarg0 = id;
		data.put("filterId",id);
		data.put("filterName",sName);

		array3.put(data);

	} 
	rs.close();


	if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) ) {
		sSql =
			" SELECT b.batch_id, b.batch_name" +
			" FROM cupd_batch b" + 
			" WHERE ( (b.type_id = 1" + 
			" AND b.batch_id IN" +
				" (SELECT DISTINCT i.batch_id" +
				" FROM cupd_import i, cupd_batch b" +
				" WHERE i.status_id = "+ UpdateStatus.COMMIT_COMPLETE +
				" AND i.batch_id = b.batch_id" +
				" AND b.cust_id = " + cust.s_cust_id + "))" +
			" OR (b.type_id > 1) )" +
			" AND b.cust_id = " + cust.s_cust_id +
			" ORDER BY type_id, batch_name";
	} else {
		sSql =
			" SELECT b.batch_id, b.batch_name" +
			" FROM cupd_batch b" + 
			" WHERE ( (b.type_id = 1" + 
			" AND b.batch_id IN" +
				" (SELECT DISTINCT i.batch_id" +
				" FROM cupd_import i, cupd_batch b, ccps_object_category oc" +
				" WHERE i.status_id = "+ UpdateStatus.COMMIT_COMPLETE +
				" AND i.batch_id = b.batch_id" +
				" AND b.cust_id = " + cust.s_cust_id + 
				" AND oc.object_id = i.import_id" +
				" AND oc.type_id = " + ObjectType.IMPORT +
				" AND oc.cust_id = " + cust.s_cust_id +
				" AND oc.category_id = " + sSelectedCategoryId + "))" +
			" OR (b.type_id > 1) )" +
			" AND b.cust_id = " + cust.s_cust_id +
			" ORDER BY type_id, batch_name";
	}

	rs = stmt.executeQuery(sSql);
	while(rs.next()) {
		data = new JsonObject();
		id = rs.getString(1);
		sName= new String(rs.getBytes(2),"ISO-8859-1");
		++kBat;
		if(kTarg==0) data.put("isChecked","SELECTED");
		else data.put("isChecked","");
		if (kBat == 0)		kBat0 = id;
		data.put("batchID", id);
		data.put("batchName",sName);
		array4.put(data);
	}
	rs.close();

	String	attrParm = "";
	String	attrName = "";
	String rs1, rs2, rs3, rs4;
	int nType;

	rs = stmt.executeQuery(
		"SELECT c.attr_id, c.display_name + '(' + t.type_name + ')', a.type_id " +
		"FROM ccps_attribute a, ccps_cust_attr c, ccps_data_type t " +
		"WHERE c.cust_id = "+CUSTOMER_ID+" " +
		"AND c.attr_id = a.attr_id " +
		"AND a.type_id = t.type_id " +
		"AND c.display_seq IS NOT NULL " +
		"ORDER BY c.display_seq");

	while (rs.next())	{
		data = new JsonObject();
		rs1 = rs.getString (1);
		rs2 = new String(rs.getBytes(2),"ISO-8859-1");
		nType = rs.getInt(3);
		data.put("attrID",rs1);
		data.put("displayName",rs2);
		data.put("typeName",nType);
		attrParm += rs1+"," + rs2 +","+ rs1 ;
		attrName += rs1 + ","+rs1;
		data.put("attrParm",attrParm);
		data.put("attrName",attrName);

		array5.put(data);
	}

	rs.close();


	String sCategoryId = null;
	String sCategoryName = null;

	String ssSql = "";
		ssSql = " SELECT category_id, category_name" +
				" FROM ccps_category" +
				" WHERE cust_id="+CUSTOMER_ID+
				" ORDER BY category_name";


	ResultSet rs5  = stmt.executeQuery(ssSql);

	while (rs5.next())
	{
		data = new JsonObject();
		sCategoryId = rs5.getString(1);
		sCategoryName = new String(rs5.getBytes(2), "UTF-8");
		data.put("sCategoryId",sCategoryId);
		data.put("sCategoryName",sCategoryName);

		array6.put(data);
	}
	rs5.close();
	array.put(array1);
	array.put(array2);
	array.put(array3);
	array.put(array4);
	array.put(array5);
	array.put(array6);
	out.println(array);

	} catch(Exception ex) {
		ErrLog.put(this,ex,"export_new.jsp",out,1);
		return;
	} finally {
		if (rs!= null) rs.close();
        if (rs2!= null) rs2.close();
        if (rs3!= null) rs3.close();
        if (rs4!= null) rs4.close();
        if (stmt!= null) stmt.close();
        if (stmt2!= null) stmt2.close();
        if (srvConnection!= null) connectionPool.free(srvConnection);
        if (srvConnection2!= null) connectionPool.free(srvConnection2);
	}
%>

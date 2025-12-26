<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.cnt.*,
		java.util.*,java.sql.*,
		java.io.*,javax.servlet.*,
		javax.servlet.http.*,org.xml.sax.*,
		javax.xml.transform.*,
		javax.xml.transform.stream.*,org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
	errorPage="../error_page.jsp"
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
	AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);
    JsonObject object = new JsonObject();
	JsonArray array = new JsonArray();

	ConnectionPool cp	= null;
    Connection conn		= null;
    Statement stmt		= null;
    ResultSet rs		= null;

    String sSql ="Exec dbo.usp_ccnt_list_get @type_id=20, @CustomerId="+cust.s_cust_id;


    try{

        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();
        rs = stmt.executeQuery(sSql);

        while (rs.next()){
            object = new JsonObject();
            object.put("contID",rs.getString(1));
            object.put("contName",rs.getString(2));
            object.put("WizardId",rs.getString(3));
            object.put("type_id",rs.getString(4));
            object.put("display_name",rs.getString(5));
            object.put("ModifyDate",rs.getString(6));
            object.put("StatusId",rs.getString(7));
            object.put("Status",rs.getString(8));
            object.put("Editor",rs.getString(9));
            object.put("modify_date",rs.getString(10));
            
            array.put(object);
        }
        out.print(array);
        rs.close();
    }catch(Exception ex) { throw ex; }

%>

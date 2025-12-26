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
<%@ include file="../../header.jsp"%>
<%@ include file="../../../utilities/validator.jsp"%>
<%! static Logger logger = null;%>
<%
  if(logger == null)
  {
    logger = Logger.getLogger(this.getClass().getName());
  }

  AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);
  boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

  if(!can.bRead)
  {
    response.sendRedirect("../access_denied.jsp");
    return;
  }

  boolean canSpecTest = ui.getFeatureAccess(Feature.SPECIFIED_TEST);
  boolean canTestHelp = ui.getFeatureAccess(Feature.TESTING_HELP);
%>

<%
  // Connection
  ConnectionPool	cp		= null;
  Connection		conn	= null;
  Statement		stmt	= null;
  ResultSet		rs		= null;

  try
  {
    cp = ConnectionPool.getInstance();
    conn = cp.getConnection(this);
    stmt = conn.createStatement();
    JsonObject data = new JsonObject();
    JsonArray listData  = new JsonArray();
    String listTypeID = request.getParameter("typeID");
    if (listTypeID == null) listTypeID = "2";
    if(listTypeID=="3") listTypeID = "Exclusion List";

    String listType = "Testing List";
    if (listTypeID.equals("1")) listType = "Global Exclusion List";
    if (listTypeID.equals("3")) listType = "Exclusion List";
    if (listTypeID.equals("4")) listType = "Auto-Respond Notification List";
//	if (listTypeID.equals("5")) listType = "Specified Test Recipient List";

    String		id, name, typeName;


    String sSql =
            " SELECT list_id, list_name, type_name" +
                    " FROM cque_email_list l, cque_list_type t " +
                    " WHERE" +
                    " (l.type_id = "+listTypeID+(listTypeID.equals("4")?" OR l.type_id = 6":"")+((listTypeID.equals("2") && canSpecTest)?" OR l.type_id = 5 OR l.type_id = 7":"")+") " +
                    " AND cust_id = "+cust.s_cust_id+
                    " AND l.type_id = t.type_id " +
                    " AND list_name not like 'ApprovalRequest(%)' " +
                    " AND l.status_id = '" + EmailListStatus.ACTIVE +  "'" +
                    " ORDER BY list_name ASC";

    rs = stmt.executeQuery(sSql);

    String sClassAppend = "";
    int i = 0;

    while( rs.next() )
    {
      data = new JsonObject();
      if (i % 2 != 0)
      {
        sClassAppend = "_other";
        data.put("sClassAppend",sClassAppend);
      }
      else
      {
        sClassAppend = "";
        data.put("sClassAppend",sClassAppend);
      }
      i++;

      id = rs.getString(1);
      name = new String(rs.getBytes(2),"UTF-8");
      typeName = new String(rs.getBytes(3),"UTF-8");

      data.put("userId",id);
      data.put("name",name);
      data.put("typeName",typeName);

      listData.put(data);



    }
    rs.close();

    out.print(listData.toString());

  }catch(Exception ex) { throw ex; }
  finally
  {
    if (stmt != null) stmt.close();
    if (conn  != null) cp.free(conn);
  }
%>

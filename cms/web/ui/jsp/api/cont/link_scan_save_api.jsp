<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.util.*,java.sql.*,
			java.io.*,org.apache.log4j.*"
	
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

	if(!can.bWrite)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}

	String contID = request.getParameter("cont_id");
	String sNumLinks = request.getParameter("linkCount");
	int numLinks = Integer.parseInt(sNumLinks);

	// === === ===

	String sSql = "DELETE cjtk_link WHERE cont_id = " + contID;
	BriteUpdate.executeUpdate(sSql);
	
	ConnectionPool cp	= null;
	Connection conn		= null;
	JsonObject data= new JsonObject();
    JsonArray array= new JsonArray();

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("link_scan_save_api.jsp");

		String check = null;
		String linkName="";
		String hrefName="";
		String sNewLinkID="";
		int newLinkID = 0;
		
		sSql = "Exec usp_ccnt_link_insert_bytes " + contID + ",?,?," + cust.s_cust_id;
		
		for (int i=1;i<=numLinks;++i)
		{
			check = request.getParameter("check"+i);
			if (check == null) continue;

			linkName = request.getParameter("lname"+i);
			hrefName = request.getParameter("lhref"+i);

			PreparedStatement pstmt	= null;
			
			try
			{
				pstmt = conn.prepareStatement(sSql);
				pstmt.setBytes(1,linkName.getBytes("ISO-8859-1"));
				pstmt.setString(2,hrefName);
				pstmt.execute();
			}
			catch(Exception ex){ throw ex; }
			finally { if (pstmt != null) pstmt.close(); }
		}
		data.put("message", "link scan  saved successfully");
        array.put(data);
        out.print(array.toString());

	}
	catch(Exception ex) { throw ex; }
	finally { if (conn != null) cp.free(conn);}
%>
<%@ page
	language="java"
	import="com.britemoon.cps.imc.*,
			com.britemoon.cps.upd.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			java.io.*,java.util.*,
			java.sql.*,java.net.*,
			org.w3c.dom.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

String sAction = request.getParameter("action");
String sCustId = request.getParameter("cust_id");
String sImportId = request.getParameter("import_id");

String sOnStarCustId = Registry.getKey("onstar_import_cust_id");
String sOnStar2CustId = Registry.getKey("onstar2_import_cust_id");

// Connection
Statement			stmt = null;
ResultSet			rs = null; 
ConnectionPool		cp = null;
Connection			conn = null;

String sDetailXML = "";
String sMsg = "Commit not processed.";
try	{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("remote_import_action.jsp");
	stmt = conn.createStatement();

	int nImportId = Integer.parseInt(sImportId);

	int nCustId = Integer.parseInt(sCustId);
	int nOnStarCustId = -1;
	int nOnStar2CustId = -1;
	try {
		nOnStarCustId = Integer.parseInt(sOnStarCustId);
	} catch (Exception ignore) {}
	try {
		nOnStar2CustId = Integer.parseInt(sOnStar2CustId);
	} catch (Exception ignore) {}
	

	if ( (nCustId < 0) || ((nCustId != nOnStarCustId) && (nCustId != nOnStar2CustId)) ) throw new Exception ("Invalid Customer");
	if (!sAction.trim().equals("commit")) throw new Exception ("Invalid Request");

	int nStatusId = 0;
	rs = stmt.executeQuery ("SELECT status_id FROM cupd_import i, cupd_batch b"
			+ " WHERE i.batch_id = b.batch_id AND i.import_id = " + nImportId
			+ " AND b.cust_id = " + nCustId);
	if (rs.next()) nStatusId = rs.getInt(1);
	rs.close();
	
	if (nStatusId == ImportStatus.IN_STAGING)
	{
		ImportUtil.sendImportActionToRCP(sCustId, sImportId, sAction);

		stmt.executeUpdate("UPDATE cupd_import SET status_id = 40" //ImportStatus.READY_FOR_COMMIT
						+ " WHERE import_id = "+nImportId);
		sMsg = "Commit Request Received";
	}
	else if ((nStatusId > 0) && (nStatusId < ImportStatus.IN_STAGING))
	{
		sMsg = "Import processing not ready for commit, try again later.";
	}
	else if ((nStatusId > ImportStatus.IN_STAGING) && (nStatusId < ImportStatus.ERROR))
	{
		sMsg = "Commit already started.";
	}
	else if (nStatusId >= ImportStatus.ERROR)
	{
		sMsg = "Error in import processing, contact Revotas support.";
	}
	else
	{
		sMsg = "Problem processing request, contact Revotas support.";
	}
%>
<HTML>
<HEAD>
</HEAD>
<BODY>
<%=sMsg%>
</BODY>
</HTML>
<%
}
catch(Exception ex)
{ 
	ErrLog.put(this,ex,"Problem processing commit "+sDetailXML,out,1);
}
finally
{
	try { if ( stmt != null ) stmt.close(); }
	catch (SQLException ignore) { }
	if ( conn != null ) cp.free(conn); 
}
%>
</BODY></HTML>






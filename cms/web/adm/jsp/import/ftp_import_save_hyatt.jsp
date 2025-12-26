<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.upd.*, 
			java.io.*, 
			java.text.*, 
			java.sql.*, 
			java.util.*, 
			org.w3c.dom.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp"%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
String sTemplateId = BriteRequest.getParameter(request,"template_id");
String sHotelId = BriteRequest.getParameter(request,"hotel_id");

// === === ===

ConnectionPool cp = null;
Connection conn = null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("ftp_import_save_hyatt.jsp");
	conn.setAutoCommit(false);
		
	// === === ==

	String sBatchId = BriteRequest.getParameter(request,"batch_id");
	
	if( sBatchId == null )
	{
		Batch b = new Batch();
		
		b.s_batch_id = BriteRequest.getParameter(request,"batch_id");		
		b.s_type_id = BriteRequest.getParameter(request,"batch_type_id");
		if(	b.s_type_id == null ) b.s_type_id = "1";
		b.s_cust_id = BriteRequest.getParameter(request,"cust_id");
		b.s_batch_name = BriteRequest.getParameter(request,"batch_name");
		b.s_descrip = BriteRequest.getParameter(request,"descrip");
		
		b.save(conn);		
		
		sBatchId = b.s_batch_id;
	}

	// === === ==

	String sSql =
		" UPDATE cupd_import_template_hyatt" +
		" SET batch_id=" + sBatchId +
		" WHERE template_id=" + sTemplateId +
		" AND hotel_id='" + sHotelId + "'";
		
	int nUpdated = BriteUpdate.executeUpdate(sSql, conn);
	
	if(nUpdated < 1)
	{
		sSql =
			" INSERT cupd_import_template_hyatt(template_id, hotel_id, batch_id)" +
			" VALUES" +
			"("  + sTemplateId +
			",'" + sHotelId + "'" +
			","  + sBatchId + ")";
		
		BriteUpdate.executeUpdate(sSql, conn);
	}
	
	// === === ===

	sSql =
		" DELETE cupd_import_template_attr_hyatt" +
		" WHERE template_id=" + sTemplateId +
		" AND hotel_id='" + sHotelId + "'";
		
	BriteUpdate.executeUpdate(sSql, conn);
	
	// === === ===
		
	String[] sFtpImportMappings = BriteRequest.getParameterValues(request,"ftp_import_mappings");
	
	if(sFtpImportMappings != null)
	{
		for(int i=0; i < sFtpImportMappings.length; i++)
		{
			sSql =
				" INSERT cupd_import_template_attr_hyatt(template_id, hotel_id, attr_id, seq)" +
				" VALUES" +
				"("  + sTemplateId +
				",'" + sHotelId + "'" +
				","  + sFtpImportMappings[i] +
				","  + String.valueOf(i) + ")";
		
			BriteUpdate.executeUpdate(sSql, conn);
		}
	}
	
	// === === ===
		
	conn.commit();
}
catch (Exception ex)
{
	try { conn.rollback(); }
	catch(Exception exx) 
	{ 
		logger.error("Exception: ",exx);
	}
	throw ex;
}
finally
{
	if (conn!=null)
	{
		conn.setAutoCommit(true);
		cp.free(conn);
	}
}
%>
<%@ include file="../header.jsp"%>
<HTML>
<HEAD>
<title>FTP Imports</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>
<BODY>
<BR><BR>
<A href="ftp_import_edit_hyatt.jsp?template_id=<%=sTemplateId%>&hotel_id=<%=sHotelId%>">Edit saved Hyatt Ftp Import</A>
<BR><BR>
<A href="ftp_import_list_hyatt.jsp">Hyatt Ftp Import List</A>
</BODY>
</HTML>
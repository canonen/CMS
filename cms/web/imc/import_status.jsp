<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.ntt.*,
			com.britemoon.cps.upd.*,
			java.util.*,
			java.sql.*,
			java.net.*,
			org.w3c.dom.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<%@ include file="header.jsp" %>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
try
{
	Element eRootElement = XmlUtil.getRootElement(request);
	String sRootElementName = eRootElement.getNodeName();
	
	if("import_status".equals(sRootElementName))
	{
		processRecipImportStatusXml(eRootElement);
	}
	else if("entity_import".equals(sRootElementName))
	{
		processEntityImportStatusXml(eRootElement);
	}
	else
	{
		throw new Exception("Malformed import_status xml.");
	}
}
catch(Throwable t)
{
	logger.error("Exception: ", t);
}
%>
<%!
private static void processEntityImportStatusXml(Element e) throws Exception
{
	EntityImport ei = new EntityImport(e);

	String sSql =
		" UPDATE cntt_entity_import" +
		" SET status_id = "	+ ei.s_status_id +
		" WHERE import_id = " + ei.s_import_id;

	BriteUpdate.executeUpdate(sSql);

	if(ei.m_EntityImportStatistics != null)
	{
		ei.m_EntityImportStatistics.save();
	}
}

private static void processRecipImportStatusXml(Element e) throws Exception
{
	Statement		stmt = null;
	ConnectionPool	cp = null;
	Connection		conn = null;

	String sSQL = null;
	String sVal = null;

	String sImportID = null;
	String sStatusID = null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("import_status.jsp");
		stmt = conn.createStatement();
		
		sImportID = XmlUtil.getChildTextValue(e, "import_id");
		if (sImportID == null)
			throw new Exception("No import_id");

		sStatusID = XmlUtil.getChildTextValue(e, "status_id");
		if (sStatusID != null)
		{
			sSQL = "UPDATE cupd_import SET status_id = "+sStatusID+" WHERE import_id = "+sImportID;
			stmt.executeUpdate(sSQL);
		}

		String sSqlSetParams = "";

		// === preprocessing stats ===

		sVal =  XmlUtil.getChildTextValue(e, "tot_rows");
		if (sVal != null) sSqlSetParams += ((sSqlSetParams.length() > 0)?",":"")+"tot_rows = "+sVal;

		sVal =  XmlUtil.getChildTextValue(e, "bad_rows");
		if (sVal != null) sSqlSetParams += ((sSqlSetParams.length() > 0)?",":"")+"bad_rows = "+sVal;

		sVal =  XmlUtil.getChildTextValue(e, "tot_file_recips");
		if (sVal != null) sSqlSetParams += ((sSqlSetParams.length() > 0)?",":"")+"tot_file_recips = "+sVal;

		sVal =  XmlUtil.getChildTextValue(e, "warning_recips");
		if (sVal != null) sSqlSetParams += ((sSqlSetParams.length() > 0)?",":"")+"warning_recips = "+sVal;

		// === staging stats ===
		
		sVal =  XmlUtil.getChildTextValue(e, "tot_recips");
		if (sVal != null) sSqlSetParams += ((sSqlSetParams.length() > 0)?",":"")+"tot_recips = "+sVal;

		sVal =  XmlUtil.getChildTextValue(e, "file_dups");
		if (sVal != null) sSqlSetParams += ((sSqlSetParams.length() > 0)?",":"")+"file_dups = "+sVal;

		sVal =  XmlUtil.getChildTextValue(e, "bad_emails");
		if (sVal != null) sSqlSetParams += ((sSqlSetParams.length() > 0)?",":"")+"bad_emails = "+sVal;

		sVal =  XmlUtil.getChildTextValue(e, "bad_fingerprints");
		if (sVal != null) sSqlSetParams += ((sSqlSetParams.length() > 0)?",":"")+"bad_fingerprints = "+sVal;

		// === commit stats ===

		sVal =  XmlUtil.getChildTextValue(e, "new_recips");
		if (sVal != null) sSqlSetParams += ((sSqlSetParams.length() > 0)?",":"")+"new_recips = "+sVal;

		sVal =  XmlUtil.getChildTextValue(e, "dup_recips");
		if (sVal != null) sSqlSetParams += ((sSqlSetParams.length() > 0)?",":"")+"dup_recips = "+sVal;

		sVal =  XmlUtil.getChildTextValue(e, "num_committed");
		if (sVal != null) sSqlSetParams += ((sSqlSetParams.length() > 0)?",":"")+"num_committed = "+sVal;

		sVal =  XmlUtil.getChildTextValue(e, "left_to_commit");
		if (sVal != null) sSqlSetParams += ((sSqlSetParams.length() > 0)?",":"")+"left_to_commit = "+sVal;

		// === === ===

		sVal =  XmlUtil.getChildCDataValue(e, "error");
		if (sVal != null)
		{
			sVal = sVal.replaceAll("'","''");
			sSqlSetParams += ((sSqlSetParams.length() > 0)?",":"")+"error_message = '"+ sVal +"'";
		}

		if (sSqlSetParams.length() > 0)
		{
			sSQL = "SELECT count(*) FROM cupd_import_statistics WHERE import_id = "+sImportID;
			ResultSet rs = stmt.executeQuery(sSQL);
			if ((rs.next())&&(rs.getInt(1) < 1))
			{
				rs.close();
				sSQL = "INSERT cupd_import_statistics (import_id) VALUES ("+sImportID+")";
				stmt.executeUpdate(sSQL);
			}
			else rs.close();
			
			sSQL = "UPDATE cupd_import_statistics SET "+sSqlSetParams+" WHERE import_id = "+sImportID;
			stmt.executeUpdate(sSQL);
		}
	}
	catch (Exception ex) 
	{ 
		logger.error("Exception: ",ex);
	}
	finally
	{
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}
}
%>

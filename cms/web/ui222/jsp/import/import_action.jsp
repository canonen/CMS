<%@ page
	language="java"
	import="com.britemoon.cps.upd.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			java.io.*,java.util.*,
			java.sql.*,java.net.*,
			org.w3c.dom.*,org.apache.log4j.*"
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

AccessPermission can = user.getAccessPermission(ObjectType.IMPORT);
AccessPermission canFilter = user.getAccessPermission(ObjectType.FILTER);

String sSelectedCategoryId = request.getParameter("category_id");

String sAction = request.getParameter("mode");

if((sAction.trim().equals("delete") && !can.bDelete) || (!sAction.trim().equals("delete") && !can.bExecute))
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

// Connection
Statement			stmt = null;
ResultSet			rs = null; 
ConnectionPool		cp = null;
Connection			conn = null;
Connection			conn2 = null;
PreparedStatement	pstmt = null;

String sSQL = null;
	
try
{
	String sImportID = request.getParameter("import_id");
	int nImportID = Integer.parseInt(sImportID);

	String sFilterFlag = request.getParameter("filter");
	boolean bCreateFilter = canFilter.bWrite;
	bCreateFilter = (sFilterFlag!=null?(bCreateFilter && (sFilterFlag.trim().equals("1"))):false);

	// === === ===
	
	ImportUtil.sendImportActionToRCP(cust.s_cust_id, sImportID, sAction);

	// === === ===
	
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("import_action.jsp");
	stmt = conn.createStatement();

	if (sAction.trim().equals("commit"))
	{
		sSQL = 
			" UPDATE cupd_import SET status_id = 40" + //ImportStatus.READY_FOR_COMMIT
			" WHERE import_id = " + nImportID;
		stmt.executeUpdate(sSQL);
	}
	else if (sAction.trim().equals("rollback"))
	{
		sSQL = 	
			" SELECT i.batch_id" +
			" FROM cupd_import i, cupd_batch b" +
			" WHERE i.batch_id = b.batch_id" +
			" AND i.import_id = " + nImportID +
			" AND b.cust_id = " + cust.s_cust_id;
					
		rs = stmt.executeQuery(sSQL);
		
		int nBatchID = 0;
		if (rs.next()) nBatchID = rs.getInt(1);
		rs.close();

		if (nBatchID > 0)
		{
			conn.setAutoCommit(false);
			stmt.executeUpdate("DELETE cupd_fields_mapping WHERE import_id = "+nImportID);
			stmt.executeUpdate("DELETE cupd_import_newsletter WHERE import_id = "+nImportID);
			stmt.executeUpdate("DELETE cupd_import_statistics WHERE import_id = "+nImportID);
			stmt.executeUpdate("UPDATE cftp_ftp_file_assignments SET recip_import_id = null WHERE recip_import_id = "+nImportID);
			stmt.executeUpdate("DELETE cupd_import WHERE import_id = "+nImportID);

			// === === ===
			
			int nCount = 0;
			
			sSQL = "SELECT count(*) FROM cupd_import WHERE batch_id = " + nBatchID;
			rs = stmt.executeQuery(sSQL);
			if (rs.next()) nCount += rs.getInt(1);
			rs.close();

			sSQL = "SELECT count(*) FROM cupd_import_template WHERE batch_id = " + nBatchID;
			rs = stmt.executeQuery(sSQL);
			if (rs.next()) nCount += rs.getInt(1);
			rs.close();

			if (nCount < 1)
			{
				// No imports for that batch - delete it
				stmt.executeUpdate("DELETE cupd_batch WHERE batch_id = "+nBatchID);
			}
			conn.commit();
		}
	}
	else if (sAction.trim().equals("delete"))
	{
		sSQL = 
			" SELECT i.batch_id FROM cupd_import i, cupd_batch b" +
			" WHERE i.batch_id = b.batch_id" +
			" AND i.import_id = " + nImportID +
			" AND b.cust_id = "+cust.s_cust_id;
			
		rs = stmt.executeQuery(sSQL);
		int nBatchID = 0;
		if (rs.next()) nBatchID = rs.getInt(1);
		rs.close();

		if (nBatchID > 0)
		{
			conn.setAutoCommit(false);
			
			sSQL =
				" UPDATE cupd_import SET status_id = " + ImportStatus.DELETED +
				" WHERE import_id = " + nImportID;
			stmt.executeUpdate(sSQL);

			// === === ===

			int nCount = 0;

			sSQL =
				" SELECT count(*) FROM cupd_import" +
				" WHERE batch_id = " + nBatchID +
				" AND status_id < " + ImportStatus.DELETED;

			rs = stmt.executeQuery(sSQL);
			if (rs.next()) nCount += rs.getInt(1);
			rs.close();
			
			sSQL =
				" SELECT count(*) FROM cupd_import_template" +
				" WHERE batch_id = " + nBatchID;
			
			rs = stmt.executeQuery(sSQL);
			if (rs.next()) nCount += rs.getInt(1);
			rs.close();
			
			if (nCount < 1)
			{
				// No imports for that batch - delete it
				sSQL =
					" UPDATE cupd_batch SET type_id = -1" + //BatchType.deleted
					" WHERE batch_id = " + nBatchID;
					
				stmt.executeUpdate(sSQL);
			}
			
			// === === ===
			
			conn.commit();
		}
	}

	boolean bFilterComplete = false;
	if (bCreateFilter)
	{
		try
		{
			conn2 = cp.getConnection("import_action.jsp 2");
			
			sSQL =
				" SELECT import_name FROM cupd_import" +
				" WHERE import_id = " + nImportID;
				
			String sImportName = "Import";
			
			rs = stmt.executeQuery(sSQL);
			if (rs.next()) sImportName = rs.getString(1);
			rs.close();
			
			com.britemoon.cps.tgt.Filter parentFilter =
				FilterUtil.createIpmortFilter(cust.s_cust_id, String.valueOf(nImportID), sImportName);

			sSQL =
				" INSERT ctgt_preview_attr (filter_id, attr_id, display_seq)" +
				" SELECT " + parentFilter.s_filter_id + ", attr_id, max(seq)" +
				" FROM cupd_fields_mapping WHERE import_id = " + nImportID +
				" AND attr_id > 0" +
				" GROUP BY attr_id";
			stmt.executeUpdate (sSQL);
			
			sSQL =
				" SELECT category_id FROM ccps_object_category" +
				" WHERE cust_id = " + cust.s_cust_id +
				" AND object_id = " + nImportID +
				" AND type_id = " + ObjectType.IMPORT;
				
			rs = stmt.executeQuery(sSQL);
			while (rs.next())
			{
				sSQL =
					" INSERT ccps_object_category (cust_id,  object_id, type_id, category_id)" +
					" VALUES (?, ?, ?, ?)";

				try
				{
					pstmt = conn2.prepareStatement(sSQL);

					pstmt.setString(1, cust.s_cust_id);
					pstmt.setString(2, parentFilter.s_filter_id);
					pstmt.setString(3, String.valueOf(ObjectType.FILTER));
					pstmt.setString(4, rs.getString(1));

					pstmt.executeUpdate();
				}
				catch(Exception ex) { throw ex; }
				finally { pstmt.close(); }
			}
			rs.close();
			
			bFilterComplete = true;
		}
		catch (Exception ex2)
		{
			logger.error("Problem Creating Filter",ex2);
		}
	}
%>
<HTML>
<HEAD>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>
<BODY>
<!--- Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader><b class=sectionheader>Import:</b> Request Sent</td>
	</tr>
</table>
<br>
<!---- Info----->
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
						<p align="center"><b>Request Sent<%=((bCreateFilter)?"<BR>"+((bFilterComplete)?"Target group created.":"<FONT color=red>Problem creating Target group!</FONT>"):"")%></b></p>
						<p align="center"><a href="import_list.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">Back to List</a></p>
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
<%
}
catch(Exception ex)
{ 
	if (stmt != null) stmt.execute ("If @@TranCount>0 ROLLBACK TRANSACTION");
	logger.error("Exception: ",ex);
}
finally
{
	try { if ( stmt != null ) stmt.close(); }
	catch (Exception ignore) { }

	if ( conn != null ) {
            conn.setAutoCommit(true);
            cp.free(conn);
        } 
	if ( conn2 != null ) cp.free(conn2); 
}
%>
</BODY></HTML>






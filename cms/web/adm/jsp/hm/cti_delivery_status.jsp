<%@ page language="java"
	import="java.net.*, java.io.*,
			java.util.*,java.sql.*,
			java.net.*,com.britemoon.*,
			com.britemoon.cps.*,org.apache.log4j.*" 
	contentType="text/html;charset=UTF-8" %>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="/cms/adm/css/style.css" TYPE="text/css">
</HEAD>
<BODY>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

String val = null;	
int nMaxMinsForReceived = 60;
val = Registry.getKey("hmon_cti_delivery_max_minutes_for_received");
if (val != null) {
	try  { nMaxMinsForReceived = Integer.parseInt(val); }
	catch (Exception ex) {}
}

int nMaxHoursForCompleted = 48;
val = Registry.getKey("hmon_cti_delivery_max_hours_for_completed");
if (val!=null) {
	try  { nMaxHoursForCompleted = Integer.parseInt(val); }
	catch (Exception ex) {}
}

String sCustId = null;
String sCampName = null;
String sCampId = null;
String sChunkId = null;
String sOrderId = null;
String sCreateDate = null;
String sSubmitDate = null;
String sConfirmDate = null;
String sZipFileName = null;
String sFileName = null;
String sStatus = null;
String sCampQty = null;
String sFileUrl = null;
String sRecipQty = null;

ConnectionPool cp = null;
Connection conn = null;
Statement stmt = null;
ResultSet rs = null;
String sSql =  null;
boolean noError = true;

out.println("<H2>CTI Order Delivery Monitor (status: 3=received, 4=processed, 5=printed 6=shipped, 7=completed)</H2>");	
try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("cti_delivery_status.jsp");
	stmt = conn.createStatement();
	
	/* update recip_qty */
	boolean hasMore = false;
	do {
		hasMore = false;
		sSql =
			"SELECT TOP 1 c.cust_id, d.camp_id, d.chunk_id, f.file_url " +
			"  FROM cxcs_delivery d WITH(NOLOCK), " +
			"       cque_campaign c WITH(NOLOCK), " +
			"       cexp_export_file f WITH(NOLOCK) " +
			" WHERE d.zip_file_name IS NOT NULL " +
			"   AND d.recip_qty IS NULL " +
			"   AND d.camp_id = c.camp_id " +
			"   AND d.file_id = f.file_id " +
			"   AND f.status_id = " + ExportStatus.COMPLETE;
		rs = stmt.executeQuery(sSql);
		if (rs.next()) {
			sCustId = rs.getString(1);
			sCampId = rs.getString(2);
			sChunkId = rs.getString(3);
			sFileUrl = rs.getString(4);
			hasMore = true;
		}
		rs.close();
		if (hasMore) {
			sRecipQty = "-1";
			String deliveryDir = Registry.getKey("cti_delivery_dir");
			String dirName = deliveryDir + "\\" + sCustId;	
			String fileName = dirName + "\\" + sFileUrl.substring(sFileUrl.lastIndexOf('/'));
			System.out.println("processing file : " + fileName);
			BufferedReader in = null;
			try {
				FileReader fileReader = new FileReader(fileName);
				in = new BufferedReader(fileReader);
				String line = in.readLine();
				sRecipQty = line.substring(line.lastIndexOf(':')+1);
				sRecipQty = sRecipQty.trim();
				System.out.println(" recip_qty = " + sRecipQty);
			}
			catch (IOException ioe) {
				System.out.println("problem processing file : " + fileName);
			}
			finally {
				if (in != null) {
					try {
						in.close();
					}
					catch (IOException ioe) {
						ioe.printStackTrace();
					}
				}
			}
			BriteUpdate.executeUpdate("UPDATE cxcs_delivery SET recip_qty = " + sRecipQty + 
					                  " WHERE camp_id = " + sCampId + " AND chunk_id = " + sChunkId);
		}
	}
	while (hasMore);		
	
	/* campaign error due to CTI WS during setup */
	sSql =
		"SELECT c.cust_id, c.camp_name, d.camp_id, d.chunk_id, d.create_date, d.zip_file_name, d.submit_date, d.order_id, q.recip_queued_qty, d.recip_qty " +
		"  FROM cxcs_delivery d WITH(NOLOCK), " +
		"       cque_campaign c WITH(NOLOCK), " +
		"       cexp_export_file f WITH(NOLOCK), " +
		"       cque_schedule s WITH(NOLOCK), " +
		"       cque_camp_statistic q WITH(NOLOCK) " +
		" WHERE d.submit_date IS NULL " +
		"   AND DATEDIFF(hh, d.create_date, getdate()) < 168 " +
		"   AND d.order_id IS NULL " +
		"   AND d.camp_id = c.camp_id " +
		"   AND c.status_id = " + CampaignStatus.ERROR +
		"   AND d.camp_id = s.camp_id " +
		"   AND ISNULL(s.start_date, getdate()) <= getdate() " +
		"   AND d.file_id = f.file_id " +
		"   AND f.status_id = " + ExportStatus.COMPLETE +
		"   AND d.camp_id = q.camp_id " +
		" ORDER BY d.camp_id";
	rs = stmt.executeQuery(sSql);
	if (rs.next()) {
		noError = false;
		out.println("<BR><H3>Campaign error due to CTI WS during setup within past 7 days, you can fix these orders safely:</H3><BR>");
		out.println("SQL:<BR>" + sSql + "<BR>");
		out.println("<TABLE border=1 cellpadding=1 cellspacing=0>");
		out.println("  <TR>");
		out.println("    <TH>Attention</TH>");
		out.println("    <TH>Cust ID</TH>");
		out.println("    <TH>Camp Name</TH>");
		out.println("    <TH>Camp ID</TH>");
		out.println("    <TH>Camp Qty</TH>");
		out.println("    <TH>Order Qty</TH>");
		out.println("    <TH>Create Date</TH>");
		out.println("    <TH>Zip File Name</TH>");
		out.println("    <TH>Submit Date</TH>");		
		out.println("    <TH>Order ID</TH>");
		out.println("    <TH>Action</TH>");
		out.println("  </TR>");
	    do {
			sCustId = rs.getString(1);
			sCampName = rs.getString(2);
			sCampId = rs.getString(3);
			sChunkId = rs.getString(4);
			sCreateDate = rs.getString(5);
			sZipFileName = rs.getString(6);
			sSubmitDate = rs.getString(7);
			sOrderId = rs.getString(8);
			sCampQty = rs.getString(9);
			sRecipQty = rs.getString(10);
			sFileName = sZipFileName;
			if (sZipFileName != null)
			{
				int n = sZipFileName.lastIndexOf("\\");
				sFileName = sZipFileName.substring(n+1);
			}
			out.println("  <TR>");
			out.println("    <TD>ALERT</TD>");
			out.println("    <TD>" + sCustId + "</TD>");
			out.println("    <TD>" + sCampName + "</TD>");
			out.println("    <TD>" + sCampId + "</TD>");
			out.println("    <TD>" + sCampQty + "</TD>");
			out.println("    <TD>" + sRecipQty + "</TD>");
			out.println("    <TD>" + sCreateDate + "</TD>");
			out.println("    <TD>" + sFileName + "</TD>");
			out.println("    <TD>" + sSubmitDate + "</TD>");
			out.println("    <TD>" + sOrderId + "</TD>");
			out.println("    <TD><A class=\"button\" href=\"../STIP/admin_fix_camp.jsp?cust_id=" + sCustId + "&camp_id=" + sCampId + "&chunk_id=" + sChunkId + "\">fix</A></TD>");
			out.println("  </TR>");
		} while (rs.next());
		out.println("</TABLE>");
	}
	rs.close();
	
	
	/* submission failures */
	sSql =
		"SELECT c.cust_id, c.camp_name, d.camp_id, d.chunk_id, d.create_date, d.zip_file_name, d.submit_date, d.order_id, q.recip_queued_qty, d.recip_qty  " +
		"  FROM cxcs_delivery d WITH(NOLOCK), " +
		"       cque_campaign c WITH(NOLOCK), " +
		"       cexp_export_file f WITH(NOLOCK), " +
		"       cque_schedule s WITH(NOLOCK), " +
		"       cque_camp_statistic q WITH(NOLOCK) " +
		" WHERE d.submit_date IS NOT NULL " +
		"   AND (d.order_id IS NULL OR d.order_id = '') " +
		"   AND d.camp_id = c.camp_id " +
		"   AND c.status_id = " + CampaignStatus.BEING_PROCESSED +
		"   AND d.camp_id = s.camp_id " +
		"   AND ISNULL(s.start_date, getdate()) <= getdate() " +
		"   AND d.file_id = f.file_id " +
		"   AND f.status_id = " + ExportStatus.COMPLETE +
		"   AND d.camp_id = q.camp_id " +
		" ORDER BY d.camp_id";
	rs = stmt.executeQuery(sSql);
	if (rs.next()) {
		noError = false;
		out.println("<BR><H3>Order submission failed, you can re-submit these orders safely:</H3><BR>");
		out.println("SQL:<BR>" + sSql + "<BR>");
		out.println("<TABLE border=1 cellpadding=1 cellspacing=0>");
		out.println("  <TR>");
		out.println("    <TH>Attention</TH>");
		out.println("    <TH>Cust ID</TH>");
		out.println("    <TH>Camp Name</TH>");
		out.println("    <TH>Camp ID</TH>");
		out.println("    <TH>Camp Qty</TH>");
		out.println("    <TH>Order Qty</TH>");
		out.println("    <TH>Create Date</TH>");
		out.println("    <TH>Zip File Name</TH>");
		out.println("    <TH>Submit Date</TH>");		
		out.println("    <TH>Order ID</TH>");
		out.println("    <TH>Action</TH>");
		out.println("  </TR>");
	    do {
			sCustId = rs.getString(1);
			sCampName = rs.getString(2);
			sCampId = rs.getString(3);
			sChunkId = rs.getString(4);
			sCreateDate = rs.getString(5);
			sZipFileName = rs.getString(6);
			sSubmitDate = rs.getString(7);
			sOrderId = rs.getString(8);
			sCampQty = rs.getString(9);
			sRecipQty = rs.getString(10);
			sFileName = sZipFileName;
			if (sZipFileName != null)
			{
				int n = sZipFileName.lastIndexOf("\\");
				sFileName = sZipFileName.substring(n+1);
			}
			out.println("  <TR>");
			out.println("    <TD>ALERT</TD>");
			out.println("    <TD>" + sCustId + "</TD>");
			out.println("    <TD>" + sCampName + "</TD>");
			out.println("    <TD>" + sCampId + "</TD>");
			out.println("    <TD>" + sCampQty + "</TD>");
			out.println("    <TD>" + sRecipQty + "</TD>");
			out.println("    <TD>" + sCreateDate + "</TD>");
			out.println("    <TD>" + sFileName + "</TD>");
			out.println("    <TD>" + sSubmitDate + "</TD>");
			out.println("    <TD>" + sOrderId + "</TD>");
			out.println("    <TD><A class=\"button\" href=\"../STIP/admin_submit_and_update_order.jsp?cust_id=" + sCustId + "&camp_id=" + sCampId + "&chunk_id=" + sChunkId + "&file_name=" + URLEncoder.encode(sZipFileName,"UTF-8") + "\">re-submit</A></TD>");
			out.println("  </TR>");
		} while (rs.next());
		out.println("</TABLE>");
	}
	rs.close();

	/* submission successful, haven't received status 'received' */
	sSql =
		"SELECT c.cust_id, c.camp_name, d.camp_id, d.submit_date, d.order_id, d.confirm_date, d.status, q.recip_queued_qty, d.recip_qty  " +
		"  FROM cxcs_delivery d WITH(NOLOCK), " +
		"       cque_campaign c WITH(NOLOCK), " +
		"       cexp_export_file f WITH(NOLOCK), " +
		"       cque_schedule s WITH(NOLOCK)," +
		"       cque_camp_statistic q WITH(NOLOCK) " +
		" WHERE d.submit_date IS NOT NULL " +
		"   AND (d.order_id IS NOT NULL AND d.order_id != '') " +
		"   AND d.confirm_date IS NULL " +
		"   AND d.status = 1 " +
		"   AND DATEDIFF(mi, d.submit_date, getdate()) > " + nMaxMinsForReceived +
		"   AND d.camp_id = c.camp_id " +
		"   AND c.status_id = " + CampaignStatus.BEING_PROCESSED +
		"   AND d.camp_id = s.camp_id " +
		"   AND ISNULL(s.start_date, getdate()) <= getdate()" +
		"   AND d.file_id = f.file_id " +
		"   AND f.status_id = " + ExportStatus.COMPLETE +
		"   AND d.camp_id = q.camp_id " +
		" ORDER BY d.camp_id";
	rs = stmt.executeQuery(sSql);
	if (rs.next()) {
		noError = false;
		out.println("<BR><H3>Order submitted but not 'received' within " + nMaxMinsForReceived+ " minutes, please contact CTI</H3><BR>");
		out.println("SQL:<BR>" + sSql + "<BR>");
		out.println("<TABLE border=1 cellpadding=1 cellspacing=0>");
		out.println("  <TR>");
		out.println("    <TH>Attention</TH>");
		out.println("    <TH>Cust ID</TH>");
		out.println("    <TH>Camp Name</TH>");
		out.println("    <TH>Camp ID</TH>");
		out.println("    <TH>Camp Qty</TH>");
		out.println("    <TH>Order Qty</TH>");
		out.println("    <TH>Submit Date</TH>");		
		out.println("    <TH>Order ID</TH>");
		out.println("    <TH>Confirm Date</TH>");		
		out.println("    <TH>Status</TH>");
		out.println("  </TR>");
	    do {
			sCustId = rs.getString(1);
			sCampName = rs.getString(2);
			sCampId = rs.getString(3);
			sSubmitDate = rs.getString(4);
			sOrderId = rs.getString(5);
			sConfirmDate = rs.getString(6);
			sStatus = rs.getString(7);
			sCampQty = rs.getString(8);
			sRecipQty = rs.getString(9);
			out.println("  <TR>");
			out.println("    <TD>ALERT</TD>");
			out.println("    <TD>" + sCustId + "</TD>");
			out.println("    <TD>" + sCampName + "</TD>");
			out.println("    <TD>" + sCampId + "</TD>");
			out.println("    <TD>" + sCampQty + "</TD>");
			out.println("    <TD>" + sRecipQty + "</TD>");
			out.println("    <TD>" + sSubmitDate + "</TD>");
			out.println("    <TD>" + sOrderId + "</TD>");
			out.println("    <TD>" + sConfirmDate + "</TD>");
			out.println("    <TD>" + sStatus + "</TD>");
			out.println("  </TR>");
		} while (rs.next());
		out.println("</TABLE>");
	}
	rs.close();

	/* submission successful, haven't received status 'processed', 'printed', 'shipped' or 'completed') */
	sSql =
		"SELECT c.cust_id, c.camp_name, d.camp_id, d.submit_date, d.order_id, d.confirm_date, d.status, q.recip_queued_qty, d.recip_qty " +
		"  FROM cxcs_delivery d WITH(NOLOCK), " +
		"       cque_campaign c WITH(NOLOCK), " +
		"       cexp_export_file f WITH(NOLOCK), " +
		"       cque_schedule s WITH(NOLOCK)," +
		"       cque_camp_statistic q WITH(NOLOCK) " +
		" WHERE d.submit_date IS NOT NULL " +
		"   AND d.confirm_date IS NOT NULL " +
		"   AND d.status not in (4,5,6,7) " +
		"   AND DATEDIFF(hh, d.submit_date, getdate()) > " + nMaxHoursForCompleted +
		"   AND d.camp_id = c.camp_id " +
		"   AND c.status_id = " + CampaignStatus.BEING_PROCESSED +
		"   AND d.camp_id = s.camp_id " +
		"   AND ISNULL(s.start_date, getdate()) <= getdate()" +
		"   AND d.file_id = f.file_id " +
		"   AND f.status_id = " + ExportStatus.COMPLETE +
		"   AND d.camp_id = q.camp_id " +
		" ORDER BY d.camp_id";
	rs = stmt.executeQuery(sSql);
	if (rs.next()) {
		noError = false;
		out.println("<BR><H3>Submission received but not 'printed', 'shipped' or 'completed' within " + nMaxHoursForCompleted + " hours, please contact CTI</H3><BR>");
		out.println("SQL:<BR>" + sSql + "<BR>");
		out.println("<TABLE border=1 cellpadding=1 cellspacing=0>");
		out.println("  <TR>");
		out.println("    <TH>Attention</TH>");
		out.println("    <TH>Cust ID</TH>");
		out.println("    <TH>Camp Name</TH>");
		out.println("    <TH>Camp ID</TH>");
		out.println("    <TH>Camp Qty</TH>");
		out.println("    <TH>Order Qty</TH>");
		out.println("    <TH>Submit Date</TH>");		
		out.println("    <TH>Order ID</TH>");
		out.println("    <TH>Confirm Date</TH>");		
		out.println("    <TH>Status</TH>");
		out.println("  </TR>");
	    do {
			sCustId = rs.getString(1);
			sCampName = rs.getString(2);
			sCampId = rs.getString(3);
			sSubmitDate = rs.getString(4);
			sOrderId = rs.getString(5);
			sConfirmDate = rs.getString(6);
			sStatus = rs.getString(7);
			sCampQty = rs.getString(8);
			sRecipQty = rs.getString(9);
			out.println("  <TR>");
			out.println("    <TD>ALERT</TD>");
			out.println("    <TD>" + sCustId + "</TD>");
			out.println("    <TD>" + sCampName + "</TD>");
			out.println("    <TD>" + sCampId + "</TD>");
			out.println("    <TD>" + sCampQty + "</TD>");
			out.println("    <TD>" + sRecipQty + "</TD>");
			out.println("    <TD>" + sSubmitDate + "</TD>");
			out.println("    <TD>" + sOrderId + "</TD>");
			out.println("    <TD>" + sConfirmDate + "</TD>");
			out.println("    <TD>" + sStatus + "</TD>");
			out.println("  </TR>");
		} while (rs.next());
		out.println("</TABLE>");
	}
	rs.close();
	
	if (noError)
	{
		out.println("<BR><H3>There is no error found at this moment</H3><BR>");
	}
	
	
	/* delivery history */
	sSql =
		"SELECT c.cust_id, c.camp_name, d.camp_id, d.create_date, d.submit_date, d.order_id, d.confirm_date, d.status, q.recip_queued_qty, d.recip_qty " +
		"  FROM cxcs_delivery d WITH(NOLOCK), " +
		"       cque_campaign c WITH(NOLOCK), " +
		"       cexp_export_file f WITH(NOLOCK), " +
		"       cque_schedule s WITH(NOLOCK)," +
		"       cque_camp_statistic q WITH(NOLOCK) " +
		" WHERE DATEDIFF(dd, d.create_date, getdate()) < 60 " +
		"   AND d.camp_id = c.camp_id " +
		"   AND c.status_id = " + CampaignStatus.BEING_PROCESSED +
		"   AND d.camp_id = s.camp_id " +
		"   AND ISNULL(s.start_date, getdate()) <= getdate()" +
		"   AND d.file_id = f.file_id " +
		"   AND f.status_id = " + ExportStatus.COMPLETE +
		"   AND d.camp_id = q.camp_id " +
		" ORDER BY d.create_date desc";
	rs = stmt.executeQuery(sSql);
	if (rs.next()) {
		noError = false;
		out.println("<BR><H3>History of all orders created within the last 60 days</H3><BR>");
		out.println("SQL:<BR>" + sSql + "<BR>");
		out.println("<TABLE border=1 cellpadding=1 cellspacing=0>");
		out.println("  <TR>");
		out.println("    <TH>Cust ID</TH>");
		out.println("    <TH>Camp Name</TH>");
		out.println("    <TH>Camp ID</TH>");
		out.println("    <TH>Camp Qty</TH>");
		out.println("    <TH>Order Qty</TH>");
		out.println("    <TH>Create Date</TH>");	
		out.println("    <TH>Submit Date</TH>");		
		out.println("    <TH>Order ID</TH>");
		out.println("    <TH>Confirm Date</TH>");		
		out.println("    <TH>Status</TH>");
		out.println("  </TR>");
	    do {
			sCustId = rs.getString(1);
			sCampName = rs.getString(2);
			sCampId = rs.getString(3);
			sCreateDate = rs.getString(4);
			sSubmitDate = rs.getString(5);
			sOrderId = rs.getString(6);
			sConfirmDate = rs.getString(7);
			sStatus = rs.getString(8);
			sCampQty = rs.getString(9);
			sRecipQty = rs.getString(10);
			out.println("  <TR>");
			out.println("    <TD>" + sCustId + "</TD>");
			out.println("    <TD>" + sCampName + "</TD>");
			out.println("    <TD>" + sCampId + "</TD>");
			out.println("    <TD>" + sCampQty + "</TD>");
			out.println("    <TD>" + sRecipQty + "</TD>");
			out.println("    <TD>" + sCreateDate + "</TD>");
			out.println("    <TD>" + sSubmitDate + "</TD>");
			out.println("    <TD>" + sOrderId + "</TD>");
			out.println("    <TD>" + sConfirmDate + "</TD>");
			out.println("    <TD>" + sStatus + "</TD>");
			out.println("  </TR>");
		} while (rs.next());
		out.println("</TABLE>");
	}
	rs.close();
	
}
catch (Exception ex)
{
	logger.error("Exception: ", ex);
}
finally
{
	try { if ( stmt != null ) stmt.close(); }
	catch (SQLException se) { }
	if ( conn != null ) cp.free(conn); 
}
out.println("</BODY>");
out.println("<HTML>");
%>


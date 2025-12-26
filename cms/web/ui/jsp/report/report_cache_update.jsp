<%@ page
	language="java"
	import="com.britemoon.cps.tgt.*"
	import="com.britemoon.cps.imc.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.*"
	import="java.util.*"
	import="java.sql.*"
	import="java.net.*"
	import="org.w3c.dom.*"
	import="java.io.*"
	import="org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

if(!can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>
<HTML>
<HEAD>
	<LINK rel="stylesheet" href="<%=ui.s_css_filename%>" type="text/css">
</HEAD>
<BODY>
<%
out.flush();

// === === ===

String	sCampID = BriteRequest.getParameter(request, "camp_id");
String	sCacheID = BriteRequest.getParameter(request, "cache_id");
String	sStartDate = BriteRequest.getParameter(request, "start_date");
String	sEndDate = BriteRequest.getParameter(request, "end_date");
String	sFilterID = BriteRequest.getParameter(request, "filter_id");
String	sAttrID = BriteRequest.getParameter(request, "attr_id");
String	sAttrValue1 = BriteRequest.getParameter(request, "attr_value1");
String	sAttrValue2 = BriteRequest.getParameter(request, "attr_value2");
String	sAttrOperator = BriteRequest.getParameter(request, "attr_operator");
String	sUserID = BriteRequest.getParameter(request, "user_id");
String	sGetCacheInfo = BriteRequest.getParameter(request, "get_cache_info");
String	sCustID = cust.s_cust_id; 

if ( (sCampID == null) || (sCampID.equals("")) ) throw new Exception ("Campaign ID required");
if ( (sCacheID == null) || (sCacheID.equals("")) ) sCacheID = "0";
if ( (sUserID == null) || (sUserID.equals("")) ) sUserID = "0";
String sTempCacheID = sCacheID;
if (sCacheID.equals("0")) sTempCacheID = "-" + NextInt.get(sCustID);

// === === ===

String[] sCacheIdList = sCacheID.split(",");

for (int n=0; n < sCacheIdList.length; n++) 
{
sCacheID = sCacheIdList[n];

if (!sCacheID.equals("0") && sGetCacheInfo != null && sGetCacheInfo.equals("1")) 
{
	System.out.println("Retrieving missing report cache info");

	ConnectionPool	cp		= null;
	Connection		conn	= null;
	Statement		stmt	= null;
	ResultSet		rs		= null; 
	String          sql     = null;
	try {
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("report_cache_update.jsp");

		stmt = conn.createStatement();
		sql = "SELECT cache_start_date, cache_end_date, attr_id, attr_value1, attr_value2, attr_operator, user_id, filter_id"
		     + "  FROM crpt_camp_summary_cache " 
		     + "  WHERE cache_id = " + sCacheID + " AND camp_id = "+sCampID;
		rs = stmt.executeQuery(sql);
		if (rs.next()) {
			sStartDate = rs.getString(1);
			sEndDate = rs.getString(2);
			sAttrID = rs.getString(3);
			sAttrValue1 = rs.getString(4);
			sAttrValue2 = rs.getString(5);
			sAttrOperator = rs.getString(6);
			sUserID = rs.getString(7);
			sFilterID = rs.getString(8);
		}
		rs.close();
	}
	catch (Exception ex) { 
		ErrLog.put(this, ex, "Report Cache Update Error.",out,1);
	} 
	finally {
		try { 	
			if( stmt != null ) stmt.close(); 
		}
		catch (Exception ex2) {}
		if ( conn != null ) cp.free(conn);
	}
}

if(sFilterID != null) {
	try { FilterUtil.sendFilterUpdateRequestToRcp(sFilterID); }
	catch (Exception ex) { logger.error("Exception: ",ex); }
}

StringWriter swXML = new StringWriter();

swXML.write("<camp_reports>\r\n");
swXML.write("<camp_report_cache>\r\n");
swXML.write("<camp_id>"+sCampID+"</camp_id>\r\n");
swXML.write("<cust_id>"+cust.s_cust_id+"</cust_id>\r\n");
swXML.write("<cache_id>"+sCacheID+"</cache_id>\r\n");
swXML.write("<cache_start_date><![CDATA["+(sStartDate!=null?sStartDate:"")+"]]></cache_start_date>\r\n");
swXML.write("<cache_end_date><![CDATA["+(sEndDate!=null?sEndDate:"")+"]]></cache_end_date>\r\n");
swXML.write("<filter_id>"+(sFilterID!=null?sFilterID:"")+"</filter_id>\r\n");
swXML.write("<attr_id>"+(sAttrID!=null?sAttrID:"")+"</attr_id>\r\n");
swXML.write("<attr_value1><![CDATA["+(sAttrValue1!=null?sAttrValue1:"")+"]]></attr_value1>\r\n");
swXML.write("<attr_value2><![CDATA["+(sAttrValue2!=null?sAttrValue2:"")+"]]></attr_value2>\r\n");
swXML.write("<attr_operator>"+(sAttrOperator!=null?sAttrOperator:"")+"</attr_operator>\r\n");
swXML.write("<user_id>"+sUserID+"</user_id>\r\n");
swXML.write("<temp_cache_id>"+sTempCacheID+"</temp_cache_id>\r\n");
swXML.write("</camp_report_cache>\r\n");
swXML.write("</camp_reports>\r\n");

String sCacheXml = Service.communicate(ServiceType.RRPT_CAMPAIGN_REPORT_CACHE, cust.s_cust_id, swXML.toString());
Element e = XmlUtil.getRootElement(sCacheXml);

if(e == null) throw new Exception("Malformed Campaign Report xml.");

sCampID = XmlUtil.getChildTextValue(e, "camp_id");
sCustID = XmlUtil.getChildTextValue(e, "cust_id");
sCacheID = XmlUtil.getChildTextValue(e, "cache_id");
sTempCacheID = XmlUtil.getChildTextValue(e, "temp_cache_id");

if ((sCampID == null) || (sCustID == null)) throw new Exception("Campaign not specified.");

// === === ===

// Connection
Statement		stmt	= null;
PreparedStatement pstmt	= null;
ResultSet		rs		= null; 
ConnectionPool	cp		= null;
Connection		conn	= null;
String 			sSQL 	= null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("report_cache_update.jsp");
	conn.setAutoCommit(false);

	boolean foundCache = false;

	try
	{ 	
		stmt = conn.createStatement();
		// also update attr/filter info
		sSQL = "UPDATE crpt_camp_summary_cache"
			 + "   SET cache_start_date = " + ( sStartDate    == null ? "null" : "'" + sStartDate + "'" )
 			 + "        ,cache_end_date = " + ( sEndDate      == null ? "null" : "'" + sEndDate + "'" )
 			 + "               ,attr_id = " + ( sAttrID       == null ? "null" : sAttrID )
 			 + "           ,attr_value1 = " + ( sAttrValue1   == null ? "null" : sAttrValue1 )
 			 + "           ,attr_value2 = " + ( sAttrValue2   == null ? "null" : sAttrValue2 )
 			 + "         ,attr_operator = " + ( sAttrOperator == null ? "null" : sAttrOperator )
  			 + "               ,user_id = " + ( sUserID       == null ? "null" : sUserID )
 			 + "             ,filter_id = " + ( sFilterID     == null ? "null" : sFilterID )
			 + "        ,last_status_id = 10"
			 + " WHERE cache_id = " + sCacheID + " AND camp_id = "+sCampID;
		System.out.println("sql = " + sSQL);
		int rc = stmt.executeUpdate(sSQL);
		if (rc > 0) {
			foundCache = true;
		}
	}
	catch (Exception ex) { throw ex; }
	finally { if( stmt != null ) stmt.close(); }

	if (!foundCache) {

	         sSQL = "INSERT crpt_camp_summary_cache"
			 + " (camp_id, cust_id, camp_name, start_date, "
		 	 + "  sent, bbacks, reaching, dist_reads, tot_reads, dist_clicks, unsubs, tot_clicks, tot_text_clicks, tot_html_clicks, tot_aol_clicks, "
		  	 + "  tot_links, dist_text_clicks, dist_html_clicks, dist_aol_clicks, multi_readers, link_multi_clickers, multi_link_clickers, "
		 	 + "  last_update_date, cache_id, cache_start_date, cache_end_date, attr_id, attr_value1, attr_value2, attr_operator, user_id, filter_id, last_status_id)"
		 	 + " SELECT ?,?,camp_name,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,getDate(),?,?,?,?,?,?,?,?,?,10"
		 	 + "  FROM cque_campaign WHERE camp_id = " + sCampID;

	try
	{ 	
		pstmt = conn.prepareStatement(sSQL);
		pstmt.setString(1,sCampID);
		pstmt.setString(2,sCustID);
			pstmt.setString(3,sTempCacheID);
			pstmt.setString(4,sStartDate);
			pstmt.setString(5,sEndDate);
			pstmt.setString(6,sAttrID);
			pstmt.setString(7,sAttrValue1);
			pstmt.setString(8,sAttrValue2);
			pstmt.setString(9,sAttrOperator);
			pstmt.setString(10,sUserID);
			pstmt.setString(11,sFilterID);
					pstmt.executeUpdate();
				}
				catch (Exception ex) { throw ex; }
				finally { if( pstmt != null ) pstmt.close(); }
			}
	conn.commit();
}
catch(Exception ex)
{ 
	conn.rollback();
	ErrLog.put(this, ex, "Campaign Cache Update Error.",out,1);
}
finally
{
	if( conn != null )
	{
		try { conn.setAutoCommit(true);	}
		catch(Exception eee) {logger.error("Exception: ",eee); }
		cp.free(conn); 
	}
}
}
%>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Report:</b> Updating</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
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
						<p>The Demographic or Time Report is being updated.</p>
						<p><P align="center"><a href="report_cache_list.jsp?Q=<%=sCampID%>">Back to List</a></p>
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


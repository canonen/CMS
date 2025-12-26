<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.io.*,
			java.util.*,org.xml.sax.*,
			javax.xml.transform.*,
			javax.xml.transform.stream.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%
	response.setHeader("Expires", "0");
	response.setHeader("Pragma", "no-cache");
	response.setHeader("Cache-Control", "no-cache");
	response.setHeader("Cache-Control", "max-age=0");
	response.setContentType("text/html; charset=UTF-8");
%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

if(!can.bRead)
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

// Connection
Statement		stmt	= null;
ResultSet		rs		= null; 
ConnectionPool	cp		= null;
Connection		conn	= null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("report_redirect.jsp");
	stmt = conn.createStatement();
	
	String sCampID = request.getParameter("id");

	int numRecs = 0;
	String media_type=null;
	
	if ((sCampID != null) && (sCampID != ""))
	{
		String sSQL =
			" SELECT c.media_type_id" +
			" FROM cque_campaign c" +
			" WHERE c.cust_id = " + cust.s_cust_id +
			" AND c.camp_id IN ( " + sCampID + " )";
			
		rs = stmt.executeQuery(sSQL); 
		while(rs.next()){
		 numRecs++;
		 media_type = rs.getString(1);
		 }
		rs.close();
		 
		 
	}
	
	if ((sCampID == null) || (sCampID == "") || (numRecs < 1))
	{
%>
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
								<b>No Campaign for that ID</b>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			</tbody>
		</table>
		<br><br>
<%	
	}
	else
	{
		  
		
		if ("2".equals(media_type)){
					String rcp1=null;
					String cust_id=cust.s_cust_id;
		
					String sSql = "select c.cust_id,m.ip_address into #rcp"
						 			+" from  brite_ccps_500.dbo.cadm_cust_mod_inst c with(nolock)"
						 			+" left join  brite_ccps_500.dbo.cadm_mod_inst i with(nolock)  on c.mod_inst_id=i.mod_inst_id "
						 			+" left join   brite_ccps_500.dbo.cadm_machine m with(nolock) on  m.machine_id=i.machine_id "
						 			+" where c.cust_id='"+ cust_id +"' and i.mod_id=6  select * from #rcp   ";
						 			  
									rs= stmt.executeQuery(sSql);			
										while (rs.next()){
										   rcp1 = rs.getString("ip_address");                               
									 	}
									sSql = "drop table #rcp";
									stmt.executeUpdate(sSql);
										
									rs.close();
					 
					 
					
					String redirectURL = "http://"+rcp1+"/rrcp/imc/sms/ReportSms.jsp?Cpid="+sCampID+"&Ctid="+cust_id+"" ;
					 
					 
					%>
				 	<SCRIPT>location.href = '<%= redirectURL %>';</SCRIPT>
					<%
					
					
		}else{
		
		String redirectURL = "report_object.jsp?act=VIEW&id=" + sCampID;
		
		if ("1".equals(user.s_recip_owner))
		{
			String sCacheID = "0";
			
			String sSQL =
				" SELECT cache_id"+
				" FROM crpt_camp_summary_cache" + 
				" WHERE camp_id IN ( " + sCampID + " )" +
				" AND cache_start_date IS NULL" + 
				" AND cache_end_date IS NULL" + 
				" AND attr_id IS NULL" + 
				" AND attr_value1 IS NULL" + 
				" AND attr_value2 IS NULL" + 
				" AND attr_operator IS NULL" + 
				" AND user_id = " + user.s_user_id;
			
			rs = stmt.executeQuery(sSQL); 
			while(rs.next()) sCacheID = rs.getString(1);
			rs.close();
			
			if ("0".equals(sCacheID))
			{
				redirectURL =
					"report_cache_update.jsp?camp_id=" + sCampID + 
					"&cache_id=0" + 
					"&start_date=" + 
					"&end_date=" + 
					"&attr_id=" + 
					"&attr_value1=" + 
					"&attr_value2=" + 
					"&attr_operator=" + 
					"&user_id=" + user.s_user_id;
			}
			else
			{
				redirectURL = "report_object.jsp?act=VIEW&Z=1&id=" + sCampID + "&C=" + sCacheID;
			}
		}
		else
		{
			redirectURL = "report_object.jsp?act=VIEW&id=" + sCampID;
		}
		
		 
		
%>
	 	<SCRIPT> location.href = '<%= redirectURL %>';</SCRIPT>
<%
//		response.sendRedirect(redirectURL);
	}
    }
}
catch(Exception ex)
{
	ErrLog.put(this,ex,"Error: " + ex.getMessage(),out,1);
}
finally
{
	if (stmt!=null) stmt.close();
	if (conn!=null) cp.free(conn);
	out.flush();
}
%>
</BODY>
</HTML>

<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.ftp.*, 
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
	String sTaskId = BriteRequest.getParameter(request,"task_id");
	String sCustId = BriteRequest.getParameter(request,"cust_id");	

	if((sTaskId == null)&&(sCustId == null)) return;

	FtpTask ft = null;
	FtpTaskSchedule fts = null;
	FtpTaskImportTemplate ftit = null;

	if(sTaskId != null)
	{
		ft = new FtpTask();
		ft.s_task_id = sTaskId;
		if(ft.retrieve() < 1) return;
		
		fts = new FtpTaskSchedule(sTaskId);
		ftit = new FtpTaskImportTemplate(sTaskId);
	}
	else
	{
		ft = new FtpTask();
		
		ft.s_cust_id = sCustId;
		ft.s_date_format = "yyyyMMdd";
		
		fts = new FtpTaskSchedule();

		java.util.Date dDate = new java.util.Date();
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
		fts.s_next_start_date = sdf.format(dDate) + " 01:00:00.000";
		ftit = new FtpTaskImportTemplate();
	}
	
	if(	fts.s_next_start_interval == null ) fts.s_next_start_interval = "1440"; // = 24 * 60;
	
	Customer cust = new Customer(ft.s_cust_id);
%>
<HTML>
<HEAD>
<title>FTP Import Edit</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>
<BODY>

<FORM name='ftp_import_form' action='ftp_task_save.jsp' method=POST>
<INPUT type='hidden' name='task_id' value='<%=HtmlUtil.escape(ft.s_task_id)%>'>
<INPUT type='hidden' name='cust_id' value='<%=HtmlUtil.escape(ft.s_cust_id)%>'>
<INPUT type='submit' value='Save'>
<BR><BR>
<H4>Customer: <%=cust.s_cust_name%> (ID = <%=cust.s_cust_id%>)</H4>
<H4>Task name: <INPUT type="text" name="task_name" value="<%=HtmlUtil.escape(ft.s_task_name)%>"> (ID = <%=ft.s_task_id%>)</H4>
<TABLE cellpadding=1 cellspacing=0 border=1>
	<TR>
		<TD>
<CENTER><H4>Where to get ...</H4></CENTER>
<TABLE>
	<TR>
		<TD>server</TD>
		<TD><INPUT type="text" name="server" value="<%=HtmlUtil.escape(ft.s_server)%>"></TD>
	</TR>
	<TR>
		<TD>directory</TD>
		<TD><INPUT type="text" name="directory" value="<%=HtmlUtil.escape(ft.s_directory)%>"></TD>
	</TR>
	<TR>
		<TD>username</TD>
		<TD><INPUT type="text" name="username" value="<%=HtmlUtil.escape(ft.s_username)%>"></TD>
	</TR>
	<TR>
		<TD>password</TD>
		<TD><INPUT type="text" name="password" value="<%=HtmlUtil.escape(ft.s_password)%>"></TD>
	</TR>
	<TR>
		<TD>filename_prefix</TD>
		<TD><INPUT type="text" name="filename_prefix" value="<%=HtmlUtil.escape(ft.s_filename_prefix)%>"></TD>
	</TR>
	<TR>
		<TD>filename_suffix</TD>
		<TD><INPUT type="text" name="filename_suffix" value="<%=HtmlUtil.escape(ft.s_filename_suffix)%>"></TD>
	</TR>
	<TR>
		<TD>date_format</TD>
		<TD><INPUT type="text" name="date_format" value="<%=HtmlUtil.escape(ft.s_date_format)%>"></TD>
	</TR>
<%
	boolean bPgpFlag = ((ft.s_pgp_flag != null)&&(Integer.parseInt(ft.s_pgp_flag) > 0));
%>
	<TR>
		<TD>pgp_flag</TD>
		<TD><INPUT type="checkbox" name="pgp_flag" value="1"<%=(bPgpFlag)?" checked":""%>></TD>
	</TR>
	<TR>
		<TD>Task Type</TD>
		<TD>
			<SELECT name="task_type_id">
				<OPTION></OPTION>
				<%=getTaskTypeOptions(ft.s_task_id, ft.s_type_id)%>
			</SELECT>
	</TR>
</TABLE>
		</TD>
		<TD>
<CENTER><H4>When ...</H4></CENTER>
<TABLE>
	<TR>
		<TD>next_start_date</TD>
		<TD><INPUT type="text" name="next_start_date" value="<%=HtmlUtil.escape(fts.s_next_start_date)%>"></TD>
	</TR>
	<TR>
		<TD>next_start_interval (minutes)<BR>1 day = 24 hours = 1440 minutes</TD>
		<TD><INPUT type="text" name="next_start_interval" value="<%=HtmlUtil.escape(fts.s_next_start_interval)%>"></TD>
	</TR>
	<TR>
		<TD>linked_setup_id</TD>
		<TD><INPUT type="text" name="linked_task_id" value="<%=HtmlUtil.escape(fts.s_linked_task_id)%>"></TD>
	</TR>
        
        <tr>
			<td align="left" valign="middle">
                        <input name="hm_daily_weekday_mask" type="hidden" value="0">
                        Check the days when Host Monitor should check for alerts. <br>(This does not control when FTP task runs): 
				<% int nSWeekdayMask = 0;
                                   if(fts.s_hm_daily_weekday_mask != null) {
                                      nSWeekdayMask = Integer.parseInt(fts.s_hm_daily_weekday_mask); 
                                   }
                                %>
                            
			</td>
			<td>

                            <table cellspacing="0" cellpadding="1" border="0">
                                    <tr>
                                            <td align="center" valign="bottom" width="30"><label for="q_wk_mon">Mon</label></td>
                                            <td align="center" valign="bottom" width="30"><label for="q_wk_tue">Tue</label></td>
                                            <td align="center" valign="bottom" width="30"><label for="q_wk_wed">Wed</label></td>
                                            <td align="center" valign="bottom" width="30"><label for="q_wk_thu">Thu</label></td>
                                            <td align="center" valign="bottom" width="30"><label for="q_wk_fri">Fri</label></td>
                                            <td align="center" valign="bottom" width="30"><label for="q_wk_sat">Sat</label></td>
                                            <td align="center" valign="bottom" width="30"><label for="q_wk_sun">Sun</label></td>
                                    </tr>
                                    <tr>
                                            <td align="center" valign="top" width="30"><input name="hm_daily_weekday_mask" id="q_wk_mon" type="checkbox" value="2"<%=((nSWeekdayMask&2)>0)?" checked":""%>></td>
                                            <td align="center" valign="top" width="30"><input name="hm_daily_weekday_mask" id="q_wk_tue" type="checkbox" value="4"<%=((nSWeekdayMask&4)>0)?" checked":""%>></td>
                                            <td align="center" valign="top" width="30"><input name="hm_daily_weekday_mask" id="q_wk_wed" type="checkbox" value="8"<%=((nSWeekdayMask&8)>0)?" checked":""%>></td>
                                            <td align="center" valign="top" width="30"><input name="hm_daily_weekday_mask" id="q_wk_thu" type="checkbox" value="16"<%=((nSWeekdayMask&16)>0)?" checked":""%>></td>
                                            <td align="center" valign="top" width="30"><input name="hm_daily_weekday_mask" id="q_wk_fri" type="checkbox" value="32"<%=((nSWeekdayMask&32)>0)?" checked":""%>></td>
                                            <td align="center" valign="top" width="30"><input name="hm_daily_weekday_mask" id="q_wk_sat" type="checkbox" value="64"<%=((nSWeekdayMask&64)>0)?" checked":""%>></td>
                                            <td align="center" valign="top" width="30"><input name="hm_daily_weekday_mask" id="q_wk_sun" type="checkbox" value="1"<%=((nSWeekdayMask&1)>0)?" checked":""%>></td>
                                    </tr>
                            </table>
						
                    </tr>
				</table>
			</td>
		</tr>
</TABLE>
		</TD>
		<TD>
<CENTER><H4>Process downloaded file using ...</H4></CENTER>
<TABLE>
	<TR>
		<TD>Import template:</TD>
		<TD>
			<SELECT name="recip_import_template_id">
				<OPTION></OPTION>
				<%=getImportTemplateOptions(ft.s_cust_id, ftit.s_recip_import_template_id)%>
			</SELECT>
		</TD>
	</TR>
	<TR>
		<TD>Entity import template:</TD>
		<TD>
			<SELECT name="entity_import_template_id">
				<OPTION></OPTION>
				<%=getEntityImportTemplateOptions(ft.s_cust_id, ftit.s_entity_import_template_id)%>
			</SELECT>
		</TD>
	</TR>
</TABLE>
		</TD>
	</TR>
</TABLE>
</FORM>

</BODY>
</HTML>

<%!
private static String getImportTemplateOptions(String sCustId, String sSelectedTemplateId) throws Exception
{
	String sSql =
		" SELECT" +
		" 	template_id," +
		"	template_name" + 
		" FROM" +
		"	cupd_batch b," +			
		"	cupd_import_template it" +	
		" WHERE b.cust_id = " + sCustId +
		"	AND it.batch_id = b.batch_id" +
		" ORDER BY template_name";
			
	return getTemplateOptions(sSql, sSelectedTemplateId);
}

private static String getEntityImportTemplateOptions(String sCustId, String sSelectedTemplateId) throws Exception
{
	String sSql =
		" SELECT" +
		" 	template_id," +
		"	template_name" + 
		" FROM" +
		"	cntt_entity_import_template eit" +	
		" WHERE eit.cust_id = " + sCustId +
		" ORDER BY template_name";
			
	return getTemplateOptions(sSql, sSelectedTemplateId);
}

private static String getTemplateOptions(String sSql, String sSelectedTemplateId) throws Exception
{
	String sOptions = "";

	ConnectionPool cp = null;
	Connection conn = null;
	Statement stmt = null; 
	
	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("ftp_task_edit.jsp");
		stmt = conn.createStatement();

		String sTemplateId = null;
		String sTemplateName = null;
		boolean bSelected = false;
		
		ResultSet rs = stmt.executeQuery(sSql);
		
		while(rs.next())
		{
			sTemplateId = rs.getString(1);
			sTemplateName = rs.getString(2);

			bSelected = sTemplateId.equals(sSelectedTemplateId);
			sOptions +=
				"<OPTION value='" + sTemplateId + "'" + ((bSelected)?" selected":"") + "> " + 
				HtmlUtil.escape(sTemplateName) + " (" + sTemplateId  + ") </OPTION>\r\n";
		}
		rs.close();
	}
	catch (Exception ex) { throw ex; }
	finally
	{
		if (stmt!=null) stmt.close();
		if (conn!=null) cp.free(conn);			
	}
	return sOptions;
}

private static String getTaskTypeOptions(String sTaskId, String sSelectedTypeId) throws Exception
{
	String sOptions = "";

	ConnectionPool cp = null;
	Connection conn = null;
	Statement stmt = null; 
	String sSql =
		" SELECT" +
		" 	type_id," +
		"	type_name" + 
		" FROM" +
		"	cftp_ftp_task_type tasktype" +	
		" ORDER BY type_id";

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("ftp_task_edit.jsp");
		stmt = conn.createStatement();

		String sTaskTypeId = null;
		String sTaskTypeName = null;
		boolean bSelected = false;
		
		ResultSet rs = stmt.executeQuery(sSql);
		
		while(rs.next())
		{
			sTaskTypeId = rs.getString(1);
			sTaskTypeName = rs.getString(2);

			bSelected = sTaskTypeId.equals(sSelectedTypeId);
			sOptions +=
				"<OPTION value='" + sTaskTypeId + "'" + ((bSelected)?" selected":"") + "> " + 
				HtmlUtil.escape(sTaskTypeName) + " (" + sTaskTypeId  + ") </OPTION>\r\n";
		}
		rs.close();
	}
	catch (Exception ex) { throw ex; }
	finally
	{
		if (stmt!=null) stmt.close();
		if (conn!=null) cp.free(conn);			
	}
	return sOptions;
}
%>

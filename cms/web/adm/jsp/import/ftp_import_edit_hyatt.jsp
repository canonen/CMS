<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.upd.*, 
			java.io.*, 
			java.text.*, 
			java.sql.*, 
			java.util.*, 
			org.w3c.dom.*"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%
	
	String sTemplateId = BriteRequest.getParameter(request,"template_id");
	String sHotelId = BriteRequest.getParameter(request,"hotel_id");	
	String sCustId = BriteRequest.getParameter(request,"cust_id");

	String sBatchId = getBatchId(sTemplateId,sHotelId);
	Batch batch = new Batch(sBatchId);

	if(sCustId == null) sCustId = batch.s_cust_id;
	if(batch.s_cust_id == null) batch.s_cust_id = sCustId;
	
	Customer c = new Customer(sCustId);	
	if(batch.s_batch_name == null) batch.s_batch_name = c.s_cust_name + " Auto FTP Batch";
%>
<HTML>
<HEAD>
<title>FTP Import Edit</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>
<BODY>
<H4>Customer: <%=c.s_cust_name%> (<%=c.s_cust_id%>)</H>
<FORM name='ftp_import_form' action='ftp_import_save_hyatt.jsp' method=POST>
<INPUT type='hidden' name='cust_id' value='<%=HtmlUtil.escape(sCustId)%>'>
<INPUT type='button' value='Save' onClick='save();'>
<BR><BR>
<TABLE cellpadding=1 cellspacing=0 border=1>
	<TR>
		<TD>
<TABLE>
	<TR>
		<TD>template_id</TD>
		<TD>
			<SELECT <%=((sTemplateId!=null)?"disabled":"name='template_id'")%>>
				<OPTION></OPTION>
				<%=getSetupOptions(sCustId, sTemplateId)%>
			</SELECT>
<% if(sTemplateId!=null) { %>
			<INPUT type="hidden" name="template_id" value="<%=HtmlUtil.escape(sTemplateId)%>">
<% } %>	
		</TD>
	</TR>
	<TR>
		<TD>hotel_id</TD>
		<TD>
			<INPUT type="text" <%=((sHotelId!=null)?"disabled":"name='hotel_id'")%> value="<%=HtmlUtil.escape(sHotelId)%>">		
<% if(sHotelId!=null) { %>
			<INPUT type="hidden" name="hotel_id" value="<%=HtmlUtil.escape(sHotelId)%>">
<% } %>	
		</TD>
	</TR>
</TABLE>
		</TD>	
		<TD nowrap>			
<TABLE>
	<TR>
		<TD colspan=2 align="center">Existing batch:</TD>
	</TR>
	<TR>
		<TD colspan=2 align="center">
			<SELECT name="batch_id">
				<OPTION></OPTION>
				<%=getBatchOptions(batch.s_cust_id, batch.s_batch_id)%>
			</SELECT>
		</TD>
	</TR>
	<TR>
		<TD colspan=2 align="center">OR New batch</TD>		
	</TR>
	<TR>
		<TD>batch_name:</TD>
		<TD><INPUT type="text" size=50 name="batch_name" value="<%=HtmlUtil.escape(batch.s_batch_name)%>"></TD>
	<TR>
	</TR>
		<TD>descrip:</TD>
		<TD><INPUT type="text" size=50 name="descrip" value="<%=HtmlUtil.escape(batch.s_descrip)%>"></TD>
	</TR>
</TABLE>
		</TD>
	</TR>
	<TR>
		<TD colspan=3>
<CENTER><H4>Mappings ...</H4></CENTER>
<SELECT multiple name="ftp_import_mappings" style="width: 0; height: 0;"></SELECT>
<TABLE cellpadding="0" cellspacing="0" border="0" class="main" width="100%"> 
    <TR> 
        <TD> Attributes to be imported </TD>
        <TD></TD>
        <TD>Customer Attribute List </TD>
    </TR>
	<TR> 
		<TD width="40%" valign="middle" align="center">
			<SELECT name="target" size="10" style="width: 100%" onDblClick="removeField()">
			<%CustAttrs mapped_attrs = getMappedAttrs(sTemplateId, sHotelId);%>
			<%=CustAttrsUtil.toHtmlOptions(mapped_attrs)%>
			</SELECT>
		</TD>
		<TD valign="middle" align="center" nowrap>
			<p><a class="subactionbutton" href="javascript:void(0);" onclick="upField();">Move Up</a></p>
			<p><a class="subactionbutton" href="javascript:void(0);" onclick="downField();">Move Down</a></p>
			<br>
			<p><a class="subactionbutton" href="javascript:void(0);" onclick="addField();"><< Move Left</a></p>
			<p><a class="subactionbutton" href="javascript:void(0);" onclick="removeField();">Move Right >></a></p>
		</TD>
		<TD width="40%" valign="middle" align="center">
			<SELECT name="source" size="10" style="width: 100%" onDblClick="addField()">
			<%CustAttrs cust_attrs = getCustAttrs(sCustId);%>
			<%=CustAttrsUtil.toHtmlOptions(cust_attrs)%>
			</SELECT>
		</TD>
	</TR>
</TABLE>
		</TD>
	</TR>
</TABLE>
</FORM>

<SCRIPT>
	function save()
	{
		fixFtpImportMappings();
		ftp_import_form.submit();
	}

	function fixFtpImportMappings()
	{
		ftp_import_form.target.disabled = true;
		ftp_import_form.source.disabled = true;		

		var t_ops = ftp_import_form.target.options;
		var fif_ops = ftp_import_form.ftp_import_mappings.options;

		for(var i=0; i < t_ops.length; ++i)
		{
			fif_ops[i] = new Option(t_ops[i].text, t_ops[i].value);
			fif_ops[i].selected = true;
		}
	}
	
	function upField()
	{
		var id, name;

		var ops = ftp_import_form.target.options;
		var si = ftp_import_form.target.selectedIndex;
		
		if( si < 1 ) return false;

		id = ops[si-1].value;
		name = ops[si-1].text;
		
		ops[si-1].value = ops[si].value;
		ops[si-1].text  = ops[si].text;

		ops[si].value = id;
		ops[si].text  = name;

		ftp_import_form.target.selectedIndex--;
	}

	function downField()
	{
		var id, name;

		var ops = ftp_import_form.target.options;
		var si = ftp_import_form.target.selectedIndex;

		if( si < 0 ) return;
		if( si >= ftp_import_form.target.length - 1 ) return false;

		id = ops[si+1].value;
		name = ops[si+1].text;
		
		ops[si+1].value = ops[si].value;
		ops[si+1].text  = ops[si].text;

		ops[si].value = id;
		ops[si].text  = name;
		
		ftp_import_form.target.selectedIndex++;
	}

	function addField()
	{
		var ops = ftp_import_form.source.options;
		var si = ftp_import_form.source.selectedIndex;

		if( si == -1 ) return false;

		ftp_import_form.target.options[ftp_import_form.target.length] = new Option(ops[si].text, ops[si].value);
		ops[si] = null;
	}

	function removeField()
	{
		if( ftp_import_form.target.selectedIndex == -1 ) return false;

		ftp_import_form.target.options[ftp_import_form.target.selectedIndex] = null;
		ftp_import_form.source.selectedIndex = 0;

		for(var i=0; i < itemOpt.length; ++i) ftp_import_form.source.options[i] = itemOpt[i]; 

		removeTargetFromSource()			
	}

	function removeTargetFromSource()
	{
		for(var i=0; i < ftp_import_form.target.options.length; ++i)
		{
			for(var j=0; j < ftp_import_form.source.options.length; ++j)
			{
				if( ftp_import_form.target.options[i].value == ftp_import_form.source.options[j].value )
				{
					ftp_import_form.source.options[j] = null;
					--j;
				}
			}
		}
	}
	
	var itemOpt = new Array();
	function Init()
	{
		for(var i=0; i < ftp_import_form.source.options.length; ++i)
		{
			itemOpt[i] = ftp_import_form.source.options[i];
		}
		removeTargetFromSource();
	}

</SCRIPT>

</BODY>
</HTML>

<%!
private static String getBatchId(String sTemplateId, String sHotelId) throws Exception
{
	String sBatchId = null;
		
	ConnectionPool cp = null;
	Connection conn = null;
	Statement stmt = null; 

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("ftp_import_edit_hyatt.jsp");
		stmt = conn.createStatement();
		
		String sSql =
			" SELECT batch_id" +		
			" FROM cupd_import_template_hyatt b" +		
			" WHERE	template_id = " + sTemplateId +
			" AND hotel_id  = '" + sHotelId + "'";
	
		ResultSet rs = stmt.executeQuery(sSql);
		if(rs.next())sBatchId = rs.getString(1);
		rs.close();
	}
	catch (Exception ex) { throw ex; }
	finally
	{
		if (stmt!=null) stmt.close();
		if (conn!=null) cp.free(conn);			
	}
	return sBatchId;
}

private static String getBatchOptions(String sCustId, String sSelectedBatchId) throws Exception
{
	String sOptions = "";

	ConnectionPool cp = null;
	Connection conn = null;
	Statement stmt = null; 

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("ftp_import_edit_hyatt.jsp");
		stmt = conn.createStatement();
		
		String sSql =
			" SELECT" +
			" 	batch_id," +		
			"	batch_name" + 
			" FROM cupd_batch b" +		
			" WHERE	b.cust_id = " + sCustId +
			" ORDER BY batch_name, batch_id";

		String sBatchId = null;
		String sBatchName = null;
		boolean bSelected = false;
		
		ResultSet rs = stmt.executeQuery(sSql);
		
		while(rs.next())
		{
			sBatchId = rs.getString(1);
			sBatchName = rs.getString(2);

			bSelected = sBatchId.equals(sSelectedBatchId);
			sOptions +=
				"<OPTION value='" + sBatchId + "'" + ((bSelected)?" selected":"") + "> " + 
				HtmlUtil.escape(sBatchName) + " (" + sBatchId  + ") </OPTION>\r\n";
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


private static String getSetupOptions(String sCustId, String sSelectedTemplateId) throws Exception
{
	String sOptions = "";

	ConnectionPool cp = null;
	Connection conn = null;
	Statement stmt = null; 

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("ftp_import_edit_hyatt.jsp");
		stmt = conn.createStatement();
		
		String sSql =
			" SELECT" +
			" 	it.template_id, " +	
			"	it.template_name, " + 
			"	it.batch_id " + 
			" FROM" +
			"	cupd_import_template it" +		
			" ORDER BY it.template_id";

		String sTemplateId = null;
		String sParentCustId = null;		
		String sBatchId = null;		
		String sBatchName = null;
		String sTemplateName = null;
		boolean bSelected = false;
		
		ResultSet rs = stmt.executeQuery(sSql);
		
		while(rs.next())
		{
			sTemplateId = rs.getString(1);
			sTemplateName = rs.getString(2);
			sBatchId = rs.getString(3);			
			

			bSelected = sTemplateId.equals(sSelectedTemplateId);
			sOptions +=
				"<OPTION value='" + sTemplateId + "'" + ((bSelected)?" selected":"") + "> " + 
				" template_id=" + sTemplateId + " " + sTemplateName +
				" from batch " + HtmlUtil.escape(sBatchName) + " (" + sBatchId  + ") </OPTION>\r\n";
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

private static CustAttrs getMappedAttrs(String sTemplateId, String sHotelId) throws Exception
{
	CustAttrs cas = new CustAttrs();
	
	cas.m_sRetrieveSql = 
			" SELECT" +
			"	ca.cust_id," +
			"	ca.attr_id," +
			"	ca.display_name," +
			"	ca.display_seq," +
			"	ca.fingerprint_seq," +
			"	ca.sync_flag," +
			"	ca.hist_flag," +
			"	ca.newsletter_flag," +
			"	ca.recip_view_seq," +
			"	fimh.seq" +
			" FROM" +
			"	ccps_cust_attr ca,"+
			"	cupd_import_template_attr_hyatt fimh," +
			"	cupd_import_template_hyatt fih," +
			"	cupd_batch b" +
			" WHERE fih.template_id=" + sTemplateId +
			" AND fih.hotel_id='" + sHotelId + "'" +
			" AND ca.attr_id = fimh.attr_id" + 
			" AND fimh.template_id = fih.template_id" +
			" AND fimh.hotel_id = fih.hotel_id" +			
			" AND fih.batch_id = b.batch_id" +
			" AND b.cust_id = ca.cust_id" +
			" ORDER BY fimh.seq, ca.display_name";
	
	cas.retrieve();
	return cas;
}

private static CustAttrs getCustAttrs(String sCustId) throws Exception
{
	CustAttrs cas = new CustAttrs();
	
	cas.m_sRetrieveSql = 
			" SELECT" +
			"	ca.cust_id," +
			"	ca.attr_id," +
			"	ca.display_name," +
			"	ca.display_seq," +
			"	ca.fingerprint_seq," +
			"	ca.sync_flag," +
			"	ca.hist_flag," +
			"	ca.newsletter_flag," +
			"	ca.recip_view_seq" +
			" FROM ccps_cust_attr ca" +
			" WHERE ca.cust_id=" + sCustId +
			" ORDER BY ca.display_seq, ca.display_name";
	
	cas.retrieve();
	return cas;
}

%>

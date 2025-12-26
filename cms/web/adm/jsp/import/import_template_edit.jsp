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
			org.apache.log4j.Logger"
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
	String sCustId = BriteRequest.getParameter(request,"cust_id");

	if((sTemplateId == null)&&(sCustId == null)) return;

	ImportTemplate it = null;
	Batch batch = null;

	if(sTemplateId != null)
	{
		it = new ImportTemplate(sTemplateId);
		batch = new Batch(it.s_batch_id);
	}
	else
	{
		it = new ImportTemplate();
		batch = new Batch();
		batch.s_cust_id = sCustId;
	}

	if ( it.s_upd_rule_id == null ) it.s_upd_rule_id = "30";
	
	Customer cust = new Customer(batch.s_cust_id);
%>
<HTML>
<HEAD>
<title>FTP Import Edit</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>
<BODY onload="Init();">
<FORM name='ftp_import_form' action='import_template_save.jsp' method=POST>
<INPUT type='hidden' name='template_id' value='<%=HtmlUtil.escape(it.s_template_id)%>'>
<INPUT type='hidden' name='cust_id' value='<%=HtmlUtil.escape(batch.s_cust_id)%>'>
<INPUT type='button' value='Save' onClick='save();'>
<H4>Customer: <%=cust.s_cust_name%> (ID = <%=cust.s_cust_id%>)</H4>
<H4>Template name: <INPUT type="text" name="template_name" value="<%=HtmlUtil.escape(it.s_template_name)%>"> (ID = <%=it.s_template_id%>)</H4>		
<BR><BR>
<TABLE cellpadding=1 cellspacing=0 border=1>
	<TR>
		<TD>
<CENTER><H4>Where to put ...</H4></CENTER>
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
		<TD colspan=2 align="center">OR new batch</TD>
	</TR>
	<TR>
		<TD>batch_name</TD>
		<TD><INPUT type="text" name="batch_name" value="<%=HtmlUtil.escape(batch.s_batch_name)%>"></TD>
	</TR>
	<TR>
		<TD>descrip</TD>
		<TD><INPUT type="text" name="descrip" value="<%=HtmlUtil.escape(batch.s_descrip)%>"></TD>
	</TR>
</TABLE>
		</TD>
		<TD>		
<CENTER><H4>How to process ...</H4></CENTER>
<TABLE>
	<TR>
		<TD>type_id</TD>
		<TD>
			<SELECT name="import_type_id">
				<%=ImportType.toHtmlOptions(it.s_type_id)%>
			</SELECT>
		</TD>
	</TR>
	<TR>
		<TD>first_row</TD>
		<TD><INPUT type="text" name="first_row" value="<%=HtmlUtil.escape(it.s_first_row)%>"></TD>
	</TR>
	<TR>
		<TD>field_separator</TD>
		<TD><INPUT type="text" name="field_separator" value="<%=HtmlUtil.escape(it.s_field_separator)%>"></TD>
	</TR>
	<TR>
		<TD>multi_value_field_separator</TD>
		<TD><INPUT type="text" name="multi_value_field_separator" value="<%=HtmlUtil.escape(it.s_multi_value_field_separator)%>"></TD>
	</TR>
<%
	boolean bAutoCommitFlag = ((it.s_auto_commit_flag != null)&&(Integer.parseInt(it.s_auto_commit_flag) > 0));
%>
	<TR>
		<TD>auto_commit_flag</TD>
		<TD><INPUT type="checkbox" name="auto_commit_flag" value="1"<%=(bAutoCommitFlag)?" checked":""%>></TD>
	</TR>
	<TR>
		<TD>upd_rule_id</TD>
		<TD>
			<SELECT name="upd_rule_id">
				<%=UpdateRule.toHtmlOptions(it.s_upd_rule_id)%>
			</SELECT>
		</TD>
	</TR>
	<TR>
		<TD>upd_hierarchy_id</TD>
		<TD>
			<SELECT name="upd_hierarchy_id">
				<%=Hierarchy.toHtmlOptions(it.s_upd_hierarchy_id)%>
			</SELECT>
		</TD>
	</TR>
<%
	boolean bFullNameFlag = ((it.s_full_name_flag != null)&&(Integer.parseInt(it.s_full_name_flag) > 0));
%>
	<TR>
		<TD>full_name_flag</TD>
		<TD><INPUT type="checkbox" name="full_name_flag" value="1"<%=(bFullNameFlag)?" checked":""%>></TD>
	</TR>
<%
	boolean bEmailTypeFlag = ((it.s_email_type_flag != null)&&(Integer.parseInt(it.s_email_type_flag) > 0));
%>
	<TR>
		<TD>email_type_flag</TD>
		<TD><INPUT type="checkbox" name="email_type_flag" value="1"<%=(bEmailTypeFlag)?" checked":""%>></TD>
	</TR>
<%
	boolean bNameImportAsFileFlag = ((it.s_name_import_as_file_flag != null)&&(Integer.parseInt(it.s_name_import_as_file_flag) > 0));
%>
	<TR>
		<TD>name_import_as_file_flag</TD>
		<TD><INPUT type="checkbox" name="name_import_as_file_flag" value="1"<%=(bNameImportAsFileFlag)?" checked":""%>></TD>
	</TR>
<%
	boolean bFilterPerImportFlag = ((it.s_filter_per_import_flag != null)&&(Integer.parseInt(it.s_filter_per_import_flag) > 0));
%>
	<TR>
		<TD>filter_per_import_flag</TD>
		<TD><INPUT type="checkbox" name="filter_per_import_flag" value="1"<%=(bFilterPerImportFlag)?" checked":""%>></TD>
	</TR>
</TABLE>
	</TR>
	<TR>
		<TD colspan=4>
<CENTER><H4>Mappings ...</H4></CENTER>
<SELECT multiple name="import_template_attrs" style="width: 0; height: 0;"></SELECT>
<TABLE cellpadding="0" cellspacing="0" border="0" class="main" width="100%"> 
    <TH> Attributes in Import</TH>
    <TH></TH>
    <TH>List of Customer Attributes </TH>
	<TR> 
		<TD width="40%" valign="middle" align="center">
			<SELECT name="target" size="10" style="width: 100%" onDblClick="removeField()">
			<%CustAttrs mapped_attrs = getMappedAttrs(it.s_template_id);%>
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
			<OPTION value="-1">--- ignore ---</OPTION>			
			<%CustAttrs cust_attrs = getCustAttrs(batch.s_cust_id);%>
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
		var fif_ops = ftp_import_form.import_template_attrs.options;

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
		if(ops[si].value > 0) ops[si] = null;
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
					ftp_import_form.target.options[i].text = ftp_import_form.source.options[j].text;
					if(ftp_import_form.target.options[i].value > 0) ftp_import_form.source.options[j] = null;
					break; //--j;
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
private static String getBatchOptions(String sCustId, String sSelectedBatchId) throws Exception
{
	String sOptions = "";

	ConnectionPool cp = null;
	Connection conn = null;
	Statement stmt = null; 

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("ftp_import_edit.jsp");
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

private static CustAttrs getMappedAttrs(String sTemplateId) throws Exception
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
			"	ita.seq" +
			" FROM" +
			"	ccps_cust_attr ca,"+
			"	cupd_import_template_attr ita," +
			"	cupd_import_template it," +
			"	cupd_batch b" +
			" WHERE ita.template_id=" + sTemplateId +
			" AND ca.attr_id = ita.attr_id" + 
			" AND ita.template_id = it.template_id" +
			" AND it.batch_id = b.batch_id" +
			" AND b.cust_id = ca.cust_id" +
			" UNION" +			
			" SELECT" +
			"	-1," +
			"	-1," +
			"	'-1'," +
			"	-1," +
			"	-1," +
			"	-1," +
			"	-1," +
			"	'-1'," +
			"	-1," +			
			"	ita.seq" +			
			" FROM" +
			"	cupd_import_template_attr ita" +
			" WHERE ita.template_id=" + sTemplateId +
			" AND ita.attr_id = -1" + 			
			" ORDER BY ita.seq";
		
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

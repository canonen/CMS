<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.ntt.*, 
			java.io.*, 
			java.text.*, 
			java.sql.*, 
			java.util.*,
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
	String sEntityId = BriteRequest.getParameter(request,"entity_id");

	if((sTemplateId == null)&&(sEntityId == null)) return;

	EntityImportTemplate eit = null;

	if(sTemplateId != null)
	{
		eit = new EntityImportTemplate(sTemplateId);
	}
	else
	{
		eit = new EntityImportTemplate();
		eit.s_entity_id = sEntityId;
	}

	Entity e = new Entity(eit.s_entity_id);
	Customer cust = new Customer(e.s_cust_id);
%>
<HTML>
<HEAD>
<title>FTP Import Edit</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>
<BODY onload="Init();">
<FORM name='ftp_import_form' action='entity_import_template_save.jsp' method=POST>
<INPUT type='hidden' name='template_id' value='<%=HtmlUtil.escape(eit.s_template_id)%>'>
<INPUT type='hidden' name='entity_id' value='<%=HtmlUtil.escape(e.s_entity_id)%>'>
<INPUT type='button' value='Save' onClick='save();'>
<H4>Customer: <%=cust.s_cust_name%> (ID = <%=cust.s_cust_id%>)</H4>
<H4>Entity: <%=e.s_entity_name%> (ID = <%=e.s_entity_id%>)</H4>
<H4>Template name: <INPUT type="text" name="template_name" value="<%=HtmlUtil.escape(eit.s_template_name)%>"> (ID = <%=eit.s_template_id%>)</H4>		
<BR><BR>
<TABLE cellpadding=1 cellspacing=0 border=1>
	<TR>
		<TD>		
<CENTER><H4>How to process ...</H4></CENTER>
<TABLE>
	<TR>
		<TD>first_row</TD>
		<TD><INPUT type="text" name="first_row" value="<%=HtmlUtil.escape(eit.s_first_row)%>"></TD>
		<TD>field_separator</TD>
		<TD><INPUT type="text" name="field_separator" value="<%=HtmlUtil.escape(eit.s_field_separator)%>"></TD>
	</TR>
</TABLE>
	</TR>
	<TR>
		<TD colspan=4>
<CENTER><H4>Mappings ...</H4></CENTER>
<SELECT multiple name="entity_import_template_attrs" style="width: 0; height: 0;"></SELECT>
<TABLE cellpadding="0" cellspacing="0" border="0" class="main" width="100%"> 
	<TR> 
		<TD width="40%" valign="middle" align="center">
			<SELECT name="target" size="10" style="width: 100%" onDblClick="removeField()">
			<%EntityAttrs mapped_attrs = getMappedAttrs(eit.s_template_id);%>
			<%=toHtmlOptions(mapped_attrs)%>
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
			<%EntityAttrs entity_attrs = getEntityAttrs(e.s_entity_id);%>
			<%=toHtmlOptions(entity_attrs)%>
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
		var fif_ops = ftp_import_form.entity_import_template_attrs.options;

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
private static EntityAttrs getMappedAttrs(String sTemplateId) throws Exception
{
	EntityAttrs cas = new EntityAttrs();

	cas.m_sRetrieveSql = 
			" SELECT" +
			"	attr_id," +
			"	-1," +
			"	-1," +
			"	'attr_name'," +
			"	-1," +
			"	-1," +
			"	-1" +
			" FROM" +
			"	cntt_entity_import_template_attr eita" +
			" WHERE" +
			"	eita.template_id=" + sTemplateId +			
			" ORDER BY eita.seq";
	
	cas.retrieve();

	return cas;
}

private static EntityAttrs getEntityAttrs(String sEntityId) throws Exception
{
	EntityAttrs eas = new EntityAttrs();

	eas.m_sRetrieveSql = 
		"EXEC usp_cntt_entity_attrs_4_import_get @entity_id=" + sEntityId;
	eas.retrieve();

	return eas;

//
//			" SELECT" +
//			"	attr_id," +
//			"	entity_id," +
//			"	type_id," +
//			"	attr_name," +
//			"	scope_id," +
//			"	internal_id_flag," +
//			"	fingerprint_seq" +
//			" FROM cntt_entity_attr" +
//			" WHERE entity_id=" + sEntityId +
//			" ORDER BY attr_id ";

}

private static String toHtmlOptions(EntityAttrs eas)
{
	return toHtmlOptions(eas, null);
}
private static String toHtmlOptions(EntityAttrs eas, String sSelectedId)
{
	StringWriter sw = new StringWriter();

	EntityAttr ea = null;
	for(Enumeration e = eas.elements(); e.hasMoreElements(); )
	{
		ea = (EntityAttr) e.nextElement();
		sw.write(
			"<OPTION value=\"" + ea.s_attr_id + "\"" +
			(ea.s_attr_id.equals(sSelectedId)?" selected":"")  + ">" +
			HtmlUtil.escape(ea.s_attr_name) + "</OPTION>\r\n");
	}
	return sw.toString();
}
%>

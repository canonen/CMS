<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			java.io.*,java.sql.*,
			java.util.*,org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

String sFromAddressId = request.getParameter("from_address_id");

FromAddress fa = null;

if( sFromAddressId == null)
{
	fa = new FromAddress();
	fa.s_cust_id = cust.s_cust_id;
}
else fa = new FromAddress(sFromAddressId);
%>
<%
	ConnectionPool cp = null;
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null; 
	String sSql = null;
	String sDomainId = null;	
	ArrayList arrDomain = new ArrayList();
	
	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();

		sSql =  " SELECT domain_id, domain" +
				" FROM cadm_vanity_domain vd, cadm_mod_inst mi" +
				" WHERE vd.cust_id=" + cust.s_cust_id +
				" AND vd.mod_inst_id=mi.mod_inst_id" +
				" AND mi.mod_id=" + Module.AINB +
				" ORDER BY domain";

		rs = stmt.executeQuery(sSql);
		while(rs.next())
		{
			sDomainId = rs.getString(1);
			arrDomain.add(rs.getString(2));
		}
		rs.close();
	}
	catch(Exception ex)
	{
		ErrLog.put(this, ex, "Error in " + this.getClass().getName() , out, 1);
	}
	finally
	{
		if(conn!=null) cp.free(conn);
	}

%>

<HTML>
<HEAD>
	<TITLE></TITLE>
	<%@ include file="../../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="javascript">
function checkBeforeSave()
{
	var pref = document.from_address.prefix.value;
	var domainName = document.from_address.domain.value;
	
	if( (pref == null) || (pref == "") )
	{
		alert('Please provide a valid email address prefix for the From Address');
	}
	else if( (domainName == null) || (domainName == "") )
	{
		alert('Please provide a valid domain address for the From Address');
	}
	
	if( (pref != null) && (pref != "") && (domainName != null) && (domainName != "") )
	{
		if(domainName.indexOf(".") >= 1)
		{
			from_address.submit();
		}
		else
		{	
			alert('Invalid domain address');
		}
	}
}
</script>	
</HEAD>

<BODY>
<FORM method="POST" action="from_address_save.jsp" name="from_address">
<% if(fa.s_from_address_id != null) { %>
	<INPUT type="hidden" name="from_address_id" size="50" readonly value=<%=fa.s_from_address_id%>>
<% } %>
<table cellspacing="0" cellpadding="3" border="0">
	<tr>
		<td align="left" valign="middle">
			<a class="savebutton" href="#" onClick="checkBeforeSave();">Save</a>
		</td>
	</tr>
</table>
<br>
<TABLE cellpadding="0" cellspacing="0" class="listTable" width="400">
	<TR>
		<% if (sFromAddressId != null){	%>
		<th class="sectionheader"><B class="sectionheader">Step 1:</B> Edit from address</th>
		<% }else{ %>
		<th class="sectionheader"><B class="sectionheader">Step 1:</B> Enter New from address</th>
		<% }%>
	</TR>
	<tr>
		<td>
			<table border="0" cellspacing="1" cellpadding="2">
				<TR>
					<Td width=150 align="left">Prefix</Td>
					<TD><INPUT type="text" id="prefix" name="prefix" size="45" value=<%=(fa.s_prefix==null)?"":fa.s_prefix%>></TD>
				</TR>
				<TR>
					<TD colspan="2">@</TD>
				</tr>
				<tr>
					<Td width=150>Domain</Td>
					<% if ( (arrDomain.isEmpty()) && (fa.s_domain == null) ){ %>
					<TD><INPUT type="text" id="domain" name="domain" size="45" value=""></TD>
					<%} else { %>
					<TD>
						<SELECT name="domain" size="1">
							<OPTION value="<%=(fa.s_domain==null)?"":fa.s_domain%>" selected><%=(fa.s_domain==null)?"":fa.s_domain%></OPTION>					
							<% for(int i=0; i< arrDomain.size(); i++ ){%>
							<OPTION value=<%=arrDomain.get(i)%>><%=arrDomain.get(i)%></OPTION>
							<%}%>
						</SELECT>
					</TD>
					<%}%>
				</TR>
			</TABLE>
		</td>
	</tr>
</table>
<br><br>
</FORM>
</BODY>
</HTML>

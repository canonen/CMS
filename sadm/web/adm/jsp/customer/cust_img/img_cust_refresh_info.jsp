<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../../header.jsp" %>

<%
String sCustId = BriteRequest.getParameter(request, "cust_id");
ImgCustRefreshInfo icri = new ImgCustRefreshInfo(sCustId);
if(icri.s_refresh_url == null) icri.s_refresh_url = "http://cdm.mirror-image.com/InstaContent/autopost.cgi";
if(icri.s_immediate_refresh_flag == null) icri.s_immediate_refresh_flag = "1";
%>

<HTML>
<HEAD>
	<TITLE></TITLE>
	<%@ include file="../../header.html" %>
	<LINK rel="stylesheet" href="../../../css/style.css" type="text/css">
</HEAD>

<BODY>

<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%;">
	<col>
	<tr height="35">
		<td valign="top">
			<table cellpadding="4" cellspacing="0" border="0">
				<tr>
					<td vAlign="middle" align="left">
						<a class="savebutton" href="#" onclick="FT.submit()">Save</a>&nbsp;&nbsp;&nbsp;
					</td>
				</tr>
			</table>
			<br>
		</td>
	</tr>
	<tr>
		<td>
			<table id="Tabs_Table1" cellspacing="0" cellpadding="0" border="0" class="layout" style="width:650;">
				<col width="150">
				<col>
				<tr height="20">
					<td class="EditTabOn" id="tab1_Step1" valign="center" nowrap align="middle">UI Settings</td>
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center" colspan="2">
					
<FORM name="FT" method="POST" action="img_cust_refresh_info_save.jsp">
<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
	<tr>
		<td width="150">cust_id</td>
		<td><INPUT type="text" name="cust_id" size="50" readonly value="<%=icri.s_cust_id%>"></td>
	</tr>
	<tr>
		<td width="150">domain_prefix</td>
		<td><INPUT type="text" name="domain_prefix" size="50" value="<%=HtmlUtil.escape(icri.s_domain_prefix)%>"></td>
	</tr>
	<tr>
		<td width="150">refresh_url</td>
		<td><INPUT type="text" name="refresh_url" size="50" value="<%=HtmlUtil.escape(icri.s_refresh_url)%>"></td>
	</tr>
	<tr>
		<td width="150">immediate_refresh_flag</td>
		<td>
		<SELECT name="immediate_refresh_flag">
			<OPTION value=0<%=("0".equals(icri.s_immediate_refresh_flag))?" selected":""%>>0</OPTION>
			<OPTION value=1<%=("1".equals(icri.s_immediate_refresh_flag))?" selected":""%>>1</OPTION>
		</SELECT>		
	</tr>
	<tr>
		<td width="150">login_id</td>
		<td><INPUT type="text" name="login_id" size="50" value="<%=HtmlUtil.escape(icri.s_login_id)%>"></td>
	</tr>
	<tr>
		<td width="150">login_pwd</td>
		<td><INPUT type="text" name="login_pwd" size="50" value="<%=HtmlUtil.escape(icri.s_login_pwd)%>"></td>
	</tr>
</table>
</FORM>

					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
</table>
</BODY>
</HTML>

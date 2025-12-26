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
CustUiSettings cus = new CustUiSettings(sCustId);
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
						<FORM name="FT" method="POST" action="cust_ui_settings_save.jsp">
						<table class="main" border="0" cellspacing="1" cellpadding="3" width="100%">
							<tr>
								<td width="150">cust_id</td>
								<td><INPUT type="text" name="cust_id" size="50" readonly value="<%=cus.s_cust_id%>"></td>
							</tr>
							<tr style="display:none;">
								<td width="150">css_filename</td>
								<td><INPUT type="text" name="css_filename" size="50" value="<%=(cus.s_css_filename==null)?"":cus.s_css_filename%>"></td>
							</tr>
							<tr style="display:none;">
								<td width="150">frame_dir</td>
								<td><INPUT type="text" name="frame_dir" size="50" value="<%=(cus.s_frame_dir==null)?"":cus.s_frame_dir%>"></td>
							</tr>
							<tr>
								<td width="150">config_file</td>
								<td><INPUT type="text" name="config_file" size="50" value="<%=(cus.s_config_file==null)?"":cus.s_config_file%>"></td>
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

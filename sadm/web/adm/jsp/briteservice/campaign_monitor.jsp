<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="com.britemoon.sas.imc.*" 
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*" 
	import="org.w3c.dom.*"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<%

String order_by = BriteRequest.getParameter(request, "order_by");
if ((order_by == null) || ("".equals(order_by))) {
	order_by = "cust_name";
}

String machine_id = BriteRequest.getParameter(request, "machine_id");
if ((machine_id == null) || ("".equals(machine_id))) {
	machine_id = "0";
}

String cust_id = BriteRequest.getParameter(request, "cust_id");
if ((cust_id == null) || ("".equals(cust_id))) {
	cust_id = "0";
}

String cust_name = BriteRequest.getParameter(request, "cust_name");
if ((cust_name == null) || ("".equals(cust_name))) {
	cust_name = "";
}

String camp_id = BriteRequest.getParameter(request, "camp_id");
if ((camp_id == null) || ("".equals(camp_id))) {
	camp_id = "";
}
String action = BriteRequest.getParameter(request, "action");
if ((action == null) || ("".equals(action))) {
	action = "";
}
SystemAccessPermission canCust = systemuser.getAccessPermission(SystemObjectType.CUSTOMER);
if (!canCust.bRead){
	response.sendRedirect("../access_denied.jsp");
	return;
}

SystemAccessPermission canCustUser = systemuser.getAccessPermission(SystemObjectType.CUSTOMER_USER);
SystemAccessPermission canServ = systemuser.getAccessPermission(SystemObjectType.SERVER);
boolean isSuperUser = (systemuser.s_super_user_flag != null && systemuser.s_super_user_flag.equals("1"));

ConnectionPool cp = null;
Connection conn = null;
Statement	stmt = null;
ResultSet	rs = null; 
String sSQL = null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();	
%>
<html>
<head>
<title>BriteService</title>
<link rel="stylesheet" href="../../css/style.css" type="text/css">
<link rel="stylesheet" href="briteservice.css" type="text/css">
<script language="javascript" src="briteservice.js"></script>
<script language="javascript">

	function refreshList()
	{
		var machine, orderBy;		
		machine = FT.machine_id.value;
		orderBy = FT.order_by[FT.order_by.selectedIndex].value;		
		var sURL = "campaign_monitor.jsp?machine_id="+ machine + "&order_by="+ orderBy;		
		location.href = sURL;
	}

	function refreshCust()
	{
		var selected_cust_id = document.getElementById("cust_id").value;
		var selected_cust_name = document.getElementById("cust_name").value;
		if (selected_cust_id == "0" && selected_cust_name == "") {
			alert("Please select a customer");
			return;
		}
		loadCust(selected_cust_id, selected_cust_name);
	}
	
	function approveCamp(camp_id)
	{
		var selected_cust_id = document.getElementById("cust_id").value;
		var selected_cust_name = document.getElementById("cust_name").value;
		if (selected_cust_id == "0" && selected_cust_name == "") {
			alert("Please select a customer");
			return;
		}
		document.getElementById("camp_id").value = camp_id;
		document.getElementById("action").value = "approve";
		loadCust(selected_cust_id, selected_cust_name);
	}
	
	function suspendCamp(camp_id)
	{
		var selected_cust_id = document.getElementById("cust_id").value;
		var selected_cust_name = document.getElementById("cust_name").value;
		if (selected_cust_id == "0" && selected_cust_name == "") {
			alert("Please select a customer");
			return;
		}
		document.getElementById("camp_id").value = camp_id;
		document.getElementById("action").value = "suspend";
		loadCust(selected_cust_id, selected_cust_name);
	}

	function setCampStatus(camp_id, cps_status_id, rcp_status_id)
	{
		var selected_cust_id = document.getElementById("cust_id").value;
		var selected_cust_name = document.getElementById("cust_name").value;
		if (selected_cust_id == "0" && selected_cust_name == "") {
			alert("Please select a customer");
			return;
		}
		document.getElementById("camp_id").value = camp_id;

		var Module = "CCPS_Login";
		var destURL = "set_camp_status.jsp?camp_id=" + camp_id + "&cust_id=" + selected_cust_id + "&cps_status_id=" + cps_status_id + "&rcp_status_id=" + rcp_status_id;
		destURL = "redirect.jsp?cust_id=" + selected_cust_id + "&url=" + encodeURIComponent(destURL);
		gotoSiteSlim(destURL, Module);;
	}
				
	var pastCustIDs = getCookie("pastCustIDs") || "0";
	
	function loadCust(cust_id, cust_name)
	{	
		if ((cust_id != "0") && (cust_id != ""))
		{
			CustNameBox.innerHTML = "Loading...";
			toggleObj(document.getElementById("dataArea"), "hide");
			custArea.innerHTML = "";
			document.getElementById("cust_id").value = cust_id;
			document.getElementById("cust_name").value = cust_name;
			var dCustList = document.getElementById("cust_list");
			dCustList.addRecentRow(cust_id, cust_name, pastCustIDs);
			setCookie(pastCustIDs, "pastCustIDs", cust_id + "xxx" + cust_name + "," + pastCustIDs);
			loadData(cust_id);
		}
		else
		{
			CustNameBox.innerHTML = "";
			toggleObj(document.getElementById("dataArea"), "hide");
			custArea.innerHTML = "";
			document.getElementById("cust_id").value = "0";
			document.getElementById("cust_name").value = "";
			loadData("0");
		}
	}
	
	var httpData;
	function loadData(cust_id)
	{
		if ((cust_id != "0") && (cust_id != ""))
		{
			if (document.all)
			{ 
				httpData = new ActiveXObject("Msxml2.XMLHTTP"); 
			}
			else
			{ 
				httpData = new XMLHttpRequest(); 
			}
			var camp_id = document.getElementById("camp_id").value;
			var action = document.getElementById("action").value;
			httpData.onreadystatechange = httpDataChange;
			httpData.open("GET", "xml_get_campaigns_for_cust.jsp?cust_id=" + cust_id + "&camp_id=" + camp_id + "&action=" + action, false);
			httpData.send();          
		}
	}
		
	function httpDataChange()
	{
		if (httpData.readyState == 4)
		{
			
			var _oXsl = new ActiveXObject("Msxml2.FreeThreadedDOMDocument");

			_oXsl.async = false;
			_oXsl.load("campaign_list.xsl");

			var oXslTemplate = new ActiveXObject("Msxml2.XSLTemplate");
			oXslTemplate.stylesheet = _oXsl;
			
			var oXslProc = oXslTemplate.createProcessor();
			oXslProc.input = httpData.responseXML;

			oXslProc.transform();
			
			custArea.innerHTML = oXslProc.output;

			var cust_id, cust_name;
			cust_id = document.getElementById("cust_id").value;
			cust_name = document.getElementById("cust_name").value;	
			CustNameBox.innerHTML = cust_name + " (" + cust_id + ")";
			
 			toggleObj(document.getElementById("dataArea"), "show");
		}
	} 

	
</script>
</head>
<body onload="loadCust('<%= cust_id %>', '<%= cust_name %>');">
<form name="FT" id="FT" style="display:inline;">
<table class="layout" style="width:100%; height:100%;" cellspacing="0" cellpadding="0" border="0">
	<tr height="35">
		<td valign="top">
			<table cellspacing="0" cellpadding="0" border="0" width="100%">
				<tr>
					<td align="left" valign="top" width="100%">
						<table cellpadding="0" cellspacing="0" border="0" class="layout">
							<col width="300">
							<col width="20">
							<col>
							<col width="200">
							<tr>
								<td align="left" valign="middle">
									<div id="cust_list" class="dropDown" defaulttext="Select A Customer" canclick="yes" slcolor="#abc0e7" hlcolor="#abc0e7" doonclick="yes" setrecent="yes">
										<table class="dropDownTable" cellspacing="0" cellpadding="2" style="display:none;" width="100%" id="cust_list">
											<col width="4" style="padding-left:5px; cursor:default; font-size:8pt; font-family:Verdana;" />
											<col style="padding-left:5px; cursor:default; font-size:8pt; font-family:Verdana;" />
										<%
										String partner_clause = "and p.partner_id = '" + systemuser.s_partner_id + "'";
										if (isSuperUser) {
											//britemoon superuser can see everything
											if (systemuser.s_partner_id.equals("86")) {
												partner_clause = "";
											}
										%>	
											<tr noHL="1" sortval="0" clickAction="loadCust('', '');" name="Internal Systems">
												<td colspan="2" style="border-bottom: 1px solid #3C3C3C;"><b>Internal Systems</b></td>
											</tr>
											<tr noHL="0" sortval="0" clickAction="loadCust('248', 'Revotas Production');">
												<td></td>
												<td>Revotas Production (248)</td>
											</tr>
											<tr noHL="0" sortval="0" clickAction="loadCust('3', 'Demo');">
												<td></td>
												<td>Demo (3)</td>
											</tr>
											<tr noHL="0" sortval="0" clickAction="loadCust('242', 'QA');">
												<td></td>
												<td>QA (242)</td>
											</tr>
										<%} %>
											<tr noHL="1" sortval="0" clickAction="loadCust('', '');" name="Select A Customer">
												<td colspan="2" style="border-bottom: 1px solid #3C3C3C;"><b>Select A Customer</b></td>
											</tr>
										<%
										if ("cust_name".equals(order_by))
										{
												sSQL = "select c.cust_id, c.cust_name, SUBSTRING(c.cust_name, 1,1) " +
													" from sadm_customer c with(nolock)" +
													" left outer join sadm_cust_mod_inst cmi with(nolock) on c.cust_id = cmi.cust_id" +
													" left outer join sadm_mod_inst mi with(nolock) on mi.mod_inst_id = cmi.mod_inst_id" +
													" inner join sadm_machine ma with(nolock) on ma.machine_id = mi.machine_id" +
													" left outer join sadm_cust_partner pc with(nolock) on c.cust_id = pc.cust_id" +
													" left outer join sadm_partner p with(nolock) on p.partner_id = pc.partner_id" +
													" where c.status_id = 3 " + partner_clause;
													
											if (!"0".equals(machine_id))
											{
												sSQL += " and ma.machine_id = '" + machine_id + "'";
											}
											
											sSQL += " group by c.cust_name, c.cust_id" +
													" order by c.cust_name, c.cust_id";
										}
										else
										{
											sSQL = "select c.cust_id, c.cust_name, SUBSTRING(CAST(c.cust_id as varchar(16)), 1,1)" +
													" from sadm_customer c with(nolock)" +
													" left outer join sadm_cust_mod_inst cmi with(nolock) on c.cust_id = cmi.cust_id" +
													" left outer join sadm_mod_inst mi with(nolock) on mi.mod_inst_id = cmi.mod_inst_id" +
													" inner join sadm_machine ma with(nolock) on ma.machine_id = mi.machine_id" +
													" left outer join sadm_cust_partner pc with(nolock) on c.cust_id = pc.cust_id" +
													" left outer join sadm_partner p with(nolock) on p.partner_id = pc.partner_id" +
													" where c.status_id = 3 " + partner_clause;
													
											if (!"0".equals(machine_id))
											{
												sSQL += " and ma.machine_id = '" + machine_id + "'";
											}
											
											sSQL += " group by c.cust_name, c.cust_id" +
													" order by c.cust_id, c.cust_name";
										}

										rs = stmt.executeQuery(sSQL);

										String sCustID = null;
										String sCustName = null;
										String sSortVal = null;

										byte[] b = null;
										while(rs.next())
										{
											sCustID = rs.getString(1);
											
											b = rs.getBytes(2);
											sCustName = (b==null)?null:new String(b,"UTF-8");
											
											b = rs.getBytes(3);
											sSortVal = (b==null)?null:new String(b,"UTF-8");
											%>
											<tr noHL="0" clickAction="loadCust('<%= sCustID %>', '<%= sCustName %>');" sortval="<%= sSortVal %>">
												<td></td>
											<% if ("cust_name".equals(order_by)) { %>
												<td><%= sCustName %> (<%= sCustID %>)</td>
											<% } else { %>
												<td><%= sCustID %> (<%= sCustName %>)</td>
											<% } %>
											</tr>
											<%
										}
										rs.close();
										%>
										</table>
									</div>
								</td>
								<td align="center" valign="middle"><img src="icoRefresh.gif" alt="Refresh Customer List" style="cursor:hand;" onclick="refreshList();"></td>
								<td align="center" valign="middle">
									&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								</td>
								<td align="right" valign="middle">
									Order By: &nbsp;<select name="order_by" id="order_by" onchange="refreshList();">
										<option value="cust_name"<% if ("cust_name".equals(order_by)) { %> selected<% } %>>Customer Name</option>
										<option value="cust_id"<% if ("cust_id".equals(order_by)) { %> selected<% } %>>Customer ID</option>
									</select>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr height="40">
		<td class="top_heading" id="CustNameBox"></td>
	</tr>
	<tr id="dataArea" style="display:none;">
		<td valign="top" align="left">
			<table id="Tabs_Table1" class="layout" style="width:100%; height:100%;" cellspacing="0" cellpadding="0" border="0">
				<col width="150">
				<col>
				<tr height="22">
					<td class="EditTabOn" valign="center" nowrap align="middle">Active Campaigns</td>
					<td class="EmptyTab"  valign="center" nowrap align="middle"><img height="2" src="../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="1">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="left" colspan="2">
						<table class="layout" style="width:100%; height:100%;" cellspacing="0" cellpadding="0" border="0">
							<col width="500">
							<col>
							<tr>
								<td colspan="2" valign="top" align="left">
									<div id="custArea" style="width:100%; height:100%;"></div>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<div style="display:none;">
	<input type="hidden" name="machine_id" id="machine_id" value="<%= machine_id %>">
	<input type="hidden" name="cust_id" id="cust_id" value="000">
	<input type="hidden" name="cust_name" id="cust_name" value="">
	<input type="hidden" name="camp_id" id="camp_id" value="">
	<input type="hidden" name="action" id="action" value="">
	<input type="hidden" name="type_id_user_login" id="type_id_user_login" value="<%= SystemUserActivityType.USER_LOGIN %>">
	<input type="hidden" name="type_id_system_admin" id="type_id_system_admin" value="<%= SystemUserActivityType.SYSTEM_ADMIN %>">
</div>
</form>
</body>
</html>
<%
}
catch(Exception ex)
{
	ex.printStackTrace(response.getWriter());
}
finally
{
	if(conn!=null) cp.free(conn);
}
%>
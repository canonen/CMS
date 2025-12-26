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

if((order_by == null) || ("".equals(order_by)))
{
	order_by = "cust_name";
}

String machine_id = BriteRequest.getParameter(request, "machine_id");

if((machine_id == null) || ("".equals(machine_id)))
{
	machine_id = "0";
}

SystemAccessPermission canServ;
canServ = systemuser.getAccessPermission(SystemObjectType.SERVER);

if(!canServ.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

SystemAccessPermission canCust;
canCust = systemuser.getAccessPermission(SystemObjectType.CUSTOMER);

SystemAccessPermission canCustUser;
canCustUser = systemuser.getAccessPermission(SystemObjectType.CUSTOMER_USER);

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

	function loadMachine(machine_id, machine_name, machine_ip)
	{	
		if (machine_id != "")
		{
			MachineNameBox.innerHTML = "Loading...";
			toggleObj(document.getElementById("dataArea"), "hide");
			document.getElementById("cust_list").location.href = "blank.htm";
			
			document.getElementById("machine_id").value = machine_id;
			document.getElementById("machine_name").value = machine_name;
			document.getElementById("machine_ip").value = machine_ip;
			
			loadModules(machine_id);
		}
		else
		{
			MachineNameBox.innerHTML = "";
			toggleObj(document.getElementById("dataArea"), "hide");
			document.getElementById("cust_list").location.href = "blank.htm";
			
			document.getElementById("machine_id").value = "";
			document.getElementById("machine_name").value = "";
			document.getElementById("machine_ip").value = "";
		}
	}
	
	var httpModules;

	function loadModules(machine_id)
	{
		if ((machine_id != "0") && (machine_id != ""))
		{
			if (document.all)
			{ 
				httpModules = new ActiveXObject("Msxml2.XMLHTTP"); 
			}
			else
			{ 
				httpModules = new XMLHttpRequest(); 
			}
			
			httpModules.onreadystatechange = httpModulesChange;
			httpModules.open("GET", "xml_get_modules_for_machine.jsp?machine_id=" + machine_id, false);
			httpModules.send();          
		}
	}
	
	function httpModulesChange()
	{
		if (httpModules.readyState == 4)
		{
			document.getElementById("Module_AINB").value = "0";
			document.getElementById("Module_AJTK").value = "0";
			document.getElementById("Module_ASBS").value = "0";
			document.getElementById("Module_CCPS").value = "0";
			document.getElementById("Module_CCTM").value = "0";
			document.getElementById("Module_CXCS").value = "0";
			document.getElementById("Module_RRCP").value = "0";
			document.getElementById("Module_RQUE").value = "0";
			document.getElementById("Module_RSYN").value = "0";
			document.getElementById("Module_SADM").value = "0";

			document.getElementById("IPtextBox").innerHTML = "";

			var IPTextBoxHTML = "";
			var s_abbr, s_ip, s_serv, s_db, s_user, s_pwd;
			
			IPTextBoxHTML = "<table cellspacing=\"0\" cellpadding=\"0\" border=\"0\">";

			var nodes = httpModules.responseXML.selectNodes("/MachineModules/module");
				
			if (nodes.length >= 1)
			{
				for (var i=0; i<nodes.length; i++)
				{
					s_abbr = getXMLNodeData(nodes(i), "module_abbr");
					s_ip = getXMLNodeData(nodes(i), "machine_ip");
					s_serv = getXMLNodeData(nodes(i), "sql_ip");
					s_db = getXMLNodeData(nodes(i), "db_name");
					s_user = getXMLNodeData(nodes(i), "db_user");
					s_pwd = getXMLNodeData(nodes(i), "db_pass");
					
					document.getElementById("Module_" + s_abbr).value = s_ip;

					IPTextBoxHTML += "<tr>";
						IPTextBoxHTML += "<td valign=\"middle\" align=\"right\" class=\"gridPreviewLabel\" nowrap><b>" + s_abbr + ":&nbsp;</b></td>";
						IPTextBoxHTML += "<td valign=\"middle\" align=\"left\" class=\"gridPreviewData\" nowrap>";
						IPTextBoxHTML += "<a href=\"#\" language=\"vbscript\" onclick=\"loadSQL '" + s_serv + "', '" + s_db + "', '" + s_user + "', '" + s_pwd + "'\">" + s_ip + "</a></td>";//&nbsp;&nbsp;<a href=\"#\" style=\"font-weight:normal; font-size:7pt;\" language=\"vbscript\" onclick=\"loadVNC '" + s_serv + "'\">(VNC)</a></td>";
					IPTextBoxHTML += "</tr>";
				}

				IPTextBoxHTML += "</table>";

				document.getElementById("IPtextBox").innerHTML = IPTextBoxHTML;
			
				var machine_id, machine_name;
				machine_id = document.getElementById("machine_id").value;
				machine_name = document.getElementById("machine_name").value;
				
				document.getElementById("cust_list").location.href = "index.jsp?machine_id=" + machine_id;
				
				MachineNameBox.innerHTML = machine_name + " (" + machine_id + ")&nbsp;&nbsp;<a class=\"resourcebutton\" target=\"_top\" href=\"../index.jsp?tab=Serv&sec=1&url=software%2Fmachine_edit_frame.jsp%3Fmachine_id%3D" + machine_id + "\">edit</a>";

				toggleObj(document.getElementById("dataArea"), "show");
			}
			else
			{
				document.getElementById("Module_AINB").value = "0";
				document.getElementById("Module_AJTK").value = "0";
				document.getElementById("Module_ASBS").value = "0";
				document.getElementById("Module_CCPS").value = "0";
				document.getElementById("Module_CCTM").value = "0";
				document.getElementById("Module_CXCS").value = "0";
				document.getElementById("Module_RRCP").value = "0";
				document.getElementById("Module_RQUE").value = "0";
				document.getElementById("Module_RSYN").value = "0";
				document.getElementById("Module_SADM").value = "0";
				
				document.getElementById("IPtextBox").innerHTML = "";
				
				toggleObj(document.getElementById("dataArea"), "hide");
			}
		}
	}
	
</script>
<script language="vbscript">
	
	Function loadSQL(server, db, uid, pwd)
	
		'MsgBox "isqlw -S " & server & " -d " & db & " -U " & uid & " -P " & pwd
		
		Dim ss
		Set ss = CreateObject("WScript.Shell")
		ss.run "isqlw -S " & server & " -d " & db & " -U " & uid & " -P " & pwd, 3
		Set ss = nothing
		
	End Function
	
</script>
</head>
<body>
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
							<tr>
								<td align="left" valign="middle">
									<div id="machine_list" class="dropDown" defaulttext="Select A Server" canclick="yes" slcolor="#abc0e7" hlcolor="#abc0e7" doonclick="yes" setrecent="yes">
										<table class="dropDownTable" cellspacing="0" cellpadding="2" style="display:none;" width="100%" id="cust_list">
											<col width="4" style="padding-left:5px; cursor:default; font-size:8pt; font-family:Verdana;" />
											<col style="padding-left:5px; cursor:default; font-size:8pt; font-family:Verdana;" />
											<tr noHL="1" sortval="0" clickAction="loadCust('', '');" name="Select A Customer">
												<td colspan="2" style="border-bottom: 1px solid #3C3C3C;"><b>Select A Server</b></td>
											</tr>
										<%
										sSQL = "SELECT ma.machine_id, " +
												" LTRIM(substring(ma.machine_name, CHARINDEX('-', ma.machine_name) + 1, (LEN(ma.machine_name) - CHARINDEX('-', ma.machine_name) + 1))) As 'MachineName', " +
												" ma.IP_Address, " + 
												" SUBSTRING(LTRIM(substring(ma.machine_name, CHARINDEX('-', ma.machine_name) + 1, (LEN(ma.machine_name) - CHARINDEX('-', ma.machine_name) + 1))), 1,1)" +
												" FROM sadm_machine ma with(nolock)" +
												" ORDER BY 2";

										rs = stmt.executeQuery(sSQL);

										String sMachineID = null;
										String sMachineName = null;
										String sIP = null;
										String sSortVal = null;

										byte[] b = null;
										while(rs.next())
										{
											sMachineID = rs.getString(1);
											
											b = rs.getBytes(2);
											sMachineName = (b==null)?null:new String(b,"UTF-8");
											
											b = rs.getBytes(3);
											sIP = (b==null)?null:new String(b,"UTF-8");
											
											b = rs.getBytes(4);
											sSortVal = (b==null)?null:new String(b,"UTF-8");
											%>
											<tr noHL="0" clickAction="loadMachine('<%= sMachineID %>', '<%= sMachineName %>', '<%= sIP %>');" sortval="<%= sSortVal %>">
												<td></td>
												<td><%= sMachineName %> (<%= sIP %>)</td>
											</tr>
											<%
										}
										rs.close();
										%>
										</table>
									</div>
								</td>
								<td align="center" valign="middle"><img src="icoRefresh.gif" alt="Refresh Server List" style="cursor:hand;" onclick="refreshList();"></td>
								<td align="center" valign="middle">
									&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr height="40">
		<td class="top_heading" id="MachineNameBox"></td>
	</tr>
	<tr id="dataArea" style="display:none;">
		<td valign="top" align="left">
			<table id="Tabs_Table1" class="layout" style="width:100%; height:100%;" cellspacing="0" cellpadding="0" border="0">
				<col width="150">
				<col width="150">
				<col>
				<tr height="22">
					<td class="EditTabOn" id="tab1_Step1" onclick="switchSteps('Tabs_Table1', 'tab1_Step1', 'block1_Step1');" valign="center" nowrap align="middle">Module Links</td>
					<td class="EditTabOff" id="tab1_Step2" onclick="switchSteps('Tabs_Table1', 'tab1_Step2', 'block1_Step2');" valign="center" nowrap align="middle">Customers</td>
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="1">
					<td class="fillTabbuffer" valign="top" align="left" colspan="3"><img height="2" src="../../images/blank.gif" width="1"></td>
				</tr>
				<tbody class="EditBlock" id="block1_Step1">
				<tr>
					<td class="fillTab" valign="top" align="left" colspan="3">
						<table cellspacing="0" cellpadding="0" class="layout" style="width:100%; height:100%;">
							<col>
							<col width="10">
							<col>
							<col width="10">
							<col>
							<tr height="5">
								<td></td>
								<td></td>
								<td></td>
								<td></td>
								<td></td>
							</tr>
							<tr>
								<td valign="top" class="listSmallHeading">
									<span>RCP Links</span>
									<div style="width:100%; height:100%;">
									<br>
										<a href="javascript:gotoModulePage('RRCP', '/rrcp/adm/index.htm');">Admin Page</a><br><br>
										<li><a href="javascript:gotoModulePage('RRCP', '/rrcp/adm/jsp/timer_manager/timer_manager.jsp');">Timer Manager</a></li>
										<li><a href="javascript:gotoModulePage('RRCP', '/rrcp/adm/jsp/report_log/report_log.jsp');">Report Log</a></li>
										<li><a href="javascript:gotoModulePage('RRCP', '/rrcp/adm/jsp/filter_monitor/filter_monitor.jsp');">Target Group Processing Monitor</a></li>
										<li><a href="javascript:gotoModulePage('RRCP', '/rrcp/adm/jsp/registry.jsp');">Registry</a></li>
									<br><br>
										<li><a href="javascript:gotoModulePage('RRCP', '/rrcp/adm/jsp/task_manager/task_manager.jsp');">Task Manager</a></li>
										<li><a href="javascript:gotoModulePage('RRCP', '/rrcp/adm/jsp/connection_pool.jsp');">Connection Pool</a></li>
										<li><a href="javascript:gotoModulePage('RRCP', '/rrcp/adm/jsp/query_analyzer/sql.jsp');">Query Analyzer</a></li>
										<li><a href="javascript:gotoModulePage('RRCP', '/rrcp/adm/jsp/upd_log/upd_log.jsp');">Update Log</a></li>
										<li><a href="javascript:gotoModulePage('RRCP', '/rrcp/adm/jsp/chunk_monitor/chunk_monitor.jsp');">Chunk Monitor</a></li>
										<li><a href="javascript:gotoModulePage('RRCP', '/rrcp/adm/jsp/current_monitor/current_monitor.jsp');">Current Monitor</a></li>
										<li><a href="javascript:gotoModulePage('RRCP', '/rrcp/adm/jsp/sync_monitor/sync_monitor.jsp');">Sync Monitor</a></li>
										<li><a href="javascript:gotoModulePage('RRCP', '/rrcp/adm/jsp/performance_monitor/performance_monitor.jsp');">Performance Monitor</a></li>
										<li><a href="javascript:gotoModulePage('RRCP', '/rrcp/adm/jsp/billing_camp_report/billing_camp_report_form.jsp');">Billing camp report</a></li>
									</div>
								</td>
								<td></td>
								<td valign="top" class="listSmallHeading">
									<span>CPS Links</span>
									<div style="width:100%; height:100%;">
									<br>
										<a href="javascript:gotoModulePage('CCPS', '/cms/adm/index.htm');">Admin Page</a><br><br>
										<li><a href="javascript:gotoModulePage('CCPS', '/cms/adm/jsp/timer_manager/timer_manager.jsp');">Timer Manager</a></li>
										<li><a href="javascript:gotoModulePage('CCPS', '/cms/adm/jsp/camp/camp_monitor.jsp');">Campaign Monitor</a></li>
										<li><a href="javascript:gotoModulePage('CCPS', '/cms/adm/jsp/session_monitor.jsp');">Session monitor</a></li>
										<li><a href="javascript:gotoModulePage('CCPS', '/cms/adm/jsp/camp/admin_camp_report_form.jsp');">Admin Campaign Report</a></li>
										<li><a href="javascript:gotoModulePage('CCPS', '/cms/adm/jsp/registry.jsp');">Registry</a></li>
									<br><br>
										<li><a href="javascript:gotoModulePage('CCPS', '/cms/adm/jsp/task_manager/task_manager.jsp');">Task Manager</a></li>
										<li><a href="javascript:gotoModulePage('CCPS', '/cms/adm/jsp/connection_pool.jsp');">Connection Pool</a></li>
										<li><a href="javascript:gotoModulePage('CCPS', '/cms/servlet/FTPImportScheduler');">FTP Import Scheduler</a></li>
										<li><a href="javascript:gotoModulePage('CCPS', '/cms/adm/jsp/camp/camp_request_log.jsp');">Campaign Request Log</a></li>
										<li><a href="javascript:gotoModulePage('CCPS', '/cms/adm/jsp/export/custom_export_list.jsp');">Custom Export Setup</a></li>
										<li><a href="javascript:gotoModulePage('CCPS', '/cms/adm/jsp/export/export_list.jsp');">Export List</a></li>
										<li><a href="javascript:gotoModulePage('CCPS', '/cms/adm/jsp/cont/cont_debug.jsp');">Content debug</a></li>
										<li><a href="javascript:gotoModulePage('CCPS', '/cms/adm/jsp/camp/camp_debug.jsp');">Campaign debug</a></li>
									</div>
								</td>
								<td></td>
								<td valign="top" class="listSmallHeading">
									<span>SBS Links</span>
									<div style="width:100%; height:100%;">
									<br>
										<a href="javascript:gotoModulePage('ASBS', '/asbs/adm/');">Admin Page</a><br><br>
										<li><a href="javascript:gotoModulePage('ASBS', '/asbs/adm/jsp/timer_manager/timer_manager.jsp');">Timer Manager</a></li>
										<li><a href="javascript:gotoModulePage('ASBS', '/asbs/adm/jsp/registry.jsp');">Registry</a></li>
										<li><a href="javascript:gotoModulePage('ASBS', '/asbs/adm/jsp/connection_pool.jsp');">Connection Pool</a></li>
										<li><a href="javascript:gotoModulePage('ASBS', '/asbs/adm/jsp/task_manager/task_manager.jsp');">Task Manager</a></li>
									<br><br>
										<li><a href="javascript:gotoModulePage('ASBS', '/asbs/adm/jsp/s_servlet/s_servlet_monitor.jsp');">S Servlet Monitor</a></li>
										<li><a href="javascript:gotoModulePage('ASBS', '/asbs/adm/jsp/s_servlet/cache_monitor.jsp');">Cache Monitor</a></li>
										<li><a href="javascript:gotoModulePage('ASBS', '/asbs/adm/jsp/others/form_monitor.jsp');">Form Monitor</a></li>
										<li><a href="javascript:gotoModulePage('ASBS', '/asbs/adm/jsp/others/sbs_response_monitor.jsp');">Response Monitor</a></li>
										<li><a href="javascript:gotoModulePage('ASBS', '/asbs/adm/jsp/hm/sbs_backlog_hmon.jsp');">HostMonitor Backlog</a></li>
										<li><a href="javascript:gotoModulePage('ASBS', '/asbs/adm/jsp/hm/sbs_response_hm.jsp');">HostMonitor Response</a></li>
									</div>
								</td>
							</tr>
							<tr height="10">
								<td>
								</td>
								<td></td>
								<td>
								</td>
								<td></td>
								<td>
								</td>
							</tr>
							<tr height="160">
								<td valign="top" class="listSmallHeading">
									<span>JTK Links</span>
									<div style="width:100%; height:100%;">
									<br>
										<a href="javascript:gotoModulePage('AJTK', '/ajtk/adm/');">Admin Page</a><br><br>
										<li><a href="javascript:gotoModulePage('AJTK', '/ajtk/adm/jsp/connection_pool.jsp');">Connection Pool</a></li>
										<li><a href="javascript:gotoModulePage('AJTK', '/ajtk/adm/jsp/registry.jsp');">Registry</a></li>
									<br><br>
										<li><a href="javascript:gotoModulePage('AJTK', '/ajtk/adm/jsp/jj_servlet_monitor.jsp');">JJ Servlet Monitor</a></li>
										<li><a href="javascript:gotoModulePage('AJTK', '/ajtk/adm/jsp/jj_cache_monitor.jsp');">JJ Cache Monitor</a></li>
										<li><a href="javascript:gotoModulePage('AJTK', '/ajtk/adm/jsp/jtk_response_monitor.jsp');">Response Monitor</a></li>
									<!--
										<li><a href="javascript:gotoModulePage('AJTK', '/ajtk/adm/jsp/jtk_tomcat_monitor.jsp');">jTomcat Monitor</a></li>
										<li><a href="javascript:gotoModulePage('AJTK', '/ajtk/adm/jsp/jtk_tomcat_log.jsp');">Tomcat Log</a></li>
									-->
										<li><a href="javascript:gotoModulePage('AJTK', '/ajtk/adm/jsp/jtk_response_hm.jsp');">HostMonitor Response</a></li>
									</div>
								</td>
								<td></td>
								<td valign="top" class="listSmallHeading">
									<span>SAS Links</span>
									<div style="width:100%; height:100%;">
									<br>
										<a href="javascript:gotoModulePage('SADM', '/sadm/adm/');">Admin Page</a><br><br>
										<li><a href="javascript:gotoModulePage('SADM', '/sadm/adm/jsp/customer/cust_list.jsp');">Customers</a></li>
										<li><a href="javascript:gotoModulePage('SADM', '/sadm/adm/jsp/software/w_frame.jsp');">Software</a></li>
										<li><a href="javascript:gotoModulePage('SADM', '/sadm/adm/jsp/hm/w_frame.jsp');">HostMonitor</a></li>
									</div>
								</td>
								<td></td>
								<td valign="top" class="listSmallHeading">
									<span>InBound Links</span>
									<div style="width:100%; height:100%;">
									<br>
										<a href="javascript:gotoModulePage('AINB', '/ainb/ui/jsp/login.jsp?company=demo&login=demo&password=pass');">Admin Page</a>
									</div>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				</tbody>
				<tbody class="EditBlock" id="block1_Step2" style="display:inline;">
				<tr>
					<td class="fillTab" valign="top" align="left" colspan="3">
						<table class="layout" style="width:100%; height:100%;" cellspacing="0" cellpadding="0" border="0">
							<col width="500">
							<col>
							<col width="200">
							<tr>
								<td colspan="2" valign="top" align="left">
									<div id="custArea" style="width:100%; height:100%;">
										<iframe id="cust_list" name="cust_list" src="blank.htm" style="width:100%; height:100%;" scroll="auto" frameborder="0" border="0" /></div>
								</td>
								<td valign="top" align="left" style="padding:10px;">
									<table cellspacing="0" cellpadding="3" width="100%">
										<tr>
											<td class="sec bar">Module List</td>
										</tr>
										<tr height="5">
											<td>
											</td>
										</tr>
										<tr>
											<td id="IPtextBox"></td>
										</tr>
										<tr height="10">
											<td>
											</td>
										</tr>
										<tr>
											<td class="sec bar">Common Links</td>
										</tr>
										<tr height="5">
											<td>
											</td>
										</tr>
										<tr>
											<td>
												<li><a href="javascript:gotoModulePage('RRCP', '/rrcp/adm/');">RCP Admin</a></li>
												<li><a href="javascript:gotoModulePage('CCPS', '/cms/adm/');">CPS Admin</a></li>
												<li><a href="javascript:gotoModulePage('ASBS', '/asbs/adm/');">SBS Admin</a></li>
												<li><a href="javascript:gotoModulePage('AJTK', '/ajtk/adm/');">JTK Admin</a></li>
												<li><a href="javascript:gotoModulePage('SADM', '/sadm/adm/');">SAS Admin</a></li>
												<li><a href="javascript:gotoModulePage('AINB', '/ainb/ui/jsp/login.jsp?company=demo&login=demo&password=pass');">InBound Admin</a></li>
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
</table>
<div style="display:none;">
	<input type="hidden" name="machine_id" id="machine_id" value="">
	<input type="hidden" name="machine_name" id="machine_name" value="">
	<input type="hidden" name="machine_ip" id="machine_ip" value="">
	<input type="hidden" name="Module_AINB" id="Module_AINB" value="0">
	<input type="hidden" name="Module_AJTK" id="Module_AJTK" value="0">
	<input type="hidden" name="Module_ASBS" id="Module_ASBS" value="0">
	<input type="hidden" name="Module_CCPS" id="Module_CCPS" value="0">
	<input type="hidden" name="Module_CCTM" id="Module_CCTM" value="0">
	<input type="hidden" name="Module_CXCS" id="Module_CXCS" value="0">
	<input type="hidden" name="Module_RRCP" id="Module_RRCP" value="0">
	<input type="hidden" name="Module_RQUE" id="Module_RQUE" value="0">
	<input type="hidden" name="Module_RSYN" id="Module_RSYN" value="0">
	<input type="hidden" name="Module_SADM" id="Module_SADM" value="0">
	<input type="hidden" name="type_id_user_login" id="type_id_user_login" value="<%= SystemUserActivityType.USER_LOGIN %>">
	<input type="hidden" name="type_id_user_login" id="type_id_system_admin" value="<%= SystemUserActivityType.SYSTEM_ADMIN %>">
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
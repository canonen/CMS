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

<HTML>

<HEAD>
	<TITLE></TITLE>
	<%@ include file="../../header.html" %>
	<LINK rel="stylesheet" href="../../../css/style.css" type="text/css">
	<script language="javascript">
		
		function loadSync(url)
		{
			var newWin;
			var windowName = "SyncWin";
			var windowFeatures = "depedent=yes, scrollbars=yes, resizable=yes, toolbar=no, location=no, menubar=no, height=500, width=700";
			newWin = window.open(url, windowName, windowFeatures);
		}
		
	</script>
</HEAD>
<BODY>
<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%;">
	<col>
	<tr height="35">
		<td valign="top">
			<table cellpadding="4" cellspacing="0" border="0">
				<tr>
					<td vAlign="middle" align="left">
						&nbsp;&nbsp;&nbsp;
					</td>
				</tr>
			</table>
			<br>
		</td>
	</tr>
	<tr>
		<td>
			<table id="Tabs_Table1" cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%;">
				<col width="200">
				<col>
				<tr height="20">
					<td class="EditTabOn" id="tab1_Step1" valign="center" nowrap align="middle">Module Synchronization</td>
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center" colspan="2">
						<table class="listTable" width="100%" cellspacing="0" cellpadding="2" border="0">
							<tr>
								<th>Module Name</th>
								<!--<th>Version</th>//-->
								<th>Machine</th>
								<th>Ip Address</th>
								<th>Synchronize</th>
							</tr>
				<%
				String sCustId = BriteRequest.getParameter(request, "cust_id");	

				String sSql =
							" SELECT" +
								" mo.abbreviation, mi.version, ma.machine_name," +
								" ma.ip_address, cmi.mod_inst_id" +
							" FROM" +
								" sadm_cust_mod_inst cmi, sadm_mod_inst mi," +
								" sadm_module mo, sadm_machine ma," +
								" sadm_mod_inst_service mis" +
							" WHERE" +
								" cmi.cust_id=" + sCustId + " AND" +
								" mi.mod_inst_id = cmi.mod_inst_id AND" +
								" mo.mod_id = mi.mod_id AND" +
								" ma.machine_id = mi.machine_id AND"+
								" mis.mod_inst_id = cmi.mod_inst_id AND" +
								" mis.service_type_id = " + ServiceType.CUST_SETUP +
							" ORDER BY mo.abbreviation";

				String sModName = null;
				String sVersion = null;
				String sMachineName = null;
				String sIpAddress = null;
				String sModInstId = null;

				ConnectionPool cp = null;
				Connection conn = null;

				try
				{
					cp = ConnectionPool.getInstance();
					conn = cp.getConnection(this);

					Statement stmt = null;
					ResultSet rs = null; 
						
					try
					{		
						stmt = conn.createStatement();
 						rs = stmt.executeQuery(sSql);
		
						int iCount = 0;
						String sClassAppend = "";

						while(rs.next())
						{
							if (iCount % 2 != 0) sClassAppend = "_Alt";
							else sClassAppend = "";
							
							++iCount;
							
							sModName = rs.getString(1);
							sVersion = rs.getString(2);
							sMachineName = rs.getString(3);
							sIpAddress = rs.getString(4);
							sModInstId = rs.getString(5);
							%>
							<tr>
								<td class="listItem_Title<%= sClassAppend %>"><%=sModName%></td>
								<!--<td class="listItem_Data<%= sClassAppend %>"><%=sVersion%></td>//-->
								<td class="listItem_Data<%= sClassAppend %>"><%=sMachineName%></td>
								<td class="listItem_Data<%= sClassAppend %>"><%=sIpAddress%></td>
								<td class="listItem_Data<%= sClassAppend %>"><a href="javascript:loadSync('sync.jsp?cust_id=<%=sCustId%>&mod_inst_id=<%=sModInstId%>');">Synchronize</a></td>
							</tr>
							<%
						}
						rs.close();
					}
					catch(SQLException ex)
					{
						throw ex;
					}
					finally
					{
						if(stmt!=null) stmt.close();
					}
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
						</table>
					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
</table>
</BODY>
</HTML>

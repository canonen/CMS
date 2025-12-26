<%@ page
	language="java"
	import="com.britemoon.*, com.britemoon.sas.*, java.net.*, java.io.*, java.sql.*, java.util.*, java.util.*, java.sql.*, org.w3c.dom.*"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../jsp/header.jsp" %>
<%@ include file="../jsp/validator.jsp"%>
<%
	//grab query strings
	String sNavTab = request.getParameter("tab");
	String sNavSection = request.getParameter("sec");

	//set default values for querystrings
	if ((null == sNavTab) || ("" == sNavTab))		sNavTab = "Home";
	if ((null == sNavSection) || ("" == sNavSection))	sNavSection = "1";
	
	boolean bFeat = false;
	
	//set default values for selected Tab
		int iHome = 0;
		int iCust = 0;
		int iServ = 0;
		int iHelp = 0;
		int iBill = 0;
		int iSyst = 0;
	
	//set default values to show or hide tabs
		int showHome = 1;
		int showCust = 1;
		int showServ = 1;
		int showHelp = 1;
		int showBill = 1;
		int showSyst = 1;
		
	//default sec for tabs
		String defHome = "1";
		String defCust = "1";
		String defServ = "1";
		String defHelp = "1";
		String defBill = "1";
		String defSyst = "1";
	
	//set default values to show or hide sections
		int showHome1 = 1;
		int showHome2 = 1;
		int showHome3 = 1;
		int showHome4 = 1;
		int showHome5 = 1; 
		
		int showCust1 = 1;
		int showCust2 = 1;
		
		int showServ1 = 1;
		int showServ2 = 1;
		int showServ3 = 1;
		
		int showHelp1 = 1;
		int showHelp2 = 1;
		int showHelp3 = 1;
		
		int showBill1 = 1;
		int showBill2 = 1;
		int showBill3 = 1;
		
		int showSyst1 = 1;
		int showSyst2 = 1;
		int showSyst3 = 1;
		int showSyst4 = 1;
		int showSyst5 = 1;
		int showSyst6 = 1;
			
	//check access levels per section
		SystemAccessPermission can;
	
	//==================
	//CUSTOMERS
	//==================
		//Customer List
		//--------------
			can = systemuser.getAccessPermission(SystemObjectType.CUSTOMER);
			if(!can.bWrite) showCust = 0;
		
	//==================
	//SERVERS
	//==================
		//Server List
		//--------------
			can = systemuser.getAccessPermission(SystemObjectType.SERVER);
			if(!can.bRead)
			{
				showServ = 0;
				showHome2 = 0;
			}
			
	//==================
	//HELP
	//==================
		//Help Document
		//--------------
			can = systemuser.getAccessPermission(SystemObjectType.HELP_DOC);
			if(!can.bRead) showHelp1 = 0;
			if("1".equals(defHelp) && showHelp1 == 0) defHelp = "2";
		
		//FAQs
		//--------------
			can = systemuser.getAccessPermission(SystemObjectType.FAQ);
			if(!can.bRead) showHelp2 = 0;
			if("2".equals(defHelp) && showHelp2 == 0) defHelp = "3";
		
		//Support Tickets
		//--------------
			can = systemuser.getAccessPermission(SystemObjectType.SUPPORT_TICKET);
			if(!can.bRead) showHelp3 = 0;
		
		//Help & Support Tab
		//--------------
			if (showHelp1 == 0 && showHelp2 == 0 && showHelp3 == 0) showHelp = 0;
		
	//==================
	//BILLING
	//==================
		//Billing
		//--------------
			can = systemuser.getAccessPermission(SystemObjectType.BILLING);
			showBill = 0;
			if(can.bRead && systemuser.s_partner_id.equals("86")) showBill = 1;
	
	//==================
	//SYSTEM
	//==================
		//System Users
		//--------------
			can = systemuser.getAccessPermission(SystemObjectType.SYSTEM_USER);
			if(!can.bRead) showSyst1 = 0;
			if("1".equals(defSyst) && showSyst1 == 0) defSyst = "2";
			
		//Partners
		//--------------
			can = systemuser.getAccessPermission(SystemObjectType.PARTNER);
			if(!can.bRead) showSyst2 = 0;
			if("2".equals(defSyst) && showSyst2 == 0) defSyst = "3";
			
		//System Note
		//--------------
			can = systemuser.getAccessPermission(SystemObjectType.SYSTEM_NOTE);
			if(!can.bRead) showSyst3 = 0;
			if("3".equals(defSyst) && showSyst3 == 0) defSyst = "4";
			
		//Host Monitor
		//--------------
			can = systemuser.getAccessPermission(SystemObjectType.HOST_MONITOR);
			if(!can.bRead) showSyst4 = 0;
			if("4".equals(defSyst) && showSyst4 == 0) defSyst = "5";
		
			// host monitor files = host monitor
			showHome5 = showSyst4; 
			
		//Registry
		//--------------
			can = systemuser.getAccessPermission(SystemObjectType.REGISTRY);
			if(!can.bRead) showSyst5 = 0;

		//Delivery Monitor
		//--------------
			can = systemuser.getAccessPermission(SystemObjectType.DELIVERY_MONITOR);
			if(!can.bRead) showSyst6 = 0;
		
		//Administration Tab
		//--------------
			if (showSyst1 == 0 && showSyst2 == 0 && showSyst3 == 0 && showSyst4 == 0 && showSyst5 == 0 && showSyst6 == 0) showSyst = 0;
		
	//set default values for tab navigation links
		String sHome = "<a class=\"navmain\" href=\"../jsp/index.jsp?tab=Home&sec=" + defHome + "\" target=\"_parent\">Home</a>";
		String sCust = "<a class=\"navmain\" href=\"../jsp/index.jsp?tab=Cust&sec=" + defCust + "\" target=\"_parent\">Customers</a>";
		String sServ = "<a class=\"navmain\" href=\"../jsp/index.jsp?tab=Serv&sec=" + defHelp + "\" target=\"_parent\">Servers</a>";
		String sHelp = "<a class=\"navmain\" href=\"../jsp/index.jsp?tab=Help&sec=" + defHelp + "\" target=\"_parent\">Help &amp; Support</a>";
		String sBill = "<a class=\"navmain\" href=\"../jsp/index.jsp?tab=Bill&sec=" + defBill + "\" target=\"_parent\">Billing</a>";
		String sSyst = "<a class=\"navmain\" href=\"../jsp/index.jsp?tab=Syst&sec=" + defSyst + "\" target=\"_parent\">System</a>";
	
	//check tab and set variables
		if (sNavTab.equals("Home"))
		{
				iHome = 1;
				sHome = "Home";
		}
		else if (sNavTab.equals("Cust"))
		{
				iCust = 1;
				sCust = "Customers";
		}
		else if (sNavTab.equals("Serv"))
		{
				iServ = 1;
				sServ = "Servers";
		}
		else if (sNavTab.equals("Help"))
		{
				iHelp = 1;
				sHelp = "Help & Support";
		}
		else if (sNavTab.equals("Bill"))
		{
				iBill = 1;
				sBill = "Billing";
		}
		else if (sNavTab.equals("Syst"))
		{
				iSyst = 1;
				sSyst = "System";
		}
		else
		{
				iHome = 1;
				sHome = "Home";
		}
%>
<HTML>
<HEAD>
<TITLE></TITLE>
<link rel="stylesheet" href="../css/style.css" type="text/css">
<style>

td
{
	padding:0px;
}

</style>
</HEAD>
<body leftmargin="0" topmargin="0" marginheight="0" marginwidth="0" style="padding:0px;">
<table cellspacing="0" cellpadding="0" border="0" width="100%">
	<tr>
		<td align="left" valign="middle">
			<table cellspacing="0" cellpadding="0" border="0" width="100%">
				<tr>
					<td width="100%" style="font-size:18pt; padding-left:5px; padding-top:10px; padding-bottom:5px;">
						<img src="../images/logo.gif" align="absbottom" border="0">&nbsp;&nbsp;Administration Module</td>
					<td width="450" align="right" valign="bottom">
						<IFRAME src="../jsp/session_info.jsp" width="400" height="50" scrolling="no" frameborder="0">
						[Your user agent does not support frames or is currently configured
						not to display frames. However, you may visit
						<A href="foo.html">the related document.</A>]
						</IFRAME>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td align="left" valign="top">
		<!----- ----->
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr>
					<td align="left" valign="top">
					<!-- Main Nav --->
						<table width="100%" cellpadding="0" cellspacing="0" class="navmain">
							<tr>
								<td<%= (showHome == 0)?" style=\"display:none;\"":"" %> align="center" nowrap class="navmain<%= (iHome == 1)?"on":"off" %>"><%= sHome %></td>
								<td<%= (showCust == 0)?" style=\"display:none;\"":"" %> align="center" nowrap class="navmain<%= (iCust == 1)?"on":"off" %>"><%= sCust %></td>
								<td<%= (showServ == 0)?" style=\"display:none;\"":"" %> align="center" nowrap class="navmain<%= (iServ == 1)?"on":"off" %>"><%= sServ %></td>
								<td<%= (showHelp == 0)?" style=\"display:none;\"":"" %> align="center" nowrap class="navmain<%= (iHelp == 1)?"on":"off" %>"><%= sHelp %></td>
								<td<%= (showBill == 0)?" style=\"display:none;\"":"" %> align="center" nowrap class="navmain<%= (iBill == 1)?"on":"off" %>"><%= sBill %></td>
								<td<%= (showSyst == 0)?" style=\"display:none;\"":"" %> align="center" nowrap class="navmain<%= (iSyst == 1)?"on":"off" %>"><%= sSyst %></td>
								<td width="100%" class="navmainoff">&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
						<!-- Sub Nav --->
						<% if (iHome == 1) { %>
						<table width="100%" cellpadding="0" cellspacing="0" class="navsub">
							<tr>
								<td colspan="5" class="navsub"><img src="../images/blank.gif" height="5"></td>
							</tr>
							<tr>
								<td class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("1"))?"on":"off" %>" href="../jsp/index.jsp?tab=Home&sec=1"  target="_parent">Users &amp; Modules</a></td>
								<td<%= (showHome2 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("2"))?"on":"off" %>" href="../jsp/index.jsp?tab=Home&sec=2"  target="_parent">Servers</a></td>
								<td<%= (showHome3 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("3"))?"on":"off" %>" href="../jsp/index.jsp?tab=Home&sec=3"  target="_parent">Session Monitor</a></td>
								<td<%= (showHome4 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("4"))?"on":"off" %>" href="../jsp/index.jsp?tab=Home&sec=4"  target="_parent">Campaign Monitor</a></td>
								<td<%= (showHome5 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("5"))?"on":"off" %>" href="../jsp/index.jsp?tab=Home&sec=5"  target="_parent">Host Monitor</a></td>
								<td class="navsub" width="100%">&nbsp;</td>
							</tr>
							<!-- Current Subnav arrow -->
							<tr>
								<td height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("1"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showHome2 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("2"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showHome3 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("3"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showHome4 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("4"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showHome5 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("5"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/blank.gif" height="10"></td>
							</tr>
						</table>
						<% } %>
						<% if (iCust == 1) { %>
						<table width="100%" cellpadding="0" cellspacing="0" class="navsub">
							<tr>
								<td colspan="3" class="navsub"><img src="../images/blank.gif" height="5"></td>
							</tr>
							<tr>
								<td<%= (showCust1 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("1"))?"on":"off" %>" href="../jsp/index.jsp?tab=Cust&sec=1"  target="_parent">Customer List</a></td>
								<td<%= (showCust2 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("2"))?"on":"off" %>" href="../jsp/index.jsp?tab=Cust&sec=2"  target="_parent">Check Unique IDs</a></td>
								<td class="navsub" width="100%">&nbsp;</td>
							</tr>
							<!-- Current Subnav arrow -->
							<tr>
								<td<%= (showCust1 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("1"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showCust2 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("2"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/blank.gif" height="10"></td>
							</tr>
						</table>
						<% } %>
						<% if (iServ == 1) { %>
						<table width="100%" cellpadding="0" cellspacing="0" class="navsub">
							<tr>
								<td colspan="4" class="navsub"><img src="../images/blank.gif" height="5"></td>
							</tr>
							<tr>
								<td<%= (showServ1 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("1"))?"on":"off" %>" href="../jsp/index.jsp?tab=Serv&sec=1"  target="_parent">Machines</a></td>
								<td<%= (showServ2 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("2"))?"on":"off" %>" href="../jsp/index.jsp?tab=Serv&sec=2"  target="_parent">Module Versions</a></td>
								<td<%= (showServ3 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("3"))?"on":"off" %>" href="../jsp/index.jsp?tab=Serv&sec=3"  target="_parent">Module Instances</a></td>
								<td class="navsub" width="100%">&nbsp;</td>
							</tr>
							<!-- Current Subnav arrow -->
							<tr>
								<td<%= (showServ1 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("1"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showServ2 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("2"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showServ3 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("3"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/blank.gif" height="10"></td>
							</tr>
						</table>
						<% } %>
						<% if (iHelp == 1) { %>
						<table width="100%" cellpadding="0" cellspacing="0" class="navsub">
							<tr>
								<td colspan="4" class="navsub"><img src="../images/blank.gif" height="5"></td>
							</tr>
							<tr>
								<td<%= (showHelp1 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("1"))?"on":"off" %>" href="../jsp/index.jsp?tab=Help&sec=1"  target="_parent">Help Document</a></td>
								<td<%= (showHelp2 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("2"))?"on":"off" %>" href="../jsp/index.jsp?tab=Help&sec=2"  target="_parent">FAQs</a></td>
								<td<%= (showHelp3 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("3"))?"on":"off" %>" href="../jsp/index.jsp?tab=Help&sec=3"  target="_parent">Support Tickets</a></td>
								<td class="navsub" width="100%">&nbsp;</td>
							</tr>
							<!-- Current Subnav arrow -->
							<tr>
								<td<%= (showHelp1 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("1"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showHelp2 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("2"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showHelp3 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("3"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/blank.gif" height="10"></td>
							</tr>
						</table>
						<% } %>
						<% if (iBill == 1) { %>
						<table width="100%" cellpadding="0" cellspacing="0" class="navsub">
							<tr>
								<td colspan="4" class="navsub"><img src="../images/blank.gif" height="5"></td>
							</tr>
							<tr>
								<td<%= (showBill1 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("1"))?"on":"off" %>" href="../jsp/index.jsp?tab=Bill&sec=1"  target="_parent">Billing</a></td>
								<td<%= (showBill2 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("2"))?"on":"off" %>" href="../jsp/index.jsp?tab=Bill&sec=2"  target="_parent">Plans</a></td>
								<td<%= (showBill3 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("3"))?"on":"off" %>" href="../jsp/index.jsp?tab=Bill&sec=3"  target="_parent">Rates</a></td>
								<td class="navsub" width="100%">&nbsp;</td>
							</tr>
							<!-- Current Subnav arrow -->
							<tr>
								<td<%= (showBill1 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("1"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showBill2 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("2"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showBill3 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("3"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/blank.gif" height="10"></td>
							</tr>
						</table>
						<% } %>
						<% if (iSyst == 1) { %>
						<table width="100%" cellpadding="0" cellspacing="0" class="navsub">
							<tr>
								<td colspan="6" class="navsub"><img src="../images/blank.gif" height="5"></td>
							</tr>
							<tr>
								<td<%= (showSyst1 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("1"))?"on":"off" %>" href="../jsp/index.jsp?tab=Syst&sec=1"  target="_parent">System Users</a></td>
								<td<%= (showSyst2 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("2"))?"on":"off" %>" href="../jsp/index.jsp?tab=Syst&sec=2"  target="_parent">Partners</a></td>
								<td<%= (showSyst3 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("3"))?"on":"off" %>" href="../jsp/index.jsp?tab=Syst&sec=3"  target="_parent">System Notes</a></td>
								<td<%= (showSyst4 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("4"))?"on":"off" %>" href="../jsp/index.jsp?tab=Syst&sec=4"  target="_parent">Host Monitor Files</a></td>
								<td<%= (showSyst5 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("5"))?"on":"off" %>" href="../jsp/index.jsp?tab=Syst&sec=5"  target="_parent">Registry</a></td>
								<td<%= (showSyst6 == 0)?" style=\"display:none;\"":"" %> class="navsub" nowrap><a class="navsub<%= (sNavSection.equals("6"))?"on":"off" %>" href="../jsp/index.jsp?tab=Syst&sec=6"  target="_parent">Delivery Monitor</a></td>
								<td class="navsub" width="100%">&nbsp;</td>
							</tr>
							<!-- Current Subnav arrow -->
							<tr>
								<td<%= (showSyst1 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("1"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showSyst2 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("2"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showSyst3 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("3"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showSyst4 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("4"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showSyst5 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("5"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td<%= (showSyst6 == 0)?" style=\"display:none;\"":"" %> height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/<%= (sNavSection.equals("6"))?"subnavarrow":"blank" %>.gif" height="10"></td>
								<td height="10" background="../images/subnavbg.gif" class="subnavbuffer"><img src="../images/blank.gif" height="10"></td>
							</tr>
						</table>
						<% } %>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</BODY>
</HTML>

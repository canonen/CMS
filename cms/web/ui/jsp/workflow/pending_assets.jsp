<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.ctl.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.wfl.*,
			java.sql.*,java.io.*,
			java.util.*,org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
	errorPage="../error_page.jsp"
%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	String sDestCustId = request.getParameter("cust_id");
	String sUiMode = request.getParameter("ui_mode");
	String sLocation = request.getParameter("loc");

	if(sDestCustId!=null && sLocation != null)
	{
//		if (sUiMode.equals("multi"))
//               ui.setUIMode(ui.MULTI_CUSTOMER);
//          else
//               ui.setUIMode(ui.SINGLE_CUSTOMER);
		ui.setActiveCustomer(session, sDestCustId);
		ui.setDestinationCustomer(session, sDestCustId);

%>
          <SCRIPT>
               parent.location.href = "<%=sLocation%>";
          </SCRIPT>	
<%
	}


    	ConnectionPool cp	= null;
	Connection conn		= null;
	Statement stmt		= null;
	ResultSet rsAssets		= null, rsRequests = null;

	String sSql = null;

     String sErrors = null;
     String sClassAppend = "";
	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();
          int iObjectType = 0;
          String sObjectName = null, sObjectId = null, sApprovor = null, sRequestor = null, sRequestDate = null;
          String sAprvlRequestId = null, sApprovalId = null;
          String sApprovalPage = null;
          String sCustId = null, sCustName = null;
          int iLevel = -1;
          boolean bChildrenDisplayed = false;


%>

<html>
<head>
<title>Pending Assets</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>
<script>

	var dur = 9;
	var popTim;
	var pCount = 1;
	var sCount = 0;
	var hasPop = false;
	var moveCustID = "";
	var moveLoc = "";
	
	var scX, scY, pX, pY;
	scX = window.screen.width;
	scY = window.screen.height;
	
	pX = parseInt(((scX / 2) - 215));
	pY = parseInt(((scY / 2) - 75));
	
	function switch_cust2(cust_id, loc)
	{
		moveCustID = cust_id;
		moveLoc = loc;
		
		if (cust_id != "<%= cust.s_cust_id %>")
		{
			loadSwitchWin();
		}
		else
		{
			location.href='pending_assets.jsp?cust_id='+cust_id+'&loc=' + loc;
		}
	}
	
	var _oPop;
	
	function loadSwitchWin()
	{
		var sHTML = "";
		sHTML += "<html><head><title>Switching Customers</title></head>";
		sHTML += "<body style=\"padding:0px;\">";
		sHTML += "<table cellspacing=0 cellpadding=0 border=0 class=\"layout\" style=\"width:100%; height:100%;\">";
		sHTML += "<tr><td valign=middle style=\"padding:10px;\" class=switchCust>Switching To Child Customer";

		if (pCount == 1)
		{
			sHTML += ".";
			pCount++;
		}
		else if (pCount == 2)
		{
			sHTML += "..";
			pCount++;
		}
		else if (pCount == 3)
		{
			sHTML += "...";
			pCount = 1;
		}

		sHTML += "</td></tr>";
		sHTML += "</table></body></html>";
		
		if (hasPop == false)
		{
			_oPop = window.createPopup();
			_oPop.document.createStyleSheet("<%= ui.s_css_filename %>");
			hasPop = true;
			_oPop.show(pX, pY, 425, 150);
		}
	
		with (_oPop.document.body)
		{
			// Populate the Popup's HTML
			innerHTML = sHTML;
		}
		
		sCount++;
		
		if (sCount <= dur)
		{
			popTim = window.setTimeout("loadSwitchWin()", 300);
		}
		else
		{
			window.clearTimeout(popTim);
			_oPop.hide();
			location.href= "pending_assets.jsp?cust_id=" + moveCustID + "&loc=" + moveLoc;
		}
	}
	
</script>
<body>
<form name="FT" method="post" action="pending_assets.jsp">

<br>
<table cellspacing="0" cellpadding="0" width="100%" border="0">
			<%
			int iAssetCount = 0;

			rsAssets = stmt.executeQuery("Exec usp_ccps_approval_multi_dept_asset_list_get "+cust.s_cust_id + ", " + user.s_user_id + ", 0");
			while (rsAssets.next())
			{
				iObjectType = rsAssets.getInt(1);
				sObjectId = rsAssets.getString(2);
				sObjectName = rsAssets.getString(3);
				sApprovor = rsAssets.getString(4);
				sRequestor = rsAssets.getString(5);
				sRequestDate = rsAssets.getString(6);
				sAprvlRequestId = rsAssets.getString(7);
				sApprovalId = rsAssets.getString(8);
				sCustId = rsAssets.getString(9);
				sCustName = rsAssets.getString(10);
				iLevel = rsAssets.getInt(11);
				sApprovalPage = WorkflowUtil.getApprovalUrl(iObjectType, sObjectId, cust.s_cust_id, false) + "&aprvl_request_id=" + sAprvlRequestId;

				if (iAssetCount % 2 != 0) sClassAppend = "_Alt";
				else sClassAppend = "";

                    if (iAssetCount == 0 && iLevel == 0) {
                    %>
                         <tr>
                              <td class="listHeading" valign="center" nowrap align="left">
                                   Assets Awaiting Approval
                                   <br><br>
                                   <table class="listTable" width="100%" cellspacing="0" cellpadding="2">
                                        <tr>
                                             <th align="left" nowrap>Customer</th>
                                             <th align="left" nowrap>Asset Type</th>
                                             <th align="left" nowrap>Name</th>
                                             <th align="left" nowrap>Requestor</th>
                                             <th align="left" nowrap>Approver</th>
                                             <th align="left" nowrap>Last Request Date</th>
                                             <th align="left" nowrap>Request History</th>
                                        </tr>
                    <%
                    }
                    if (iLevel > 0 && !bChildrenDisplayed ) {
                         bChildrenDisplayed = true;

                         if (iAssetCount > 0) {
                    %>
                         </table>
                    </td>
               </tr>
                         <% } %>
               <tr>
                    <td class="listHeading" valign="center" nowrap align="left">
                         <%=((ui.n_ui_type_id == UIType.HYATT_ADMIN || ui.n_ui_type_id == UIType.HYATT_USER)?"Property ":"Child Customer ")%>Assets Awaiting Approval
                         <br>
                         <table class="listTable" width="100%" cellspacing="0" cellpadding="2">
                              <tr>
                                   <th align="left" nowrap>Customer</th>
                                   <th align="left" nowrap>Asset Type</th>
                                   <th align="left" nowrap>Name</th>
                                   <th align="left" nowrap>Requestor</th>
                                   <th align="left" nowrap>Approver</th>
                                   <th align="left" nowrap>Last Request Date</th>
                                   <th align="left" nowrap>Request History</th>
                              </tr>
                    <%
                    }

				iAssetCount++;
				%>
				<tr>
					<td class="listItem_Title<%= sClassAppend %>" nowrap><%= sCustName %></td>
					<td class="listItem_Data<%= sClassAppend %>"><%= ObjectType.getDisplayName(iObjectType) %></td>
					<td class="listItem_Data<%= sClassAppend %>"><a href=# onclick="switch_cust2(<%=sCustId%>,'<%=sApprovalPage%>')" target"=_self"><%= sObjectName %></a></td>
<%--					<td class="listItem_Data<%= sClassAppend %>"><a href="<%= sApprovalPage %>" target"=_self"><%= sObjectName %></a></td> --%>
					<td class="listItem_Data<%= sClassAppend %>" nowrap><%= sRequestor %></td>
					<td class="listItem_Data<%= sClassAppend %>" nowrap><%= sApprovor %></td>
					<td class="listItem_Title<%= sClassAppend %>" nowrap><%= sRequestDate %></td>
					<td class="listItem_Data<%= sClassAppend %>"><a href="approval_request_history.jsp?approval_id=<%= sApprovalId %>" target"=_self">History</a></td>
				</tr>
				<%
			}
			rsAssets.close();
			
			if (iAssetCount == 0)
			{
				%>
				<tr>
					<td class="listItem_Data">There are currently no assets awaiting approval.</td>
				</tr>
				<%
			}
			%>
			</table>
		</td>
	</tr>
</table>
<br><br>
<table cellspacing="0" cellpadding="0" width="100%" border="0">
			<%
			iAssetCount = 0;
               bChildrenDisplayed = false;

			rsAssets = stmt.executeQuery("Exec usp_ccps_approval_multi_dept_asset_list_get "+cust.s_cust_id + ", " + user.s_user_id + ", 1");
			while (rsAssets.next())
			{
				iObjectType = rsAssets.getInt(1);
				sObjectId = rsAssets.getString(2);
				sObjectName = rsAssets.getString(3);
				sApprovor = rsAssets.getString(4);
				sRequestor = rsAssets.getString(5);
				sRequestDate = rsAssets.getString(6);
				sAprvlRequestId = rsAssets.getString(7);
				sApprovalId = rsAssets.getString(8);
				sCustId = rsAssets.getString(9);
				sCustName = rsAssets.getString(10);
				iLevel = rsAssets.getInt(11);
				sApprovalPage = WorkflowUtil.getApprovalUrl(iObjectType, sObjectId, cust.s_cust_id, false) + "&aprvl_request_id=" + sAprvlRequestId;

				if (iAssetCount % 2 != 0) sClassAppend = "_Alt";
				else sClassAppend = "";

                    if (iAssetCount == 0 && iLevel == 0) {
                    %>
                         <tr>
                              <td class="listHeading" valign="center" nowrap align="left">
                                   Approved Assets
                                   <br><br>
                                   <table class="listTable" width="100%" cellspacing="0" cellpadding="2">
                                        <tr>
                                             <th align="left" nowrap>Customer</th>
                                             <th align="left" nowrap>Asset Type</th>
                                             <th align="left" nowrap>Name</th>
                                             <th align="left" nowrap>Requestor</th>
                                             <th align="left" nowrap>Approver</th>
                                             <th align="left" nowrap>Last Request Date</th>
                                             <th align="left" nowrap>Request History</th>
                                        </tr>
                    <%
                    }
                    if (iLevel > 0 && !bChildrenDisplayed ) {
                         bChildrenDisplayed = true;
                         if (iAssetCount > 0) {
                    %>
                         </table>
                    </td>
               </tr>
                         <% } %>
               <tr>
                    <td class="listHeading" valign="center" nowrap align="left">
                         <%=((ui.n_ui_type_id == UIType.HYATT_ADMIN || ui.n_ui_type_id == UIType.HYATT_USER)?"Property ":"Child Customer ")%> Assets - Approved
                         <br>
                         <table class="listTable" width="100%" cellspacing="0" cellpadding="2">
                              <tr>
                                   <th align="left" nowrap>Customer</th>
                                   <th align="left" nowrap>Asset Type</th>
                                   <th align="left" nowrap>Name</th>
                                   <th align="left" nowrap>Requestor</th>
                                   <th align="left" nowrap>Approver</th>
                                   <th align="left" nowrap>Last Request Date</th>
                                   <th align="left" nowrap>Request History</th>
                              </tr>
                    <%
                    }

				iAssetCount++;
				%>
				<tr>
					<td class="listItem_Title<%= sClassAppend %>" nowrap><%= sCustName %></td>
					<td class="listItem_Data<%= sClassAppend %>"><%= ObjectType.getDisplayName(iObjectType) %></td>
					<td class="listItem_Data<%= sClassAppend %>"><a href=# onclick="switch_cust2(<%=sCustId%>,'<%=sApprovalPage%>')" target"=_self"><%= sObjectName %></a></td>
<%--					<td class="listItem_Data<%= sClassAppend %>"><a href="<%= sApprovalPage %>" target"=_self"><%= sObjectName %></a></td> --%>
					<td class="listItem_Data<%= sClassAppend %>" nowrap><%= sRequestor %></td>
					<td class="listItem_Data<%= sClassAppend %>" nowrap><%= sApprovor %></td>
					<td class="listItem_Title<%= sClassAppend %>" nowrap><%= sRequestDate %></td>
					<td class="listItem_Data<%= sClassAppend %>"><a href="approval_request_history.jsp?approval_id=<%= sApprovalId %>" target"=_self">History</a></td>
				</tr>
				<%
			}
			rsAssets.close();
			
			if (iAssetCount == 0)
			{
				%>
				<tr>
					<td class="listItem_Data">There are currently no approved assets.</td>
				</tr>
				<%
			}
			%>
		</table>
		</td>
	</tr>
</table>
<br><br>
<table cellspacing="0" cellpadding="0" width="100%" border="0">
			<%
			iAssetCount = 0;
               bChildrenDisplayed = false;

			rsAssets = stmt.executeQuery("Exec usp_ccps_approval_multi_dept_asset_list_get "+cust.s_cust_id + ", " + user.s_user_id + ", 2");
			while (rsAssets.next())
			{
				iObjectType = rsAssets.getInt(1);
				sObjectId = rsAssets.getString(2);
				sObjectName = rsAssets.getString(3);
				sApprovor = rsAssets.getString(4);
				sRequestor = rsAssets.getString(5);
				sRequestDate = rsAssets.getString(6);
				sAprvlRequestId = rsAssets.getString(7);
				sApprovalId = rsAssets.getString(8);
				sCustId = rsAssets.getString(9);
				sCustName = rsAssets.getString(10);
				iLevel = rsAssets.getInt(11);
				sApprovalPage = WorkflowUtil.getApprovalUrl(iObjectType, sObjectId, cust.s_cust_id, false) + "&aprvl_request_id=" + sAprvlRequestId;

				if (iAssetCount % 2 != 0) sClassAppend = "_Alt";
				else sClassAppend = "";

                    if (iAssetCount == 0 && iLevel == 0) {
                    %>
                         <tr>
                              <td class="listHeading" valign="center" nowrap align="left">
                                   Rejected Assets
                                   <br><br>
                                   <table class="listTable" width="100%" cellspacing="0" cellpadding="2">
                                        <tr>
                                             <th align="left" nowrap>Customer</th>
                                             <th align="left" nowrap>Asset Type</th>
                                             <th align="left" nowrap>Name</th>
                                             <th align="left" nowrap>Requestor</th>
                                             <th align="left" nowrap>Approver</th>
                                             <th align="left" nowrap>Last Request Date</th>
                                             <th align="left" nowrap>Request History</th>
                                        </tr>
                    <%
                    }
                    if (iLevel > 0 && !bChildrenDisplayed ) {
                         bChildrenDisplayed = true;
                         if (iAssetCount > 0) {
                    %>
                         </table>
                    </td>
               </tr>
                         <% } %>
               <tr>
                    <td class="listHeading" valign="center" nowrap align="left">
                         <%=((ui.n_ui_type_id == UIType.HYATT_ADMIN || ui.n_ui_type_id == UIType.HYATT_USER)?"Property ":"Child Customer ")%>Assets - Rejected
                         <br>
                         <table class="listTable" width="100%" cellspacing="0" cellpadding="2">
                              <tr>
                                   <th align="left" nowrap>Customer</th>
                                   <th align="left" nowrap>Asset Type</th>
                                   <th align="left" nowrap>Name</th>
                                   <th align="left" nowrap>Requestor</th>
                                   <th align="left" nowrap>Approver</th>
                                   <th align="left" nowrap>Last Request Date</th>
                                   <th align="left" nowrap>Request History</th>
                              </tr>
                    <%
                    }

				iAssetCount++;
				%>
				<tr>
					<td class="listItem_Title<%= sClassAppend %>" nowrap><%= sCustName %></td>
					<td class="listItem_Data<%= sClassAppend %>"><%= ObjectType.getDisplayName(iObjectType) %></td>
					<td class="listItem_Data<%= sClassAppend %>"><a href=# onclick="switch_cust2(<%=sCustId%>,'<%=sApprovalPage%>')" target"=_self"><%= sObjectName %></a></td>
<%--					<td class="listItem_Data<%= sClassAppend %>"><a href="<%= sApprovalPage %>" target"=_self"><%= sObjectName %></a></td> --%>
					<td class="listItem_Data<%= sClassAppend %>" nowrap><%= sRequestor %></td>
					<td class="listItem_Data<%= sClassAppend %>" nowrap><%= sApprovor %></td>
					<td class="listItem_Title<%= sClassAppend %>" nowrap><%= sRequestDate %></td>
					<td class="listItem_Data<%= sClassAppend %>"><a href="approval_request_history.jsp?approval_id=<%= sApprovalId %>" target"=_self">History</a></td>
				</tr>
				<%
			}
			rsAssets.close();
				
			if (iAssetCount == 0)
			{
				%>
				<tr>
					<td class="listItem_Data">There are currently no rejected assets.</td>
				</tr>
				<%
			}

			%>
			</table>
		</td>
	</tr>
</table>
<br><br>
</body>
<%
}
catch(Exception ex) { throw ex; }
finally
{
	try { if (stmt != null) stmt.close(); }
	catch(Exception ex) {}
	if (conn != null) cp.free(conn);
}
%>
</html>


<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.ctl.*,
		java.sql.*,java.util.Vector,
		org.w3c.dom.*,org.apache.log4j.*"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>

<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
AccessPermission can = user.getAccessPermission(ObjectType.EXPORT);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

// ********** KU
String		scurPage	= request.getParameter("curPage");
String		samount		= request.getParameter("amount");

//********** For Retargeting

String userId			= request.getParameter("user_id");
String userType			= request.getParameter("user_type");
String retargetingType = userType.equals("google") ? "50" : userType.equals("facebook") ? "40" : "0";

//********** For Retargeting

int			curPage			= 1;
int			amount			= 0;

curPage		= (scurPage		== null) ? 1 : Integer.parseInt(scurPage);
amount		= (samount==null)? 25 : Integer.parseInt(samount);

boolean isCustom = false;

Statement 		stmt	= null;
ResultSet 		rs		= null; 
ConnectionPool 	cp		= null;
Connection 		conn	= null;

try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("retargeting_list.jsp");
	stmt = conn.createStatement();

	boolean isDisable = false;
	String		CUSTOMER_ID	= cust.s_cust_id;

	String	sFilename	= "";
	String	sFileUrl	= "";
	String	sFileId		= "";
	String	sStatus		= "";
	int nStatusID = 0;
	int nTypeID = 0;
	 String url2="";
	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;


%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<HTML>
<c:set var="loc" value="en_US"/>
<c:if test="${!(empty param.locale)}">
  <c:set var="loc" value="${param.locale}"/>
</c:if>

<fmt:setLocale value="${loc}" />

<fmt:bundle basename="app">
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<link rel="stylesheet" href="/cms/ui/css/demo_table_jui.css" TYPE="text/css">
<link rel="stylesheet" href="/cms/ui/css/jquery-ui-1.7.2.custom.css" TYPE="text/css">
	<SCRIPT src="../../js/scripts.js"></SCRIPT>
	<script language="javascript">

	function ExportWin(freshurl)
	{
		var window_features = 'scrollbars=yes,resizable=yes,menubar=yes,toolbar=yes,location=no,status=yes,height=600,width=500';
		SmallWin = window.open(freshurl,'ExportWin',window_features);
	}
	
	</script>
<script language="JavaScript" src="/cms/ui/ooo/script.js"></script>
	<SCRIPT src="../../js/jquery.js"></SCRIPT>
	<SCRIPT src="/cms/ui/js/jquery.dataTables.min_new.js"></SCRIPT>
	<script type="text/javascript">
		$(document).ready(function() {
			$("#checkboxall").click(function() 
			{ 
				var checked_status = this.checked;  
				$(".check_me").each(function(){
					this.checked = checked_status;
				});				
			}); 
			
			$('#example tbody td').hover( function() {
				$(this).siblings().addClass('highlighted');
				$(this).addClass('highlighted');
			}, function() {
				$(this).siblings().removeClass('highlighted');
				$(this).removeClass('highlighted');
			} );
			$('#example2 tbody td').hover( function() {
				$(this).siblings().addClass('highlighted');
				$(this).addClass('highlighted');
			}, function() {
				$(this).siblings().removeClass('highlighted');
				$(this).removeClass('highlighted');
			} );
			oTable = $('#example').dataTable( {
							"bJQueryUI": true,
							"sPaginationType": "full_numbers"
				} );
			
			$('#filter').change( function(){
				filter_string = $('#filter').val();
				oTable.fnFilter( filter_string , 4);
				filter_string = $('#filter').val();
				oTable2.fnFilter( filter_string , 3);
			});
		} );
	</script>	

<script type="text/javascript">

function checkForm ()
{
	var nDels=0;
	var elLength = document.FT.elements.length;

    for (i=0; i<elLength; i++)
    {
        var type = FT.elements[i].type;
        if (type=="checkbox" && FT.elements[i].checked){
            nDels ++;
        }
    }
	
	if (nDels == 0) {
		alert ("Nothing to erase");
		return false;
	}
	FT.NDELS.value = nDels;
	return true;
}

</script>	
</HEAD>
<BODY class="paging_body">

<div class="page_header"><fmt:message key="header_exp"/></div>
<div class="page_desc"><fmt:message key="header_exp_desc"/></div>
<div id="info">
<div id="xsnazzy">

<div class="xboxcontent">
			<table class=listTable cellSpacing=0 cellPadding=2 width="100%" style="padding-top: 4px;">
				<TBODY>
	<tr>
		<TD noWrap align=left style="padding-left:10px; width:5%;">
			<% if (can.bWrite) { %>
			   <a class="newbutton" href="https://cms.revotas.com/cms/ui/jsp/export/retargeting_new.jsp?user_id=<%=userId%>&user_type=<%=userType%><%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>" <%=(isDisable)?"disabled":""%>><fmt:message key="button_export"/></a>&nbsp;&nbsp;&nbsp;
			<% } %>			
		</td>
		<%
		int numCstmExp = 0;
		rs = stmt.executeQuery("SELECT count(*) FROM cexp_custom_export WHERE cust_id = "+CUSTOMER_ID);
		if (rs.next()) numCstmExp = rs.getInt(1);
		if (numCstmExp > 0)
		{
			%>
		<td noWrap align=left style="padding-left:10px; width:5%;">
			<a class="newbutton" href="custom_export_list.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">&nbsp;New Custom Export</a>
		</td>
			<% 
		}
		%>
		<td noWrap align=left style="padding-left:10px; width:5%;">
		<%
		if (can.bDelete)
		{
			%>
			<a class="buttons-idelete" href="#" onClick="if( checkForm () ) FT.submit();" <%=(isDisable)?"disabled":""%>>
							<fmt:message key="button_export_delete"/></a>
			<%
		}
		%>
		</td>
		<td noWrap align=right style="padding-right:10px;">
		
			<a class="newbutton" href="retargeting_list.jsp?user_type=<%=userType%>&user_id=<%=userId%>"><fmt:message key="button_refresh"/></a>
		
		</td>
	</tr>
	</tbody>	
</table>
			<FORM  METHOD="POST" NAME="FT" ACTION="retargeting_delete.jsp?user_id=<%=userId%>&user_type=<%=userType%>"><INPUT TYPE="hidden" NAME="NDELS" VALUE="0" ><INPUT TYPE="hidden" NAME="FILE" VALUE="-9999">
			<div class="list-headers">Exports</div>
			<table class="listTable" id="example" width="100%" cellpadding="2" cellspacing="0"><thead>
					<th width="1%"><input type="checkbox" id="checkboxall"></th>
					<th width="1%"></th>
					<th valign="middle" nowrap><fmt:message key="export_column_name"/></th>
					<th valign="middle" nowrap ><fmt:message key="export_column_status"/></th>
					<th valign="middle" nowrap>&nbsp;</th>
				</thead>
				<tbody>
			<%
			if (sSelectedCategoryId == null || sSelectedCategoryId.equals("0"))
			{
				rs = stmt.executeQuery(
					"SELECT f.file_url, f.export_name, f.file_id, ISNULL(s.display_name, s.status_name),"+
					" ISNULL(f.status_id, "+ExportStatus.COMPLETE+"), f.type_id " +
					"FROM cexp_export_file f, cexp_export_status s " +
					"WHERE cust_id = "+CUSTOMER_ID+
					" AND ISNULL(f.status_id, "+ExportStatus.COMPLETE+") = s.status_id " +
					" AND f.type_id="+retargetingType +
					" ORDER BY file_id DESC");
			}
			else
			{
				rs = stmt.executeQuery(
					"SELECT f.file_url, f.export_name, f.file_id, ISNULL(s.display_name, s.status_name),"+
					" ISNULL(f.status_id, "+ExportStatus.COMPLETE+"), f.type_id " +
					"FROM cexp_export_file f, cexp_export_status s, ccps_object_category c " +
					"WHERE f.cust_id = "+CUSTOMER_ID+
					" AND ISNULL(f.status_id, "+ExportStatus.COMPLETE+") = s.status_id " +
					" AND c.cust_id = "+CUSTOMER_ID+" AND c.type_id = "+ObjectType.EXPORT+
					" AND c.category_id = "+sSelectedCategoryId+" AND c.object_id = f.file_id " +
				    " AND f.type_id="+retargetingType +
					" ORDER BY file_id DESC");
			}

			boolean isOne = false;

			String sClassAppend = "";
			int exportCount = 0;

			while (rs.next())
			{ 
				if (exportCount % 2 != 0)
				{
					sClassAppend = "_other";
				}
				else
				{
					sClassAppend = "";
				}
				exportCount++;
				
				//Page logic
				if ((exportCount <= (curPage-1)*amount) || (exportCount > curPage*amount)) continue;
				
				isOne = true;
				sFileUrl  = rs.getString(1);
				sFilename = new String(rs.getBytes(2),"ISO-8859-1");
				sFileId   = rs.getString(3);
				sStatus   = rs.getString(4);
				nStatusID = rs.getInt(5);
				nTypeID = rs.getInt(6);
				%>
				<tr>
				<%
				if (can.bDelete)
				{
					%>
					<td class="list_row<%= sClassAppend %>"><input type="checkbox" class="check_me" name="check1" value="<%=sFileId%>" <%=(isDisable)?"disabled":""%> ></td>
					<td class="list_row<%= sClassAppend %>"><img src="../../images/icon_report_18_18.png" border="0" alt=""></td>
					<%
				}
				%>
					<%if ((nTypeID == ExportType.CUSTOM)|| (nTypeID == ExportType.CUSTOM_FIXED_WIDTH) ){%>	
					<td class="list_row<%= sClassAppend %>">
						<%=(nStatusID == ExportStatus.COMPLETE)?"<a href=\"custom_export_edit.jsp?file_id="+sFileId+"&categoryId="+sSelectedCategoryId+" \" >"+sFilename+"</a>":sFilename%>
					</td>
					<!-- For Retargeting -->
					<%} else {
					%>
					<td class="list_row<%= sClassAppend %>">
						<%=(nStatusID == ExportStatus.COMPLETE)?"<a href=\"retargeting_edit.jsp?user_id="+userId+"&user_type="+userType+"&file_id="+sFileId+"&categoryId="+sSelectedCategoryId+" \" >"+sFilename+"</a>":sFilename%>
					</td>
					
				   	<% }%>
					<!-- For Retargeting -->
					
					<td class="list_row<%= sClassAppend %>"><%=sStatus%></td>
					<td class="list_row<%= sClassAppend %>">
						<%= (nStatusID == ExportStatus.COMPLETE)?"<a class=\"resourcebutton\" href=\""+sFileUrl+"\" onClick=\"ExportWin('"+sFileUrl+"');return false;\">View/Save</a>":"&nbsp;&nbsp;" %>
						<%String url1=sFileUrl.substring(0,12);
						   url2=url1+"revotas.com/rrcp/imc/retargeting/retargeting_history.jsp?cust_id="+CUSTOMER_ID+"&file_url="+sFileUrl;%>
						   <input type="hidden" value=<%=url2%>>
						<a class="newbutton" onclick="getHistory(this.parentElement)">History</a>
						   <input type="hidden" value=<%=sFileUrl%>>
						<a class="newbutton" onclick="getReport(this.parentElement, <%=sFileId%>)">Report</a>
					</td>
				</tr>
				<%
			}
			rs.close();

			if (!isOne)
			{
				%>
				<tr>
					<td class="listItem_Title" colspan="3">There are currently no Exports</td>
				</tr>
				<%
			}
			%>
			</tbody>
			</table>	
</div>

</div>			
</div>		
		</td>
	</tr>
</table>
<br><br>
</FORM>

<!-- For Retargeting -->
<script type="text/javascript">

function fbErrorMessage()
{
	
alert("Please, Login on Facebook");	
	
	
	
}

function getHistory(obj)
{
	
	var adress=obj.children[1].value;
	var myWindow = window.open(adress, "", "width=300,height=430,top=100,left=400");
}

function getReport(obj,fileId)
{
	var retargetingType = '<%=retargetingType%>';
	var val=obj.children[3].value;
	var preUrl=val.substring(0, 12);
	var custid=<%=CUSTOMER_ID%>;
	

	if(retargetingType === '50') {
		window.open("http://rcp3.revotas.com/rrcp/imc/retargeting/google-report.jsp?file_id=" + fileId, "", "width=1005,height=461,top=100,left=300");
		return;
	}
	var report = window.open(preUrl+"revotas.com/rrcp/imc/retargeting/crm_report.jsp?cust_id="+custid+"&file_url="+val, "", "width=1005,height=461,top=100,left=300");
	
	
	/*
	var http = new XMLHttpRequest();
    var url = preUrl+"revotas.com/rrcp/imc/retargeting/crm_report.jsp"; 
	var params = "cust_id="+ custid
			   + "&file_url="+val;
               
	http.open("POST", url, true);
	http.setRequestHeader("Content-type",
			"application/x-www-form-urlencoded; charset=UTF-8");

	http.onreadystatechange = function() {
		if (http.readyState == 4 && http.status == 200) {
			var serverResponse = http.responseText;

		}
	}
 	http.send(params);
	*/
}
</script>
<!-- For Retargeting -->
</BODY>
</fmt:bundle>
<%

	} catch(Exception ex) {
		ErrLog.put(this,ex,"retargeting_list.jsp",out,1);
		return;
	} finally {
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}
%>
</HTML>

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
	conn = cp.getConnection("export_list.jsp");
	stmt = conn.createStatement();

	boolean isDisable = false;
	String		CUSTOMER_ID	= cust.s_cust_id;

	String	sFilename	= "";
	String	sFileUrl	= "";
	String	sFileId		= "";
	String	sStatus		= "";
	int nStatusID = 0;
	int nTypeID = 0;

	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;


%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<link rel="stylesheet" href="../../css/style2.css" TYPE="text/css">
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
	<SCRIPT src="../../js/jquery.dataTables.js"></SCRIPT>
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
			oTable = $('#example').dataTable({
				"sDom": "tlrip",
				"aoColumns": [{ "bSortable": false },{ "bSortable": false },null,null,{ "bSortable": false }],
				"aaSorting": [[ 3, "asc" ]]
			});
			
			$('#filter').change( function(){
				filter_string = $('#filter').val();
				oTable.fnFilter( filter_string , 4);
				filter_string = $('#filter').val();
				oTable2.fnFilter( filter_string , 3);
			});
		} );
	</script>		
</HEAD>
<BODY class="paging_body" onLoad="innerFramOnLoad();">
<DIV id=tsnazzy><B class=ttop><B class=tb1></B><B class=tb2></B><B 
class=tb3></B><B class=tb4></B></B>
	<div class="tip tboxcontent">
		<strong>Email marketing tip #5:</strong> To reduce the number of bogus email addresses in your contact list, always use a double opt-in subscription system. <a href="tips">Read more.</a>
	</div>
	<B class=tbottom><B class=tb4></B><B 
class=tb3></B><B class=tb2></B><B class=tb1></B></B></DIV>
<div class="page_header">Export</div>
<div class="page_desc">Export data for further uses.</div>
<div id="info">
<div id="xsnazzy">
<b class="xtop"><b class="xb1"></b><b class="xb2"></b><b class="xb3"></b><b class="xb4"></b></b>
<div class="xboxcontent">
			<table class=listTable cellSpacing=0 cellPadding=2 width="100%" style="padding-top: 4px;">
				<TBODY>
	<tr>
		<TD noWrap align=left style="padding-left:10px; width:5%;">
			<% if (can.bWrite) { %>
			<a class="newbutton" href="export_new.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>" <%=(isDisable)?"disabled":""%>>&nbsp;New Export</a>&nbsp;&nbsp;&nbsp;
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
			<a class="newbutton" href="#" onClick="if( checkForm () ) FT.submit();" <%=(isDisable)?"disabled":""%>>
							&nbsp;Delete</a>
			<%
		}
		%>
		</td>
		<td noWrap align=right style="padding-right:10px;">
		
			<a class="newbutton" href="export_list.jsp">&nbsp;Refresh</a>
		
		</td>
	</tr>
	</tbody>	
</table>
			<FORM  METHOD="POST" NAME="FT" ACTION="export_delete.jsp"><INPUT TYPE="hidden" NAME="NDELS" VALUE="0" ><INPUT TYPE="hidden" NAME="FILE" VALUE="-9999">
<table class="list_table" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<th align="left" nowrap>Exports</TH>
				</tr>
			</table>
			<table class="list_table" id="example" width="100%" cellpadding="2" cellspacing="0"><thead>
					<th width="1%"><input type="checkbox" id="checkboxall"></th>
					<th width="1%"></th>
					<th valign="middle" nowrap>Export Name</th>
					<th valign="middle" nowrap >Status</th>
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
					"ORDER BY file_id DESC");
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
					"ORDER BY file_id DESC");
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
					<td class="list_row<%= sClassAppend %>"><input type="checkbox" class="check_me" name="check1" <%=(isDisable)?"disabled":""%> ></td>
					<td class="list_row<%= sClassAppend %>"><img src="../../images/icon_report_18_18.png" border="0" alt=""></td>
					<%
				}
				%>
					<%if ((nTypeID == ExportType.CUSTOM)|| (nTypeID == ExportType.CUSTOM_FIXED_WIDTH) ){ %>	
					<td class="list_row<%= sClassAppend %>">
						<%=(nStatusID == ExportStatus.COMPLETE)?"<a href=\"custom_export_edit.jsp?file_id="+sFileId+"&categoryId="+sSelectedCategoryId+" \" >"+sFilename+"</a>":sFilename%>
					</td>
					<%} else { %>
					<td class="list_row<%= sClassAppend %>">
						<%=(nStatusID == ExportStatus.COMPLETE)?"<a href=\"export_edit.jsp?file_id="+sFileId+"&categoryId="+sSelectedCategoryId+" \" >"+sFilename+"</a>":sFilename%>
					</td>
					<%}%>
					
					<td class="list_row<%= sClassAppend %>"><%=sStatus%></td>
					<td class="list_row<%= sClassAppend %>">
						<%= (nStatusID == ExportStatus.COMPLETE)?"<a class=\"resourcebutton\" href=\""+sFileUrl+"\" onClick=\"ExportWin('"+sFileUrl+"');return false;\">View/Save</a>":"&nbsp;" %>
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
<b class="xbottom"><b class="xb4"></b><b class="xb3"></b><b class="xb2"></b><b class="xb1"></b></b>
</div>			
</div>		
		</td>
	</tr>
</table>
<br><br>
</FORM>
</BODY>

<SCRIPT language="JavaScript">

function innerFramOnLoad()
{

	FT1.curPage.value = <%= curPage %>;
	FT1.amount.value = <%= amount %>;

	var prevPage = document.getElementById("prev_page");
	var firstPage = document.getElementById("first_page");
	var nextPage = document.getElementById("next_page");
	var lastPage = document.getElementById("last_page");

	/* *** *** *** */

	<%
	if( curPage > 1)
	{
		%>
		prevPage.style.display = "";
		firstPage.style.display = "";
		<%
	}

	if( exportCount > (curPage*amount) )
	{
		%>
		nextPage.style.display = "";
		lastPage.style.display = "";
		<%
	}
	%>

	var recCount = new Number("<%= exportCount %>");
	var perPage = new Number(FT1.amount.value);
	var thisPage = new Number(FT1.curPage.value);
	var catName = FT1.category_id[FT1.category_id.selectedIndex].text;

	var pageCount = new Number(Math.ceil(recCount / perPage));

	if (pageCount == 0)
	{
		pageCount = 1;
	}
	
	FT1.pageCount.value = pageCount;
	
	var startRec;
	var endRec;

	startRec = ((thisPage - 1) * perPage) + 1;
	endRec = ((thisPage - 1) * perPage) + perPage;

	if (endRec >= recCount)
	{
		endRec = recCount;
	}

	if (perPage == 1000)
	{
		perPage = "ALL";
	}

	if (thisPage == 1)
	{
		firstPage.style.display = "none";
		prevPage.style.display = "none";
	}

	if (thisPage >= pageCount)
	{
		lastPage.style.display = "none";
		nextPage.style.display = "none";
	}

	var finalMessage = "";

	if (recCount == 0)
	{
		finalMessage = "0 records";
	}
	else
	{
		finalMessage = "Page " + thisPage + " of " + pageCount + " (records " + startRec + " to " + endRec + " of " + recCount + " records)";
	}

	document.getElementById("cat_1").innerHTML = catName;
	document.getElementById("rec_1").innerHTML = perPage;
	document.getElementById("page_1").innerHTML = finalMessage;
}

function GO(parm)
{

	switch( parm )
	{
		case 0:
			FT1.curPage.value = 1;
			break;
		case 1:
			FT1.curPage.value = <%= curPage + 1 %>;
			break;
		case 2:
			break;
		case 3:
			FT1.curPage.value = <%= curPage %>;
			break;
		case -1:
			FT1.curPage.value = <%= curPage - 1 %>;
			break;
		case 99:
			FT1.curPage.value = FT1.pageCount.value;
			break;
	}
	
	FT1.submit();
}

function checkForm ()
{
 /*  mistake in working with amount of less then 2, so we add one HIDDEN element  */

 var nDels=0;
 for (var i = 0 ; i < FT.FILE.length ; i ++ )
 {
    if (FT.FILE[i].checked) 
	nDels ++;
 }
 if (nDels == 0)
 {
	alert ("Nothing to erase");
	return false;
 }
 FT.NDELS.value = nDels;
 return true;
}

</SCRIPT>

<%

	} catch(Exception ex) {
		ErrLog.put(this,ex,"export_list.jsp",out,1);
		return;
	} finally {
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}
%>
</HTML>

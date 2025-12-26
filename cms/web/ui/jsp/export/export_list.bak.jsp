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
	<SCRIPT src="../../js/scripts.js"></SCRIPT>
	<script language="javascript">

	function ExportWin(freshurl)
	{
		var window_features = 'scrollbars=yes,resizable=yes,menubar=yes,toolbar=yes,location=no,status=yes,height=600,width=500';
		SmallWin = window.open(freshurl,'ExportWin',window_features);
	}
	
	</script>
<script language="JavaScript" src="/cms/ui/ooo/script.js"></script>		
</HEAD>
<BODY class="paging_body" onLoad="innerFramOnLoad();">
<table width="100%">
	<tr>
		<td class="page_header">Export</td>
	</tr>
</table>
<br>	
<div id="info">
<div id="xsnazzy">
<b class="xtop"><b class="xb1"></b><b class="xb2"></b><b class="xb3"></b><b class="xb4"></b></b>
<div class="xboxcontent">
<table cellspacing="0" cellpadding="0" width="10%" border="0">
	<tr>
		<td class="main_button" valign="center" nowrap align="left"><img width="10" src="../../images/blank.gif"/></td>
		<td class="main_button" valign="center" nowrap align="left">
			<% if (can.bWrite) { %>
			<a class="newbutton" href="export_new.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>" <%=(isDisable)?"disabled":""%>>
			<img border="0" width="45" src="../../images/45_45_export.png" onmouseout="this.src='../../images/45_45_export.png'" onmouseover="this.src='../../images/45_45_exportg.png'"><br>New Export</a>&nbsp;&nbsp;&nbsp;
			<% } %>			
		</td>
		<td class="main_button" valign="center" nowrap align="left"><img width="10" src="../../images/blank.gif"/></td>
		<td class="main_button" valign="center" nowrap align="left">
		<%
		int numCstmExp = 0;
		rs = stmt.executeQuery("SELECT count(*) FROM cexp_custom_export WHERE cust_id = "+CUSTOMER_ID);
		if (rs.next()) numCstmExp = rs.getInt(1);
		if (numCstmExp > 0)
		{
			%>
		<td align="left" valign="middle" nowrap>
			<a class="newbutton" href="custom_export_list.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">			<img border="0" width="45" src="../../images/45_45_export.png" onmouseout="this.src='../../images/45_45_export.png'" onmouseover="this.src='../../images/45_45_exportg.png'"><br>New Custom Export</a>&nbsp;&nbsp;&nbsp;
		</td>
			<% 
		}
		%>
		</td>
		<td class="main_button" valign="center" nowrap align="left"></td>
		<td class="main_button" valign="center" nowrap align="left">
		<%
		if (can.bDelete)
		{
			%>
			<a class="deletebutton" href="#" onClick="if( checkForm () ) FT.submit();" <%=(isDisable)?"disabled":""%>>
							<img border="0" width="45" src="../../images/45_45_delete.png" onmouseout="this.src='../../images/45_45_delete.png'" onmouseover="this.src='../../images/45_45_deleteg.png'"><br>Delete</a>&nbsp;&nbsp;&nbsp;
			<%
		}
		%>
			
		</td>
	</tr>
	
</table>
</div>
<b class="xbottom"><b class="xb4"></b><b class="xb3"></b><b class="xb2"></b><b class="xb1"></b></b>
</div>


<table cellspacing="0" cellpadding="4" border="0" width="650">
	<tr>

		<td nowrap valign="middle" align="right" width="100%">
			<table class="filterList" cellspacing="1" cellpadding="0" border="0">
				<tr>
					<td align="right" valign="middle" nowrap><a class="filterHeading" href="#" onclick="filterReveal(30);">Filter:</a></td>
					<td align="right" valign="middle" nowrap>&nbsp;Category: <span id="cat_1"></span>&nbsp;</td>
					<td align="right" valign="middle" nowrap>&nbsp;Records / Page: <span id="rec_1"></span>&nbsp;</td>
				</tr>
			</table>
		</td>
	</tr>

</table>
<div id="filterBox" style="display:none;">
	<FORM  METHOD="GET" NAME="FT1" ID="FT1" ACTION="export_list.jsp" style="display:inline;">
	<INPUT TYPE="hidden" NAME="pageCount" VALUE="">
	<INPUT TYPE="hidden" NAME="curPage" VALUE="<%= curPage %>">
	<table class="listTable" cellspacing="0" cellpadding="2" border="0">
		<tr>
			<th valign="middle" align="left" colspan="2">Filter the Exports</th>
			<th valign="top" align="right" style="cursor:hand;" onclick="filterReveal(30);">&nbsp;<b>X</b>&nbsp;</th>
		</tr>
		<tr<%= !canCat.bRead?" style=\"display:none\"":"" %>>
			<td valign="middle" align="right">Category:&nbsp;</td>
			<td valign="middle" align="left"><%= CategortiesControl.toHtml(cust.s_cust_id, canCat.bExecute, sSelectedCategoryId,"") %></td>
			<td valign="middle" align="right">&nbsp;</td>
		</tr>
		<tr>
			<td valign="middle" align="right">&nbsp;Paging:&nbsp;</td>
			<td valign="middle" align="left">
				<SELECT NAME="amount" SIZE="1">
					<OPTION VALUE=1000>ALL</OPTION>
					<OPTION VALUE=10>10</OPTION>
					<OPTION VALUE=25>25</OPTION>
					<OPTION VALUE=50>50</OPTION>
					<OPTION VALUE=100>100</OPTION>
				</SELECT>
			</td>
			<td valign="middle" align="right">&nbsp;</td>
		</tr>
		<tr>
			<td valign="middle" align="center" colspan="2"><a class="subactionbutton" href="#" onClick="filterReveal(30);GO(0);">Filter</a></td>
			<td valign="middle" align="right">&nbsp;</td>
		</tr>
	</table>
	</FORM>
</div>
<br>

<FORM  METHOD="POST" NAME="FT" ACTION="export_delete.jsp">
<INPUT TYPE="hidden" NAME="NDELS" VALUE="0" >
<INPUT TYPE="hidden" NAME="FILE" VALUE="-9999">

<table cellspacing="0" cellpadding="0" width="650" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			<table class="main" cellspacing="1" cellpadding="2" border="0" align="right">
				<tr>
					<td align="right" valign="middle" nowrap>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td align="right" valign="middle" nowrap>&nbsp;<span id="page_1"></span></td>
					<td align="center" valign="middle">
						<table class="main" cellspacing="0" cellpadding="5" border="0">
							<tr>
								<td align="right" valign="middle" nowrap id="first_page" style="display:none"><a href="javascript:GO(0)"><< First</a></td>
								<td align="right" valign="middle" nowrap id="prev_page" style="display:none"><a href="javascript:GO(-1)">< Previous</a></td>
								<td align="right" valign="middle" nowrap id="next_page" style="display:none"><a href="javascript:GO(1)">Next ></a></td>
								<td align="right" valign="middle" nowrap id="last_page" style="display:none"><a href="javascript:GO(99)">Last >></a></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			
			<br><br>

			<div id="info">
			<div id="xsnazzy">
			<b class="xtop"><b class="xb1"></b><b class="xb2"></b><b class="xb3"></b><b class="xb4"></b></b>
			<div class="xboxcontent">	
							
			<table class="list_table" width="99.8%" cellspacing="0" cellpadding="2">
				<tr>
					<th align="left" nowrap>Exports</TH>
					<th align="left" nowrap> &nbsp;</TH>
					<th align="left" nowrap></TH>
					<th align="left" nowrap><img src="../../images/16_L_refresh.gif"/> <a href="#" onclick="GO(0);">Refresh</a></TH>
				</tr>	
				<tr>
				<%
				if (can.bDelete)
				{
					%>
					<th class="list_name" width="30">Delete</th>
					<%
				}
				%>
					<th class="list_name" width="550">Export Name</th>
					<th class="list_name" >Status</th>
					<th class="list_name"  width="50">&nbsp;</th>
				</tr>
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
					sClassAppend = "_Alt";
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
					<td class="listItem_Data<%= sClassAppend %>"><INPUT TYPE="checkbox" NAME="FILE" VALUE="<%=sFileId%>"  UNCHECKED <%=(isDisable)?"disabled":""%> ></TD>
					<%
				}
				%>
					<%if ((nTypeID == ExportType.CUSTOM)|| (nTypeID == ExportType.CUSTOM_FIXED_WIDTH) ){ %>	
					<td class="listItem_Title<%= sClassAppend %>">
						<%=(nStatusID == ExportStatus.COMPLETE)?"<a href=\"custom_export_edit.jsp?file_id="+sFileId+"&categoryId="+sSelectedCategoryId+" \" >"+sFilename+"</a>":sFilename%>
					</td>
					<%} else { %>
					<td class="listItem_Title<%= sClassAppend %>">
						<%=(nStatusID == ExportStatus.COMPLETE)?"<a href=\"export_edit.jsp?file_id="+sFileId+"&categoryId="+sSelectedCategoryId+" \" >"+sFilename+"</a>":sFilename%>
					</td>
					<%}%>
					
					<td class="listItem_Data<%= sClassAppend %>"><%=sStatus%></td>
					<td class="listItem_Data<%= sClassAppend %>">
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
			</table>
</div>
<b class="xbottom"><b class="xb4"></b><b class="xb3"></b><b class="xb2"></b><b class="xb1"></b></b>
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

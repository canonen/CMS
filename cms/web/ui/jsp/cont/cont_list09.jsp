<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.ctl.*,
			java.net.*,java.sql.*,
			java.util.*,java.io.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	
	AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

	if(!can.bRead)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}

	AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
	boolean canDynCont = ui.getFeatureAccess(Feature.DYNAMIC_CONTENT);
	boolean isPrintEnabled = ui.getFeatureAccess(Feature.PRINT_ENABLED);

	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;

	// === === ===

	String scurPage = request.getParameter("curPage");

	int	curPage	= 1;
	int contCount = 0;

	curPage	= (scurPage	== null) ? 1 : Integer.parseInt(scurPage);
	
	// ********** KU

	String samount = request.getParameter("amount");
	int amount = 0;
	
	if (samount == null) samount = ui.getSessionProperty("cont_list_page_size");
	if ((samount == null)||("".equals(samount))) samount = "25";
	try { amount = Integer.parseInt(samount); }
	catch (Exception ex) { samount = "25"; amount = 25; }
	ui.setSessionProperty("cont_list_page_size", samount);

	// ********** KU
	
	String strStatusId = null;
	String htmlFirstBox = "";
	String htmlContentRow = "";
	String htmlContentChild = "";
	String htmlContent = "";

	// === === ===

	ConnectionPool cp	= null;
	Connection 	conn	= null;
	Statement 	stmt	= null;			
	ResultSet 	rs		= null;
	Connection 	conn2	= null;
	Statement 	stmt2	= null;			
	ResultSet 	rs2		= null;
	Connection 	conn3	= null;
	Statement 	stmt3	= null;			
	ResultSet 	rs3		= null;

	try
	{

		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("cont_list");
		stmt = conn.createStatement();
		conn2 = cp.getConnection("cont_list 2");
		stmt2 = conn2.createStatement();
		conn3 = cp.getConnection("cont_list 3");
		stmt3 = conn3.createStatement();

		// === === ===
                       
		String sClassAppend = "";
		
		String sOldContID = "0";
		String sNewContID = "0";
		
		String sOldLogicID = "0";
		String sNewLogicID = "0";
		
		String sOldBlockID = "0";
		String sNewBlockID = "0";
		
		int blockCount = 0;
		
		String contID = null;
		String wizardString = null;
		String contName = null;
		String wizardID = null;
		int typeID;
		String typeName = null;
		String modifyDateTxt = null;
		int statusID;
		String statusName = null;
		String userName = null;
		String modifyDate = null;

		// === === ===
		
		String sSql =
			" Exec dbo.usp_ccnt_list_get" +
			" @type_id=" + ContType.CONTENT +
			", @CustomerId="+cust.s_cust_id;

		strStatusId = request.getParameter("status_id");
		if(strStatusId==null) strStatusId = "0"; /* Status default */
		if(!strStatusId.equals("0")) sSql += ",@StatusId=" + strStatusId;
		if (sSelectedCategoryId != null) sSql += ",@category_id="+sSelectedCategoryId;

		rs = stmt.executeQuery(sSql);		
		while (rs.next())
		{
			if (contCount % 2 != 0) sClassAppend = "_Alt";
			else sClassAppend = "";
			
			++contCount;
			
			htmlContentChild = "";

			//Page logic
			if (contCount <= (curPage-1)*amount) continue;
			else if (contCount > curPage*amount) continue;
	
			contID = rs.getString(1);
			contName = new String(rs.getBytes(2),"UTF-8");
			wizardID = rs.getString(3);
			typeID = rs.getInt(4);
			typeName = rs.getString(5);
			modifyDateTxt = rs.getString(6);
			statusID = rs.getInt(7);
			statusName = rs.getString(8);
			userName = rs.getString(9);
			modifyDate = rs.getString(10);
			
			htmlFirstBox = "<td class=\"listItem_Data" + sClassAppend + "\"><a href=\"javascript:goToEdit('" + contID + "', '" + typeID + "')\">" + contName + "</a></td>\n";
			
			// === === ===
			
			ContBody cb = new ContBody(contID);
			String sText = cb.s_text_part + cb.s_html_part + cb.s_aol_part;
			sText = ContUtil.replaceScrapeBlockIds(sText);
			Vector vLogicBlockIds = ContUtil.getLogicBlockIds(sText);
			String sLogicBlockId = null;
			
			for (Enumeration e = vLogicBlockIds.elements() ; e.hasMoreElements() ;)
			{
				sLogicBlockId = (String) e.nextElement();

				sSql = 
					" SELECT c.cont_id, c.cont_name," +
					" Convert(Varchar, ce.modify_date,100) as 'ModifyDate', cs.status_name " +
					" FROM ccnt_content c, ccnt_cont_edit_info ce, ccnt_cont_status cs " +
					" WHERE c.cont_id = " + sLogicBlockId + 
					" AND c.type_id = " + ContType.LOGIC_BLOCK +
					" AND c.cont_id = ce.cont_id " +
					" AND c.status_id = cs.status_id ";
				rs2 = stmt2.executeQuery(sSql);
				
				if (!rs2.next())
				{
					rs2.close();
					continue;
				}
				
				String logicID = rs2.getString(1);

				htmlContentChild += "<tr>\n";
				htmlContentChild += "<td class=\"listGroup_Data\">&nbsp;</td>\n";
				
				if (!canDynCont)
				{
					htmlContentChild +=
						"<td class=\"listGroupChild_Title\">"+
						new String(rs2.getBytes(2),"UTF-8")+
						"</td>\n";
				}
				else
				{
					String sUrl = 
						"cont/logic_block_edit.jsp?logic_id=" + logicID +
						((sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:"");
					sUrl = URLEncoder.encode(sUrl, "UTF-8");
					
					htmlContentChild +=
						"<td class=\"listGroupChild_Title\">" +
						"<a target=\"_top\" href=\"../index.jsp?tab=Cont&sec=2&url=" + sUrl +"\">"+
						new String(rs2.getBytes(2),"UTF-8")+
						"</a></td>\n";
				}
				
				htmlContentChild += "<td class=\"listGroupChild_Data\">Logic Block</td>\n";
				htmlContentChild += "<td class=\"listGroupChild_Data\" nowrap>"+rs2.getString(3)+"</td>\n";
				htmlContentChild += "<td class=\"listGroupChild_Data\" nowrap>"+rs2.getString(4)+"</td>\n";
				htmlContentChild += "</tr>\n";

				rs2.close();
				
				// === === ===

				sSql = 
					" SELECT c.cont_id, c.cont_name," +
					" Convert(Varchar, ce.modify_date,100) as 'ModifyDate', cs.status_name " +
					" FROM ccnt_cont_part p, ccnt_content c, " +
					" ccnt_cont_edit_info ce, ccnt_cont_status cs " +
					" WHERE p.parent_cont_id = " + logicID +
					" AND p.child_cont_id = c.cont_id " +
					" AND c.type_id = " + ContType.PARAGRAPH +
					" AND c.cont_id = ce.cont_id " +
					" AND c.status_id = cs.status_id " +
					" ORDER BY p.seq";
					
				rs3 = stmt3.executeQuery(sSql);
				blockCount = 0;
				
				while (rs3.next())
				{
					if (blockCount % 2 != 0) sClassAppend = "_Alt";
					else sClassAppend = "";
					
					++blockCount;
					
					String blockID = rs3.getString(1);

					htmlContentChild += "<tr>\n";
					htmlContentChild += "<td class=\"listItem_Data" + sClassAppend + "\">&nbsp;</td>\n";
					
					if (!canDynCont)
					{
htmlContentChild += "<td class=\"listItemChild_Title" + sClassAppend + "\">"+new String(rs3.getBytes(2),"UTF-8")+"</td>\n";
					}
					else
					{
htmlContentChild +=
	"<td class=\"listItemChild_Title" + sClassAppend + "\">" +
	"<a target=\"_top\" href=\"../index.jsp?tab=Cont&sec=2&url=" +
		URLEncoder.encode("cont/cont_block_edit.jsp?cont_id=" + blockID +
				((sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""),"UTF-8")+
	"\">" + new String(rs3.getBytes(2),"UTF-8")+"</a></td>\n";
					}
					htmlContentChild += "<td class=\"listItemChild_Data" + sClassAppend + "\">Content Element</td>\n";
					htmlContentChild += "<td class=\"listItem_Title" + sClassAppend + "\" nowrap>"+rs3.getString(3)+"</td>\n";
					htmlContentChild += "<td class=\"listItemChild_Data" + sClassAppend + "\" nowrap>"+rs3.getString(4)+"</td>\n";
					htmlContentChild += "</tr>\n";
				}
			}
			
			if ((contCount - 1) % 2 != 0) sClassAppend = "_Alt";
			else sClassAppend = "";
			
			boolean isTemplate = false;
						
			if (wizardID == null)
			{
				isTemplate = false;
			}
			else
			{
				isTemplate = true;
			}
			
			if (htmlContentChild.equals(""))
			{
				if (isTemplate) typeName = "Email Template";
				htmlContentRow += "<td class=\"listItem_Data" + sClassAppend + "\">&nbsp;</td>\n";
			}
			else
			{
				typeName = typeName + " (Dynamic)";
				if (isTemplate) typeName = "Email Template (Dynamic)";
				htmlContentRow += "<td class=\"listItem_Data" + sClassAppend + "\"><a id=\"link_" + contID + "\" class=\"resourcebutton\" style=\"width:15px;text-align:center;\" href=\"javascript:showHide('" + contID + "');\">+</a></td>\n";
				htmlContentChild = "<tbody id=\"cont_" + contID + "\" style=\"display:none;\">\n" + htmlContentChild + "</tbody>\n";
			}

			htmlContentRow += htmlFirstBox;
			
			htmlContentRow += "<td class=\"listItem_Data" + sClassAppend + "\">"+typeName+"</td>\n";

			htmlContentRow += "<td class=\"listItem_Title" + sClassAppend + "\" nowrap>"+modifyDateTxt+"</td>\n";
			htmlContentRow += "<td class=\"listItem_Data" + sClassAppend + "\" nowrap>"+statusName+"</td>\n";

			htmlContentRow += "</tr>\n";

			htmlContentRow += htmlContentChild;
			htmlContent += htmlContentRow;
			htmlContentRow = "";
		}

		if (htmlContent.length() == 0)
			htmlContent += "<tr><td colspan=\"5\" class=\"listItem_Data\">There is currently no Content</td></tr>\n";

	}
	catch(Exception ex) { throw ex; }
	finally
	{
		try
		{
			if (stmt3!=null) stmt3.close();
			if (stmt2!=null) stmt2.close();
			if (stmt!=null) stmt.close();
		}
		catch (SQLException ignore) { }
		
		if (conn3!=null) cp.free(conn3);
		if (conn2!=null) cp.free(conn2);
		if (conn!=null) cp.free(conn);
	}
%>

<html>
<head>
<title>Content List</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="javascript">

	function showHide(id)
	{
		if (document.getElementById("cont_" + id).style.display == "none")
		{
			document.getElementById("cont_" + id).style.display = "";
			document.getElementById("link_" + id).innerText = "-";
		}
		else
		{
			document.getElementById("cont_" + id).style.display = "none";
			document.getElementById("link_" + id).innerText = "+";
		}
	}
	
	function goToEdit(cont_id, type_id)
	{
		var sURL = "";
		
		//if (type_id == <%= ContType.PRINT %>) sURL = "../print/login.jsp?<%= ((sSelectedCategoryId!=null)?"category_id="+sSelectedCategoryId+"&":"") %>cont_id=" + cont_id;
		//else sURL = "cont_edit.jsp?<%= ((sSelectedCategoryId!=null)?"category_id="+sSelectedCategoryId+"&":"") %>cont_id=" + cont_id;
		sURL = "cont_edit.jsp?<%= ((sSelectedCategoryId!=null)?"category_id="+sSelectedCategoryId+"&":"") %>cont_id=" + cont_id;
		
		location.href = sURL;
	}

</script>
<script language="JavaScript" src="/cms/ui/ooo/script.js"></script>	
</head>
<BODY class="paging_body" onLoad="innerFramOnLoad();">
<table width="100%">
	<tr>
		<td class="page_header">Content</td>
	</tr>
</table>
<br>	
<div id="info">
<div id="xsnazzy">
<b class="xtop"><b class="xb1"></b><b class="xb2"></b><b class="xb3"></b><b class="xb4"></b></b>
<div class="xboxcontent">
<table cellpadding="3" cellspacing="0" border="0" width="95%">
	<tr>
		<% if (can.bWrite) { %>
		<td vAlign="middle" align="left" nowrap>
			<a class="newbutton" href="cont_edit.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">New <%= (isPrintEnabled)?"Email ":"" %>Content</a>&nbsp;&nbsp;&nbsp;
		</td>
		<% if (isPrintEnabled) { %>
		<td vAlign="middle" align="left" nowrap>
			<a class="newbutton" href="../print/cont_new.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">New Print Content</a>&nbsp;&nbsp;&nbsp;
		</td>
		<% } %>
		<td vAlign="middle" align="left" nowrap>
			<a class="newbutton" href="cont_load_manual.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">Upload Content Files</a>&nbsp;&nbsp;&nbsp;
		</td>
		<td vAlign="middle" align="left" nowrap>
			<a class="newbutton" href="cont_load_zip.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">Upload Content ZIP</a>&nbsp;&nbsp;&nbsp;
		</td>
		<% } %>
	</tr>
</table>
</div>
<b class="xbottom"><b class="xb4"></b><b class="xb3"></b><b class="xb2"></b><b class="xb1"></b></b>
</div>

			<table class="filterList" cellspacing="1" cellpadding="0" border="0">
				<tr>
					<td align="right" valign="middle" nowrap><a class="filterHeading" href="#" onclick="filterReveal(30);">Filter:</a></td>
					<td align="right" valign="middle" nowrap>&nbsp;Category: <span id="cat_1"></span>&nbsp;</td>
					<td align="right" valign="middle" nowrap>&nbsp;Records / Page: <span id="rec_1"></span>&nbsp;</td>
				</tr>
			</table>
			
<div id="filterBox" style="display:none;">
	<FORM  METHOD="GET" NAME="FT" ID="FT" ACTION="cont_list.jsp" style="display:inline;">
	<INPUT TYPE="hidden" NAME="pageCount" VALUE="">
	<INPUT TYPE="hidden" NAME="curPage" VALUE="<%= curPage %>">
	<table class="listTable" cellspacing="0" cellpadding="2" border="0">
		<tr>
			<th valign="middle" align="left" colspan="2">Filter the Content</th>
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
<table cellspacing="0" cellpadding="0" width="95%" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			<table class="main" cellspacing="1" cellpadding="2" border="0" align="right">
				<tr>
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
			<table class="listTable" width="100%" cellpadding="2" cellspacing="0">
				<tbody>
				<tr>
					<th align="left" nowrap>Content&nbsp;</TH>
					<th align="left" nowrap> &nbsp;</TH>
					<th align="left" nowrap> &nbsp;</TH>
					<th align="left" nowrap></TH>
					<th align="left" nowrap><img src="../../images/16_L_refresh.gif"/> <a href="#" onclick="GO(0);">Refresh</a></TH>
				</tr>						
				<tr>
					<th class="list_name" align="left" valign="middle" nowrap>&nbsp;</th>
					<th class="list_name" align="left" valign="middle" width="40%" nowrap>&#x20;Name</th>
					<th class="list_name" align="left" valign="middle" width="20%" nowrap>&#x20;Type</th>
					<th class="list_name" align="left" valign="middle" width="20%" nowrap>&#x20;Last update</th>
					<th class="list_name" align="left" valign="middle" width="20%" nowrap>&#x20;Status</th>
					<!--<th align="left" valign="middle" nowrap>&#x20;Action</th>//-->
					<!--<th align="left" valign="middle" nowrap>&#x20;Modified By</th>//-->
				</tr>
				<!-- List of the contents -->
				<%= htmlContent %>
				</tbody>
			</table>
</div>
<b class="xbottom"><b class="xb4"></b><b class="xb3"></b><b class="xb2"></b><b class="xb1"></b></b>
</div>			
		</td>
	</tr>
</table>
<br><br>
<script language="javascript">

<%@ include file="../../js/scripts.js" %>

function innerFramOnLoad()
{

	var prevPage = document.getElementById("prev_page");
	var firstPage = document.getElementById("first_page");
	var nextPage = document.getElementById("next_page");
	var lastPage = document.getElementById("last_page");

	FT.curPage.value = <%= curPage %>;
	FT.amount.value = <%= amount %>;

	<% if( curPage > 1) { %>
	prevPage.style.display = "";
	firstPage.style.display = "";
	<% } %>

	<% if( contCount > (curPage*amount) ) { %>
	nextPage.style.display = "";
	lastPage.style.display = "";
	<% } %>

	var recCount = new Number("<%= contCount %>");
	var perPage = new Number(FT.amount.value);
	var thisPage = new Number(FT.curPage.value);
	var catName = FT.category_id[FT.category_id.selectedIndex].text;

	var pageCount = new Number(Math.ceil(recCount / perPage));

	if (pageCount == 0)
	{
		pageCount = 1;
	}
	FT.pageCount.value = pageCount;
	
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
			FT.curPage.value=1;
			break;
		case 1:
			FT.curPage.value = <%= curPage + 1 %>;
			break;
		case 2:
			break;
		case -1:
			FT.curPage.value = <%= curPage - 1 %>;
			break;
		case 99:
			FT.curPage.value = FT.pageCount.value;
			break;
	}
	
	FT.submit();
}

</script>
</body>

</html>


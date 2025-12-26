<%@ page
	language="java"
	import="com.britemoon.cps.*,
			com.britemoon.*,
			com.britemoon.cps.ctl.*,
			java.util.*,java.sql.*,
			java.net.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.IMPORT);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

String sBatchID = request.getParameter("batch_id");

int nBatchID = Integer.parseInt((sBatchID == null)?"0":sBatchID);
 
boolean bCanExecute = can.bExecute;

// === === ===

String		scurPage	= request.getParameter("curPage");
String		samount		= request.getParameter("amount");

int			curPage			= 1;
int			amount			= 0;

curPage		= (scurPage		== null) ? 1 : Integer.parseInt(scurPage);

// === === ===

String sImportListGroupBy = ui.getSessionProperty("import_list_group_by");
String sGroupBy = request.getParameter("group_by");
if (sGroupBy == null)
{
	if ((null != sImportListGroupBy) && ("" != sImportListGroupBy))
	{
		sGroupBy = sImportListGroupBy;
	}
	else
	{
		sGroupBy = "import";
	}
}


ui.setSessionProperty("import_list_group_by", sGroupBy);

String sImportListOrderBy = ui.getSessionProperty("import_list_order_by");
String sOrderBy = request.getParameter("order_by");
if (sOrderBy == null)
{
	if ((null != sImportListOrderBy) && ("" != sImportListOrderBy))
	{
		sOrderBy = sImportListOrderBy;
	}
	else
	{
		sOrderBy = "date";
	}
}

ui.setSessionProperty("import_list_order_by", sOrderBy);

String sImportListPageSize = ui.getSessionProperty("import_list_page_size");
if (samount == null)
{
	if ((null != sImportListPageSize) && ("" != sImportListPageSize))
	{
		samount = sImportListPageSize;
	}
	else
	{
		samount = "25";
	}
}

amount = (samount==null)? 25 : Integer.parseInt(samount);

ui.setSessionProperty("import_list_page_size", samount);


String sSelectedCategoryId = request.getParameter("category_id");
if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
	sSelectedCategoryId = ui.s_category_id;

ConnectionPool	cp= null;
Connection		conn = null;
Statement		stmt = null; 

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("import_list.jsp");
	stmt = conn.createStatement();

%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<SCRIPT LANGUAGE="JAVASCRIPT">
<%@ include file="../../js/scripts.js" %>
</SCRIPT>
</HEAD>
<BODY onLoad="innerFramOnLoad()">
<%
String[]	tmp	= new String[14];
boolean		bCanMakeImport=false;

	//Make sure don''t have any uncommitted imports in queue 
	ResultSet rs = stmt.executeQuery ("SELECT count(*) from cupd_import i, cupd_batch b"
			+ " WHERE i.batch_id = b.batch_id"
			+ "  AND b.cust_id = " + cust.s_cust_id
			+ "  AND i.status_id < 50"); //ImportStatus.COMMIT_COMPLETE
	if (rs.next()) bCanMakeImport = (rs.getInt(1) == 0);
	rs.close ();
%>
<%
	if (!bCanMakeImport) // Warn that have import pending
	{
%>
<FONT COLOR="red">You currently have one or more imports pending.<br></FONT>
<BR>
<%
	}
%>

<table cellpadding="3" cellspacing="0" border="0" width="100%">
	<tr>
		<td vAlign="middle" align="left" nowrap>
<%
	if (can.bWrite)
	{
%>
		<table cellpadding="0" cellspacing="0" border="0">
			<tr>
				<td nowrap valign="middle">
					<strong>Select a batch and Import a File</strong>&nbsp;&nbsp;&nbsp;
				</td>
				<td nowrap valign="middle" rowspan="2">&nbsp; OR &nbsp; </td>
				<td nowrap valign="middle">
					<strong>Manually Add Recipients</strong>&nbsp;&nbsp;&nbsp;
				</td>
			</tr>
			<tr>
				<td nowrap valign="middle">
					<FORM  METHOD="POST" NAME="FT" ID="FT" ACTION="import_list.jsp" style="display:inline;">
					<%=(sSelectedCategoryId!=null)?"<INPUT type=\"hidden\" name=\"category_id\" value=\""+sSelectedCategoryId+"\">":""%>
					<table cellpadding="2" cellspacing="0">
						<tr>
							<td nowrap>
							<a class="newbutton" href="javascript:submitForm();" <%=(!bCanExecute)?"disabled":""%>>New Import</a>
							&nbsp;&nbsp;
							<SELECT NAME=batch_id>
								<OPTION VALUE=0> --- --- --- New Batch --- --- ---</OPTION>
<%
		//Load the possible batches
		if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) )
		{
			rs = stmt.executeQuery(" SELECT DISTINCT b.batch_id, b.batch_name" +
									" FROM cupd_batch b" + 
									" WHERE b.type_id = 1" + 
									"  AND b.batch_id IN (SELECT DISTINCT i.batch_id" +
										" FROM cupd_import i, cupd_batch b" +
										" WHERE i.status_id = "+UpdateStatus.COMMIT_COMPLETE+
										" AND i.batch_id = b.batch_id AND b.cust_id = " + cust.s_cust_id + ")" +
									"  AND b.cust_id = " + cust.s_cust_id +
									" ORDER BY b.batch_id DESC");
		}
		else
		{
			rs = stmt.executeQuery(" SELECT DISTINCT b.batch_id, b.batch_name" +
									" FROM cupd_batch b" + 
									" WHERE b.type_id = 1" + 
									" AND b.batch_id IN (SELECT DISTINCT i.batch_id" +
										" FROM cupd_import i, cupd_batch b, ccps_object_category oc" +
										" WHERE i.status_id = "+UpdateStatus.COMMIT_COMPLETE+
										" AND i.batch_id = b.batch_id" +
										" AND b.cust_id = " + cust.s_cust_id + 
											" AND oc.object_id = i.import_id" +
										" AND oc.type_id = " + ObjectType.IMPORT +
										" AND oc.cust_id = " + cust.s_cust_id +
										" AND oc.category_id = " + sSelectedCategoryId + ")" +
									" AND b.cust_id = " + cust.s_cust_id +
									" ORDER BY b.batch_id DESC");
		}

		while (rs.next())
		{
%>
			<OPTION VALUE=<%= rs.getInt(1) %>><%= rs.getString(2) %></OPTION>
<%
		}
		rs.close();
%>
							</SELECT>&nbsp;&nbsp;&nbsp;
							</td>
						</tr>
					</table>
					</FORM>
				</td>
				<td nowrap valign="middle">
					<a class="newbutton" href="../edit/manual_import.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>" <%=(!bCanExecute)?"disabled":""%>>Manual Entry</a>&nbsp;&nbsp;&nbsp;
				</td>
			</tr>
		</table>
<%
	}
%>
		</td>
		<td nowrap valign="middle" align="right" width="100%">
			<table class="filterList" cellspacing="1" cellpadding="0" border="0">
				<tr>
					<td align="right" valign="middle" class="filterHeading" nowrap rowspan="2"><a class="filterHeading" href="#" onclick="filterReveal(30);">Filter:</a></td>
					<td align="right" valign="middle" nowrap>&nbsp;Category: <span id="cat_1"></span>&nbsp;</td>
					<td align="right" valign="middle" nowrap>&nbsp;Records / Page: <span id="rec_1"></span>&nbsp;</td>
				</tr>
				<tr>
					<td align="right" valign="middle" nowrap>&nbsp;Grouped By: <span id="group_1"></span>&nbsp;</td>
					<td align="right" valign="middle" nowrap>&nbsp;Sorted By: <span id="order_1"></span>&nbsp;</td>
				</tr>
			</table>
		</td>
	</tr>
</table>	
<div id="filterBox" style="display:none;">
	<FORM  METHOD="GET" NAME="FT1" ID="FT1" ACTION="import_list.jsp" style="display:inline;">
	<INPUT TYPE="hidden" NAME="pageCount" VALUE="">
	<INPUT TYPE="hidden" NAME="curPage" VALUE="<%= curPage %>">
	<table class="listTable" cellspacing="0" cellpadding="2" border="0">
		<tr>
			<th valign="middle" align="left" colspan="2">Filter the Imports</th>
			<th valign="top" align="right" style="cursor:hand;" onclick="filterReveal(30);">&nbsp;<b>X</b>&nbsp;</th>
		</tr>
		<tr<%= !canCat.bRead?" style=\"display:none\"":"" %>>
			<td valign="middle" align="right">Category:&nbsp;</td>
			<td valign="middle" align="left"><%= CategortiesControl.toHtml(cust.s_cust_id, canCat.bExecute, sSelectedCategoryId,"") %></td>
			<td valign="middle" align="right">&nbsp;</td>
		</tr>
		<tr>
			<td valign="middle" align="right">&nbsp;Group By:&nbsp;</td>
			<td valign="middle" align="left"><select name="group_by" id="group_by"><option value="batch"<%=(sGroupBy.equals("batch"))?" selected":""%>>Batch</option><option value="import"<%=(sGroupBy.equals("import"))?" selected":""%>>Import</option></select></td>
			<td valign="middle" align="right">&nbsp;</td>
		</tr>
		<tr>
			<td valign="middle" align="right">&nbsp;Sort By:&nbsp;</td>
			<td valign="middle" align="left"><select name="order_by" id="order_by"><option value="name"<%=(sOrderBy.equals("name"))?" selected":""%>>Name</option><option value="date"<%=(sOrderBy.equals("date"))?" selected":""%>>Date</option></select></td>
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

<%
	if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) )
	{
	  	rs = stmt.executeQuery(	"SELECT	i.import_id,"
				+ " i.import_name,"
				+ " isnull(convert(varchar(50),i.import_date,100),'') as import_date,"
				+ " s.display_name,"
				+ " b.batch_name,"
				+ " ISNULL(st.tot_rows,0),"
				+ " ISNULL(st.bad_emails,0) + ISNULL(st.bad_rows,0),"
				+ " ISNULL(st.warning_recips,0),"
				+ " ISNULL(st.file_dups,0),"
				+ " ISNULL(st.dup_recips,0),"
				+ " ISNULL(st.new_recips,0),"
				+ " ISNULL(st.num_committed,0),"
				+ " ISNULL(st.left_to_commit,0),"
				+ " s.status_id"
			+ " FROM cupd_import i"
				+ " INNER JOIN cupd_batch b"
					+ " ON i.batch_id = b.batch_id"
					+ " AND b.type_id = 1"
					+ " AND b.cust_id = " + cust.s_cust_id
				+ " INNER JOIN cupd_import_status s ON i.status_id = s.status_id"
				+ " LEFT OUTER JOIN cupd_import_statistics st ON i.import_id = st.import_id"
			+ " WHERE i.status_id < 50" //ImportStatus.COMMIT_COMPLETE
			+ " ORDER BY b.batch_name, i.import_id DESC");
	}
	else
	{
	  	rs = stmt.executeQuery(	"SELECT	i.import_id,"
				+ " i.import_name,"
				+ " isnull(convert(varchar(50),i.import_date,100),'') as import_date,"
				+ " s.display_name,"
				+ " b.batch_name,"
				+ " ISNULL(st.tot_rows,0),"
				+ " ISNULL(st.bad_emails,0) + ISNULL(st.bad_rows,0),"
				+ " ISNULL(st.warning_recips,0),"
				+ " ISNULL(st.file_dups,0),"
				+ " ISNULL(st.dup_recips,0),"
				+ " ISNULL(st.new_recips,0),"
				+ " ISNULL(st.num_committed,0),"
				+ " ISNULL(st.left_to_commit,0),"
				+ " s.status_id"
			+ " FROM cupd_import i"
				+ " INNER JOIN cupd_batch b"
					+ " ON (i.batch_id = b.batch_id"
					+ " AND b.type_id = 1"
					+ " AND b.cust_id = " + cust.s_cust_id + ")"
				+ " INNER JOIN ccps_object_category c"
					+ " ON (i.import_id = c.object_id"
					+ " AND c.cust_id = " + cust.s_cust_id
					+ " AND c.type_id = " + ObjectType.IMPORT
					+ " AND c.category_id = " + sSelectedCategoryId + ")"
				+ " INNER JOIN cupd_import_status s ON i.status_id = s.status_id"
				+ " LEFT OUTER JOIN cupd_import_statistics st ON i.import_id = st.import_id"
			+ " WHERE i.status_id < 50" //ImportStatus.COMMIT_COMPLETE
			+ " ORDER BY b.batch_name, i.import_id DESC");
	}
		
	int importCount = 0;
	int nStatusID = 0;
	String sUrl = null;
	
	String sClassAppend = "_Alt";
	
	while(rs.next())
	{ 
		if (importCount == 0)
		{
%>
<table cellspacing="0" cellpadding="0" width="100%" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			<table cellspacing="0" cellpadding="0" border="0" align="right">
				<tr>
					<td align="right" valign="middle">&nbsp;&nbsp;<a class="resourcebutton" href="#" onclick="GO(0);">Refresh List</a>&nbsp;&nbsp;</td>
				</tr>
			</table>
			Current Imports
			<br><br>
			<table class="listTable" cellpadding="2" cellspacing="0" WIDTH="100%">
				<tr>
					<th nowrap>Status</th>
					<th nowrap width=150>Import Name</th>
					<th nowrap>Import Date</th>
					<th nowrap>Batch</th>
					<th nowrap>Total in File</th>
					<th nowrap>Rejected</th>
					<!--<th nowrap>Warnings</th><th nowrap>File duplicates</th>//-->
					<th nowrap>Duplicate Recipients</th>
					<th nowrap>New Recipients</th>
					<!--<th nowrap>Committed</th>//-->
					<th nowrap>Left to Commit</th>
				</tr>
<%
		}
		
		if (importCount % 2 != 0) sClassAppend = "_Alt";
		else sClassAppend = "";

		importCount++;
	
		tmp[0] = rs.getString(1);	// import_id
		tmp[1] = rs.getString(2);	// import_name
		tmp[2] = rs.getString(3); 	// import_date
		tmp[3] = rs.getString(4);	// status_name
		tmp[4] = rs.getString(5);	// batch_name
		tmp[5] = rs.getString(6);	// tot_rows
		tmp[6] = rs.getString(7);	// bad_emails + bad_rows
		tmp[7] = rs.getString(8);	// warning_recips
		tmp[8] = rs.getString(9);	// file_dups
		tmp[9] = rs.getString(10);	// dup_recips
		tmp[10] = rs.getString(11);	// new_recips
		tmp[11] = rs.getString(12);	// num_committed
		tmp[12] = rs.getString(13);	// left_to_commit
		nStatusID = rs.getInt(14);  // status_id

		sUrl = "import_details.jsp?import_id="+tmp[0];
%>
				<tr>
					<td class="listItem_Data<%= sClassAppend %>"><%=tmp[3]%></td>
					<td class="<%=(sOrderBy.equals("name"))?"listItem_Title":"listItem_Data"%><%= sClassAppend %>"><a href="<%=sUrl%><%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>" target="_self"><%=tmp[1]%></a></td>
					<td class="<%=(sOrderBy.equals("date"))?"listItem_Title":"listItem_Data"%><%= sClassAppend %>"><%=tmp[2]%></td>
					<td class="listItem_Data<%= sClassAppend %>"><%=tmp[4]%></td>
					<td class="listItem_Data<%= sClassAppend %>"><%=tmp[5]%></td>
					<td class="listItem_Data<%= sClassAppend %>"><%=tmp[6]%></td>
					<!--<td class="listItem_Data<%= sClassAppend %>"><%=tmp[7]%></td><td class="listItem_Data<%= sClassAppend %>"><%=tmp[8]%></td>-->
					<td class="listItem_Data<%= sClassAppend %>"><%=tmp[9]%></td>
					<td class="listItem_Data<%= sClassAppend %>"><%=tmp[10]%></td>
					<!--<td class="listItem_Data<%= sClassAppend %>"><%=tmp[11]%></td>-->
					<td class="listItem_Data<%= sClassAppend %>"><%=tmp[12]%></td>
				</tr>
<%
	}
	rs.close();
	if (importCount != 0)
	{
%>
			</table>
		</td>
	</tr>
</table>
<br>
<%
	}
%>
<table cellspacing="0" cellpadding="0" width="100%" border="0">
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
			Completed Imports
			<br><br>
			<table class="listTable" cellpadding="2" cellspacing="0" width="100%">
				<tr>
					<th nowrap width="150">Import Name</th>
					<th nowrap>Import Date</th>
					<%=(sGroupBy.equals("batch"))?"":"<th nowrap>Batch</th>"%>
					<th nowrap>Status</th>
					<th nowrap>Total in File</th>
					<th nowrap>Rejected</th>
					<!-- <th nowrap>Warnings</th><th nowrap>File duplicates</th>-->
					<th nowrap>Duplicate Recipients</th>
					<th nowrap>New Recipients</th>
					<!-- <th nowrap>Committed</th><th nowrap>Left to Commit</th> -->
				</tr>
<%
	String sSQL = "";

	if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) ) {
		sSQL = "SELECT	i.import_id,"
				+ " i.import_name,"
				+ " isnull(convert(varchar(50),i.import_date,100),'') as show_date,"
				+ " s.display_name,"
				+ " b.batch_name,"
				+ " ISNULL(st.tot_rows,0),"
				+ " ISNULL(st.bad_emails,0) + ISNULL(st.bad_rows,0),"
				+ " ISNULL(st.warning_recips,0),"
				+ " ISNULL(st.file_dups,0),"
				+ " ISNULL(st.dup_recips,0),"
				+ " ISNULL(st.new_recips,0),"
				+ " ISNULL(st.num_committed,0),"
				+ " ISNULL(st.left_to_commit,0),"
				+ " s.status_id,"
				+ " b.batch_id"
			+ " FROM cupd_import i";
			
		if (sGroupBy.equals("batch"))
		{	
			sSQL += " INNER JOIN (cupd_batch b INNER JOIN cupd_import ii ON b.batch_id = ii.batch_id)";
		}
		else
		{
			sSQL += " INNER JOIN cupd_batch b";

		}
		sSQL += " ON (i.batch_id = b.batch_id"
					+ " AND b.type_id = 1"
					+ " AND b.cust_id = " + cust.s_cust_id + ")"
				+ " INNER JOIN cupd_import_status s ON i.status_id = s.status_id"
				+ " LEFT OUTER JOIN cupd_import_statistics st ON i.import_id = st.import_id"
			+ " WHERE i.status_id >= 50" //ImportStatus.COMMIT_COMPLETE
			+ " AND i.status_id < 80"; //ImportStatus.DELETED
		
		if (sGroupBy.equals("batch"))
		{
			sSQL += " GROUP BY b.batch_name, b.batch_id, i.import_date, i.import_id, i.import_name, s.display_name, b.batch_name,"
			+ " st.tot_rows, st.bad_emails, st.bad_rows, st.warning_recips, st.file_dups, st.dup_recips, "
			+ " st.new_recips, st.num_committed, st.left_to_commit, s.status_id";
			
			if (sOrderBy.equals("name"))
			{
				sSQL += "  ORDER BY b.batch_name, i.import_date DESC";
			}
			else
			{
				sSQL += "  ORDER BY max(ii.import_date) DESC, b.batch_name, i.import_date DESC";
			}
		}
		else
		{
			if (sOrderBy.equals("name"))
			{
				sSQL += "  ORDER BY i.import_name, i.import_date DESC";
			}
			else
			{
				sSQL += "  ORDER BY i.import_date DESC";
			}
		}
		
	} else {
	  	
		sSQL = "SELECT	i.import_id,"
				+ " i.import_name,"
				+ " isnull(convert(varchar(50),i.import_date,100),'') as show_date,"
				+ " s.display_name,"
				+ " b.batch_name,"
				+ " ISNULL(st.tot_rows,0),"
				+ " ISNULL(st.bad_emails,0) + ISNULL(st.bad_rows,0),"
				+ " ISNULL(st.warning_recips,0),"
				+ " ISNULL(st.file_dups,0),"
				+ " ISNULL(st.dup_recips,0),"
				+ " ISNULL(st.new_recips,0),"
				+ " ISNULL(st.num_committed,0),"
				+ " ISNULL(st.left_to_commit,0),"
				+ " s.status_id,"
				+ " b.batch_id"
			+ " FROM cupd_import i";
			
		if (sGroupBy.equals("batch"))
		{	
			sSQL += " INNER JOIN (cupd_batch b INNER JOIN cupd_import ii ON b.batch_id = ii.batch_id)";
		}
		else
		{
			sSQL += " INNER JOIN cupd_batch b";

		}
		sSQL += " ON (i.batch_id = b.batch_id"
					+ " AND b.type_id = 1"
					+ " AND b.cust_id = " + cust.s_cust_id + ")"
				+ " INNER JOIN ccps_object_category c"
					+ " ON (i.import_id = c.object_id"
					+ " AND c.cust_id = " + cust.s_cust_id
					+ " AND c.type_id = " + ObjectType.IMPORT
					+ " AND c.category_id = " + sSelectedCategoryId + ")"
				+ " INNER JOIN cupd_import_status s ON i.status_id = s.status_id"
				+ " LEFT OUTER JOIN cupd_import_statistics st ON i.import_id = st.import_id"
			+ " WHERE i.status_id >= 50" //ImportStatus.COMMIT_COMPLETE
			+ " AND i.status_id < 80"; //ImportStatus.DELETED
		
		if (sGroupBy == "batch")
		{
			sSQL += "  GROUP BY b.batch_name, b.batch_id, i.import_date, i.import_id, i.import_name, s.display_name, b.batch_name,"
			+ "  st.tot_rows, st.bad_emails, st.bad_rows, st.warning_recips, st.file_dups, st.dup_recips, "
			+ "  st.new_recips, st.num_committed, st.left_to_commit, s.status_id"
			+ "  ORDER BY max(ii.import_date) DESC, b.batch_name, i.import_date DESC";
		}
		else
		{
			sSQL += "  ORDER BY i.import_id DESC";
		}
		
	}

	rs = stmt.executeQuery(sSQL);

	int checkBatchID = 0;
	nStatusID = 0;
	sUrl = null;

	importCount = 0;

	int iGroupCount = 0;

	sClassAppend = "_Alt";

	int oldBatchID = 0;
	int newBatchID = 0;

	while(rs.next())
	{
		importCount++;
		
		tmp[0] = rs.getString(1);	// import_id
		tmp[1] = rs.getString(2);	// import_name
		tmp[2] = rs.getString(3); 	// import_date
		tmp[3] = rs.getString(4);	// status_name
		tmp[4] = rs.getString(5);	// batch_name
		tmp[5] = rs.getString(6);	// tot_rows
		tmp[6] = rs.getString(7);	// bad_emails + bad_rows
		tmp[7] = rs.getString(8);	// warning_recips
		tmp[8] = rs.getString(9);	// file_dups
		tmp[9] = rs.getString(10);	// dup_recips
		tmp[10] = rs.getString(11);	// new_recips
		tmp[11] = rs.getString(12);	// num_committed
		tmp[12] = rs.getString(13);	// left_to_commit
		nStatusID = rs.getInt(14);  // status_id
		checkBatchID = rs.getInt(15);	// batch_id
		
		newBatchID = checkBatchID;

		sUrl = "import_details.jsp?import_id="+tmp[0];
		
		//Page logic
		if ((importCount <= (curPage-1)*amount) || (importCount > curPage*amount)) continue;
		
		if (sGroupBy.equals("batch"))
		{
			if (newBatchID != oldBatchID)
			{
%>
				<tr>
					<td align="left" valign="middle" colspan="9" width="100%" class="listGroup_Title"><%= tmp[4] %></td>
				</tr>
<%
				iGroupCount++;
				oldBatchID = newBatchID;
			}
			
			sClassAppend = "";
		}
		else
		{
			if (importCount % 2 != 0)
			{
				sClassAppend = "_Alt";
			}
			else
			{
				sClassAppend = "";
			}
		}
%>
				<tr>
					<td class="listItem<%=(sGroupBy.equals("batch"))?"Child":""%><%=(sOrderBy.equals("name"))?"_Title":"_Data"%><%= sClassAppend %>"><a href="<%=sUrl%><%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>" target="_self"><%=tmp[1]%></a></td>
					<td class="<%=(sOrderBy.equals("date"))?"listItem_Title":"listItem_Data"%><%= sClassAppend %>"><%=tmp[2]%></td>
					<%=(sGroupBy.equals("batch"))?"":"<TD class=\"listItem_Data" + sClassAppend + "\">" + tmp[4] + "</td>"%>
					<td class="listItem_Data<%= sClassAppend %>"><%=tmp[3]%></td>
					<td class="listItem_Data<%= sClassAppend %>"><%=tmp[5]%></td>
					<td class="listItem_Data<%= sClassAppend %>"><%=tmp[6]%></td>
					<!--<td class="listItem_Data<%= sClassAppend %>"><%=tmp[7]%></td><td class="listItem_Data<%= sClassAppend %>"><%=tmp[8]%></td>-->
					<td class="listItem_Data<%= sClassAppend %>"><%=tmp[9]%></td>
					<td class="listItem_Data<%= sClassAppend %>"><%=tmp[10]%></td>
					<!--<td class="listItem_Data<%= sClassAppend %>"><%=tmp[11]%></td>
					<td class="listItem_Data<%= sClassAppend %>"><%=tmp[12]%></td>-->
				</tr>
<%
	}
	rs.close();
	if (importCount == 0)
	{
%>
				<tr>
					<td class="listItem_Title" colspan="10" align="left" valign="middle">There are no imports currently.</td>
				</tr>
<%
	}
%>
			</table>
		</td>
	</tr>
</table>
<br><br>
</BODY>


<SCRIPT>

function innerFramOnLoad()
{

	FT1.curPage.value = <%= curPage %>;
	FT1.amount.value = <%= amount %>;

	var prevPage = document.getElementById("prev_page");
	var firstPage = document.getElementById("first_page");
	var nextPage = document.getElementById("next_page");
	var lastPage = document.getElementById("last_page");

	// === === ===

	<%
	if( curPage > 1)
	{
	%>
		prevPage.style.display = "";
		firstPage.style.display = "";
		<%
	}

	if( importCount > (curPage*amount) )
	{
	%>
		nextPage.style.display = "";
		lastPage.style.display = "";
		<%
	}
	%>

	var recCount = new Number("<%= importCount %>");
	var perPage = new Number(FT1.amount.value);
	var thisPage = new Number(FT1.curPage.value);
	var catName = FT1.category_id[FT1.category_id.selectedIndex].text;
	var groupByName = FT1.group_by[FT1.group_by.selectedIndex].text;
	var orderbyName = FT1.order_by[FT1.order_by.selectedIndex].text;

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
	document.getElementById("group_1").innerHTML = groupByName;
	document.getElementById("order_1").innerHTML = orderbyName;
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
		case -1:
			FT1.curPage.value = <%= curPage - 1 %>;
			break;
		case 99:
			FT1.curPage.value = FT1.pageCount.value;
			break;
	}
	
	FT1.submit();
}

function submitForm()
{
	location.href = 'import_new.jsp?<%=(sSelectedCategoryId!=null)?"category_id="+sSelectedCategoryId+"&":""%>batch_id='+FT.batch_id.value;
}

</SCRIPT>
</HTML>
<%
}
catch(Exception ex)
{ 
	ErrLog.put(this, ex, "Problem getting Import list", out, 1);
}
finally
{
	if ( stmt != null ) stmt.close();
	if ( conn != null ) cp.free(conn); 
}
%>

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

//Is it the standard ui?
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);


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
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<c:set var="loc" value="en_US"/>
<c:if test="${!(empty param.locale)}">
  <c:set var="loc" value="${param.locale}"/>
</c:if>
<fmt:setLocale value="${loc}" />

<fmt:bundle basename="app">
<head>

<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<link rel="stylesheet" href="/cms/ui/css/demo_table_jui.css" TYPE="text/css">
<link rel="stylesheet" href="/cms/ui/css/jquery-ui-1.7.2.custom.css" TYPE="text/css">

<SCRIPT LANGUAGE="JAVASCRIPT">
<%@ include file="../../js/scripts.js" %>
</SCRIPT>
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
					
					
				oTable2 = $('#example2').dataTable( {
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
</HEAD>
<BODY class="paging_body">
<DIV id=tsnazzy>
<div class="page_header"><fmt:message key="header_import"/></div>
<div class="page_desc"><fmt:message key="header_import_desc"/></div>
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
<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
  <TBODY>
  <TR>
    <TD class="listHeading" vAlign="center" noWrap="nowrap" align="left">
		<DIV id=info>
		<DIV id=xsnazzy>
			<DIV class=xboxcontent>
				<FORM  METHOD="POST" NAME="FT" ID="FT" ACTION="import_list.jsp" style="display:inline;">
<%=(sSelectedCategoryId!=null)?"<INPUT type=\"hidden\" name=\"category_id\" value=\""+sSelectedCategoryId+"\">":""%>
				<TABLE class=listTable cellSpacing=0 cellPadding=2 width="100%" style="padding-top: 4px;">
					<TBODY>
						<TR>
<%
//if (!STANDARD_UI) {
%>						
							<TD noWrap valign="top" align=left style="padding-left:10px; width:5%;"><a class="newbutton" href="javascript:submitForm();"><fmt:message key="button_import"/></a>&nbsp; </TD>
							<TD noWrap valign="top" align=left style="padding-left:10px; width:5%;">
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
							</SELECT>
							</TD>
<%
//}
%>
							<TD noWrap valign="top" align=left style="width:5%;"><a class="newbutton" href="../edit/manual_import.jsp"><fmt:message key="button_import_manual"/></a>&nbsp; </TD>
							<TD noWrap valign="top" align=right style="padding-left:10px; width:95%;">
								Filter&nbsp;<select id="filter"><option value="">No Filters</option>
<%									
	ResultSet batches = stmt.executeQuery(
							"SELECT DISTINCT batch_name FROM cupd_batch WHERE batch_id IN (SELECT DISTINCT i.batch_id" +
							" FROM cupd_import i, cupd_batch b" +
							" WHERE i.status_id = "+UpdateStatus.COMMIT_COMPLETE+
							" AND i.batch_id = b.batch_id AND b.cust_id = " + cust.s_cust_id + ")" +
							" AND cust_id = " + cust.s_cust_id + " ORDER BY batch_name");
	while(batches.next()){
%>
<option value="<%=batches.getString(1)%>"><%=batches.getString(1)%></option>
<%
	}
%>								</select>
								&nbsp; 
							</TD>
							<TD noWrap valign="top" ><A class="data_refresh" href="import_list.jsp"><fmt:message key="button_refresh"/></A>
							</TD>
						</TR>
					</TBODY>
				</TABLE>
				</FORM>
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
	
	String sClassAppend = "_other";
	
	while(rs.next())
	{ 
		if (importCount == 0)
		{
%>	
<div class="list-headers">Current Imports</div>
<table cellspacing="0" cellpadding="0" width="99.8%" border="0">	
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			<table class="listTable" id="example2" cellpadding="2" cellspacing="0" width="100%">
				<THEAD>		
				<tr>
					<th nowrap><fmt:message key="im_column_import_status"/></th>
					<th nowrap width=150><fmt:message key="im_column_import_name"/></th>
					<th nowrap><fmt:message key="im_column_import_date"/></th>
					<th nowrap>Batch</th>
					<th nowrap>Total in File</th>
					<th nowrap><fmt:message key="im_column_import_rejected"/></th>
					<th nowrap>Left to Commit</th>
				</tr>
				</THEAD>
				<TBODY>
<%
		}
		
		if (importCount % 2 != 0) sClassAppend = "_other";
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
					<td class="list_row<%= sClassAppend %>"><%=tmp[3]%></td>
					<td class="<%=(sOrderBy.equals("name"))?"list_row":"list_row"%><%= sClassAppend %>"><a href="<%=sUrl%><%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>" target="_self"><%=tmp[1]%></a></td>
					<td class="<%=(sOrderBy.equals("date"))?"list_row":"list_row"%><%= sClassAppend %>"><%=tmp[2]%></td>
					<td class="list_row<%= sClassAppend %>"><%=tmp[4]%></td>
					<td class="list_row<%= sClassAppend %>"><%=tmp[5]%></td>
					<td class="list_row<%= sClassAppend %>"><%=tmp[6]%></td>
					<td class="list_row<%= sClassAppend %>"><%=tmp[12]%></td>
				</tr>
<%
	}
	rs.close();
	if (importCount != 0)
	{
%>
			</TBODY>
			</table>
		</td>
	</tr>
</table>

<br>
<%
	}
%>		

<div class="list-headers">Completed Imports</div>

<table cellspacing="0" cellpadding="0" width="99.8%" border="0" >
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
			<table class="listTable" id="example" cellpadding="2" cellspacing="0" width="100%">
				<THEAD>
				<tr>
					<TH><input type="checkbox" id="checkboxall"></TH>
					<th></th>
					<th nowrap width="150"><fmt:message key="im_column_import_name"/></th>
					<th nowrap><fmt:message key="im_column_import_date"/></th>
					<%=(sGroupBy.equals("batch"))?"":"<th nowrap>Batch</th>"%>
					<th nowrap><fmt:message key="im_column_import_status"/></th>
					<th nowrap width="50"><fmt:message key="im_column_import_total"/>&nbsp;&nbsp;</th>
					<th nowrap width="90"><fmt:message key="im_column_import_rejected"/></th>
					<th nowrap width="100"><fmt:message key="im_column_import_dup"/></th>
					<th nowrap width="50"><fmt:message key="im_column_import_new"/>&nbsp;&nbsp;</th>
				</tr>
				</THEAD>
				<TBODY>
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

	sClassAppend = "_other";

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
				sClassAppend = "_other";
			}
			else
			{
				sClassAppend = "";
			}
		}
%>
			<tr>
					<TD class="list_row<%= sClassAppend %>"><input type="checkbox" class="check_me" name="check1"></TD>
					<TD class="list_row<%= sClassAppend %>"><img src="../../images/icon_report_18_18.png" border="0" alt=""></TD>
					<td class="list_row<%=(sGroupBy.equals("batch"))?"Child":""%><%=(sOrderBy.equals("name"))?"_Title":""%><%= sClassAppend %>"><a href="<%=sUrl%><%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>" target="_self"><%=tmp[1]%></a></td>
					<td class="<%=(sOrderBy.equals("date"))?"list_row":"list_row_"%><%= sClassAppend %>"><%=tmp[2]%></td>
					<%=(sGroupBy.equals("batch"))?"":"<TD class=\"list_row" + sClassAppend + "\">" + tmp[4] + "</td>"%>
					<td class="list_row<%= sClassAppend %>"><%=tmp[3]%></td>
					<td class="list_row<%= sClassAppend %>"><%=tmp[5]%></td>
					<td class="list_row<%= sClassAppend %>"><%=tmp[6]%></td>
					<td class="list_row<%= sClassAppend %>"><%=tmp[9]%></td>
					<td class="list_row<%= sClassAppend %>"><%=tmp[10]%></td>
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
				</TBODY>
			</table>
		</td>
	</tr>
</table>
</div>

</div>
</div>


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
</body>
</fmt:bundle>

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

<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.ctm.*"
	import="org.apache.log4j.*"
	import="java.util.*"
	import="java.sql.*"
	import="java.net.*"
	import="java.text.DateFormat"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<%  if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<jsp:useBean id="tbeans" class="java.util.Hashtable" scope="application" />
<%
//Make sure these are gone
session.removeAttribute("pbean");
session.removeAttribute("tbean");

String		scurPage	= request.getParameter("curPage");
String		samount		= request.getParameter("amount");
String		sOrderBy	= request.getParameter("sort_by"); 
int			curPage			= 1;
int			amount			= 0;

curPage		= (scurPage		== null) ? 1 : Integer.parseInt(scurPage);

if ((samount == null)||("".equals(samount))) samount = "25";
try { amount = Integer.parseInt(samount); }
catch (Exception ex) 
{ 
	samount = "25"; 
	amount = 25;
}

if ((sOrderBy == null)||("".equals(sOrderBy))) sOrderBy = "mod_date desc";

//Grab this customer's pages from the db
ConnectionPool connPool = null;
Connection conn         = null;
Statement stmt          = null;
ResultSet rs            = null;

String isAdmin = (String)session.getAttribute("isAdmin");
String isHyatt = (String)session.getAttribute("isHyatt");
String isWizard = (String)session.getAttribute("isWizard");
String isParent = "0";

int templateID, contentID;
String t_image, pageName, templateName, status;
Timestamp modDate;

StringBuilder TABLE_TR = new StringBuilder();

if (isAdmin == null || isAdmin.length() == 0) {
    isAdmin = "0";
}


if (isHyatt == null || isHyatt.length() == 0) {
    isHyatt = "0";
}


if (isWizard == null || isWizard.length() == 0) {
    isWizard = "0";
}


if (isAdmin.equals("1") && isHyatt.equals("1")) {
    isParent = "1";
}
int iCount = 0;
String sClassAppend = null;
 
%>
 
<html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="../header.html" %>
<c:set var="loc" value="en_US"/>
<c:if test="${!(empty param.locale)}">
  <c:set var="loc" value="${param.locale}"/>
</c:if>

<fmt:setLocale value="${loc}" />
<fmt:bundle basename="app">

<head>
<meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>TEMPLATE </title>
  <!-- Tell the browser to be responsive to screen width -->
  <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
 
  <link rel="stylesheet" href="../report/assets/css/bootstrap.min.css">
   <link rel="stylesheet" href="../report/assets/css/daterangepicker/daterangepicker.css">
  <link rel="stylesheet" href="../report/assets/css/font-awesome.min.css">
 
  <link rel="stylesheet" href="../report/assets/css/ionicons.min.css">
 
  <link rel="stylesheet" href="../report/assets/css/AdminLTE.css">
  <link rel="stylesheet" href="../report/assets/css/Style.css">
  <link rel="stylesheet" href="../report/assets/css/DataTable/dataTables.bootstrap.min.css">
  <link rel="stylesheet" href="../report/assets/css/skin-blue.min.css">

  <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
  <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
  <!--[if lt IE 9]>
  <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
  <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
  <![endif]-->

  <!-- Google Font -->
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700,300italic,400italic,600italic">


<style> 
td {
	font-size: 12px;
	vertical-align: middle !important;
	 
} 
th {
	font-size: 12px;
	background-color: #ecf0f5; 
	vertical-align: middle !important;
} 
.w100{
	width:100px !important;
}

.btn:hover{
-webkit-box-shadow: inset 0 0 100px rgba(0,0,0,0.2);
    box-shadow: inset 0 0 100px rgba(0,0,0,0.2);
}
</style>
</head>

<body class="hold-transition"  onLoad="innerFramOnLoad();"   >


<section class="content-header" style="margin-left:20px;margin-right:20px;padding:0px;margin-top:10px;" >
	   <div class="row">
	    	 <div class="col-md-12">
	    				<h3><fmt:message key="header_template"/></h3>
					 	<small><fmt:message key="header_template_desc"/></small><br/><br/>
	    	 </div>
			 <div class="col-md-6">
			  	<a class="btn btn-primary" href="selecttemplate.jsp">
					 <fmt:message key="buttontemplate"/>
					 <small>Templates</small> 
				</a> 
				
				<% if ("0".equals(isWizard)) { %>
				<%  if ("1".equals(isAdmin)) { %>
			 				<a class="btn btn-primary" href="/cms/ui/jsp/ctmadmin/index.jsp<%=(isParent.equals("1")?"?parent=true":"")%>">Master Template Admin</a> 
				<%   } } %>
				
			  </div>
			 <div class="col-md-6">
				 <div class="pull-right">
						  <span id="filter-list-text">Sorted By: <b id="sortedby"></b></span>
						  <button type="button" class="btn btn-default margin dropdown-toggle" data-toggle="dropdown" aria-expanded="false">Filter
							<span class="fa fa-caret-down"></span>
						  </button>
						  <ul class="dropdown-menu">
						      <li <%= ("p.name asc".equals(sOrderBy))?"class=active":"" %> ><a href="index.jsp?sort_by=p.name asc">Name</a></li>
						      <li <%= ("t.name asc".equals(sOrderBy))?"class=active":"" %> ><a href="index.jsp?sort_by=t.name asc">Template</a></li>
						      <li <%= ("status".equals(sOrderBy))?"class=active":"" %> ><a href="index.jsp?sort_by=status">Status</a></li>
						      <li <%= ("mod_date desc".equals(sOrderBy))?" class=active":"" %> ><a href="index.jsp?sort_by=mod_date desc">Modified</a></li>
						  </ul>
	  			 </div>
			 </div>
			 
			 
	    </div> 
	    <div class="row">
	    
	    	<div class="col-md-12">
	    		<table id="example1" class="table table-bordered table-striped table-hover"   >
	    		<thead>
				<tr>
					<th align="left" ><fmt:message key="tmp_column_image"/></th>
					<th align="left" ><fmt:message key="tmp_column_name"/></th>
					<th align="left" ><fmt:message key="tmp_column_template"/></th>
					<th align="left" ><fmt:message key="tmp_column_status"/></th>
					<th align="left" ><fmt:message key="tmp_column_last_modified"/></th>
					
					<th align="center"  >
						<% if ("0".equals(isWizard)) { %>
							<fmt:message key="tmp_column_action"/>
						<% } %>
					</th>
				 </tr>
				 </thead>
				  <tbody>
					<%
					try {
						connPool = ConnectionPool.getInstance();
						conn = connPool.getConnection("index.jsp");
						stmt = conn.createStatement();

						rs = stmt.executeQuery("" +
							"select distinct content_id, category, p.template_id, p.name, mod_date, t.name as template_name, " +
							"status, mod_by, creation_date, user_name, t.small_image " +
							"from ctm_pages p with(nolock), ctm_templates t with(nolock) " +
							"where p.template_id = t.template_id " +
							"and p.customer_id = " + cust.s_cust_id + " " +
							"and status <> 'deleted' " +
							"order by " + sOrderBy);
							

							while (rs.next())
							{
								contentID = rs.getInt(1);
								if (iCount % 2 != 0) {
									sClassAppend = "_Alt";
								} else {
									sClassAppend = "";
								}
								
								++iCount;
								
								templateID = rs.getInt(3);
								pageName = new String(rs.getBytes(4), "UTF-8");
								modDate = rs.getTimestamp(5);
					
								templateName = rs.getString(6);
								status = rs.getString(7);
								t_image = rs.getString(11);
								
								//Page logic
								if ((iCount <= (curPage-1)*amount) || (iCount > curPage*amount)) continue;
								%>
								<tr>
									<td class="listItem_Data<%=sClassAppend%>" align=center>
									<img width="100" height="100" border="0" src="/cctm/ui/images/templates/<%= t_image %>"> </td>
					
									<td class="listItem_Data<%=sClassAppend%>"><a href="pageedit.jsp?isEdit=true&contentID=<%= contentID %>&templateID=<%= templateID %>"><%= pageName %></td>
									<td class="listItem_Data<%=sClassAppend%>" align=left><%= templateName %></td>
									<td class="listItem_Data<%=sClassAppend%>" align=left><%= status %></td>
									<td class="listItem_Data<%=sClassAppend%>" align=left><%= DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(modDate) %></td>
									<td width="18%">
									<% if ("0".equals(isWizard)) { %>
										<table width="100%" style="border:none" border="0"> 
										<tbody>
										<tr>
											<td class="listItem_Data<%=sClassAppend%>" align=center>
											<a class="btn b_turuncu c_beyaz" href="pageedit.jsp?isEdit=false&contentID=<%= contentID %>&templateID=<%= templateID %>"><fmt:message key="tmp_column_action_btn_preview"/></a></td>
											<td class="listItem_Data<%=sClassAppend%>" align=center>
											<%=(!status.equals("locked"))?("<a class='btn btn-flat b_kirmizi c_beyaz ' href=\"\" onClick=\"if( confirm('Are you sure?') ) href='pagedelete.jsp?contentID="+contentID+"'\">Delete</a>"):("&nbsp;")%>
											</td>
											<% if ("0".equals(isHyatt)) { %>
											<td class="listItem_Data<%=sClassAppend%>" align=center>
											<%	if (!status.equals("locked")) {
												if (status.equals("draft")) { %>
												<a class="btn btn-flat btn-default" href="commit.jsp?contentID=<%= contentID %>&templateID=<%= templateID %>"><fmt:message key="tmp_column_action_btn_commit"/></a>
											<% 	} else { %>
												<a class="btn btn-flat btn-default" href="uncommit.jsp?contentID=<%= contentID %>&templateID=<%= templateID %>"><fmt:message key="tmp_column_action_btn_uncommit"/></a>
											<% 	}
												} else { %>
											&nbsp;
											<%	} %>
											</td>
											<% } %>
											<td class="listItem_Data<%=sClassAppend%>" align=center><a class="btn btn-flat b_mavi c_beyaz" href="pageedit.jsp?clone=true&contentID=<%= contentID %>&templateID=<%= templateID %>"><fmt:message key="tmp_column_action_btn_clone"/></a></td>
											</tr></tbody></table>
											<% } %>
										
									</td>
								</tr>
								<%
							}
							//Free the db connection
							rs.close();
							 
							if (iCount == 0)
							{
								%>
								<tr>
									<td class="listItem_Data" colspan="6" align="left" valign="middle">There are currently no templates.</td>
								</tr>
								<%
							}
							
								}catch(Exception ex){	ErrLog.put(this, ex, "Error in " + this.getClass().getName(), out, 1);}
								finally{
									try	{if (stmt != null) stmt.close();if (conn != null) connPool.free(conn);}
									catch (SQLException e)	{logger.error("Could not clean db statement or connection", e);	}
								}
							%>
							
					   </tbody>
					</table>
	    	
	    	
	    		 
	    		
	    	</div>
	    </div>
</section>
  
  
  <div id="filterBox" style="display:none;">
<form method="GET" name="FT" id="FT" action="index.jsp" style="display:inline;">
 
	<input type="hidden" name="curPage" value="<%= curPage %>">
	<select NAME="sort_by" SIZE="1">
			<option value="p.name asc"<%= ("p.name asc".equals(sOrderBy))?" selected":"" %>>Name</option>
			<option value="t.name asc"<%= ("t.name asc".equals(sOrderBy))?" selected":"" %>>Template</option>
			<option value="status"<%= ("status".equals(sOrderBy))?" selected":"" %>>Status</option>
			<option value="mod_date desc"<%= ("mod_date desc".equals(sOrderBy))?" selected":"" %>>Modified</option>
		</select>
</form>
</div>
 
<br><br>

<script src="../report/assets/js/jquery.min.js"></script>
<script src="../report/assets/js/bootstrap.min.js"></script>
<script src="../report/assets/js/adminlte.min.js"></script>
 <!-- FastClick -->
<script src="../report/assets/js/fastclick.js"></script>
<!-- AdminLTE for demo purposes -->
<script src="../report/assets/js/demo.js"></script>

<script src="../report/assets/js/daterangepicker/moment.min.js"></script>
<script src="../report/assets/js/daterangepicker/daterangepicker.js"></script>

<script type="text/javascript" src="../report/assets/js/FushionCharts/fusioncharts.js"></script>
<script type="text/javascript" src="../report/assets/js/FushionCharts/fusioncharts.theme.fint.js"></script>

<!-- DataTables -->
<script src="../report/assets/js/DataTable/jquery.dataTables.min.js"></script>
<script src="../report/assets/js/DataTable/dataTables.bootstrap.min.js"></script>
<script>
    $(function () { 
	    $('#example1').DataTable({
	      'paging'      : true,
	      'lengthChange': true,
	      'searching'   : true,
	      'ordering'    : true,
	      'info'        : true,
	      'autoWidth'   : false,
	      "lengthMenu": [[10, 25, 50, 100,-1], [10, 25, 50, 100, "All"]]
		   
	    })
	    
	    
  })

</script>
<SCRIPT>
 
function innerFramOnLoad()
{
	var sBy = FT.sort_by[FT.sort_by.selectedIndex].text; 
	sortedby.innerHTML = sBy;
}
 

</SCRIPT>
</body>
</fmt:bundle>
</html>


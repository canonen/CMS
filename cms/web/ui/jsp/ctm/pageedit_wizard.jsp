<%@ page
    language="java"
	import="org.apache.log4j.*"
    import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.ctm.*"
	import="java.util.*"
	import="java.sql.*"
    errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<jsp:useBean id="tbeans" class="java.util.Hashtable" scope="application" />
<%-- Page requires a templateID parameter, contentID parameter is optional --%>
<%

int custID = Integer.parseInt(cust.s_cust_id);

String isHyatt = (String)session.getAttribute("isHyatt");
if (isHyatt == null || isHyatt.length() == 0) {
    isHyatt = "0";
}

//Grab pbean and tbean from either the session or create a new one
PageBean pbean = (PageBean)session.getAttribute("pbean");
TemplateBean tbean = null;

String sTemplateID = request.getParameter("templateID");
String contentID = request.getParameter("contentID");
contentID = ( (contentID != null) && (contentID.length() > 0) )?contentID:null;

//Grab this customer's pages from the db
ConnectionPool connPool = null;
Connection conn         = null;
Statement stmt          = null;
ResultSet rs            = null;

String status = null;
try {
	connPool = ConnectionPool.getInstance();
	conn = connPool.getConnection("index.jsp");
	stmt = conn.createStatement();

	if (contentID != null && !contentID.equals("null")) {
		rs = stmt.executeQuery("select template_id " +
					   "  from ctm_pages " +
					   " where content_id = '"+ contentID +"' " +
					   "   and status <> 'deleted'");

		while (rs.next()) {
			sTemplateID = rs.getString(1);
		}
	}

	rs = stmt.executeQuery(
		"SELECT status" +
		" FROM ctm_pages p" +
		" WHERE p.template_id = " + sTemplateID +
		" AND p.content_id = " + contentID +
		" AND p.customer_id = " + custID);
	
	if (rs.next()) status = rs.getString(1);
	rs.close();

} 
catch (SQLException e) 
{
	throw e;
} finally {
	stmt.close();
	if (conn != null) connPool.free(conn);
}

if (sTemplateID == null || !tbeans.containsKey(new Integer(sTemplateID))) {
	//templateID is null
	%> templateID is null <%
	return;
}

int templateID = Integer.parseInt(sTemplateID);

//if pbean doesn't exist or it is a different template (different templateID)
//or contentID is different
boolean refreshed = false;
if (pbean == null || (pbean.getTemplateBean()).getTemplateID() != templateID ||
   (contentID != null && !contentID.equals(String.valueOf(pbean.getContentID())))) {

	//Grab a tbean from the Hashtable using the templateID key
	tbean = (TemplateBean)tbeans.get(new Integer(templateID));
	boolean ok = false;
	if (isHyatt.equals("1")) {
		ok = tbean.isGlobal(); // this is fine because hyatt is in its own CPS otherwise make sure cust's parent cust id = template's cust id
	}	
	else {
		ok = (tbean.getCustID() == 0);
	}	
	if (!ok && tbean.getCustID() != custID && !tbean.inChildCustList(custID+"")) {
		//Do not let him use other customer's private Templates
		//response.sendRedirect("login.jsp");
		%> Bad CustID For TemplateID: <%= sTemplateID %> <%
		return;
	}
	pbean = new PageBean(custID, tbean);

	//See if there is a contentID in the request
	if (contentID != null) {
		//load it from the db
		try {
			pbean.load(Integer.parseInt(contentID));
			if (pbean.getCustID() != custID) {
				//User is not allowed to see this page
				//response.sendRedirect("login.jsp");
				%> Really Bad ClientID For TemplateID: <%= sTemplateID %> <%
				return;
			}
		} catch (SQLException e) {
			throw e;
		}
	} else {
		//set the hidden values to the default values
		pbean.setHiddenValues();
	}
	session.setAttribute("pbean", pbean);
	session.setAttribute("tbean", tbean);

	refreshed = true;
} else {
	tbean = (TemplateBean)session.getAttribute("tbean");
}
if (request.getParameter("clone") != null) {
	//set pageName to "" and contentID to 0 and redirect to savepage.jsp
	pbean.setPageName("");
	int oldContentID = pbean.getContentID();
	pbean.setContentID(0);
	response.sendRedirect("pagesave.jsp?oldContentID="+oldContentID);
	return;
}

if (pbean.getPageName().length() == 0) {
	//redirect to the save page
	response.sendRedirect("pagesave.jsp");
	return;
}

if (contentID == null)
{
	try
	{
		contentID = String.valueOf(pbean.getContentID());
		contentID = "&contentID="+contentID;
	}
	catch (Exception ex)
	{
		contentID = "";
	}
	
	if (contentID == null)
	{
		contentID = "";
	}
}
else
{
	contentID = "&contentID="+contentID;
}

boolean isEdit;
String sIsEdit = request.getParameter("isEdit");
if ((sIsEdit != null && sIsEdit.equals("false")) || "locked".equals(status)) {
	isEdit = false;
} else {
	isEdit = true;
}
String previewType = request.getParameter("previewType");
if (previewType == null) previewType = "html";

%>


<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>Edit <%= pbean.getPageName() %></title>
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
  
<script language="javascript" >
	
	function moveSteps(stepNum)
	{
		var frm = parent.top.document.FT.step.value = stepNum;
	}
	
</script>

<style> 
 td {
	font-size: 12px;
	vertical-align: middle !important;
	 border-top:none !important;
	 vertical-align: top !important;
} 
th {
	font-size: 12px;
	background-color: #ecf0f5; 
	vertical-align: middle !important;
	border:none !important;
	 vertical-align: top !important;
} 
.w100{
	width:100px !important;
}
.temp_title{
color:#000;  
}

.temp_title:hover{
color:#000;

}
.btn:hover{
-webkit-box-shadow: inset 0 0 100px rgba(0,0,0,0.2);
    box-shadow: inset 0 0 100px rgba(0,0,0,0.2);
}
</style>
</head>

<body class="hold-transition"  >


<section class="content-header" style="margin-left:20px;margin-right:20px;padding:0px;margin-top:10px; height:100%;" >

  			<div class="row">
  			
	  		 <%	if (!"locked".equals(status)) { %>
					<div class="col-md-12">
						 <a class="btn btn-primary" href="commit.jsp?templateID=<%= templateID %><%= contentID %>"> Save And Continue >> </a> 
					</div><br/><br/>
			<% } %>
  		 	      <div class="col-md-12">
	  		 <%
				if (isEdit)
				{
					%>
						 <a class="btn btn-warning" href="pageedit.jsp?isEdit=false&templateID=<%= templateID %><%= contentID %>">Preview</a> 
					   
				<%	if (!"locked".equals(status)) { %>
						<a class="btn btn-info" href="pagesave.jsp?rename=true"><%=(isHyatt.equals("1")?"Rename":"Rename/Change Send Type")%></a>
				<%	} %>
					 
				<%
				}
			else
			{
				//Can be html or txt
				if (previewType.equals("html"))
				{
					%>
				 		<a class="btn btn-warning" href="#">HTML</a>&nbsp;</td>
					    <a class="btn btn-default" href="pageedit.jsp?previewType=txt&isEdit=false&templateID=<%= templateID %><%= contentID %>">Text</a>
					<%
				}
				else
				{
					%>
					 <a class="btn btn-warning" href="pageedit.jsp?previewType=html&isEdit=false&templateID=<%= templateID %><%= contentID %>">HTML</a> 
					 <a class="btn btn-default" href="#">Text</a> 
					<%	
				}
				%>
					<td nowrap align="left" valign="middle">
			<%	if (!"locked".equals(status)) { %>
					<a class="subactionbutton" href="pageedit.jsp?isEdit=true&templateID=<%= templateID %><%= contentID %>">Edit Template</a>
			<%	} %>
					&nbsp;&nbsp;&nbsp;
					</td>
				<%
			}
			%>
			
					<div class="pull-right">
					 
				<%	if (!"locked".equals(status)) { %> 
							 <a class="btn btn-primary" href="index.jsp"><< Return to Templates</a> 
				<%	} %>
		  		 				
					</div>
			
			 </div>
			
	  	</div>
	  	
	 
			
		   
	   
</section>
  	<iframe style="width:100%; height:100%;position:absolute;" height="100%" frameborder="0" border="0" scrolling="auto" name="template" src="pageedit2.jsp?previewType=<%= previewType %>&isEdit=<%= isEdit %>&templateID=<%= templateID %><%= contentID %>"></iframe>
 
	
 
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
 
 
</body> 
</html>		
 


<%@ page 
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.ctm.*"
	import="org.apache.log4j.*"
	import="java.sql.*"
	import="java.util.*" 
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<%  if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%
PageBean pbean = (PageBean)session.getAttribute("pbean");
/*
String isWizard = (String)session.getAttribute("isWizard");
if ("1".equals(isWizard)) {
	response.sendRedirect("pagesave_wizard.jsp?" + request.getQueryString());
	return;
}
*/
int custID = Integer.parseInt(cust.s_cust_id);
int userID = Integer.parseInt(user.s_user_id);

String returnURL = request.getParameter("returnURL");
if (returnURL == null) returnURL = "pageedit.jsp?templateID="+pbean.getTemplateBean().getTemplateID();

String pageName = request.getParameter("pageName");
String sendType = request.getParameter("sendType");

String rename = request.getParameter("rename");

if ((pbean.getPageName().length() != 0 || (pageName != null && pageName.length() != 0)) && rename == null) {
	if (pageName != null && pageName.length() != 0) {
		pbean.setPageNameAndType(pageName, Integer.parseInt(sendType));
	}

	pbean.save(userID, (String)session.getAttribute("userName"), -1);
	
	String oldContentID = request.getParameter("oldContentID");
	if (oldContentID != null) {
		WebUtils.copyImages(application.getInitParameter("ImagePath")+pbean.getCustID()+"\\", Integer.parseInt(oldContentID), pbean.getContentID());
	}

	response.sendRedirect(returnURL);
	return;
}

String nameValue = "";
if (rename != null) {
	nameValue = WebUtils.htmlEncode(pbean.getPageName());
}

String oldContentID = request.getParameter("oldContentID");

//Grab this customer's pages from the db
ConnectionPool connPool = null;
Connection conn         = null;
Statement stmt          = null;
ResultSet rs            = null;

connPool = ConnectionPool.getInstance();
conn = connPool.getConnection("pagesave.jsp");
stmt = conn.createStatement();


rs = stmt.executeQuery("SELECT send_type_id, send_type_name FROM ctm_send_type");

String sendTypeSelectBox = "";
String isSelected = "";
int curID;
while (rs.next()) {
	curID = rs.getInt(1);
	if (curID == pbean.getSendType()) isSelected = " selected";
	else isSelected = "";

	sendTypeSelectBox += "<option value=\""+curID+"\""+isSelected+">"+rs.getString(2)+"</option>\n";
}

//Free the db connection
rs.close();
stmt.close();
if (conn != null) connPool.free(conn);

String sContentParm = "";
if (pbean.getContentID() != 0) {
          sContentParm = "&contentID=" + pbean.getContentID(); 
} 
//If no name in pbean and no name supplied by user, ask for a name

String isHyatt = (String)session.getAttribute("isHyatt");
if (isHyatt == null || isHyatt.length() == 0) {
    isHyatt = "0";
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>Page Name</title>
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


<section class="content-header" style="margin-left:20px;margin-right:20px;padding:0px;margin-top:10px;" >
	   <div class="row">
	    	 <div class="col-md-12">
	    	 	<%
				if (rename != null)
				{
					// only display the following if this is a rename, DON'T display if this is a new Template
					%>
				 		<a class="btn btn-info" href="<%=returnURL%><%=sContentParm%>">< Return to Edit Template</a> 
					<%
				}
				%>
	    	   			<a class="btn btn-primary" href="index.jsp"><< Return to Templates</a><br/><br/>
	    	 </div>
			 
	    </div> 
	    <div class="row">
	    	
	    	<div class="col-md-12">
	    	   
	    	 			<div class=""> 
						  	 <a class="btn btn-sm btn-warning" href="javascript:FT.submit();">Save</a>
					  </div>
				  
	    	 	<br/><br/>
	   		</div>
	    	<div class="col-md-12">
	    		  <div class="box box-primary">
			            <div class="box-header">
			              <h3 class="box-title">Step 1: Template Information</h3>
			            </div>
			            <!-- /.box-header -->
			            <div class="box-body no-padding">
			            
			            <form name="FT" method="POST" action="pagesave.jsp">
						<input type="hidden" name="returnURL" value="<%= returnURL %>">
						<% if (oldContentID != null) { %>
						     <input type="hidden" name="oldContentID" value="<%= oldContentID %>">
						<% } %>
						
						  <div class="row">
						  	<div class="col-md-6">
						  		 <table class="table table-condensed">
					                <tbody>
					                <tr>
										  <td class="">
												<% if (pageName != null && pageName.length() == 0) { %>
												     <h3>Please enter a name for the content.</h3>
										<% } %>
													<table class="" cellspacing="1" cellpadding="2" width="100%">
														<tr>
															<td width="150">Name: </td>
															<td> 
																<div class="form-group">
												                   <input type="text" class="form-control"  name="pageName"  value="<%= nameValue %>" >
												                </div>
															
																
															</td>
														</tr>
														<tr<%= ("1".equals(isHyatt))?" style=\"display:none;\"":"" %>>
															<td width="150">Send Type: </td>
															<td>
																<div class="form-group">
												                 
												                   <select class="form-control"  name="sendType">
																		<%= sendTypeSelectBox %>
																		</select>
												                </div>
																
															</td>
														</tr>
													</table>
												</td>
					                 </tr>
					             	 </tbody>
			             		 </table>
						  	</div>
						  </div>
						</form>
			             
			            </div>
			            <!-- /.box-body -->
         	 </div>
	    		
	    	</div>
	    </div>
</section>
  
 
 
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
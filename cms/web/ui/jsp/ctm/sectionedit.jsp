<%@ page 
	language="java"
	import="org.apache.log4j.*"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.ctm.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<%  if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<jsp:useBean id="tbean" class="com.britemoon.cps.ctm.TemplateBean" scope="session" />
<% 
PageBean pbean = (PageBean)session.getAttribute("pbean");

int section = (new Integer(request.getParameter("section"))).intValue();


String sContentParm = "";
String sTemplateParm = "";
if (pbean.getContentID() != 0) {
     sContentParm = "&contentID=" + pbean.getContentID();
}
if (tbean.getTemplateID() != 0) {
     sTemplateParm = "&templateID=" + tbean.getTemplateID();
}

%>

<%-- Create the form --%>
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
  
 .btn1 {
    display: inline-block;
    padding: 6px 12px;
    margin-bottom: 0;
    font-size: 14px;
    font-weight: 400;
    line-height: 1.42857143;
    text-align: center;
    white-space: nowrap;
    vertical-align: middle;
    -ms-touch-action: manipulation;
    touch-action: manipulation;
    cursor: pointer;
    -webkit-user-select: none;
    -moz-user-select: none;
    -ms-user-select: none;
    user-select: none;
    background-image: none;
    border: 1px solid transparent;
    border-radius: 4px;
    color:#fff;
}
.btn1:hover{ color:#fff;}
.btn1 {
  border-radius: 3px;
  -webkit-box-shadow: none;
  box-shadow: none;
  border: 1px solid transparent;
  color:#fff;
} 
.btn1:active {
  color:#fff;
  -webkit-box-shadow: inset 0 3px 5px rgba(0, 0, 0, 0.125);
  -moz-box-shadow: inset 0 3px 5px rgba(0, 0, 0, 0.125);
  box-shadow: inset 0 3px 5px rgba(0, 0, 0, 0.125);
}
.btn1:focus {
  outline: none;
}
  
.btn1-default {
  background-color: #f4f4f4;
  color: #444;
  border-color: #ddd;
}
.btn1-default:hover,
.btn1-default:active,
.btn1-default.hover {
  background-color: #e7e7e7;
   
}
.btn1-primary {
  background-color: #3c8dbc;
  border-color: #367fa9;
}
.btn1-primary:hover,
.btn1-primary:active,
.btn1-primary.hover {
  background-color: #367fa9;
}
 
.btn1-info {
  background-color: #00c0ef;
  border-color: #00acd6;
}
.btn1-info:hover,
.btn1-info:active,
.btn1-info.hover {
  background-color: #00acd6;
}
.btn1-danger {
  background-color: #dd4b39;
  border-color: #d73925;
}
.btn1-danger:hover,
.btn1-danger:active,
.btn1-danger.hover {
  background-color: #d73925;
}
.btn1-warning {
  background-color: #f39c12;
  border-color: #e08e0b;
}
.btn1-warning:hover,
.btn1-warning:active,
.btn1-warning.hover {
  background-color: #e08e0b;
}
 
 
.btn1[class*='bg-']:hover {
  -webkit-box-shadow: inset 0 0 100px rgba(0, 0, 0, 0.2);
  box-shadow: inset 0 0 100px rgba(0, 0, 0, 0.2);
}

input[type=text],textarea {
 
    display: block;
    width: 100%;
    height: 34px;
    padding: 6px 12px;
    font-size: 14px;
    line-height: 1.42857143;
    color: #555;
    background-color: #fff;
    background-image: none;
    border: 1px solid #ccc;
    border-radius: 4px;
    -webkit-box-shadow: inset 0 1px 1px rgba(0,0,0,.075);
    box-shadow: inset 0 1px 1px rgba(0,0,0,.075);
    -webkit-transition: border-color ease-in-out .15s,-webkit-box-shadow ease-in-out .15s;
    -o-transition: border-color ease-in-out .15s,box-shadow ease-in-out .15s;
    transition: border-color ease-in-out .15s,box-shadow ease-in-out .15s;
  
}
input[type=text]:focus {
  border-color: #3c8dbc;
  box-shadow: none;
}
input[type=text]::-moz-placeholder,
input[type=text]:-ms-input-placeholder,
input[type=text]::-webkit-input-placeholder {
  color: #bbb;
  opacity: 1;
}
input[type=text]:not(select) {
  -webkit-appearance: none;
  -moz-appearance: none;
  appearance: none;
}
textarea{
height: auto !important;
}
</style>



<SCRIPT LANGUAGE="Javascript" SRC="../../js/AnchorPosition.js"></SCRIPT>
	<SCRIPT LANGUAGE="Javascript" SRC="../../js/PopupWindow.js"></SCRIPT>
	<SCRIPT LANGUAGE="Javascript" SRC="../../js/ColorPicker.js"></SCRIPT>

	<SCRIPT LANGUAGE="JavaScript">
	// Runs when a color is clicked
	function pickColor(color) 
    {
		field.value = color;
	}

	var field;
	</SCRIPT>
    <script>_editor_url = "../../js/editor/"; </script>
    <script language="Javascript1.2" SRC="../../js/editor/editor_ctm.js"></script>
	<script language="Javascript1.2">
        window.onload=function()
       {
           initEditorInputHooks();
           Array.from(document.querySelector("form[name=FT]").querySelectorAll('button')).forEach(function(e) {
	   	e.addEventListener('click',function(event) {
	   		event.preventDefault();
	   	});
	});
       }
       function initEditorInputHooks() 
       {
               <%= pbean.createSectionFormHtmlEditorHooks(section) %>
       }
       
    </script>
    
</head>

<body class="hold-transition"  >


<section class="content-header" style="margin-left:20px;margin-right:20px;padding:0px;margin-top:10px; height:100%;" >

  			<div class="row">
	  		  		<div class="col-md-12">
						<a class="btn1 btn1-warning" href="javascript:FT.submit();">Save</a>
						<a class="btn1 btn1-info" href="pageedit.jsp?isEdit=true<%=sContentParm%><%=sTemplateParm%>">< Return to Edit Template</a>
				  
						<div class="pull-right">
							 <a class="btn1 btn1-primary" href="index.jsp"><< Return to Templates</a>  
						</div>
					</div> 
					
				 
		 	</div>
		 	<div class="row">
		 		<div class="col-md-8">
		 				<form method="POST" name="FT" action="sectionedit2.jsp" enctype="multipart/form-data">
						<input type="hidden" name="section" value="<%= section %>">
					  <br/>
						 <table class="table"  >
							 <tr>
								<td><span class="page-header"><%= tbean.getSectionLabel(section) %></span>&nbsp;</td>
							</tr>
							<%= pbean.createSectionForm(section, application.getInitParameter("ImageURL")) %>
						</table>
						</form>
		 				
		 		</div>
		 		
		 	</div>
	  	
	 
	   
</section>
  	
 
<br><br>
 
</body> 
</html>			
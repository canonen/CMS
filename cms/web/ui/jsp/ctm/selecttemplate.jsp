<%@ page 
          language="java"
          import="org.apache.log4j.*"
          import="com.britemoon.cps.*"
          import="com.britemoon.cps.ctm.*"
          import="java.util.*" 
          errorPage="../error_page.jsp"
          contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<jsp:useBean id="tbeans" class="java.util.Hashtable" scope="application" />
<%
//Make sure these are gone
session.removeAttribute("pbean");
session.removeAttribute("tbean");
StringBuilder TABLE_TR = new StringBuilder();

String isHyatt = (String)session.getAttribute("isHyatt");
if (isHyatt == null || isHyatt.length() == 0) isHyatt = "0";

int numPerPage = 6;
String sNumPerPage = application.getInitParameter("NumTemplatesPerPage");
if (sNumPerPage != null) numPerPage = Integer.parseInt(sNumPerPage);

String isWizard = (String)session.getAttribute("isWizard");
if ("1".equals(isWizard)) {
    numPerPage = 100;
}

String sCurPage = request.getParameter("page");
int curPage, nextPage, prevPage;
if (sCurPage == null)
{
	curPage = 1;
	nextPage = 2;
	prevPage = 0;
}
else
{
	curPage = Integer.parseInt(sCurPage);
	nextPage = curPage + 1;
	prevPage = curPage - 1;
}

int custID = Integer.parseInt(cust.s_cust_id);

TemplateBean tbean;

//No next page if there aren't any more to show
int actualNumTemplates = 0;
for(Enumeration tb = tbeans.elements(); tb.hasMoreElements();)
{
	tbean = (TemplateBean)tb.nextElement();
	if (!tbean.isActive()) continue;
	boolean ok = false;
	if (isHyatt.equals("1"))
	{
		// this is fine because hyatt is in its own CPS otherwise make sure cust's parent cust id = template's cust id	
		ok = (tbean.isGlobal() && (tbean.getCustID() != 0));
	}	
	else
	{
		ok = (tbean.getCustID() == 0);
	}	
	if (ok || tbean.getCustID() == custID || tbean.inChildCustList(custID+"")) ++actualNumTemplates;
}

if (curPage*numPerPage >= actualNumTemplates) nextPage = 0;
 
Vector vKeys = new Vector();
Enumeration keys = tbeans.keys();

while (keys.hasMoreElements()) vKeys.add(keys.nextElement());

Collections.sort(vKeys);
Iterator sortedKeys = vKeys.iterator();

int rowCount = 0, count = 0;
boolean hasOneRow = false;

int iCount = 0;
String sClassAppend = "_Alt";

// skip the ones displayed in previous pages
int numToSkip = curPage*numPerPage-numPerPage;
while (numToSkip > 0)
{
	if (!sortedKeys.hasNext()) break;
	Integer key = (Integer) sortedKeys.next();
	tbean = (TemplateBean)tbeans.get(key);

	if (!tbean.isActive()) continue;
	boolean ok = false;
	if (isHyatt.equals("1"))
	{
		ok = (tbean.isGlobal() && (tbean.getCustID() != 0)); // this is fine because hyatt is in its own CPS otherwise make sure cust's parent cust id = template's cust id
	}	
	else
	{
		ok = (tbean.getCustID() == 0);
	}	
	
	if ( tbean.isActive() && (ok || tbean.getCustID() == custID || tbean.inChildCustList(custID+"")) )
	{
		numToSkip--;
	}
}

// display the next page
while (sortedKeys.hasNext() && count < numPerPage)
{
	Integer key = (Integer) sortedKeys.next();
	tbean = (TemplateBean)tbeans.get(key);
	boolean ok = false;
	if (isHyatt.equals("1"))
	{
		ok = (tbean.isGlobal() && (tbean.getCustID() != 0)); // this is fine because hyatt is in its own CPS otherwise make sure cust's parent cust id = template's cust id
	}	
	else
	{
		ok = (tbean.getCustID() == 0);
	}	
	if ( tbean.isActive() && (ok || tbean.getCustID() == custID || tbean.inChildCustList(custID+"")) )
	{
		hasOneRow = true;
		++rowCount;
		++count;
		if (rowCount == 4)
		{
			rowCount = 1;
			TABLE_TR.append("</tr><tr>");
			 
			if (iCount % 2 != 0) sClassAppend = "_Alt";
			else sClassAppend = "";
			
			++iCount;
		}
		
		
				TABLE_TR.append("<td width='33%' valign='top' align='center'>");
				
				TABLE_TR.append("<table class='table text-center'> ");
				
				TABLE_TR.append("<tr>");
				TABLE_TR.append("<td valign='top'>");
					TABLE_TR.append("<a href='pageedit.jsp?templateID="+ tbean.getTemplateID()+"'>");
						TABLE_TR.append("<h4 class='temp_title'  href='pageedit.jsp?templateID="+ tbean.getTemplateID()+"'>");
						TABLE_TR.append( tbean.getTemplateName());
						TABLE_TR.append("</h4> ");
					TABLE_TR.append("</a> ");
					
				TABLE_TR.append("</td>");
		    TABLE_TR.append("</tr> ");
		    
				TABLE_TR.append("<tr>");
					TABLE_TR.append("<td valign='top' height='200' >");
						TABLE_TR.append("<a href='pageedit.jsp?templateID="+ tbean.getTemplateID()+"'>");
						TABLE_TR.append("<img height='190' border='0' src='/cctm/ui/images/templates/"+ tbean.getImageURL(0)+"'>");
						TABLE_TR.append("</a> ");
					TABLE_TR.append("</td>");
				TABLE_TR.append("</tr> ");
				
				
			    TABLE_TR.append("<tr>");
					 	TABLE_TR.append("<td valign='top'>");
						TABLE_TR.append("<a class='btn btn-warning' target='_blank' href='/cctm/ui/images/templates/"+tbean.getImageURL(1)+"'>Preview</a>");
						TABLE_TR.append("</td>");
				TABLE_TR.append("</tr> ");
				TABLE_TR.append("</table> ");
				
				TABLE_TR.append("</td>");
		 
	}
}

for (int x=rowCount+1;x<4;++x){
	TABLE_TR.append("<td width='33%'></td>");
	 
}

if (!hasOneRow){
	TABLE_TR.append("<td colspan='3' >There are currently no templates to choose from.</td>");
	 
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>Select a Template </title>
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
	    				<a class="btn btn-primary" href="index.jsp"><< Return to Templates</a><br/><br/>
	    	 </div>
			 
	    </div> 
	    <div class="row">
	    	
	    	<div class="col-md-12">
	    	 	<% if ((prevPage != 0) || (nextPage != 0)) {
	    	 		
	    	 		if (prevPage != 0) { %>
	    	 			<div class="pull-left"> 
						  <a class="btn btn-sm btn-info" href="selecttemplate.jsp?page=<%= prevPage %>">< Previous</a> 
						 </div>
					 <% }  
	    	 		if (nextPage != 0) { %>
	    	 			<div class="pull-right"> 
						 <a  class="btn btn-sm btn-info" href="selecttemplate.jsp?page=<%= nextPage %>">Next ></a> 
						  </div>
					 <% }  
	    	 	} %>
	    	 	<br/><br/>
	   		</div>
	    	<div class="col-md-12">
	    		  <div class="box box-primary">
			            <div class="box-header">
			              <h3 class="box-title">Select a Template</h3>
			            </div>
			            <!-- /.box-header -->
			            <div class="box-body no-padding">
			              <table class="table table-condensed">
			                <tbody>
			                <tr>
			               		 <%=TABLE_TR %> 
			                 </tr>
			             	 </tbody>
			              </table>
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
 
</body> 
</html>				
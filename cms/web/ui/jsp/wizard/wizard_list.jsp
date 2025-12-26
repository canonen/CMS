<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.ctl.*,
			java.util.*,java.sql.*,
			java.net.*,java.text.DateFormat,
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

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bRead) {
	response.sendRedirect("../access_denied.jsp");
	return;
}

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

ConnectionPool	cp			= null;
Connection		conn		= null;
Statement		stmt		= null;
ResultSet		rs			= null; 

StringBuilder TABLE_TR = new StringBuilder();
String sSelectedCategoryId = request.getParameter("category_id");
boolean isDisable = false;

try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("wizard/wizard_list.jsp 1");
	stmt = conn.createStatement();
	

	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id))) {
		sSelectedCategoryId = ui.s_category_id;
	}
	if (sSelectedCategoryId == null) sSelectedCategoryId = "0";

	String		scurPage	= request.getParameter("curPage");
	String		samount		= request.getParameter("amount");

	int		curPage		= 1;
	int		amount		= 0;

	curPage		= (scurPage	== null) ? 1 : Integer.parseInt(scurPage);
	
	// ********** KU
	
	if (samount == null) samount = ui.getSessionProperty("wizard_list_page_size");
	if ((samount == null)||("".equals(samount))) samount = "25";
	try { amount = Integer.parseInt(samount); }
	catch (Exception ex) { samount = "25"; amount = 25; }
	ui.setSessionProperty("wizard_list_page_size", samount);
		
	// ********** KU

			String sSql = "usp_cque_wizard_camp_list_get " + cust.s_cust_id + "," + sSelectedCategoryId;
			rs = stmt.executeQuery(sSql);

			String sCampId = null;
			String sCampName = null;
			String sDisplayName = null;
			String sModifyDate = null;
			int campCount = 0;
			String s_status_id;

			String sClassAppend = "";
			
			while( rs.next() )
			{
				 
				sCampId = rs.getString(1);
				sCampName = new String(rs.getBytes(2), "ISO-8859-1");
				sDisplayName = rs.getString(3);
				sModifyDate = rs.getString(4);
				s_status_id = rs.getString(5);
				
				 TABLE_TR.append("<tr>");
				 TABLE_TR.append("<td>"+sDisplayName+"</td>"); 
				 
				if (sSelectedCategoryId!=null) {
					 TABLE_TR.append("<td><a href='wizard.jsp?camp_id="+sCampId+"&category_id="+sSelectedCategoryId+"'>"+sCampName+"</a></td>");
					
				}else{
					 TABLE_TR.append("<td><a href='wizard.jsp?camp_id="+sCampId+"'>"+sCampName+"</a></td>");
					
				} 
				
				 
				 TABLE_TR.append("<td>"+sModifyDate+"</td>");
				 
				  if ((Integer.parseInt(s_status_id) == 60)) {  
						TABLE_TR.append("<td><a href='../report/report_object.jsp?act=VIEW&id="+ sCampId+"'>view report</a></td>");
				  } else {   
					 	TABLE_TR.append("<td>Not sent yet</td>");
				  }   
				 
				  
				 TABLE_TR.append("</tr>");
			 	
				 
					 
				  
					 
				 
 	 
			}
			rs.close();
			 
	 
if (stmt != null) stmt.close();
}
catch(Exception ex)
{ 
	ErrLog.put(this,ex,"wizard_list.jsp",out,1);	
}
finally
{
	if (conn != null) cp.free(conn);
}
%>


<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>Quick Campaigns </title>
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
	border: 1px solid #f2f2f2 !important;
}
 

th {
	font-size: 12px;
	background-color: #ecf0f5;
	border: 1px solid #f2f2f2 !important;
	vertical-align: middle !important;
}

.w100{
	width:100px !important;
}

</style>
</head>



<body class="hold-transition">

<div id="filter-name" style="display:none">
	<%= CategortiesControl.toHtml(cust.s_cust_id, canCat.bExecute, sSelectedCategoryId, "") %>
</div>


<section class="content-header" style="margin-left:20px;margin-right:20px;" >
 	  
</section>

<section class="content-header" style="margin-left:20px;margin-right:20px;padding:0px;margin-top:10px;" >
	   <div class="row">
			 <div class="col-md-6">
			 <%
				if (can.bWrite)
				{
					%>
					 
					 <a class="btn btn-sm margin btn-primary" href="wizard.jsp?<%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>">
							<i class="fa  fa-plus" style="padding-right:5px;"></i>  New Wizard
					 </a>
							<small> Quick Campaigns </small>   
					
					
					<%
				}
				%>
			 
			 
			 	

				  
			 </div>
			 <div class="col-md-6">
				 <div class="pull-right">
						 <%  if(canCat.bRead) { %>
						  <span id="filter-list-text">Category : All </span>
						  <button type="button" class="btn btn-default margin dropdown-toggle" data-toggle="dropdown" aria-expanded="false">Filter
							<span class="fa fa-caret-down"></span>
						  </button>
							
						  <ul id="filter-list" class="dropdown-menu"> </ul>
						 
						  
						 <% } %>
	  			 </div>
			 </div>
	    </div> 
</section>
	
	
 <section class="content" style="margin-left:5px;margin-right:5px;">
    <div class="row">
        <div class="col-xs-12">
           
          <div class="box box-primary">
         
            <!-- /.box-header -->
            <div class="box-body">
              <table id="example1" class="table table-bordered table-striped ">
                <thead>
					<tr>
					  <th class="w100">Status</th>
					  <th>Campaign</th>
					  <th>Modify Date</th>
					  <th>Reporting</th> 
					</tr>
                </thead>
                <tbody>
					<%= TABLE_TR %>
                </tbody>
               
              </table>
            </div>
            <!-- /.box-body -->
          </div>
          <!-- /.box -->
        </div>
        <!-- /.col -->
      </div>
  </section>

<script src="../report/assets/js/jquery.min.js"></script>
<script src="../report/assets/js/bootstrap.min.js"></script>
<script src="../report/assets/js/adminlte.min.js"></script>
 <!-- FastClick -->
<script src="../report/assets/js/fastclick.js"></script>
<!-- AdminLTE for demo purposes -->
<script src="../report/assets/js/demo.js"></script>

<script src="../report/assets/js/daterangepicker/moment.min.js"></script>
<script src="../report/assets/js/daterangepicker/daterangepicker.js"></script>
 

<!-- DataTables -->
<script src="../report/assets/js/DataTable/jquery.dataTables.min.js"></script>
<script src="../report/assets/js/DataTable/dataTables.bootstrap.min.js"></script>
<script>
 
  $(function () {
    
    $('#example1').DataTable({
		"lengthMenu": [[10, 25, 50, 100,-1], [10, 25, 50, 100, "All"]]

	});
	
	
	var catID=<%=sSelectedCategoryId%>;
	var select =$('#filter-name').find('select option');
	var select_list="";
	select.each(function(){
		
		var val=$(this).val();
		var text=$(this).text();
	    select_list+="<li><a href='wizard_list.jsp?category_id="+val+"'>"+text+" </a></li>";
		if(catID==val){ 
			 $('#filter-list-text').html("Category  : "+text);
		}
		 
		 
		  		  
	});
	$('#filter-list').append(select_list);
	
  })
 </script>
 
</body>
</html>

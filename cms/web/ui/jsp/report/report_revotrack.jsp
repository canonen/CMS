<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*, 
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
	
	AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

	if(!can.bRead)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}

	AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD); 
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
	
	if (samount == null) samount = ui.getSessionProperty("rept_list_page_size");
	if ((samount == null)||("".equals(samount))) samount = "2000";
	try { amount = Integer.parseInt(samount); }
	catch (Exception ex) { samount = "25"; amount = 25; }
	ui.setSessionProperty("rept_list_page_size", samount);

	// ********** KU
	
  	String strStatusId = null;
	String htmlFirstBox = "";
	String htmlContentRow = "";
	String htmlContentChild = "";
	String htmlContent = "";
	String htmlContentDT = "";

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
		conn = cp.getConnection("report_revotrack.jsp");
		stmt = conn.createStatement();
		 
		 

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
				
		 
			String  Name=null;
			String  Start_Date=null;
			
			String  Sent =null;
			String  Reaching=null;			
			String  Bbacks=null;
			
			String  Dist_Reads=null;
			String  Distinct_Read_PRC=null;
			
			String  Distinct_Clicks=null;
			String  Distinct_Clicks_PRC=null;
			
			String  Purchasers=null;
			String  Purchases=null;
			String  Yuzde=null;
			String  Total=null;
			String  Camp_id=null;


		    String  Type_id=null;
			String  Media_id=null;
			String  Queue_daily_flag=null;

			 
			
				
		// ============
				
 		 
		String sSql =
			" Exec dbo.zcs_ReportRevotrack" + 
			"  @Custid="+cust.s_cust_id;
 

 
		  
		rs = stmt.executeQuery(sSql);		
		while (rs.next())
		{
			if (contCount % 2 != 0) sClassAppend = "_other";
			else sClassAppend = "";
			
			++contCount;
		 
			//Page logic
			if (contCount <= (curPage-1)*amount) continue;
			else if (contCount > curPage*amount) continue;
	
			String Statusid = rs.getString(1);
			Name = new String(rs.getBytes(2),"UTF-8");
			 
			Start_Date = rs.getString(3);
			
			Sent = rs.getString(4);
			Reaching = rs.getString(5);
			Bbacks=rs.getString(6);
			
			Dist_Reads = rs.getString(7);
			Distinct_Read_PRC = rs.getString(8);
			
			Distinct_Clicks = rs.getString(9);
			Distinct_Clicks_PRC = rs.getString(10);
			
			Purchasers = rs.getString(11);
			Purchases = rs.getString(12);
			
			Yuzde = rs.getString(13);
			Total = rs.getString(14);
			Camp_id = rs.getString(15);

			Type_id = rs.getString(16);
			Media_id = rs.getString(17); 
			Queue_daily_flag = rs.getString(18); 
		
			String TYPE_VALUE=null;
			  
	
				if(Type_id.equals("2") && Media_id.equals("1") && Queue_daily_flag!=null ){
 						 TYPE_VALUE="Automated Check Daily";
				}
 
			 	if(Type_id.equals("2") && Media_id.equals("1") && Queue_daily_flag==null){
 					 
						 TYPE_VALUE="Standard";
				}

				if(Type_id.equals("4") && Media_id.equals("1")  ){
						TYPE_VALUE="Automated Triggered"; 
				}
  
  
			htmlFirstBox = "<tr>"
							+" "
							+"<td class=\"list_row" + sClassAppend + "\"> "
							+"<a href=\"javascript:goToEdit('" + Camp_id + "' )\">" + Name + "</a></td>\n";
			
			// === === ===
			if ((contCount - 1) % 2 != 0) sClassAppend = "_other";
			else sClassAppend = "";
			
			boolean isTemplate = false;
			htmlContent += htmlFirstBox;
			htmlContent += "<td class=\"list_row" + sClassAppend + "\">"+TYPE_VALUE+"</td>\n";
			htmlContent += "<td class=\"list_row" + sClassAppend + "\">"+Start_Date+"</td>\n";
			htmlContent += "<td class=\"list_row" + sClassAppend + "\" nowrap>"+Sent+"</td>\n";
 			htmlContent += "<td class=\"list_row" + sClassAppend + "\" nowrap>"+Reaching+"</td>\n";
 			htmlContent += "<td class=\"list_row" + sClassAppend + "\" nowrap>"+Bbacks+"</td>\n"; 
 			
 			htmlContent += "<td class=\"list_row" + sClassAppend + "\" nowrap>"+Dist_Reads+"</td>\n";
 			htmlContent += "<td class=\"list_row" + sClassAppend + "\" nowrap>"+Distinct_Read_PRC+"</td>\n";
 			
 			htmlContent += "<td class=\"list_row" + sClassAppend + "\" nowrap>"+Distinct_Clicks+"</td>\n";
 			htmlContent += "<td class=\"list_row" + sClassAppend + "\" nowrap>"+Distinct_Clicks_PRC+"</td>\n";
 			
 			htmlContent += "<td class=\"list_row" + sClassAppend + "\" nowrap>"+Purchasers+"</td>\n";
 			htmlContent += "<td class=\"list_row" + sClassAppend + "\" nowrap>"+Purchases+"</td>\n";
 			
 			htmlContent += "<td class=\"list_row" + sClassAppend + "\" nowrap>"+Yuzde+"</td>\n";
 			htmlContent += "<td class=\"list_row" + sClassAppend + "\" nowrap>"+Total+"</td>\n";
 			

			htmlContent += "</tr>\n";
 
			 
		}

		if (htmlContent.length() == 0){
			htmlContent += "<tr><td colspan=\"5\" class=\"list_row\">There is currently no Content</td></tr>\n";
		}

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

 


<head>
<title>Revotrack Report</title>
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
											"aLengthMenu": [[5, 10, 15, 25, 50, 100 , -1], [5, 10, 15, 25, 50, 100, "All"]],
										    "iDisplayLength" : 10,
											"sPaginationType": "full_numbers",
											"aaSorting": [[ 2, "desc" ]]
				} );
				oTable2 = $('#example2').dataTable({
					"sDom": "tlrip",
				    "aLengthMenu": [[5, 10, 15, 25, 50, 100 , -1], [5, 10, 15, 25, 50, 100, "All"]],
				    "iDisplayLength" : 10,
					"aoColumns": [null,null,null,null,null,null,null],
					"aaSorting": [[ 1, "desc" ]]
				});
				
				$('#filter').change( function(){
					filter_string = $('#filter').val();
					oTable.fnFilter( filter_string , 4);
					filter_string = $('#filter').val();
					oTable2.fnFilter( filter_string , 3);
				});

			} );

		</script>
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
	
	function goToEdit(report_id)
	{
		var sURL = "";
		
		sURL = "report_redirect.jsp?act=VIEW&id=" + report_id;
		location.href = sURL;
	}

</script>
<script language="JavaScript" src="/cms/ui/ooo/script.js"></script>	
</head>
<BODY class="paging_body">




<div class="page_header">Revotrack List</div>
<div class="page_desc"> See the results of your campaigns</div>	
<div id="info">
<div id="xsnazzy">

<div class="xboxcontent">	

		  <table style="padding-top: 4px;" width="100%" cellpadding="2" cellspacing="0" class="listTable">
		 			<tbody>
		 				<tr>
		 					 <td nowrap="true" align="left" valign="middle">
		 						<a  href="report_revotrack_excel.jsp?exportToExcel=YES" class="newbutton">
		 								 	&nbsp;Export to Excel</a></td>
		 						 
		 				</tr>
		 				</tbody>
			</table>
			 				
			<table class="listTable" id="example" width="100%" cellpadding="2" cellspacing="0">
				<thead>
				<tr>
				   
					<th align="left" valign="middle" width="20%" nowrap>&#x20; Name</th>
					<th align="left" valign="middle" width="10%" nowrap>&#x20; Type</th>
					<th align="left" valign="middle" width="10%" nowrap>&#x20; Start Date</th>
					<th align="left" valign="middle" width="10%" nowrap>&#x20; Sent </th>
					
					<th align="left" valign="middle" width="5%" nowrap>&#x20; Reaching</th>
					<th align="left" valign="middle" width="5%" nowrap>&#x20; bbacks</th>
				 	<th align="left" valign="middle" width="5%" nowrap>&#x20; Dist Reads</th>
					<th align="left" valign="middle" width="5%" nowrap>&#x20; Distinct Read PRC</th>
					<th align="left" valign="middle" width="5%" nowrap>&#x20; Distinct Clicks</th>
					<th align="left" valign="middle" width="5%" nowrap>&#x20; Distinct Clicks PRC</th>
					<th align="left" valign="middle" width="5%" nowrap>&#x20; Purchasers</th>
					<th align="left" valign="middle" width="5%" nowrap>&#x20; Purchases</th>
					<th align="left" valign="middle" width="5%" nowrap>&#x20; %</th>
					<th align="left" valign="middle" width="5%" nowrap>&#x20; Total</th>
					
				 </tr>
				</thead>
				<tbody>
				<!-- List of the contents -->
				<%= htmlContent %>
				</tbody>
			</table>
			
			 
</div>

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

 

</script>

	 
			 
				 

</body>
</fmt:bundle>

</html>


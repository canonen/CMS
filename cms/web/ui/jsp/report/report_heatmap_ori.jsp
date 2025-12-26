<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.imc.*,			
			com.britemoon.cps.rpt.*,
			java.sql.*,java.net.*,java.io.*,
			java.util.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%@ include file="functions.jsp"%>
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

String	sCampID	= request.getParameter("Q");
String	sCache 	= request.getParameter("Z");
sCache = ("1".equals(sCache))?sCache:"0";
%>

<HTML>
<HEAD>
<%@ include file="../header.html" %>
<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" >

<script type="text/javascript" src="heatmap-js/heatmap.js"></script>
<script type="text/javascript" src="heatmap-js/jquery.min.js"></script>	
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">


<script language="javascript">

var showMoreOn = false;
function pop_up_win(url)
{
	windowName = 'report_results_window';
	windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, height=600, width=750';
	ReportWin = window.open(url, windowName, windowFeatures);
}
function toggleShowMore(more)
{
	var elems = document.getElementById('twebp').getElementsByTagName('tr');
	
	if(!showMoreOn)
	{
		
		for (var i = 0; i < elems.length; i++) {
				elems[i].className = 'showMore';
		}
		document.getElementById('showMoreText').text = 'Show less';
		showMoreOn = true;
	}
	else
	{
		var l = elems.length;
		if(l < 10)
		{
			l = elems.length;
		}
		for (var i = 0; i < l; i++) 
		{
			if(i>10)
			elems[i].className = 'hideMore';
			else
			elems[i].className = 'showMore';
		}
		elems[l-1].className = 'showMore';
		document.getElementById('showMoreText').text = 'Show more';
		showMoreOn = false;
		
	}
}
</script>

<style>
.report_heatmap_main { width:100%; height:100%; }

.demo-wrapper{position:relative;width:100%; height:100%; }
</style>


<style>
.hideMore {
	display:none;
}
.showMore {
}
</style>
</HEAD>
<BODY>

<%
ConnectionPool	cp		= null;
Connection		conn	= null;
Statement		stmt	= null;
ResultSet		rs		= null; 

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

	int nPos = 0;
	String reportName = "";
	String SubjectLine = "";
	String reportDate = "";
	int numRecs = 0;
	


	//Customize deliveryTracker report Feature (part of release 5.9)
	int showTrackerRpt = 0;
	boolean bFeat = ui.getFeatureAccess(Feature.PV_DELIVERY_TRACKER);
	if (bFeat)
	{
 		int nCount = getSeedListCount(stmt,cust.s_cust_id, sCampID);
		if (nCount > 0)
			showTrackerRpt = 1;
	}
	// end release 5.9
	
	if ((sCampID != null))
	{
		String sSql = 
			" SELECT count(camp_id)" +
			" FROM cque_campaign c with(nolock)" +
			" WHERE c.cust_id = " + cust.s_cust_id +
			" AND c.camp_id = " + sCampID;
			
		rs = stmt.executeQuery(sSql);
		if(rs.next()) numRecs = rs.getInt(1);
		rs.close();

		// === === ===		
		
		
		
		// === === ===	
		
		sSql = 
			" SELECT count(*)" +
			" FROM crpt_camp_pos with(nolock)" +
			" WHERE camp_id IN ("+sCampID+")";
			
		rs = stmt.executeQuery(sSql);
		if ( rs.next() ) nPos = rs.getInt(1);
		rs.close();
		
		// === === ===				

		sSql = 
			" EXEC usp_crpt_camp_list" +
			"  @camp_id="+sCampID+
			", @cust_id="+cust.s_cust_id+
			", @cache=0";
			
		rs = stmt.executeQuery(sSql);
		
		while( rs.next() )
		{
			byte[] bVal = rs.getBytes("CampName");
			reportName = (bVal!=null?new String(bVal,"UTF-8"):"");
			byte[] bVal2 = rs.getBytes("SubjectLine");
			SubjectLine = (bVal2!=null?new String(bVal2,"UTF-8"):"");
			reportDate = rs.getString("StartDate");
		}
		rs.close();
	}

	if ((sCampID == null) || ("".equals(sCampID)) || (numRecs < 1))
	{
%>
	<table class="listTable" cellspacing=0 cellpadding=0 width=650 border=0>
		<tr>
			<td valign=top align=center width=650>
				<table cellspacing=1 cellpadding=2 width="100%">
					<tr>
						<td align="center" valign="middle" style="padding:10px;">
							<b>No Campaign for that ID</b>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	<br><br>
<%
	}
	else
	{
%>
		<div class="sectionTopHeader" style="margin-bottom:1px;">
			<a href="report_object.jsp?id=<%=sCampID%>">
				<span>Campaign Results</span>
			</a>
			<a href="report_cache_list.jsp?Q=<%=sCampID%>">
				<span>Demographic Or Time Report</span>
			</a>
			<a href="report_time.jsp?Q=<%=sCampID%>">
				<span>Activity vs. Time Report</span>
			</a>
			<a href="report_time.jsp?Q=<%=sCampID%>">
							<span>RevoTrack Results </span>
			</a>
			<a class="activeTab" href="#">
				<span>HeatMap</span>
			</a>
			<br class="clearfix">
		</div>
	
		<table width=100% class=listTable  cellspacing=0 cellpadding=0>
			<tr>
				<th class=sectionheader>&nbsp;<b class=sectionheader>HeatMap</b></th>
			</tr>
			<tr>
				<td>Campaign Name :<b><%= reportName %></b></td>
			</tr>
			<tr>
				<td>Subject Name : <b><%= SubjectLine %></b></td>
			</tr>
			 
			
			 
		</table>
		
		<br>
		
		<!-- Main container start -->
		
		<!-- Content Linkleri -->
		<% 
			String sSqlSinan ="";
			String Cont_ID="";
			int Link_ID=0;
			int Tot_Html_Clicks=0;
			String Link_Name ="";
			String Href ="";
			int  Toplam_Link_Sayisi=0;
			int  Toplam_Click_Sayisi=0;
			int  Ortalama=0;
		
		/*sSqlSinan = 
				"select  l.cont_id as Cont_ID, c.link_id as Link_ID,  c.link_name as Link_Name, c.tot_html_clicks as Tot_Html_Clicks, l.href as Href from crpt_camp_link c, cjtk_link l where c.link_id=l.link_id and c.camp_id=" + sCampID +"and c.tot_html_clicks!=0"; 
		 */
			
		
			sSqlSinan = 
				"select  l.cont_id as Cont_ID, c.tot_html_clicks as Tot_Html_Clicks, l.href as Href,"+
			 	"(select count(*) from crpt_camp_link where camp_id="+ sCampID +" and tot_html_clicks!=0) Count1,"+
				"(select SUM(tot_html_clicks) from crpt_camp_link where   camp_id="+sCampID+"  and  tot_html_clicks!=0) Count2 "+
				"from crpt_camp_link c , cjtk_link l "+ 
			 	"where c.link_id=l.link_id and c.camp_id="+sCampID+" and c.tot_html_clicks!=0";
			
		
					rs = stmt.executeQuery(sSqlSinan);
					out.print("<table style='display:none'  width=100% class=listTable   id=sinan cellspacing=0 cellpadding=0>");
					 
					while (rs.next()) {
					
						Cont_ID = rs.getString(1);
						
						out.println("<tr><td>" + rs.getInt("Tot_Html_Clicks") + "</td>");
						out.println("<td>" + rs.getString("Href") + "</td> ");
						out.println("<td>" + rs.getInt("Count1") + "</td> ");
						out.println("<td>" + rs.getInt("Count2") + "</td> </tr>");
						
						//Toplam_Link_Sayisi = rs.getInt(4);
						//Toplam_Click_Sayisi = rs.getInt(5);
						 
						}
					out.print("</table>");
					
					rs.close();
					 
					
					
		%>
			
		<!-- Content Linkleri End -->	
		
		<!-- Content  -->	
		
		<%
		if (Cont_ID == null)
			{
				//No values have been selected yet
				out.println("Enter formula values above and then select preview type.");
				return;
			}
		
			// === === ===
		
			Content cont = new Content();
			cont.s_cont_id = Cont_ID;
			if(cont.retrieve() < 1){
				//throw new Exception("Invalid content. Content does not exist.");
				
				%>
				
				<table align="center" class="listTable" cellspacing=0 cellpadding=0 width=650 border=0>
						<tr>
							<td valign=top align=center width=650>
								<table cellspacing=1 cellpadding=2 width="100%">
									<tr>
										<td align="center" valign="middle" style="padding:10px;">
											<b>Raporu Update Edin.</b>
										</td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
					<br><br>
				
				
				
				<%
				
				
				
				
			}
			// === === ===
		
			ContBody cont_body = new ContBody(Cont_ID);
				
			String htmlPart = cont_body.s_html_part;
			
			if(htmlPart == null) htmlPart = " ";

		
			// === === ===
				
		%>
		
			 <div class="demo-wrapper">
				
				<div class="heatmap" id="report_heatmap_main" >

					<% out.print(htmlPart);%>

				</div>	
			</div>
		 
			  
		<!-- Content End  -->
		<!-- Main container end -->

		
<%
	}
}
catch (Exception ex) { throw ex; }
finally
{
	try
	{
		if( stmt  != null ) stmt.close(); 
		if( conn  != null ) cp.free(conn);
	}
	catch (SQLException ex) { }
}
%>



<script language="javascript">
	
		$('#mobile').remove();
		$('#coupon').remove();
		
		
		
		//var newHTML = $('#report_heatmap_main').clone().find("body").remove().end().html();
		
		//console.log(newHTML);
		//title.append('<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10">');
		
 

	var sayac=0;
	var toplam_clicks=0;
	var href;
	 
	var ContentHeight = document.getElementById('report_heatmap_main');
	      if(ContentHeight) {
		    var ContentHeight=document.getElementsByTagName("html")[0].scrollHeight
		   
	  }   
	
	$('#report_heatmap_main a' ).each(function(){	
	
			
			

		
			var link=$(this);
			var href = $(this).attr('href');
			$(this).click(false);	 
			var Img=$(this).find('img').attr('src');
			
			if(Img){
				
			 var height = $(this).parent().find("img").height();	
			 var width = $(this).parent().find("img").width(); 
			 var imgposition =$(this).find("img").position();
			 
			  
			 	  $('#sinan tr').each(function() {
				   		 
				   	   var urlKontrol = $(this).find("td").eq(1).text();
				   	   
				   	   
				   	  	if(urlKontrol==href){
				   	   	 
				   	   		
				   	   		
				   	   		var sayi = $(this).find("td").eq(0).text();
							var toplamadet = $(this).find("td").eq(2).text();
							var toplamclicks = $(this).find("td").eq(3).text();
							var ort=Math.round(toplamclicks/toplamadet);
							
							var yuzde=(sayi*100)/toplamclicks;

							var left_konum=Math.round(imgposition.left + (width/2)-30);
							var top_konum=Math.round(imgposition.top + (height/2)-18);
							
						       link.append('<div class="tooltip" style="padding:10px; font-size:14px;color:#fff;text-decoration:none; z-index: 10000001;position:absolute;left:'+left_konum+';top:'+top_konum+'; ">%' + yuzde.toFixed(2) +' </div>');

							 
							var xx = h337.create({
								 element: document.getElementById("report_heatmap_main"),
								"height":ContentHeight,
								"radius":50,
								"visible":true										
							});

							var database = {max:ort,
								 data: [{x:imgposition.left + (width/2), y: imgposition.top + (height/2), count: sayi}]
								 };
													
							xx.store.setDataSet(database);
							
				   	   	 	
						 
					}
				   });		

				 
				
			}
 	
		
	});
	 	
   
</script>

</body>
</html>
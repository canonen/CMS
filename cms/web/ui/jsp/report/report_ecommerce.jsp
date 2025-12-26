<%@ page
	language="java"
	import="com.britemoon.cps.imc.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			java.util.*,java.sql.*,
			java.util.Date,java.io.*,
			java.math.BigDecimal,
			org.apache.log4j.*"
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

AccessPermission can = user.getAccessPermission(ObjectType.PV_DELIVERY_TRACKER);
if(!can.bRead || !can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

%>

<html>
	<head>
		<title>Revotrack Report</title>
		<LINK rel="stylesheet" href="<%=ui.s_css_filename%>" type="text/css">	

<script language="javascript">
var showMoreOn = false;
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
.hideMore {
	display:none;
}
.showMore {
}
</style>


<script type="text/javascript">
	var fileLoc = "report_ecommerce_month.jsp?cust_id=<%=cust.s_cust_id%>";
	var totalAmt;
	var Month;
</script>


	</head>
	<%
	
	// Get Connection
	Statement		stmt	= null;
	ResultSet		rs		= null; 
	ConnectionPool	cp		= null;
	Connection		conn	= null;

	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("report_ecommerce.jsp");
	stmt = conn.createStatement();

	rs = stmt.executeQuery("select sum(purchases) as purchases, CAST(ROUND(sum(total), 2) AS MONEY) as total_sales from crpt_mbs_revenue_report with(nolock) where camp_id in (select camp_id from cque_campaign with(nolock) where cust_id="+cust.s_cust_id+" and type_id in (2,4))");

	String sPurchases		=null;
	Double sTotal_Sales		=null;

	while(rs.next()){

		sPurchases 		= rs.getString(1);
		sTotal_Sales		= rs.getDouble(2);				
	}
	rs.close();



	rs = stmt.executeQuery("select CAST(ROUND(sum(total)/sum(purchases), 2,1) AS MONEY) as Average_Sales from crpt_mbs_revenue_report with(nolock) where camp_id in (select camp_id from cque_campaign with(nolock) where cust_id="+cust.s_cust_id+" and type_id in (2,4))");

	Double sAverage_Sales		=null;

	while(rs.next()){

		sAverage_Sales 		= rs.getDouble(1);
	}
	rs.close();


	rs = stmt.executeQuery("select count(camp_id) as Camp_Count from crpt_mbs_revenue_report with(nolock) where camp_id in (select camp_id from cque_campaign with(nolock) where cust_id="+cust.s_cust_id+" and type_id in (2,4))");

	String sCamp_Count		=null;

	while(rs.next()){

		sCamp_Count 		= rs.getString(1);
	}
	rs.close();

%>	

								<style>
								.sumTbl td {
									border:1px solid #e9e9e9;
									text-align:right;
								}
								</style>

		<div class="sectionTopHeader" style="margin-bottom:1px;">
			<a href="report_ecommerce.jsp?cust_id=<%=cust.s_cust_id%>">
				<span>Campaign Results</span>
			</a>

			<br class="clearfix">
		</div>
		
<table class=listTable border=0 cellspacing=0 cellpadding=0 width="465">
						<tr>
							<th colspan="4">Sales Conversions</th>
							
						</tr>
						<tr>
							<td>
								<table cellpadding="8" cellspacing="0" width="500" class="sumTbl" style="border-collapse:collapse;">
									<tr>
										<td style="text-align:left;"><img align="absmiddle" src="http://a.dryicons.com/images/icon_sets/coquette_part_2_icons_set/png/128x128/edit_page.png" width="18"> Campaign Count</td>
										<td style="background-color:#f3f3f3;font-weight: bold;"><% out.print(sCamp_Count); %></td>
									</tr>
									<tr>
										<td style="text-align:left;"><img align="absmiddle" src="http://c.dryicons.com/images/icon_sets/coquette_part_2_icons_set/png/128x128/search_user.png" width="18"> Purchases</td>
										<td style="background-color:#eaeaea;font-weight: bold;"><% out.print(sPurchases); %></td>
									</tr>
									<tr>
										<td style="text-align:left;"><img align="absmiddle" src="http://c.dryicons.com/images/icon_sets/coquette_part_2_icons_set/png/128x128/insert_to_shopping_cart.png" width="18"> Sales</td>
										<td style="background-color:#f3f3f3;font-weight: bold;"><% out.print(sTotal_Sales); %> TL </td>
									</tr>
									<tr>
										<td style="text-align:left;"><img align="absmiddle" src="http://a.dryicons.com/images/icon_sets/coquette_part_2_icons_set/png/32x32/chart_up.png" width="18"> Average Sales</td>
										<td style="background-color:#eaeaea;font-weight: bold;"><% out.print(sAverage_Sales); %> TL </td>
									</tr>
							
								</table>
							
							</td>
						</tr>
</table>
<br>

			<TABLE id="twebp" class="listTable" cellpadding=0 cellspacing=0>
						<tr>
							<th>Campaign Name</th>
							<th>Purchasers</th>
							<th>Purchases</th>
							<th>Sales</th>
							
						</tr>			
			<%
				
				
				rs = stmt.executeQuery("select cc.camp_name, c.purchasers, c.purchases, CAST(ROUND(c.total, 2,1) AS MONEY) as Total, cc.camp_id from crpt_mbs_revenue_report c with(nolock) left join cque_campaign cc with(nolock) on c.camp_id=cc.camp_id where cc.cust_id="+cust.s_cust_id+" and cc.type_id in (2,4) order by c.total desc");

				int iCount = 0;
				String sClassAppend = "_other";


				String sCamp_Name		=null;
				String sCamp_Purchasers		=null;
				String sCamp_Purchases		=null;
				BigDecimal sCamp_Sales		=null;
				String sCamp_ID		=null;
				
				ResultSetMetaData rsmd = rs.getMetaData();
				int nColumns = rsmd.getColumnCount();

				while(rs.next()){
					if (iCount % 2 != 0) sClassAppend = "_other";
					else sClassAppend = "";
					iCount++;
					
					sCamp_Name 	 	= new String(rs.getBytes(1),"UTF-8");
					sCamp_Purchasers 		= rs.getString(2);
					sCamp_Purchases 		= rs.getString(3);
					sCamp_Sales	 		= rs.getBigDecimal(4);
					 sCamp_Sales = sCamp_Sales.setScale(2, BigDecimal.ROUND_HALF_UP);
					sCamp_ID	 		= rs.getString(5);
					%>
						<tr class="<%=(iCount > 10 ? "hideMore" : "showMore")%>">
							<td class="list_row<%= sClassAppend %>"><a href="report_redirect.jsp?act=VIEW&id=<% out.print(sCamp_ID); %>"><% out.print(sCamp_Name); %></a></td>
							<td class="list_row<%= sClassAppend %>"><% out.print(sCamp_Purchasers); %></td>
							<td class="list_row<%= sClassAppend %>"><% out.print(sCamp_Purchases); %></td>
							<td class="list_row<%= sClassAppend %>"><% out.print(sCamp_Sales); %> TL</td>
							
						</tr>	
					<%						
				}
				rs.close();				
			%>
				<tr>
					<th colspan="4" style="text-align:center;"><a id="showMoreText" style="font-size:11px;" href="javascript:void(0);" onclick="toggleShowMore()">Show more</a></th>
				</tr>
			
			</TABLE>
			
	</body>
</HTML>

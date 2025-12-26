<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.ctl.*,
			java.util.*,java.sql.*,
			java.util.List,
			java.text.DecimalFormat,java.text.DecimalFormatSymbols,java.math.BigDecimal,
			java.text.SimpleDateFormat,
			org.w3c.dom.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%@ include file="wvalidator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

CustCredit cc = new CustCredit(cust.s_cust_id);

%>
<%@ include file="header.jsp"%>

<%
DecimalFormat df = new DecimalFormat("#,##0");
df.setDecimalFormatSymbols(new DecimalFormatSymbols(Locale.ITALY));
%>
<table cellpadding="0" class="p8-table" cellspacing="0" border="0">
<tr>
	<td colspan="4">
		<div class="notification-box" id="notification-box">
			<button class="close" data-dismiss="alert" onclick="javascript:document.getElementById('notification-box').style.display='none';">&times;</button>
			<b>Duyuru!</b> Revotas v2.8 simple wizard ve advanced targeting ile yayına girdi.
		</div>
		<table cellpadding="0" cellspacing="0">
		<tr>
			<td width="250">
				<div id="chart_div"><b>Grafik Yükleniyor<br>Lütfen bekleyiniz..</b></div>
			</td>
			<td>
				<table cellpadding="0" cellspacing="0" class="">
					<tr>
						<th style="font-size: 11pt;" colspan="3">Hesap Özeti: <%=cust.s_cust_name%></th>
					</tr>
					<tr>
						<td class="tright">Toplam</td>
						<td><div class="tboxes noread" id="include0">...</div></td>
						<td class="perc">100 %</td>
					</tr>
					<tr>
						<td class="tright">Aktif</td>
						<td><div class="tboxes act" id="include1">...</div></td>
						<td class="perc"><div id="include11"><img src="/cms/ui/images/smallloader.gif"/></div></td>
					</tr>
					<tr>
						<td class="tright">Geri dönen</td>
						<td><div class="tboxes undeliv" id="include2">...</div></td>
						<td class="perc"><div id="include22"><img src="/cms/ui/images/smallloader.gif"/></div></td>
					</tr>
					<tr>
						<td class="tright">Listeden çıkan</td>
						<td><div class="tboxes unsub" id="include3">...</div></td>
						<td class="perc"><div id="include33"><img src="/cms/ui/images/smallloader.gif"/></div></td>
					</tr>
					<tr>
						<td class="tright">Okuyan</td>
						<td><div class="tboxes noread" id="include4">...</div></td>
						<td class="perc"><div id="include44"><img src="/cms/ui/images/smallloader.gif"/></div></td>
					</tr>
					<tr>
						<td class="tright">Okumayan</td>
						<td><div class="tboxes noread" id="include5">...</div></td>
						<td class="perc"><div id="include55"><img src="/cms/ui/images/smallloader.gif"/></div></td>
					</tr>
				</table>
			
			</td>
		</tr>
		</table>

	</td>
</tr>
<!--
<tr>
	<th class="">Toplam Kredi</th>
	<th class="">Harcanan Kredi</th>
	<th class="">Kalan Kredi</th>
	<th class="">Kredi Sat?n Al</th>
</tr>
<tr>
	<td><div class="cval ctotal"><%=df.format(new BigDecimal(cc.s_allocated_credit))%></div></td>
	<td><div class="cval ctotal"><%=df.format(new BigDecimal(cc.s_used_credit))%></div></td>
	<td><div class="cval ctotal"><%=df.format(new BigDecimal(cc.s_remaining_credit))%></div></td>
	<td><div class="cready"><a href="#"><img border="0" src="images/1340280784_plus_32.png"></a></div></td>
</tr>
-->
</table>

<%@ include file="footer.jsp"%>

	<script type="text/javascript" src="https://www.google.com/jsapi"></script>
	<script type="text/javascript">
		var fileLoc = "rcp_stats.jsp?custid=<%=cust.s_cust_id%>&opt=";
		var totalRecip;
		var activeRecip;
		var bbackRecip;
		var unsubRecip;
		var readRecip;
		var noreadRecip;
		var activeRecipPrc;
		var bbackRecipPrc;
		var unsubRecipPrc;
		var readRecipPrc;
		var noreadRecipPrc;
		google.load("visualization", "1", {packages:["corechart"]});
	</script>

    <script type="text/javascript">
	
	function pieChart()
	{		
		var data = google.visualization.arrayToDataTable([
		['Task', 'Hours per Day'],
		['Aktif',     parseInt(activeRecip)],
		['Geri Dönen',      parseInt(bbackRecip)],
		['Listeden Çıkan',  parseInt(unsubRecip)]
		]);

		var options = {
			is3D:false,
			legend: {position: 'none'},
			width:250,
			height:250,
			chartArea:{left:10,top:10,width:"90%",height:"100%"},
			colors:['#3366CC','#FF9900','#DC3912']
		};

		if(totalRecip != 0)
		{
			var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
			chart.draw(data, options);
		}
		else
			document.getElementById('chart_div').innerHTML = '<b>Grafik oluşturmak için veri bulunmuyor.</b>';
	}
    </script>
	
	<script type="text/javascript">
	function addCommas(nStr)
	{
	  nStr += '';
	  x = nStr.split('.');
	  x1 = x[0];
	  x2 = x.length > 1 ? '.' + x[1] : '';
	  var rgx = /(\d+)(\d{3})/;
	  while (rgx.test(x1)) {
		x1 = x1.replace(rgx, '$1' + '.' + '$2');
	  }
	  return x1 + x2;
	}
	$(document).ready( function() {

	$.get(fileLoc+'6', function(data) {
			$("#include0").html(' '+addCommas(data));totalRecip=data;
			
			$.get(fileLoc+'1', function(data) {
				$("#include1").html(' '+addCommas(data));activeRecip=data;
				activeRecipPrc = (activeRecip * 100)/totalRecip;
				$("#include11").html(' (%'+activeRecipPrc.toFixed(2)+')');
				
				$.get(fileLoc+'2', function(data) {
					$("#include2").html(addCommas(data));bbackRecip=data;
					bbackRecipPrc = (bbackRecip * 100)/totalRecip;
					$("#include22").html(' (%'+bbackRecipPrc.toFixed(2)+')');
				
					$.get(fileLoc+'3', function(data) {
						$("#include3").html(addCommas(data));unsubRecip=data;
						unsubRecipPrc = (unsubRecip * 100)/totalRecip;
						$("#include33").html(' (%'+unsubRecipPrc.toFixed(2)+')');
					
						$.get(fileLoc+'4', function(data) {
							$("#include4").html(addCommas(data));readRecip=data;
							readRecipPrc = (readRecip * 100)/totalRecip;
							$("#include44").html(' (%'+readRecipPrc.toFixed(2)+')');
							
							noreadRecip=totalRecip-readRecip;							
							$("#include5").html(''+addCommas(noreadRecip));
							noreadRecipPrc = (noreadRecip * 100)/totalRecip;
							$("#include55").html(' (%'+noreadRecipPrc.toFixed(2)+')');
								
							pieChart();
						});
					});
				});
			});
		});
	});
	</script>
</body>
</html>
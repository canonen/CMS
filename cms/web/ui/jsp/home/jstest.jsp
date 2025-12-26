<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.ctl.*,
			java.util.*,java.sql.*,
			java.net.*,java.text.DateFormat,
			java.text.SimpleDateFormat,
			org.json.simple.JSONObject,
			org.w3c.dom.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@page import="com.britemoon.cps.som.camp.*"%>
<%@page import="com.britemoon.cps.som.com.*"%>
<%@page import="com.britemoon.cps.som.fb.*"%>
<%@page import="com.britemoon.cps.som.servlets.*"%>
<%@page import="com.britemoon.cps.som.tw.*"%>
<%@page import="com.restfb.types.Post, com.restfb.types.Page,twitter4j.ResponseList,twitter4j.Status,twitter4j.TwitterException,twitter4j.ProfileImage"%>


<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

Customer cSuper = ui.getSuperiorCustomer();
Customer cActive = ui.getActiveCustomer();

boolean isHyatt = ui.getFeatureAccess(Feature.HYATT);

String sSysName = ui.getProp("sys_name");
%>
<html>
<head>
<title></title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script type="text/javascript" src="../../js/svg.js"></script>
<script type="text/javascript" src="../../js/report/jquery-1.5.1.js"></script>
<script language="JavaScript" src="../../js/scripts.js"></script>
<script language="JavaScript" src="../../js/tab_script.js"></script>
<script type="text/javascript" src="../../js/highcharts.js"></script>
<script type="text/javascript" src="../../js/flexcroll.js"></script>
<script type="text/javascript">
	var mydomain=(window.location.href.match(/:\/\/(.[^/]+)/)[1]).replace('www.','');
	alert(mydomain);
</script>
<script language="JavaScript">
	
	function loadSysAnnounce()
	{
		var newWin;
        var url = "system_notice.jsp";
        var windowName = "system_announcements";
		var windowFeatures = "depedent=yes, scrollbars=no, resizable=yes, toolbar=no, location=no, menubar=no, height=400, width=550";
		newWin = window.open(url, windowName, windowFeatures);
	}
	
	function loadSysNote(note_id)
	{
		var newWin;
        var url = "system_note_info_get.jsp?win=true&note_id=" + note_id;
        var windowName = "system_announcements";
		var windowFeatures = "depedent=yes, scrollbars=no, resizable=yes, toolbar=no, location=no, menubar=no, height=400, width=550";
		newWin = window.open(url, windowName, windowFeatures);
	}
	
</script>
<script type="text/javascript">
	var fileLoc = "remoteFileStats.jsp?custid=<%=cust.s_cust_id%>&opt=";
	var totalDBSize;
	var totalUnsubs;
	var totalUnsubsPrc;
	var totalBBacks;
	var totalBBacksPrc;
	var activeRecips;
	var activeRecipsPrc;
</script>

<script type="text/javascript">
$(document).ready( function() {

	getSocialStuff(); 
	
	$("#hoverover").click(
		function() {
		  $('#periodSelectorMonth').hide();
		  $('#periodSelector').toggle();
		}
	);
	
	$("#hoveroverMonth").click(
		function() {
		  $('#periodSelector').hide();
		  $('#periodSelectorMonth').toggle();
		}
	);

	$.get(fileLoc+'1', function(data) {
		$("#include1").html(' '+data);totalDBSize=data;
		$.get(fileLoc+'2', function(data) {
			$("#include2").html(data);
			totalUnsubs=data;
			totalUnsubsPrc = (totalUnsubs * 100)/totalDBSize;
			$("#include22").html(' (%'+totalUnsubsPrc.toFixed(2)+')');
		
			$.get(fileLoc+'3', function(data) {
				$("#include3").html(data);
				totalBBacks=data;
				totalBBacksPrc = (totalBBacks * 100)/totalDBSize;
				$("#include33").html(' (%'+totalBBacksPrc.toFixed(2)+')');
			
				$.get(fileLoc+'4', function(data) {
					$("#include4").html(data);
					activeRecips=data;
					activeRecipsPrc = (activeRecips * 100)/totalDBSize;
					$("#include44").html(' (%'+activeRecipsPrc.toFixed(2)+')');
									
					pieChart();
					graphBy('month', true, 1);
				});
			});
		});
	});
});
</script>

<script type="text/javascript">

	function getSocialStuff() {
	
		
		$('#socialcontainer').html('<img src="/cms/ui/images/smallloader.gif"/>');
		$('#fblikes').html('<img src="/cms/ui/images/smallloader.gif"/>');
		$('#twfollowers').html('<img src="/cms/ui/images/smallloader.gif"/>');
	
		$.get('socialinc.jsp', function(data) {

			var $response=$(data);
			$('#socialcontainer').html($response.filter('#socialRs').html());
			$('#fblikes').html($response.filter('#facebookRs').html());
			$('#twfollowers').html($response.filter('#twitterRs').html());


		});
	
	}
	
	function pageSwitcher(objId) {
		
		$('#socialcontainer').html('<img src="/cms/ui/images/smallloader.gif"/>');
		$('#fblikes').html('<img src="/cms/ui/images/smallloader.gif"/>');
		$('#twfollowers').html('<img src="/cms/ui/images/smallloader.gif"/>');
	
		$.get('socialinc.jsp?switchPage='+objId, function(data) {

			var $response=$(data);
			$('#socialcontainer').html($response.filter('#socialRs').html());
			$('#fblikes').html($response.filter('#facebookRs').html());
			$('#twfollowers').html($response.filter('#twitterRs').html());

			var list = document.getElementById('pages');

			for (var i = 0; i < list.options.length -1; i++) {
			  
				if(list.options[i].value == objId) {
				
					list.options[i].selected = true;
				}
			  
			}

		});
	
	}
	
function pieChart() {
	var chart = new Highcharts.Chart({
      chart: {
         renderTo: 'chart_div2',
         plotBackgroundColor: null,
         plotBorderWidth: null,
         plotShadow: false,
		 width: 250,
		 height: 250
      },
      title: {
         text: 'Account Summary',
		 margin:0,
		 align: 'left',
		 x: 0,
		 y: 5
      },
      tooltip: {
         formatter: function() {
            return '<b>'+ this.point.name +'</b>: '+ this.percentage.toFixed(2) +' %';
         }
      },
	  legend: {
		margin:100,
		width: 250,
        floating: true,
        align: 'left',
        x: 0,
		y:-10,
        itemWidth: 70,
		borderWidth: 0,
			itemStyle: {
				color: '#666666',
				fontSize: '11px'
			}
	  },
      plotOptions: {
         pie: {
            allowPointSelect: true,
            cursor: 'pointer',
            dataLabels: {
               enabled: false
            },
            showInLegend: true,
			slicedOffset: 5,
			size: '70%',
			shadow: false
         }
      },
      series: [{
         type: 'pie',
         data: [
            {
	                   name: 'Active',    
	                   y: activeRecipsPrc,
	                   sliced: true,
	                   selected: true,
	    			   color: '#89A54E'
	                },
	    			{
	    				name: 'Unsubs',
	    				y: totalUnsubsPrc,
	    				color: '#AA4643'
	    			},
	    			{
	    				name: 'Bounced',
	    				y: totalBBacksPrc,
	    				color: '#4D4E50'
			}
         ]
      }]
   });	
}

function graphBy(type, skipLoader, amount) {
	if(!skipLoader) {
		$("#chart_div").html('<span style=\'display: block;font-size: 12px;margin: 10px 0;text-align: center;\'><img src=\'/cms/ui/images/smallloader.gif\'><br>Loading chart.. <br> This may take a few seconds.</span>');
	}

	if(amount > 4) {
		return false;
	}
	
	var period=30*amount;
	var caption=amount + " Month";
	var average = 0;
	var vals = "";
	var nums = "";
	
	if(type == 'week') {
		period=7*amount;
		caption= amount + " Week";
	}
	
	var series = {
		data: []
	};
			
	var options = {
		chart: {
			renderTo: 'chart_div',
			defaultSeriesType: 'spline'
		},
		title: {
			text: 'Emails Sent on Last '+caption,
			margin:20,
			align: 'left',
			x: 0,
			y: 5
		},
		xAxis: {
			categories: [],
			labels: {
				enabled:false
			}
		},
		yAxis: {
			title:null, 
			min:0
		},
		 plotOptions: {
         spline: {
			allowPointSelect: true,
            cursor: 'pointer',
            lineWidth: 1,
            states: {
               hover: {
                  lineWidth: 2
               }
            },
            marker: {
               enabled: false,
               states: {
                  hover: {
                     enabled: true,
                     symbol: 'circle',
                     radius: 5,
                     lineWidth: 1
                  }
               }   
            }
         }
      },
	  plotOptions: {
        series: {
            color: '#ff6600',
			shadow:false,
			marker: {
                enabled: false
            }
        }
    },
		tooltip: {
         formatter: function() {
                   return 'Date:'+this.x +'<br><b>'+this.y+'</b> Emails Sent';
         }
		},
		legend: {
         enabled:false
      },
		series: []
	};

	$.get(fileLoc+period, function(data) {
		var values = data.split('|'); 
						
		for(var i=0;i<values.length-1;i++){
			var valueItems = values[i].split('_');
			var numbers = valueItems[0];
			var periods = valueItems[1];
			var periodItems = periods.split('-');
			
			var dateLabel = periodItems[2]+"/"+periodItems[1]+"/"+periodItems[0];
			average += parseInt(numbers);
			
			options.xAxis.categories.push(dateLabel);
			series.data.push(parseFloat(numbers));
		}
		options.series.push(series);
		var chart = new Highcharts.Chart(options);
	});	
}
</script>

<script language="JavaScript">

	function loadAdminNote(id)
	{
		var newWin;
        var url = "admin_note_get.jsp?note_id=" + id;
        var windowName = "admin_note_get";
		var windowFeatures = "depedent=yes, scrollbars=no, resizable=yes, toolbar=no, location=no, menubar=no, height=400, width=550";
		newWin = window.open(url, windowName, windowFeatures);
	}
	
	function loadUserNote(id)
	{
		var newWin;
        var url = "user_note_get.jsp?note_id=" + id;
        var windowName = "user_note_get";
		var windowFeatures = "depedent=yes, scrollbars=no, resizable=yes, toolbar=no, location=no, menubar=no, height=400, width=550";
		newWin = window.open(url, windowName, windowFeatures);
	}
	
</script>
<style type="text/css">
a {
	outline: none;
}
ul#tabnav2 {
	text-align: right; 
	margin: 5px 0 0;
	padding: 3px 0;	
	list-style-type: none;
	border-bottom:2px solid #666666;
}

ul#tabnav2 li { 
	display: inline;
}

#tabnav2 li a.active  { 
	background-color: #666666; 
	color: #ffffff; 
	position: relative;
	top: 1px;
	padding-top: 4px; 	
}

ul#tabnav2 li a { 
	padding: 3px 15px; 
	border: 1px solid #666666; 
	background-color: #F1F1F1; 
	color: #9F9E9E; 
	margin-right: 0px; 
	text-decoration: none;
	border-bottom: none;
	font-size: 13px;
	font-weight:normal;
	border-radius: 5px 5px 0 0;
	font-family:Arial;
	font-size:12px;
}
.ul#tabnav2 li a:hover {
	text-decoration:none;
	color:#000000;
}
.noClassPassiveTab {
	border:none !important;
	color:#666666 !important;
}
#hoverover {
	position:relative;
}
#periodSelector, #periodSelectorMonth {
	background-color: #666666;
    color: #DDDDDD;
    padding: 5px;
	display:none;
}
#periodSelector a, #periodSelectorMonth a {
	color: #FFFFFF;
    font-family: arial;
    font-size: 11px;
    font-weight: bold;
    padding-left: 2px;
    padding-right: 2px;
    text-decoration: none;
}
.scrollgeneric {
    font-size: 1px;
    line-height: 1px;
    position: absolute;
	cursor: pointer;
	border-radius: 5px 5px 5px 5px;
}
.vscrollerbase, .vscrollerbar {
    top: 0;
    width: 5px;
}
.vscrollerbarbeg {
    height: auto;
    top: 0;
    width: 5px;
}
.vscrollerbasebeg {
    top: 0;
    width: 5px;
}
.scrollerjogbox {
    bottom: 0;
    right: 0;
    width: 5px;
}
.vscrollerbase {
    background: none repeat scroll 0 0 #dddddd;
    width: 5px;
}
 .vscrollerbar {
    background-color: #8F9793;
    padding: 0;
	padding: 5px;
    z-index: 2;
	left: 0;
}

#revo-dashboard {
	width:860px;
}	
</style>
</head>
<body topmargin="7" leftmargin="2" marginheight="2" marginwidth="0">
 
<%
ConnectionPool		cp				= null;
Connection			conn 			= null;
Statement			stmt			= null;
ResultSet			rs				= null; 

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("welcome.jsp");
	stmt = conn.createStatement();

	String sClassAppend = "";
	String sSql = "";
	
	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;
	if (sSelectedCategoryId == null) sSelectedCategoryId = "0";
	
	String	campaignType			= "Error";

	int		curPage					= 1;
	int		amount					= 5;
	
	int		hasSeenAdminNote		= 0;

	int		hasUserNotesAccess		= 0;
	int		hasAdminNotesAccess		= 1;
	
	String	sNoteId					= null;
	String	sParentId				= cSuper.s_cust_id;
	String	sNoteCustId				= cSuper.s_cust_id;
	Customer cNote 					= null;
	
	sSql = "EXEC usp_ccps_cust_parent_chain_get @cust_id = " + cSuper.s_cust_id;
	rs = stmt.executeQuery(sSql);

	while (rs.next())
	{
		sParentId = rs.getString(1);
	}
	rs.close();
	
		AccessPermission canNote = user.getAccessPermission(ObjectType.USER_NOTES);
		AccessPermission canCamp = user.getAccessPermission(ObjectType.CAMPAIGN);
		AccessPermission canRept = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);
		AccessPermission canCont = user.getAccessPermission(ObjectType.CONTENT);
		
		String campClass = "Tab_ON";
		String reptClass = "Tab_OFF";
		String contClass = "Tab_OFF";
		
		int hasAssetAccess = 1;
		int showCamp = 0;
		int showRept = 0;
		int showCont = 0;
		
		if (canCamp.bRead)
		{
			campClass = "Tab_ON";
			reptClass = "Tab_OFF";
			contClass = "Tab_OFF";
			showCamp = 1;
		}
		else if (canRept.bRead)
		{
			campClass = "Tab_OFF";
			reptClass = "Tab_ON";
			contClass = "Tab_OFF";
			showRept = 1;
		}
		else if (canCont.bRead)
		{
			campClass = "Tab_OFF";
			reptClass = "Tab_OFF";
			contClass = "Tab_ON";
			showCont = 1;
		}
		else
		{
			hasAssetAccess = 0;
			campClass = "Tab_OFF";
			reptClass = "Tab_OFF";
			contClass = "Tab_OFF";
		}	


%>
	
<style type="text/css">
a {
	outline: none;
}
</style>

	<div id="revo-dashboard">
		
		<div style="width:460px;float:left;margin-right:2px;">
		
			<div style="margin-bottom:2px;">
				<div style="width:100%;border-bottom:2px solid #666666;">
					<span href="" style="background-color: #666666;border-left: 1px solid #666666;border-radius: 3px 3px 0 0;border-right: 1px solid #666666;border-top: 1px solid #666666;color: #FFFFFF;display: block;float: left;font-family: arial;font-size: 12px;margin-right: 3px;padding: 5px;text-decoration: none;">Dashboard</span>
					<span href="" style="font-size:11px;display:block;color: #bdbdbd;float: left;margin-left: 5px;margin-top: 7px;text-decoration: none;">Graph by:</span>
					<a id="hoverover" href="javascript:void(0);" style="display:block;margin-right: 5px;color: #666666;float: left;margin-left: 5px;margin-top: 7px;text-decoration: none;"><img src="/cms/ui/images/dbweek.png" border="0"/> <span>Week</span>					
					</a>
					<a id="hoveroverMonth" href="javascript:void(0);" style="display:block;color: #666666;float: left;margin-left: 5px;margin-top: 7px;text-decoration: none;"><img src="/cms/ui/images/dbmonth.png" border="0"/> <span>Month</span></a>
					<div style="clear:both;"></div>
				</div>

				<div id="periodSelector">
						Show me last 
						<a href="javascript:void(0);" onclick="graphBy('week',false,1);">1</a> 
						<a href="javascript:void(0);" onclick="graphBy('week',false,2);">2</a> 
						<a href="javascript:void(0);" onclick="graphBy('week',false,3);">3</a> 
						<a href="javascript:void(0);" onclick="graphBy('week',false,4);">4</a> Week(s)
				</div>
				
				<div id="periodSelectorMonth">
						Show me last 
						<a href="javascript:void(0);" onclick="graphBy('month',false,1);">1</a> 
						<a href="javascript:void(0);" onclick="graphBy('month',false,2);">2</a> 
						<a href="javascript:void(0);" onclick="graphBy('month',false,3);">3</a> 
						<a href="javascript:void(0);" onclick="graphBy('month',false,4);">4</a> Month(s)
				</div>
					
				<div style="height: 150px;background-color:#FFFFFF;border-left:1px solid #DDDDDD;border-right:1px solid #DDDDDD;border-bottom:1px solid #DDDDDD;padding:5px;">
					<div id="chart_div" style="height: 150px;width:440px;"><span style='display: block;font-size: 12px;margin: 10px 0;text-align: center;'><img src="/cms/ui/images/smallloader.gif"/><br>Loading chart.. <br> This may take a few seconds.</span></div>
				</div>
			</div>
			
			<div style="margin-bottom:10px;background-color:#FFFFFF;border:1px solid #DDDDDD;padding:5px;">
				<div style="float:left;width:250px;">
					 <div id="chart_div2" style="height: 250px;width: 250px;"><span style='display: block;font-size: 12px;margin: 80px 0;text-align: center;'><img src="/cms/ui/images/smallloader.gif"/><br>Loading chart.. <br> This may take a few seconds.</span></div>
				</div>
				<div style="float:left;width:180px">					
					<table cellpadding="4" cellspacing="0" width="100%">
						<tr>
							<td width="16"><img src='/cms/ui/images/db_icon&16.png'/></td>
							<td style="border-bottom:1px solid #f1f0f0;">
								<div style="font-size:14px;font-family:Arial;color:#3c3c3c;margin-bottom:3px;">Total Database Size</div>
								<div>
									<span id="include1" style="font-size:16px;font-family:Arial;font-weight:bold;color:#000000">
										<img src="/cms/ui/images/smallloader.gif"/> 
									</span>
									<span id="include11" style="font-size:12px;font-family:Arial;color:#666666;">Emails</span>
								</div>
							</td>
						</tr>
						<tr>
							<td><img src='/cms/ui/images/flag_2_icon&16.png'/></td>
							<td style="border-bottom:1px solid #f1f0f0">
								<div style="font-size:14px;font-family:Arial;color:#3c3c3c;margin-bottom:3px;">Unsubscriptions</div>
								<div>
									<span id="include2" style="font-size:16px;font-family:Arial;font-weight:bold;color:#aa4643">
										<img src="/cms/ui/images/smallloader.gif"/> 
									</span>
									<span id="include22" style="font-size:12px;font-family:Arial;color:#2b2b2b;"></span>
								</div>
							</td>
						</tr>
						<tr>
							<td><img src='/cms/ui/images/disconnected_icon&16.png'/></td>
							<td style="border-bottom:1px solid #f1f0f0">
								<div style="font-size:14px;font-family:Arial;color:#3c3c3c;margin-bottom:3px;">Bouncebacks</div>
								<div>
									<span id="include3" style="font-size:16px;font-family:Arial;font-weight:bold;color:#4d4e50">
										<img src="/cms/ui/images/smallloader.gif"/> 
									</span>
									<span id="include33" style="font-size:12px;font-family:Arial;color:#2b2b2b;"></span>
								</div>
							</td>
						</tr>
						<tr>
							<td><img src='/cms/ui/images/round_checkmark_icon&16.png'/></td>
							<td style="border-bottom:1px solid #f1f0f0">
								<div style="font-size:14px;font-family:Arial;color:#3c3c3c;margin-bottom:3px;">Currently Active</div>
								<div>
									<span id="include4" style="font-size:16px;font-family:Arial;font-weight:bold;color:#89a54e">
										<img src="/cms/ui/images/smallloader.gif"/> 
									</span>
									<span id="include44" style="font-size:12px;font-family:Arial;color:#2b2b2b;"></span>
								</div>
							</td>
						</tr>
						<tr>
							<td><img src='/cms/ui/images/facebook_icon&16.png'/></td>
							<td style="border-bottom:1px solid #f1f0f0">
								<div style="font-size:14px;font-family:Arial;color:#3c3c3c;margin-bottom:3px;">Facebook Fans</div>
								<div id="fblikes">
										<img src="/cms/ui/images/smallloader.gif"/> 
								</div>
							</td>
						</tr>
						<tr>
							<td><img src='/cms/ui/images/twitter_2_icon&16.png'/></td>
							<td>
								<div style="font-size:14px;font-family:Arial;color:#3c3c3c;margin-bottom:3px;">Twitter</div>
								<div id="twfollowers">
									<img src="/cms/ui/images/smallloader.gif"/> 
									
								</div>
							</td>
						</tr>
					</table>
					
				</div>
				<div style="clear:both;"></div>
			</div>
			<div>
					<!-- recent assets start-->
						<%
							if (hasAssetAccess == 1)
							{
								%>
								<div id="info">
							<div id="xsnazzy">

							<div>
								<ul id="tabnav2">
									<% if (canRept.bRead) { %><li><a id="tab1_Step2" class="noClassPassiveTab" onclick="toggleTabs('tab1_Step','block1_Step',2,3,'active','noClassPassiveTab');" href="javascript:void(0)">Reports</a></li><% } %>
									<% if (canCont.bRead) { %><li><a id="tab1_Step3" class="noClassPassiveTab" href="javascript:void(0)" onclick="toggleTabs('tab1_Step','block1_Step',3,3,'active','noClassPassiveTab');">Content</a></li><% } %>
									<% if (canCamp.bRead) { %><li><a id="tab1_Step1" class="active" onclick="toggleTabs('tab1_Step','block1_Step',1,3,'active','noClassPassiveTab');" href="javascript:void(0)">Campaigns</a></li><% } %>
								</ul>				
								
								<table cellspacing="0" class=listTable cellpadding="0" width="100%" border="0">
									<tr>
										<td class="listHeading" style="padding:0;border-top:0" valign="center" nowrap align="left">
											
											<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=100% border=0>
												
												
											<%
											String s_origin_camp_id;
											String s_camp_id;
											String s_camp_name;
											String s_status_id;
											String s_status_name;
											String s_type_id;
											String s_type_id_name;
											String s_filter_name;
											String s_cont_name;
											String s_created_date;
											String s_modified_date;
											String s_start_date;
											String s_finish_date;
											String d_created_date;
											String d_modified_date;
											String d_start_date;
											String d_finish_date;
											String s_qty_queued;
											String s_qty_sent;
											String s_approval_flag;
											String s_queue_daily_flag;
											String s_sample_qty;
											String s_sample_qty_sent;
											String s_final_flag;

											if(canCamp.bRead)
											{
												%>
												<tbody class=EditBlock id=block1_Step1<%= (showCamp==0)?" style=\"display:none;\"":"" %>>
												<tr>
													<td valign=top align=left colspan=4 style="border-top:none;">
														
														
														<%
															int recAmount = 0;

															sSql = "EXEC usp_cque_camp_list_get_all 4" + 
																"," + cust.s_cust_id +
																"," + sSelectedCategoryId +
																",2";
																
															rs = stmt.executeQuery(sSql);
															
															int campCount = 0;

															while( rs.next() )
															{
																if (campCount == 0)
																{
																	%>
														<table class="table-soft" cellpadding="0" cellspacing="0" border="0" width="100%">
															<tr>
																<th class="subsectionheader" valign="middle">Campaigns</th>
																<th class="subsectionheader" valign="middle">Status</th>
																<th class="subsectionheader" valign="middle">Type</th>
															</tr>
																	<%
																}
																
																if (campCount % 2 != 0) sClassAppend = "_Alt";
																else sClassAppend = "";
																
																campCount++;
																
																s_origin_camp_id	= rs.getString(1);
																s_camp_id			= rs.getString(2);
																s_camp_name			= new String(rs.getBytes(3), "UTF-8");
																s_status_id			= rs.getString(4);
																s_status_name		= rs.getString(5);
																s_type_id			= rs.getString(6);
																s_type_id_name		= rs.getString(7);
																s_filter_name		= new String(rs.getBytes(8), "UTF-8");
																s_cont_name			= new String(rs.getBytes(9), "UTF-8");
																d_created_date		= rs.getString(10);
																d_modified_date		= rs.getString(11);
																d_start_date		= rs.getString(12);
																d_finish_date		= rs.getString(13);
																s_created_date		= rs.getString(14);
																s_modified_date		= rs.getString(15);
																s_start_date		= rs.getString(16);
																s_finish_date		= rs.getString(17);
																s_qty_queued		= rs.getString(18);
																s_qty_sent			= rs.getString(19);
																s_approval_flag		= rs.getString(20);
																s_queue_daily_flag	= rs.getString(21);
																s_sample_qty		= rs.getString(22);
																s_sample_qty_sent	= rs.getString(23);
																s_final_flag		= rs.getString(24);
																%>
															<tr>
																<td class="listItem_Data<%= sClassAppend %>"><a target="_top" href="../index.jsp?tab=Camp&sec=1&url=<%= URLEncoder.encode("camp/camp_edit.jsp?camp_id=" + s_origin_camp_id + "&type_id=2","UTF-8") %>" target"=_self"><%= s_camp_name %></a></td>
																<td class="listItem_Title<%= sClassAppend %>"><%= s_status_name %></td>
																<td class="listItem_Data<%= sClassAppend %>">(<%= s_type_id_name %>)</td>
															</tr>
																<%
															}
															rs.close();
																
															if (campCount == 0)
															{
																%>
														<table class="table-soft" cellpadding="2" cellspacing="0" border="0" width="100%">
															<tr>
																<th class="subsectionheader" valign="middle" width="50%">Campaigns</th>
																<th class="subsectionheader" valign="middle" width="25%">Status</th>
																<th class="subsectionheader" valign="middle" width="25%">Type</th>
															</tr>
																<%
															}
																recAmount = 0;

																sSql =
																	"EXEC usp_cque_camp_list_get_all 5" + 
																	"," + cust.s_cust_id +
																	"," + sSelectedCategoryId +
																	",2";
																rs = stmt.executeQuery(sSql);

																//campCount = 0;

																s_origin_camp_id	= null;
																s_camp_id			= null;
																s_camp_name			= null;
																s_status_id			= null;
																s_status_name		= null;
																s_type_id			= null;
																s_type_id_name		= null;
																s_filter_name		= null;
																s_cont_name			= null;
																d_created_date		= null;
																d_modified_date		= null;
																d_start_date		= null;
																d_finish_date		= null;
																s_created_date		= null;
																s_modified_date		= null;
																s_start_date		= null;
																s_finish_date		= null;
																s_qty_queued		= null;
																s_qty_sent			= null;
																s_approval_flag		= null;
																s_queue_daily_flag	= null;
																s_sample_qty		= null;
																s_sample_qty_sent	= null;
																s_final_flag		= null;
																		
																sClassAppend = "";

																while( rs.next() )
																{
																	if (campCount % 2 != 0) sClassAppend = "_Alt";
																	else sClassAppend = "";
																	
																	campCount++;
																	recAmount++;
																	
																	s_origin_camp_id	= rs.getString(1);
																	s_camp_id			= rs.getString(2);
																	s_camp_name			= new String(rs.getBytes(3), "UTF-8");
																	s_status_id			= rs.getString(4);
																	s_status_name		= rs.getString(5);
																	s_type_id			= rs.getString(6);
																	s_type_id_name		= rs.getString(7);
																	s_filter_name		= new String(rs.getBytes(8), "UTF-8");
																	s_cont_name			= new String(rs.getBytes(9), "UTF-8");
																	d_created_date		= rs.getString(10);
																	d_modified_date		= rs.getString(11);
																	d_start_date		= rs.getString(12);
																	d_finish_date		= rs.getString(13);
																	s_created_date		= rs.getString(14);
																	s_modified_date		= rs.getString(15);
																	s_start_date		= rs.getString(16);
																	s_finish_date		= rs.getString(17);
																	s_qty_queued		= rs.getString(18);
																	s_qty_sent			= rs.getString(19);
																	s_approval_flag		= rs.getString(20);
																	s_queue_daily_flag	= rs.getString(21);
																	s_sample_qty		= rs.getString(22);
																	s_sample_qty_sent	= rs.getString(23);
																	s_final_flag		= rs.getString(24);

																	//Page logic
																	if ((recAmount <= (curPage-1)*amount) || (recAmount > curPage*amount)) continue;
																	%>
																<tr>
																	<td class="listItem_Data<%= sClassAppend %>"><a target="_top" href="../index.jsp?tab=Camp&sec=1&url=<%= URLEncoder.encode("camp/camp_edit.jsp?camp_id=" + s_origin_camp_id + "&type_id=2","UTF-8")%>" target"=_self"><%= s_camp_name %></a></td>
																	<td class="listItem_Title<%= sClassAppend %>"><%= s_status_name %></td>
																	<td class="listItem_Data<%= sClassAppend %>">(<%= s_type_id_name %>)</td>
																</tr>
																	<%
																}
																rs.close();
																%>
															<% if (campCount == 0) { %>
																<tr>
																	<td class="listItem_Title" colspan="3" align="left" valign="middle">There are currently no draft campaigns being worked on</td>
																</tr>
															<% } %>
															
														</table>
														
													</td>
												</tr>
												</tbody>
												<%
											}
											
											if(canRept.bRead)
											{
												%>
												<tbody class=EditBlock id=block1_Step2<%= (showRept==0)?" style=\"display:none;\"":"" %>>
												<tr>
													<td valign=top align=left colspan=4>
														
														<table class="table-soft" cellpadding="0" cellspacing="0" border="0" width="100%">
															<tr>
																<th class="subsectionheader" valign="middle" width="75%">Reports</th>
																<th class="subsectionheader" valign="middle" width="25%">Status</th>
															</tr>
												<%
												sSql = "EXEC usp_crpt_camp_list @cust_id=" + cust.s_cust_id + "";

												if (sSelectedCategoryId!=null)
													sSql +=",@category_id=" + sSelectedCategoryId;
												
												int reportCount = 0;

												if (stmt.execute(sSql))
												{
													rs = stmt.getResultSet();
													while (rs.next())
													{
														//if (rs.getString(11).equals("Complete"))
														//{
															if (reportCount % 2 != 0)
															{
																sClassAppend = "_Alt";
															}
															else
															{
																sClassAppend = "";
															}
															
															++reportCount;
															if ((reportCount <= (curPage-1)*amount) || (reportCount > curPage*amount)) continue;
															%>
															<tr>
																<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle"><a target="_top" href="../index.jsp?tab=Rept&sec=1&url=<%= URLEncoder.encode("report/report_redirect.jsp?act=VIEW&id=" + rs.getString("Id"),"UTF-8") %>"><%= new String(rs.getBytes("CampName"), "UTF-8") %></a></td>
																<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle"><%= rs.getString("UpdateStatus") %></td>
															</tr>
															<%
														//}
													}
													rs.close();
												}
												
												if (reportCount == 0)
												{
													%>
															<tr>
																<td class="listItem_Title" colspan="3" align="left" valign="middle">There are currently no Reports</td>
															</tr>
													<%
												}
												%>
														</table>
													</td>
												</tr>
												</tbody>
												<%
											}
											
											if(canCont.bRead)
											{
												%>
												<tbody class=EditBlock id=block1_Step3<%= (showCont==0)?" style=\"display:none;\"":"" %>>
												<tr>
													<td valign=top align=left colspan=4>
														
														
														<table class="table-soft" cellpadding="0" cellspacing="0" border="0" width="100%">
															<tr>
																<th class="subsectionheader" valign="middle" width="75%">Content</th>
																<th class="subsectionheader" valign="middle" width="25%">Modified Date</th>
															</tr>
														<%
														int contCount = 0;
														
														sSql = "Exec dbo.usp_ccnt_list_get @type_id="+ContType.CONTENT+", @CustomerId="+cust.s_cust_id;
														if (sSelectedCategoryId != null) sSql += ",@category_id="+sSelectedCategoryId;
														
														rs = stmt.executeQuery(sSql);

														String contID = "";
														
														while (rs.next())
														{
															if (contCount % 2 != 0)
															{
																sClassAppend = "_Alt";
															}
															else
															{
																sClassAppend = "";
															}
															
															++contCount;

															//Top 5 logic
															if (contCount <= (curPage-1)*amount) continue;
															else if (contCount > curPage*amount) continue;
															
															contID = rs.getString(1);
															%>
															<tr>
																<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle"><a target="_top" href="../index.jsp?tab=Cont&sec=1&url=<%= URLEncoder.encode("cont/cont_edit.jsp?cont_id=" + contID,"UTF-8") %>"><%= new String(rs.getBytes(2),"UTF-8") %></a></td>
																<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle" nowrap><%= rs.getString(5) %></td>
															</tr>
															<%
														}
														rs.close();
														
														if (contCount == 0)
														{
															%>
															<tr>
																<td class="listItem_Title" colspan="2" align="left" valign="middle">There is currently no Content</td>
															</tr>
															<%
														}
														%>
														</table>
													</td>
												</tr>
												</tbody>
												<%
											}
											%>
											</table>
										</td>
									</tr>
									<tr>
									<td>
										<% if (canCamp.bRead) { %><a target="_top" class="subactionbutton" href="../index.jsp?tab=Camp&sec=1" title="View All Campaigns">All Campaigns</a><% } %>
										<% if (canRept.bRead) { %><a target="_top" class="subactionbutton" href="../index.jsp?tab=Rept&sec=1">All Reports</a><% } %>
										<% if (canCont.bRead) { %><a target="_top" class="subactionbutton" href="../index.jsp?tab=Cont&sec=1" title="View All Content">All Content</a><% } %>
									</td>
									</tr>
								</table>
								
								</div>

							</div>			
							</div>
								<%
							}
							%>
					<!-- recent assets end -->
			</div>
		</div>
		
		
		<div style="float:left;width:385px;">			
			
			<ul id="tabnav2">
				<li><a href="javascript:void(0);" class="active" id="tab2_Step1" onclick="toggleTabs('tab2_Step','block2_Step',1,2,'active','noClassPassiveTab');">Announcements</a></li>
				<li><a href="javascript:void(0);" class="noClassPassiveTab" id="tab2_Step2" onclick="toggleTabs('tab2_Step','block2_Step',2,2,'active','noClassPassiveTab');"><span>User Notes</span></a></li>
			</ul>
			
					
					<%
					String sRequest = new String("<request><note_id></note_id></request>");
					String sResponse = Service.communicate(ServiceType.SADM_SYSTEM_NOTE_INFO, cust.s_cust_id, sRequest);      
					Element eRoot = XmlUtil.getRootElement(sResponse);        
					if (eRoot != null && !eRoot.getTagName().toUpperCase().equals("ERROR"))
					{
						sNoteId = XmlUtil.getChildTextValue(eRoot, "note_id");			
						/** system note**/ 

								if (sNoteId != null)
								{
									String sRequest2 = new String("<request><note_id>"+sNoteId+"</note_id></request>");
									String sResponse2 = Service.communicate(ServiceType.SADM_SYSTEM_NOTE_INFO, cust.s_cust_id, sRequest2);      
									
									Element eRoot2 = XmlUtil.getRootElement(sResponse2);        
									
									if (eRoot2 != null && !eRoot2.getTagName().toUpperCase().equals("ERROR"))
									{
										String s_note_id = XmlUtil.getChildTextValue(eRoot2, "note_id");
										String s_modify_date = XmlUtil.getChildTextValue(eRoot2, "modify_date");
										String s_subject = XmlUtil.getChildTextValue(eRoot2, "subject");
										String s_body = XmlUtil.getChildCDataValue(eRoot2, "body");
										%>
										<div id="block2_Step1" style="background-color:#FFFFFF;border-left:1px solid #DDDDDD;border-right:1px solid #DDDDDD;">
										<table cellpadding="0" style="width:100% !important;width:99.5%;" cellspacing="0" class="welcome-boxes">
											<tr>
												<td>
													<div style="height:200px;overflow:auto;" class="flexcroll">
														<div><%= s_subject %></div>
														<div><%= s_body %></div>
													</div>
													<div style="margin-top: 5px;">
														<a href="javascript:loadSysNote('<%= sNoteId %>');" class="button_res">Read More</a>
														<a href="javascript:loadSysAnnounce();" class="button_res">Past Announcements</a>
													</div>
												</td>
											</tr>
										</table>
										</div>
										<%
									}
								}
								else
								{
									%>
										<div id="block2_Step1" style="background-color:#FFFFFF;border-left:1px solid #DDDDDD;border-right:1px solid #DDDDDD;">
										<table cellpadding="0" cellspacing="0" width="100%" class="welcome-boxes">
											<tr bgcolor="#696969">
												<th>Announcement</th>
											</tr>
											<tr>
												<td>There are currently no system notices</td>
											</tr>
										</table>
										</div>
									<%
								}

						
						/*** system note */
						sNoteId = null;
					}
					else
					{
						if (hasAdminNotesAccess == 1)
						{
							sSql = "SELECT TOP 1 note_id, cust_id FROM chom_user_note WHERE (cust_id = '" + sParentId + "' OR cust_id = '" + cSuper.s_cust_id + "') AND admin=1 AND published = 1 ORDER BY cust_id, modify_date DESC";
							rs = stmt.executeQuery(sSql);

							if (rs.next())
							{
								sNoteId = rs.getString(1);
								sNoteCustId = rs.getString(2);
							}
							rs.close();
							
							if (sNoteId != null)
							{
								hasSeenAdminNote = 1;
								cNote = new Customer(sNoteCustId);
								%>
					
								
								<table cellspacing="0" cellpadding="0" width="100%" border="0">
									<tr>
										<td class="listHeading" valign="center" nowrap align="left">
											<%= cNote.s_cust_name %> Announcement
											<br><br>
											<iframe src="admin_note_get.jsp?note_id=<%= sNoteId %>&win=false" name=usernotebox width="100%" height="145" scrolling="no" frameborder="0">
											[Your user agent does not support frames or is currently configured]
											</iframe>
										</td>
									</tr>
								</table>
								
								
								<%
							}
						}
					}

					
					%>
					</td>
					<td align="left" valign="top">
						<%
						if(hasAdminNotesAccess == 1)
						{
							if (hasSeenAdminNote == 0)
							{
								sNoteId = null;
								sSql = "SELECT TOP 1 note_id, cust_id FROM chom_user_note WHERE (cust_id = '" + sParentId + "' OR cust_id = '" + cSuper.s_cust_id + "') AND admin=1 AND published = 1 ORDER BY cust_id, modify_date DESC";
								rs = stmt.executeQuery(sSql);

								if (rs.next())
								{
									sNoteId = rs.getString(1);
									sNoteCustId = rs.getString(2);
								}
								rs.close();
								
								if (sNoteId != null)
								{
									cNote = new Customer(sNoteCustId);
									%>
									<table cellspacing="0" cellpadding="0" width="100%" border="0">
										<tr>
											<td class="listHeading" valign="center" nowrap align="left">
												<%= cNote.s_cust_name %> Announcement
												<br><br>
												<iframe src="admin_note_get.jsp?note_id=<%= sNoteId %>&win=false" name=usernotebox width="100%" height="225" scrolling="no" frameborder="0">
												[Your user agent does not support frames or is currently configured]
												</iframe>
											</td>
										</tr>
									</table>
									
									<%
								}
							}
							%>
						<!--<table cellspacing="0" cellpadding="0" width="100%" border="0">
							<tr>
								<td class="listHeading" valign="center" nowrap align="left">
									Recent Admin Notes
									<br><br>
									<table cellspacing="0" cellpadding="0" width="100%" border="0">
										<tr>
											<td>
												<table class="listTable" cellpadding="2" cellspacing="0" border="0" width="100%">
													<tr>
														<th class="subsectionheader" align="left" valign="middle">Subject</th>
														<th class="subsectionheader" align="left" valign="middle" nowrap>User</th>
														<th class="subsectionheader" align="left" valign="middle" nowrap>Modified Date</th>
													</tr>
							<%
							if (sNoteId == null)
							{
								sNoteId = "-999"; 
							}
							
							sSql = "EXEC usp_chom_user_note_list_get_published @cust_id=" + cust.s_cust_id + ",@admin=1,@exclude_id="+ sNoteId;
							
							int iCount = 0;
							rs = stmt.executeQuery(sSql);
							
							String sId = "";
							String sSubj = "";
							String sUserID = "";
							String sUser = "";
							String dDate = "";
							String sDate = "";

							while (rs.next())
							{
								
								if (iCount % 2 != 0) sClassAppend = "_Alt";
								else sClassAppend = "";
								
								++iCount;

								sId = rs.getString(1);
								sSubj = rs.getString(2);
								sUserID = rs.getString(3);
								sUser = rs.getString(4);
								dDate = rs.getString(5);
								sDate = rs.getString(6);
								
								if ((iCount <= (curPage-1)*amount) || (iCount > curPage*amount)) continue;
								%>
													<tr>
														<td class="listItem_Title<%= sClassAppend %>" align="left" valign="middle" width="50%"><a href="javascript:loadAdminNote('<%= sId %>');"><%= sSubj %></a></td>
														<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle" width="25%" nowrap><%= sUser %></td>
														<td class="listItem_Data<%= sClassAppend %>" align="left" valign="middle" width="25%" nowrap><%= sDate %></td>
													</tr>
								<%
							}
							rs.close();
							
							if (iCount == 0)
							{
								%>
													<tr>
														<td class="listItem_Data" colspan="3">There are currently no Admin Notes</td>
													</tr>
								<%
							}
							%>
												</table>
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
						<br>//-->
							<%
						}
						%>
						
						
						<!-- USER NOTES START -->
								<%
					if (canNote.bRead)
					{
						hasUserNotesAccess = 1;            
					%>
					<style>
						.welcome-boxes {
							border-collapse:collapse;
							font-family:arial;
							font-size:12px;
						}
						.welcome-boxes td {
							border-bottom:1px solid #DDDDDD;
							padding:5px;
							font-family: arial;
							font-size: 12px;
							background-color:#FFFFFF;
							color:#343434;
							line-height:18px;
						}
						.welcome-boxes th {
							color: #666666;
							font-family: arial;
							font-size: 13px;
							font-weight: normal;
							padding: 5px;
						}
					
					</style>
					<div id="block2_Step2" style="display:none;background-color:#FFFFFF;border-left:1px solid #DDDDDD;border-right:1px solid #DDDDDD;">
					<table cellpadding="0" cellspacing="0" width="100%" class="welcome-boxes">
						<tr bgcolor="#696969">
							<th>Subject</th>
							<th>User</th>
							<th>Modified Date</th>
						</tr>
						<%
								
								sSql = "EXEC usp_chom_user_note_list_get_published @cust_id=" + cust.s_cust_id + ",@admin=0,@exclude_id="+ sNoteId;
								
								int iCount = 0;
								rs = stmt.executeQuery(sSql);
								
								String sId = "";
								String sSubj = "";
								String sUserID = "";
								String sUser = "";
								String dDate = "";
								String sDate = "";

								while (rs.next())
								{
									
									if (iCount % 2 != 0) sClassAppend = "_Alt";
									else sClassAppend = "";
									
									++iCount;

									sId = rs.getString(1);
									sSubj = rs.getString(2);
									sUserID = rs.getString(3);
									sUser = rs.getString(4);
									dDate = rs.getString(5);
									sDate = rs.getString(6);
									
									if ((iCount <= (curPage-1)*amount) || (iCount > curPage*amount)) continue;
									%>
										<tr>
											<td class="listItem_Title<%= sClassAppend %>" align="left"><a href="javascript:loadUserNote('<%= sId %>');"><%= sSubj %></a></td>
											<td class="listItem_Data<%= sClassAppend %>" align="left"><%= sUser %></td>
											<td class="listItem_Data<%= sClassAppend %>" align="left"><%= sDate %></td>
										</tr>
									<%
								}
								rs.close();
								
								if (iCount == 0)
								{
									%>
										<tr>
											<td class="listItem_Data" colspan="3" align="left" valign="middle">There are currently no User Notes</td>
										</tr>
									<%
								}
								%>
					</table>
					</div>
								
							

				
			<%
			}
			%>
						<!-- USER NOTES END -->
						
						
						
		<!-- Social box start -->
		<ul id="tabnav2">
			<li><a href="javascript:void(0);" class="active" id="tab5_Step1" onclick="toggleTabs('tab5_Step','block5_Step',1,2,'active','noClassPassiveTab');">Facebook</a></li>
			<li><a href="javascript:void(0);" class="noClassPassiveTab" id="tab5_Step2" onclick="toggleTabs('tab5_Step','block5_Step',2,2,'active','noClassPassiveTab');"><span>Twitter</span></a></li>
		</ul>
		<div id="socialcontainer" style="border-bottom:1px solid #dddddd;border-left:1px solid #dddddd;border-right:1px solid #dddddd;background-color:#FFFFFF;margin-bottom:5px;padding:10px;">
			
			<img src='/cms/ui/images/smallloader.gif'></br>
			Loading Timeline, this may take a few seconds.
		</div>
		
		<!-- Social box end -->
		
		</div>
		<div style="clear:both;"></div>
	
	</div>	
		
	<!-- new dash board end -->
	
<%
}
catch(Exception ex)
{ 
	//ErrLog.put(this,ex,"welcome.jsp",out,1);
	throw new Exception(ex);
}
finally
{
	try { if (stmt != null) stmt.close(); }
	catch(Exception e) {}
	if (conn != null) cp.free(conn);
}
%>
</body>
</html>

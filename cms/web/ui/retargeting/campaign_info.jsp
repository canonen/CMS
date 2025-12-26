<%@ page language="java"
         import="org.json.JSONObject,
                 com.restfb.json.JsonArray,
                 com.facebook.ads.sdk.AdAccount"
 
         contentType="text/html;charset=UTF-8"%>
         
         <%
         
         String audience_id=request.getParameter("audience_id");
         String account_id =request.getParameter("account_id");
         if(audience_id==null || account_id==null)
             return;
         
         %>
 
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title>Ads Report</title>
<meta
	content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no"
	name="viewport">
<link rel="stylesheet" href="assets/css/bootstrap.min.css">

<link rel="stylesheet" href="assets/css/font-awesome.min.css">

<link rel="stylesheet" href="assets/css/ionicons.min.css">

<link rel="stylesheet" href="assets/css/AdminLTE.css">
<link rel="stylesheet" href="assets/css/Style.css">

<link rel="stylesheet" href="assets/css/skin-blue.min.css">
<link rel="stylesheet"
	href="assets/css/DataTable/dataTables.bootstrap.min.css">
<link rel="stylesheet"
	href="assets/css/daterangepicker/daterangepicker.css">
<!--[if lt IE 9]>
  <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
  <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
  <![endif]-->

<link rel="stylesheet"
	href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700,300italic,400italic,600italic">

<style>
#chartLegend table {
	margin-left: auto;
	margin-right: auto;
}

#chartLegend {
	text-align: center;
}

#chartLegend-mounth table {
	margin-left: auto;
	margin-right: auto;
}

#chartLegend-mounth {
	text-align: center;
}

#chartLegend-all table {
	margin-left: auto;
	margin-right: auto;
}

#chartLegend-all {
	text-align: center;
}

.ui-datepicker-calendar {
	display: none !important;
}
</style>
</head>
<body>
  <div class="box-header" style="margin-left: 10px;">
		<h3 class="box-title">
			<b>CRM Ads</b>
		</h3>
	</div>

	<div class="wrapper" style="margin-left: 20px; margin-right: 20px;">
		<div class="row">

			<div class="col-md-12">

				<div class="box box-primary">
					<div class="box-header">
						<h3 class="box-title" id="audience-name">e</h3>

				</div>
				
	<div class="panel panel-default">	
	<br>	
				<div class="row" style="padding-left: 10px">	
					<div class="col-xs-4">
					<label>Campaign Select</label> 
					<div class="form-group"> 
					<select style="margin-left: 5px" id="campaign-list">
					
					</select>
					</div>
					</div>
					<div class="col-xs-4">
					<label>Date Range</label>
						<div class="form-group">
						<div class="input-group">
						 <div class="input-group-addon">
							<i class="fa fa-calendar"></i>
							</div>
						
						<input type="text" name="date_range" class="form-control pull-right" id="date_range">
							</div>
						</div>
					</div>
				</div>
				</div>


				</div>
				

			</div>
			<!-- md-12 END !-->

		</div>
		<div class="panel panel-default">	
		<div class="row">
		    <div class="col-md-3">
                <div class="row">
                    <div class="col-md-12">
                        <span style="float:left;">Impressions</span>
                        <span style="float:right;font-size: 17px;color: #2727c3;" id="impressions"></span>
                    </div>   
                </div>
                <div class="row">
                    <div class="col-md-12">
                        <span style="float:left;">Revenue</span>
                        <span style="float:right;font-size: 17px;color: #2727c3;" id="revenueperconv"></span>
                    </div>   
                </div>
                <div class="row">
                    <div class="col-md-12">
                        <span style="float:left;">Cost</span>
                        <span style="float:right;font-size: 17px;color: #2727c3;" id="cost"></span>
                    </div>   
                </div>
		    </div>
		    <div class="col-md-3" style="border-left: 1px solid #e6e6e6;border-right: 1px solid #e6e6e6;">
		        <div class="row">
                    <div class="col-md-6">
                        <div id="donut-chart1" style="height:150px;"></div>
                    </div>   
                    <div class="col-md-6">
                        <div>Clicks</div>
                        <span id="clicks" style="color: #84c446;font-weight: 600;font-size: 18px;"></span>
                    </div>
                </div>
		    </div>
		    <div class="col-md-3" style="border-right: 1px solid #e6e6e6;">
		        <div class="row">
                    <div class="col-md-6">
                        <div id="donut-chart2" style="height:150px;"></div>
                    </div>   
                    <div class="col-md-6">
                        <div>Conversions</div>
                        <span id="conversions" style="color: #59c8e6;font-weight: 600;font-size: 18px;"></span>
                    </div>
                </div>
		    </div>
		    <div class="col-md-3">
		        <div class="col-md-12">
                       <div class="row">
                       <div class="col-md-12">
                        <span style="float:left;">ROI</span>
                        <span style="float:right;font-size: 17px;color: #ffd280;" id="roi"></span>
                        </div>
                        </div>
                        <div class="row">
                       <div class="col-md-12">
                        <span style="float:left;">CPM</span>
                        <span style="float:right;color: #c3c3c3;font-size: 17px;" id="averagecpm"></span>
                        </div>
                        </div>
                        <div class="row">
                       <div class="col-md-12">
                        <span style="float:left;">CPC</span>
                        <span style="font-size: 17px;float:right;color: #d6d621;" id="averagecpc"></span>
                        </div>
                        </div>
                        <div class="row">
                       <div class="col-md-12">
                        <span style="float:left;">Cost per conv</span>
                        <span style="float:right;font-size: 17px;color: #e09da2;" id="costperconv"></span>
                        </div>
                        </div>
                    </div>  
		    </div>
		</div>
        </div>
		<div class="row">
        <div class="col-md-12">
		    <div class="box-body">
					<div id="line-open-click-send" style="width: 98%; height: 300px;"></div>
					<div id="chartLegend-all"></div>
				</div>
            </div>
		</div>
		<!-- row END !-->
	</div>
	<!-- wrapper END !-->
    
    
    
<script src="assets/js/jquery.min.js"></script>
<script src="assets/js/bootstrap.min.js"></script>
<script src="assets/js/adminlte.min.js"></script>
<!-- FastClick -->
<script src="assets/js/fastclick.js"></script>
<!-- AdminLTE for demo purposes -->
<script src="assets/js/demo.js"></script>
<!-- FLOT CHARTS -->
<script src="assets/js/Flot/jquery.flot.js"></script>
<!-- FLOT RESIZE PLUGIN - allows the chart to redraw when the window is resized -->
<script src="assets/js/Flot/jquery.flot.resize.js"></script>
<!-- FLOT PIE PLUGIN - also used to draw donut charts -->
<script src="assets/js/Flot/jquery.flot.pie.js"></script>
<!-- FLOT CATEGORIES PLUGIN - Used to draw bar charts -->
<script src="assets/js/Flot/jquery.flot.categories.js"></script>
<script src="assets/js/Flot/jquery.flot.stack.js"></script>

<script src="assets/js/DataTable/jquery.dataTables.min.js"></script>
<script src="assets/js/DataTable/dataTables.bootstrap.min.js"></script>
<script src="assets/js/DataTable/jquery.slimscroll.min.js"></script>
<script src="assets/js/Flot/jquery.flot.time.js"></script>


<script src="assets/js/daterangepicker/moment.min.js"></script>
<script src="assets/js/daterangepicker/daterangepicker.js"></script>

<script src="assets/js/daterangepicker/daterangepicker.js"></script>
</body>
<script>
var plot_statistics;
var audience_id=<%=audience_id%>;
var account_id =<%=account_id%>;
var startDate = moment().subtract(1, 'weeks');
var endDate = moment();

document.getElementById('campaign-list').addEventListener('change',function(){
	getReportRange();
})

function statusChangeCallback(response) {
	   
	var userID="";
	
			if (response.status === 'connected') {
                
				userID       = response.authResponse.userID;
				
				//console.log(userID);
				
				getName(audience_id);
				

			} 
		}

function checkLoginState() {
			FB.getLoginStatus(function(response) {
				statusChangeCallback(response);
			});
		}

		window.fbAsyncInit = function() {
			FB.init({
				appId : '278434559502747',
				cookie : true,
				xfbml : true,
				version : 'v3.2'
			});
            
			
			FB.getLoginStatus(function(response) {
				statusChangeCallback(response);
			});
          
		
		};

(function(d, s, id) {
			var js, fjs = d.getElementsByTagName(s)[0];
			if (d.getElementById(id))
				return;
			js = d.createElement(s);
			js.id = id;
			js.src = "https://connect.facebook.net/en_US/sdk.js";
			fjs.parentNode.insertBefore(js, fjs);
		}(document, 'script', 'facebook-jssdk'));


var camps=[];

function getName(audience_id) {
	

	FB.api('/'+audience_id+'?fields=["name"]', function(response) {
		
		  //console.log(response.name);
	      document.getElementById('audience-name').innerHTML=response.name+" Audience";
          getAds(audience_id)
        
         
      });
	
	
}

function getAds(audience_id)
{
	
	FB.api('/'+audience_id+'?fields=["ads"]', function(response) {
		
		
		var obj=response.ads.data;
		  //console.log(response);
		var camp = getCampaigns(obj);
		
	     //var ins= getInsights(obj);
	    // getTest();

        
         
      });
}

function getCampaigns(response)
{

	    for(i=0;i<response.length;i++)
       {
		   (function(index) {
     		 FB.api('/'+response[i]['id']+'?fields=["campaign,name"]', function(response) {
    			//console.log(response.name);
				var el = document.createElement('option');
				el.value = response.id;
				el.innerText = response.name;
				document.getElementById('campaign-list').appendChild(el);
				if(index==0) {
					getReportRange();
				}
    			/*
    			if(!(camps.includes(response.campaign.id)))
    	        	{
    	        	
    	        	FB.api('/'+response.campaign.id+'/insights?time_ranges=list<{\'since\':\'2019-02-15\',\'until\':\'2019-07-09\'}', function(response) {
            	     
            	        console.log(response);
            	     });
    	        	
    	        	camps.push(response.campaign.id)
    	        	}
    	        */
    	     });
	   })(i);
    	   }
	
	
}

/*function getInsights(response)
{
	
	
    for(i=0;i<response.length;i++)
            {
    FB.api('/'+response[i]['id']+'?fields=insights{clicks,spend,cpc,cpm,actions,action_values,impressions,conversions,ctr,frequency},name,id', 
    		function(response) {
   	    var ins= response.insights;
   //	 console.log(response);
              if(typeof ins != 'undefined')
           	   {
           	   var dt=ins.data;
           	   var impressions=dt[0].impressions;
           	   var cost       =dt[0].spend;
           	   var cpc        =dt[0].cpc;
           	   var clicks     =dt[0].clicks;
           	   var cpm        =dt[0].cpm;
           	   var conversion =dt[0].action_values;
           	   
           	   var total=0;
           	   if(typeof conversion!="undefined")
           		   {
           	   for(var i=0;i<conversion.length;i++)
           		   total=total+parseInt(conversion[i].value);
           		   }
           	   
           	   document.getElementById('impressions').innerHTML="<h4>"+impressions+"</h4>";
           	   document.getElementById('cost').innerHTML="<h4>"+cost+"</h4>";
           	   document.getElementById('cpc').innerHTML="<h4>"+cpc+"</h4>";
           	   document.getElementById('clicks').innerHTML="<h4>"+clicks+"</h4>";
           	   document.getElementById('cpm').innerHTML="<h4>"+cpm+"</h4>";
           	   document.getElementById('conversion').innerHTML="<h4>"+total+"</h4>";
           	   //console.log(ins);
           	   }
                     
             
   	        
   	     }); //end insights parameters
   		
   		
            }   // end for
	
	
	
	
	
}*/

function togglePlot(el, seriesIdx) {
    if(el.style.border) {
        el.style.border = ''
    } else {
        el.style.border = '1px solid black';
    }
    var previousPoint2 = plot_statistics.getData();
    previousPoint2[seriesIdx].points.show = !previousPoint2[seriesIdx].points.show;
    previousPoint2[seriesIdx].lines.show = !previousPoint2[seriesIdx].lines.show;
    plot_statistics.setData(previousPoint2);
    plot_statistics.draw();
}

function getReportRange()
{

var start_date = startDate.format('YYYY/MM/DD');
var end_date   = endDate.format('YYYY/MM/DD')



//FB.api('/'+audience_id+'?fields=["ads"]', function(response) {
	
	
	//var obj=response.ads.data;
 
    //for(i=0;i<obj.length;i++)
    //{
    	//var ID=obj[i]['id'];
	var ID=document.getElementById('campaign-list').value;
	//FB.api('/'+obj[i]['id']+'?fields=insights{clicks}', 
	//function(response) {
            //var ins= response.insights;
      //if(typeof ins != 'undefined')
   	   //{
       
    	  
    	  var http = new XMLHttpRequest();
    	  var url = "report_detail.jsp"; 
    	  var params = "account_id="+ account_id
    	  		     +"&ads_id="+ID
    	  		     +"&start_date="+start_date
    	  		     +"&end_date="+end_date;
    	             
    	  http.open("POST", url, true);
    	  http.setRequestHeader("Content-type",
    	  		"application/x-www-form-urlencoded; charset=UTF-8");

    	  http.onreadystatechange = function() {
    	  	if (http.readyState == 4 && http.status == 200) {
    	  		var serverResponse = http.responseText;
              if(serverResponse!="error")
            	  {
            	  
            	  var data = JSON.parse(serverResponse);
            	  var clicks=0;
            	  var cpc=0;
            	  var cpm=0;
            	  var date_start="";
            	  var date_stop="";
            	  var impressions=0;
            	  var spend=0;
				  var spendperconversion = 0;
            	  var conversions=0;
				  var revenue=0;
            	  //var day_click="";
				  var day_click = [];
            	  //var day_impression="";
				  var day_impression=[];
				  var day_spend=[];
				  var day_cpc=[];
				  var day_conversions=[];
				  var day_revenue=[];
				  var day_spendperconversion=[];
            	  
            	  for(var i=0;i<data.length;i++)
            		  {
            		  
            		    clicks  = clicks+parseInt(data[i].clicks);
            		    cpc     = cpc+parseInt(data[i].cpc);
            		    cpm     = cpm+parseInt(data[i].cpm);
            		    date_start = data[i].date_start;
            		    date_stop  = data[i].date_stop;
            		    impressions = impressions+parseInt(data[i].impressions);
						revenue += data[i].conversion_values ? parseInt(data[i].conversion_values) : 0;
						spendperconversion += data[i].cost_per_conversion ? data[i].cost_per_conversion : 0;
            		    spend       = spend+parseInt(data[i].spend);
            		    var day_conversion=0;
						var leads = data[i].actions ? data[i].actions.filter(function(val){return val.action_type === 'lead'}) : [];
						console.log(data[i]);
            		    if(leads.length === 1)
						{
							conversions=conversions+parseInt(leads[0].value);
							day_conversion=day_conversion+parseInt(leads[0].value);
						}
            		  
            		  //day_click      = day_click +"[\'"+i+"\',"+parseInt(data[i].clicks)+"],";
					  day_click.push([new Date(data[i].date_start),parseInt(data[i].clicks)]);
            		  //day_impression = day_impression+"[\'"+i+"\',"+parseInt(data[i].impressions)+"],";
					  day_impression.push([new Date(data[i].date_start),parseInt(data[i].impressions)]);
            		  day_spend.push([new Date(data[i].date_start),parseInt(data[i].spend)]);
					  day_spendperconversion.push([new Date(data[i].date_start), data[i].cost_per_conversion ? parseInt(data[i].cost_per_conversion) : 0]);
					  day_cpc.push([new Date(data[i].date_start),parseInt(data[i].cpc)]);
					  day_revenue.push([new Date(data[i].date_start), data[i].conversion_values ? parseInt(data[i].conversion_values) : 0]);
					  day_conversions.push([new Date(data[i].date_start),day_conversion]);
            		  }
            	   document.getElementById('impressions').innerHTML=impressions;
              	   document.getElementById('cost').innerHTML=spend;
              	   document.getElementById('averagecpc').innerHTML=cpc;
              	   document.getElementById('clicks').innerHTML=clicks;
              	   document.getElementById('averagecpm').innerHTML=cpm;
              	   document.getElementById('conversions').innerHTML=conversions;
				   document.getElementById('revenueperconv').innerHTML=revenue;
				   document.getElementById('costperconv').innerHTML=spendperconversion;
				   document.getElementById('roi').innerText = spend != 0 ? Math.ceil((revenue / spend) * 100) + ' %' : '0 %';
            	  
              	 //day_click=day_click.substring(0, day_click.length-1);
              	 //day_impression=day_impression.substring(0, day_impression.length-1);
              	
              	   
              	    //day_click = "["+day_click+"]";
                	//day_impression = "["+day_impression+"]";
                	
                
                	
                	chartView(day_click,day_impression,day_spend,day_cpc,day_conversions,day_revenue,day_spendperconversion);
            	  
            	  
            	  }
    	  	}
    	  }
    	  	http.send(params);
    	  
    	  
    	  
   	   //}//end if
     
      //});

    //} // end for
//});







	
	
	
	
	
}
function getTest()
{
	
	 FB.api('/6058907131344/insights?fields=["name"]', function(response) {
	
		    console.log(response);
	     });
	
	
	}
</script>
<script type="text/javascript">

	$(function() {
	     $('#date_range').daterangepicker({startDate: startDate,
          endDate: endDate,	locale: {format: 'YYYY/MM/DD'}}, function(start, end, label) {
			startDate = start;
			endDate = end;	
			getReportRange();
		});
  });

	
	
	function chartView(clicks,impressions,cost,averagecpc,conversions,revenue,costperconversion)
	{
		
		
		/*
		 * Year Open, Click , Send DATA
		 * ----------
		 */
	
		//var clicks = [ [ '2017', 10 ], [ '2018', 20 ] ]
		//var impressions = [ [ '2017', 50 ], [ '2018', 100 ] ]

		var allConversionValueData = {
			label : "All Conversion Value",
			data : revenue,
			color : '#D32F2F',
            idx: 0
		}
        
        var impressionsData = {
			label : "Impressions",
			data : impressions,
			color : '#2f55d3',
            idx: 1
		}
        
        var clicksData = {
			label : "Clicks",
			data : clicks,
			color : '#31d94b',
            idx: 2
		}
        
        var conversionsData = {
			label : "Conversions",
			data : conversions,
			color : '#c315c3',
            idx: 3
		}
        
        var costData = {
			label : "Cost",
			data : cost,
			color : '#bfe324',
            idx: 4
		}
        
        var averageCpcData = {
			label : "Average Cpc",
			data : averagecpc,
			color : '#4ef2f8',
            idx: 5
		}
        
        var costPerConversionData = {
			label : "Cost Per Conversion",
			data : costperconversion,
			color : '#3c8e09',
            idx: 6
		}

		plot_statistics = $.plot('#line-open-click-send', [ allConversionValueData, impressionsData, clicksData, 
		conversionsData, costData, averageCpcData, costPerConversionData ], {
			grid : {
				hoverable : true,
				borderColor : '#f3f3f3',
				borderWidth : 1,
				tickColor : '#f3f3f3'
			},
			series : {
				shadowSize : 0,
				lines : {
					show : true
				},
				points : {
					show : true
				}
			},
			legend : {
				noColumns : 7,
				container : $("#chartLegend-all"),
                labelFormatter: function(label, series){
                        return '<a href="#" style="border: 1px solid" onClick="togglePlot(this,'+series.idx+'); return false;">'+label+'</a>';
                    }
			},
			lines : {
				fill : false
			},
			yaxis : {
				show : true
			},
			xaxis : {
                mode: 'time',
                timeformat: "%d-%m-%Y",
				show : true,
                tickSize : 1,
				tickDecimals : 0
			}
		})
		//Initialize tooltip on hover
		$('<div class="tooltip-inner" id="line-open-click-send-tooltip"></div>')
				.css({
					position : 'absolute',
					display : 'none',
					opacity : 0.8
				}).appendTo('body')
		$('#line-open-click-send').bind('plothover',
            function(event, pos, item) {

                if (item) {
                    var x = item.datapoint[0], y = item.datapoint[1]
                    $('#line-open-click-send-tooltip').html(
                            item.series.label + ' of ' + (new Date(x).toLocaleDateString()) + ' = ' + y)
                            .css({
                                top : item.pageY + 5,
                                left : item.pageX + 5
                            }).fadeIn(200)
                } else {
                    $('#line-open-click-send-tooltip').hide()
                }

            })
		/* END LINE CHART */
		
		var totalClicks = parseInt(document.getElementById('clicks').innerText);
		var totalImpressions = parseInt(document.getElementById('impressions').innerText);
		var totalConversions = parseInt(document.getElementById('conversions').innerText);
		
		var clickData = [
      { label: 'Clicks', data:totalClicks, color: '#84c446' },
      { label: '', data:(totalImpressions - totalClicks) , color: '#59c8e6' } 
    ]
        
        var conversionData = [
      { label: 'Conversions', data:totalConversions, color: '#59c8e6' },
      { label: '', data:(totalClicks - totalConversions) , color: '#faa926' } 
    ]
    $.plot('#donut-chart1', clickData, {
      series: {
        pie: {
          show       : true,
          radius     : 1,
          innerRadius: 0.5,
          label      : {
            show     : true,
            radius   : 2 / 3,
            formatter: labelFormatter,
          }

        }
      },
      legend: {
        show: false
      }
    })
        $.plot('#donut-chart2', conversionData, {
      series: {
        pie: {
          show       : true,
          radius     : 1,
          innerRadius: 0.5,
          label      : {
            show     : true,
            radius   : 2 / 3,
            formatter: labelFormatter,
          }

        }
      },
      legend: {
        show: false
      }
    })
    /*
     * END DONUT CHART
     */
	/*
		* Custom Label formatter
		* ----------------------
  	*/
  function labelFormatter(label, series) {
    return '<div style="font-size:13px; text-align:center; padding:2px; color: #000000; font-weight: 600; max-width: 40px;">'
      + label
      + '<br>'
      + Math.round(series.percent) + '%</div>'
  }

	}
</script>
</html>
var startDate = moment().subtract(1, 'weeks');
var endDate = moment();

document.getElementById('audience-name').innerText = listName;

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

$('#date_range').daterangepicker({startDate: startDate,
          endDate: endDate ,locale: {format: 'DD-MM-YYYY'}}, function(start, end, label) {
    startDate = start;
    endDate = end;
    fetchReports(startDate.format('YYYYMMDD'),endDate.format('YYYYMMDD'));
  });

document.getElementById('campaign-list').addEventListener('change', function(event) {
   selectCampaign(event.target.value); 
}); 

function fetchReports(startDate, endDate) {
    var campaignList = document.getElementById('campaign-list');
    while(campaignList.hasChildNodes()) {
        campaignList.removeChild(campaignList.firstChild);
    }
    fetch('http://rcp3.revotas.com:70/googleads/getreport', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            refreshToken: refreshToken,
            clientCustomerId: clientCustomerId,
            listName: listName,
            startDate: startDate,
            endDate: endDate
        })
    }).then(resp=>resp.json()).then(resp=>{
        reportData = resp;
        let count = 0;
        for(let campaignId in resp) {
            if(campaignId !== 'fields' && campaignId !== 'TotalReport') {
                var newOption = document.createElement('option');
                newOption.value = campaignId;
                for(let campaignDate in resp[campaignId]) {
                    newOption.innerText = resp[campaignId][campaignDate][1];
                }
                campaignList.appendChild(newOption);
                if(count===0)
                    selectCampaign(campaignId);
                count++;
            }
        }
    });
}

fetchReports(startDate.format('YYYYMMDD'),endDate.format('YYYYMMDD'));

function selectCampaign(campaignId) {
    drawLineChart(reportData[campaignId]);
}

function sortReportData(data) {
    data.sort((a,b) => {
        return new Date(a[0]).getTime() - new Date(b[0]).getTime();
    })
}

var plot_statistics;

function drawLineChart(data) {
    
    var allConversionValue = [];
    var impressions = [];
    var clicks = [];
    var conversions = [];
    var cost = [];
    var averageCpc = [];
    var averageCpm = [];
    var costPerConversion = [];
    
    var totalImpressions = 0;
    var totalClicks = 0;
    var totalConversions = 0;
    var totalCost = 0;
    var totalCostPerConversion = 0;
    var totalRevenue = 0;
    var totalAverageCpm = 0;
    var totalAverageCpc = 0;
    for(let lineData in data) {
        totalImpressions += parseInt(data[lineData][5]);
        totalClicks += parseInt(data[lineData][6]);
        totalConversions += parseInt(data[lineData][7]);
        totalCostPerConversion += parseInt(data[lineData][11]);
        totalRevenue += parseInt(data[lineData][12]);
        totalCost += parseInt(data[lineData][8]);
        totalAverageCpc += parseInt(data[lineData][9]);
        totalAverageCpm += parseInt(data[lineData][10]);
        
        
        allConversionValue.push( [new Date(data[lineData][2]), data[lineData][4]]);
        impressions.push( [new Date(data[lineData][2]), data[lineData][5]]);
        clicks.push( [new Date(data[lineData][2]), data[lineData][6]]);
        conversions.push( [new Date(data[lineData][2]), data[lineData][7]]);
        cost.push( [new Date(data[lineData][2]), data[lineData][8]]);
        averageCpc.push( [new Date(data[lineData][2]), data[lineData][9]]);
        costPerConversion.push( [new Date(data[lineData][2]), data[lineData][11]]);
    }
    
    document.getElementById('impressions').innerText = totalImpressions;
    document.getElementById('clicks').innerText = totalClicks;
    document.getElementById('conversions').innerText = totalConversions;
    document.getElementById('cost').innerText = totalCost;
    document.getElementById('costperconv').innerText = totalCostPerConversion;
    document.getElementById('revenueperconv').innerText = totalRevenue;
    document.getElementById('averagecpc').innerText = totalAverageCpc;
    document.getElementById('averagecpm').innerText = totalAverageCpm;
    document.getElementById('roi').innerText = totalCostPerConversion !== 0 ? Math.ceil((totalRevenue / totalCostPerConversion) * 100) + ' %' : '0 %';
    
    sortReportData(allConversionValue);
    sortReportData(impressions);
    sortReportData(clicks);
    sortReportData(conversions);
    sortReportData(cost);
    sortReportData(averageCpc);
    sortReportData(averageCpm);
    sortReportData(costPerConversion);

		var allConversionValueData = {
			label : "All Conversion Value",
			data : allConversionValue,
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
			data : averageCpc,
			color : '#4ef2f8',
            idx: 5
		}
        
        var costPerConversionData = {
			label : "Cost Per Conversion",
			data : costPerConversion,
			color : '#3c8e09',
            idx: 6
		}

		plot_statistics = $.plot('#line-open-click-send', [ allConversionValueData, impressionsData, clicksData, conversionsData, costData, averageCpcData, costPerConversionData ], {
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
        var clickData = [
      { label: 'Clicks', data:totalClicks, color: '#37d9f7' },
      { label: '', data:(totalImpressions - totalClicks) , color: '#b8ff46' } 
    ]
        
        var conversionData = [
      { label: 'Conversions', data:totalConversions, color: '#37d9f7' },
      { label: '', data:(totalClicks - totalConversions) , color: '#ff7ff5' } 
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
            threshold: 0.1
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
            threshold: 0.1
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
    return '<div style="font-size:13px; text-align:center; padding:2px; color: #000000; font-weight: 600;">'
      + label
      + '<br>'
      + Math.round(series.percent) + '%</div>'
  }


  }
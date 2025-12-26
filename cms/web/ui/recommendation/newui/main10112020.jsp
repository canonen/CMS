<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
            com.britemoon.cps.imc.*,
			java.sql.*,java.net.*,
			java.util.Calendar,
			java.io.*,java.util.*,
			java.text.DateFormat,org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%
	String cust_id = request.getParameter("cust_id");
	String camp_id = request.getParameter("camp_id");
	String tarih_aralik  = request.getParameter("tarih_aralik");
	ConnectionPool cp = null;
	Connection conn = null;
	Statement stmt = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;

	Service service = null;
	Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust_id);
	service = (Service) services.get(0);
   String rcpUrl = service.getURL().getHost();
   
   Calendar calendar = Calendar.getInstance();  
         

    int  current_year;
    int  current_month;
    int  current_month_cal;
    int  current_day;

    current_year = calendar.get(Calendar.YEAR); 
    current_month = calendar.get(Calendar.MONTH); 
    current_month_cal = current_month + 1;
    current_day = calendar.get(Calendar.DAY_OF_MONTH); 
   
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Document</title>
    <link rel="stylesheet" href="./dist/css/adminlte.min.css">
    <link rel="stylesheet" href="./dist/css/select2.min.css">
    <link rel="stylesheet" href="./dist/css/all.min.css">
    <link rel="stylesheet" href="assets/css/daterangepicker/daterangepicker.css">
	<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700,300italic,400italic,600italic">
    <style>
	body {
          font-family: 'Source Sans Pro', 'Helvetica Neue', Helvetica, Arial, sans-serif !important;
      }
        button, .nav-link.active {
            background-color:#3c8dbc !important;
            border-color: 367fa9 !important;
        }
    
    </style>
</head>
<body>
    <div class="col-md-12">
            <div class="card">
              <div class="card-header p-2">
                <ul class="nav nav-pills">
                  <li class="nav-item"><a class="nav-link <%if(tarih_aralik == null){%>active<%}%>" href="#campaign_name" data-toggle="tab">Name</a></li>
                  <li class="nav-item"><a class="nav-link" href="#campaign_type" data-toggle="tab">Type</a></li>
                  <li class="nav-item"><a class="nav-link" href="#campaign_template" data-toggle="tab">Template</a></li>
                  <li class="nav-item"><a class="nav-link" href="#campaign_code" data-toggle="tab">Code</a></li>
                  <%if(camp_id!=null) {%>
                      <li class="nav-item"><a onclick="reportPage()" class="nav-link <%if(tarih_aralik != null){%>active<%}%>" href="#campaign_report" data-toggle="tab">Report</a></li>
                    <%}%>
                  
                </ul>
              </div><!-- /.card-header -->
              <div class="card-body">
                <div class="tab-content">
                  <div class="tab-pane <%if(tarih_aralik == null){%>active<%}%>" id="campaign_name">
                    <form class="form-horizontal">
                     <div class="form-group col-md-6 row">
                          <label>Status</label>
                          <select id="campaignStatus" class="form-control select2" style="width: 100%;">
                              <option value="1">Enabled</option>
                              <option value="0">Disabled</option>
                          </select>
                        </div>
                      <div class="form-group row">
                        <label for="campaignName" class="col-md-2 col-form-label">Campaign Name</label>
                        <div class="col-md-4">
                          <input type="text" class="form-control" id="campaignName" placeholder="Campaign Name">
                        </div>
                      </div>
                      <div class="form-group row">
                            <label for="campaignTitle" class="col-md-2 col-form-label">Campaign Title</label>
                            <div class="col-md-4">
                              <input type="text" class="form-control" id="campaignTitle" placeholder="Campaign Title">
                            </div>
                          </div>
                    </form>
                    <button type="submit" class="btn btn-primary next_button">Next</button>
                  </div>
                  <!-- /.tab-pane -->
                  <div class="tab-pane" id="campaign_type">
                  <div class="form-group col-md-6 row">
                  <label>Select Campaign Type</label>
                  <select id="campaignType" class="form-control select2" style="width: 100%;">
                      <option value="50">Top Seller</option>
                      <option value="60">Price Drop</option>
                      <option value="70">New Product</option>
                      <option value="80">Back in Stock</option>
                      <option value="90">Buy Also</option>
                      <option value="100">Similar</option>
                      <option value="110">You Might</option>
                      <option value="120">View Also</option>
                      <option value="130">Recently Viewed</option>
                      <option value="140">Trending</option>
                  </select>
                </div>
                   <div class="form-group row">
                        <label for="containerSize" class="col-md-2 col-form-label">Container Size</label>
                        <div class="col-md-4">
                          <input type="text" class="form-control" id="containerSize" placeholder="auto">
                        </div>
                      </div>
                      <div class="form-group row">
                        <label for="productLimit" class="col-md-2 col-form-label">Product Limit</label>
                        <div class="col-md-4">
                          <input type="text" class="form-control" id="productLimit" placeholder="auto">
                        </div>
                      </div>
                    
                 <button type="submit" class="btn btn-primary next_button">Next</button>
                  </div>
                  <!-- /.tab-pane -->
                  <!-- /.tab-pane -->
                  
                  <!-- /.tab-pane -->

                  <div class="tab-pane" id="campaign_template">
                      <div class="form-group col-md-6">
                          <label>Select Campaign Template</label>
                          <select id="template-list" class="form-control select2" style="width: 100%;">
                          </select>
                        </div>
                        <div class="form-group">
                        <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#modal-lg">
                          Manage Templates
                        </button>
                        </div>
                        <button id="saveCampaign" type="button" class="btn btn-primary" disabled>
                          Save
                        </button>
                  </div>
                  <!-- /.tab-pane -->
                    <div class="tab-pane" id="campaign_code">
                        <div class="form-group col-md-12">
                            <input type="text" class="form-control" id="campaignHtmlCode" readonly>
                        </div>
                    </div>
                    
                    <!-- /.tab-pane -->
                    <div class="tab-pane <%if(tarih_aralik != null){%>active<%}%>" id="campaign_report">
                    <div class="row">
                    <div class="col-12">
                     <form method="post" action="main.jsp?cust_id=<%=cust_id%>&camp_id=<%=camp_id%>">
													<div class="row" style="justify-content: flex-end;">
																		<div class="col-xs-6">
																					<div class="form-group">
																								<div class="input-group">
																											<input type="text" name="tarih_aralik" class="form-control pull-right" id="tarih_aralik">
																								</div>
																					</div>
																		</div>
																		<div class="col-xs-4">
																					<button type="submit" class="btn btn-primary">Submit</button>
																		</div>
													
													</div>
												
												</form>
                        </div>
                        </div>
                      <div class="row">
                       <div class="col-12 col-sm-6 col-md-4">
            <div class="info-box">
              <span style="background-color: #59c8e6 !important" class="info-box-icon bg-info elevation-2"><i class="fas fa-mouse-pointer"></i></span>

              <div class="info-box-content">
                <span class="info-box-text">Click Rate</span>
                <span class="info-box-number" id="click-rate">
                  <small>%</small>
                </span>
              </div>
              <!-- /.info-box-content -->
            </div>
            <!-- /.info-box -->
          </div>
                       <div class="col-12 col-sm-6 col-md-4">
            <div class="info-box">
              <span style="background-color: #e66eaa !important" class="info-box-icon bg-info elevation-2"><i class="fas fa-circle-notch"></i></span>

              <div class="info-box-content">
                <span class="info-box-text">Conversion Rate</span>
                <span class="info-box-number" id="conversion-rate">
                  <small>%</small>
                </span>
              </div>
              <!-- /.info-box-content -->
            </div>
            <!-- /.info-box -->
          </div>
                       <div class="col-12 col-sm-6 col-md-4">
            <div class="info-box">
              <span style="background-color:#f56954 !important" class="info-box-icon bg-info elevation-2"><i class="fas fa-shopping-bag"></i></span>

              <div class="info-box-content">
                <span class="info-box-text">Purchases</span>
                <span class="info-box-number" id="purchases">
                </span>
              </div>
              <!-- /.info-box-content -->
            </div>
            <!-- /.info-box -->
          </div>
                      <div class="col-12 col-sm-6 col-md-4">
            <div class="info-box">
              <span style="background-color:#faa926 !important" class="info-box-icon bg-info elevation-2"><i class="fas fa-cash-register"></i></span>

              <div class="info-box-content">
                <span class="info-box-text">Average Order Value</span>
                <span class="info-box-number" id="avg-order-value">
                </span>
              </div>
              <!-- /.info-box-content -->
            </div>
            <!-- /.info-box -->
          </div>
                      <div class="col-12 col-sm-6 col-md-4">
            <div class="info-box">
              <span style="background-color:#84c446 !important" class="info-box-icon bg-info elevation-2"><i class="fas fa-funnel-dollar"></i></span>

              <div class="info-box-content">
                <span class="info-box-text">Revenue</span>
                <span class="info-box-number" id="revenue">
                </span>
              </div>
              <!-- /.info-box-content -->
            </div>
            <!-- /.info-box -->
          </div>
                      <div class="col-12 col-sm-6 col-md-4">
            <div class="info-box">
              <span style="background-color:#ffeb3b !important" class="info-box-icon bg-info elevation-2"><i class="fas fa-money-bill-alt"></i></span>

              <div class="info-box-content">
                <span class="info-box-text">Contribution</span>
                <span class="info-box-number" id="contribution">
                </span>
              </div>
              <!-- /.info-box-content -->
            </div>
            <!-- /.info-box -->
          </div>
                       </div>
                        <div class="form-group col-md-12">
                            <div id="recommendation-report-graph" style="width: 92vw; height: 300px;"></div>
                            <div id="chartLegend-all" style="margin-top: 25px;"></div>
                            <div id="recommendation-report-graph2" style="width: 92vw; height: 300px; margin-top: 30px;"></div>
                            <div id="chartLegend-all2" style="margin-top: 25px;"></div>
                        </div>
                    </div>
                </div>
                <!-- /.tab-content -->
              </div><!-- /.card-body -->
            </div>
            <!-- /.nav-tabs-custom -->
          </div>
          <div class="col-md-12">
              <div class="card">
                  <div class="card-header">
                      Preview Area
                  </div>
                  <div class="card-body">
                     <div style="width: 100%; display: flex; justify-content: center; align-items: center">
                         <div class="preview_container rvts_top_seller"></div>
                     </div>
                      
                  </div>
              </div>
          </div>
          
          <div class="modal fade" id="modal-lg" style="display: none;" aria-hidden="true">
        <div class="modal-dialog modal-lg">
          <div class="modal-content">
            <div class="modal-header">
              <h4 class="modal-title">Manage Your Templates</h4>
              <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                <span aria-hidden="true">×</span>
              </button>
            </div>
            <div class="modal-body row">
             <div class="form-group col-md-6">
                  <label>Presets</label>
                  <select id="preset-list" class="form-control select2" style="width: 100%;">
                  </select>
                  <input style="margin-top: 10px;" type="text" class="form-control" id="createTemplateName" placeholder="Template Name">
                  <button id="createCss" style="margin-top: 8px;" type="submit" class="btn btn-primary">New Template</button>
                  <i id="templateCreating" class="fas fa-2x fa-sync-alt fa-spin" style="display:none;margin-top: 10px;"></i>
                  <span id="createSuccess" style="display:none;color:green;position: absolute;font-size: 14px;margin-top: 18px;margin-left: 25px;">Created Successfully</span>
                  <span id="createError" style="display:none;color:red;position: absolute;font-size: 14px;margin-top: 18px;margin-left: 25px;">An Error Occurred</span>
                </div>
              <div class="form-group col-md-6">
                  <label>Templates</label>
                  <select id="template-list2" class="form-control select2" style="width: 100%;">
                  </select>
                  <input style="margin-top: 10px;" type="text" class="form-control" id="templateName" placeholder="Template Name">
                  <button id="saveCss" style="margin-top: 8px;" type="submit" class="btn btn-primary">Save</button>
                  <button id="deleteTemplate" style="margin-top: 8px;" type="submit" class="btn btn-danger">Delete</button>
                  <i id="templateSaving" class="fas fa-2x fa-sync-alt fa-spin" style="display:none;margin-top: 10px;"></i>
                  <span id="saveSuccess" style="display:none;color:green;position: absolute;font-size: 14px;margin-top: 18px;margin-left: 25px;">Saved Successfully</span>
                  <span id="saveError" style="display:none;color:red;position: absolute;font-size: 14px;margin-top: 18px;margin-left: 25px;">An Error Occurred</span>
                  <span id="deleteSuccess" style="display:none;color:green;position: absolute;font-size: 14px;margin-top: 18px;margin-left: 25px;">Deleted Successfully</span>
                  <span id="deleteError" style="display:none;color:red;position: absolute;font-size: 14px;margin-top: 18px;margin-left: 25px;">An Error Occurred</span>
                  
                </div>
                <div class="form-group col-md-12">
                    <label for="inputDescription">CSS</label>
                    <textarea id="cssArea" class="form-control" rows="4"></textarea>
              </div>
              <div class="col-md-12">
              <div class="card">
                  <div class="card-header">
                      Preview Area
                  </div>
                  <div class="card-body">
                     <div style="width: 100%; height: 400px; display: flex; justify-content: center; align-items: center">
                         <div class="preview_container2"></div>
                     </div>
                      
                  </div>
              </div>
          </div>
            </div>
            <div class="modal-footer justify-content-between">
              <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
            </div>
          </div>
          <!-- /.modal-content -->
        </div>
        <!-- /.modal-dialog -->
      </div>
    <script src="./dist/js/jquery.min.js"></script>
    <script src="./dist/js/bootstrap.bundle.min.js"></script>
    <script src="./dist/js/adminlte.min.js"></script>
    <script src="./dist/js/select2.full.min.js"></script>
    <!-- FLOT CHARTS -->
<script src="assets/js/Flot/jquery.flot.js"></script>
<!-- FLOT RESIZE PLUGIN - allows the chart to redraw when the window is resized -->
<script src="assets/js/Flot/jquery.flot.resize.js"></script>
<!-- FLOT PIE PLUGIN - also used to draw donut charts -->
<script src="assets/js/Flot/jquery.flot.pie.js"></script>
<!-- FLOT CATEGORIES PLUGIN - Used to draw bar charts -->
<script src="assets/js/Flot/jquery.flot.categories.js"></script>
<script src="assets/js/Flot/jquery.flot.stack.js"></script>
<script src="assets/js/Flot/jquery.flot.time.js"></script>
   <script src="assets/js/daterangepicker/moment.min.js"></script>
<script src="assets/js/daterangepicker/daterangepicker.js"></script>
    
    <script>
    var editMode = false;
        
    var custId = <%=cust_id%>;
    var navLinks = Array.from(document.querySelectorAll('.nav-link'));
    Array.from(document.querySelectorAll('.next_button')).forEach(function(element, index) {
        element.addEventListener('click', function() {
            navLinks[index+1].click();
        })
    });
    
    var rcpLink = '<%=rcpUrl%>';
    var rvtsRecommendationObj = {};
    rvtsRecommendationObj.rvts_customer_id = custId;
        
    var rvtsRecoPreviewMode = true;
    </script>
    
    <%
    if(camp_id!=null) {
    try {
 	  
   cp = ConnectionPool.getInstance();
   conn = cp.getConnection("recommendation_main.jsp");
   
   String sql = "select camp_name, camp_title, camp_type, template_id, status, products_num_block, container_size, rcp_link, currency_config from "
               + "c_recommendation_config where camp_id = ? and cust_id = ?";
   
   pstmt = conn.prepareStatement(sql);
   int x=1;
   pstmt.setString(x++,camp_id);
   pstmt.setLong(x++,Long.parseLong(cust_id));
   rs = pstmt.executeQuery();
   String camp_name=null;
   String camp_title=null;
   String camp_type=null;
   String template_id=null;
   String status=null;
   String products_num_block=null;
   String container_size=null;
   String rcp_link=null;
   String currency_config=null;
   if(rs.next()) {
       camp_name = rs.getString(1);
       camp_title = rs.getString(2);
       camp_type = rs.getString(3);
       template_id = rs.getString(4);
       status = rs.getString(5);
       products_num_block = rs.getString(6);
       container_size = rs.getString(7);
       rcp_link = rs.getString(8);
       currency_config = rs.getString(9);
       %>
       <script>editMode=true;</script>
       <%
   }
   rs.close();
   StringBuilder jsonObj = new StringBuilder();
   jsonObj.append("{");
   jsonObj.append("\"camp_id\":\""+camp_id+"\",");
   jsonObj.append("\"camp_name\":\""+camp_name+"\",");
   jsonObj.append("\"camp_title\":\""+camp_title+"\",");
   jsonObj.append("\"camp_type\":\""+camp_type+"\",");
   jsonObj.append("\"template_id\":\""+template_id+"\",");
   jsonObj.append("\"status\":\""+status+"\",");
   jsonObj.append("\"products_num_block\":\""+products_num_block+"\",");
   jsonObj.append("\"container_size\":\""+container_size+"\",");
   jsonObj.append("\"rcp_link\":\""+rcp_link+"\",");
   jsonObj.append("\"currency_config\":"+currency_config);
   jsonObj.append("}");
   
   %>
        <script>var configObj = JSON.parse('<%=jsonObj.toString()%>')</script>
    <%
   }
   catch(Exception e){
 	 out.print(e);
   }
   finally{
 	  
   try { if ( pstmt != null ) pstmt.close(); }
   catch (Exception ignore) { }
 
   if ( conn != null ) {
 	       cp.free(conn);
 	 } 
 	  
   }
   }
   %>
    
    <script src="recommendation.js"></script>
    <script src="script.js"></script>
    
    <script>
        var alreadyRendered = false;
        
        function reportPage() {
            renderGraphs();
        }
        
        
        
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
        
        function togglePlot2(el, seriesIdx) {
            if(el.style.border) {
                el.style.border = ''
            } else {
                el.style.border = '1px solid black';
            }
            var previousPoint2 = plot_statistics2.getData();
            previousPoint2[seriesIdx].points.show = !previousPoint2[seriesIdx].points.show;
            previousPoint2[seriesIdx].lines.show = !previousPoint2[seriesIdx].lines.show;
            plot_statistics2.setData(previousPoint2);
            plot_statistics2.draw();
        }
        
        var plot_statistics;
        var plot_statistics2;
        var tarihAralik = '<%=tarih_aralik%>';
        var tempStartDate = tarihAralik !== 'null' ? tarihAralik.split('-')[0].trim() : moment().startOf('month');
        var tempEndDate = tarihAralik !== 'null' ? tarihAralik.split('-')[1].trim() : moment().endOf('month');
        
        $('#tarih_aralik').daterangepicker({
	   ranges: {
                'Today': [moment(), moment()],
                'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
                'Last 7 Days': [moment().subtract(6, 'days'), moment()],
                'Last 30 Days': [moment().subtract(29, 'days'), moment()],
                'This Month': [moment().startOf('month'), moment().endOf('month')],
                'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
		},
		startDate: tempStartDate,
		endDate: tempEndDate,
		locale: {format: 'YYYY/MM/DD'}
   });
        
        if(tarihAralik!=='null')document.querySelector('input[name=tarih_aralik]').value = tarihAralik;
        
        function renderGraphs() {
            if(alreadyRendered)
                return;
            fetchPromise.then(resp => {
                setTimeout(function() {
                    document.getElementById('recommendation-report-graph').innerHTML = '';
            document.getElementById('recommendation-report-graph2').innerHTML = '';
            plot_statistics = $.plot('#recommendation-report-graph', [ resp[0] ], {
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
				noColumns : 3,
				container : $("#chartLegend-all"),
                labelFormatter: function(label, series){
                        return '<a href="#" style="border: 1px solid" onClick="togglePlot(this,'+series.idx+'); return false;">'+label+'</a>';
                    }
			},
			lines : {
				fill : true
			},
			yaxis : {
				show : true
			},
			xaxis : {
                mode: 'time',
                timeformat: "%d-%m-%Y",
				show : true,
                tickSize: [1, 'day'],
				tickDecimals : 0
			}
		})
		
	$('<div class="tooltip-inner" id="line-open-click-send-tooltip"></div>')
				.css({
					position : 'absolute',
					display : 'none',
					opacity : 0.8
				}).appendTo('body')
		$('#recommendation-report-graph').bind('plothover',
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
            
            
            
            
            
            plot_statistics2 = $.plot('#recommendation-report-graph2', [ resp[1] ], {
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
				noColumns : 3,
				container : $("#chartLegend-all2"),
                labelFormatter: function(label, series){
                        return '<a href="#" style="border: 1px solid" onClick="togglePlot2(this,'+series.idx+'); return false;">'+label+'</a>';
                    }
			},
			lines : {
				fill : true
			},
			yaxis : {
				show : true
			},
			xaxis : {
                mode: 'time',
                timeformat: "%d-%m-%Y",
				show : true,
                tickSize: [1, 'day'],
				tickDecimals : 0
			}
		})
		
	$('<div class="tooltip-inner" id="line-open-click-send-tooltip2"></div>')
				.css({
					position : 'absolute',
					display : 'none',
					opacity : 0.8
				}).appendTo('body')
		$('#recommendation-report-graph2').bind('plothover',
            function(event, pos, item) {

                if (item) {
                    var x = item.datapoint[0], y = item.datapoint[1]
                    $('#line-open-click-send-tooltip2').html(
                            item.series.label + ' of ' + (new Date(x).toLocaleDateString()) + ' = ' + y)
                            .css({
                                top : item.pageY + 5,
                                left : item.pageX + 5
                            }).fadeIn(200)
                } else {
                    $('#line-open-click-send-tooltip2').hide()
                }

            })
                    
                    alreadyRendered = true;
                }, 50);
            })
        }
        
        var fetchPromise = fetch('https://'+ rcpLink + '/rrcp/imc/recommendation/get_recommendation_data.jsp?cust_id=' + custId + '&camp_id=' + campaignId + (tarihAralik != 'null' ? '&tarih_aralik=' + tarihAralik : ''))
        .then(function(resp) {return resp.json();})
        .then(function(resp) {
            var totalActivity = resp.totalActivity;
            var totalImpression = resp.totalImpression;
            var totalOrder = resp.totalOrder;
            var totalRevenue = resp.totalRevenue;
            var totalContribution = resp.totalContribution

            if(totalActivity && totalImpression)document.getElementById('click-rate').innerHTML = (totalActivity/totalImpression).toFixed(2) + '<small>%</small>';
            if(totalOrder && totalActivity)document.getElementById('conversion-rate').innerHTML = (totalOrder/totalActivity).toFixed(2) + '<small>%</small>';
            if(totalOrder)document.getElementById('purchases').innerHTML = (totalOrder);
            if(totalRevenue && totalOrder)document.getElementById('avg-order-value').innerHTML = (totalRevenue/totalOrder).toFixed(2);
            if(totalRevenue)document.getElementById('revenue').innerHTML = parseInt(totalRevenue);
            if(totalContribution)document.getElementById('contribution').innerHTML = parseInt(totalContribution);
            
            var clickRateDataArray = [];
            var clickRateData = resp.clickRate;
            for(var key in clickRateData) {
                clickRateDataArray.push([new Date(key), clickRateData[key]]);
            }
            
            var conversionRateDataArray = [];
            var conversionRateData = resp.conversionRate;
            for(var key in conversionRateData) {
                conversionRateDataArray.push([new Date(key), conversionRateData[key]]);
            }
            
            var clickDataArray = [];
            var clickData = resp.click;
            for(var key in clickData) {
                clickDataArray.push([new Date(key), clickData[key]]);
            }
            
            var viewDataArray = [];
            var viewData = resp.view;
            for(var key in viewData) {
                viewDataArray.push([new Date(key), viewData[key]]);
            }
            
            var revenueDataArray = [];
            var revenueData = resp.revenue;
            for(var key in revenueData) {
                revenueDataArray.push([new Date(key), revenueData[key]]);
            }
            
            var contributionDataArray = [];
            var contributionData = resp.contribution;
            for(var key in contributionData) {
                contributionDataArray.push([new Date(key), contributionData[key]]);
            }
            
            conversionRateDataArray.sort((a,b) => (a[0]-b[0]));
            clickRateDataArray.sort((a,b) => (a[0]-b[0]));
            clickDataArray.sort((a,b) => (a[0]-b[0]));
            viewDataArray.sort((a,b) => (a[0]-b[0]));
            revenueDataArray.sort((a,b) => (a[0]-b[0]));
            contributionDataArray.sort((a,b) => (a[0]-b[0]));
            
            conversionRateDataArray = conversionRateDataArray.map(e => [e[0],parseFloat(e[1]).toFixed(5)]);
            clickRateDataArray = clickRateDataArray.map(e => [e[0],parseFloat(e[1]).toFixed(5)]);
            
		var clickRateData = {
			label : "Click Rate",
			data : clickRateDataArray,
			color : '#59c8e6',
            idx: 0
		}
        
        var conversionRateData = {
			label : "Conversion Rate",
			data : conversionRateDataArray,
			color : '#84C446',
            idx: 0
		}
        
        var viewData = {
			label : "View",
			data : viewDataArray,
			color : '#f58503',
            idx: 1
		}
        
        var revenueData = {
			label : "Revenue",
			data : revenueDataArray,
			color : '#23dbf4',
            idx: 2
		}
        
        var contributionData = {
			label : "Contribution",
			data : contributionDataArray,
			color : '#f20909',
            idx: 3
		}
		
	
		
            
            
        return [clickRateData, conversionRateData];    
            
            
            
            
            
        });
        
        
        <%if(tarih_aralik != null){%>renderGraphs();<%}%>
        
    </script>
    
    <script>
        var currencyConfigs = null;
var currencyFetched = fetch('https://'+rcpLink+'/rrcp/imc/currency/get_currency_config.jsp?cust_id=<%=cust_id%>')
        .then(resp => resp.json())
        .then(resp => {
            currencyConfigs = resp;
            document.getElementById('saveCampaign').removeAttribute('disabled');
        }).catch(() => {
            alert('An error occurred while loading configurations!');
            location.reload();
        });
			

</script>
    
    
</body>
</html>
<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- <xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl"> -->

	<xsl:output method="html" indent="yes" />
	
	<xsl:template match="/">
		<xsl:text disable-output-escaping="yes"><![CDATA[<!DOCTYPE html>]]></xsl:text>
		<html>
		<head>
            <meta charset="utf-8"/>
            <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
            <title>Revotas Report </title> 
            <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport"/>
            
            <link rel="stylesheet" href="assets/css/bootstrap.min.css"/>
            <link rel="stylesheet" href="assets/css/font-awesome.min.css"/>
            <link rel="stylesheet" href="assets/css/ionicons.min.css"/>
            
            <link rel="stylesheet" href="assets/css/AdminLTE.css"/>
            <link rel="stylesheet" href="assets/css/Style.css"/>
            
            <link rel="stylesheet" href="assets/css/skin-blue.min.css"/>
            <link rel="stylesheet" href="assets/css/DataTable/dataTables.bootstrap.min.css"/> 
            <link rel="stylesheet" href="assets/css/daterangepicker/daterangepicker.css"/>
            <script src="assets/js/FushionCharts/fusioncharts.js"></script>
            <script src="assets/js/FushionCharts/fusioncharts.theme.fint.js"></script>
            <!--[if lt IE 9]>
            <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
            <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
            <![endif]-->
                
            <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700,300italic,400italic,600italic"/>
 
            <style> 
            <![CDATA[
                a.reportPopDetail{ text-decoration:underline; color:#21759B; }
                .hovercontent { position: relative;}
                .bubbleContainer td { background-color: #FFFFFF; color: #666666; padding: 3px; vertical-align: middle; }
                .bubbleContainer  { border: 1px solid #DFDFDF;}
            ]]>
            </style>

			<xsl:if test="1 = /CampaignList/RecipView">
				<script type="text/javascript">
					<![CDATA[
					function pop_up_win(url) {
						windowName = 'report_results_window';
						windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, height=600, width=700';
						ReportWin = window.open(url, windowName, windowFeatures);
					} ]]>
				</script>
			</xsl:if>				
		</head>
		<body class="hold-transition">

                    	<xsl:choose>

                            <xsl:when test = "CampaignList/OnlyOne">
           
                                    <div class="wrapper" style="margin-left:20px;margin-right:20px;">
                                        <div class="row">
                                            <div class="col-md-6">
                                                    <div class="box-body pad table-responsive">
                                                            <table class="text-center">
                                                                <tbody> 
                                                                    <tr>
                                                                        <td>
                                                                            <xsl:if test="1 = /CampaignList/ReportCache">
                                                                            <xsl:element name="a">
                                                                            <xsl:attribute name="class">topLinks</xsl:attribute>
                                                                            <xsl:attribute name="href">report_cache_list.jsp?Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;C=0</xsl:attribute>
                                                                                Return to Demographic or Time Reportsss</xsl:element>
                                                                            <xsl:comment><xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/></xsl:comment> 
                                                                            </xsl:if>
                                                                        </td>
                                                                        <td width="5"></td>
                                                                        <td>
                                                                            <xsl:if test="/CampaignList/Campaigns/Row/Cache/StartDate!='' or /CampaignList/Campaigns/Row/Cache/EndDate!='' or /CampaignList/Campaigns/Row/Cache/AttrName!=''">
                                                                            <xsl:element name="a">
                                                                                <xsl:attribute name="class">topLinks</xsl:attribute>
                                                                                <xsl:attribute name="href">report_cache_edit.jsp?Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/></xsl:attribute>
                                                                                Edit Criteria</xsl:element>
                                                                            </xsl:if>

                                                                        </td>
                                                                        <td width="5"></td>
                                                                        <td>
                                                                    
                                                                            <xsl:element name="a">
                                                                                <xsl:attribute name="class">btn btn-block btn-warning</xsl:attribute>
                                                                                <xsl:attribute name="href">report_object.jsp?act=PRNT&#38;id=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>
                                                                                </xsl:attribute>
                                                                                    Export to Excel
                                                                            </xsl:element>

                                                                        </td>
                                                                        <td width="5"> </td>
                                                                        <td>
                                                                            <xsl:element name="a">
                                                                                <xsl:attribute name="class">btn btn-block btn-warning</xsl:attribute>
                                                                                <xsl:attribute name="href">/cms/servlet/ReportToPDF</xsl:attribute>
                                                                                <xsl:attribute name="target">_blank</xsl:attribute>
                                                                                    Export to PDF
                                                                            </xsl:element>
                                                                        </td>
                                                                    
                                                                    </tr>
                                                                </tbody>
                                                            </table>
                                                    </div>
                                            </div>
                                        </div>
                                    
                                        <div class="row">
                                            <div class="col-md-12">
                                                <div class="nav-tabs-custom">
                                                    <ul class="nav nav-tabs">

                                                        <xsl:choose>
                                                            <xsl:when test="1 = /CampaignList/ReportCache">
                                                                <xsl:element name="li">
                                                                    <xsl:element name="a">
                                                                        <xsl:attribute name="href">report_object.jsp?act=VIEW&#38;id=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                        <span>Campaign Results</span>	 
                                                                    </xsl:element>
                                                                </xsl:element>
                                                               <li class="active"> <a href="javscript:void(null);"><span>Demographic Or Time Report</span></a></li>				
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                            
                                                                <li class="active"> <a href="javscript:void(null);" ><span>Campaign Results</span></a></li>
                                                                
                                                                <xsl:if test="1 = /CampaignList/StandardUIRptFlag">
                                                                <xsl:element name="li">
                                                                    <xsl:element name="a">
                                                                        <xsl:attribute name="href">report_cache_list.jsp?Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/></xsl:attribute>
                                                                        <span>Demographic Or Time Reports</span>	 
                                                                    </xsl:element>
                                                                </xsl:element>
                                                                </xsl:if>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                        <xsl:element name="li">
                                                            <xsl:element name="a">
                                                                <xsl:attribute name="href">report_time.jsp?Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                <span>Activity vs Time Report</span>	 
                                                            </xsl:element>
                                                        </xsl:element>

                                                        <xsl:if test="1 = /CampaignList/DeliveryTrackerRptFlag">
                                                            <xsl:element name="li">
                                                                <xsl:element name="a">
                                                                    <xsl:attribute name="href">eTrackerReport.jsp?Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                    <span>Delivery Tracking</span>
                                                                </xsl:element>
                                                            </xsl:element>
                                                        </xsl:if>
                                                        
                                                        <xsl:if test="0 &lt; /CampaignList/ReportPosFlag">
                                                            <xsl:element name="li">
                                                                <xsl:element name="a">
                                                                    <xsl:attribute name="href">report_track.jsp?Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/></xsl:attribute>
                                                                    <span>RevoTrack Results</span>
                                                                </xsl:element>
                                                            </xsl:element>
                                                        </xsl:if>
                                                        <xsl:element name="li"> 
                                                            <xsl:element name="a">
                                                                    <xsl:attribute name="href">report_heatmap.jsp?Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/></xsl:attribute>
                                                                    <span>HeatMap</span>
                                                            </xsl:element>
                                                        </xsl:element>
  
                                                    </ul>
                                                </div> 
                                            </div>
                                        </div>
                                    
                                    </div>

                                    <section class="content">
                                        <xsl:if test="1 = /CampaignList/GeneralSecFlag">
                                        <!-- Report Summary Start -->

                                             <div class="row">
                                                <div class="col-lg-2 col-xs-6">
                                                <!-- small box -->
                                                <div class="small-box b_turuncu">
                                                    <div class="inner c_beyaz">
                                                    <h3><xsl:value-of select="CampaignList/Campaigns/Row/Size"/></h3>
                                                        
                                                    <p>Send</p>
                                                    </div>
                                                    <div class="icon">
                                                    <i class="fa fa-send"></i>
                                                    </div>
                                                    <a href="#" class="small-box-footer"> </a>
                                                </div>
                                                </div>
                                                <!-- ./col -->
                                                <div class="col-lg-2 col-xs-6">
                                                <!-- small box -->
                                                <div class="small-box b_mor">
                                                    <div class="inner c_beyaz">
                                                        <h3><xsl:value-of select="CampaignList/Campaigns/Row/Reaching"/></h3>
                                                        <p>Received</p>
                                                    </div>
                                                    <div class="icon">
                                                      <i class="fa fa-bullhorn"></i>
                                                    </div>
                                                    <a href="#" class="small-box-footer"> </a>
                                                </div>
                                                </div>
                                                <!-- ./col -->
                                                <div class="col-lg-2 col-xs-6">
                                                <!-- small box -->
                                                <div class="small-box b_mavi">
                                                    <div class="inner c_beyaz ">
                                                    <h3><xsl:value-of select="CampaignList/Campaigns/Row/DistinctReads"/></h3>

                                                    <p>Read</p>
                                                    </div>
                                                    <div class="icon">
                                                    <i class="fa fa-folder-open"></i>
                                                    </div>
                                                    <a href="#" class="small-box-footer"> </a>
                                                </div>
                                                </div>
                                                <!-- ./col -->
                                                <div class="col-lg-2 col-xs-6">
                                                <!-- small box -->
                                                <div class="small-box b_yesil">
                                                    <div class="inner c_beyaz">
                                                    <h3><xsl:value-of select="CampaignList/Campaigns/Row/DistinctClicks"/> </h3>

                                                    <p>Clicks</p>
                                                    </div>
                                                    <div class="icon">
                                                    <i class="ion ion-stats-bars"></i>
                                                    </div>
                                                    <a href="#" class="small-box-footer"> </a>
                                                </div>
                                                </div>
                                                <!-- ./col -->
                                                <div class="col-lg-2 col-xs-6">
                                                <!-- small box -->
                                                <div class="small-box b_kirmizi">
                                                    <div class="inner c_beyaz">
                                                    <h3><xsl:value-of select="CampaignList/Campaigns/Row/Unsubs"/></h3>

                                                    <p>Unsubs</p>
                                                    </div>
                                                    <div class="icon">
                                                    <i class="ion ion-android-walk"></i>
                                                    </div>
                                                    <a href="#" class="small-box-footer"> </a>
                                                </div>
                                                </div>
                                                <!-- ./col -->
                                                <div class="col-lg-2 col-xs-6">
                                                <!-- small box -->
                                                <div class="small-box b_gri">
                                                    <div class="inner c_beyaz">
                                                    <h3><xsl:value-of select="CampaignList/Campaigns/Row/BBacks"/></h3>

                                                    <p>Bounced</p>
                                                    </div>
                                                    <div class="icon">
                                                    <i class="fa fa-user-times"></i>
                                                    </div>
                                                    <a href="#" class="small-box-footer"> </a>
                                                </div>
                                                </div>
                                                <!-- ./col -->
                                            </div><!-- /.row  END -->

                                        <!-- Report Summary End -->
                                        </xsl:if>


                                        <div class="row">
                                             <div class="col-md-6 connectedSortable " >
                                                        <xsl:if test="1 = /CampaignList/GeneralSecFlag">
                                                        <!-- Report Summary Start -->
                                                                <div class="box box-primary">
                                                                    <div class="box-header with-border">
                                                                        <h3 class="box-title">Report Summary</h3>
                                                                        <div class="box-tools pull-right">
                                                                            <button type="button" class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i>  </button>
                                                                        </div>
                                                                    </div>
                                                                    <div class="box-body" style="background-color:#f1f1f1;">
                                                                        <div class="col-md-12 no-padding">
                                                                        <div class="box">
                                                                            <div class="box-body no-padding">
                                                                                <table class="table table-striped">
                                                                                        <tbody>
                                                                                            <tr class="sectionHeaders">
                                                                                                <th>Campaign</th>
                                                                                                <th>Sending Start</th>
                                                                                                <th>Sending Finished</th>
                                                                                                
                                                                                            </tr>
                                                                                            <tr class="contentRows">
                                                                                                <td><xsl:value-of select="CampaignList/Campaigns/Row/Name"/></td>
                                                                                                <td><xsl:value-of select="CampaignList/Campaigns/Row/StartDate"/></td>
                                                                                                <td><xsl:value-of select="CampaignList/Campaigns/Row/EndDate"/></td>
                                                                                            </tr>
                                                                                        </tbody>
                                                                                </table>
                                                                            </div> <!-- /.box-body -->
                                                                        </div><!-- /.box -->
                                                                        </div><!-- /.col-md-12 -->

                                                                        <div class="col-md-7">
                                                                            <div class="nav-tabs-custom">
                                                                                <ul class="nav nav-tabs">
                                                                                    <li class="active"><a href="#tab_Received" data-toggle="tab">Received</a></li>
                                                                                    <li><a href="#tab_Read" data-toggle="tab">Read</a></li>
                                                                                    <li><a href="#tab_Clicks" data-toggle="tab">Clicks</a></li>
                                                                                    <li><a href="#tab_Unsubs" data-toggle="tab">Unsubs</a></li>
                                                                                </ul>
                                                                                <div class="tab-content">
                                                                                    <div class="tab-pane active" id="tab_Received">

                                                                                        <div id="chart-Received">FusionCharts XT will load here!</div>

                                                                                    </div><!-- /.tab-pane -->
                                                                                    <div class="tab-pane" id="tab_Read">

                                                                                        <div id="chart-Read">FusionCharts XT will load here!</div>

                                                                                    </div><!-- /.tab-pane -->
                                                                                    <div class="tab-pane" id="tab_Clicks">

                                                                                        <div id="chart-Click">FusionCharts XT will load here!</div>

                                                                                    </div><!-- /.tab-pane -->
                                                                                    <div class="tab-pane" id="tab_Unsubs">

                                                                                        <div id="chart-Unsub">FusionCharts XT will load here!</div>

                                                                                    </div><!-- /.tab-pane -->
                                                                                </div> <!-- /.tab-content -->
                                                                            </div> <!-- nav-tabs-custom -->

                                                                        </div><!-- /.col-md-6 -->
                                                                        <div class="col-md-5 no-padding" >
                                                                            <div class="box">
                                                                                <div class="box-body no-padding">
                                                                                    <table class="table table-striped" border="0" cellspacing="0" width="100%" cellpadding="0">
                                                                                        <thead>
                                                                                            <tr>
                                                                                                <th>Metric</th>
                                                                                                <th>#</th>
                                                                                                <th>%</th>
                                                                                                <th>Total</th>
                                                                                            </tr>
                                                                                        </thead>
                                                                                        <tbody>
                                                                                            <tr>
                                                                                                <td>Sent</td>
                                                                                                <td>
                                                                                                    <xsl:element name="div">
                                                                                                        <xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                                                        <div class="hovercontent">																		
                                                                                                        <xsl:element name="a">																			
                                                                                                            <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                            <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=all&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                            <xsl:value-of select="CampaignList/Campaigns/Row/Size"/>
                                                                                                        </xsl:element>
                                                                                                        </div>
                                                                                                    </xsl:element>
                                                                                                </td>
                                                                                                <td>100%</td>
                                                                                                <td>N/A</td>
                                                                                            </tr>
                                                                                            <tr>
                                                                                                <td>Bounced</td>
                                                                                                <td>
                                                                                                    <xsl:element name="div">
                                                                                                            <xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                                                        <div class="hovercontent">
                                                                                                        <xsl:element name="a">
                                                                                                            <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                            <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=bbk&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                            <xsl:value-of select="CampaignList/Campaigns/Row/BBacks"/>
                                                                                                        </xsl:element>
                                                                                                        </div>
                                                                                                    </xsl:element>																		
                                                                                                </td>
                                                                                                <td><xsl:value-of select="CampaignList/Campaigns/Row/BBackPrc"/>%</td>
                                                                                                <td>N/A</td>
                                                                                            </tr>
                                                                                            <tr>
                                                                                                <td>Received</td>
                                                                                                <td>
                                                                                                    <xsl:element name="div">
                                                                                                            <xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                                                        <div class="hovercontent">
                                                                                                        <xsl:element name="a">
                                                                                                            <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                            <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=rcvd&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                            <xsl:value-of select="CampaignList/Campaigns/Row/Reaching"/>
                                                                                                        </xsl:element>
                                                                                                        </div>
                                                                                                    </xsl:element>
                                                                                                </td>
                                                                                                <td><xsl:value-of select="CampaignList/Campaigns/Row/ReachingPrc"/>%</td>
                                                                                                <td>N/A</td>
                                                                                            </tr>
                                                                                            <tr>
                                                                                                <td>Read</td>
                                                                                                <td>
                                                                                                    <xsl:element name="div">
                                                                                                            <xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                                                        <div class="hovercontent">
                                                                                                        <xsl:element name="a">
                                                                                                            <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                            <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=read&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                            <xsl:value-of select="CampaignList/Campaigns/Row/DistinctReads"/>
                                                                                                        </xsl:element> 
                                                                                                        </div>
                                                                                                    </xsl:element>	
                                                                                                </td>
                                                                                                <td><xsl:value-of select="CampaignList/Campaigns/Row/DistinctReadPrc"/>%</td>
                                                                                                <td><xsl:value-of select="CampaignList/Campaigns/Row/TotalReads"/></td>
                                                                                            </tr>
                                                                                            <tr>
                                                                                                <td>Clicks</td>
                                                                                                <td>
                                                                                                <xsl:element name="div">
                                                                                                        <xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                                                    <div class="hovercontent">
                                                                                                    <xsl:element name="a">
                                                                                                        <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                        <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                        <xsl:value-of select="CampaignList/Campaigns/Row/DistinctClicks"/>
                                                                                                    </xsl:element> 
                                                                                                    </div>
                                                                                                </xsl:element>																		
                                                                                                </td>
                                                                                                <td><xsl:value-of select="CampaignList/Campaigns/Row/DistinctClickPrc"/>%</td>
                                                                                                <td><xsl:value-of select="CampaignList/Campaigns/Row/TotalClicks"/></td>
                                                                                            </tr>
                                                                                            <tr>
                                                                                                <td>Unsubs</td>
                                                                                                <td>
                                                                                                <xsl:element name="div">
                                                                                                        <xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>	
                                                                                                    <div class="hovercontent">
                                                                                                    <xsl:element name="a">
                                                                                                        <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                        <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=unsub&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                        <xsl:value-of select="CampaignList/Campaigns/Row/Unsubs"/>
                                                                                                    </xsl:element> 
                                                                                                    </div>
                                                                                                </xsl:element>	
                                                                                                </td>
                                                                                                <td><xsl:value-of select="CampaignList/Campaigns/Row/UnsubPrc"/>%</td>
                                                                                                <td>N/A</td>
                                                                                            </tr>    
                                                                                        </tbody>
                                                                                    </table>      
                                                        
                                                        
                                                                            
                                                                                </div>
                                                                            </div>
                                                                            
                                                                        </div>
                                                                        
                                                                    </div><!-- /.box-body -->
                                                                </div><!-- /.box box-primary -->

                                                        <!-- Report Summary End -->
                                                        </xsl:if>


                                                        <xsl:if test="1 = /CampaignList/DistClickSecFlag">
                                                        <!-- Detailed ClickedThrues Unique Start -->

                                                            <xsl:variable name="jsonDataLinks">
                                                                <xsl:for-each select="CampaignList/Campaigns/Row/Links">
                                                                    <xsl:text>{ "label" : "</xsl:text><xsl:value-of select="translate(LinkName,translate(LinkName,'&#231;&#305;&#287;&#246;&#351;&#252;&#199;&#304;&#208;&#214;&#350;&#220;abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ',''),'')"/><xsl:text>" },</xsl:text>
                                                                </xsl:for-each>
                                                            </xsl:variable> 
                                                            
                                                        

                                                            <xsl:variable name="jsonDataLinksHTMLClicks">
                                                                <xsl:for-each select="CampaignList/Campaigns/Row/Links">
                                                                    <xsl:text>{ "value" : "</xsl:text><xsl:value-of select="(DistinctHTMLPrc * DistinctClickPrc) div 100"/><xsl:text>" },</xsl:text>
                                                                </xsl:for-each>
                                                            </xsl:variable>

                                                            
                                                    
                                                            <xsl:variable name="jsonDataLinksTextClicks">
                                                                <xsl:for-each select="CampaignList/Campaigns/Row/Links">
                                                                    <xsl:text>{ "value" : "</xsl:text><xsl:value-of select="(DistinctTextPrc * DistinctClickPrc) div 100"/><xsl:text>" },</xsl:text>
                                                                </xsl:for-each>
                                                            </xsl:variable>
                                                    
                                                            

                                                            <xsl:variable name="TotalNumOfLinks">
                                                                    <xsl:value-of select="count(CampaignList/Campaigns/Row/Links) * 25"/>
                                                            </xsl:variable>

                                                            
                                                    
                                                            <xsl:variable name="TotalNumOfLinksurl">
                                                                    <xsl:value-of select="count(CampaignList/Campaigns/Row/Links) * 30"/>
                                                            </xsl:variable>
        

                                                            <xsl:variable name="detailedClickLabels">
                                                                <xsl:for-each select="CampaignList/Campaigns/Row/Links">
                                                                <xsl:sort select="position()" data-type="number" order="descending"/>
                                                                        <xsl:value-of select="LinkName"/>
                                                                        <xsl:if test="not(position() = last())">
                                                                            <xsl:text>|</xsl:text>
                                                                        </xsl:if>
                                                                </xsl:for-each>
                                                            </xsl:variable>

                                                            
                                                        
                                                            <xsl:variable name="detailedClickHTMLValues">
                                                                <xsl:for-each select="CampaignList/Campaigns/Row/Links">
                                                                        <xsl:value-of select="DistinctHTML"/>
                                                                        <xsl:if test="not(position() = last())">
                                                                            <xsl:text>,</xsl:text>
                                                                        </xsl:if>
                                                                </xsl:for-each>
                                                            </xsl:variable>

                                                            
                                                        
                                                            <xsl:variable name="detailedClickTextValues">
                                                                <xsl:for-each select="CampaignList/Campaigns/Row/Links">
                                                                        <xsl:value-of select="DistinctText"/>
                                                                        <xsl:if test="not(position() = last())">
                                                                            <xsl:text>,</xsl:text>
                                                                        </xsl:if>
                                                                </xsl:for-each>
                                                            </xsl:variable>

                                                            <script>
                                                            
                                                            var Category=[<xsl:value-of select="$jsonDataLinks"></xsl:value-of>];
                                                            var Text=[<xsl:value-of select="$jsonDataLinksTextClicks"></xsl:value-of>];
                                                            var Html=[<xsl:value-of select="$jsonDataLinksHTMLClicks"></xsl:value-of>];
                                                                                        
                                                            </script>
                                                        
                                                            <xsl:variable name="detailedClickLink">
                                                                <xsl:text>http://chart.apis.google.com/chart?chf=bg,s,FFFFFF&amp;chxl=0:|0|20|40|60|80|100|1:|</xsl:text><xsl:value-of select='$detailedClickLabels'/><xsl:text>&amp;chxs=0,000000,10,0,l,676767|1,000000,10,0,l,676767&amp;chxt=x,y&amp;chbh=14,10,10&amp;chs=450x</xsl:text><xsl:value-of select="$TotalNumOfLinksurl"></xsl:value-of><xsl:text></xsl:text><xsl:text>&amp;cht=bhs&amp;chco=3399CC,80C65A&amp;chd=t:</xsl:text><xsl:value-of select='$detailedClickTextValues'/><xsl:text>|</xsl:text><xsl:value-of select='$detailedClickHTMLValues'/><xsl:text>&amp;chdlp=b&amp;chg=20,20,2,2&amp;chm=N,000000,0,-1,11|N,000000,1,-1,11,1</xsl:text>
                                                            </xsl:variable>
                                                            
                                                            
        
                                                            <div class="box box-primary">
                                                                    <div class="box-header with-border">
                                                                        <h3 class="box-title">Detailed Click Throughs (Unique)</h3>
                                                                        <div class="box-tools pull-right">
                                                                            <button type="button" class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i>  </button>
                                                                        </div>
                                                                    </div>
                                                                    <div class="box-body" style="background-color:#f1f1f1;">
                                                                        
                                                                        <div class="col-md-12">
                                                                                <div class="box">
                                                                                    <div class="box-body no-padding">
                                                                                        <div id="chart-containerLink">FusionCharts XT will load here!</div>
                                                                                        </div>
                                                                                        
                                                                                </div>
                                                                        </div><!-- /.col-md-12 -->
                                                                        
                                                                        <div class="col-md-12">
                                                                            <div class="box">
                                                                                <div class="box-body no-padding">
                                                                                        <table id="example2" class="table table-bordered table-striped">
                                                                                                <thead>
                                                                                                    <tr>
                                                                                                        <th>Name</th>
                                                                                                        <th>Clicks</th>
                                                                                                        <th>Text</th>
                                                                                                        <th>HTML</th>
                                                                                                        <th>%</th>
                                                                                                    </tr>
                                                                                                </thead>
                                                                                                <tbody>
                                                                                                <xsl:for-each select="CampaignList/Campaigns/Row/Links">
                                                                                                    <tr>
                                                                                                        <td><xsl:value-of select="LinkName"/></td>
                                                                                                        <td>
                                                                                                            <div class="hovercontent">																		
                                                                                                                <xsl:element name="a">
                                                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
                                                                                                                    </xsl:attribute>
                                                                                                                    <xsl:value-of select="DistinctClicks"/>
                                                                                                                </xsl:element>
                                                                                                            </div> 
                                                                                                        </td>
                                                                                                        <td>
                                                                                                            <xsl:element name="div">
                                                                                        
                                                                                                                <div class="hovercontent">																		
                                                                                                                    <xsl:element name="a">
                                                                                                                        <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                                        <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=T&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
                                                                                                                        </xsl:attribute>
                                                                                                                        <xsl:value-of select="DistinctText"/>
                                                                                                                    </xsl:element>
                                                                                                                </div>
                                                                                                            </xsl:element>
                                                                                                        
                                                                                                        </td>
                                                                                                        <td>
                                                                                                                <xsl:element name="div">
                                                                                                                    
                                                                                                                        <div class="hovercontent">																		
                                                                                                                            <xsl:element name="a">
                                                                                                                                <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                                                <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=H&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
                                                                                                                                </xsl:attribute>
                                                                                                                                <xsl:value-of select="DistinctHTML"/>
                                                                                                                            </xsl:element>
                                                                                                                        </div>
                                                                                                                    </xsl:element>
                                                                                                        
                                                                                                        </td>
                                                                                                        <td><xsl:value-of select="DistinctClickPrc"/>%</td>
                                                                                                    </tr>
                                                                                                </xsl:for-each>
                                                                                                </tbody> 
                                                                                        </table>
                                                                                </div> <!-- /.box-body -->
                                                                            </div><!-- /.box -->
                                                                        </div><!-- /.col-md-12 -->
                                                
                                                                    
                                                                        
                                                                    </div><!-- /.box-body -->
                                                            </div><!-- /.box box-primary -->


                                                        <!-- Detailed ClickedThrues Unique End -->
                                                        </xsl:if>

                                                        <xsl:if test="1 = /CampaignList/TotClickSecFlag">
                                                        <!-- Detailed ClickedThrues Agree Start -->

                                                            <div class="box box-primary">
                                                                    <div class="box-header with-border">
                                                                        <h3 class="box-title">Detailed Click Throughs (Aggregate)</h3>
                                                                        <div class="box-tools pull-right">
                                                                            <button type="button" class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i>  </button>
                                                                        </div>
                                                                    </div>
                                                                    <div class="box-body" style="background-color:#f1f1f1;">
                                                                        
                                                                        
                                                                        <div class="col-md-12">
                                                                            <div class="box">
                                                                                <div class="box-body no-padding">
                                                                                        <table id="example3" class="table table-bordered table-striped">
                                                                                                <thead>
                                                                                                    <tr>
                                                                                                        <th>Name</th>
                                                                                                        <th>Clicks</th>
                                                                                                        <th>Text</th>
                                                                                                        <th>HTML</th>
                                                                                                        <th>%</th>
                                                                                                    </tr>
                                                                                                </thead>
                                                                                                <tbody>
                                                                                                <xsl:for-each select="CampaignList/Campaigns/Row/Links">
                                                                                                   <tr>
                                                                                                    <td><xsl:value-of select="LinkName"/></td>
                                                                                                    <td>
                                                                                                        <xsl:element name="div">
                                                                                                        <xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                                                        <div class="hovercontent">																		
                                                                                                            <xsl:element name="a">
                                                                                                            <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                            <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
                                                                                                            </xsl:attribute>
                                                                                                            <xsl:value-of select="TotalClicks"/>
                                                                                                        </xsl:element>
                                                                                                        </div>
                                                                                                    </xsl:element>
                                                                                                    </td>
                                                                                                    <td>
                                                                                                        <xsl:element name="div">
                                                                                                        <xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                                                        <div class="hovercontent">																		
                                                                                                            <xsl:element name="a">
                                                                                                            <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                            <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=T&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
                                                                                                            </xsl:attribute>
                                                                                                            <xsl:value-of select="TotalText"/>
                                                                                                        </xsl:element>
                                                                                                        </div>
                                                                                                        </xsl:element>
                                                                                                    
                                                                                                    </td>
                                                                                                    <td>
                                                                                                        <xsl:element name="div">
                                                                                                        <xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                                                        <div class="hovercontent">																		
                                                                                                            <xsl:element name="a">
                                                                                                                <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                                <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=H&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
                                                                                                                </xsl:attribute>
                                                                                                                <xsl:value-of select="TotalHTML"/>
                                                                                                            </xsl:element>
                                                                                                        </div>
                                                                                                    </xsl:element>
                                                                                                    
                                                                                                    </td>
                                                                                                    <td ><xsl:value-of select="TotalClickPrc"/>%</td>
                                                                                                   </tr>
                                                                                                </xsl:for-each>
                                                                                                </tbody> 
                                                                                        </table>
                                                                                </div> <!-- /.box-body -->
                                                                            </div><!-- /.box -->
                                                                        </div><!-- /.col-md-12 -->
                                                
                                                                    
                                                                        
                                                                    </div><!-- /.box-body -->
                                                            </div><!-- /.box box-primary -->


                                                        <!-- Detailed ClickedThrues Agree End -->
                                                        </xsl:if>

                                                </div><!-- /.col-md-6 connectedSortable -->
                                                <!-- /.col-md-6 RİGHT connectedSortable  START-->
                                                <div class="col-md-6 connectedSortable ">

                                                    <xsl:if test="1 = /CampaignList/ReportCache">
                                                    
                                                        <div class="box box-primary">
                                                            <div class="box-header with-border">
                                                            <h3 class="box-title">Report Parameters</h3>
                                                            <div class="box-tools pull-right">
                                                                <button type="button" class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i>  </button>
                                                            </div>
                                                            </div>
                                                            <div class="box-body" style="background-color:#f1f1f1;">
                                                            
                                                                <div class="col-md-6">
                                                                    <div class="box">
                                                                        <div class="box-body no-padding">
                                                                            <table class="table table-striped" border="0" cellspacing="0" width="100%" cellpadding="0">
                                                                                <tbody>
                                                                                    <tr>
                                                                                        <td>&#160;</td>
                                                                                        <td>&#160;</td>
                                                                                    </tr>
                                                                                    <xsl:if test="/CampaignList/Campaigns/Row/Cache/StartDate!=''">
                                                                                        <tr>
                                                                                            <td>Start Date:</td>
                                                                                            <td><xsl:value-of select="/CampaignList/Campaigns/Row/Cache/StartDate"/></td>
                                                                                        </tr>
                                                                                    </xsl:if>
                                                                                    <xsl:if test="/CampaignList/Campaigns/Row/Cache/EndDate!=''">
                                                                                    <tr>
                                                                                        <td>End Date:</td>
                                                                                        <td><xsl:value-of select="/CampaignList/Campaigns/Row/Cache/EndDate"/></td>
                                                                                    </tr>
                                                                                    </xsl:if>
                                                                                   <xsl:if test="/CampaignList/Campaigns/Row/Cache/AttrName!=''">
                                                                                        <tr>
                                                                                            <td>Attribute:</td>
                                                                                            <td>
                                                                                                <xsl:value-of select="/CampaignList/Campaigns/Row/Cache/AttrName"/>
                                                                                                <xsl:value-of select="/CampaignList/Campaigns/Row/Cache/AttrOperator"/>
                                                                                                <xsl:value-of select="/CampaignList/Campaigns/Row/Cache/AttrValue1"/>
                                                                                                <xsl:if test="/CampaignList/Campaigns/Row/Cache/AttrOperator = 'BETWEEN'">
                                                                                                AND <xsl:value-of select="/CampaignList/Campaigns/Row/Cache/AttrValue2"/>
                                                                                                </xsl:if>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </xsl:if>
                                                                                    <tr>
                                                                                        <td width="150">Only Recips Owned By User?</td>
                                                                                        <td>
                                                                                            <xsl:choose>
                                                                                                <xsl:when test="/CampaignList/Campaigns/Row/Cache/UserID = 0">
                                                                                                    No
                                                                                                </xsl:when>
                                                                                                <xsl:otherwise>
                                                                                                    Yes
                                                                                                </xsl:otherwise>
                                                                                            </xsl:choose>
                                                                                        </td>
                                                                                    </tr> 
                                                                                </tbody>
                                                                            </table>      
                                                                        </div>
                                                                    </div>
                                                                
                                                                </div>
                                                                
                                                                <div class="col-md-12">
                                                                        <div class="box">
                                                                            <div class="box-body">
                                                                                <table id="example1" class="table table-bordered table-striped">
                                                                                <thead>
                                                                                <tr>
                                                                                    <th>Domain</th>
                                                                                    <th>Sent</th>
                                                                                    <th>Bounced</th>
                                                                                    <th>Read</th>
                                                                                    <th>Click</th>
                                                                                    <th>Unsub</th>
                                                                                    <th>Spam</th>
                                                                                </tr>
                                                                                </thead>
                                                                                <tbody>
                                                                                <tr>
                                                                                    <td>Trident</td>
                                                                                    <td>Internet  Explorer 4.0   </td>
                                                                                    <td>Win 95+</td>
                                                                                    <td>4</td>
                                                                                    <td>X</td>
                                                                                    <td>4</td>
                                                                                    <td>X</td>
                                                                                </tr>
                                                                                
                                                                                </tbody> 
                                                                                </table>
                                                                            </div>
                                                                            <!-- /.box-body -->
                                                                        </div>
                                                                    
                                                                    </div>
                                                            </div><!-- /.box-body -->
                                                        </div><!-- /.box box-primary -->
                                                    
                                                    </xsl:if>
                                                    <xsl:if test="1 = /CampaignList/BBackSecFlag">

                                                        <div class="box box-primary">
                                                            <div class="box-header with-border">
                                                                    <h3 class="box-title">Bounceback Categories</h3>
                                                                    <div class="box-tools pull-right">
                                                                        <button type="button" class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i>  </button>
                                                                    </div>
                                                            </div>
                                                             <div class="box-body" style="background-color:#f1f1f1;">
                                                            
                                                                    <div class="col-md-6">
                                                                        <div class="box">
                                                                            <div class="box-body no-padding">
                                                                                <table class="table table-striped" border="0" cellspacing="0" width="100%" cellpadding="0">
                                                                                    <tbody>
                                                                                    <tr>
                                                                                        <th> </th>
                                                                                        <th>#</th>
                                                                                        <th>%</th>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td>Total Bounceback</td>
                                                                                        <td>
                                                                                            <xsl:element name="div">
                                                                                                <xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                                                <div class="hovercontent">																		
                                                                                                <xsl:element name="a">
                                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=bbk&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');
                                                                                                    </xsl:attribute>
                                                                                                    <xsl:value-of select="CampaignList/Campaigns/Row/BBacks"/>
                                                                                                </xsl:element>
                                                                                                </div>
                                                                                            </xsl:element>
                                                                                        </td>
                                                                                        <td>100%</td>
                                                                                    </tr>
                                                                                    <xsl:for-each select="CampaignList/Campaigns/Row/BounceBacks">
														       
                                                                                            <tr>
                                                                                                <td><xsl:value-of select="CategoryName"/></td>
                                                                                                <td>
                                                                                                    <xsl:element name="div">
                                                                                                        <xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                                                        <div class="hovercontent">																		
                                                                                                        <xsl:element name="a">
                                                                                                            <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                            <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=bbk&#38;Q=<xsl:value-of select="CampID"/>&#38;B=<xsl:value-of select="CategoryID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');
                                                                                                            </xsl:attribute>
                                                                                                            <xsl:value-of select="BBacks"/>
                                                                                                        </xsl:element>
                                                                                                        </div>
                                                                                                    </xsl:element>
                                                                                                </td>
                                                                                                <td><xsl:value-of select="BBackPrc"/></td>
                                                                                            </tr>

                                                                                    </xsl:for-each>	
                                                                                    </tbody>
                                                                                </table>      
                                                                            </div>
                                                                        </div>
                                                                        
                                                                    </div>
                                                                    <div class="col-md-6">
                                                                        <div class="box">
                                                                            <div class="box-body no-padding">
                                                                                
                                                                                <xsl:variable name="bounceCatNames">
                                                                                    <xsl:for-each select="CampaignList/Campaigns/Row/BounceBacks">
                                                                                    <xsl:sort select="position()" data-type="number" order="descending"/>
                                                                                        <xsl:text>|</xsl:text>
                                                                                            <xsl:value-of select="CategoryName"/>
                                                                                    </xsl:for-each>
                                                                                </xsl:variable>
                                                                                
                                                                                <xsl:variable name="bounceCatValues">
                                                                                    <xsl:for-each select="CampaignList/Campaigns/Row/BounceBacks">
                                                                                            <xsl:value-of select="BBackPrc"/>
                                                                                            <xsl:if test="not(position() = last())">
                                                                                                <xsl:text>,</xsl:text>
                                                                                            </xsl:if>
                                                                                    </xsl:for-each>
                                                                                </xsl:variable>
                                                                                
                                                                                <xsl:variable name="bouncebackCatLinks">
                                                                                    <xsl:text>http://chart.apis.google.com/chart?chf=bg,s,FFFFFF&amp;chxl=0:|%250|%2520|%2540|%2560|%2580|%25100|1:</xsl:text><xsl:value-of select='$bounceCatNames'/><xsl:text>&amp;chxs=0,000000,10,0,l,676767|1,000000,10,0,l,676767&amp;chxt=x,y&amp;chbh=14,10,10&amp;chs=300x250&amp;cht=bhs&amp;chco=3399CC&amp;chd=t:</xsl:text><xsl:value-of select='$bounceCatValues'/><xsl:text>&amp;chdlp=b&amp;chg=20,20,2,2&amp;chm=N%25,CCCCCC,0,-1,10</xsl:text>
                                                                                </xsl:variable>
                                                                                
                                                                                
                                                                                
                                                                                <xsl:variable name="jsonData">
                                                                                    <xsl:for-each select="CampaignList/Campaigns/Row/BounceBacks">
                                                                                        <xsl:text>{ "label" : "</xsl:text>
                                                                                            <xsl:value-of select="CategoryName"/>
                                                                                        <xsl:text>", "value" : "</xsl:text>
                                                                                            <xsl:value-of select="BBackPrc"/>
                                                                                        <xsl:text>" },</xsl:text>
                                                                                    </xsl:for-each>
                                                                                </xsl:variable>
                                                                                
                                                                                <script>
                                                                                    var bback=[<xsl:value-of select="$jsonData"></xsl:value-of>];
                                                                                </script>

                                                                                <div id="chart-containerBounceback">FusionCharts XT will load here!</div>
                                                                            </div>
                                                                        </div>

                                                                    </div><!-- /.col-md-6 -->
                                                                
                                                             </div><!-- /.box-body -->
                                                        </div><!-- /.box box-primary -->
                                                    
                                                    </xsl:if>


                                                    <xsl:if test="count(CampaignList/Campaigns/Row/Domains) &gt; 0">
                                                        <xsl:if test="1 = /CampaignList/DomainFlag">
                                                        <!-- Domain Deliverability Start -->
                                                        <div class="box box-primary">
                                                            <div class="box-header with-border">
                                                            <h3 class="box-title">Domain Deliverability</h3>
                                                            <div class="box-tools pull-right">
                                                                <button type="button" class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i>  </button>
                                                            </div>
                                                            </div>
                                                            <div class="box-body" style="background-color:#f1f1f1;">
                                                            
                                                                <div class="col-md-6">
                                                                    <div class="box">
                                                                        <div class="box-body no-padding">
                                                                            <table class="table table-striped" border="0" cellspacing="0" width="100%" cellpadding="0">
                                                                                <tbody>
                                                                                    <tr>
                                                                                        <th>Top 5 Domains</th>
                                                                                        <th> </th>
                                                                                    </tr>
                                                                                     <xsl:for-each select="CampaignList/Campaigns/Row/Domains">
																                                 
                                                                                        <xsl:if test="position() &lt; = 5">
                                                                                            <tr>
                                                                                                <td><xsl:value-of select="Domain"/></td>
                                                                                                <td><xsl:value-of select="Reads"/>(<xsl:value-of select="ReadPrc"/>%) Reads</td>
                                                                                            </tr>	
                                                                                        </xsl:if>
                                                                                    </xsl:for-each>
                                                                                </tbody>
                                                                            </table>      
                                                                        </div>
                                                                    </div>
                                                                
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <div class="box">
                                                                        <div class="box-body no-padding">

                                                                                    <xsl:variable name="domainDelivValues">
                                                                                        <xsl:for-each select="CampaignList/Campaigns/Row/Domains">
                                                                                            <xsl:if test="position() &lt; = 5">
                                                                                                <xsl:value-of select="Reads"/>
                                                                                                <xsl:if test="position() &lt; 5">
                                                                                                    <xsl:text>,</xsl:text>
                                                                                                </xsl:if>
                                                                                            </xsl:if>
                                                                                        </xsl:for-each>
                                                                                    </xsl:variable>
                                                                                    
                                                                                    <xsl:variable name="domainDelivLabels">
                                                                                        <xsl:for-each select="CampaignList/Campaigns/Row/Domains">
                                                                                            <xsl:if test="position() &lt; = 5">
                                                                                                <xsl:value-of select="Domain"/>
                                                                                                <xsl:if test="position() &lt; 5">
                                                                                                    <xsl:text>|</xsl:text>
                                                                                                </xsl:if>
                                                                                            </xsl:if>
                                                                                        </xsl:for-each>
                                                                                    </xsl:variable>
                                                                                
                                                                                    <xsl:variable name="domaindelivlink">
                                                                                        <xsl:text>http://chart.apis.google.com/chart?chf=bg,s,FFFFFF&amp;chs=300x150&amp;cht=p3&amp;chco=008000|FF0000|3399CC|FF9900|C2BDDD&amp;chds=0,10000&amp;chd=t:</xsl:text><xsl:value-of select='$domainDelivValues'/><xsl:text>&amp;chdl=</xsl:text><xsl:value-of select='$domainDelivLabels'/><xsl:text>&amp;chdlp=b&amp;chdls=000000,10</xsl:text>
                                                                                    </xsl:variable>
                                                                                   
                                                                               
                                                                                
                                                                                <xsl:variable name="jsonDataDomains">
                                                                                    <xsl:for-each select="CampaignList/Campaigns/Row/Domains">
                                                                                        <xsl:if test="position() &lt; = 5">
                                                                                            <xsl:text>{ "label" : "</xsl:text>
                                                                                                <xsl:value-of select="Domain"/>
                                                                                            <xsl:text>", "value" : "</xsl:text>
                                                                                                <xsl:value-of select="Reads"/>
                                                                                            <xsl:text>" },</xsl:text>
                                                                                        </xsl:if>
                                                                                    </xsl:for-each>
                                                                                </xsl:variable>
                                                                                    <script>
                                                                                        var DataDomains= [<xsl:value-of select="$jsonDataDomains"></xsl:value-of>];

                                                                                    </script>

                                                                            <div id="chart-containerDomain">FusionCharts XT will load here!</div>
                                                                        </div>
                                                                    </div>
                                        
                                                                </div><!-- /.col-md-6 -->
                                                                <div class="col-md-12">
                                                                        <div class="box">
                                                                            <div class="box-body">
                                                                                <table id="example1" class="table table-bordered table-striped">
                                                                                <thead>
                                                                                <tr>
                                                                                    <th>Domain</th>
                                                                                    <th>Sent</th>
                                                                                    <th>Bounced</th>
                                                                                    <th>Read</th>
                                                                                    <th>Click</th>
                                                                                    <th>Unsub</th>
                                                                                    <th>Spam</th>
                                                                                </tr>
                                                                                </thead>
                                                                                <tbody>
                                                                                <xsl:for-each select="CampaignList/Campaigns/Row/Domains">
																	                <tr>
                                                                                            <td><xsl:value-of select="Domain"/></td>
                                                                                            <td>
                                                                                                <xsl:element name="a">
                                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=domainsent&#38;Q=<xsl:value-of select="CampID"/>&#38;D=<xsl:value-of select="Domain"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                    <xsl:value-of select="Sent"/>
                                                                                                </xsl:element>
                                                                                            </td>
                                                                                            <td>
                                                                                                <xsl:element name="a">
                                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=domainbbk&#38;Q=<xsl:value-of select="CampID"/>&#38;D=<xsl:value-of select="Domain"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                    <xsl:value-of select="BBacks"/></xsl:element>(<xsl:value-of select="BBackPrc"/>%)
                                                                                            </td>
                                                                                            <td>
                                                                                                <xsl:element name="a">
                                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=domainread&#38;Q=<xsl:value-of select="CampID"/>&#38;D=<xsl:value-of select="Domain"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                    <xsl:value-of select="Reads"/>
                                                                                                </xsl:element>(<xsl:value-of select="ReadPrc"/>%)
                                                                                            </td>
                                                                                            <td>
                                                                                                <xsl:element name="a">
                                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=domainclick&#38;Q=<xsl:value-of select="CampID"/>&#38;D=<xsl:value-of select="Domain"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                    <xsl:value-of select="Clicks"/>
                                                                                                </xsl:element>(<xsl:value-of select="ClickPrc"/>%)
                                                                                            </td>
                                                                                            <td>
                                                                                                <xsl:element name="a">
                                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=domainunsub&#38;Q=<xsl:value-of select="CampID"/>&#38;D=<xsl:value-of select="Domain"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                    <xsl:value-of select="Unsubs"/>
                                                                                                </xsl:element>(<xsl:value-of select="UnsubPrc"/>%)
                                                                                            </td>
                                                                                            <td>
                                                                                                <xsl:element name="a">
                                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=domainspam&#38;Q=<xsl:value-of select="CampID"/>&#38;D=<xsl:value-of select="Domain"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                    <xsl:value-of select="UnsubsSpam"/>
                                                                                                </xsl:element>(<xsl:value-of select="UnsubsSpamPrc"/>%)
                                                                                            </td>
                                                                                        </tr>
																                </xsl:for-each>
                                                                                
                                                                                </tbody> 
                                                                                </table>
                                                                            </div>
                                                                            <!-- /.box-body -->
                                                                        </div>
                                                                    
                                                                    </div>
                                                            </div><!-- /.box-body -->
                                                        </div><!-- /.box box-primary -->
                                                        <!-- Domain Deliverability End -->	
                                                        </xsl:if>
                                                     </xsl:if>

                                                    <xsl:if test="1 = /CampaignList/BBackSecFlag">

                                                        <div class="box box-primary">
                                                                <div class="box-header with-border">
                                                                <h3 class="box-title">Unsubscribe Categories</h3>
                                                                <div class="box-tools pull-right">
                                                                    <button type="button" class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i>  </button>
                                                                </div>
                                                                </div>
                                                                <div class="box-body" style="background-color:#f1f1f1;">
                                                                
                                                                    <div class="col-md-6">
                                                                        <div class="box">
                                                                            <div class="box-body no-padding">
                                                                                <table class="table table-striped" border="0" cellspacing="0" width="100%" cellpadding="0">
                                                                                    <tbody>
                                                                                        <tr>
                                                                                            <th></th>
                                                                                            <th># Unique</th>
                                                                                            <th>% Percent</th>
                                                                                        </tr>
                                                                                        <tr>
                                                                                            <td>Total Unsubscribes</td>
                                                                                            <td>
                                                                                                    <xsl:element name="div">
                                                                                                    <xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                                                        <div class="hovercontent">																		
                                                                                                            <xsl:element name="a">
                                                                                                                <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                                <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=unsub&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                                <xsl:value-of select="CampaignList/Campaigns/Row/Unsubs"/>
                                                                                                            </xsl:element>
                                                                                                        </div>
                                                                                                    </xsl:element>
                                                                                            </td>
                                                                                            <td>100%</td>
                                                                                        </tr>


                                                                                        <xsl:if test="count(CampaignList/Campaigns/Row/Unsub) &gt; 0">
                                                                                            <xsl:for-each select="CampaignList/Campaigns/Row/Unsub">
                                                                                                <tr>
                                                                                                    <td><xsl:value-of select="LevelName"/></td>
                                                                                                    <td>
                                                                                                        <xsl:element name="div">
                                                                                                        <xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                                                            <div class="hovercontent">																		
                                                                                                            <xsl:element name="a">
                                                                                                                <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                                <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=unsublevel&#38;Q=<xsl:value-of select="CampID"/>&#38;S=<xsl:value-of select="LevelID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                                <xsl:value-of select="Unsubs"/>
                                                                                                            </xsl:element>
                                                                                                            </div>
                                                                                                        </xsl:element>
                                                                                                    </td>
                                                                                                    <td><xsl:value-of select="UnsubsPrc"/>%</td>
                                                                                                </tr>	
                                                                                                
                                                                                            </xsl:for-each>
                                                                                            </xsl:if>


                                                                                    </tbody>
                                                                                </table>      
                                                                            </div>
                                                                        </div>
                                                                    
                                                                    </div>
                                                                    <div class="col-md-6">
                                                                        <div class="box">
                                                                            <div class="box-body no-padding">

                                                                                <xsl:if test="count(CampaignList/Campaigns/Row/Unsub) &gt; 0">
                                                                                        <xsl:variable name="jsonDataUnsubs">
                                                                                            <xsl:for-each select="CampaignList/Campaigns/Row/Unsub">
                                                                                                <xsl:text>{ "value" : "</xsl:text>
                                                                                                    <xsl:value-of select="Unsubs"/>	
                                                                                                    <xsl:text>", "label":"</xsl:text><xsl:value-of select="LevelName"/><xsl:text>" },</xsl:text>
                                                                                            </xsl:for-each>
                                                                                        </xsl:variable>

                                                                                         <xsl:variable name="unsubvalues">
                                                                                            <xsl:for-each select="CampaignList/Campaigns/Row/Unsub">
                                                                                                <xsl:value-of select="Unsubs"/>
                                                                                                <xsl:if test="not(position() = last())">
                                                                                                    <xsl:text>|</xsl:text>
                                                                                                </xsl:if>
                                                                                            </xsl:for-each>
                                                                                        </xsl:variable>

                                                                                        <xsl:variable name="unsublabels">
                                                                                            <xsl:for-each select="CampaignList/Campaigns/Row/Unsub">
                                                                                                <xsl:value-of select="LevelName"/>
                                                                                                <xsl:if test="not(position() = last())">
                                                                                                    <xsl:text>|</xsl:text>
                                                                                                </xsl:if>
                                                                                            </xsl:for-each>
                                                                                        </xsl:variable>

                                                                                        <xsl:variable name="unsublink">
                                                                                            <xsl:text>http://chart.apis.google.com/chart?chf=bg,s,FFFFFF&amp;chxl=1:|%250|%2525|%2550|%2575|%25100&amp;chxs=0,676767,10|1,FFFFFF,10,0,l,676767&amp;chxt=x,y&amp;chs=300x150&amp;cht=gm&amp;chco=FFCC33,FFFFFF,008000|80C65A|FFCC33|FFFF88|FF0000|AA0033&amp;chd=t:</xsl:text><xsl:value-of select='$unsubvalues'/><xsl:text>&amp;chl=</xsl:text><xsl:value-of select='$unsublabels'/>
                                                                                        </xsl:variable>

                                                                                         <script>
                                                                                         

                                                                                              FusionCharts.ready(function(){
                                                                                            var fusionchartsUnsubscribe = new FusionCharts({
                                                                                                    type: 'doughnut2d',
                                                                                                    renderAt: 'chart-containerUnsubscribe',
                                                                                                    width: '100%', 
                                                                                                    dataFormat: 'json',
                                                                                                    dataSource: {
                                                                                                        "chart": {
                                                                                                            "showBorder": "0",
                                                                                                            "use3DLighting": "0",
                                                                                                            "enableSmartLabels": "0",
                                                                                                            "startingAngle": "310",
                                                                                                            "showLabels": "0",
                                                                                                            "showPercentValues": "1",
                                                                                                            "showLegend": "1",
                                                                                                            "centerLabel": "$value",
                                                                                                            "centerLabelBold": "1",
                                                                                                            "showTooltip": "0",
                                                                                                            "decimals": "0",
                                                                                                            "useDataPlotColorForLabels": "1",
                                                                                                            "theme": "fint",
                                                                                                            "palettecolors":"FAA926,59C8E6"
                                                                                                        },
                                                                                                        "data": [ <xsl:value-of select="$jsonDataUnsubs"></xsl:value-of>]
                                                                                                    }
                                                                                                }
                                                                                                );
                                                                                                    fusionchartsUnsubscribe.render();
                                                                                                    });
                                                                                        </script>

                                                                                        
                                                                                        
                                                                                </xsl:if>
                                                                                       
                                                                                 <div id="chart-containerUnsubscribe">FusionCharts XT will load here!</div>
                                                                               
                                                                            </div>
                                                                        </div>
                                            
                                                                    </div><!-- /.col-md-6 -->
                                                                </div><!-- /.box-body -->
                                                        </div><!-- /.box box-primary -->
                                                    
                                                    </xsl:if>


                                                    <xsl:if test="1 = /CampaignList/OptoutFlag">
                                                        <!-- Newsletter Opt-outs Start -->
                                                        
                                                         <div class="box box-primary">
                                                                <div class="box-header with-border">
                                                                <h3 class="box-title">Newsletter Optouts</h3>
                                                                <div class="box-tools pull-right">
                                                                    <button type="button" class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i>  </button>
                                                                </div>
                                                                </div>
                                                                <div class="box-body" style="background-color:#f1f1f1;">
                                                                
                                                                    <div class="col-md-12">
                                                                        <div class="box">
                                                                            <div class="box-body no-padding">
                                                                                <table class="table table-striped" border="0" cellspacing="0" width="100%" cellpadding="0">
                                                                                    <tbody>
                                                                                        <tr>
                                                                                             <td></td>
                                                                                             <td># Unique</td>
                                                                                        </tr>
                                                                                        <tr>
                                                                                            <td>Total Reaching</td>
                                                                                            <td>
                                                                                                <xsl:element name="div">
                                                                                                <xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                                                    <div class="hovercontent">																		
                                                                                                        <xsl:element name="a">
                                                                                                            <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                            <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=rcvd&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                            <xsl:value-of select="CampaignList/Campaigns/Row/Reaching"/>
                                                                                                        </xsl:element>
                                                                                                    </div>
                                                                                                </xsl:element>
                                                                                          </td>
                                                                                        </tr>
                                                                                    </tbody>
                                                                                </table>      
                                                                            </div>
                                                                        </div>
                                                                    
                                                                    </div>
                                                                    
                                                                </div><!-- /.box-body -->
                                                        </div><!-- /.box box-primary -->
         
                                                        <!-- Newsletter Opt-outs End -->
                                                    </xsl:if>	

                                                    <xsl:if test="1 = /CampaignList/FormSecFlag">
                                                        <!-- form submissions Start -->
                                                        <div class="box box-primary">
                                                                <div class="box-header with-border">
                                                                <h3 class="box-title">Form Submissions</h3>
                                                                <div class="box-tools pull-right">
                                                                    <button type="button" class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i>  </button>
                                                                </div>
                                                                </div>
                                                                <div class="box-body" style="background-color:#f1f1f1;">
                                                                
                                                                    <div class="col-md-12">
                                                                        <div class="box">
                                                                            <div class="box-body no-padding">
                                                                                <table class="table table-striped" border="0" cellspacing="0" width="100%" cellpadding="0">
                                                                                    <tbody>
                                                                                        <tr>
                                                                                            <th>Form Name</th>
                                                                                            <th>Page Views</th>
                                                                                            <th>Submissions</th>
                                                                                            <th>Multiple Times</th>
                                                                                            <th>Submit</th>
                                                                                        </tr>
                                                                                        <xsl:for-each select="CampaignList/Campaigns/Row/Forms">
                                                                                            <tr>
                                                                                                <td><xsl:value-of select="FirstFormName"/></td>
                                                                                                <td>
                                                                                                    <xsl:element name="a">
                                                                                                        <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                        <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=view&#38;Q=<xsl:value-of select="CampID"/>&#38;F=<xsl:value-of select="FirstFormID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                        <xsl:value-of select="DistinctViews"/>
                                                                                                    </xsl:element>
                                                                                                </td>
                                                                                                <td>
                                                                                                    <xsl:element name="a">
                                                                                                        <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                        <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=submit&#38;Q=<xsl:value-of select="CampID"/>&#38;F=<xsl:value-of select="LastFormID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                        <xsl:value-of select="DistinctSubmits"/>
                                                                                                    </xsl:element>
                                                                                                    (<xsl:value-of select="DistinctViewSubmitPrc"/>%)
                                                                                                </td>
                                                                                                <td>
                                                                                                    <xsl:element name="a">
                                                                                                        <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                        <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multisubmit&#38;Q=<xsl:value-of select="CampID"/>&#38;F=<xsl:value-of select="LastFormID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                        <xsl:value-of select="MultiSubmitters"/>
                                                                                                    </xsl:element>
                                                                                                </td>
                                                                                                <td><xsl:value-of select="LastFormName"/></td>
                                                                                            </tr>
                                                                                        </xsl:for-each>	
                                                                                        <tr>
                                                                                            <td>Form Name</td>
                                                                                            <td>Page Views</td>
                                                                                            <td>Submissions</td>
                                                                                            <td>Multiple Times</td>
                                                                                            <td>Submit</td>
                                                                                        </tr>
                                                                                        <xsl:for-each select="CampaignList/Campaigns/Row/Forms">
                                                                                            <tr>
                                                                                                <td><xsl:value-of select="FirstFormName"/></td>
                                                                                                <td>
                                                                                                    <xsl:element name="a">
                                                                                                        <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                        <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=view&#38;Q=<xsl:value-of select="CampID"/>&#38;F=<xsl:value-of select="FirstFormID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                        <xsl:value-of select="TotalViews"/>
                                                                                                    </xsl:element>
                                                                                                </td>
                                                                                                <td>
                                                                                                    <xsl:element name="a">
                                                                                                        <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                        <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=submit&#38;Q=<xsl:value-of select="CampID"/>&#38;F=<xsl:value-of select="LastFormID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                        <xsl:value-of select="TotalSubmits"/>
                                                                                                    </xsl:element>
                                                                                                    (<xsl:value-of select="TotalViewSubmitPrc"/>%)
                                                                                                </td>
                                                                                                <td>
                                                                                                    <xsl:element name="a">
                                                                                                        <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                        <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multisubmit&#38;Q=<xsl:value-of select="CampID"/>&#38;F=<xsl:value-of select="LastFormID"/>&#38;Z=<xsl:value-of select="/CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="/CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                        <xsl:value-of select="MultiSubmitters"/>
                                                                                                    </xsl:element>
                                                                                                </td>
                                                                                                <td><xsl:value-of select="LastFormName"/></td>
                                                                                            </tr>
                                                                                        </xsl:for-each>
                                                                                    </tbody>
                                                                                </table>      
                                                                            </div>
                                                                        </div>
                                                                    
                                                                    </div>
                                                                    
                                                                </div><!-- /.box-body -->
                                                        </div><!-- /.box box-primary -->
                                                        <!-- form submissions end -->
                                                    </xsl:if>	

                                                       
                                                    <xsl:if test="1 = /CampaignList/DistClickSecFlag">
                                                    <!-- Additional Metrics Start -->
                                                        <div class="box box-primary">
                                                                    <div class="box-header with-border">
                                                                    <h3 class="box-title">Additional Metrics</h3>
                                                                    <div class="box-tools pull-right">
                                                                        <button type="button" class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i>  </button>
                                                                    </div>
                                                                    </div>
                                                                    <div class="box-body" style="background-color:#f1f1f1;">
                                                                    
                                                                        <div class="col-md-12">
                                                                            <div class="box">
                                                                                <div class="box-body no-padding">
                                                                                    <table class="table table-striped" border="0" cellspacing="0" width="100%" cellpadding="0">
                                                                                        <tbody>
                                                                                            <tr>
                                                                                                <th></th>
                                                                                                <th># Count</th>
                                                                                            </tr>
                                                                                             <xsl:if test="1 = /CampaignList/TotReadFlag">
                                                                                                <tr>
                                                                                                    <td>Total HTML Email views</td>
                                                                                                    <td>
                                                                                                        <xsl:element name="div">
                                                                                                        <xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                                                            <div class="hovercontent">																		
                                                                                                                <xsl:element name="a">
                                                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=read&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                                    <xsl:value-of select="CampaignList/Campaigns/Row/TotalReads"/>
                                                                                                                </xsl:element>
                                                                                                            </div>
                                                                                                        </xsl:element>
                                                                                                    </td>
                                                                                                </tr>
                                                                                            </xsl:if>
                                                                                            <xsl:if test="1 = /CampaignList/MultiReadFlag">
                                                                                            <tr>
                                                                                                <td>Opened HTML Email more than once</td>
                                                                                                <td>
                                                                                                    <xsl:element name="div">
                                                                                                    <xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                                                        <div class="hovercontent">																		
                                                                                                            <xsl:element name="a">	
                                                                                                                <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                                <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multiread&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                                <xsl:value-of select="CampaignList/Campaigns/Row/MultiReaders"/>
                                                                                                            </xsl:element>
                                                                                                        </div>
                                                                                                    </xsl:element>
                                                                                                </td>
                                                                                            </tr>
                                                                                            </xsl:if>
                                                                                            <xsl:if test="1 = /CampaignList/TotClickFlag">
                                                                                                <tr>
                                                                                                    <td>Aggregate Clickthroughs</td>
                                                                                                    <td>
                                                                                                        <xsl:element name="div">
                                                                                                        <xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                                                            <div class="hovercontent">																		
                                                                                                                <xsl:element name="a">
                                                                                                                        <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                                        <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                                        <xsl:value-of select="CampaignList/Campaigns/Row/TotalClicks"/>
                                                                                                                    </xsl:element>
                                                                                                            </div>
                                                                                                        </xsl:element>
                                                                                                    </td>
                                                                                                </tr>
                                                                                            </xsl:if>
                                                                                            <xsl:if test="1 = /CampaignList/MultiLinkClickFlag">
                                                                                                <tr>
                                                                                                    <td>Clicked on more than one link</td>
                                                                                                    <td>
                                                                                                        <xsl:element name="div">
                                                                                                                <xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                                                                    <div class="hovercontent">																		
                                                                                                                        <xsl:element name="a">
                                                                                                                            <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                                            <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multilink&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                                            <xsl:value-of select="CampaignList/Campaigns/Row/MultiLinkClickers"/>
                                                                                                                        </xsl:element>
                                                                                                            </div>
                                                                                                        </xsl:element>
                                                                                                    </td>
                                                                                                </tr>
                                                                                            </xsl:if>
                                                                                            <xsl:if test="1 = /CampaignList/LinkMultiClickFlag">
                                                                                                <tr>
                                                                                                    <td>Clicked on one link multiple times</td>
                                                                                                    <td>
                                                                                                        <xsl:element name="div">
                                                                                                            <xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                                                                <div class="hovercontent">																		
                                                                                                                    <xsl:element name="a">
                                                                                                            <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                            <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multiclick&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                            <xsl:value-of select="CampaignList/Campaigns/Row/OneLinkMultiClickers"/>
                                                                                                            </xsl:element>
                                                                                                            </div>
                                                                                                        </xsl:element>
                                                                                                    </td>
                                                                                                </tr>
                                                                                            </xsl:if>
                                                                                                    
                                                                                        </tbody>
                                                                                    </table>      
                                                                                </div>
                                                                            </div>
                                                                        
                                                                        </div>
                                                                        
                                                                    </div><!-- /.box-body -->
                                                        </div><!-- /.box box-primary -->
                                                    <!-- Additional Metrics End -->
                                                    </xsl:if>  

                                                    <xsl:if test="1 = /CampaignList/ActionSecFlag">
								                    <!-- Reciepent Actions Start -->

                                                        <div class="box box-primary">
                                                                    <div class="box-header with-border">
                                                                        <h3 class="box-title">Recipient Actions</h3>
                                                                        <div class="box-tools pull-right">
                                                                            <button type="button" class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i>  </button>
                                                                        </div>
                                                                    </div>
                                                                    <div class="box-body" style="background-color:#f1f1f1;">
                                                                            <div class="col-md-6">
                                                                                <div class="box">
                                                                                    <div class="box-body no-padding">
                                                                                        <table class="table table-striped" border="0" cellspacing="0" width="100%" cellpadding="0">
                                                                                            <tbody>
                                                                                            <tr>
                                                                                                <td></td>
                                                                                                <td># Unique</td>
                                                                                                <td>% Percent</td>
                                                                                            </tr>
                                                                                            <tr>
                                                                                                <td>Total Reaching</td>
                                                                                                <td>
                                                                                                    <xsl:element name="div">
                                                                                                        <xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                                                            <div class="hovercontent">																		
                                                                                                            <xsl:element name="a">
                                                                                                            <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                            <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=rcvd&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                            <xsl:value-of select="CampaignList/Campaigns/Row/Reaching"/>
                                                                                                            </xsl:element>
                                                                                                        </div>
                                                                                                    </xsl:element>
                                                                                                </td>
                                                                                                <td>100%</td>
                                                                                            </tr>
                                                                                            <tr>
                                                                                                <td>Total Open HTML</td>
                                                                                                <td>
                                                                                                    <xsl:element name="div">
                                                                                                        <xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                                                            <div class="hovercontent">																		
                                                                                                            <xsl:element name="a">
                                                                                                                <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                                <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=read&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                                <xsl:value-of select="CampaignList/Campaigns/Row/DistinctReads"/>
                                                                                                            </xsl:element>
                                                                                                        </div>
                                                                                                    </xsl:element>
                                                                                                </td>
                                                                                                <td><xsl:value-of select="CampaignList/Campaigns/Row/DistinctReadPrc"/>%</td>
                                                                                            </tr>
                                                                                            <tr>
                                                                                                <td>Total Click Throughs</td>
                                                                                                <td>
                                                                                                    <xsl:element name="div">
                                                                                                        <xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                                                            <div class="hovercontent">																		
                                                                                                            <xsl:element name="a">
                                                                                                                <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                                <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                                <xsl:value-of select="CampaignList/Campaigns/Row/DistinctClicks"/>
                                                                                                            </xsl:element>
                                                                                                        </div>
                                                                                                    </xsl:element>
                                                                                                </td>
                                                                                                <td><xsl:value-of select="CampaignList/Campaigns/Row/DistinctClickPrc"/>%</td>
                                                                                            </tr>
                                                                                            <tr>
                                                                                                <td>Total Unsubscribes</td>
                                                                                                <td>
                                                                                                    <xsl:element name="div">
                                                                                                        <xsl:attribute name="class"><xsl:value-of select="CampaignList/Campaigns/Row/Id"/></xsl:attribute>
                                                                                                            <div class="hovercontent">																		
                                                                                                                <xsl:element name="a">
                                                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=unsub&#38;Q=<xsl:value-of select="CampaignList/Campaigns/Row/Id"/>&#38;Z=<xsl:value-of select="CampaignList/ReportCache"/>&#38;C=<xsl:value-of select="CampaignList/Campaigns/Row/CacheId"/>');</xsl:attribute>
                                                                                                                    <xsl:value-of select="CampaignList/Campaigns/Row/Unsubs"/>
                                                                                                                </xsl:element>
                                                                                                        </div>
                                                                                                    </xsl:element>
                                                                                                </td>
                                                                                                <td><xsl:value-of select="CampaignList/Campaigns/Row/UnsubPrc"/>%</td>
                                                                                            </tr>
                                                                                            </tbody>
                                                                                        </table>      
                                                                                    </div>
                                                                                </div>
                                                                            
                                                                            </div>
                                                                            <div class="col-md-6">
                                                                                <div class="box">
                                                                                    <div class="box-body no-padding">
                                                                                            <xsl:variable name="recActionsLink">
                                                                                                <xsl:text>http://chart.apis.google.com/chart?chf=bg,s,FFFFFF&amp;chxl=0:|%250|%2520|%2540|%2560|%2580|%25100|1:|Open HTML|Click Throughs|Unsubscribes&amp;chxs=0,000000,10,0,l,676767|1,000000,10,0,l,676767&amp;chxt=x,y&amp;chbh=14,10,10&amp;chs=300x100&amp;cht=bhs&amp;chco=3399CC&amp;chd=t:</xsl:text>
                                                                                                    <xsl:value-of select="CampaignList/Campaigns/Row/UnsubPrc"/>
                                                                                                    <xsl:text>,</xsl:text>
                                                                                                    <xsl:value-of select="CampaignList/Campaigns/Row/DistinctClickPrc"/>
                                                                                                    <xsl:text>,</xsl:text>
                                                                                                    <xsl:value-of select="CampaignList/Campaigns/Row/DistinctReadPrc"/>
                                                                                                <xsl:text>&amp;chdlp=b&amp;chg=20,20,2,2&amp;chm=N%25,CCCCCC,0,-1,10</xsl:text>
                                                                                            </xsl:variable>

                                                                                        <script>
                                                                                            var DistinctReads="<xsl:value-of select="CampaignList/Campaigns/Row/DistinctReads"/>";
                                                                                            var DistinctClicks="<xsl:value-of select="CampaignList/Campaigns/Row/DistinctClicks"/>";
                                                                                            var Unsubs2="<xsl:value-of select="CampaignList/Campaigns/Row/Unsubs"/>";

                                                                                        </script>
                                                                                        <div id="chart-containerRecipient">FusionCharts XT will load here!</div>
                                                                                    </div>
                                                                                </div>
                                                    
                                                                            </div><!-- /.col-md-6 -->
                                                                    </div><!-- /.box-body -->
                                                        </div><!-- /.box box-primary -->
                                                    
                                                    <!-- Reciepent Actions End -->
                                                    </xsl:if>  
                                                </div><!-- /.col-md-6 RİGHT connectedSortable END -->
                                         
                                        </div><!-- /.row END -->

                                    </section>



<script src="assets/js/jquery.min.js"></script>
<script src="assets/js/bootstrap.min.js"></script>
<script src="assets/js/adminlte.min.js"></script>
 <!-- FastClick -->
<script src="assets/js/fastclick.js"></script>
<!-- AdminLTE for demo purposes -->
<script src="assets/js/demo.js"></script>

<script src="assets/js/DataTable/jquery.dataTables.min.js"></script>
<script src="assets/js/DataTable/dataTables.bootstrap.min.js"></script>
<script src="assets/js/DataTable/jquery.slimscroll.min.js"></script>

<script src="assets/js/jquery-ui.min.js"></script>



<script src="../../js/report/scripts_compressed_zaf.js"></script>

<script type="text/javascript">

  $('.connectedSortable').sortable({
    placeholder         : 'sort-highlight',
    connectWith         : '.connectedSortable',
    handle              : '.box-header, .nav-tabs',
    forcePlaceholderSize: true,
    zIndex              : 999999
  });
  $('.connectedSortable .box-header, .connectedSortable .nav-tabs-custom').css('cursor', 'move');

 
  $(function () {
     
    $('#example1').DataTable({
      'paging'      : true,
      'lengthChange': false,
      'searching'   : false,
      'ordering'    : false,
      'info'        : true,
      'autoWidth'   : false
    })

    $('#example2').DataTable({
      'paging'      : true,
      'lengthChange': false,
      'searching'   : false,
      'ordering'    : false,
      'info'        : true,
      'autoWidth'   : false
    })
     $('#example3').DataTable({
      'paging'      : true,
      'lengthChange': false,
      'searching'   : false,
      'ordering'    : false,
      'info'        : true,
      'autoWidth'   : false
    })
  })
 


  FusionCharts.ready(function(){
  var fusionchartsReceived = new FusionCharts({
  type: 'doughnut2d',
  renderAt: 'chart-Received',
  width: '100%', 
  dataFormat: 'json',
  dataSource: {
      "chart": {
          "showBorder": "0",
          "use3DLighting": "0",
          "enableSmartLabels": "0",
          "startingAngle": "310",
          "showLabels": "0",
          "showPercentValues": "1",
          "showLegend": "1",
          "centerLabel": "$value",
          "centerLabelBold": "1",
          "showTooltip": "0",
          "decimals": "0",
          "useDataPlotColorForLabels": "1",
          "theme": "fint",
          "palettecolors":"888D90,A587BE"
      },
     
      "data": [{
          "label": "Bounced",
          "value": "<xsl:value-of select="100 - CampaignList/Campaigns/Row/ReachingPrc"/>"
      }, {
          "label": "Received",
          "value": "<xsl:value-of select="CampaignList/Campaigns/Row/ReachingPrc"/>"
      } ]
  }
  });
  fusionchartsReceived.render();


  var fusionchartsRead = new FusionCharts({
  type: 'doughnut2d',
  renderAt: 'chart-Read',
  width: '100%', 
  dataFormat: 'json',
  dataSource: {
      "chart": {
          "showBorder": "0",
          "use3DLighting": "0",
          "enableSmartLabels": "0",
          "startingAngle": "310",
          "showLabels": "0",
          "showPercentValues": "1",
          "showLegend": "1",
          "centerLabel": "$value",
          "centerLabelBold": "1",
          "showTooltip": "0",
          "decimals": "0",
          "useDataPlotColorForLabels": "1",
          "theme": "fint",
          "palettecolors":"A587BE,59C8E6"
      },
      "data": [{
          "label": "Recieved",
          "value": "<xsl:value-of select="100 - CampaignList/Campaigns/Row/DistinctReadPrc"/>"
      }, {
          "label": "Read",
          "value": "<xsl:value-of select="CampaignList/Campaigns/Row/DistinctReadPrc"/>"
      } ]
 
  }
  });
  fusionchartsRead.render();

  var fusionchartsClick = new FusionCharts({
  type: 'doughnut2d',
  renderAt: 'chart-Click',
  width: '100%', 
  dataFormat: 'json',
  dataSource: {
      "chart": {
          "showBorder": "0",
          "use3DLighting": "0",
          "enableSmartLabels": "0",
          "startingAngle": "310",
          "showLabels": "0",
          "showPercentValues": "1",
          "showLegend": "1",
          "centerLabel": "$value",
          "centerLabelBold": "1",
          "showTooltip": "0",
          "decimals": "0",
          "useDataPlotColorForLabels": "1",
          "theme": "fint",
          "palettecolors":"888D90,84C446"
      },
      "data": [{
          "label": "No Clicks",
          "value": "<xsl:value-of select="100 - CampaignList/Campaigns/Row/DistinctClickPrc"/>"
      }, {
          "label": "Clicks",
          "value": "<xsl:value-of select="CampaignList/Campaigns/Row/DistinctClickPrc"/>"
      } ]

     
  }
  });
  fusionchartsClick.render();

  var fusionchartsUnsub = new FusionCharts({
  type: 'doughnut2d',
  renderAt: 'chart-Unsub',
  width: '100%', 
  dataFormat: 'json',
  dataSource: {
      "chart": {
          "showBorder": "0",
          "use3DLighting": "0",
          "enableSmartLabels": "0",
          "startingAngle": "310",
          "showLabels": "0",
          "showPercentValues": "1",
          "showLegend": "1",
          "centerLabel": "$value",
          "centerLabelBold": "1",
          "showTooltip": "0",
          "decimals": "0",
          "useDataPlotColorForLabels": "1",
          "theme": "fint" ,
          "palettecolors":"A587BE,f56954"
      },
      "data": [{
          "label": "Received",
          "value": "<xsl:value-of select="100 - CampaignList/Campaigns/Row/UnsubPrc"/>"
      }, {
          "label": "Unsubs",
          "value": "<xsl:value-of select="CampaignList/Campaigns/Row/UnsubPrc"/>"
      } ]
     
  }
  });
  fusionchartsUnsub.render();
 

  var fusionchartsLink = new FusionCharts({
        type: 'stackedbar2d',
        renderAt: 'chart-containerLink',
        width: '100%', 
        dataFormat: 'json',
        dataSource: {
            "chart": {
                "theme": "fint",
                //"xAxisname": "Quarter",
            //  "yAxisName": "Revenues (In USD)",
                //Showing the Cumulative Sum of stacked data
               // "showSum": "1",
               // "numberPrefix": "$"
            },
            "categories": [{
                "category": Category
            }],
            "dataset": [{
                    "seriesname": "Text",
                    "color": "0080C0",
                    "data": Text
                },
                {
                    "seriesname": "HTML",
                    "color": "F6BD0F",
                    "data": Html
                }
            ]
        }
    });

  fusionchartsLink.render();
      



  var fusionchartsBounceback = new FusionCharts({
    type: 'bar2d',
    renderAt: 'chart-containerBounceback',
    width: '100%', 
    dataFormat: 'json',
    dataSource: {
        "chart": {
            "paletteColors": "#0075c2",
            "bgColor": "#ffffff",
            "showBorder": "0",
            "showCanvasBorder": "0",
            "usePlotGradientColor": "0",
            "plotBorderAlpha": "10",
            "placeValuesInside": "1",
            "valueFontColor": "#ffffff",
            "showAxisLines": "1",
            "axisLineAlpha": "25",
            "divLineAlpha": "10",
            "alignCaptionWithCanvas": "0",
            "showAlternateVGridColor": "0",
            "captionFontSize": "14",
            "subcaptionFontSize": "14",
            "subcaptionFontBold": "0",
            "toolTipColor": "#ffffff",
            "toolTipBorderThickness": "0",
            "toolTipBgColor": "#000000",
            "toolTipBgAlpha": "80",
            "toolTipBorderRadius": "2",
            "toolTipPadding": "5"
        },

        "data":  bback
    }
});
    fusionchartsBounceback.render();


    var fusionchartsDomain = new FusionCharts({
    type: 'doughnut2d',
    renderAt: 'chart-containerDomain',
    width: '100%', 
    dataFormat: 'json',
    dataSource: {
        "chart": {
            "showBorder": "0",
            "use3DLighting": "0",
            "enableSmartLabels": "0",
            "startingAngle": "310",
            "showLabels": "0",
            "showPercentValues": "1",
            "showLegend": "1",
            "centerLabel": "$value",
            "centerLabelBold": "1",
            "showTooltip": "0",
            "decimals": "0",
            "useDataPlotColorForLabels": "1",
            "theme": "fint",
            "palettecolors":"FAA926,59C8E6,90D1CE,A587BE,84C446"
        },
        "data": DataDomains
    }
}
);
    fusionchartsDomain.render();

  

 var fusionchartsRecipient = new FusionCharts({
    type: 'bar2d',
    renderAt: 'chart-containerRecipient',
    width: '100%', 
    dataFormat: 'json',
    dataSource: {
        "chart": {
            "paletteColors": "#0075c2",
            "bgColor": "#ffffff",
            "showBorder": "0",
            "showCanvasBorder": "0",
            "usePlotGradientColor": "0",
            "plotBorderAlpha": "10",
            "placeValuesInside": "1",
            "valueFontColor": "#ffffff",
            "showAxisLines": "1",
            "axisLineAlpha": "25",
            "divLineAlpha": "10",
            "alignCaptionWithCanvas": "0",
            "showAlternateVGridColor": "0",
            "captionFontSize": "14",
            "subcaptionFontSize": "14",
            "subcaptionFontBold": "0",
            "toolTipColor": "#ffffff",
            "toolTipBorderThickness": "0",
            "toolTipBgColor": "#000000",
            "toolTipBgAlpha": "80",
            "toolTipBorderRadius": "2",
            "toolTipPadding": "5"
        },

        "data": [
            {
                "label": "Open HTML",
                "value": "<xsl:value-of select="CampaignList/Campaigns/Row/DistinctReads"/>",
                "color": "59C8E6"
            },
            {
                "label": "Click Throughs",
                "value": "<xsl:value-of select="CampaignList/Campaigns/Row/DistinctClicks"/>",
                "color": "84C446"
            },
            {
                "label": "Unsubscribes",
                "value": "<xsl:value-of select="CampaignList/Campaigns/Row/Unsubs"/>",
                "color": "f56954"
            }
        ]
    }
});
    fusionchartsRecipient.render();

 

  });
</script>
 

                            </xsl:when>
                            <!--  End CampaignList/OnlyOne -->
                    
                            <!-- Start CampaignList/TotalsSecFlag -->
                                <xsl:otherwise>

                                    <link rel="stylesheet" media="all" type="text/css" href="http://cms.revotas.com/cms/ui/css/reset.css" />
			                        <link rel="stylesheet" media="all" type="text/css" href="http://cms.revotas.com/cms/ui/css/style_compressed_zaf.css" />
			                        <script type="text/javascript" src="http://cms.revotas.com/cms/ui/js/report/main_compressed_zaf.js"></script>	
                                    
                                    <div class="wrapper">
                                        <div id="sortableColumnLeft" class="droptrue moveObj" style="width:100%;border:none;">
                                            <xsl:if test="1 = /CampaignList/TotalsSecFlag">
                                            <!-- Campaign Info Start -->
                                            <div class="ui-state-default sectionblock" id="section-CampInfo">
                                                <a class="sectionSheaders" href="javascript:toggleContentBox('reportCampInfo')"><img id="reportCampInfo_excol" style="border:none;" src="http://www.revotas.com/sq_minus_icon16.png" alt="expand-collapse" /> <span>Campaign Info</span></a>	
                                                <div id="reportCampInfo" style="display:block;">
                                                    <table cellpadding="0" cellspacing="0" border="0" width="100%">
                                                        <tr class="sectionContainerTbl">
                                                            <td width="">
                                                                <table cellpadding="0" width="100%" cellspacing="0" border="0" class="borderTbl">
                                                                    <tr class="sectionHeaders">
                                                                        <td width="300">Campaign Name</td>
                                                                        <td width="150">Date</td>
                                                                        <td width="150">Total Sent</td>
                                                                        <td width="150">Bounce Backs</td>
                                                                        <td width="150">Open</td>
                                                                        <td width="150">Click Throughs</td>
                                                                        <td>Unsubscribes</td>
                                                                    </tr>
                                                                    <xsl:for-each select="CampaignList/Campaigns/Row">
                                                                        <xsl:variable name="aColor">
                                                                            <xsl:choose>
                                                                                <xsl:when test="position() mod 2 = 1">
                                                                                    <xsl:text>nobg</xsl:text>
                                                                                </xsl:when>
                                                                            <xsl:otherwise>contentRows</xsl:otherwise>
                                                                        </xsl:choose>
                                                                        </xsl:variable>
                                                                        
                                                                            <tr class="{$aColor}">
                                                                            
                                                                                <td width="">
                                                                                    <xsl:element name="a">
                                                                                        <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                        <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/CampaignView"/>?act=VIEW&#38;id=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');
                                                                                        </xsl:attribute>
                                                                                        <xsl:value-of select="Name"/>
                                                                                    </xsl:element> (cache=<xsl:value-of select="CacheId"/>)
                                                                                </td>
                                                                                <td><xsl:value-of select="StartDate"/></td>
                                                                                <td>
                                                                                    <xsl:element name="a">
                                                                                        <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                        <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=all&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');
                                                                                        </xsl:attribute>
                                                                                        <xsl:value-of select="Size"/>
                                                                                    </xsl:element>
                                                                                </td>
                                                                                <td>
                                                                                    <xsl:element name="a">
                                                                                        <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                        <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=bbk&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');
                                                                                        </xsl:attribute>
                                                                                        <xsl:value-of select="BBacks"/> 
                                                                                    </xsl:element>
                                                                                    (<xsl:value-of select="BBackPrc"/>%)
                                                                                </td>
                                                                                <td>
                                                                                    <xsl:element name="a">
                                                                                        <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                        <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=read&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');
                                                                                        </xsl:attribute>
                                                                                        <xsl:value-of select="DistinctReads"/>
                                                                                    </xsl:element>
                                                                                    (<xsl:value-of select="DistinctReadPrc"/>%)
                                                                                </td>
                                                                                <td>
                                                                                    <xsl:element name="a">
                                                                                        <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                        <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');
                                                                                        </xsl:attribute>
                                                                                        <xsl:value-of select="DistinctClicks"/>
                                                                                    </xsl:element>
                                                                                    (<xsl:value-of select="DistinctClickPrc"/>%)
                                                                                </td>														
                                                                                <td>
                                                                                    <xsl:element name="a">
                                                                                        <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                        <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=unsub&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');
                                                                                        </xsl:attribute>
                                                                                        <xsl:value-of select="Unsubs"/>
                                                                                    </xsl:element>
                                                                                    (<xsl:value-of select="UnsubPrc"/>%)
                                                                                </td>
                                                                            </tr>
                                                                    </xsl:for-each>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </div>
                                            </div>
                                            <!-- Campaign Info End -->
                                            </xsl:if>
                                            <xsl:if test="1 = /CampaignList/GeneralSecFlag">
                                            <!-- General Campaign Statistics Start -->
                                            <div class="ui-state-default sectionblock" id="section-GenCampStats">
                                                <a class="sectionSheaders" href="javascript:toggleContentBox('reportGenCampStats')"><img id="reportGenCampStats_excol" style="border:none;" src="http://www.revotas.com/sq_minus_icon16.png" alt="expand-collapse" /> <span>General Campaign  Statistics</span></a>	
                                                <div id="reportGenCampStats" style="display:block;">
                                                    <table cellpadding="0" cellspacing="0" border="0" width="100%">
                                                        <tr class="sectionContainerTbl">
                                                            <td width="">
                                                                <table cellpadding="0" width="100%" cellspacing="0" border="0" class="borderTbl">
                                                                    <tr class="sectionHeaders">
                                                                        <td width="300">Campaign Name</td>
                                                                        <td width="150">Total Sent</td>
                                                                        <td width="150">Total Bouncebacks</td>
                                                                        <td>Total Reaching</td>
                                                                    </tr>
                                                                    <xsl:for-each select="CampaignList/Campaigns/Row">
                                                                        <xsl:variable name="aColor">
                                                                            <xsl:choose>
                                                                                <xsl:when test="position() mod 2 = 1">
                                                                                    <xsl:text>nobg</xsl:text>
                                                                                </xsl:when>
                                                                            <xsl:otherwise>contentRows</xsl:otherwise>
                                                                        </xsl:choose>
                                                                        </xsl:variable>
                                                                        
                                                                        <tr class="{$aColor}">
                                                                            
                                                                            <td width="">
                                                                                <xsl:element name="a">
                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/CampaignView"/>?act=VIEW&#38;id=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');
                                                                                    </xsl:attribute>
                                                                                    <xsl:value-of select="Name"/>
                                                                                </xsl:element> (cache=<xsl:value-of select="CacheId"/>)
                                                                            </td>
                                                                            <td>
                                                                                <xsl:element name="a">
                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=all&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');
                                                                                    </xsl:attribute>
                                                                                    <xsl:value-of select="Size"/>
                                                                                </xsl:element>
                                                                            </td>
                                                                            <td>
                                                                                <xsl:element name="a">
                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=bbk&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');
                                                                                    </xsl:attribute>
                                                                                    <xsl:value-of select="BBacks"/>
                                                                                </xsl:element>
                                                                                (<xsl:value-of select="BBackPrc"/>%)
                                                                            </td>
                                                                            <td>
                                                                                <xsl:element name="a">
                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=rcvd&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');
                                                                                    </xsl:attribute>
                                                                                    <xsl:value-of select="Reaching"/>
                                                                                </xsl:element>
                                                                                (<xsl:value-of select="ReachingPrc"/>%)
                                                                            </td>
                                                                        </tr>
                                                                    </xsl:for-each>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </div>
                                            </div>
                                            <!-- General Campaign Statistics End -->
                                            </xsl:if>
                                            
                                            <xsl:if test="1 = /CampaignList/DistClickSecFlag">
                                                <!-- Detailed Clickthrough Info Start -->
                                                <div class="ui-state-default sectionblock" id="section-DetCTInfo">
                                                    <a class="sectionSheaders" href="javascript:toggleContentBox('reportDetCTInfo')"><img id="reportDetCTInfo_excol" style="border:none;" src="http://www.revotas.com/sq_minus_icon16.png" alt="expand-collapse" /> <span>Detailed Clickthrough Info</span></a>	
                                                    <div id="reportDetCTInfo" style="display:block;">
                                                        <table cellpadding="0" cellspacing="0" border="0" width="100%">
                                                            <tr class="sectionContainerTbl">
                                                                <td width="">
                                                                    <table cellpadding="0" width="100%" cellspacing="0" border="0" class="borderTbl">
                                                                    <xsl:for-each select="CampaignList/Campaigns/Row">
                                                                        <tr class="sectionHeaders">
                                                                            <td width="250">Campaign Name</td>
                                                                            <td width="150"># of Links</td>
                                                                            <td width="150">Total Clicks</td>
                                                                            <td width="250"># of Recipients who clicked multiple linkss</td>
                                                                            <td width="150">Total Text</td>
                                                                            <td>Total HTML</td>
                                                                        </tr>
                                                                        <tr class="contentRows">
                                                                            <td width="">
                                                                                <xsl:element name="a">
                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/CampaignView"/>?act=VIEW&#38;id=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
                                                                                    <xsl:value-of select="Name"/>
                                                                                </xsl:element>(cache=<xsl:value-of select="CacheId"/>)
                                                                            </td>
                                                                            <td><xsl:value-of select="TotalLinks"/></td>
                                                                            <td>
                                                                                <xsl:element name="a">
                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
                                                                                    <xsl:value-of select="DistinctClicks"/>
                                                                                </xsl:element>
                                                                            </td>
                                                                            <td>
                                                                                <xsl:element name="a">
                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multilink&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
                                                                                    <xsl:value-of select="MultiLinkClickers"/>
                                                                                </xsl:element>
                                                                            </td>
                                                                            <td>
                                                                                <xsl:element name="a">
                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>&#38;T=T');</xsl:attribute>
                                                                                    <xsl:value-of select="DistinctText"/>
                                                                                </xsl:element>
                                                                                (<xsl:value-of select="DistinctTextPrc"/>%)
                                                                            </td>
                                                                            <td>
                                                                                <xsl:element name="a">
                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>&#38;T=H');</xsl:attribute>
                                                                                    <xsl:value-of select="DistinctHTML"/>
                                                                                </xsl:element>
                                                                                (<xsl:value-of select="DistinctHTMLPrc"/>%)
                                                                            </td>
                                                                        </tr>
                                                                        <tr class="sectionHeaders">
                                                                            <td width="250">Link Name</td>
                                                                            <td width="150"># of Clicks</td>
                                                                            <td width="150">Text Clicks</td>
                                                                            <td width="250">HTML Clicks</td>
                                                                            <td width="150"></td>
                                                                            <td></td>
                                                                        </tr>
                                                                        <xsl:for-each select="./Links">
                                                                            <xsl:variable name="aColor">
                                                                                <xsl:choose>
                                                                                    <xsl:when test="position() mod 2 = 1">
                                                                                        <xsl:text>nobg</xsl:text>
                                                                                    </xsl:when>
                                                                                <xsl:otherwise>contentRows</xsl:otherwise>
                                                                            </xsl:choose>
                                                                            </xsl:variable>
                                                                            
                                                                            <tr class="{$aColor}">
                                                                            <td><xsl:value-of select="LinkName"/></td>
                                                                            <td>
                                                                                <xsl:element name="a">
                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;C=<xsl:value-of select="../CacheId"/>&#38;H=<xsl:value-of select="HrefID"/>');</xsl:attribute>
                                                                                    <xsl:value-of select="DistinctClicks"/>
                                                                                </xsl:element> (<xsl:value-of select="DistinctClickPrc"/>%)
                                                                            </td>
                                                                            <td>
                                                                                <xsl:element name="a">
                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;C=<xsl:value-of select="../CacheId"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=T');</xsl:attribute>
                                                                                    <xsl:value-of select="DistinctText"/>
                                                                                </xsl:element>
                                                                                (<xsl:value-of select="DistinctTextPrc"/>%)
                                                                            </td>
                                                                            <td>
                                                                                <xsl:element name="a">
                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;C=<xsl:value-of select="../CacheId"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=H');</xsl:attribute>
                                                                                    <xsl:value-of select="DistinctHTML"/>
                                                                                </xsl:element>
                                                                                (<xsl:value-of select="DistinctHTMLPrc"/>%)
                                                                            </td>
                                                                            <td></td>
                                                                            <td></td>
                                                                        </tr>
                                                                        </xsl:for-each>
                                                                    </xsl:for-each>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </div>
                                                    
                                                <!-- Detailed Clickthrough Info End -->
                                            </xsl:if>
                                            
                                            <xsl:if test="1 = /CampaignList/TotClickSecFlag">
                                                <!-- Additional Total Clickthrough Info Start -->
                                                
                                                <div class="ui-state-default sectionblock" id="section-AddTCInfo">
                                                    <a class="sectionSheaders" href="javascript:toggleContentBox('reportAddTCInfo')"><img id="reportAddTCInfo_excol" style="border:none;" src="http://www.revotas.com/sq_minus_icon16.png" alt="expand-collapse" /> <span>Additional Total Clickthrough Info</span></a>	
                                                    <div id="reportAddTCInfo" style="display:block;">
                                                        <table cellpadding="0" cellspacing="0" border="0" width="100%">
                                                            <tr class="sectionContainerTbl">
                                                                <td width="">
                                                                    <table cellpadding="0" width="100%" cellspacing="0" border="0" class="borderTbl">
                                                                    <xsl:for-each select="CampaignList/Campaigns/Row">
                                                                        <tr class="sectionHeaders">
                                                                            <td width="200">Campaign Name</td>
                                                                            <td width="150"># of Links</td>
                                                                            <td width="200">Total Clicks</td>
                                                                            <td width="200"># clicked on more than one link</td>
                                                                            <td width="200"># clicked on one link multiple times</td>
                                                                            <td style="width:100px">Total Text</td>
                                                                            <td>Total HTML</td>
                                                                        </tr>
                                                                        <tr class="contentRows">
                                                                            <td width="">
                                                                                <xsl:element name="a">
                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/CampaignView"/>?act=VIEW&#38;id=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
                                                                                    <xsl:value-of select="Name"/>
                                                                                </xsl:element>
                                                                            </td>
                                                                            <td><xsl:value-of select="TotalLinks"/></td>
                                                                            <td>
                                                                                <xsl:element name="a">
                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
                                                                                    <xsl:value-of select="TotalClicks"/>
                                                                                </xsl:element>
                                                                            </td>
                                                                            <td>
                                                                                <xsl:element name="a">
                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multilink&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
                                                                                    <xsl:value-of select="MultiLinkClickers"/>
                                                                                </xsl:element>
                                                                            </td>
                                                                            <td>
                                                                                <xsl:element name="a">
                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multiclick&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>');</xsl:attribute>
                                                                                    <xsl:value-of select="OneLinkMultiClickers"/>
                                                                                </xsl:element>
                                                                            </td>
                                                                            <td>
                                                                                <xsl:element name="a">
                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>&#38;T=T');</xsl:attribute>
                                                                                    <xsl:value-of select="TotalText"/>
                                                                                </xsl:element>
                                                                                (<xsl:value-of select="TotalTextPrc"/>%)
                                                                            </td>
                                                                            <td>
                                                                                <xsl:element name="a">
                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="Id"/>&#38;C=<xsl:value-of select="CacheId"/>&#38;T=H');</xsl:attribute>
                                                                                    <xsl:value-of select="TotalHTML"/>
                                                                                </xsl:element>
                                                                                (<xsl:value-of select="TotalHTMLPrc"/>%)
                                                                            </td>
                                                                        </tr>
                                                                        <tr class="sectionHeaders">
                                                                            <td>Link Name</td>
                                                                            <td># of Clicks</td>
                                                                            <td># clicked on one link multiple times</td>
                                                                            <td>Text Clicks</td>
                                                                            <td>HTML Clicks</td>
                                                                            <td></td>
                                                                            <td></td>
                                                                        </tr>
                                                                        <xsl:for-each select="./Links">
                                                                            <xsl:variable name="aColor">
                                                                                <xsl:choose>
                                                                                    <xsl:when test="position() mod 2 = 1">
                                                                                        <xsl:text>nobg</xsl:text>
                                                                                    </xsl:when>
                                                                                <xsl:otherwise>contentRows</xsl:otherwise>
                                                                            </xsl:choose>
                                                                            </xsl:variable>
                                                                            
                                                                            <tr class="{$aColor}">
                                                                            <td><xsl:value-of select="LinkName"/></td>
                                                                            <td>
                                                                                <xsl:element name="a">
                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;C=<xsl:value-of select="../CacheId"/>&#38;H=<xsl:value-of select="HrefID"/>');</xsl:attribute>
                                                                                    <xsl:value-of select="TotalClicks"/>
                                                                                </xsl:element> 
                                                                                (<xsl:value-of select="TotalClickPrc"/>%)
                                                                            </td>
                                                                            <td>
                                                                                <xsl:element name="a">
                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=multiclick&#38;Q=<xsl:value-of select="CampID"/>&#38;C=<xsl:value-of select="../CacheId"/>&#38;H=<xsl:value-of select="HrefID"/>');</xsl:attribute>
                                                                                    <xsl:value-of select="MultiClickers"/>
                                                                                </xsl:element>
                                                                            </td>
                                                                            <td>
                                                                                <xsl:element name="a">
                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;C=<xsl:value-of select="../CacheId"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=T');</xsl:attribute>
                                                                                    <xsl:value-of select="TotalText"/>
                                                                                </xsl:element>
                                                                                <xsl:value-of select="TotalTextPrc"/>%
                                                                            </td>
                                                                            <td>
                                                                                <xsl:element name="a">
                                                                                    <xsl:attribute name="class">reportPopDetail</xsl:attribute>
                                                                                    <xsl:attribute name="href">javascript:pop_up_win('<xsl:value-of select="/CampaignList/DetailView"/>?Action=click&#38;Q=<xsl:value-of select="CampID"/>&#38;C=<xsl:value-of select="../CacheId"/>&#38;H=<xsl:value-of select="HrefID"/>&#38;T=H');</xsl:attribute>
                                                                                    <xsl:value-of select="TotalHTML"/>
                                                                                </xsl:element>
                                                                                (<xsl:value-of select="TotalHTMLPrc"/>%)
                                                                            </td>
                                                                            <td></td>
                                                                            <td></td>
                                                                        </tr>
                                                                        </xsl:for-each>
                                                                    </xsl:for-each>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </div>									
                                                
                                                
                                                <!-- Additional Total Clickthrough Info End -->
                                            </xsl:if>
                                            
                                        </div>
                                    </div>
                                </xsl:otherwise>
                                <!-- End CampaignList/TotalsSecFlag  -->
			            </xsl:choose>



 
  
		</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
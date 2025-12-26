<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
            com.britemoon.cps.imc.*,
			java.sql.*,java.net.*,
			java.io.*,java.util.*,
			java.text.DateFormat,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../../jsp/validator.jsp"%>
<%
	String popup_id = request.getParameter("popup_id");
	ConnectionPool cp = null;
	Connection conn = null;
	Statement stmt =null;

	Service service = null;
	Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id);
	service = (Service) services.get(0);
   String rcpUrl = service.getURL().getHost();
   
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Document</title>
    <link rel="stylesheet" href="./dist/css/adminlte.min.css">
    <link rel="stylesheet" href="./dist/css/select2.min.css">
    <link rel="stylesheet" href="./dist/css/all.min.css">
    <link rel="stylesheet" href="./dist/css/bootstrap-slider.min.css">
    <link rel="stylesheet" href="./style.css">
        <!-- Emoji CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">

    <link href="assets/emoji/css/emoji.css" rel="stylesheet">
    
    


  <link rel="stylesheet" href="assets/css/font-awesome.min.css">
 <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700,300italic,400italic,600italic">
 
  
  <style>
      body {
          font-family: 'Source Sans Pro', 'Helvetica Neue', Helvetica, Arial, sans-serif !important;
      }
      .card-primary.card-outline {
            border-top: 3px solid #59c8e6;
        }
      .custom-control-input:checked~.custom-control-label::before {
            border-color: #59c8e6;
            background-color: #59c8e6;
        }
      .btn-primary {
        color: #fff;
        background-color: #59c8e6;
        border-color: #59c8e6;
        box-shadow: none;
    }
      .nav-pills .nav-link.active, .nav-pills .show>.nav-link {
          background-color: #59c8e6;
      }
      .positionDiv {
          display: flex;
          margin-bottom: 20px;
      }
      .positionDiv > div {
          margin-right: 50px;
      }
      .selectbox {
            width: fit-content;
            background-image: url(assets/img/screen.png);
            padding: 6px 4px 22px 4px;
            background-size: 100% 100%;
            background-position: center;
            background-repeat: no-repeat;
        }
      #slidingPosition>.selectbox, #drawerPosition>.selectbox, #socialProofPositionSliding>.selectbox {
          background-size: 60% 64%;
          padding: 9px 6px 25px 6px;
      }
      #contentPosition>.selectbox {
            padding: 6px 4px 5px 4px;
            background-size: 100% 109px;
            background-position: top;
      }
        .selectBoxRow {
            display: flex;
            justify-content: center;
            width: auto;
        }
        .selectBox, .selectDirectBox {
            width: 35px;
            height: 25px;
            margin: 1px;
            border: 1px solid #ced4da;
        }
        .selectBox:hover,.selectBox.selected {
            background-color: #ff6600;
        }
        .selectDirectBox:hover,.selectDirectBox.selected {
            background-color: lightblue;
        }
      
      
      input[type="radio"] {
          display: none;
      }
 
    input[type="radio"]:checked + .bbox {
      color:#fff;
      background-color: #59C8E6 ;
    }
      
    input[type="radio"]:checked + .bbox.integration {
      color:#fff;
      background-color: #f4f4f4 ;
    }
    
   .btn-app2{ 
   		border-radius: 3px;
	    padding: 15px 5px;
	    width: 80%;
	  
	    text-align: center;
	    color: #666;
	    border: 1px solid #ddd;
	    background-color: #f4f4f4;
	    font-size: 16px;
    }
      .btn-app2.integration {
          background-color: #fff;
        width: 200px;
        height: 150px;
        display: flex;
      }  
      
    .btn-app2 > .fas, .btn-app2 > .fab, .btn-app2 > .glyphicon, .btn-app2 > .ion {
	    font-size: 30px;
	    line-height: 30px;
	    display: block;
	}
	.bg{background-color:#007e90;}
	.blabel{width: 100%;}
      
      #product_notifications_editor button {
    text-align: center;
    padding: 1px 3px;
    height:25px;
    width:25px;
    background-repeat: no-repeat;
    background-size: contain;
    border:none;
}
	
  </style>
  
</head>
<body>
   
   <div class="col-md-12">
            <div class="card">
             <!--HEADER-->
              <div class="headmenu card-header p-2" style="display: none;">
                <ul class="nav nav-pills">
                  <li class="nav-item"><a class="nav-link active campaign_type" href="#campaign_type" data-toggle="tab">Campaign Type</a></li>
                  <li class="nav-item"><a class="nav-link campaign_content" href="#campaign_content" data-toggle="tab">Content</a></li>
                  <li class="nav-item"><a class="nav-link campaign_design" href="#campaign_design" data-toggle="tab">Design</a></li>
                  <li class="nav-item"><a class="nav-link campaign_trigger" href="#campaign_trigger" data-toggle="tab">Trigger</a></li>
                  <li class="nav-item"><a class="nav-link campaign_target_audience" href="#campaign_target_audience" data-toggle="tab">Target Audience</a></li>
                  <li class="nav-item"><a class="nav-link campaign_integration" href="#campaign_integration" data-toggle="tab">Integrations</a></li>
                  <li class="nav-item" style="display:none;"><a class="nav-link campaign_product_alert" href="#campaign_product_alert" data-toggle="tab">Product Alert</a></li>
                  <li class="nav-item" style="display:none;"><a class="nav-link campaign_social_proof" href="#campaign_social_proof" data-toggle="tab">Social Proof</a></li>
                  <li class="nav-item"><a class="nav-link campaign_live_preview" href="#campaign_live_preview" data-toggle="tab">Live Preview</a></li>
                  <li class="nav-item"><a class="nav-link campaign_reports" href="#campaign_reports" data-toggle="tab">Reports</a></li>
                  <button style="margin-left:auto;" class="btn btn-primary" onclick="saveConfigs(this)">Save</button>
                    <div style="margin-top:7px;"><i id="config-saving" style="display:none;" class="fas fa-spinner fa-spin"></i></div>
                <button style="margin-left:10px;" class="btn btn-primary" onclick="cloneWidget(this)">Clone</button>
                </ul>
              </div>
              <!--HEADER-END-->
              <!--BODY-->
              <div class="card-body">
                <div class="tab-content">
                  <div class="tab-pane active" id="campaign_type">
                   <label>Select Your Campaign Type</label>
                    <div class="custom-control custom-switch">
                      <input type="checkbox" class="custom-control-input no-preview" id="enabled">
                      <label class="custom-control-label" for="enabled">Enabled</label>
                    </div>
                    <div class="form-group row">
                        <label for="widgetName" class="col-md-2 col-form-label">Widget Name</label>
                        <div class="col-md-4">
                          <input type="text" class="form-control no-preview" name="widgetName" id="widgetName">
                        </div>
                      </div>
         <div class="row">
                     <div class="col-md-2 col-xs-2"> 
                            <label for="sticky" class="blabel"> 
                                <input type="radio" name="type" id="sticky" value="sticky">  
                                <a class="btn btn-app2 bbox "><img src="http://cms.revotas.com/cms/ui/smartwidgets/newui/assets/icons/sticky.png" style="width: 100px;margin: auto;height: 100px;display: block;">Sticky</a>
                           </label>

                     </div>
                     <div class="col-md-2 col-xs-2"> 
                            <label for="sliding" class="blabel"> 
                                <input type="radio" name="type" id="sliding" value="sliding">  
                                <a class="btn btn-app2 bbox "><img src="http://cms.revotas.com/cms/ui/smartwidgets/newui/assets/icons/sliding.png" style="width: 100px;margin: auto;height: 100px;display: block;">Sliding</a>
                           </label>

                     </div>
                     <div class="col-md-2 col-xs-2"> 
                            <label for="fading" class="blabel"> 
                                <input type="radio" name="type" id="fading" value="fading">  
                                <a class="btn btn-app2 bbox "><img src="http://cms.revotas.com/cms/ui/smartwidgets/newui/assets/icons/fading.png" style="width: 100px;margin: auto;height: 100px;display: block;">Fading</a>
                           </label>

                     </div>
                     <div class="col-md-2 col-xs-2"> 
                            <label for="drawer" class="blabel"> 
                                <input type="radio" name="type" id="drawer" value="drawer">  
                                <a class="btn btn-app2 bbox "><img src="http://cms.revotas.com/cms/ui/smartwidgets/newui/assets/icons/drawer.png" style="width: 100px;margin: auto;height: 100px;display: block;">Drawer</a>
                           </label>

                     </div>
                     <div class="col-md-2 col-xs-2"> 
                            <label for="productAlert" class="blabel"> 
                                <input class="no-preview" type="radio" name="type" id="productAlert" value="productAlert">  
                                <a class="btn btn-app2 bbox "><img src="http://cms.revotas.com/cms/ui/smartwidgets/newui/assets/icons/pro-alert.png" style="width: 100px;margin: auto;height: 100px;display: block;">Product Alert</a>
                           </label>

                     </div>
                     <div class="col-md-2 col-xs-2"> 
                            <label for="socialProof" class="blabel"> 
                                <input class="no-preview" type="radio" name="type" id="socialProof" value="socialProof">  
                                <a class="btn btn-app2 bbox "><img src="http://cms.revotas.com/cms/ui/smartwidgets/newui/assets/icons/social-proof.png" style="width: 100px;margin: auto;height: 100px;display: block;">Social Proof</a>
                           </label>

                     </div>
                     <div class="col-md-2 col-xs-2"> 
                            <label for="script" class="blabel"> 
                                <input type="radio" name="type" id="script" value="script">  
                                <a class="btn btn-app2 bbox "><img src="http://cms.revotas.com/cms/ui/smartwidgets/newui/assets/icons/script.png" style="width: 100px;margin: auto;height: 100px;display: block;">Script</a>
                           </label>

                     </div>
	   </div>       

                    
                    
                  </div>
                  
                    <div class="tab-pane" id="campaign_content">
                    <label>What should the visitor view ? (Right Message)</label>
                    <div class="row">
                     <div class="col-md-2 col-xs-2"> 
                            <label for="iframeType" class="blabel"> 
                                <input type="radio" name="contentType" id="iframeType" value="iframeType" checked>  
                                <a class="btn btn-app2 bbox "><i class="fas fa-window-maximize"></i>Iframe</a>
                           </label>

                     </div>
                     <div class="col-md-2 col-xs-2"> 
                            <label for="htmlCode" class="blabel"> 
                                <input type="radio" name="contentType" id="htmlCode" value="htmlCode">  
                                <a class="btn btn-app2 bbox "><i class="fas fa-code"></i>HTML</a>
                           </label>

                     </div>
	   </div> 
                   <div class="form-group row">
                        <label for="iframeLink" class="col-md-2 col-form-label">Iframe Link</label>
                        <div class="col-md-4">
                          <input type="text" class="form-control" name="iframeLink" id="iframeLink" placeholder="http:....">
                        </div>
                      </div>
                      
                      <div class="form-group row">
                        <label for="iframeClassName" class="col-md-2 col-form-label">Iframe Class</label>
                        <div class="col-md-4">
                          <input type="text" class="form-control" name="iframeClassName" id="iframeClassName" placeholder="optional">
                        </div>
                      </div>
                      
                      <div class="form-group row">
                        <label for="cssLinks" class="col-md-2 col-form-label">Css Links</label>
                        <div class="col-md-4">
                          <input type="text" class="form-control" name="cssLinks" id="cssLinks" placeholder="optional">
                        </div>
                      </div>
                      
                      <div class="form-group col-md-12" style="display:none;">
                            <label for="html">Html Code</label>
                            <textarea name="html" id="html" class="form-control" rows="4"></textarea>
                      </div>
                      
                      <div class="card card-outline card-primary collapsed-card scriptArea">
                          <div class="card-header">
                          <button style="width: 100%" type="button" class="btn" data-card-widget="collapse">
                              <h3 class="card-title">Script Code</h3>
                            </button>
                          </div>
                          <div class="card-body">
                            <div class="form-group col-md-12 scriptCode">
                                <textarea name="scriptCode" id="scriptCode" class="form-control no-preview" rows="4"></textarea>
                          </div>
                          </div>
                        </div>
                      
                      
                      
                      
                    </div>
                    <div class="tab-pane" id="campaign_design"> 
                       <label>What should my content look like ?  (Right Message)</label>
                        <div class="card card-outline card-primary collapsed-card">
                          <div class="card-header">
                          <button style="width: 100%" type="button" class="btn" data-card-widget="collapse">
                              <h3 class="card-title">Display</h3>
                            </button>
                          </div>
                          <div class="card-body">
                            <div class="form-group row">
                            <label for="height" class="col-md-2 col-form-label">Height</label>
                            <div class="col-md-10">
                              <input class="widget_slider" name="height" style="width:100%;" id="height" data-slider-id='ex3Slider' type="text" data-slider-orientation="horizontal" data-slider-min="0" data-slider-max="1000" data-slider-step="1" data-slider-value="50"/>
                            </div>
                          </div>
                          
                          <div class="form-group row">
                            <label for="width" class="col-md-2 col-form-label">Width</label>
                            <div class="col-md-10">
                              <input class="widget_slider" name="width" style="width:100%;" id="width" data-slider-id='ex4Slider' type="text" data-slider-orientation="horizontal" data-slider-min="0" data-slider-max="1000" data-slider-step="1" data-slider-value="200"/>
                            </div>
                          </div>

                          <div class="form-group row">
                            <label for="previewSize" class="col-md-2 col-form-label">Preview Size</label>
                            <div class="col-md-10">
                              <input class="widget_slider" name="previewSize" style="width:100%;" id="previewSize" data-slider-id='ex15Slider' type="text" data-slider-orientation="horizontal" data-slider-min="0" data-slider-max="1000" data-slider-step="1" data-slider-value="0"/>
                            </div>
                          </div>
                          
                          <div class="form-group row">
                            <div class="col-md-6">
                              <label for="background-color">Background Color</label>
                                <div id="background-color"></div>
                            </div>
                          </div>

                           <div style="display: none;" class="form-group row overlayColor">
                            <div class="col-md-6">
                             <div class="custom-control custom-switch">
                          <input type="checkbox" class="custom-control-input" id="overlayColorEnabled">
                          <label class="custom-control-label" for="overlayColorEnabled">Overlay Color</label>
                        </div>
                                <div id="overlay-color"></div>
                            </div>
                          </div>
                          </div>
                        </div>
                        <div class="card card-outline card-primary collapsed-card">
                          <div class="card-header">
                          <button style="width: 100%" type="button" class="btn" data-card-widget="collapse">
                              <h3 class="card-title">Duration</h3>
                            </button>
                          </div>
                          <div class="card-body">
                            <div class="form-group row">
                            <label for="showDuration" class="col-md-2 col-form-label">Show Duration</label>
                            <div class="col-md-6">
                              <input class="widget_slider no-preview" name="showDuration" style="width:100%;" id="showDuration" data-slider-id='ex5Slider' type="text" data-slider-orientation="horizontal" data-slider-min="0" data-slider-max="120000" data-slider-step="500" data-slider-value="1000"/>
                            </div>
                          </div>

                           <div class="form-group row">
                            <label for="closeDuration" class="col-md-2 col-form-label">Close Duration</label>
                            <div class="col-md-6">
                              <input class="widget_slider no-preview" name="closeDuration" style="width:100%;" id="closeDuration" data-slider-id='ex6Slider' type="text" data-slider-orientation="horizontal" data-slider-min="0" data-slider-max="120000" data-slider-step="500" data-slider-value="1000"/>
                            </div>
                          </div>

                           <div class="form-group row">
                            <label for="autoCloseDelay" class="col-md-2 col-form-label">Auto Close Duration</label>
                            <div class="col-md-6">
                              <input class="widget_slider no-preview" name="autoCloseDelay" style="width:100%;" id="autoCloseDelay" data-slider-id='ex7Slider' type="text" data-slider-orientation="horizontal" data-slider-min="0" data-slider-max="120000" data-slider-step="500" data-slider-value="0"/>
                            </div>
                          </div>
                          </div>
                        </div>
                        
                        
                        
                        <div class="card card-outline card-primary collapsed-card">
                          <div class="card-header">
                          <button style="width: 100%" type="button" class="btn" data-card-widget="collapse">
                              <h3 class="card-title">Position</h3>
                            </button>
                          </div>
                          <div class="card-body">
                            <div class="positionDiv">
                        <div style="display:none;" id="slidingPosition">
                            <label>Position</label>
                        </div>
                        <div style="display:none;" id="fadingPosition">
                            <label>Position</label>
                        </div>
                        <div style="display:none;" id="drawerPosition">
                            <label>Position</label>
                        </div>
                        <div id="contentPosition">
                            <label>Content Position</label>
                        </div>
                    </div>
                        
                        <div class="form-group col-md-6 row">
                          <label>Starting State</label>
                          <select id="drawerStartState" name="drawerStartState" class="form-control select2" style="width: 100%;">
                                <option value="closed" selected>Closed</option>
                                <option value="opened">Opened</option>
                          </select>
                        </div>
                        
                        <div style="display: none;" class="form-group col-md-6 row">
                          <label>Overlay Click</label>
                          <select id="overlayClick" name="overlayClick" class="form-control select2 no-preview" style="width: 100%;">
                              <option value="donotclose" selected>Do not close</option>
                              <option value="close">Close</option>
                          </select>
                        </div>
                        
                        <div style="display: none;" class="form-group col-md-6 row">
                          <label>Overlay Lock</label>
                          <select id="overlayLock" name="overlayLock" class="form-control select2 no-preview" style="width: 100%;">
                              <option value="true" selected>True</option>
                              <option value="false">False</option>
                          </select>
                        </div>
                        
                        <div class="form-group row">
                        <label for="fixedElements" class="col-md-2 col-form-label">Fixed Elements</label>
                        <div class="col-md-4">
                          <input type="text" class="form-control" name="fixedElements" id="fixedElements" placeholder="optional">
                        </div>
                      </div>
                      
                      <div class="form-group row">
                        <label for="fixedElementsUnaffected" class="col-md-2 col-form-label">Fixed Elements(Unaffected)</label>
                        <div class="col-md-4">
                          <input type="text" class="form-control" name="fixedElementsUnaffected" id="fixedElementsUnaffected" placeholder="optional">
                        </div>
                      </div>
                          </div>
                        </div>
                        
                        
                       
                       
                       
                       
                       
                       
                        
                        
                    </div>
                    <div class="tab-pane" id="campaign_trigger"> 
                    <label>When should visitor see my campaign ? (Right Time)</label>
                  <div class="card card-outline card-primary collapsed-card">
<div class="card-header">
<input class="no-preview" style="display:unset;" id="afterLoad" name="trigger" type="radio" value="afterLoad"/>
<label for="afterLoad">After 'X' seconds</label>
<button style="display:none;" data-card-widget="collapse"></button>
</div>
<div class="card-body">
<div class="form-group row delay">
<label for="delay" class="col-md-12 col-form-label">Show the message when the visitor has view your site for a certain period of time</label>
<div class="col-md-6">
  <input class="widget_slider no-preview" name="delay" style="width:100%;" id="delay" data-slider-id='ex1Slider' type="text" data-slider-orientation="horizontal" data-slider-min="0" data-slider-max="120000" data-slider-step="500" data-slider-value="1000"/>
</div>
</div>
</div>
</div>


<div class="card card-outline card-primary collapsed-card">
<div class="card-header">
<input class="no-preview" style="display:unset;" id="scroll" name="trigger" type="radio" value="scroll"/>
<label for="scroll">Show when the visitor has scrolled</label>
<button style="display:none;" data-card-widget="collapse"></button>
</div>
<div class="card-body">
<div class="form-group row scrollPercentage">
<label for="scrollPercentage" class="col-md-12 col-form-label">Show the message when the visitor has scrolled a certain Percentage</label>
<div class="col-md-6">
  <input class="widget_slider no-preview" name="scrollPercentage" style="width:100%;" id="scrollPercentage" data-slider-id='ex2Slider' type="text" data-slider-orientation="horizontal" data-slider-min="0" data-slider-max="100" data-slider-step="1" data-slider-value="50"/>
</div>
</div>
</div>
</div>
                       
<div class="card card-outline card-primary collapsed-card">
<div class="card-header">
<input class="no-preview" style="display:unset;" id="mouseLeave" name="trigger" type="radio" value="mouseLeave"/>
<label for="mouseLeave">On Exit Intent</label>
<button style="display:none;" data-card-widget="collapse"></button>
</div>
<div class="card-body">
    <label>Show the message the visitor tries to leave the site</label>
</div>
</div>
 <div class="custom-control custom-switch">
  <input type="checkbox" class="custom-control-input no-preview" name="nonBlocking" id="nonBlocking">
  <label class="custom-control-label" for="nonBlocking">Non-Blocking(Widget will be executed regardless of its order in widget list)</label>
</div>
                  
                    </div>
                    <div class="tab-pane" id="campaign_target_audience">
                    <div class="input-group condition-configs">
                        <div class="condition-panel">
                            <button class="smart-widget-button" id="group-conditions">Group Conditions</button>
                            <button class="smart-widget-button" id="remove-group">Remove Group</button>
                            <button class="smart-widget-button" id="ungroup-conditions">Ungroup conditions</button>
                        </div>
                    </div>
                     </div>
                          <div class="tab-pane" id="campaign_live_preview">
                             <div class="custom-control custom-switch">
                              <input onchange="savePreviewConfigs()" type="checkbox" class="custom-control-input no-preview" id="noConditions">
                              <label class="custom-control-label" for="noConditions">No Conditions</label>
                            </div>
                             <div class="custom-control custom-switch">
                              <input onchange="savePreviewConfigs()" type="checkbox" class="custom-control-input no-preview" id="noTriggers">
                              <label class="custom-control-label" for="noTriggers">No Triggers</label>
                            </div>
                             <div class="custom-control custom-switch">
                              <input onchange="savePreviewConfigs()" type="checkbox" class="custom-control-input no-preview" id="previewType">
                              <label class="custom-control-label" for="previewType">New Window</label>
                            </div>
                              <div class="form-group row">
                                <label for="previewUrl" class="col-md-2 col-form-label">Site Url</label>
                                <div class="col-md-8">
                                  <input type="text" class="form-control no-preview" name="previewUrl" id="previewUrl" placeholder="https://...">
                                </div>
                              </div>
                              <div class="form-group row">
                                  <button onclick="initiateLivePreview()" type="submit" class="btn btn-primary">Start Live Preview</button>
                                  <div style="margin: 5px 5px 0 15px;" id="livePreviewStatus"></div>
                                  <div style="margin-top: 5px;">
                                      <i id="preview-connecting" style="display:none;" class="fas fa-spinner fa-spin"></i>
                                      <i id="preview-connected" style="display:none;color:green;" class="fas fa-check-circle"></i>
                                  </div>
                              </div>
                              
                          </div>
                          
                          <div class="tab-pane" id="campaign_integration">
                          <div class="row">
                         <div class="col-md-2 col-xs-2"> 
                                <label for="revotas" class="blabel"> 
                                    <input class="no-preview" type="radio" name="integration" id="revotas" value="revotas">  
                                    <a class="btn btn-app2 bbox integration"><img src="http://cms.revotas.com/cms/ui/smartwidgets/newui/assets/icons/revo-logo.png" style="width: 140px;margin: auto;display: block;"></a>
                               </label>

                         </div>
	                       </div>   
                         
                         <div class="form-group col-md-6 row revotas intgr" style="display:none">
                          <label>Form</label>
                          <select id="formId" name="formId" class="form-control select2 no-preview" style="width: 100%;">
                              <%
                                cp = null;
                                conn = null;
                                stmt =null;

                                try
                                {
                                    cp = ConnectionPool.getInstance();			
                                    conn = cp.getConnection(this);

                                    stmt = conn.createStatement();

                                    String sSql = "SELECT f.form_id, f.form_name FROM csbs_form f, csbs_form_edit_info fei WHERE f.cust_id = " + cust.s_cust_id + " AND fei.form_id = f.form_id ORDER BY f.form_name ASC";

                                    ResultSet rs = stmt.executeQuery(sSql);
                                    while (rs.next())
                                    {%>
                                        <option value="<%=rs.getString(1)%>"><%=rs.getString(2)%></option>
                                    <%}
                                    rs.close();
                                }
                                catch(Exception ex)
                                {
                                    throw ex;
                                }
                                finally
                                {
                                    if (stmt!=null) stmt.close();
                                    if (conn!=null) cp.free(conn);
                                }
                                %>
                          </select>
                        </div>
                          </div>
                          <div class="tab-pane" id="campaign_product_alert">
                          <!--Progress bar-->
                          <div class="custom-control custom-switch">
                              <input onchange="toggleProgressBar(this)" type="checkbox" class="custom-control-input no-preview" id="showProgressBar" checked>
                              <label class="custom-control-label" for="showProgressBar">Show Progress Bar</label>
                            </div>
                           <div id="progressBG" style="margin-top: 10px; width: 300px;height: 10px;background-color: rgba(220,220,220,1);border-radius: 10px;">
                                <div id="progressFill" style="position: absolute;width: 40px;height: 10px;background-color: rgba(54,161,239,1);border-radius: 10px;"></div>
                            </div>
                            <div style="display: flex;margin-top:20px;">
                            <div class="form-group row progressBarColor">
                            <div>
                              <label for="progressFillColor">Progress Bar Fill Color</label>
                                <div id="progressFillColor"></div>
                            </div>
                          </div>
                           <div class="form-group row progressBarColor">
                            <div>
                              <label for="progressBGColor">Progress Bar Background Color</label>
                                <div id="progressBGColor"></div>
                            </div>
                          </div>
                             </div>
                            <!-- -->
                            <div class="form-group">Replace <b>[STOCK-COUNT]</b> with remaining stock amount when it drops below <input onchange="showProductAlertPreview();" class="no-preview" id="stockCount" style="width: 50px;" value="10"> available items, otherwise replace <b>[STOCK-COUNT]</b> with <input onchange="showProductAlertPreview();" class="no-preview" id="stockWord" style="width: 50px;"></div>
                            <div class="form-group row">
                            
                        <label for="productAlertQuerySelector" class="col-md-2 col-form-label">Query Selector</label>
                        <div class="col-md-4">
                          <input placeholder="optional" type="text" class="form-control no-preview" name="productAlertQuerySelector" id="productAlertQuerySelector">
                        </div>
                               <div class="col-md-6 form-control" style="background-color: #efefef;"><i class="fa fa-exclamation"></i> Or you can place <b style="color:#ff4747;">&lt;div class="rvts_product_alert"&gt;&lt;/div&gt;</b> anywhere in your page</div>
                                
                      </div>
                            <!-- -->
                            
                            
                            <!-- -->
                            
                            
                            <!--Text Editor-->
                            
                            
                            <div style="margin:20px 0;" id="product_notifications_editor">
                               <div style="position:relative;width:270px;">
                                <button onclick="document.execCommand('italic',false,null);"><i class="fa fa-italic"></i></button>
                                <button onclick="document.execCommand('bold',false,null);"><i class="fa fa-bold"></i></button>
                                <button onclick="document.execCommand('underline',false,null);"><i class="fa fa-underline"></i></button>
                                <button onclick="document.execCommand('strikethrough',false,null);"><i class="fa fa-strikethrough"></i></button>
                                <button title="Text Fore Color" style="position: relative;" onclick="this.children[1].click()">
                                    <i style="color:black;" class="fa fa-paint-brush"></i>
                                    <input style="visibility: hidden;position: absolute;right: 0;width: 0;height: 0;" class="no-preview color-apply" type="color" onclick="chooseColor(this)" oninput="chooseColor(this)" id="myColor">
                                </button>
                                <button title="Text Background Color" style="position: relative;" onclick="this.children[1].click()">
                                    <i style="color:white;" class="fa fa-paint-brush"></i>
                                    <input style="visibility: hidden;position: absolute;right: 0;width: 0;height: 0;" class="no-preview color-apply" type="color" onclick="chooseBackColor(this)" oninput="chooseBackColor(this)" id="myColor2">
                                </button>
                                <button title="Edit HTML" onclick="toggleHTMLMode();"><i class="fa fa-code"></i></button>
                        
                                
                                <div style="display:none;" class="lead emoji-picker-container form-control" data-emojiable="true"
                               data-emoji-input="unicode"></div>
                                </div>
                                <div class="form-control" spellcheck="false" id="richTextEditor" contenteditable="true" style="height:100px;overflow-y: scroll"></div>
                            </div>
                            
                            <div style="border-bottom: 1px solid #59c8e6">
                                <i class="fa fa-eye-slash" style="font-weight: bold; margin-right: 10px;"></i>Visibility Filter
                            </div>
                            <div>
                                Show only on these products (leave empty to show all)
                            </div>
                            
                            <div class="row">
                                <div class="col-md-4">
                                    <div class="form-group row">
                                        <label class="col-form-label">Product Id</label>
                                    </div>
                                    <div id="productIdList" style="border-radius:5px; border:1px solid #ced4da;padding:15px 0 5px 0;margin-bottom: 10px;" class="row col-md-10"></div>
                                    <div class="form-group row">
                                        <button type="submit" class="btn btn-primary" onclick="addProductId()">+</button>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                   <div class="form-group row">
                                        <label class="col-form-label">Search By Product Name(Include)</label>
                                    </div>
                                    <div id="productNameInclude" style="border-radius:5px; border:1px solid #ced4da;padding:15px 0 5px 0;margin-bottom: 10px;" class="row col-md-10"></div>
                                    <div class="form-group row">
                                        <button type="submit" class="btn btn-primary" onclick="addProductNameInclude()">+</button>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                   <div class="form-group row">
                                        <label class="col-form-label">Search By Product Name(Exclude)</label>
                                    </div>
                                    <div id="productNameExclude" style="border-radius:5px; border:1px solid #ced4da;padding:15px 0 5px 0;margin-bottom: 10px;" class="row col-md-10"></div>
                                    <div class="form-group row">
                                        <button type="submit" class="btn btn-primary" onclick="addProductNameExclude()">+</button>
                                    </div>
                                </div>
                                
                            </div>
                           
                            </div>
                            <div class="tab-pane" id="campaign_social_proof">
                            <div class="card card-outline card-primary collapsed-card">
                          <div class="card-header">
                          <button style="width: 100%" type="button" class="btn" data-card-widget="collapse">
                              <h3 class="card-title">Design</h3>
                            </button>
                          </div>
                          <div class="card-body">
                          <div class="form-group row" style="display:none;">
                            <div class="col-md-6">
                              <label for="background-color2">Background Color</label>
                                <div id="background-color2"></div>
                            </div>
                          </div>
                          <div class="form-group col-md-6 row">
                          <label>Animation Type</label>
                          <select onchange="changeSocialProofAnimation(this)" id="socialProofAnimation" class="form-control no-preview select2" style="width: 100%;">
                              <option value="sliding">Sliding</option>
                              <option value="fading">Fading</option>
                          </select>
                        </div>
                        <div class="form-group row">
                            <label for="widgetSize" class="col-md-3 col-form-label">Widget Size</label>
                            <div class="col-md-6">
                              <input onchange="showSocialProofPreview();" class="widget_slider no-preview" name="widgetSize" style="width:100%;" id="widgetSize" data-slider-id='ex30Slider' type="text" data-slider-orientation="horizontal" data-slider-min="0" data-slider-max="2" data-slider-step="1" data-slider-value="0"/>
                            </div>
                          </div>
                          <div class="form-group row">
                            <label for="showDuration2" class="col-md-3 col-form-label">Show Duration</label>
                            <div class="col-md-6">
                              <input class="widget_slider no-preview" name="showDuration2" style="width:100%;" id="showDuration2" data-slider-id='ex50Slider' type="text" data-slider-orientation="horizontal" data-slider-min="0" data-slider-max="120000" data-slider-step="500" data-slider-value="1000"/>
                            </div>
                          </div>
                          <div class="form-group row">
                            <label for="closeDuration2" class="col-md-3 col-form-label">Close Duration</label>
                            <div class="col-md-6">
                              <input class="widget_slider no-preview" name="closeDuration2" style="width:100%;" id="closeDuration2" data-slider-id='ex60Slider' type="text" data-slider-orientation="horizontal" data-slider-min="0" data-slider-max="120000" data-slider-step="500" data-slider-value="1000"/>
                            </div>
                          </div>
                          <div class="form-group row">
                            <label for="initialDelay" class="col-md-3 col-form-label">Initial Delay</label>
                            <div class="col-md-6">
                              <input class="widget_slider no-preview" name="initialDelay" style="width:100%;" id="initialDelay" data-slider-id='ex74Slider' type="text" data-slider-orientation="horizontal" data-slider-min="0" data-slider-max="120000" data-slider-step="500" data-slider-value="0"/>
                            </div>
                          </div>
                          <div class="custom-control custom-switch">
                              <input type="checkbox" class="custom-control-input no-preview" id="showInLoop">
                              <label class="custom-control-label" for="showInLoop">Show Notifications In Loop</label>
                            </div>
                          <div class="form-group row" style="display: none;">
                            <label for="loopInterval" class="col-md-3 col-form-label">Delay Between Notifications</label>
                            <div class="col-md-6">
                              <input class="widget_slider no-preview" name="loopInterval" style="width:100%;" id="loopInterval" data-slider-id='ex74Slider' type="text" data-slider-orientation="horizontal" data-slider-min="0" data-slider-max="120000" data-slider-step="500" data-slider-value="0"/>
                            </div>
                          </div>
                           <div class="form-group row">
                            <label for="autoCloseDelay2" class="col-md-3 col-form-label">Auto Close Duration</label>
                            <div class="col-md-6">
                              <input class="widget_slider no-preview" name="autoCloseDelay2" style="width:100%;" id="autoCloseDelay2" data-slider-id='ex77Slider' type="text" data-slider-orientation="horizontal" data-slider-min="0" data-slider-max="120000" data-slider-step="500" data-slider-value="0"/>
                            </div>
                          </div>
                           
                            <div class="positionDiv">
                                <div id="socialProofPositionSliding">
                                    <label>Position</label>
                                </div>
                                <div style="display:none;" id="socialProofPositionFading">
                                    <label>Position</label>
                                </div>
                            </div>
                              </div>
                            </div>
                            <div class="card card-outline card-primary collapsed-card">
                          <div class="card-header">
                          <button style="width: 100%" type="button" class="btn" data-card-widget="collapse">
                              <h3 class="card-title">Content</h3>
                            </button>
                          </div>
                          <div class="card-body">
                             <div class="form-group"><b>[LAST_ORDER_CITY]</b>: will be replaced by a city name where an order has been placed recently</div>
                             <div class="form-group"><b>[TOP_SELLER_PRODUCT]</b>: will be replaced by a random top seller product</div>
                             <div class="form-group"><b>[PRICE_DROP_PRODUCT]</b>: will be replaced by a random price drop product</div>
                             <div class="form-group"><b>[NEW_ARRIVAL_PRODUCT]</b>: will be replaced by a random new arrival product</div>
                              <div class="form-group"><b>[TOTAL_PAGE_VIEW]</b>: will be replaced by view count of <input class="no-preview" id="pageViewReferrer" style="width: 200px;" placeholder="Current Page..."> or a random number between <input class="no-preview" id="pageViewCountMin" style="width: 50px;" value="10"> and <input class="no-preview" id="pageViewCountMax" style="width: 50px;" value="100"></div>
                              <div class="form-group"><b>[TOTAL_PRODUCT_VIEW]</b>: will be replaced by a random number between <input class="no-preview" id="productViewCountMin" style="width: 50px;" value="10"> and <input class="no-preview" id="productViewCountMax" style="width: 50px;" value="100"></div>
                              <div class="form-group"><b>[TOTAL_ORDER]</b>: will be replaced by the number of user who made order or replace by a random number between <input class="no-preview" id="orderCountMin" style="width: 50px;" value="10"> and <input class="no-preview" id="orderCountMax" style="width: 50px;" value="100"></div>
                              <div class="form-group"><b>[TOTAL_CART]</b>: will be replaced by the number of user who added to cart or replace by a random number between <input class="no-preview" id="cartCountMin" style="width: 50px;" value="10"> and <input class="no-preview" id="cartCountMax" style="width: 50px;" value="100"></div>
                              <div class="custom-control custom-switch">
                                  <input type="checkbox" class="custom-control-input no-preview" id="randomizeTotalPageView">
                                  <label style="font-weight:400;" class="custom-control-label" for="randomizeTotalPageView">Fill <b>[TOTAL_PAGE_VIEW]</b> with random number from range</label>
                                </div>
                              <div class="custom-control custom-switch">
                                  <input type="checkbox" class="custom-control-input no-preview" id="randomizeTotalOrder">
                                  <label style="font-weight:400;" class="custom-control-label" for="randomizeTotalOrder">Fill <b>[TOTAL_ORDER]</b> with random number from range</label>
                                </div>
                                <div class="custom-control custom-switch">
                                  <input type="checkbox" class="custom-control-input no-preview" id="randomizeTotalCart">
                                    <label style="font-weight:400;" class="custom-control-label" for="randomizeTotalCart">Fill <b>[TOTAL_CART]</b> with random number from range</label>
                                </div>
                            <div style="margin:20px 0;" id="social_proof_editor">
                               <div style="position:relative;width:305px;">
                                <button onclick="document.execCommand('italic',false,null);"><i class="fa fa-italic"></i></button>
                                <button onclick="document.execCommand('bold',false,null);"><i class="fa fa-bold"></i></button>
                                <button onclick="document.execCommand('underline',false,null);"><i class="fa fa-underline"></i></button>
                                <button onclick="document.execCommand('strikethrough',false,null);"><i class="fa fa-strikethrough"></i></button>
                                <button title="Text Fore Color" style="position: relative;" onclick="this.children[1].click()">
                                    <i style="color:black;" class="fa fa-paint-brush"></i>
                                    <input style="visibility: hidden;position: absolute;right: 0;width: 0;height: 0;" class="no-preview color-apply" type="color" onclick="chooseColor(this)" oninput="chooseColor(this)" id="myColor">
                                </button>
                                <button title="Text Background Color" style="position: relative;" onclick="this.children[1].click()">
                                    <i style="color:white;" class="fa fa-paint-brush"></i>
                                    <input style="visibility: hidden;position: absolute;right: 0;width: 0;height: 0;" class="no-preview color-apply" type="color" onclick="chooseBackColor(this)" oninput="chooseBackColor(this)" id="myColor2">
                                </button>
                                <button title="Edit HTML" onclick="toggleHTMLMode2();"><i class="fa fa-code"></i></button>
                        
                                
                                <div style="display:none;" class="lead emoji-picker-container form-control" data-emojiable="true"
                               data-emoji-input="unicode"></div>
                                </div>
                                <div class="form-control" spellcheck="false" id="richTextEditor2" contenteditable="true" style="height:100px;overflow-y: scroll"></div>
                            </div>
                              </div>
                            </div>
                            <div class="card card-outline card-primary collapsed-card">
                          <div class="card-header">
                          <button style="width: 100%" type="button" class="btn" data-card-widget="collapse">
                              <h3 class="card-title">Filters</h3>
                            </button>
                          </div>
                          <div class="card-body">
                          <div class="row">
                                <div class="col-md-4">
                                    <div class="form-group row">
                                        <label class="col-form-label">Product Id</label>
                                    </div>
                                    <div id="productIdList2" style="border-radius:5px; border:1px solid #ced4da;padding:15px 0 5px 0;margin-bottom: 10px;" class="row col-md-10"></div>
                                    <div class="form-group row">
                                        <button type="submit" class="btn btn-primary" onclick="addProductId2()">+</button>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                   <div class="form-group row">
                                        <label class="col-form-label">Search By Product Name(Include)</label>
                                    </div>
                                    <div id="productNameInclude2" style="border-radius:5px; border:1px solid #ced4da;padding:15px 0 5px 0;margin-bottom: 10px;" class="row col-md-10"></div>
                                    <div class="form-group row">
                                        <button type="submit" class="btn btn-primary" onclick="addProductNameInclude2()">+</button>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                   <div class="form-group row">
                                        <label class="col-form-label">Search By Product Name(Exclude)</label>
                                    </div>
                                    <div id="productNameExclude2" style="border-radius:5px; border:1px solid #ced4da;padding:15px 0 5px 0;margin-bottom: 10px;" class="row col-md-10"></div>
                                    <div class="form-group row">
                                        <button type="submit" class="btn btn-primary" onclick="addProductNameExclude2()">+</button>
                                    </div>
                                </div>
                                
                            </div>
                              </div>
                            </div>
                             </div>
                          <div class="tab-pane" id="campaign_reports">
                            <iframe src="https://<%=rcpUrl%>/rrcp/imc/rpt/report_smartwidget_activity_day_new_iframe.jsp?cust_id=<%=cust.s_cust_id%>&popup_id=<%=popup_id%>" style="border:none;width: calc(100vw - 75px); height: 120vh;"></iframe>
                             </div>
                </div>
                
                <div class="preview-area">
                    <label class="col-md-2 col-form-label">Preview Area</label>
                    <div style="display: flex; flex-direction: column;">
                      <div class="preview-panel"></div>
                    </div>
                </div>
                
              </div>
              <!--BODY-END-->
            </div>
  </div>
  
  <script src="./dist/js/jquery.min.js"></script>
    <script src="./dist/js/bootstrap.bundle.min.js"></script>
    <script src="./dist/js/adminlte.min.js"></script>
    <script src="./dist/js/select2.full.min.js"></script>
    <script src="./dist/js/bootstrap-slider.min.js"></script>
    <!-- Begin emoji-picker JavaScript -->
<script src="assets/emoji/js/config.js"></script>
<script src="assets/emoji/js/util.js"></script>
<script src="assets/emoji/js/jquery.emojiarea.js"></script>
<script src="assets/emoji/js/emoji-picker.js"></script>
<script src="assets/emoji/js/unicode_emoji.js"></script>
<!-- End emoji-picker JavaScript -->
    
    <script>
        $(function () {
        // Initializes and creates emoji set from sprite sheet
        window.emojiPicker = new EmojiPicker({
            emojiable_selector: '[data-emojiable=true]',
            assetsPath: 'assets/emoji/img/',
            popupButtonClasses: 'fa fa-smile-o'
        });
        window.emojiPicker.discover();
    });
                          

        
        
        
        var custId = '<%=cust.s_cust_id%>';
        var rcp_url = '<%=rcpUrl%>';
        var popup_id = '<%=popup_id%>';
        var configLoaded = false;
        if(popup_id=='null') {
            popup_id = [...Array(30)].map(i=>(~~(Math.random()*36)).toString(36)).join('');
            window.location = '?popup_id=' + popup_id;
        }
        var startPositionLabels = ['top right','top center','top left','left top','left center','left bottom','bottom left','bottom center','bottom right','right bottom','right center','right top'];
        document.getElementById('height').setAttribute('data-slider-max', screen.height);
        document.getElementById('width').setAttribute('data-slider-max', screen.width);
        document.getElementById('previewSize').setAttribute('data-slider-max', screen.width > screen.height ? screen.width : screen.height);
        
        
        
        
        $("#height").on("slide", function(slideEvt) {
            //console.log(slideEvt.value);
        });
    </script>
    <script src="./colorpicker.js"></script>
    <script src="./smartwidget.js"></script>
    <script src="./script.js"></script>
    <script>
    <%
    		cp = null;
    		conn = null;
    		stmt =null;
    
    		try
    		{
    			cp = ConnectionPool.getInstance();			
    			conn = cp.getConnection(this);
    
    			stmt = conn.createStatement();
    
    			String sSql = "SELECT form_id, config_param, popup_id, popup_name FROM c_smart_widget_config WHERE cust_id =" + cust.s_cust_id + " AND popup_id ='" + popup_id + "'";
    
    			ResultSet rs = stmt.executeQuery(sSql);
    			if (rs.next() && popup_id!=null)
    			{%>
    				var form_id = <%=rs.getString(1)%>;
    				var widget_name = '<%=rs.getString(4)%>';
    				var config_param = JSON.parse('<%=rs.getString(2).replaceAll("'", "\\\\'")%>');
    				config_param.html = decodeURIComponent(config_param.html);
                    config_param.scriptCode = decodeURIComponent(config_param.scriptCode);
    				document.getElementById('formId').value = form_id;
    				document.getElementById('widgetName').value = widget_name;
                    if(!config_param.integration)config_param.integration = 'revotas';
    				setSmartWidgetParams(config_param);
                    if(config_param.conditionConfig) {
                        smartWidgetConditionConfig = config_param.conditionConfig;
                        fillGroupObject(smartWidgetConditionConfig);
                        reRender();
                    }
                 showHeadMenu();
                 configLoaded = true;
    			<%} else {%>
				var config = '{"type":"group","elements":[],"operator":"and"}';
				smartWidgetConditionConfig = JSON.parse(config);
				fillGroupObject(smartWidgetConditionConfig);
				reRender();
    			<%}
    			rs.close();
                          
                sSql = "select web_page, register_page, cart_page, order_page from c_smart_widget_settings where cust_id = " + cust.s_cust_id;
                rs = stmt.executeQuery(sSql); 
                if(rs.next()) {
                    %>
                    if(!savedPreviewUrl) {
                        document.getElementById('previewUrl').value = '<%=rs.getString(1)%>';
                    }
                    var registerPage = '<%=rs.getString(2)%>';
                    var cartPage = '<%=rs.getString(3)%>';
                    var orderPage = '<%=rs.getString(4)%>';
                    <%
                } else {
                    %>
                    var registerPage = '';
                    var cartPage = '';
                    var orderPage = '';
                    <%
                }
                    
                rs.close();
                          
    		}
    		catch(Exception ex)
    		{
    			throw ex;
    		}
    		finally
    		{
    			if (stmt!=null) stmt.close();
    			if (conn!=null) cp.free(conn);
    		}
	    	%>
    $('#delay').slider({
            formatter: function(value) {
                document.querySelector('label[for=delay]').textContent = 'Show the message when the visitor has view your site for a certain period of time (' + (value/1000) + ' s)';
                return (value/1000) + ' s';
            }
        });
        
        $('#scrollPercentage').slider({
            formatter: function(value) {
                document.querySelector('label[for=scrollPercentage]').textContent = 'Show the message when the visitor has scrolled a certain Percentage (' + value + '%)';
                return value + '%';
            }
        });

       $('#height').slider({
            formatter: function(value) {
                document.querySelector('label[for=height]').textContent = 'Height ('+(value == 0 ? 'auto' : value + ' px')+')';
                return (value == 0 ? 'auto' : value + ' px');
            }
        });
        
        $('#width').slider({
            formatter: function(value) {
                document.querySelector('label[for=width]').textContent = 'Width ('+(value == 0 ? 'auto' : value + ' px')+')';
                return (value == 0 ? 'auto' : value + ' px');
            }
        });
        
        $('#widgetSize').slider({
            formatter: function(value) {
                var result = value == 0 ? 'small' : value == 1 ? 'medium' : value == 2 ? 'large' : '';
                document.querySelector('label[for=widgetSize]').textContent = 'Widget Size ('+result+')';
                return result;
            }
        });
                        
        
        $('#previewSize').slider({
            formatter: function(value) {
                document.querySelector('label[for=previewSize]').textContent = 'Preview Size ('+(value == 0 ? 'auto' : value + ' px')+')';
                return (value == 0 ? 'auto' : value + ' px');
            }
        });
        
        $('#showDuration').slider({
            formatter: function(value) {
                document.querySelector('label[for=showDuration]').textContent = 'Show Duration (' + (value/1000) + ' s)';
                return (value/1000) + ' s';
            }
        });
                          
      $('#showDuration2').slider({
            formatter: function(value) {
                document.querySelector('label[for=showDuration2]').textContent = 'Show Duration (' + (value/1000) + ' s)';
                return (value/1000) + ' s';
            }
        });
        
        $('#closeDuration').slider({
            formatter: function(value) {
                document.querySelector('label[for=closeDuration]').textContent = 'Close Duration (' + (value/1000) + ' s)';
                return (value/1000) + ' s';
            }
        });
        
         $('#closeDuration2').slider({
            formatter: function(value) {
                document.querySelector('label[for=closeDuration2]').textContent = 'Close Duration (' + (value/1000) + ' s)';
                return (value/1000) + ' s';
            }
        });
                                          
        
        $('#autoCloseDelay').slider({
            formatter: function(value) {
                document.querySelector('label[for=autoCloseDelay]').textContent = 'Auto Close Duration (' + (value == 0 ? 'Disabled' : (value/1000) + ' s') + ')';
                return (value == 0 ? 'Disabled' : (value/1000) + ' s');
            }
        });
                          
        $('#initialDelay').slider({
            formatter: function(value) {
                document.querySelector('label[for=initialDelay]').textContent = 'Initial delay (' + (value/1000) + ' s)';
                return (value/1000) + ' s';
            }
        });
                          
      $('#loopInterval').slider({
            formatter: function(value) {
                document.querySelector('label[for=loopInterval]').textContent = 'Delay Between Notifications (' + (value/1000) + ' s)';
                return (value/1000) + ' s';
            }
        });
                          
      $('#autoCloseDelay2').slider({
            formatter: function(value) {
                document.querySelector('label[for=autoCloseDelay2]').textContent = 'Auto Close Duration (' + (value == 0 ? 'Disabled' : (value/1000) + ' s') + ')';
                return (value == 0 ? 'Disabled' : (value/1000) + ' s');
            }
        });
                 
        document.querySelectorAll('.widget_slider').forEach(slider => {
            if(!slider.classList.contains('no-preview')) {
                $('#'+slider.id).on('slideStop',()=>{
                    showPreview('sliderstop');
                });
            }
        });
                 
        if(configLoaded && config_param.type !== 'productAlert' && config_param.type !== 'socialProof') {
            showPreview('configLoaded');
        } else if(configLoaded && config_param.type === 'productAlert') {
            showProductAlertPreview();
        } else if(configLoaded && config_param.type === 'socialProof') {
            showSocialProofPreview();
        }
                          
        
    
  
    </script>
</body>
</html>
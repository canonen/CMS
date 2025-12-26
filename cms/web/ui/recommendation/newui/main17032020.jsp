<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
            com.britemoon.cps.imc.*,
			java.sql.*,java.net.*,
			java.io.*,java.util.*,
			java.text.DateFormat,org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%
	String cust_id = request.getParameter("cust_id");
	String camp_id = request.getParameter("camp_id");
	ConnectionPool cp = null;
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;

	Service service = null;
	Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust_id);
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
</head>
<body>
    <div class="col-md-12">
            <div class="card">
              <div class="card-header p-2">
                <ul class="nav nav-pills">
                  <li class="nav-item"><a class="nav-link active" href="#campaign_name" data-toggle="tab">Name</a></li>
                  <li class="nav-item"><a class="nav-link" href="#campaign_type" data-toggle="tab">Type</a></li>
                  <li class="nav-item"><a class="nav-link" href="#campaign_template" data-toggle="tab">Template</a></li>
                  <li class="nav-item"><a class="nav-link" href="#campaign_code" data-toggle="tab">Code</a></li>
                </ul>
              </div><!-- /.card-header -->
              <div class="card-body">
                <div class="tab-content">
                  <div class="tab-pane active" id="campaign_name">
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
                        <button id="saveCampaign" type="button" class="btn btn-primary">
                          Save
                        </button>
                  </div>
                  <!-- /.tab-pane -->
                    <div class="tab-pane" id="campaign_code">
                        <div class="form-group col-md-12">
                            <input type="text" class="form-control" id="campaignHtmlCode" readonly>
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
   
   String sql = "select camp_name, camp_title, camp_type, template_id, status, products_num_block, container_size, rcp_link from "
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
   if(rs.next()) {
       camp_name = rs.getString(1);
       camp_title = rs.getString(2);
       camp_type = rs.getString(3);
       template_id = rs.getString(4);
       status = rs.getString(5);
       products_num_block = rs.getString(6);
       container_size = rs.getString(7);
       rcp_link = rs.getString(8);
       %>
       <script>editMode=true;</script>
       <%
   }
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
   jsonObj.append("\"rcp_link\":\""+rcp_link+"\"");
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
</body>
</html>
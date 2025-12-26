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
	ConnectionPool cp = null;
	Connection conn = null;
	Statement stmt =null;
   
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
    
    


  <link rel="stylesheet" href="assets/css/font-awesome.min.css">
 
 
  
  <style>
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
      #slidingPosition>.selectbox, #drawerPosition>.selectbox {
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
    .btn-app2 > .fas, .btn-app2 > .fab, .btn-app2 > .glyphicon, .btn-app2 > .ion {
	    font-size: 30px;
	    line-height: 30px;
	    display: block;
	}
	.bg{background-color:#007e90;}
	.blabel{width: 100%;}
	
  </style>
  
</head>
<body>
   
   <div class="col-md-12">
            <div class="card">
             <!--HEADER-->
              <div class="card-header p-2">
                <ul class="nav nav-pills">
                  <li class="nav-item"><a class="nav-link active smartwidget_settings" href="#smartwidget_settings" data-toggle="tab">Settings</a></li>
                </ul>
              </div>
              <!--HEADER-END-->
              <!--BODY-->
              <div class="card-body">
                <div class="tab-content">


                    <div class="tab-pane active" id="smartwidget_settings">
                    <div class="form-group row">
                        <label for="webPage" class="col-md-2 col-form-label">Web Page</label>
                        <div class="col-md-4">
                          <input type="text" class="form-control" name="webPage" id="webPage" placeholder="optional">
                        </div>
                      </div>
                    <div class="form-group row">
                        <label for="registerPage" class="col-md-2 col-form-label">Register Page</label>
                        <div class="col-md-4">
                          <input type="text" class="form-control" name="registerPage" id="registerPage" placeholder="optional">
                        </div>
                      </div>
                      <div class="form-group row">
                        <label for="cartPage" class="col-md-2 col-form-label">Cart Page</label>
                        <div class="col-md-4">
                          <input type="text" class="form-control" name="cartPage" id="cartPage" placeholder="optional">
                        </div>
                      </div>
                      <div class="form-group row">
                        <label for="orderPage" class="col-md-2 col-form-label">Order Page</label>
                        <div class="col-md-4">
                          <input type="text" class="form-control" name="orderPage" id="orderPage" placeholder="optional">
                        </div>
                      </div>
    
                     </div>

                </div>
                <button id="saveSettings" class="btn btn-primary">Save</button>
                
              </div>
              <!--BODY-END-->
            </div>
  </div>
  
  <script src="./dist/js/jquery.min.js"></script>
    <script src="./dist/js/bootstrap.bundle.min.js"></script>
    <script src="./dist/js/adminlte.min.js"></script>
    <script src="./dist/js/select2.full.min.js"></script>
    <script src="./dist/js/bootstrap-slider.min.js"></script>
    
    <script>
        var custId = '<%=cust.s_cust_id%>';

    </script>
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
    
    			String sSql = "SELECT web_page, register_page, cart_page, order_page FROM c_smart_widget_settings WHERE cust_id =" + cust.s_cust_id;
    
    			ResultSet rs = stmt.executeQuery(sSql);
    			if (rs.next())
    			{%>
                    var web_page = '<%=rs.getString(1)%>';
                    var register_page = '<%=rs.getString(2)%>';
                    var cart_page = '<%=rs.getString(3)%>';
                    var order_page = '<%=rs.getString(4)%>';
                    document.getElementById('webPage').value = web_page;
                    document.getElementById('registerPage').value = register_page;
                    document.getElementById('cartPage').value = cart_page;
                    document.getElementById('orderPage').value = order_page;
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
            document.getElementById('saveSettings').addEventListener('click', function() {
                var web_page = document.getElementById('webPage').value;
                var register_page = document.getElementById('registerPage').value;
                var cart_page = document.getElementById('cartPage').value;
                var order_page = document.getElementById('orderPage').value;
                
            fetch('http://cms.revotas.com/cms/ui/smartwidgets/newui/save_smartwidget_settings.jsp?cust_id=<%=cust.s_cust_id%>',{	
                method: 'POST',
                mode: 'no-cors',
                headers: {
                    'Content-Type':'application/json'
                },
                body: web_page + '<|>' + register_page + '<|>' + cart_page + '<|>' + order_page
            }).then(function() {
                fetch('http://f.revotas.com/frm/smartwidgets/save_smartwidget_settings.jsp?cust_id=<%=cust.s_cust_id%>',{	
                    method: 'POST',
                    mode: 'no-cors',
                    headers: {
                        'Content-Type':'application/json'
                    },
                    body: web_page + '<|>' + register_page + '<|>' + cart_page + '<|>' + order_page
                }).then(function() {
                    alert("Configurations saved successfully");
                });
            });
            });
                
    </script>
</body>
</html>
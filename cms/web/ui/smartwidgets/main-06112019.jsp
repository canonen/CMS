<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.net.*,
			java.io.*,java.util.*,
			java.text.DateFormat,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%
	String cust_id = request.getParameter("cust_id");
	String popup_id = request.getParameter("popup_id");
	ConnectionPool cp = null;
	Connection conn = null;
	Statement stmt =null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Smart Widget Panel</title>
    
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="main-container" style="display:flex;justify-content: flex-start">
        <div class="control-panel">
        
	    <span style="margin-bottom: 10px;">
	    	<input id="enabled" type="checkbox"/>
	    	<label for="enabled" class="label" style="padding: 0;">Enabled</label>
	    </span>
            <label for="type" class="label">Type</label>
            <select class="config-select" id="type">
                <option value="sticky">Sticky</option>
                <option value="sliding">Sliding</option>
                <option value="slidingNoOverlay">Sliding (No overlay)</option>
                <option value="fading">Fading</option>
                <option value="fadingNoOverlay">Fading (No overlay)</option>
            </select>
            
            <label for="trigger" class="label">Trigger</label>
            <select class="config-select" id="trigger">
            	<option value="noTrigger">No Trigger</option>
                <option value="afterLoad" selected>After Load</option>
                <option value="mouseLeave">Mouse Leave Site</option>
                <option value="scroll">Scroll Down</option>
            </select>
            
            <label for="content-type" class="label">Content Type</label>
            <select class="config-select" id="content-type">
            	<option value="htmlCode" selected>HTML Code</option>
                <option value="iframeType">Iframe</option>
            </select>
            
            <div class="input-group">
            
            <div class="input-subgroup">

            <label class="widget-control label" for="background-color">Background Color</label>
            <div class="widget-control" id="background-color"></div>

            <label class="widget-control label" for="overlay-color">Overlay Color</label>
            <div class="widget-control" id="overlay-color"></div>

            </div>
            
            </div>
            
            <div class="input-group">
            
                <div class="input-subgroup">
                    <div class="group">
                        <input class="form-input text-input" id="popup_name" type="text" value="New Popup"/>
                        <label class="form-input-label" for="popup_name">Name</label>
                    </div>
                    <div class="group">
                        <input class="widget-control form-input text-input" id="show-duration" type="text" value="1s"/>
                        <label class="widget-control form-input-label" for="show-duration">Show Duration</label>
                    </div>

                    <div class="group">
                        <input class="widget-control form-input text-input" id="close-duration" type="text" value="1s"/>
                        <label class="widget-control form-input-label" for="close-duration">Close Duration</label>
                    </div>
                    
                    <div class="group">
                        <input class="widget-control form-input text-input" id="auto-close-delay" type="text"/>
                        <label class="widget-control form-input-label" for="auto-close-delay">Auto Close Delay</label>
                    </div>
                    
                    <div class="group">
                        <input class="trigger-control form-input text-input" id="DELAY" type="text" value="5s"/>
                        <label class="trigger-control form-input-label" for="DELAY">Delay</label>
                    </div>

                    <div class="group">
                        <input class="trigger-control form-input text-input" id="scroll-percentage" type="text" value="50"/>
                        <label class="trigger-control form-input-label" for="scroll-percentage">Scroll Percentage</label>
                    </div>
                </div>
                
                <div class="input-subgroup">
                    <div class="group">
                        <input class="widget-control form-input text-input" id="height" type="text" value="auto"/>
                        <label class="widget-control form-input-label" for="height">Height</label>
                    </div>

                    <div class="group">
                        <input class="widget-control form-input text-input" id="width" type="text" value="auto"/>
                        <label class="widget-control form-input-label" for="width">Width</label>
                    </div>

                    <div class="group">
                        <input class="content-type-control form-input text-input" id="HTML" type="text" value="<h1>TEST</h1>" readonly/>
                        <label class="content-type-control form-input-label" for="HTML">HTML</label>
                    </div>
                    
                    <div class="group">
                        <input class="content-type-control form-input text-input" id="iframe-link" type="text"/>
                        <label class="content-type-control form-input-label" for="iframe-link">Iframe Link</label>
                    </div>
                    
                    <div class="group">
                        <input class="content-type-control form-input text-input" id="iframe-class-name" type="text"/>
                        <label class="content-type-control form-input-label" for="iframe-class-name">Iframe Class</label>
                    </div>
                    
                </div>
            
            </div>
            
            <div class="input-group">
            
            <div class="input-subgroup">
            <label class="widget-control label" for="position">Position</label>
            <select class="widget-control config-select" id="position">
                <option value="top left">top left</option>
                <option value="top center">top center</option>
                <option value="top right">top right</option>
                <option value="left center">left center</option>
                <option value="center" selected>center</option>
                <option value="right center">right center</option>
                <option value="bottom left">bottom left</option>
                <option value="bottom center">bottom center</option>
                <option value="bottom right">bottom right</option>
            </select>
            
            <label class="widget-control label" for="start-position">Start Position</label>
            <select class="widget-control config-select" id="start-position">
                <option value="top right">top right</option>
                <option value="top center">top center</option>
                <option value="top left">top left</option>
                <option value="left top">left top</option>
                <option value="left center">left center</option>
                <option value="left bottom">left bottom</option>
                <option value="bottom left">bottom left</option>
                <option value="bottom center">bottom center</option>
                <option value="bottom right">bottom right</option>
                <option value="right bottom">right bottom</option>
                <option value="right center" selected>right center</option>
                <option value="right top">right top</option>
            </select>

            <label class="widget-control label" for="end-position">End Position</label>
            <select class="widget-control config-select" id="end-position">
                <option value="start" selected>start</option>
                <option value="center">center</option>
                <option value="end">end</option>
            </select>
            </div>
            <div class="input-subgroup">

            <label class="widget-control label" for="vertical-align">Vertical Align</label>
            <select class="widget-control config-select" id="vertical-align">
                <option value="top">top</option>
                <option value="center" selected>center</option>
                <option value="bottom">bottom</option>
            </select>
            
            <label class="widget-control label" for="horizontal-align">Horizontal Align</label>
            <select class="widget-control config-select" id="horizontal-align">
                <option value="left">left</option>
                <option value="center" selected>center</option>
                <option value="right">right</option>
            </select>
            </div>
           
            
            </div>
            
            
            <div class="input-group">
            <div class="input-subgroup">
            
            <div class="group">
                <input class="widget-control form-input text-input" id="css-links" type="text"/>
                <label class="widget-control form-input-label" for="css-links">CSS Links(comma separated)</label>
            </div>
            
            <div class="group">
                <input class="widget-control form-input text-input" id="register-page" type="text"/>
                <label class="widget-control form-input-label" for="register-page">Register page(comma separated)</label>
            </div>
            
            <div class="group">
                <input class="widget-control form-input text-input" id="cart-page" type="text"/>
                <label class="widget-control form-input-label" for="cart-page">Cart page(comma separated)</label>
            </div>
            
            <div class="group">
                <input class="widget-control form-input text-input" id="order-page" type="text"/>
                <label class="widget-control form-input-label" for="order-page">Order page(comma separated)</label>
            </div>
            
            <label for="form_id" class="label">Form</label>
	<select id="form_id" class="config-select">
	<%
		cp = null;
		conn = null;
		stmt =null;

		try
		{
			cp = ConnectionPool.getInstance();			
			conn = cp.getConnection(this);

			stmt = conn.createStatement();

			String sSql = "SELECT f.form_id, f.form_name FROM csbs_form f, csbs_form_edit_info fei WHERE f.cust_id = " + cust_id + " AND fei.form_id = f.form_id ORDER BY f.form_name ASC";

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
            <div>
                <button class="smart-widget-button" id="preview">Preview</button>
                <button class="smart-widget-button" id="save">Save</button>
            </div>
            
            
        </div>
        <div style="display: flex; flex-direction: column;">
          <div class="preview-panel"></div>
           <div class="input-group condition-configs">
            <div class="condition-panel">
                <button class="smart-widget-button" id="group-conditions">Group Conditions</button>
                <button class="smart-widget-button" id="remove-group">Remove Group</button>
                <button class="smart-widget-button" id="ungroup-conditions">Ungroup conditions</button>
            </div>
            </div>
            
        </div>
    </div>
    
    <script src="smartwidget.js"></script>
    <script src="colorpicker.js"></script>
    <script src="script.js"></script>
    <script>
        var cust_id = '<%=cust_id%>';
        var popup_id = '<%=popup_id%>';
    	document.getElementById('save').addEventListener('click', function() {
    		var form_id = document.getElementById('form_id').value;
    		var popup_name = document.getElementById('popup_name').value;
		fetch('http://cms.revotas.com/cms/ui/smartwidgets/save_smartwidget_config.jsp?popup_name='+popup_name+'&form_id='+form_id+'&cust_id=<%=cust_id%>&popup_id=<%=popup_id%>',{	
			method: 'POST',
			headers: {
				'Content-Type':'application/json'
			},
			body: JSON.stringify(getSmartWidgetParamsToSend())
		}).then(function() {
			fetch('http://f.revotas.com/frm/smartwidgets/save_smartwidget_config.jsp?popup_name='+popup_name+'&form_id='+form_id+'&cust_id=<%=cust_id%>&popup_id=<%=popup_id%>',{	
				method: 'POST',
				headers: {
					'Content-Type':'application/json'
				},
				body: JSON.stringify(getSmartWidgetParamsToSend())
		}).then(function() {
			alert('Configurations saved successfully');
		})
		
		})
		
	})
    <%
    		cp = null;
    		conn = null;
    		stmt =null;
    
    		try
    		{
    			cp = ConnectionPool.getInstance();			
    			conn = cp.getConnection(this);
    
    			stmt = conn.createStatement();
    
    			String sSql = "SELECT form_id, config_param, popup_id, popup_name FROM c_smart_widget_config WHERE cust_id =" + cust_id + " AND popup_id ='" + popup_id + "'";
    
    			ResultSet rs = stmt.executeQuery(sSql);
    			if (rs.next())
    			{%>
    				var form_id = <%=rs.getString(1)%>;
    				var popup_name = '<%=rs.getString(4)%>';
    				var config_param = JSON.parse('<%=rs.getString(2).replaceAll("'", "\\\\'")%>');
    				config_param.html = decodeURIComponent(config_param.html);
    				document.getElementById('form_id').value = form_id;
    				document.getElementById('popup_name').value = popup_name;
    				setSmartWidgetParams(config_param);
                    if(config_param.conditionConfig) {
                        smartWidgetConditionConfig = config_param.conditionConfig;
                        fillGroupObject(smartWidgetConditionConfig);
                        reRender();
                    }
    			<%} else {%>
				var config = '{"type":"group","elements":[],"operator":"or"}';
				smartWidgetConditionConfig = JSON.parse(config);
				fillGroupObject(smartWidgetConditionConfig);
				reRender();
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
	    	showPreview();
	    	Array.from(document.querySelectorAll("input.text-input")).forEach(function(element) {
		    var el = document.querySelector('label[for='+element.id+']');
		    if(element.value) el.classList.add('shrink');
		    element.addEventListener('change',function(e){
			if(e.target.value) el.classList.add('shrink');
			else el.classList.remove('shrink');
		    });
})
    </script>
</body>
</html>
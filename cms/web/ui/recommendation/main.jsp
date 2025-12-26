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
	ConnectionPool cp = null;
	Connection conn = null;
	Statement stmt =null;

	Service service = null;
	Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust_id);
	service = (Service) services.get(0);
   String rcpUrl = service.getURL().getHost();
   
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Recommendation Panel</title>
    
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="main-container" style="display:flex;justify-content: flex-start; flex-direction:column;">
       <div>
                <button class="recommendation-button" id="new">New</button>
                <button class="recommendation-button" id="save">Save</button>
                <button class="recommendation-button" id="generate_code">Generate Code</button>
            </div>
        <div class="control-panel"></div>
    </div>
    <script>var rcp_url = '<%=rcpUrl%>';</script>
    <script src="script.js"></script>
    <script>
        var cust_id = '<%=cust_id%>';
    	document.getElementById('save').addEventListener('click', function() {
        config.forEach(function(element) {
            element.cssInput = encodeURIComponent(element.cssInput);
        });
		fetch('https://cms.revotas.com/cms/ui/recommendation/save_recommendation_config.jsp?cust_id=<%=cust_id%>',{	
			method: 'POST',
			headers: {
				'Content-Type':'application/json'
			},
			body: JSON.stringify(config)
		}).then(function() {
			fetch('https://f.revotas.com/frm/recommendation/save_recommendation_config.jsp?cust_id=<%=cust_id%>',{	
				method: 'POST',
				headers: {
					'Content-Type':'application/json'
				},
				body: JSON.stringify(config)
            }).then(function() {
                alert('Configurations saved successfully');
                config.forEach(function(element) {
                    element.cssInput = decodeURIComponent(element.cssInput);
                });
            });
		
		})
		
	})
    document.getElementById('generate_code').addEventListener('click',function() {
        var width = 500;
        var height = 300;
        var left = (screen.width/2)-(width/2);
        var top = (screen.height/2)-(height/2);
            window.open("./generated.html", "Javascript Code", "height="+height+",width="+width+",left="+left+",top="+top);
	});
    fetch('https://f.revotas.com/frm/recommendation/get_recommendation_config.jsp?cust_id=<%=cust_id%>')
        .then(function(resp){return resp.json();})
        .then(function(resp){
            if(resp) {
                config=resp;
                renderConfigs();
            }
        })
    /*<%
    		cp = null;
    		conn = null;
    		stmt =null;
    
    		try
    		{
    			cp = ConnectionPool.getInstance();			
    			conn = cp.getConnection(this);
    
    			stmt = conn.createStatement();
    
    			String sSql = "SELECT config FROM c_recommendation_config WHERE cust_id =" + cust_id;
    
    			ResultSet rs = stmt.executeQuery(sSql);
    			if (rs.next())
    			{%>
    				config = JSON.parse('<%=rs.getString(1)%>');
                    renderConfigs();
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
	    	%>*/
            
    </script>
</body>
</html>
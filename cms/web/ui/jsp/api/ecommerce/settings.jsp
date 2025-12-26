<%@ page
        language="java"
        import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.rpt.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.*,
			com.britemoon.rcp.*,
			com.britemoon.rcp.imc.*,
			com.britemoon.rcp.que.*,
			java.sql.*,java.net.*,
			java.io.*,java.util.*,
			org.json.JSONObject,
			java.text.DateFormat,org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
        <%
        String sCustId = request.getParameter("custId");
        /*
        Service service = null;
            Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id);
            service = (Service) services.get(0);
           String rcpUrl = service.getURL().getHost();
        */

        String jsOut =("<!--------- Revotrack ------------>\n" +
                "\n" +
                "\n" +
                "  var setRvsCustomParamsFrom = 'inline';\n" +
                "  var rvsCustomParams = [['oid', ''], ['amt', '']];\n" +
                "  (function() {\n" +
                "    var _rTag = document.getElementsByTagName('script')[0];\n" +
                "    var _rcTag = document.createElement('script');\n" +
                "      _rcTag.type = 'text/javascript';\n" +
                "      _rcTag.async = 'true';\n" +
                "      _rcTag.src = ('https:' == document.location.protocol ? 'https://' : 'http://') + " + sCustId+ ".revotas.com/trc/jvs/rvstmini.js';\n" +
                "      _rTag.parentNode.insertBefore(_rcTag,_rTag);\n" +                             // normalde sCustId yerinde '<rvts_customer_name> var
                "\n" +                                                                               // serviceden cekilen cust obejctinin nameini aliyor ve yerine koyuyor
                "\n" +
                "<!--------- Revotrack ------------>\n");

        out.println(jsOut);
        %>
        <%--
        var rcp_url = '<%=rcpUrl%>';
        var custName = '<%=cust.s_login_name%>';
        var customerId = '<%=cust.s_cust_id%>';
        document.getElementById('revotrack').value = document.getElementById('revotrack').value.replace('<rvts_customer_name>',custName.toLowerCase());
        --%>


<%@ page
        language="java"
        import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			java.sql.*,java.net.*,
			java.io.*,java.util.*,
			org.json.JSONObject,
			java.text.DateFormat,org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp"%>
<%@ include file="../../utilities/validator.jsp"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="loc" value="en_US"/>
<c:if test="${!(empty param.locale)}">
    <c:set var="loc" value="${param.locale}"/>
</c:if>

<fmt:setLocale value="${loc}" />

<fmt:bundle basename="app">



<!--------- Revotrack ------------>
<%--
 <script type="text/javascript">
  var setRvsCustomParamsFrom = 'inline';
  var rvsCustomParams = [['oid', ''], ['amt', '']];
  (function() {
    var _rTag = document.getElementsByTagName('script')[0];
    var _rcTag = document.createElement('script');
      _rcTag.type = 'text/javascript';
      _rcTag.async = 'true';
      _rcTag.src = ('https:' == document.location.protocol ? 'https://' : 'http://') + '<rvts_customer_name>.revotas.com/trc/jvs/rvstmini.js';
      _rTag.parentNode.insertBefore(_rcTag,_rTag);
  })();
</script>
--%>
<!--------- Revotrack ------------>

        <%
        Service service = null;
            Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id);
            service = (Service) services.get(0);
           String rcpUrl = service.getURL().getHost();
        %>


        <%--
        var rcp_url = '<%=rcpUrl%>';
        var custName = '<%=cust.s_login_name%>';
        var customerId = '<%=cust.s_cust_id%>';
        document.getElementById('revotrack').value = document.getElementById('revotrack').value.replace('<rvts_customer_name>',custName.toLowerCase());
        --%>

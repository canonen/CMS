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
<%@ include file="../validator.jsp"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<c:set var="loc" value="en_US"/>
<c:if test="${!(empty param.locale)}">
    <c:set var="loc" value="${param.locale}"/>
</c:if>

<fmt:setLocale value="${loc}" />

<fmt:bundle basename="app">

    <HEAD>

        <TITLE>Revotrack Settings</TITLE>
        <%@ include file="../header.html" %>
        <link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
        <link rel="stylesheet" href="/cms/ui/css/demo_table_jui.css" TYPE="text/css">
        <link rel="stylesheet" href="/cms/ui/css/jquery-ui-1.7.2.custom.css" TYPE="text/css">
        <link rel="stylesheet" href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.min.css" type="text/css">
        <link rel="stylesheet" href="https://cdn.datatables.net/rowreorder/1.2.6/css/rowReorder.dataTables.min.css" type="text/css">

        <SCRIPT src="../../js/scripts.js"></SCRIPT>
        <!--<SCRIPT src="../../js/jquery.js"></SCRIPT>
        <SCRIPT src="/cms/ui/js/jquery.dataTables.min_new.js"></SCRIPT>
        <SCRIPT src="/cms/ui/js/jquery.dataTables.rowReorder.min.js"></SCRIPT>-->
        <script src="https://code.jquery.com/jquery-3.3.1.js"></script>
        <script src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.min.js"></script>
        <script src="https://cdn.datatables.net/rowreorder/1.2.6/js/dataTables.rowReorder.min.js"></script>

        <style>
            body {
                /*background-color: #818181;*/
                height: 100vh;
                width: 100vw;
                margin: 0;
            }
            textarea {
                height: 40vh;
                width: 40vw;
                resize: none;
            }
        </style>
    </HEAD>
    <BODY class="paging_body">
        <%-- <div class="page_header">Revotas WebPush</div>--%>
    <div class="page_header">Revotrack Settings</div>
    <div id="info">
        <div id="xsnazzy">

            <div class="xboxcontent">
                <TABLE class=listTable cellSpacing=0 cellPadding=2 width="100%" style="padding-top: 4px;">
                    <TBODY>
                    <TR>
                        <TD noWrap align=left style="padding-left:10px; width:5%;">
                            <%
                                if(logger == null)
                                {
                                    logger = Logger.getLogger(this.getClass().getName());
                                }
                            %>
                            <%--<a href="./service-worker.js" download="service-worker" class="newbutton">Download Service Worker</a>--%>
                        </td>
                        </TD>
                    </TR>
                    </TBODY>
                </TABLE>
                <textarea id="revotrack" cols="66" rows="16" spellcheck="false" readonly>

<!--------- Revotrack ------------>

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

<!--------- Revotrack ------------>
</textarea>
            </div>
        </div>
    </div>
    </td>
    </tr>
    </table>
    <br><br>
    <script>
        <%
        Service service = null;
            Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id);
            service = (Service) services.get(0);
           String rcpUrl = service.getURL().getHost();
        %>
        var rcp_url = '<%=rcpUrl%>';
        var custName = '<%=cust.s_login_name%>';
        var customerId = '<%=cust.s_cust_id%>';
        document.getElementById('revotrack').value = document.getElementById('revotrack').value.replace('<rvts_customer_name>',custName.toLowerCase());
    </script>
    </body>
</fmt:bundle>
</HTML>

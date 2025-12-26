<%@ page
		language="java"
		import="com.britemoon.*,
			com.britemoon.cps.*,
			java.io.*,java.sql.*,
			java.util.*,java.sql.*,
			org.w3c.dom.*,org.apache.log4j.*"
		contentType="text/html;charset=UTF-8"
%>
<%@ include file="../jsp/header.jsp" %>
<%@ include file="../jsp/validator.jsp"%>
<%! static Logger logger = null;%>


<%

	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	boolean bPasswordExpiring = user.isPassExpiring();

	String seenPop = null;
	if (seenPop == null) seenPop = ui.getSessionProperty("pass_exp_pop");
	if ((seenPop == null)||("".equals(seenPop))) seenPop = "0";

	String sCustId = request.getParameter("cust_id");

	Customer cSuper = ui.getSuperiorCustomer();
	Customer cActive = ui.getActiveCustomer();


//CY 08/04/2013
//Is it the standard ui?
	boolean bSTANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

	boolean hasChildren = false;
	if(cSuper.m_Customers != null) hasChildren = true;

	boolean bDoRefresh = false;
	if(sCustId != null)
	{
		cActive = ui.setActiveCustomer(session, sCustId);
		bDoRefresh = true;
	}

	if(bDoRefresh)
	{
%>
<SCRIPT>
	parent.parent.location.reload();
</SCRIPT>
<%
}
else
{
%>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jstl/fmt" %>
<html>
<c:set var="loc" value="en_US"/>
<c:if test="${!(empty param.locale)}">
	<c:set var="loc" value="${param.locale}"/>
</c:if>

<fmt:setLocale value="${loc}" />

<fmt:bundle basename="app">
	<head>
		<title></title>
		<%@ include file="../jsp/header.html" %>
		<link rel="stylesheet" href="../css/newstyle.css" TYPE="text/css">

		<script>
			var isReady = false;
			var _oPop;

			function switch_cust()
			{
				var eX, eY;
				eX = window.event.screenX;
				eY = window.event.screenY;
				eY = eY + 15;
				if (isReady)
				{
					var frmTree = document.frames("cust_tree");

					_oPop = window.createPopup();
					_oPop.document.createStyleSheet("<%= ui.s_css_filename %>");

					with (_oPop.document.body)
					{
						// Populate the Popup's HTML
						innerHTML = frmTree.document.firstChild.outerHTML;
					}
					var i = 0;
					var oTds = _oPop.document.getElementsByTagName("TD");

					if (oTds.length != window.undefined)
					{
						for (i=0; i < oTds.length; i++)
						{
							if (oTds[i].className == "listItem_Data")
							{
								oTds[i].onmouseover = switch_on;
								oTds[i].onmouseout = switch_off;
								oTds[i].onclick = select_cust;
							}
						}
					}
					_oPop.show(250, eY, 400, 200);
				}
			}

			function switch_on()
			{
				var o = getElem();
				o.runtimeStyle.backgroundColor = "#CCDDFF";
				o.runtimeStyle.borderColor = "#004466";
			}

			function switch_off()
			{
				var o = getElem();
				o.runtimeStyle.backgroundColor = "";
				o.runtimeStyle.borderColor = "";
			}

			function select_cust()
			{
				var o = getElem();
				var cust_id = o.cust_id;
				location.href = "session_info.jsp?cust_id=" + cust_id;
			}

			// Gets the element in a popup that fired the event
			function getElem()
			{
				var o = getEvent().srcElement;

				while (o.tagName != "HTML" && o.tagName != "TD")
				{
					o = o.parentElement;
				}

				return o;
			}

			// Gets the event object for the popup that fired the event
			function getEvent()
			{
				var o = _oPop.document.parentWindow;

				o.event.cancelBubble = true;

				return o.event;
			}

			function switch_ui_mode(mode)
			{
				URL = "switch_ui_mode.jsp?mode=" + mode;
				this.location.href = URL;
			}

			function loadPassChange()
			{
				URL = "../setup/users/pass_change.jsp?status=1&user_id=<%= user.s_user_id %>";
				windowName = "PassChange";
				windowFeatures = "dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, height=350, width=400";
				window.open(URL, windowName, windowFeatures);
			}

		</script>
	</head>
	<body<% if (bPasswordExpiring && "0".equals(seenPop)) { %> onload="loadPassChange();"<% } %> marginheight="0" marginwidth="0" leftmargin="0" topmargin="0" style="padding:0px;">
	<%

		if (bPasswordExpiring) seenPop = "1";
		ui.setSessionProperty("pass_exp_pop", seenPop);
	%>

	<div class="home-topnavi-container">

				<% if (bSTANDARD_UI) {	%>
		<div class="home-topnavi-std">
					<%}else{
%>
			<div class="home-topnavi">

				<%
					}%>
				<div class="topnavi-links">
					<% if (bSTANDARD_UI) {	%>
					<a href="#">Revotas BASIC</a>
					<%
						}%>
					<a href="/cms/ui/jsp/home/system_notice.jsp" target="detail" class="first-link"><fmt:message key="Announcements"/></a>
					<a href="/cms/ui/jsp/help/faq_frame.jsp" target="detail">FAQ</a>
					<a href="/cms/ui/jsp/help/index.jsp" target="detail">Help</a>

					<c:url value="index.jsp?tab=Home&sec=1&url=home%2Fwelcome_frame.jsp" var="enURL">
						<c:param name="locale" value="en_US"/>
					</c:url>

					<a target="_parent" href="index.jsp?locale=en_EN?tab=Home&sec=1&url=home%2Fwelcome_frame.jsp">.</a>


					<c:url value="index.jsp?tab=Home&sec=1&url=home%2Fwelcome_frame.jsp" var="turkishURL">
						<c:param name="locale" value="tr_TR"/>
					</c:url>

					<a target="_parent" href="index.jsp?locale=tr_TR?tab=Home&sec=1&url=home%2Fwelcome_frame.jsp">.</a>

					<div style="clear:both;"></div>
				</div>

				<div class="topnavi-right">
					<div class="info"><%= user.s_user_name %> <%= (user.s_last_name!=null)?user.s_last_name:"" %>
						(<% if (hasChildren) { %> <a href="#" onclick="switch_cust();">[Switch]</a><% } %><%=cSuper.s_cust_name%>
						<%
							if (hasChildren)
							{
								if(cSuper != cActive)
								{
						%>
						&gt;&gt;
						<%= cActive.s_cust_name %>
						<%
								}
							}%>)
					</div>
					<% if (bSTANDARD_UI) {	%>
					<div class="search-box-std">
						<%}else{
						%>
						<div class="search-box">

							<%
								}%>

							<form target="detail" action="/cms/ui/jsp/edit/recip_edit_list.jsp" name="FT" method="POST">
								<input type="hidden" value="100" name="num_recips">
								<input type="text" name="email" value="Search a contact" onclick="this.value='';" onblur="this.value=!this.value?'Search a contact':this.value;"/>
								<input type="image" value="" src="https://www.revotas.com/transbtn.png" class="hoverinput" href="#" onclick="this.submit()" style="cursor:pointer;position: absolute;right: 0;top: 0px;display: block;background-color: transparent;border:none;margin: 0;padding: 0;width: 23px;height:20px"><span style="display:none">Search</span></button>

							</form>
						</div>
						<a href="#" class="settings"></a>
						<a target="_parent" href="/cms/ui/jsp/logout.jsp" class="logout"></a>
					</div>

				</div>

				<div class="home-topnavi-base">
					<div class="logo">

						<%
							if (!bSTANDARD_UI) {
						%>
						<img src="/cms/ui/ooo/images/revotaslogo_plus.png">
						<%
						}else{
						%>
						<img src="images/nav/revotaslogo.png">

						<%
							}
						%>

					</div>

					<div class="home-topnavi-base-links">
						<span style="background:url('images/nav/topmenu_01.png') repeat-x scroll 0 0 transparent;"></span>
						<a href="/cms/ui/jsp/home/welcome.jsp" target="detail"><fmt:message key="social_home"/></a>
						<a href="/cms/ui/jsp/camp/camp_list.jsp" target="detail"><fmt:message key="campaigns"/></a>
						<a href="/cms/ui/jsp/report/report_list.jsp?amount=999999" target="detail"><fmt:message key="reports"/></a>
						<a href="/cms/ui/jsp/cont/cont_list.jsp" target="detail"><fmt:message key="contents"/></a>
						<a target="detail" class="no-border" href="/cms/ui/jsp/bill/bill_form.jsp"><fmt:message key="delivery_summary"/></a>
						<span style="background:url('images/nav/topmenu_04.png') repeat-x scroll 0 0 transparent;"></span>
						<div style="clear:both"></div>
					</div>
				</div>

			</div>

			<iframe width="1" height="1" name="cust_tree" id="cust_tree" src="../jsp/cust/cust_tree.jsp" style="display:none;"></iframe>
	</body>
</fmt:bundle>
</html>
<%
	}
%>
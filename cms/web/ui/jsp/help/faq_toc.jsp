<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			java.io.*,java.sql.*,
			java.net.*,java.util.*,
			java.util.*,java.sql.*,
			org.w3c.dom.*,javax.mail.*,
			javax.mail.internet.*,org.apache.log4j.*"
%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
%>

<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<html>
<head>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="JavaScript" src="help.js"></script>
<style>

	table
	{
		width: 100%;
		table-layout: fixed;
	}
	
</style>

<script language="JavaScript">

	var _oXml = new ActiveXObject("Microsoft.XMLDOM");
	var _oXsl = new ActiveXObject("Msxml2.FreeThreadedDOMDocument");

	function window.onload()
	{
		_oXml.async = false;
		_oXsl.async = false;
		_oXml.load("faq_xml.jsp");
		_oXsl.load("faq_toc.xsl");

		var oXslTemplate = new ActiveXObject("Msxml2.XSLTemplate");
		oXslTemplate.stylesheet = _oXsl;
		
		var oXslProc = oXslTemplate.createProcessor();
		oXslProc.input = _oXml;

<%
		String topic = request.getParameter("topic");
		
		if (topic != null && topic != "")
		{
			%>
			oXslProc.addParameter("autoLoadTopic","<%= topic %>");
			<%
		}
%>
		oXslProc.transform();

		divTOC.innerHTML = oXslProc.output;
	}


	function toggle(o, faq_id)
	{
		var oRow = o.nextSibling;

		if (oRow.style.display == "inline")
		{
			o.cells[0].firstChild.src = "imgs/16_closedBook.gif";
			oRow.style.display = "none";
		}
		else
		{
			// Handle ' in strings as to not break the XML Node Select
			var sSelect = o.cells[1].innerText.replace(/'/g,"\\'");
			var sTmp = "";
			
			switch (o.level)
			{
				// Grabs the "Code" to make sure things are unique since we are keying off of the Title
				case "0": sSelect = "/books/volume[@name='" + sSelect + "' and @code='" + o.code + "']/chapter";		break;
				case "1": sSelect = "/books/volume/chapter[@name='" + sSelect + "' and ../@code='" + o.code + "']/page";	break;
			}
			
			if (oRow.cells[1].innerText == "")
			{
				var oNodeList = _oXml.selectNodes(sSelect);
				var iLen = oNodeList.length;

				for (var i = 0; i < iLen; i++)
				{
					sTmp += oNodeList.item(i).transformNode(_oXsl);
				}

				oRow.cells[1].innerHTML = sTmp;
			}

			o.cells[0].firstChild.src = "imgs/16_openBook.gif";
			oRow.style.display = "inline";
			
			if (faq_id != undefined && faq_id != "")
			{
				parent.helpContents.location.href = "faq_display.jsp?faq_id=" + faq_id;
			}
		}
	}
	
</script>

<body>
<div class="HelpHeading">Contents:</div>

<div id="divTOC"></div>

</body>
</html>
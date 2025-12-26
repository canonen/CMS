<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.io.*,
			org.xml.sax.*,
			javax.xml.transform.*,
			javax.xml.transform.stream.*,
			org.apache.log4j.Logger"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<html>
<head>
<title>Print Content</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%= ui.s_css_filename %>" TYPE="text/css">
</head>
<SCRIPT LANGUAGE="JAVASCRIPT">
<%@ include file="../../js/scripts.js" %>
	
	function hover_on()
	{
		var o = window.event.srcElement;
		o.runtimeStyle.backgroundColor = "#CCDDFF";
		o.runtimeStyle.borderColor = "#004466";
	}
	
	function hover_off()
	{
		var o = window.event.srcElement;
		o.runtimeStyle.backgroundColor = "";
		o.runtimeStyle.borderColor = "";
	}
	
	function edit_section(id)
	{
		var URL = "doc_step_2.jsp?id=" + id;
		var windowName = "SectionEdit";
		var windowFeatures = "dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, height=650, width=700";
		var SmallWin = window.open(URL, windowName, windowFeatures);
	}
	
	function switch_on()
	{
		var o = getElem();
		o.runtimeStyle.backgroundColor = "#CCDDFF";
		o.runtimeStyle.borderColor = "#004466";
		o.children[0].rows[0].cells[0].runtimeStyle.backgroundColor = "#CCDDFF";
		o.children[0].rows[0].cells[0].runtimeStyle.borderColor = "#004466";
		o.children[0].rows[0].cells[1].runtimeStyle.backgroundColor = "#CCDDFF";
		o.children[0].rows[0].cells[1].runtimeStyle.borderColor = "#004466";
	}

	function switch_off()
	{
		var o = getElem();
		o.runtimeStyle.backgroundColor = "";
		o.runtimeStyle.borderColor = "";
		o.children[0].rows[0].cells[0].runtimeStyle.backgroundColor = "";
		o.children[0].rows[0].cells[0].runtimeStyle.borderColor = "";
		o.children[0].rows[0].cells[1].runtimeStyle.backgroundColor = "";
		o.children[0].rows[0].cells[1].runtimeStyle.borderColor = "";
	}
	
	// Gets the element in a popup that fired the event
	function getElem()
	{
		var o = getEvent().srcElement;

		while (o.className != "listItem_Data")
		{
			o = o.parentElement;
		}

		return o;
	}

	// Gets the event object for the popup that fired the event
	function getEvent()
	{
		var o = document.parentWindow;

		o.event.cancelBubble = true;

		return o.event;
	}
	
	function showHide(id)
	{
		if (document.getElementById("cont_" + id).style.display == "none")
		{
			document.getElementById("cont_" + id).style.display = "";
		}
		else
		{
			document.getElementById("cont_" + id).style.display = "none";
		}
	}

	function previewPrint(opt)
	{
		var URL = "preview.jsp?opt=" + opt;
		var windowName = "PreviewPrint";
		var windowFeatures = "dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, height=700, width=650";
		var SmallWin = window.open(URL, windowName, windowFeatures);
	}

	function weighPrint()
	{
		var URL = "weight.jsp";
		var windowName = "WeighPrint";
		var windowFeatures = "dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, height=600, width=550";
		var SmallWin = window.open(URL, windowName, windowFeatures);
	}

</SCRIPT>
<script language="javascript" src="../../js/tab_script.js"></script>
</head>
<body>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left">
			<a href="javascript:previewPrint('dyn');" class="subactionbutton">Dynamic Preview</a>&nbsp;&nbsp;&nbsp;
		</td>
		<td vAlign="middle" align="left">
			<a href="javascript:previewPrint('live');" class="subactionbutton">Live Data Preview</a>&nbsp;&nbsp;&nbsp;
		</td>
		<td vAlign="middle" align="left">
			<a href="javascript:weighPrint();" class="subactionbutton">Weigh Content</a>&nbsp;&nbsp;&nbsp;
		</td>
	</tr>
</table>
<br>
<table class=main cellspacing=1 cellpadding=1 width="650">
	<tr>
		<th width="321">Document Preview</th>
		<th width="329">Edit Sections</th>
	</tr>
	<tr>
		<td width="321"><img src="demo/bb_postcard.gif" align="Middle" border="0" style="height:450px;width:321px;" /></td>
		<td width="329" valign="top" style="padding:0px;">
			<table border="0" cellspacing="0" cellpadding="2" width="100%">
				<tr>
					<td class="subsectionheader" colspan="2">Page 1 - Front Side</td>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<td class="listItem_Data" onmouseover="switch_on();" onmouseout="switch_off();" onclick="edit_section('1');" style="cursor:hand;">
						<table border="0" cellspacing="0" cellpadding="2" width="100%">
							<tr>
								<td width="60%">Offer Masthead</td>
								<td width="40%">(Logic)</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<td class="listItem_Data" onmouseover="switch_on();" onmouseout="switch_off();" onclick="edit_section('2');" style="cursor:hand;">
						<table border="0" cellspacing="0" cellpadding="2" width="100%">
							<tr>
								<td width="60%">Offer Image</td>
								<td width="40%">(Logic)</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<td class="listItem_Data" onmouseover="switch_on();" onmouseout="switch_off();" onclick="edit_section('3');" style="cursor:hand;">
						<table border="0" cellspacing="0" cellpadding="2" width="100%">
							<tr>
								<td width="60%">Intro Text</td>
								<td width="40%">(Content)</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<td class="listItem_Data" onmouseover="switch_on();" onmouseout="switch_off();" onclick="edit_section('4');" style="cursor:hand;">
						<table border="0" cellspacing="0" cellpadding="2" width="100%">
							<tr>
								<td width="60%">Salutation</td>
								<td width="40%">(Content)</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<td class="listItem_Data" onmouseover="switch_on();" onmouseout="switch_off();" onclick="edit_section('5');" style="cursor:hand;">
						<table border="0" cellspacing="0" cellpadding="2" width="100%">
							<tr>
								<td width="60%">Offer Body</td>
								<td width="40%">(Logic)</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<td class="listItem_Data" onmouseover="switch_on();" onmouseout="switch_off();" onclick="edit_section('6');" style="cursor:hand;">
						<table border="0" cellspacing="0" cellpadding="2" width="100%">
							<tr>
								<td width="60%">Body of PostCard</td>
								<td width="40%">(Content)</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td class="subsectionheader" colspan="2">Page 2 - Address Info</td>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<td class="listItem_Data" onmouseover="switch_on();" onmouseout="switch_off();" onclick="edit_section('7');" style="cursor:hand;">
						<table border="0" cellspacing="0" cellpadding="2" width="100%">
							<tr>
								<td width="60%">Address Info</td>
								<td width="40%">(Content)</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
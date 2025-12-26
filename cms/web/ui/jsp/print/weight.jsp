<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.io.*,java.sql.*,
			java.util.*,org.w3c.dom.*,
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
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<html>
<head>
<title>Content Weighting</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%= ui.s_css_filename %>" TYPE="text/css">
<script language="javascript" src="../../js/tab_script.js"></script>
<script language="javascript">

function edit_section(id)
{
	var URL = "doc_step_2.jsp?id=" + id;
	var windowName = "SectionEdit";
	var windowFeatures = "dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, height=650, width=700";
	var SmallWin = window.open(URL, windowName, windowFeatures);
}

function EditCont(contURL)
{
	ContWin = window.open(contURL, 'EditLogic','scrollbars=yes,resizable=yes,toolbar=no,width=650,height=350');
}

</script>
</head>
<body>
<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
	<tr height="25">
		<td align="right"><a href="javascript:self.close();" class="subactionbutton">Close [X]</a></td>
	</tr>
	<tr height="120">
		<td>
			<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=100% border=0>
				<tr>
					<td class=EmptyTab valign=center nowrap align=middle width=100%><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tr>
					<td class=fillTabbuffer valign=top align=left width=100%><img height=2 src="../../images/blank.gif" width=1></td>
				</tr>
				<tbody class=EditBlock id=block1_Step1>
				<tr>
					<td class=fillTab valign=top align=center width=100%>
						<table class="main" cellspacing="1" cellpadding="3" border="0" width="100%">
							<tr>
								<td align="center" valign="middle" style="padding:10px;">
									<b>Content Weighing</b><br>
									The content sections below have been weighed and calculated using the final font formats 
									of the actual print document. If the text will not fit in the allowed space, the messages 
									below will indicate if changes need to be made.
								</td>
							</tr>
						</table>
					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
	<tr>
		<td valign="top">
			<table width=100% class="main" cellpadding="2" cellspacing="1">
				<tr>
					<th colspan="2">Offer Masthead</th>
				</tr>
				<tr>
					<td width="50%"><a href="javascript:EditCont('doc_step_3_edit.jsp?id=10');">Win Back : 60 Days Masthead</a></td>
					<td width="50%"><span style="color: #339933;">OK</span></td>
				</tr>
				<tr>
					<td width="50%"><a href="javascript:EditCont('doc_step_3_edit.jsp?id=11');">Win Back : 90 Days Masthead</a></td>
					<td width="50%"><span style="color: #CC3333;">Error:</span> Image exceeds allowed size by 14 pixels</td>
				</tr>
				<tr>
					<td width="50%"><a href="javascript:EditCont('doc_step_3_edit.jsp?id=12');">Win Back : 120 Days Masthead</a></td>
					<td width="50%"><span style="color: #339933;">OK</span></td>
				</tr>
				<tr>
					<td width="50%"><a href="javascript:EditCont('doc_step_3_edit.jsp?id=13');">Win Back : Masthead</a></td>
					<td width="50%"><span style="color: #339933;">OK</span></td>
				</tr>
			</table>
			<br>
			<table width=100% class="main" cellpadding="2" cellspacing="1">
				<tr>
					<th colspan="2">Offer Image</th>
				</tr>
				<tr>
					<td width="50%"><a href="javascript:EditCont('doc_step_3_edit.jsp?id=20');">Win Back : Last Purchased : Jewelry</a></td>
					<td width="50%"><span style="color: #339933;">OK</span></td>
				</tr>
				<tr>
					<td width="50%"><a href="javascript:EditCont('doc_step_3_edit.jsp?id=21');">Win Back : Last Purchased : Kitchen</a></td>
					<td width="50%"><span style="color: #339933;">OK</span></td>
				</tr>
				<tr>
					<td width="50%"><a href="javascript:EditCont('doc_step_3_edit.jsp?id=22');">Win Back : Last Purchased Electronics</a></td>
					<td width="50%"><span style="color: #339933;">OK</span></td>
				</tr>
				<tr>
					<td width="50%"><a href="javascript:EditCont('doc_step_3_edit.jsp?id=23');">Win Back : All Products</a></td>
					<td width="50%"><span style="color: #CC3333;">Error:</span> Image exceeds allowed size by 36 pixels</td>
				</tr>
			</table>
			<br>
			<table width=100% class="main" cellpadding="2" cellspacing="1">
				<tr>
					<td width="50%"><a href="javascript:edit_section('3');">Intro Text</a></td>
					<td width="50%"><span style="color: #339933;">OK</span></td>
				</tr>
			</table>
			<br>
			<table width=100% class="main" cellpadding="2" cellspacing="1">
				<tr>
					<td width="50%"><a href="javascript:edit_section('4');">Salutation</a></td>
					<td width="50%"><span style="color: #339933;">OK</span></td>
				</tr>
			</table>
			<br>
			<table width=100% class="main" cellpadding="2" cellspacing="1">
				<tr>
					<th colspan="2">Offer Body</th>
				</tr>
				<tr>
					<td width="50%"><a href="javascript:EditCont('doc_step_3_edit.jsp?id=50');">Win Back : 60 Days Offer Body</a></td>
					<td width="50%"><span style="color: #CC3333;">Error:</span> Text-length exceeds provided area by 43 characters</td>
				</tr>
				<tr>
					<td width="50%"><a href="javascript:EditCont('doc_step_3_edit.jsp?id=51');">Win Back : 90 Day Offer Body</a></td>
					<td width="50%"><span style="color: #339933;">OK</span></td>
				</tr>
				<tr>
					<td width="50%"><a href="javascript:EditCont('doc_step_3_edit.jsp?id=52');">Win Back : 120 Day Offer Body</a></td>
					<td width="50%"><span style="color: #339933;">OK</span></td>
				</tr>
				<tr>
					<td width="50%"><a href="javascript:EditCont('doc_step_3_edit.jsp?id=53');">Win Back : Offer Body</a></td>
					<td width="50%"><span style="color: #339933;">OK</span></td>
				</tr>
			</table>
			<br>
			<table width=100% class="main" cellpadding="2" cellspacing="1">
				<tr>
					<td width="50%"><a href="javascript:edit_section('6');">Body of Postcard</a></td>
					<td width="50%"><span style="color: #339933;">OK</span></td>
				</tr>
			</table>
			<br>
			<table width=100% class="main" cellpadding="2" cellspacing="1">
				<tr>
					<td width="50%"><a href="javascript:edit_section('7');">Address Info</a></td>
					<td width="50%"><span style="color: #339933;">OK</span></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
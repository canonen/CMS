<%@ page

	language="java"
	import="com.britemoon.*, com.britemoon.sas.*,java.io.*,java.sql.*,java.util.*"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp" %>

<HTML>

<HEAD>
	<TITLE>System Notes</TITLE>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" type="text/css" href="../../css/style.css">
    <script language="JavaScript" src="/sadm/ui/js/scripts.js"></script>
    <script language="JavaScript" src="/sadm/ui/js/tab_script.js"></script>

</HEAD>

<BODY>
	<table cellspacing="0" cellpadding="0" border="0" style="table-layout:fixed; width:100%; height:100%;">
		<col>
		<tr>
			<td>
				<table cellspacing="0" cellpadding="0" border="0" style="width:100%; height:100%;">
					<tr>
						<td class="listHeading" valign="center" align="left">
							All System Notes
							<br><br>
							<iframe src="system_note_list.jsp" name="systemnotelist" style="width:100%; height:90%;" scrolling="yes" frameborder="0">
								[Your user agent does not support frames or is currently configured]
							</iframe>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</BODY>
</HTML>

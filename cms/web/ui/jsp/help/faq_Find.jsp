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
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

String findCriteria = "";
findCriteria = request.getParameter("findCriteria");

if (findCriteria == null || findCriteria.compareTo("0") == 0)
{
	findCriteria = "";
}

%>
<html>
<head>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="JavaScript" src="../../js/scripts.js"></script>
<script language="JavaScript" src="../../js/tab_script.js"></script>
<script language="JavaScript" src="help.js"></script>
<script language="javascript">

	function find()
	{
		if (helpFind.findCriteria.value == "")
		{
			alert( "You must enter a query before performing a search. Type a word or phrase in the Find box and click Go. " );
		}
		else
		{
			helpFind.submit();
		}

		return false;
	}

</script>
</head>
<body topmargin="0" leftmargin="0" marginheight="0" marginwidth="0">
<form name="helpFind" action="faq_search.jsp" method="get" target="helpContents" style="display:inline;" onsubmit="return find();">
	<table cellpadding="0" cellspacing="0" border="0" height="100%" width="100%">
		<tr>
			<td align="left" valign="middle" nowrap>
				&nbsp;&nbsp;&nbsp;
			</td>
			<td align="left" valign="middle" nowrap>
				<b>Search:&nbsp;</b>
			</td>
			<td align="left" valign="middle" width="100%" height="100%">
				<input maxlength="50" name="findCriteria" type="text" style="width:100%;" value="<%= findCriteria %>">
			</td>
			<td align="right" valign="middle" nowrap>
				&nbsp;
				<a class="subactionbutton" href="#" onclick="find();">Go</a>
			</td>
			<td align="left" valign="middle" nowrap>
				&nbsp;&nbsp;&nbsp;
			</td>
		</tr>
	</table>
</form>
</body>
</html>

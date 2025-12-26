<%@ page import="java.util.*"
		 import="com.britemoon.*"
 		 import="com.britemoon.cps.*"
		 import="com.britemoon.cps.ctm.*" 
		 import="org.apache.log4j.*"
%>

<%! static Logger logger = null; %>
<%  if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>

<jsp:useBean id="tbeans" class="java.util.Hashtable" scope="application" />

<%
String templateID = request.getParameter("templateID");

//get it from the hashtable
TemplateBean tbean = (TemplateBean)tbeans.get(new Integer(templateID));

%>

<html>
<head>
<title>Check Master Template</title>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>
<form>
<table class=ctmhead cellpadding=2 cellspacing=0>
<tr align=middle>
<td class=ctmheadfont><b>Master Template Details</b></td>
</tr>
<tr align=left><td align=left>
<table class=ctmbody cellpadding=4 cellspacing=0 width=100%>
<tr>
<td colspan=2 align=center>
</td>
</tr>
<tr>
<td class=ctmheadtd colspan=2><b>Basic Info</b></td>
</tr>
<tr>
<th>Name:</th>
<td><%= tbean.getTemplateName() %></td>
</tr>
<tr>
<th ><nobr>Customer ID:</nobr></th>
<td><%= tbean.getCustID() %></td>
</tr>
<tr>
<th ><nobr>Replication:</nobr></th>
<td><%=(tbean.isGlobal()?"Global":"Selected Child Customer")%></td>
</tr>
<tr>
<th ><nobr>Child Customer ID:</nobr></th>
<td><%=((tbean.getChildCustList()!=null)?tbean.getChildCustList():"")%></td>
</tr>
<tr>
<th ><nobr>Requires Approval:</nobr></th>
<td><%=(tbean.isApproval()?"Yes":"No")%></td>
</tr>

<tr valign=top>
<th>Structure:</th>
<td><%= tbean.prettyOutput() %></td>
</tr>
<tr>
<td class=ctmheadtd colspan=2><b>Uploaded Master Template Files</b></td>
</tr>

<tr>
<th>HTML:</th>
<td><textarea rows=10 cols=80 wrap=off><%= tbean.getTemplate("html") %></textarea></td>
</tr>
<tr>
<th>Text:</th>
<td><textarea rows=10 cols=80 wrap=off><%= tbean.getTemplate("txt") %></textarea></td>
</tr>

<tr>
<td class=ctmheadtd colspan=2><b>Uploaded Images</b></td>
</tr>
<tr>
<th>Small Image:</th>
<td><img src=/cctm/ui/images/templates/<%= (tbean.getImageURL(0)) %>></td>
</tr>
<tr>
<th>Large Image:</th>
<td><img src=/cctm/ui/images/templates/<%= (tbean.getImageURL(1)) %>></td>
</tr>


<tr height=5><td colspan=2></td></tr>
<tr>
<td colspan=2 align=center>
</td>
</tr>
</table>
</td></tr>
</table>
</form>
</body>
</html>


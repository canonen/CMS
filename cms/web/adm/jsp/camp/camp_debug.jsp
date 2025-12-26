<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.que.*, 
			java.io.*, java.sql.*,
			java.util.*, 
			org.w3c.dom.*,
			org.apache.log4j.*"
%>
<%! static Logger logger  = null;%>

<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
response.setHeader("Expires", "0");
response.setHeader("Pragma", "no-cache");
response.setHeader("Cache-Control", "no-store, no-cache");

String sCampId = BriteRequest.getParameter(request,"camp_id");
String sPureXml = BriteRequest.getParameter(request,"pure_xml");
String sForWhat = BriteRequest.getParameter(request,"for_what");
if(sForWhat == null) sForWhat = "rcp";

String sCampXml = "";

if(sCampId != null )
{
	if("rcp".equals(sForWhat)) sCampXml = CampSetupUtil.buildCampXml4Rcp(sCampId);
	else if("inb".equals(sForWhat)) sCampXml = CampSetupUtil.buildCampXml4Inb(sCampId);
	else if("mailer".equals(sForWhat))
	{
		sCampXml = CampSetupUtil.buildCampXml4Mailer(sCampId);
		sCampXml = "<some_wrapping_tag>" + sCampXml + "</some_wrapping_tag>";
	}
}

if(sPureXml!=null)
{
	response.setContentType("text/xml;charset=UTF-8");
	out.println(sCampXml);
	out.flush();
	out.close();
	return;
}

response.setContentType("text/html;charset=UTF-8");
%>


<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>
<BODY>
Campaign setup XML:
<FORM>
<TABLE border=0>
<TR>
	<TD>Camp Id: <INPUT type=text name="camp_id" value="<%=HtmlUtil.escape(sCampId)%>"></TD>
	<TD>
		<INPUT type=radio name="for_what" value="rcp"<%=(("rcp".equals(sForWhat))?" checked":"")%>> XML for RCP setup <BR>
		<INPUT type=radio name="for_what" value="inb"<%=(("inb".equals(sForWhat))?" checked":"")%>> XML for INB setup <BR>
		<INPUT type=radio name="for_what" value="mailer"<%=(("mailer".equals(sForWhat))?" checked":"")%>> XML for MAILER (setup)
	</TD>
	<TD>Pure xml: <INPUT type=checkbox name="pure_xml"></TD>
	<TD><INPUT type=submit value="GO"></TD>
</TR>
</TABLE>
</FORM>
<TEXTAREA style='height: 80%; width: 100%'><%=HtmlUtil.escape(BriteObject.toXmlNice(sCampXml))%></TEXTAREA>
<%
out.flush();
try { XmlUtil.getRootElement(sCampXml); }
catch(Exception ex)
{
%>
<PRE>
<% ex.printStackTrace(new PrintWriter(out)); %>
</PRE>
<%
}
out.flush();
%>

</BODY>
</HTML>


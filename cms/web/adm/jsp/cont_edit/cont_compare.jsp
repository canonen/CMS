<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*, 
			java.sql.*, 
			java.util.*, 
			org.w3c.dom.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp"%>

<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	
	String sSCampId = BriteRequest.getParameter(request,"s_camp_id");
	String sDCampId = BriteRequest.getParameter(request,"d_camp_id");
%>
<%

Campaign cSCamp = new Campaign(sSCampId);
Campaign cDCamp = new Campaign(sDCampId);

Content cSCont = new Content(cSCamp.s_cont_id);
Content cDCont = new Content(cDCamp.s_cont_id);
	
Vector vSParagraphs = getParagraphs(cSCont);
Vector vDParagraphs = getParagraphs(cDCont);
%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>
<BODY>
<FORM action="cont_replace.jsp" method="post">
<INPUT type=hidden name='d_camp_id' value='<%=cDCamp.s_camp_id%>'>
<INPUT type=hidden name='s_cont_id' value='<%=cSCont.s_cont_id%>'>
<TABLE width='100%' cellspacing=0 cellpadding=2 border=1>
	<TR>
		<TD width='50%'>
			<H4 align=center>Source (new) content</H4>
			<H5>
				Campaign: <%=cSCamp.s_camp_name%><BR>
				Camp Id: <%=cSCamp.s_camp_id%><BR>
				Content: <%=cSCont.s_cont_name%><BR>
				Cont Id: <%=cSCont.s_cont_id%>
			</H5>
		</TD>
		<TD align=center>
			&gt;&gt;
			<INPUT type=checkbox disabled>
			&gt;&gt;
		</TD>
		<TD width='50%'>
			<H4 align=center>Destination (old) content</H4>
			<H5>
				Campaign: <%=cDCamp.s_camp_name%><BR>
				Camp Id: <%=cDCamp.s_camp_id%><BR>
				Content: <%=cDCont.s_cont_name%><BR>
				Cont Id: <%=cDCont.s_cont_id%>
			</H5>			
		</TD>
<%
Iterator iS = vSParagraphs.iterator();
Iterator iD = vDParagraphs.iterator();

ContBody cbS = null;
ContBody cbD = null;

while((iS.hasNext())||(iD.hasNext()))
{
	if(iS.hasNext())
	{
		cSCont = (Content) iS.next();
		cbS = new ContBody(cSCont.s_cont_id);
	}
	else
	{
		cSCont = null;
		cbS = null;
	}

	if(iD.hasNext())
	{
		cDCont = (Content) iD.next();
		cbD = new ContBody(cDCont.s_cont_id);
	}
	else
	{
		cDCont = null;
		cbD = null;
	}
%> 
	<TR>
		<TD width='50%' nowrap>
<% if(cbS != null ) { %>
<%=HtmlUtil.escape(cSCont.s_cont_name)%> ( <%=cSCont.s_cont_id%> )<BR>
<TEXTAREA rows=5 cols=55 readonly><%=HtmlUtil.escape(cbS.s_text_part)%></TEXTAREA>
<TEXTAREA rows=5 cols=55 readonly><%=HtmlUtil.escape(cbS.s_html_part)%></TEXTAREA>
<% } %>
		</TD>
		<TD nowrap>
<%
if
	(
		(cbS!=null)&&(cbD!=null)
		&&
		!(
			(
				(
					(cbS.s_text_part==null)&&
					(cbD.s_text_part==null)
				)
				||
				(
					(cbS.s_text_part!=null)&&
					(cbS.s_text_part.equals(cbD.s_text_part))
				)
				||
				(
					(cbD.s_text_part!=null)&&
					(cbD.s_text_part.equals(cbS.s_text_part))
				)
			)
			&&
			(
				(
					(cbS.s_html_part==null)&&
					(cbD.s_html_part==null)
				)
				||
				(
					(cbS.s_html_part!=null)&&
					(cbS.s_html_part.equals(cbD.s_html_part))
				)
				||
				(
					(cbD.s_html_part!=null)&&
					(cbD.s_html_part.equals(cbS.s_html_part))
				)
			)
		)
	)
{
%>
&gt;&gt;
<INPUT type=checkbox checked name='sd_cont_ids' value='<%=cbS.s_cont_id%>;<%=cbD.s_cont_id%>'>
&gt;&gt;
<%
}
%>
		</TD>
		<TD width='50%' nowrap>
<% if(cbD != null ) { %>
<%=HtmlUtil.escape(cDCont.s_cont_name)%> ( <%=cDCont.s_cont_id%> )<BR>
<TEXTAREA rows=5 cols=55 readonly><%=HtmlUtil.escape(cbD.s_text_part)%></TEXTAREA>
<TEXTAREA rows=5 cols=55 readonly><%=HtmlUtil.escape(cbD.s_html_part)%></TEXTAREA>
<% } %>
		</TD>
	</TR>
<%
}
%>
</TABLE>
<CENTER>
<% if(vSParagraphs.size() == vDParagraphs.size()) { %>
<BR><BR>
<INPUT type=submit value="Update selected paragraphs with new ones">
<% } else { %>
<H1><FONT color="#FF0000">Content structures are incompatible.</FONT></H1>
<% } %>
</CENTER>
</FORM>
</BODY>
</HTML>

<%!
private static Vector getParagraphs(String sContId) throws Exception
{
	Content cont = new Content(sContId);
	return getParagraphs(cont);
}

private static Vector getParagraphs(Content cont) throws Exception
{
	Vector v = new Vector();
	
	if("30".equals(cont.s_type_id)) v.add(cont);

	ContParts cont_parts = new ContParts();
	cont_parts.s_parent_cont_id = cont.s_cont_id;
	if(cont_parts.retrieve() < 1) return v;

	ContPart cont_part = null;
	for (Enumeration en = cont_parts.elements() ; en.hasMoreElements() ;)
	{
		cont_part = (ContPart) en.nextElement();
		v.addAll(getParagraphs(cont_part.s_child_cont_id));
	}
	
	return v;
}
%>

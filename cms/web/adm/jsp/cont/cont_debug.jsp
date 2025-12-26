<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
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
	String sContId = BriteRequest.getParameter(request,"cont_id");
%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>
<BODY>

<FORM>
	Cont Id:
	<INPUT type=text name="cont_id" value="<%=HtmlUtil.escape(sContId)%>">
	<INPUT type=submit value="GO">
</FORM>
<% if(sContId != null) drawCont(sContId, out); %>
</BODY>
</HTML>

<%!
private void drawCont(String sContId, JspWriter out) throws Exception
{
	Content cont = new Content(sContId);

	out.println("<TABLE border=1 width=100% cellspacing=0 cellpadding=3 bordercolor=#00AA00>");
	out.println("	<TR><TD>");

	out.println("Content:&nbsp;&nbsp;&nbsp;");
	out.println("cont_id = " + cont.s_cont_id);
	out.println("&nbsp;|&nbsp;");
	out.println("cont_name = " + cont.s_cont_name);
	out.println("&nbsp;|&nbsp;");
	out.println("cust_id = " + cont.s_cust_id);
	out.println("&nbsp;|&nbsp;");
	out.println("type_id = " + cont.s_type_id);
	out.println("&nbsp;|&nbsp;");
	out.println("origin_cont_id = " + cont.s_origin_cont_id);

	out.println("	</TD></TR>");
	out.println("	<TR><TD>");

	drawContBody(sContId, out);
	drawContParts(sContId, out);

	out.println("	</TD></TR>");
	out.println("</TABLE>");

}

private void drawContBody(String sContId, JspWriter out) throws Exception
{
	ContBody cont_body = new ContBody();
	cont_body.s_cont_id = sContId;
	if(cont_body.retrieve() < 1) return;
	drawContBody(cont_body, out);
}

private void drawContBody(ContBody cont_body, JspWriter out) throws Exception
{
	out.println("<TABLE border=1 width=100% cellspacing=0 cellpadding=3>");
	out.println("	<TR>");
	out.println("<TH>Text</TH>");
	out.println("<TH>HTML</TH>");
	out.println("<TH>AOL</TH>");
	out.println("	</TR>");
	out.println("	<TR>");
	out.println("<TD><TEXTAREA rows=5 style='width: 100%'>" + HtmlUtil.escape(cont_body.s_text_part) + "</TEXTAREA></TD>");
	out.println("<TD><TEXTAREA rows=5 style='width: 100%'>" + HtmlUtil.escape(cont_body.s_html_part) + "</TEXTAREA></TD>");
	out.println("<TD><TEXTAREA rows=5  style='width: 100%'>" + HtmlUtil.escape(cont_body.s_aol_part) + "</TEXTAREA></TD>");
	out.println("	</TR>");
	out.println("</TABLE>");
}

private void drawContParts(String sContId, JspWriter out) throws Exception
{
	ContParts cont_parts = new ContParts();
	cont_parts.s_parent_cont_id = sContId;
	if(cont_parts.retrieve() < 1) return;
	drawContParts(cont_parts, out);
}

private void drawContParts(ContParts cont_parts, JspWriter out) throws Exception
{
	out.println("<TABLE border=0 width=100% cellspacing=0 cellpadding=3 bordercolor=#FF0000>");
	out.println("	<TR><TD width=20>&nbsp;</TD><TD>");

	for (Enumeration en = cont_parts.elements() ; en.hasMoreElements() ;)
	{
		drawContPart((ContPart) en.nextElement(), out);
	}

	out.println("	</TD></TR>");
	out.println("</TABLE>");
}

private void drawContPart(ContPart cont_part, JspWriter out) throws Exception
{
	out.println("<TABLE border=1 width=100% cellspacing=0 cellpadding=3 bordercolor=#0000FF>");
	out.println("	<TR><TD colspan=2>");

	out.println("Content Part:&nbsp;&nbsp;&nbsp;");
	out.println("parent_cont_id = " + cont_part.s_parent_cont_id );
	out.println("&nbsp;|&nbsp;");
	out.println("child_cont_id = " + cont_part.s_child_cont_id );
	out.println("&nbsp;|&nbsp;");
	out.println("seq = " + cont_part.s_seq );
	out.println("&nbsp;|&nbsp;");
	out.println("s_filter_id = " + cont_part.s_filter_id );
	out.println("&nbsp;|&nbsp;");
	out.println("s_default_flag = " + cont_part.s_default_flag );

	out.println("	</TD></TR>");
	out.println("	<TR><TD width=20>&nbsp;</TD><TD>");

	drawCont(cont_part.s_child_cont_id, out);

	out.println("	</TD></TR>");
	out.println("</TABLE>");
}

%>
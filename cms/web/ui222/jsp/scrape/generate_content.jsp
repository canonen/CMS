<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			java.util.*,java.util.regex.*,
			java.sql.*,java.net.*,
			java.io.*,java.text.DateFormat,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>
<%
String sFormatId = request.getParameter("format_id");
ScrapeFormat format = new ScrapeFormat();
format.s_format_id = sFormatId;
if(format.retrieve() < 1) return;

ScrapeUrls urls = new ScrapeUrls();
urls.s_scrape_id = format.s_scrape_id;
if (urls.retrieve() < 1) return;

Content cont = new Content();

if (format.s_cont_id != null) {
	cont.s_cont_id = format.s_cont_id;
	cont.retrieve();
} else {
	cont.s_cont_name = format.s_format_name;
	cont.s_status_id = String.valueOf(ContStatus.READY);
	cont.s_cust_id = cust.s_cust_id;
	cont.s_charset_id = format.s_charset_id;
	cont.s_type_id = String.valueOf(ContType.LOGIC_BLOCK);
}	

ContEditInfo cei = new ContEditInfo(cont.s_cont_id);
if (cei.s_creator_id == null) cei.s_creator_id = user.s_user_id;
cei.s_modifier_id = user.s_user_id;
cei.s_modify_date = null;
cont.m_ContEditInfo = cei;	

ContParts cps = new ContParts();

for (Enumeration e = urls.elements() ;e.hasMoreElements(); ) {
	ScrapeUrl url = (ScrapeUrl) e.nextElement();

	ScrapeUrlCont suc = new ScrapeUrlCont();
	suc.s_url_id = url.s_url_id;
	suc.s_format_id = format.s_format_id;
	suc.retrieve();
	
	Content cb = new Content(); //content block
	cb.s_cont_id = suc.s_cont_id;

	if (suc.s_cont_id != null) {
		cb.s_cont_id = suc.s_cont_id;
		cb.retrieve();
	} else {
		cb.s_cust_id = cust.s_cust_id;
		cb.s_type_id = String.valueOf(ContType.PARAGRAPH);
	}

	cb.s_cont_name = format.s_format_name + " : " + ((url.s_title_text!=null)?url.s_title_text:url.s_seq);
	cb.s_status_id = String.valueOf(ContStatus.READY);
	cb.s_charset_id = format.s_charset_id;

	ContEditInfo cbei = new ContEditInfo(cb.s_cont_id);
	if (cbei.s_creator_id == null) cbei.s_creator_id = user.s_user_id;
	cbei.s_modifier_id = user.s_user_id;
	cbei.s_modify_date = null;
	cb.m_ContEditInfo = cbei;	

	ContBody cbb = new ContBody(cb.s_cont_id);
	cbb.s_html_part = url.replaceContentAttrs(format.s_cont_html);
	cbb.s_text_part = url.replaceContentAttrs(format.s_cont_text);
//System.out.println(cb.s_cont_name);
//System.out.println("format");
//System.out.println(format.s_cont_html);
//System.out.println(format.s_cont_text);
//System.out.println("replaceAttrs");
//System.out.println(cbb.s_html_part);
//System.out.println(cbb.s_text_part);

	cbb.s_html_part = (cbb.s_html_part!=null)?cbb.s_html_part.replaceAll("\\!\\*scr_title_html\\;\\*\\!", ((url.s_title_html!=null)?url.s_title_html:"")):null;
	cbb.s_text_part = (cbb.s_text_part!=null)?cbb.s_text_part.replaceAll("\\!\\*scr_title_text\\;\\*\\!", ((url.s_title_text!=null)?url.s_title_text:"")):null;	

//System.out.println("replaceAll");
//System.out.println(cbb.s_html_part);
//System.out.println(cbb.s_text_part);

	cb.m_ContBody = cbb;	

	ContSendParam cbsp = new ContSendParam();
	cbsp.s_send_html_flag = (cbb.s_html_part == null)?"0":"1";
	cbsp.s_send_text_flag = (cbb.s_text_part == null)?"0":"1";
	cbsp.s_send_aol_flag = (cbb.s_aol_part == null)?"0":"1";
	cb.m_ContSendParam = cbsp;

	cb.save();

	ContPart cp = new ContPart();
	cp.s_seq = url.s_seq;
	cp.s_child_cont_id = cb.s_cont_id;
	cp.s_filter_id = url.s_filter_id;

	cps.add(cp);

	suc.s_cont_id = cb.s_cont_id;
	suc.save();
}

cont.m_ContParts = cps;
cont.save();

format.s_cont_id = cont.s_cont_id;
format.save();

// === === ===


%>

<HTML>
<HEAD>
	<BASE target="_self">
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">	
</HEAD>
<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Scape Content:</b> Saved</td>
	</tr>
</table>
<br><br>
</BODY>
</HTML>

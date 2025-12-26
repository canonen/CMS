<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.ctl.*,
			java.sql.*,java.io.*,
			javax.servlet.*,
			javax.servlet.http.*,
			org.xml.sax.*,
			javax.xml.transform.*,
			javax.xml.transform.stream.*,
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
	
	AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

	if(!can.bRead)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}
	
	
%>


<html>
<head>
<title>Create Content</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>
<SCRIPT LANGUAGE="JAVASCRIPT">
<%@ include file="../../js/scripts.js" %>


</SCRIPT>

<body<%= (!can.bWrite)?" onload='disable_forms()'":" " %>>
<form name="ContentModify" method="post" ENCTYPE="multipart/form-data" action="cont_import_save.jsp">

Content XML File: <INPUT TYPE="file" NAME="cont_file" SIZE="30">
<BR><BR>
<a class="actionbutton" href="javascript:ContentModify.submit();">Load New Content ></a>

<h3>File Format</h3>
<pre>
&lt;content_update>
    &lt;paragraphs>

        &lt;paragraph>
            &lt;!-- ID of Paragraph in external system in assigned range, 
                 tracked and converted to internal CPS Paragraph ID -->
            &lt;paragraph_id>22000012&lt;/paragraph_id>

            &lt;!-- Name of paragraph, not necessarily unique -->
            &lt;paragraph_name>&lt;![CDATA[Sample paragraph header name]]>&lt;/paragraph_name>

            &lt;!-- Charset to be used for this paragraph, ID list stored in Revotas SW as system table -->
            &lt;charset_id>2&lt;/charset_id>

            &lt;!-- Text version of paragraph, assembled into final content 
                 for text and multipart recipients -->
            &lt;text_part>&lt;![CDATA[
                 Text for this content paragraph goes here
            ]]>&lt;/text_part>

            &lt;!-- HTML version of paragraph, assembled into final content 
                 for HTML and multipart recipients -->
            &lt;html_part>&lt;![CDATA[
                 HTML for this content paragraph goes here
            ]]>&lt;/html_part>

            &lt;!-- AOL version of paragraph, assembled into final content 
                 for AOL recipients only -->
            &lt;aol_part>&lt;![CDATA[
                 AOL for this content paragraph goes here
            ]]>&lt;/aol_part>
        &lt;/paragraph>

        &lt;paragraph>
        &lt;!-- Multiple Paragraphs expected in same Campaign Content, 
             possibly up to 2000 different paragraphs, e.g., for 
             inserting specific coupons. -->
        &lt;/paragraph>

    &lt;/paragraphs>
&lt;/content_update>
</pre>
</form>
</body>
</html>
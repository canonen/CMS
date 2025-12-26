<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.ctl.*,
			org.w3c.dom.*,org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.io.*" %>
<%@ include file="../../header.jsp"%>
<%@ include file="../../wvalidator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

String contentType = request.getContentType();
String funcNum = request.getParameter("CKEditorFuncNum");
String message = "";
String filepath = application.getRealPath("../web/ui/images/"+cust.s_cust_id+"/content_load/wizard/");
String saveFile = "";
String[] okFileExtensions = new String[] {"jpg", "png", "gif"};

if ((contentType != null) && (contentType.indexOf("multipart/form-data") >= 0)) 
{
	try 
	{
		DataInputStream in = new DataInputStream(request.getInputStream());
		
		int formDataLength = request.getContentLength();
		byte dataBytes[] = new byte[formDataLength];
		int byteRead = 0;
		int totalBytesRead = 0;
		
		while (totalBytesRead < formDataLength) {
				byteRead = in.read(dataBytes, totalBytesRead, formDataLength);
				totalBytesRead += byteRead;
		}
		String file = new String(dataBytes);
		
		saveFile = file.substring(file.indexOf("filename=\"") + 10);
		saveFile = saveFile.substring(0, saveFile.indexOf("\n"));
		saveFile = saveFile.substring(saveFile.lastIndexOf("\\") + 1,saveFile.indexOf("\""));
		
		int i = 0;
		for (String extension : okFileExtensions)
		{
			if (saveFile.toLowerCase().endsWith(extension))
			{
				i++;
				break;	
			}
		}
		
		if(i > 0)
		{
			int lastIndex = contentType.lastIndexOf("=");
			
			String boundary = contentType.substring(lastIndex + 1, contentType.length());
			int pos;

			pos = file.indexOf("filename=\"");
			pos = file.indexOf("\n", pos) + 1;
			pos = file.indexOf("\n", pos) + 1;
			pos = file.indexOf("\n", pos) + 1;
			
			int boundaryLocation = file.indexOf(boundary, pos) - 4;
			int startPos = ((file.substring(0, pos)).getBytes()).length;
			int endPos = ((file.substring(0, boundaryLocation)).getBytes()).length;
			
			FileOutputStream fileOut = new FileOutputStream(filepath+"/"+saveFile);
			fileOut.write(dataBytes, startPos, (endPos - startPos));
			fileOut.flush();
			fileOut.close();
		}
		else
			message = "Geçersiz Dosya";
	}
	catch(Exception e) 
	{
		message = "Dosya yüklenemedi.";
	}
}
%>
<html>
	<head>
		<% 
			String url = "http://cms.revotas.com/cms/ui/images/"+cust.s_cust_id+"/content_load/wizard/"+saveFile;
			out.println("<script type='text/javascript'>window.parent.CKEDITOR.tools.callFunction("+funcNum+", '"+url+"', '"+message+"');</script>"); 
		%>
	</head>
	<body></body>
</html>
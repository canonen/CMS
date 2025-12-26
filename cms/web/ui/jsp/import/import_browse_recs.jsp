<%@ page
	language="java"
	import="com.britemoon.cps.upd.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			java.io.*,java.util.*,
			java.sql.*,java.net.*,
			org.w3c.dom.*,org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.IMPORT);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>

<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>
<BODY>

<%
String sImportId = request.getParameter("import_id");
String sType = request.getParameter("type");
int nType = Integer.parseInt(sType);

String sImportURL = null;
try
{
	Import imp = new Import(sImportId);
	if ((imp.s_import_file == null) || (imp.s_import_file.trim().equals(""))) 
	{
		String sErrMsg = 
			"import_detail.jsp ERROR: " +
			"import_file is not specified. import_id = " + imp.s_import_id;
		throw new Exception (sErrMsg);
	}

	// === === ===

	String sFileType = null;
	
	switch (nType)
	{
		case 0 : //Commit
				out.print("Sample 25 records processed from Import file.<P>");
				sFileType = "preview";
				break;
		case 1 : //Bad Emails
				out.print("Records that produced an Error in processing.<P>");
				sFileType = "errors";
				break;
		case 2 : //File Dups
				out.print("Duplicates within the Import file.<P>");
				sFileType = "int_dups";
				break;
		case 3 : //Warnings
				out.print("Records that produced a Warning in processing.<P>");
				sFileType = "warn";
				break;
		case 4 : //DB Dups
				out.print("Recipients that already exist in the database.<P>");
				sFileType = "ext_dups";
				break;
		case 5 : //Bad Fingerprints 
				out.print("Recipients that already exist in the database.<P>");
				sFileType = "bad_fingerprints";
				break;
		default : throw new Exception ("Unknown type.");
	}

	// === === ===

	Vector services = Services.getByCust(ServiceType.RUPD_IMPORT_RESULT_FILE_VIEW, cust.s_cust_id);
	Service service = (Service) services.get(0);

	sImportURL = service.getURL().toString();
	sImportURL +=
		"?cust_id=" + cust.s_cust_id +
		"&import_id=" + imp.s_import_id +
		"&file_type=" + sFileType +
		"&import_file=" + imp.s_import_file.trim();
%>
<A HREF="<%=sImportURL%>" target="_self">Text File</A></P>
<%
	HttpURLConnection huc = null;
	try
	{
		URL url = new URL(sImportURL);
		huc = (HttpURLConnection) url.openConnection();
		huc.setDoOutput(false);
		huc.setDoInput(true);

		BufferedReader inRCP = new BufferedReader(new InputStreamReader(huc.getInputStream(),"UTF-8"));
		if(nType!=0) { %><PRE><% }
		for(String sLine = inRCP.readLine(); sLine != null; sLine = inRCP.readLine()) out.println(sLine);
		if(nType!=0) { %><PRE><% }
		inRCP.close();		

		if (huc.getResponseCode()!= HttpServletResponse.SC_OK)
		{
			throw new IOException ("import_detail.jsp ERROR: " + huc.getResponseMessage());
		}
	}
	catch(Exception ex) { throw ex; }
	finally { if(huc!=null) huc.disconnect(); }
}
catch(Exception ex)
{
	logger.error("import_browse_recs.jsp ERROR: cannot get data from url: ",ex);
%>
<H5 align>Cannot access requested file.</H5>
<BR><BR>
<%
} 
%>
</BODY></HTML>






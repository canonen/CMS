<%@ page
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.apache.log4j.*"
	import="java.text.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp" %>

<HTML>

<HEAD>
	<TITLE>Billing Export List</TITLE>
	<%@ include file="../header.html" %>
    <link rel="stylesheet" href="/sadm/adm/css/style.css" type="text/css">
    <script language="JavaScript" src="/sadm/ui/js/scripts.js"></script>
    <script language="JavaScript" src="/sadm/ui/js/tab_script.js"></script>
</HEAD>
<SCRIPT>

function DeleteFile(name)
{
	if (confirm("Are you sure you want to delete " + name)) {
		FT.action.value="1";
		FT.filename.value=name;
		FT.submit();
	}
}

function ExportWin(freshurl)
{
	var window_features = 'scrollbars=yes,resizable=yes,toolbar=no,location=no,status=yes,height=600,width=500';
	SmallWin = window.open(freshurl,'ExportWin',window_features);
}

</SCRIPT>

<BODY>
<FORM  METHOD="POST" NAME="FT" ACTION="bill_exp_list.jsp" TARGET="_self">
<input type=hidden name="action" value="">
<input type=hidden name="filename" value="">
<table>
  <br>
    <center><b>Revotas Billing Exports</b></center>
  <br>
  <table class="main" cellpadding="0" cellspacing="0" border="0" width="100%">
<%
    String ACTION = request.getParameter("action");
	String FILENAME = request.getParameter("filename");

	String sExportDir = Registry.getKey("sas_export_dir");
	if (sExportDir == null)
	{
		throw new Exception("'sas_export_dir' key is not found in registry");
		// sExportDir = "D:\\britemoon\\adm\\web\\export\\";
	}
	String sExportUrl = Registry.getKey("sas_export_url");
	if (sExportUrl == null)
	{
		throw new Exception("'sas_export_url' key is not found in registry");
		// sExportUrl = "http://192.168.0.226:80/sadm/export/";
	}

	String sClassAppend = "";

    // see if we need to delete a report
    if ( (ACTION != null) && (ACTION.equals("1")) && (FILENAME != null) && (FILENAME.length() > 0) ) {
		String name = null;
		name = sExportDir + FILENAME;
		try {
			File f = new File(name);
			if (f.exists()) {
				boolean rc = f.delete();
			}
		}
		catch (Exception e) {};
	}
%>
    <tr>
      <td align="left" valign="middle" colspan="6">
			Right-click on the Export names below and select [Save Target As...] to <FONT COLOR="RED">download the export</FONT> onto your local computer.
			<br>
			Click on the Preview buttons to preview the export.
      </td>
    </tr>
    <tr>
      <td align="left" valign="top" style="padding:0px;">
        <table class="listTable" cellpadding="0" cellspacing="0" border="0" width="100%">

	      <tr>
            <th align="right" valign="middle" width=40% nowrap>&nbsp;&nbsp;Export name&nbsp;&nbsp;</th>
            <th align="right" valign="middle" width=30% nowrap>&nbsp;&nbsp;Date&nbsp;&nbsp;</th>
            <th align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;Size (Bytes)&nbsp;&nbsp;</th>
            <th align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;&nbsp;&nbsp;</th>
            <th align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;&nbsp;&nbsp;</th>
          </tr>
<%
        File dir = new File(sExportDir);
        File[] files = dir.listFiles();
		SimpleDateFormat formatter = new SimpleDateFormat("MMM dd yyyy hh:mm aaa");
        String s_file_name = "";
        String s_file_url = "";
		java.util.Date d = null;
        String s_file_date = "";
        String s_file_size = "";
        for (int n=0; n < files.length; n++) {
			if (files[n].isFile()) {
                s_file_name = files[n].getName();
                s_file_url = sExportUrl + s_file_name;
				d = new java.util.Date( files[n].lastModified());
                s_file_date = formatter.format(d);
                s_file_size = "" + files[n].length();
%>
	      <tr>
		    <td class="listItem_Data" align="left"  valign="middle" width=40%>&nbsp;&nbsp;<a href="<%=s_file_url%>"><%=s_file_name%></a>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="left"  valign="middle" width=30% nowrap>&nbsp;&nbsp;<%=s_file_date%>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;<%=s_file_size%>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;<a class="resourcebutton" href="javascript:ExportWin('<%=s_file_url%>');">Preview</a>&nbsp;&nbsp;</td>
		    <td class="listItem_Data" align="right" valign="middle" width=10% nowrap>&nbsp;&nbsp;<a class="resourcebutton" href="javascript:DeleteFile('<%=s_file_name%>');">Delete</a>&nbsp;&nbsp;</td>
	      </tr>
<%

			}
		}
%>
</FROM>
</BODY>
</HTML>

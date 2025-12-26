<%@ page
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="java.security.MessageDigest"
	import="java.security.NoSuchAlgorithmException"
	import="org.apache.log4j.*"
	import="java.text.*"
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
%>

<HTML>

<HEAD>
	<TITLE>Billing Export List</TITLE>
	<%@ include file="../header.html" %>
    <script language="JavaScript" src="/sadm/ui/js/scripts.js"></script>
    <script language="JavaScript" src="/sadm/ui/js/tab_script.js"></script>
            <style>
    	html, body {
    		background-color:#4f4f4f;
    		color:#FFFFFF;
    		font-family:Tahoma;
    		font-size:11px;
    	}
    	#containerTable {
    		border:2px solid #3A3A3A;
    		border-collapse:collapse;
    	}
    	#containerTable td {
    		color:#FFFFFF;
    		font-family:Tahoma;
    		font-size:11px;
    	}
    	select {
    		padding:4px;
    		font-size:11px;
    		font-family:Tahoma;
    		color:#4F4F4F;
    		border:1px solid #000000;
    	}
    	h1 {
    		font-size:11px;
    		color:#FFCC00;
    		margin-bottom:5px;
    		margin-top:5px;
    		font-family:Tahoma;
    	}
    	.buttons {
    		background-color:#FFBA00;
    		color:#000000;
    		border:1px solid #FF9900;
    		font-size:11px;
    		font-family:Tahoma;
    		padding:1px;
    		text-decoration:none;
    	}
    	th {
    		text-decoration:underline;
    		font-size:11px;
    		font-family:Arial;
    		color:#FFFFFF;
    		background-color: #3A3A3A;
    	}
    	.innerContainerTable {
    		
    	}
    	.innerContainerTable td {
    		
    	}
    	a {
    		color:#FFFFFF;
    		text-decoration:none;
    	}
    </style>
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

<% 
if(user.s_user_name.equals("Tech") && user.s_last_name.equals("Support"))
{
%>
	<a href='http://cms.revotas.com/cms/ui/jsp/bill/bill_form.jsp' style="color:white;text-decoration:none"><< Go back</a>
<%		
} else {
%>
	<a href='http://login.revotas.com/cms/ui/jsp/bill/bill_form.jsp' style="color:white;text-decoration:none"><< Go back</a>
<%
}
%>

  <br>
    <h1>Revotas Billing Exports</h1>
  <br>
  <table id="containerTable" cellpadding="10" cellspacing="0" border="0" width="100%">
<%
    String ACTION = request.getParameter("action");
	String FILENAME = request.getParameter("filename");

	String sExportDir = Registry.getKey("import_data_dir");
	if (sExportDir == null)
	{
		throw new Exception("'sas_export_dir' key is not found in registry");
		// sExportDir = "D:\\britemoon\\adm\\web\\export\\";
	}
	String sExportUrl = Registry.getKey("import_url_dir");
	if (sExportUrl == null)
	{
		throw new Exception("'sas_export_url' key is not found in registry");
		// sExportUrl = "http://192.168.0.226:80/sadm/export/";
	}
	
	
			//Hash Customer ID
		
		String custIdHash = cust.s_cust_id;
		byte[] defaultBytes = custIdHash.getBytes();
		String hashId = "";
		
		try{
			MessageDigest algorithm = MessageDigest.getInstance("MD5");
			algorithm.reset();
			algorithm.update(defaultBytes);
			byte messageDigest[] = algorithm.digest();
		            
			StringBuffer hexString = new StringBuffer();
			for (int i=0;i<messageDigest.length;i++) {
				hexString.append(Integer.toHexString(0xFF & messageDigest[i]));
			}
			
			hashId = hexString.toString();
			
		}catch(NoSuchAlgorithmException nsae){
		            
		}
	
	
	
	
	
	
	
	

	String sClassAppend = "";

    // see if we need to delete a report
    if ( (ACTION != null) && (ACTION.equals("1")) && (FILENAME != null) && (FILENAME.length() > 0) ) {
		String name = null;
		name = sExportDir + hashId + "/" + FILENAME;
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
      <td align="left" valign="top">
        <table class="listTable" cellpadding="10" cellspacing="0" border="0" width="100%">

	      <tr>
            <th align="left" valign="middle" width=40% nowrap>Export name</th>
            <th align="left" valign="middle" width=30% nowrap>Date</th>
            <th align="left" valign="middle" width=10% nowrap>Size (Bytes)</th>
            <th align="left" valign="middle" width=10% nowrap></th>
            <th align="left" valign="middle" width=10% nowrap></th>
          </tr>
<%
        File dir = new File(sExportDir + hashId + "/");
        
        
        File[] files = dir.listFiles();
        
                if(files == null) {
							
					out.print("<tr><td colspan='5'>There is no export.</td></tr>");
					
	} else {
        
		SimpleDateFormat formatter = new SimpleDateFormat("MMM dd yyyy hh:mm aaa");
        String s_file_name = "";
        String s_file_url = "";
		java.util.Date d = null;
        String s_file_date = "";
        String s_file_size = "";
        
       			
		
        for (int n=0; n < files.length; n++) {
			if (files[n].isFile()) {
                s_file_name = files[n].getName();
                s_file_url = sExportUrl + hashId + "/" + s_file_name;
				d = new java.util.Date( files[n].lastModified());
                s_file_date = formatter.format(d);
                s_file_size = "" + files[n].length();
%>
<%
			String bgcolor = "";
			if(n%2==0) {
				bgcolor = "#575757";
			} else {
				bgcolor = "#4F4F4F";	
			}
%>
	       <tr style='background-color:<%=bgcolor%>'>
		    <td class="listItem_Data" align="left"  valign="middle" width=40%><a href="<%=s_file_url%>"><%=s_file_name%></a></td>
		    <td class="listItem_Data" align="left"  valign="middle" width=30% nowrap><%=s_file_date%></td>
		    <td class="listItem_Data" align="left" valign="middle" width=10% nowrap><%=s_file_size%></td>
		    <td class="listItem_Data" align="left" valign="middle" width=10% nowrap><a class="buttons" href="javascript:ExportWin('<%=s_file_url%>');">Preview</a></td>
		    <td class="listItem_Data" align="left" valign="middle" width=10% nowrap><a class="buttons" href="javascript:DeleteFile('<%=s_file_name%>');">Delete</a></td>
	      </tr>
<%

			}
		}
		} 
		
%>
</FROM>
</BODY>
</HTML>	
		
				
		
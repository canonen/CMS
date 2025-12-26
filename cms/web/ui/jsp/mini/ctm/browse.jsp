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
        
String[] okFileExtensions = new String[] {"jpg", "png", "gif"};

String file = application.getRealPath("../web/ui/images/"+cust.s_cust_id+"/content_load/wizard/"); 

File f = new File(file);

if (!f.exists())
{
	boolean result = f.mkdirs();
	if(!result){    
		out.println("Üzgünüz bir hata oluştu. Lütfen bu hatayı #BRWS001 kodu ile bildiriniz.");
		return;
	}
}

String [] fileNames = f.list();
File [] fileObjects= f.listFiles();
        
%>
<HTML>
    <HEAD>
        <TITLE>Resim Galerisi</TITLE>
		<style>	
			ul {
				list-style-type:none;
				margin:0;
				padding:0;
			}
			li {
				display:inline;
				margin:0;
				padding:0;
			}
			.thumb-text {
				display: block;
				margin-bottom:3px;
				padding: 6px;
				padding-bottom:8px;
				font-size:12px;
			}
			.current-item {
				display:block;
			}
			.addThumb {
				display:block;
				padding:5px 10px;
				background-color:#357AE8;
				border:1px solid #2F5BB7;
				border-radius:2px;
				font-size:11px;
				color:#FFFFFF;
				margin-bottom:10px;
				width:100px;
				text-align:center;
			}
		</style>
		<link rel="stylesheet" href="../default.css" TYPE="text/css">
    </HEAD>

    <BODY>
        <div style="padding:10px;">
		<div style="margin-bottom:5px;font-weight:bold;">Resim Galerisi</div>
		<div style="margin-bottom:10px">Lütfen içeriğinize eklemek istediğiniz resmi seçiniz.</div>
		
		<% if(fileObjects.length > 0) { %>
		
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
			<tr>
				<td width="300" valign="top">
					<div style="border:1px solid #DDDDDD;border-radius:3px;width:300px;">
					<%
						String firstThumb = "";
						String bgcolor = "#f4f4f4";
						
						for (int i = 0; i < fileObjects.length; i++) {
							if(!fileObjects[i].isDirectory()){
								if(i%2==0)
									bgcolor = "#FFFFFF";
								else 
									bgcolor = "#F4F4F4";
							
								for (String extension : okFileExtensions)
								{
								  if (fileNames[i].toLowerCase().endsWith(extension))
								  {
									if(i == 0)
										firstThumb = fileNames[i];
								  %>
									<a class="thumb-text" style="background-color:<%=bgcolor%>" href="javascript:void(0);" onclick="switchthumb('<%=fileNames[i]%>')"><%=fileNames[i]%></a>
								  <%
								  }
								}
							}
						}
					%>
					</div>
				</td>
				<td style="padding-left:25px;vertical-align:top">
					<div id="currentThumb">
						<div style="margin-bottom:10px;"><a class="addThumb" href="javascript:void(0)" onclick="setImageUrl('http://cms.revotas.com/cms/ui/images/<%=cust.s_cust_id+"/content_load/wizard/"+firstThumb%>')">Bu resmi içeriğe ekle</a></div>
						<a class="current-item" href="javascript:void(0);"><img src="<%="/cms/ui/images/"+cust.s_cust_id+"/content_load/wizard/"+firstThumb%>"></div>
				</td>
			</tr>
		</table>
		
		<% } else out.println("Resim galerisinde hiç resim bulunmuyor. Karşıya yükle butonu ile yeni resim ekleyebilirsiniz."); %>
		
		</div>
		<script type="text/javascript">
			function getUrlParam(paramName)
			{
			  var reParam = new RegExp('(?:[\?&]|&amp;)' + paramName + '=([^&]+)', 'i') ;
			  var match = window.location.search.match(reParam) ;
			 
			  return (match && match.length > 1) ? match[1] : '' ;
			}
			function setImageUrl(fileUrl)
			{
				var funcNum = getUrlParam('CKEditorFuncNum');
				window.opener.CKEDITOR.tools.callFunction(funcNum, fileUrl);
				self.close();
			}
			function switchthumb(thumbName)
			{
				var innerContent = '<div style="margin-bottom:10px;"><a class="addThumb" href="javascript:void(0)" onclick="setImageUrl(\'http://cms.revotas.com/cms/ui/images/<%=cust.s_cust_id+"/content_load/wizard/"%>'+thumbName+'\')">Bu resmi içeriğe ekle</a></div><a id="currentThumb" class="current-item" href="javascript:void(0);"><img src="<%="/cms/ui/images/"+cust.s_cust_id+"/content_load/wizard/"%>'+thumbName+'">';
				document.getElementById("currentThumb").innerHTML = innerContent;
			}
		</script>

    </BODY>
</HTML>
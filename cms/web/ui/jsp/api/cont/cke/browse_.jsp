<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.text.SimpleDateFormat,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.ctl.*,
			java.text.DecimalFormat,
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
		out.println("Üzgünüz bir hata olu?tu. Lütfen bu hatay? #BRWS001 kodu ile bildiriniz.");
		return;
	}
}

String [] fileNames = f.list();
File [] fileObjects= f.listFiles();
SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy HH:mm:ss");

%>
<HTML>
    <HEAD>
        <TITLE>Galeri - Yüklü Dosyalar</TITLE>
		<style>	
			*,body {
				font-family:Tahoma;
				font-size:12px;
			}
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
				border: 1px solid #CCCCCC;
				display: block;
				float: left;
				font-size: 12px;
				height: 100px;
				margin-bottom: 25px;
				margin-right: 5px;
				padding: 3px;
				width: 100px;
			}
			.thumb-text span {
				display: block;
				font-size: 11px;
				margin-top: 5px;
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
				font-size:12px;
				color:#FFFFFF;
				margin-bottom:10px;
				width:120px;
				text-align:center;
				text-decoration:none;
			}
		</style>
    </HEAD>

    <BODY>
        <div style="padding:10px;">
		<div style="margin-bottom:5px;font-weight:bold;font-size:12px;">Resim Galerisi</div>
		<div style="margin-bottom:10px">Lütfen içeri?inize eklemek istedi?iniz resmi seçiniz ve içeri?e ekle butonuna t?klay?n?z.</div>
		<div id="currentThumb"></div>
		
		<% if(fileObjects.length > 0) { %>
		
					<div>
					<%
						int totalPicCount = 0;
						String firstThumb = "";
						String bgcolor = "#ffffff";
						
						for (int i = 0; i < fileObjects.length; i++) {
							if(!fileObjects[i].isDirectory()){
								if(i%2==0)
									bgcolor = "#ffffff";
								else 
									bgcolor = "#ffffff";
							
								for (String extension : okFileExtensions)
								{
								  if (fileNames[i].toLowerCase().endsWith(extension))
								  {
									if(i == 0)
										firstThumb = fileNames[i];
								  %>
									<a id="thumbnum<%=i%>" class="thumb-text" style="background-color:<%=bgcolor%>" href="javascript:void(0);" onclick="switchthumb('<%=fileNames[i]%>', <%=i%>)">
									<img style="display:block;width:100px;height:100px;border:none;" width="100" height="100" src='http://cms.revotas.com/cms/ui/images/<%=cust.s_cust_id+"/content_load/wizard/"+fileNames[i]%>'>
									<span><%=fileNames[i]%><br><%=sdf.format(fileObjects[i].lastModified())%></span></a>
									
								  <%
									double bytes = fileObjects[i].length();
									double kilobytes = (bytes / 1024);									
									DecimalFormat twoDForm = new DecimalFormat("#.##");
									out.println("Size"+Double.valueOf(twoDForm.format(kilobytes))+" KB");
								  }
								}
								totalPicCount++;
							}
						}
					%>
					<div style="clear:both;"></div>
					</div>
					
		
		<% } else out.println("Resim galerisinde hiç resim bulunmuyor. Kar??ya yükle butonu ile yeni resim ekleyebilirsiniz."); %>
		
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
			function switchthumb(thumbName, elem)
			{
				var items = getElementsByClassName(document.body,'thumb-text');
				
				for(var i=0; i<items.length; i++) {
					items[i].style.backgroundColor = "#FFFFFF";
				}

				document.getElementById("thumbnum"+elem).style.background = '#00759B';
				var innerContent = '<div style="margin-bottom:10px;"><a class="addThumb" href="javascript:void(0)" onclick="setImageUrl(\'http://cms.revotas.com/cms/ui/images/<%=cust.s_cust_id+"/content_load/wizard/"%>'+thumbName+'\')">Bu resmi içeri?e ekle</a></div><a id="currentThumb" class="current-item" href="javascript:void(0);">';
				document.getElementById("currentThumb").innerHTML = innerContent;
			}
			
			function getElementsByClassName(node, classname) {
				var a = [];
				var re = new RegExp('(^| )'+classname+'( |$)');
				var els = node.getElementsByTagName("*");
				for(var i=0,j=els.length; i<j; i++)
					if(re.test(els[i].className))a.push(els[i]);
				return a;
			}
		</script>

    </BODY>
</HTML>
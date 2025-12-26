<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.ctl.*,
			org.w3c.dom.*,org.apache.log4j.*,
			java.text.SimpleDateFormat"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="java.io.*" %>
<%@ page import="java.util.Date" %>
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
SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy HH:mm:ss");
        
%>
<HTML>
    <HEAD>
        <TITLE>Gallery</TITLE>
		<script type="text/javascript" src="jquery.js"></script>
		<script type="text/javascript" src="tablesorter.js"></script>
		<link rel="stylesheet" href="table.css" type="text/css" />
		<script>
				$(document).ready(function() 
				{ 
					$("#myTable").tablesorter(); 
				} 
			); 
		</script>
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
		<div style="margin-bottom:5px;font-weight:bold;font-size:12px;">Picture Gallery</div>
		<div style="margin-bottom:10px"></div>
		<div id="currentThumb"></div>
		
		<% if(fileObjects.length > 0) { %>
		
					<div><table id="myTable" class="tablesorter">
					<thead>
					<tr>
					<th>
						Picture
					</th>
						
					<th>
						File Name
					</th>
					<th>
						Last Modified Date
					</th>
					<th>
						Size
					</th>
					<th>Options</th>
					</tr>
					<thead>
					<tbody>
					<%
						int totalPicCount = 0;
						String firstThumb = "";
						String zebra = "";
						
						for (int i = 0; i < fileObjects.length; i++) {
							if(!fileObjects[i].isDirectory()){
								if(i%2==0)
									zebra = "odd";
								else 
									zebra = "";
							
								for (String extension : okFileExtensions)
								{
								  if (fileNames[i].toLowerCase().endsWith(extension))
								  {
									if(i == 0)
										firstThumb = fileNames[i];
									
									
								  %>
								  
								  <tr class="<%=zebra%>">
								  	
								  		<td>
											<a id="thumbnum<%=i%>" class="thumb-text">
											<img style="display:block;width:100px;height:100px;border:none;" width="100" height="100" src='http://cms.revotas.com/cms/ui/images/<%=cust.s_cust_id+"/content_load/wizard/"+fileNames[i]%>'>
											</a>
								 		</td>
								 		
								 		<td>
								 			<b><%=fileNames[i]%></b>
								 		
								 		</td>
								 		<td>
								 			<i><a><%=sdf.format(fileObjects[i].lastModified())%>	</a></i>
								 		</td>
								 		
								 		<td>
								 			<i><a>	<%=(fileObjects[i].length())/1024 %>KB	</a></i>
								 		</td>
								 		<td>
										<a href="javascript:void(null);" onclick="setImageUrl('http://cms.revotas.com/cms/ui/images/<%=cust.s_cust_id+"/content_load/wizard/"+fileNames[i]%>')">Add</a>
										</td>
								 	</tr>
								  
								  	
								  		
								  	
								  	
								  <%
								  }
								}
								totalPicCount++;
							}
						}
					%>
					</tbody>
					</table>
					<div style="clear:both;"></div>
					</div>
					
		
		<% } else out.println("There is no picture in gallery now.You can upload pictures by pressing the upload button."); %>
		
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
				var innerContent = '<div style="margin-bottom:10px;"><a class="addThumb" href="javascript:void(0)" onclick="setImageUrl(\'http://cms.revotas.com/cms/ui/images/<%=cust.s_cust_id+"/content_load/wizard/"%>'+thumbName+'\')">Bu resmi içeriğe ekle</a></div><a id="currentThumb" class="current-item" href="javascript:void(0);">';
				//document.getElementById("currentThumb").innerHTML = innerContent;
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
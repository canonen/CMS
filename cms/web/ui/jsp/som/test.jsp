<%@page import="com.britemoon.cps.User"%>
<%@page import="com.britemoon.cps.Customer"%>
<%@page import="com.britemoon.cps.UIEnvironment"%>
<%@page import="com.britemoon.cps.SessionMonitor"%>

<%@ include file="../validator.jsp"%>

<%@page import="com.britemoon.cps.som.camp.*"%>
<%@page import="com.britemoon.cps.som.com.*"%>
<%@page import="com.britemoon.cps.som.fb.*"%>
<%@page import="com.britemoon.cps.som.servlets.*"%>
<%@page import="com.britemoon.cps.som.tw.*"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ 
page import="com.britemoon.cps.som.fb.*,java.util.ArrayList,java.util.List,com.restfb.Connection,com.restfb.types.Post,com.restfb.types.FacebookType,javax.servlet.http.HttpSession" 
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@page import="java.util.ArrayList"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>New Campaign</title>
<link rel="stylesheet" href="styles/style.css"/>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>

<style>
#preview-close {
	background: url("http://www.revotas.com/fbclose1.gif") no-repeat scroll 0 5px transparent;
    color: #898989;
    display: inline-block;
    float: right;
    font-size: 10px;
    padding-left: 10px;
    text-decoration: none;
}
#preview-close:hover {
	background: url("http://www.revotas.com/fbclose2.gif") no-repeat scroll 0 5px transparent !important;
	color:#535353;
}
#link_attacher {
	background: url("http://www.revotas.com/external_link_icon.gif") no-repeat scroll 0 -2px transparent;
	color: gray;
	display: inline-block;
	font-size: 11px;
	height: 16px;
	padding-left: 15px;text-decoration: none;width: 89px;
}
.fb_buttons {
	background: url("http://www.revotas.com/fbbgbtn.gif") no-repeat scroll 0 0 transparent;
    border: 1px solid #29447E;
    color: #FFFFFF;
    cursor: pointer;
    font-family: 'lucida grande',tahoma,verdana,arial,sans-serif;
    font-size: 11px;
    font-weight: normal;
    padding: 2px 16px;
	outline:none;
	text-decoration:none;
	height:18px;
	line-height:18px;
	display:inline-block;
	
}
.fb_buttons:hover {
	color:#e7e7e7;
}
#preview-structure .title {
	border: medium none;
    color: #3B5998;
    font-family: 'lucida grande',tahoma,verdana,arial,sans-serif;
    font-size: 11px;
    font-weight: bold;
    height: 29px;
    width: 300px;
	overflow:auto;
}
#preview-structure .desc {
	border: medium none;
    color: gray;
    font-family: 'lucida grande',tahoma,verdana,arial,sans-serif;
    font-size: 11px;
    font-weight: normal;
    height: 90px;
    line-height: 18px;
    width: 300px;
	overflow:auto;
}
#preview-structure .singleline {
	border: medium none;
    color: #3B5998;
    font-family: 'lucida grande',tahoma,verdana,arial,sans-serif;
    font-size: 11px;
    width: 300px;
	overflow:auto;
	background-color:#FFFFFF;
}
</style>

<script>

function changePic(option) 
{
	var pics = $('#picContainer').children();
	var $s;
	var k;
	var skip = false;

	$.each(pics, function(key, val) {
		if(val.style.display == 'block')
		{
			if(option == 'f')
			{
				$s = $(val).next();
			}
			else {
				$s = $(val).prev();
			}
			
			if ($s.length == 0) {
				skip = true;
				return false;
			}
			
			$('#firstThumbnail').val($s.attr('src'));
			k = $s.attr('id');
			return false;
		} 
	});

	if(!skip) 
	{
		k = k.split('-');
		k = k[1];
		
		$('#picContainer > :not(#'+k+')').hide();
		$s.css('display', 'block');
		$('#currentPicNum').text(k++);
	}
}

function previewClose()
{
	$('#link_preview_container').hide();
	$('#link_attacher').trigger('click');
	$('#linkAttached').val('false');
	$('#encodedLink').val("");
}

function toggleThumbnail()
{
	var ischecked = $('#no-thumb').is(':checked');
		
	if(ischecked)
	{
		$('#picContainer').hide();
		$('#enableThumbnail').val('false');
	} 
	else {
		$('#picContainer').show();
		$('#enableThumbnail').val('true');
	}
}

$(document).ready(function() {
	
	$('#link_attacher').click(function(){
		var $e = $(this);		
		
		if($e.text() == "Attach a link")
		{
			$e.text("Detach link");
		} 
		else {
			$e.text("Attach a link");
			$('#linkAttached').val('false');
		}
		
		$('#link_container').toggle();
		$('#link_preview_container').hide();
	});
	
	// triggered when a link given and clicked to add button
	$('#link_previewer').click(function(){
		
		// get the link value
		var link = $('#attached_link').val();
		
		// get first 7 chars of link to check http
		var url_check = link.substring(0, 7);
		
		// check link if http is inserted. if not insert it
		if (url_check != "http://") {
			link = "http://" + link;
		}
		
		// link should be encoded to work correctly while requesting over facebook
		link = encodeURIComponent(link);
		
		// show preloader before ajax request
		$('#link_preview_container').html("<img src='http://www.revotas.com/smallloader.gif'/> Generating link preview");
		
		// link preview container is hidden by default. show it
		$('#link_preview_container').show();
		
		// get requested link preview. returns json
		$.getJSON('link_previewer.jsp?link='+link, function(data) {

			var description = ""; // description of link
			var caption  	= ""; // caption of link
			var pictures	= ""; // get thumbnails of link
			var messageTitle = ""; // get message title. called "name" in json
			var isError = false; // check if error occurred
			var picCount = 0; // count of thumbnails
			var setFirstPic = ""; // set first thumbnail to hidden field with id firstThumbnail 
			var noThumb = false; // if no thumbnails found
			
			// parse json data 
			$.each(data, function(key, val) {
			
				// if error returns in json, return
				if(key == "error") {
					isError = true;
					return false;
				}
				
				// data has description field
				if(key == "description"){
					description = val;
				}
				// data has caption field				
				else if(key == "caption"){
					caption = val;
				} 
				// data has name field
				else if(key == "name"){
					messageTitle = val;
				} 
				// data has media field
				else if (key == "media"){
					
					// count of thumbnails
					picCount = val.length; 
					
					// check if any thumbnail exists
					if(picCount > 0)
					{	
						// loop over thumbnails to capture them
						for(var i=0;i<picCount;i++)
						{
							// make the first thumbnail default and set setFirstPic. this will be added to hidden field later
							if(i==0) {
								pictures += "<img id='picNum-"+(i+1)+"' style='display:block;' src='"+val[i].src+"' width='50' height='50' border='0'>";
								setFirstPic = val[i].src;
							} else {
								pictures += "<img id='picNum-"+(i+1)+"' style='display:none' src='"+val[i].src+"' width='50' height='50' border='0'>";
							}
						}
					} 
					// there is no thumbnail
					else {
						noThumb = true;
						$('#enableThumbnail').val('false');
					}
				} // end data media field
			}); // end each
			
			// error occurred so print error
			if(isError)
			{
				$('#link_preview_container').html("<span style='color:#bb7373'>Could not generate preview from the given link.</span>");
			} 
			// no error we got the neccessary datas over json
			else {
			
				// thumbnail found in link set to hidden field. this will be used later
				if(!noThumb)
				{
					$('#firstThumbnail').val(setFirstPic);
				}
				
				// the filed where user enters the message content. this will be appended to preview
				var messageBody = $('#message').val();
				
				// prepare link preview html body
				var previewHTML  = "<a id='preview-close' href='javascript:void(0);' onclick='previewClose();'>Remove</a><div style='clear:both;'></div>";
				previewHTML  	+= "<table id='preview-structure' cellpadding='3' cellspacing='0' witdh='100%'><tr><td colspan='2'>";
				previewHTML		+= "<div style='font-weight:bold;'>"+messageBody+"</div></td></tr>";
				previewHTML     += "<tr><td>";
				
				// print only if there is any thumbnail found
				if(!noThumb)
				{
					previewHTML     += "<div id='picContainer'>"+pictures+"</div>";
				}
				
				previewHTML     += "</td><td valign='top'>";
				previewHTML     += "<div style='font-weight:bold;color:#3B5998;'><textarea name='title' onclick='SelectAll(this);' class='title'>"+messageTitle+"</textarea></div>";
				previewHTML     += "<div style='color:#666666;'><input name='caption' onclick='SelectAll(this);' class='singleline' type='text' disabled='disabled' value='"+caption+"'></div><div><textarea name='description' onclick='SelectAll(this);' class='desc'>"+description+"</textarea></div>";
				previewHTML     += "<div style='margin-top:5px;'><img style='display:inline-block;float:left;cursor:pointer;' onclick='changePic(\"b\")' src='http://www.revotas.com/fbleft.gif'/><img style='display:inline-block;float:left;cursor:pointer;' onclick='changePic(\"f\")' src='http://www.revotas.com/fbright.gif'/>";
				previewHTML 	+="<em style='color:#484848;font-family:lucida grande,tahoma,verdana,arial,sans-serif;font-style:normal;font-size:10px;margin-left:10px;margin-top:2px;display:inline-block;float:left;'><span id='currentPicNum'>1</span> of "+picCount+"</em>";
				previewHTML 	+="<span style='margin-left:10px;margin-top:2px;font-size:10px;color:#999999;display:inline-block;float:left;margin-left:5px;'>Choose a thumbnail</span><div style='clear:both;'></div>";
				previewHTML     +="<div style='margin-top:5px;'><input id='no-thumb' style='float:left;display:inline-block;' onclick='toggleThumbnail();' type='checkbox' value='true' name='nothumb'><label style='color:#666666;font-size:11px;font-weight:bold;float:left;display:inline-block;'>No Thumbnail</label><div style='clear:both;'></div></div></div>";
				previewHTML     += "</td></tr></table>";
				
				// append your generated link preview to container
				$('#link_preview_container').html(previewHTML);
				
				// link preview is successfull so set linkAttached to true
				$('#linkAttached').val('true');
				
				// link attached encode link and put it in a field 
				$('#encodedLink').val($('#attached_link').val());
				
			} // end no errors
		}); // end json request
	}); // end function
}); // end document ready function

function SelectAll(obj)
{
    obj.focus();
    obj.select();
}	
</script>
	
	<script type="text/javascript">
	
		function trim(s)
		{
			var l=0; var r=s.length -1;
			while(l < s.length && s[l] == ' ')
			{	l++; }
			while(r > l && s[r] == ' ')
			{	r-=1;	}
			return s.substring(l, r+1);
		}

		function submitForm(type, form)
		{
			if(type == "save")
			{
				document.getElementById('campstatus'+form).value = "0";	
			} else {
				document.getElementById('campstatus'+form).value = "1";	
			}

			prepareForPublish(form);
		}

		function prepareForPublish(form)
		{
			var submitTo = document.forms[form];
			
			if(form == 'fb')
			{
				var campname 	= trim(document.forms[form].campname.value);
				var publishOn 	= document.forms[form].pages;
				var message 	= trim(document.forms[form].message.value);
				var linkAttached 	= document.forms[form].linkAttached.value;
				
				if (campname.length < 1) 
				{
					alert("Please enter a Campaign Name for your Facebook Post");
					return false;
				}
				
				if(linkAttached == "false")
				{
					if (message.length < 1) 
					{
						alert("Please enter a message to publish");
						return false;
					}
				}
				
				var counter = 0;
				
				for(var i = 0; i < publishOn.length; i++)
				{
					if(publishOn[i].checked == true)
						counter++;
				}

				if(counter < 1)
				{
					alert("Please select a page to publish or publish on your own wall.");
					return false;
				} else {
					submitTo.submit();
					return true;
				}

			} 
			else if(form == 'tw')
			{
				if(document.forms[form].message.value == "")
				{
					alert("Please enter status message");
					return false;
				}
				submitTo.submit();
			}
			else {
				return false;
			}	
			return false;
		}
	</script>
</head>
<body>
<div id="wrapper">
			
<%@ include file="inc/header.jsp" %>
	
<%


if (request.getParameter("link") != null)
      {
        String s = request.getParameter("link");
		
		
		out.println(s);
      }
	  

 %>
</body>
</html>
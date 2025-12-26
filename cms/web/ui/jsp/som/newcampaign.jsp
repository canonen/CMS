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

<%@ page contentType="text/html; charset=UTF-8" %>
    
    
<%@ 
page import="com.britemoon.cps.som.fb.*,java.util.ArrayList,java.util.List,com.restfb.Connection,com.restfb.types.Post,com.restfb.types.FacebookType,javax.servlet.http.HttpSession" 
%>

<%
// get session object
HttpSession scope = request.getSession(false);

// camp edit param
int campaignId = 0;
if(request.getParameter("camp_id") != null)
{
	campaignId = Integer.parseInt(request.getParameter("camp_id"));	
}

// check campaign type facebook or twitter
String campaignType = request.getParameter("type");

// if campaign type is not set redirect user to error page
if(campaignType == null)
{
	request.getRequestDispatcher("error.jsp?type=CAMP_TYPE_NOT_SET").forward(request, response);
	return;
}

// get customer id from session object
int custId = Integer.parseInt((String)scope.getAttribute("custId"));

// checking account object in session
ArrayList<Account> accounts = (ArrayList<Account>)scope.getAttribute("accounts");	
String access_token = "";

if(accounts == null)
{
	request.getRequestDispatcher("error.jsp?type=NO_ACCOUNTS_IN_SESSION_NEWCAMPAIGN").forward(request, response);
	return;
}

ArrayList<CampaignObject> camps 		= null;
Facebook client 						= null;
ArrayList<CampaignObject> campsTweeter 	= null;
Twitter twclient 						= null;

// if campaign type is set to facebook
if(campaignType.equals("facebook"))
{
	
	int count = 0;
	for(int i = 0; i < accounts.size(); i++)
	{
		if(accounts.get(i).getAccountType() == 1)
		{
			count++;
		}
	}
	
	if(count < 1)
	{
		out.println("<div style='padding:5px;'>You should activate your Facebook account to create new Facebook campaigns.</div>");
		
	} else {
		
		// retrieve facebook object from session
		client = (Facebook)scope.getAttribute("fbclient");
		
		if(campaignId != 0)
		{
			// get campaigns from database
			camps =  Campaign.getCampaigns(custId, 0, campaignId, true);
			boolean noData = true;
			
			if(request.getParameter("action") != null)
			{	
				
					if(camps.get(0).getCampaignStatus() == 1)
					{
						try {
							client.deleteCampaign(camps.get(0).getPublishId());
						} 
						catch(Exception e) 
						{
							request.getRequestDispatcher("result.jsp?type=facebook&rs=delete_error").forward(request, response);
							return;
						} 
						try {
							if(Campaign.deleteCampaign(campaignId, custId))
							{
								request.getRequestDispatcher("result.jsp?type=facebook&rs=delete_done").forward(request, response);
								return;
							} else {
								request.getRequestDispatcher("result.jsp?type=facebook&rs=delete_error").forward(request, response);
								return;
							}
						}
						catch(Exception e) 
						{
							request.getRequestDispatcher("result.jsp?type=facebook&rs=delete_error").forward(request, response);
							return;
						} 
					} else {
						if(Campaign.deleteCampaign(campaignId, custId))
						{
							request.getRequestDispatcher("result.jsp?type=facebook&rs=delete_done").forward(request, response);
							return;
						} else {
							request.getRequestDispatcher("result.jsp?type=facebook&rs=delete_error").forward(request, response);
							return;
						}
					}
				
			}
			
			if(camps == null)
			{
				out.println("There is no campaign.");
			}					
		}
	}
} else if(campaignType.equals("twitter")) {
	
	// Checking if twitter account is set up.
	int count = 0;
	
	for(int i = 0; i < accounts.size(); i++)
	{
		if(accounts.get(i).getAccountType() == 2)
		{
			count++;
		}
	}
	
	if(count < 1)
	{
		request.getRequestDispatcher("campaigns.jsp").forward(request, response);
		return;
		
	} else {
			
		// retrieve twitter object from session
		twclient = (Twitter)scope.getAttribute("twclient");
		
		if(campaignId != 0)
		{
			// get campaigns from database
			campsTweeter =  Campaign.getCampaigns(custId, 0, campaignId, true);
			boolean noData = true;
			
			if(request.getParameter("action") != null)
			{			
				
					if(campsTweeter.get(0).getCampaignStatus() == 1)
					{
						try {
							twclient.deleteCampaign(campsTweeter.get(0).getPublishId());
						} 
						catch(Exception e) 
						{
							request.getRequestDispatcher("result.jsp?type=twitter&rs=delete_error").forward(request, response);
							return;
						} 
						try {
							if(Campaign.deleteCampaign(campaignId, custId))
							{
								request.getRequestDispatcher("result.jsp?type=twitter&rs=delete_done").forward(request, response);
								return;
							} else {
								request.getRequestDispatcher("result.jsp?type=twitter&rs=delete_error").forward(request, response);
								return;
							}
						}
						catch(Exception e) 
						{
							request.getRequestDispatcher("result.jsp?type=twitter&rs=delete_error").forward(request, response);
							return;
						} 
					} else {
					
						if(Campaign.deleteCampaign(campaignId, custId))
						{
							request.getRequestDispatcher("result.jsp?type=twitter&rs=delete_done").forward(request, response);
							return;
						} else {
							request.getRequestDispatcher("result.jsp?type=twitter&rs=delete_error").forward(request, response);
							return;
						}
					}
			}
			
			if(campsTweeter == null)
			{
				out.println("There is no campaign.");
			}				
		}
	}
// if campaign type is not set redirect user to error page
} else {
	request.getRequestDispatcher("error.jsp?type=CAMP_TYPE_NOT_SET").forward(request, response);
	return;
}
%>	
	
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>
<head>
<meta charset="utf-8">
<title>New Campaign</title>
<meta http-equiv="Content-type" value="text/html; charset=utf-8">
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

<script language = "Javascript">
function textCounter(field,cntfield,maxlimit) {
	if (field.value.length > maxlimit)
		field.value = field.value.substring(0, maxlimit);
		else
		cntfield.value = maxlimit - field.value.length;
	}
</script>

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
				previewHTML     += "<div style='color:#666666;'><input name='caption' onclick='SelectAll(this);' class='singleline' type='text' readonly='readonly' value='"+caption+"'></div><div><textarea name='description' onclick='SelectAll(this);' class='desc'>"+description+"</textarea></div>";
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
				var len 	= publishOn.length;
				
				if(len == undefined) 
				{
					counter = 1;
				}
				else {
					for(var i = 0; i < publishOn.length; i++)
					{
						if(publishOn[i].checked == true)
							counter++;
					}
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
			
<%@include file="inc/header.jsp"%>	

<%

// After publish action performed check publish status
if(scope.getAttribute("publish_status") != null)
{
	out.println("<div>"+scope.getAttribute("publish_status").toString()+"</div>");
	scope.removeAttribute("publish_status");
}

if(campaignType.equals("facebook")) 
{
%>
	<form name="fb" method="post" action="DoPublish?type=facebook<%if(campaignId != 0){out.print("&camp_id="+campaignId);}%>">	
	<div id="container" style="width:800px;">

		<div style="color: #4B67A1;font-size: 16px;font-weight: bold;padding:20px"><%=campaignType%></div>
		<div style="padding-left:20px;">
			<div style="float:left;font-weight:bold;margin-right:5px;color:#666666">Enter your message</div>
			<div style="float:left;font-weight:bold;margin-right:5px;color:#666666;margin-top: 5px;"><img src="http://www.revotas.com/breadcrumb_arrow.gif"></div>
			<div style="float:left;font-weight:bold;margin-right:5px;color:#666666">Attach a link</div>
			<div style="float:left;font-weight:bold;margin-right:5px;color:#666666;margin-top: 5px;"><img src="http://www.revotas.com/breadcrumb_arrow.gif"></div>
			<div style="float:left;font-weight:bold;margin-right:5px;color:#666666">Choose your target</div>
			<div style="float:left;font-weight:bold;margin-right:5px;color:#666666;margin-top: 5px;"><img src="http://www.revotas.com/breadcrumb_arrow.gif"></div>
			<div style="float:left;font-weight:bold;margin-right:5px;color:#666666">Publish</div>
			<div style="clear:both"></div>
		</div>
		
		<div class="form-container" style="float:left;width:450px;">
			<div style="background-color: #FFFFFF;border: 1px solid #dddddd;width: 400px;margin:10px 20px;">
				<div style="padding: 10px;">
					<div style="color: #3B5998;font-family: 'lucida grande',tahoma,verdana,arial,sans-serif;font-size: 11px;font-weight: bold;margin-bottom: 3px;">Your Message</div>
					<div>
						<textarea id="message" name="message" style="overflow-y:auto;border: 1px solid #CCCCCC;color: #484848;font-family:'lucida grande',tahoma,verdana,arial,sans-serif;font-size: 11px;font-weight: bold;height: 55px;padding: 3px;width: 372px;"><%if(camps != null){out.println(camps.get(0).getMessage());}%></textarea>
					</div>
				</div>
				<div style="display:none;background-color: #FFFFFF;border-top: 1px dotted #CCCCCC;line-height: 18px;margin-top: 10px;padding: 10px;" id="link_preview_container"></div>
				<div style="border-top: 1px solid #E6E6E6;padding: 10px;background-color: #F2F2F2;">
					<a href='javascript:void(0)' id="link_attacher"><%if(camps != null && (!camps.get(0).getLink().equals(""))){out.println("Detach link");}else if(camps == null){out.print("Attach a link");}else{out.print("Attach a link");}%></a>
					<span id="link_container" style="<%if(camps != null && (!camps.get(0).getLink().equals(""))){out.println("display:inline;");}else{out.print("display:none;");}%>">
						<input value="<%if(camps != null && (!camps.get(0).getLink().equals(""))){out.println(camps.get(0).getLink());}else{out.println("http://");}%>" style="border: 1px solid #DDDDDD;border-radius: 3px 3px 3px 3px;color: #818181;font-family: 'lucida grande',tahoma,verdana,arial,sans-serif;font-size: 11px;line-height: 11px;padding: 4px 8px;width: 180px;" type="text" id="attached_link">
						<a class="fb_buttons" id="link_previewer" href="javascript:void(0);">Add</a>
					</span>
					
				</div>
			</div>
			<div style="margin-left:20px;padding-bottom: 10px;">
			<div style="color: #666666;line-height: 18px;margin-bottom: 10px;padding-right: 20px;padding-top: 5px;">If you would like to share a link, click on "Attach a link" type your link and click on "Add" button.
			You will see a preview of your link post. You are able to choose a thumbnail for your link post or disable thumbnail.</div>
			<%
				if(camps == null || camps.get(0).getCampaignStatus() == 0)
				{
			%>
					<a class="fb_buttons" href="javascript:void(0)" onclick="submitForm('start','fb');">Publish on Facebook</a>
					<a class="fb_buttons" href="javascript:void(0)" onclick="submitForm('save','fb');">Save</a>
			<%
				}
				if(campaignId != 0)
				{
			%>
					<a class="fb_buttons" onclick="return confirm('Are you sure to delete this campaign ? ');" href='newcampaign.jsp?type=<%=campaignType%>&camp_id=<%=campaignId%>&action=delete'>Delete</a>
			<%
				}
			%>
			</div>
			<input type="hidden" name="linkAttached" id="linkAttached" value="<%if(camps != null && !camps.get(0).getLink().equals("")){out.print("true");}else{out.print("false");}%>"/>
			<input type="hidden" name="enableThumbnail" id="enableThumbnail" value="<%if(camps != null && !camps.get(0).getPicture().equals("")){out.print("true");}else if(camps == null){out.print("true");}else{out.print("false");}%>"/>
			<input type="hidden" name="firstThumbnail" id="firstThumbnail" value="<%if(camps != null && !camps.get(0).getPicture().equals("")){out.print(camps.get(0).getPicture());}else{out.print("");}%>"/>
			<input type="hidden" name="campaignstatus" id="campstatusfb" value="0"/>
			<input type="hidden" name="link" id="encodedLink" value="<%if(camps != null && (!camps.get(0).getLink().equals(""))){out.println(camps.get(0).getLink());}else{out.println("");}%>"/>
		</div>
		<%
			// FBAccount is for facebook fan pages object
			ArrayList<FBAccount> pageAccounts = client.getAccountList();
		%>
		<div style="float:left;padding-bottom:10px;">
			<div style="margin-bottom:3px;color:#3B5998;font-weight:bold;">Campaign name</div>
			<div style="margin-bottom:2px;color:#666">Give a campaign name for this post</div>
			<div><input type="text" name="campname" value="<%if(camps != null){out.println(camps.get(0).getCampaignName());}else{out.println("");}%>" style="border: 1px solid #cccccc;color: #484848;font-family: 'lucida grande',tahoma,verdana,arial,sans-serif;font-size: 11px;font-weight: bold;margin-bottom: 10px;padding: 3px;width: 185px;"></div>
			
			<div style="border-top:1px solid #DDDDDD;padding-top:10px;margin-bottom:3px;color:#3B5998;font-weight:bold;">Publish as</div>
			<div style="margin-bottom:2px;color:#666">Your message will be posted over this account</div>
			<div>
				<select name="publishas" style="border: 1px solid #cccccc;color: #484848;font-family: 'lucida grande',tahoma,verdana,arial,sans-serif;font-size: 11px;font-weight: bold;margin-bottom: 10px;padding: 3px;width: 193px;">
					<%
						if(pageAccounts != null)
							out.println("<option value='aspage'>Page Account</option>");
					%>
					<option value="asme">My Account</option>
				</select>
			</div>
		
			<div style="border-top:1px solid #DDDDDD;padding-top:10px;margin-bottom:5px;font-weight:bold;color:#3B5998;">Choose page(s) to publish</div>
			<div style="margin-bottom:5px;color:#666">The pages you would like to post this message</div>
			<div>
			<%
				if(pageAccounts == null)
				{
					out.println("<div style='margin-bottom:3px;font-weight:normal;font-size:11px;color:#474747;'>");
					out.println("<input type='hidden' style='vertical-align:middle' type='checkbox' checked='checked' ");
					out.println("value='me' name='pages'>On my wall</div>");
				} 
				else {
				
					if(pageAccounts.size() == 0  )
					{
						out.println("No pages found");
						
					} else {
						
						String[] tokens = null;
						
						if(camps != null)
						{
							tokens = camps.get(0).getNetworks().split(",");
						}
						
						for(int i = 0; i < pageAccounts.size(); i++)
						{		
							if(camps != null)
							{
								if(tokens[0].equals("me") && i == 0)
								{
									out.println("<div style='margin-bottom:3px;font-weight:normal;font-size:11px;color:#474747;'>");
									out.println("<input style='vertical-align:middle' type='checkbox' checked='checked' ");
									out.println("value='me' name='pages'>On my wall</div>");
								} else if(i == 0) {
									out.println("<div style='margin-bottom:3px;font-weight:normal;font-size:11px;color:#474747;'><input style='vertical-align:middle' type='checkbox' ");
									out.println("value='me' name='pages'>On my wall</div>");
								}
							} else if(i == 0) {
								out.println("<div style='margin-bottom:3px;font-weight:normal;font-size:11px;color:#474747;'><input style='vertical-align:middle' type='checkbox' ");
								out.println("value='me' name='pages'>On my wall</div>");
							}
								
							out.println("<div style='margin-bottom:3px;font-weight:normal;font-size:11px;color:#474747;'>");
							out.println("<input style='vertical-align:middle' type='checkbox' ");
							out.println("name='pages'");
							
							if(camps != null)
							{										
								for(int m = 0; m < tokens.length; m++)
								{
									if(tokens[m].equals(pageAccounts.get(i).getId()))
									{
										out.println(" checked='checked' ");
									}
								}
							}
								
							out.println("value='"+pageAccounts.get(i).getId()+"'>"+pageAccounts.get(i).getName()+"</div>");
						}
					}
				}
				
				
			%>
			</div>
		</div>
	
		<div style="clear:both;"></div>
	</div>
	</form>
<% 
} else if(campaignType.equals("twitter")) {
%>
	<form name="tw" method="post" action="DoPublish?type=twitter<%if(campaignId != 0){out.print("&camp_id="+campaignId);}%>">
	<div id="container" style="width:442px;">
	
		<div style="color: #0099B9;font-size: 16px;font-weight: bold;padding: 10px 0 0 20px"><%=campaignType%></div>
		<div style="color: #666666;line-height: 18px;margin-bottom: 10px;padding-left: 20px;padding-top: 5px;">
			Give a campaign name to your post. Type your message and tweet! To mention about someone, add "@" symbol and the username of the person. i.e: @revotas
		</div>
		<div style="margin-left:20px;margin-top:10px;margin-bottom:5px;padding:10px;border:1px solid #DDDDDD;background-color:#FFFFFF;">
		<div style="color: #0099B9;font-family: 'lucida grande',tahoma,verdana,arial,sans-serif;font-size: 11px;font-weight: bold;margin-bottom: 3px;">Campaign Name:</div> 
		<input class="input-fields" type="text" name="content_name" value="<%if(campsTweeter != null){out.println(campsTweeter.get(0).getCampaignName());}%>"/>
		<div style="margin-top:10px;color: #0099B9;font-family: 'lucida grande',tahoma,verdana,arial,sans-serif;font-size: 11px;font-weight: bold;margin-bottom: 3px;">Status Message:</div>
		<textarea onKeyDown="textCounter(document.tw.message,document.tw.remLen2,140)" onKeyUp="textCounter(document.tw.message,document.tw.remLen2,140)" wrap="physical" style="border: 1px solid #CCCCCC;color: #484848;font-family: 'lucida grande',tahoma,verdana,arial,sans-serif;font-size: 11px;font-weight: bold;height: 55px;overflow-y: auto;padding: 3px;width: 372px;" name="message" maxlength="140" rows="3" cols="50"><%if(campsTweeter != null){out.println(campsTweeter.get(0).getMessage());}%></textarea>
		
		</div>
		<div style="color: #666666;margin-top: 5px;text-align: right;">
			<input style="background-color: #F9F9F9;border: medium none;color: #999999;font: 16px Helvetica Neue,Arial,Helvetica,'Liberation Sans',FreeSans,sans-serif;text-align: right;" size="1" readonly type="text" name="remLen2" value="140">
		</div>
		<div style="margin-top:20px;margin-left:20px;">
		<%
			if(campsTweeter == null || campsTweeter.get(0).getCampaignStatus() == 0)
			{
		%>
				<a class="fb_buttons" href="#" onclick="submitForm('start','tw');" class="buttonsfloat">Start</a>
				<a class="fb_buttons" href="#" onclick="submitForm('save','tw')" class="buttons-passive">Save</a>
		<%
			}
			if(campaignId != 0)
			{
		%>
				<a class='fb_buttons' onclick="return confirm('Are you sure to delete this campaign ? ');" href='newcampaign.jsp?type=<%=campaignType%>&camp_id=<%=campaignId%>&action=delete'>Delete</a>
		<%
			}
		%>
		<div style='clear:both;'></div>
		<input type="hidden" name="type" value="twitter"/> 
		<input type="hidden" id="campstatustw" name="campaignstatus" value="0"/>
		</div>
	</div>
	</form>	

<%
}
%>
</div>
</body>
</html>

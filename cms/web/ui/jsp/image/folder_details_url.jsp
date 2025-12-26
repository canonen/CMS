<%@ page
	language="java"
	import="javax.servlet.http.*,
			javax.servlet.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			com.britemoon.cps.ctl.*,
			com.britemoon.cps.cnt.*,
			java.util.*,java.sql.*,
			java.net.*,org.apache.log4j.*"
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

AccessPermission can = user.getAccessPermission(ObjectType.IMAGE);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

// if input_name is not null, we will assume this page was opened from ccps/ui/jsp/ctm/sectionedit.jsp.
// we will switch to the 'selector mode', which will update the input field from sectionedit.jsp
// after a section has been made

String sInputName = BriteRequest.getParameter(request,"input_name");
String sFolderId = BriteRequest.getParameter(request,"folder_id");
String sErrors = BriteRequest.getParameter(request,"errors");

String sRootFolderId = null;
String sGlobalFolderId = null;

try
{
	//no folder specified, grab root.
	sRootFolderId = ImageHostUtil.getRoot(cust.s_cust_id);
	sGlobalFolderId = ImageHostUtil.getGlobalRoot(cust.s_cust_id);

	if ((sRootFolderId == null) && (sGlobalFolderId == null)) {
		//No Images;
		sErrors = "This system does not have any images loaded.";
	}

	if ((sFolderId == null) || ("".equals(sFolderId)))
	{
		sFolderId = (sGlobalFolderId!=null)?sGlobalFolderId:sRootFolderId;
	}
	
%>
<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<SCRIPT src="../../js/scripts.js"></SCRIPT>
<script src="../../js/tab_script.js"></script>
<title>Image Library URL <%=(sInputName==null?"Generator":"Selector")%></title>
<script language="javascript">
	
	function on(o)
	{
		if (o.className != "image_item image_item_on")
		{
			o.runtimeStyle.backgroundColor = "#FFFFEE";
			o.runtimeStyle.borderColor = "#FFBB77";
		}
	}

	function off(o)
	{
		o.runtimeStyle.backgroundColor = "";
		o.runtimeStyle.borderColor = "";
	}
	
	var curImage;
	
	function takeAction(itemType, itemID)
	{
		if (itemID != "null")
		{
			var sElem = window.event.srcElement;
			var TDElem = sElem;
			
			if (TDElem.tagName == "BODY") return;
			
			while (TDElem.tagName != "TD" && TDElem.tagName != "BODY")
			{
				TDElem = TDElem.parentElement;
			}
			
			if (TDElem.tagName == "BODY") return;
			
			if (sElem.tagName != "INPUT")
			{
				if (itemType == "folder" && itemID != "0")
				{
					<% if (sInputName!=null) { %>
					location.href = "folder_details_url.jsp?folder_id=" + itemID + "&input_name=<%=sInputName%>";
					<% } else { %>
					location.href = "folder_details_url.jsp?folder_id=" + itemID;
					<% } %>
				}
				
				if (itemType == "url")
				{
					if (curImage != window.undefined)
					{
						curImage.className = "image_item";
					}
					
					TDElem.className = "image_item image_item_on";
					curImage = TDElem;
					
					TDElem.runtimeStyle.backgroundColor = "#CCDDFF";
					TDElem.runtimeStyle.borderColor = "#004466";
					
					FT.imgURL.value = itemID;
					<% if (sInputName==null) { %>
					FT.imgHTML.value = "<img src=\"" + itemID + "\" border=\"0\">";
					<% } %>

				}
			}
		}

	}

    <% if (sInputName!=null) { %>
	function selectURL()
	{
		var theURL;
		var theSelect;
		var theRange;

		FT.imgURL.select();
		theSelect = document.selection;
		theRange = theSelect.createRange();

		if (theRange.text.length > 0)
		{
			theRange.execCommand("Copy");
			document.selection.empty();
			opener.document.getElementById('<%=sInputName%>').value = FT.imgURL.value;
			if (opener.document.getElementById('image<%=sInputName%>') == null) {
				var inpElem = opener.document.getElementById('<%=sInputName%>');
				var brElem = opener.document.createElement("BR");
				var imgElem = opener.document.createElement("IMG");
				imgElem.id = 'image<%=sInputName%>';
				imgElem.src = FT.imgURL.value;
				inpElem.insertAdjacentElement("BeforeBegin", imgElem);
				imgElem.insertAdjacentElement("AfterEnd", brElem);
			}
			else {
				opener.document.getElementById('image<%=sInputName%>').src = FT.imgURL.value;
			}
			self.close();
			return false;
		} else {
			alert("No image selected");
		}
	}
    <% } else { %>
	function copyURL()
	{
		var theURL;
		var theSelect;
		var theRange;

		FT.imgURL.select();
		theSelect = document.selection;
		theRange = theSelect.createRange();

		if (theRange.text.length > 0)
		{
			theRange.execCommand("Copy");

			document.selection.empty();

			alert("The url has been copied.  Paste the image url in the appropriate section of your HTML.");
		} else {
			alert("No URL to copy");
		}
	}
	
	function copyHTML()
	{
		var theURL;
		var theSelect;
		var theRange;

		FT.imgHTML.select();
		theSelect = document.selection;
		theRange = theSelect.createRange();

		if (theRange.text.length > 0)
		{
			theRange.execCommand("Copy");

			document.selection.empty();

			alert("The HTML has been copied.  Paste the image HTML in the appropriate section of your content.");
		} else {
			alert("No HTML to copy");
		}
	}
	<% } %>	

	function window.onload()
	{
		self.focus();
	}

		
</script>
<style type="text/css">
	
	SELECT
	{
		width:100%;
	}
	
</style></style>
</HEAD>
<BODY topmargin="0" leftmargin="0" style="padding:0px;">
<%
if (sErrors != null)
{
	%>
	<font color="red">
	<%= sErrors %>
	</font>
	<%
}
else
{
	if (sFolderId == null)
	{
		throw new Exception("Cannot display folder details.  Folder ID not found.");
	}
	ImgFolder folder = new ImgFolder(sFolderId);
	String sPath = folder.getPrettyPathUrl(sInputName);
	%>
	<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
		<col>
		<tr height="25">
			<td align="left" valign="top" style="padding:0px;">
				<table cellspacing="0" cellpadding="4" border="0" class="layout" style="width:100%; height:100%;">
					<col width="70">
					<col>
					<col width="20">
					<col width="150">
					<tr>
						<td class="MenuBar" align="right" valign="middle">
							<b>Location:</b>
						</td>
						<td class="MenuBar" align="left" valign="middle">
							<select name="quick_folder_id" onchange="takeAction('folder', this.value);" size="1">
								<option selected value="0">&lt; --- --- --- Choose folder --- --- --- &gt;</option>
								<%
									String sFolderHTML = ImageHostUtil.getFolderOptionsHTML(sGlobalFolderId,0,sFolderId,cust.s_cust_id);
                                    sFolderHTML += ImageHostUtil.getFolderOptionsHTML(sRootFolderId,0,sFolderId,cust.s_cust_id);
								%>
								<%= sFolderHTML %>
							</select>
						</td>
						<td class="MenuBar" align="left" valign="middle">
							<img src="../../images/images_folder_up.gif" style="cursor:hand;" border="0" title="Up" onclick="takeAction('folder', '<%= folder.s_parent_id %>');">
						</td>
						<td class="MenuBar" align="right" valign="middle">
							<a href="javascript:self.close();" class="subactionbutton">Close [X]</a>&nbsp;
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr height="25">
			<td align="left" valign="top" style="padding:0px;">
				<table cellspacing="0" cellpadding="4" border="0" class="layout" style="width:100%; height:100%;">
					<col width="70">
					<col>
					<tr>
						<td class="MenuBar">&nbsp;</td>
						<td class="MenuBar" align="left" valign="middle" nowrap>
							<%= sPath %>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td align="left" valign="top">
				<div style="overflow:auto; height:100%; width:100%; padding:10px;">
						<table cellspacing="0" cellpadding="4" border="0" class="layout" style="width:100%;">
							<col width="20%">
							<col width="5%">
							<col width="20%">
							<col width="5%">
							<col width="20%">
							<col width="5%">
							<col width="20%">
							<col width="5%">
							<tr height="80">
						<%
						int iCount = -1;
						int iItems = 0;

						boolean bHasContents = false;

						//get and display subfolders
						folder.getSubFolders(cust.s_cust_id);
						
						if (folder.m_SubFolders != null && folder.m_SubFolders.size() > 0 )
						{
							bHasContents = true;
							Iterator itSubFolders = folder.m_SubFolders.iterator();
							
							while (itSubFolders.hasNext())
							{
								ImgFolder subFolder = (ImgFolder) itSubFolders.next();
								iCount++;
								iItems++;
								
								if (iCount >=4)
								{
									iCount = 0;
									%>
									</tr>
									<tr height="80">
									<%
								}
								%>
								<td align="center" valign="middle" class="image_item" title="<%= subFolder.s_folder_name %>" onmouseover="on(this);" onmouseout="off(this);" onclick="takeAction('folder', '<%= subFolder.s_folder_id %>');">
									<img src="../../images/images_folder_large.gif" border="0"><br>
									<nobr><%= subFolder.s_folder_name.replaceAll(" ", "") %></nobr><br>
								</td>
								<td align="center" valign="middle">&nbsp;</td>
								<%
							}
						}
						
						//get and display images
						folder.getImages(cust.s_cust_id);
						iItems = 0;
						
						if (folder.m_Images != null && folder.m_Images.size() > 0 )
						{
							bHasContents = true;
							Iterator itImages = folder.m_Images.iterator();
							
							while (itImages.hasNext())
							{
								Image image = (Image) itImages.next();
								iCount++;
								iItems++;
								
								if (iCount >=4)
								{
									iCount = 0;
									%>
									</tr>
									<tr height="80">
									<%
								}
								%>
								<td align="center" valign="middle" class="image_item" title="<%= image.s_image_name %>" onmouseover="on(this);" onmouseout="off(this);" onclick="takeAction('url', '<%= ImageHostUtil.getMirrorPath(image.s_cust_id, image.s_url_path) %>');">
									<img src="<%= image.s_url_path %>" border="0" class="menuImg"><br>
									<nobr><%= image.s_image_name.replaceAll(" ", "") %></nobr><br>
								</td>
								<td align="center" valign="middle">&nbsp;</td>
								<%
							}
						}
						
						if (bHasContents)
						{
							for (int x=iCount+1;x<4;++x)
							{
								%>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
								<%
							}
						}
						else
						{
							%>
							<td>No Contents</td>
							<td>&nbsp;</td>
							<%
						}
						%>
							</tr>
						</table>
				</div>
			</td>
		</tr>
		<tr height="60">
			<td align="left" valign="top" style="padding:0px;">
				<form name="FT" style="display:inline;">
				<table cellspacing="0" cellpadding="4" border="0" class="layout" style="width:100%; height:100%;">
					<col width="85">
					<col>
					<col width="85">
					<% if (sInputName!=null) { %>
					<tr height="30">
						<td class="MenuBar" align="left" valign="middle" nowrap>Image URL: </td>
						<td class="MenuBar" align="left" valign="middle" nowrap>
							<input type="text" name="imgURL" value="" style="width:100%;">
						</td>
						<td class="MenuBar" align="left" valign="middle" nowrap>
							<a class="resourcebutton" href="javascript:selectURL();">select URL</a>
						</td>
					</tr>
					<% } else { %>
					<tr height="30">
						<td class="MenuBar" align="left" valign="middle" nowrap>Image URL: </td>
						<td class="MenuBar" align="left" valign="middle" nowrap>
							<input type="text" name="imgURL" value="" style="width:100%;">
						</td>
						<td class="MenuBar" align="left" valign="middle" nowrap>
							<a class="resourcebutton" href="javascript:copyURL();">Copy URL</a>
						</td>
					</tr>
					<tr height="30">
						<td class="MenuBar" align="left" valign="middle" nowrap>Image HTML: </td>
						<td class="MenuBar" align="left" valign="middle" nowrap>
							<input type="text" name="imgHTML" value="" style="width:100%;">
						</td>
						<td class="MenuBar" align="left" valign="middle" nowrap>
							<a class="resourcebutton" href="javascript:copyHTML();">Copy HTML</a>
						</td>
					</tr>
					<% } %>
				</table>
				</form>
			</td>
		</tr>
	</table>
	<%
}
%>
</BODY>
</HTML>
<%
} catch(Exception ex) { 

	ErrLog.put(this, ex, "Problem producing Image list", out, 1);

}
%>

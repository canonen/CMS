<%@ page
	language="java"
	import="com.oreilly.servlet.multipart.*,
			com.britemoon.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.*,
			java.io.*,java.util.*,
			java.sql.*,javax.servlet.http.*,
			javax.servlet.*,org.apache.log4j.*"
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

if(!can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

String sSelectedCategoryId = null;
String sImageId = "0";
String sFileName = null, sImageUrl = null, sFolderName = null, sFolderId = null, sOverwrite = null;
String sAccessCusts = null;
String[] sAccessMap = null;
Vector vSavedImages = new Vector();
Vector vErroredImages = new Vector();
Vector vZipFiles = new Vector();
String sProcessedMsg = null;
boolean bNewImage = false, bOverwrite = true;
FilePart fpImage = null;
Part myPart = null; 

//Have a 10 Meg limit as default
int iTotalFileSizeLimit = ImageHostUtil.getTotalFileSizeLimit(cust.s_cust_id);
int iTotalFileSizeUsed = ImageHostUtil.getTotalFileSizeUsed(cust.s_cust_id);
int iFileSizeLimit = ImageHostUtil.getFileSizeLimit(cust.s_cust_id);
if (iTotalFileSizeLimit == 0) iTotalFileSizeLimit = 10240000;
MultipartParser mp = null;
	
try
{
	mp = new MultipartParser(request, iTotalFileSizeLimit);
}
catch (Exception e)
{
	mp = null;
	vErroredImages.add("<td colspan=4><font color=red>No files saved.  Upload exceded total file size limit for customer.</font></td>");
}

//Parts should arrive in the following order:
//category_id, folder_id, display_name, file
if (mp != null)
{
	while ((myPart = mp.readNextPart()) != null)
	{
		if (myPart.getName().equals("category_id")) sSelectedCategoryId = ((ParamPart)myPart).getStringValue();
		if (myPart.getName().equalsIgnoreCase("image_id"))
		{
			sImageId = ((ParamPart)myPart).getStringValue();
			if (sImageId == null) sImageId = "0";
		}
	
		if (myPart.getName().equals("folder_id")) sFolderId = ((ParamPart)myPart).getStringValue();
		if (myPart.getName().equals("image_url")) sImageUrl = ((ParamPart)myPart).getStringValue();
		if (myPart.getName().equals("overwrite")) 
		{
			sOverwrite = ((ParamPart)myPart).getStringValue();
			if (sOverwrite != null) bOverwrite = true;
		}
		if (myPart.getName().equals("access_map"))
		{
			sAccessCusts = ((ParamPart)myPart).getStringValue();
			sAccessMap = sAccessCusts.split(";");
		}
		if (myPart.isFile())
		{
			fpImage = (FilePart) myPart;
			if (fpImage != null)
			{
				sFileName = fpImage.getFileName();
//  Zip and content upload image processing does not modify filename
//					sFileName = sFileName.replace(' ','_');
//					sFileName = sFileName.toLowerCase();
				if (sOverwrite == null)	bOverwrite = false;
				
				// check file extension to see if it is a ZIP file
				if (ImageHostUtil.isZipFile(sFileName))
				{
					if (myPart.getName().equals("zip_file"))
					{
						vZipFiles = ImageHostUtil.processZipFile(fpImage, cust.s_cust_id, sFolderId, user.s_user_id, bOverwrite, sAccessMap);
						break;
					}
					else
					{    // ZIP file loaded with image files.  Can't do it.
						sProcessedMsg = "Cannot load ZIP file while uploading image files. Upload ZIP files separately.";
					}
				}
				else
				{
					sProcessedMsg = ImageHostUtil.processFile(fpImage, cust.s_cust_id, sFolderId, user.s_user_id, sImageId, sFileName, bOverwrite, sAccessMap);
				}
			}
			if (sProcessedMsg.equalsIgnoreCase("success")) vSavedImages.add(sFileName);
			else
			{
				vErroredImages.add("<td>" + sFileName + "</td><td>Image</td><td><font color=red>Error</font></td><td>" + sProcessedMsg + "</td>");
			}
		}
	}
}
%>
<HTML>

<HEAD>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>

<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Image:</b> Uploaded &amp; Saved</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">

<!-- === === === -->

<table cellspacing="0" cellpadding="3" border="0" class="listTable layout" style="width:100%;">
	<col width="40%">
	<col width="50">
	<col width="75">
	<col width="60%">
	<tr>
		<th>File Name</th>
		<th>Type</th>
		<th>Status</th>
		<th>Message</th>
	</tr>
	<%
	int itemCount = 0;
	
	if (vSavedImages != null && vSavedImages.size() > 0)
	{
		Iterator itSavedImages = vSavedImages.iterator();
		while (itSavedImages.hasNext())
		{
			%>
			<tr>
				<td><%=(String)itSavedImages.next()%></td>
				<td>Image</td>
				<td>Uploaded</td>
				<td>--</td>
			</tr>
			<%
			itemCount++;
		}
	}
	
	if (vErroredImages != null && vErroredImages.size() > 0)
	{
		Iterator itErroredImages = vErroredImages.iterator();
		while (itErroredImages.hasNext())
		{
%>
			<tr>
				<%=(String)itErroredImages.next()%>
			</tr>
<%
			itemCount++;
		}
	}
	
	if (vZipFiles != null && vZipFiles.size() > 0)
	{
		Iterator itZipFiles = vZipFiles.iterator();
		String sTmp = null;
		
		while (itZipFiles.hasNext())
		{
			sTmp = (String)itZipFiles.next();
			%>
			<tr>
				<%=sTmp%>
			</tr>
			<%
			itemCount++;
		}
	}
	
	if (itemCount == 0)
	{
		%>
		<tr>
			<td colspan="4">No images or folders were saved or uploaded.</td>
		</tr>
		<%
	}
	%>
</table>
<br><br>
<a href="image_list.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">Back to List</a>

<!-- === === === -->

					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</BODY>
</HTML>

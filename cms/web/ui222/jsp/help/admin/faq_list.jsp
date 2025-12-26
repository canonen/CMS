<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			java.io.*,java.sql.*,
			java.util.*,java.util.*,
			java.sql.*,org.w3c.dom.*,
			org.apache.log4j.*"
%>
<%@ include file="../../header.jsp" %>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

String faq_id = null;
faq_id = request.getParameter("faq_id");
%>
<html>
<head>
	<title>FAQ Admin</title>
	<%@ include file="../../header.html" %>
	<style type="text/css">
	<!--
		
		a:link,a:visited
		{
			font-family: Arial, Helvetica;
			font-size: 8pt;
			color:#990000;
			text-decoration: none;
		}
		
		td.sectionheader
		{
			font-family: Arial, Helvetica;
			color: #ffffff;
			background-color=#000040;
			font-size: 12px
		}
		
		table
		{
			font-size:8pt;
			color:#000000;
			font-family:Verdana;
		}
				
		td
		{
			font-size:8pt;
			color:#000000;
			font-family:Verdana;
		}
		
		b.sectionheader
		{
			font-family: Arial, Helvetica;
			color:#ffcc00;
			text-decoration: none;
		}
		
		input,textarea,option,select
		{
			font-family: arial;
			font-size: 9pt;
		}
		
		select.smallDDL
		{
			font-family: arial;
			font-size: 8pt;
		}
	
	//-->
	</style>
	<link rel="stylesheet" type="text/css" href="../global.css">
	<script language="javascript">
				
		var curPopupWindow = null;
		var faqWindow = null;
		
		function openPopup(url, name, pWidth, pHeight)
		{
			//closePopup();
			//curPopupWindow = window.open(url, name, "left=100,top=100,width='+pWidth+',height='+pHeight+',toolbar=no,status=no,directories=no,menubar=no,resizable=yes,scrollbars=yes", false);
			//curPopupWindow.focus();
			document.getElementById("frameEdit").src = url;
		}
		
		function closePopup() {
			if (curPopupWindow != null)
			{
				if (!curPopupWindow.closed)
				{
					curPopupWindow.close();
				}
				curPopupWindow = null;
			}
		}
		
		function showHideRow(rowID)
		{
			if ((window.event.srcElement.tagName != "img") && (window.event.srcElement.tagName != "a"))
			{
				if (document.getElementById(rowID).style.display == "none")
				{
					document.getElementById(rowID).style.display = "";
				}
				else
				{
					document.getElementById(rowID).style.display = "none";
				}
			}
		}
		
	</script>
</head>
<body bgColor="#dddddd" topmargin="0" leftmargin="0">
<table cellspacing="0" cellpadding="0" border="0" width="100%" height="100%">
	<tr>
		<td bgcolor="#FFFFFF" align="left"><img src="../../../images/logo.gif" border="0"></td>
		<td bgcolor="#FFFFFF" align="right" valign="bottom">
			<table cellpadding="0" cellspacing="0" border="0">
				<tr>
					<td align="right" valign="middle" class="navOff"><a href="help_list.jsp" style="color:#FFFFFF;">HELP</a></td>
				</tr>
				<tr>
					<td><img src="../../../images/blank.gif" width="156" height="1" border="0"></td>
				</tr>
				<tr>
					<td align="right" valign="middle" class="navOn"><a href="faq_list.jsp" style="color:#FFFFFF;">FAQs</a></td>
				</tr>
				<tr>
					<td><img src="../../../images/blank.gif" width="156" height="1" border="0"></td>
				</tr>
				<tr>
					<td align="right" valign="middle" class="navOff"><a href="support_list.jsp" style="color:#FFFFFF;">SUPPORT</a></td>
				</tr>
			</table>
		</td>
		<td bgcolor="#FFFFFF"><img src="../../../images/blank.gif" width="1" height="1" border="0"></td>
		<td bgcolor="#333399"><img src="../../../images/blank.gif" width="15" height="1" border="0"></td>
		<td bgcolor="#333399" align="left" width="100%">
			<span style="font-size:20pt; color:#FFFFFF;">Frequently Asked Questions</span>
		</td>
	</tr>
	<tr>
		<td colspan="5" height="1" width="100%" bgcolor="#333399"><img src="../../images/blank.gif" width="1" height="1" border="0"></td>
	</tr>
		<td colspan="5" width="100%" height="100%" bgColor="#ffffff" align="center" valign="top">
			<table cellspacing="0" cellpadding="0" border="0" width="100%">
				<tr>
					<td align="left" valign="top"><img src="../../../images/blank.gif" width="25" height="1" border="0"></td>
					<td align="left" valign="top" width="100%">
						<table width="100%" height="100%" cellspacing="0" cellpadding="1">
							<tr>
								<td align="left" valign="top"><img src="../../../images/blank.gif" width="1" height="5" border="0"></td>
							</tr>
							<tr>
								<td align="left" valign="top" width="100%" height="50%">
									<a href="javascript:openPopup('faq_edit.jsp', 'PopUpEdit', '850', '400')"><img src="../../../images/newbutton.gif" border="0"></a>
									<div id="faqList" style="overflow:auto; width:100%; height:210px;">
									<table width="100%" cellspacing="0" cellpadding="1" border="0">
										<tbody id="headerRow">
										<tr>
											<th align="left" valign="middle" colspan="3" width="100%">&nbsp;</th>
											<th align="left" valign="middle" nowrap>Order</th>
											<th align="left" valign="middle" nowrap>Approved</th>
											<th align="left" valign="middle" nowrap>Edit</th>
											<th align="left" valign="middle" nowrap>Preview</th>
										</tr>
									<%
										String sSql = null;
										
										sSql =
											" select v.faq_id as 'VolumeID', v.display_heading as 'VolumeHeading', v.faq_order as 'VolumeOrder', v.approved_flag as 'VolumeApproved'," +
											" c.faq_id as 'ChapterID', c.display_heading as 'ChapterHeading', c.faq_order as 'ChapterOrder', c.approved_flag as 'ChapterApproved'," +
											" p.faq_id as 'PageID', p.display_heading as 'PageHeading', p.faq_order as 'PageOrder', p.approved_flag as 'PageApproved'" +
											" from chlp_faq v with(nolock)" +
											" left outer join chlp_faq c with(nolock) on v.faq_id = c.parent_faq_id" +
											" left outer join chlp_faq p with(nolock) on c.faq_id = p.parent_faq_id" +
											" where v.type_id = 201 or c.type_id = 202 or p.type_id = 203" +
											" order by 3, 7, 11";
								
										ConnectionPool cp = null;
										Connection conn = null;
										PreparedStatement pstmt = null;
										ResultSet rs = null;
									
										try
										{
											cp = ConnectionPool.getInstance();
											conn = cp.getConnection(this);
									
											try
											{
												pstmt = conn.prepareStatement(sSql);
												rs = pstmt.executeQuery();												
												String sVolumeID = null;
												String sVolumeHeading = null;
												String sVolumeOrder = null;
												String sVolumeApproved = null;															
												String sChapterID = null;
												String sChapterHeading = null;
												String sChapterOrder = null;
												String sChapterApproved = null;															
												String sPageID = null;
												String sPageHeading = null;
												String sPageOrder = null;
												String sPageApproved = null;
												
												String oldVolumeID = "newVolume";
												String newVolumeID = "newVolume";															
												String oldChapterID = "newChapter";
												String newChapterID = "newChapter";
									
												byte[] b = null;
												while (rs.next())
												{
													sVolumeID = rs.getString(1);																
													b = rs.getBytes(2);
													sVolumeHeading = (b==null)?null:new String(b, "ISO-8859-1");																
													sVolumeOrder  = rs.getString(3);
													sVolumeApproved  = rs.getString(4);
													
													sChapterID = rs.getString(5);																
													b = rs.getBytes(6);
													sChapterHeading = (b==null)?null:new String(b, "ISO-8859-1");																
													sChapterOrder  = rs.getString(7);
													sChapterApproved  = rs.getString(8);
													
													sPageID = rs.getString(9);																
													b = rs.getBytes(10);
													sPageHeading = (b==null)?null:new String(b, "ISO-8859-1");																
													sPageOrder  = rs.getString(11);
													sPageApproved  = rs.getString(12);
													
													newVolumeID = sVolumeHeading;

													newChapterID = sChapterHeading;
													
													if (newVolumeID.compareToIgnoreCase(oldVolumeID) == 0)
													{
														//nothing here
													}
													else
													{
														%>
										</tbody>
										<tr>
											<td colspan="6"><img src="../../../images/blank.gif" width="1" height="4" border="0"></td>
										</tr>
										<tr bgcolor="#31309C" style="cursor:hand;" onclick="showHideRow('row<%= sVolumeID %>');">
											<td align="left" valign="middle" width="100%" colspan="3" style="color:#FFFFFF; padding:2px;"><b><%= sVolumeHeading %>&nbsp;</b></td>
											<td align="left" valign="middle" style="color:#FFFFFF; padding:2px;"><%= sVolumeOrder %>&nbsp;</td>
											<td align="left" valign="middle" style="color:#FFFFFF; padding:2px;"><%= sVolumeApproved %>&nbsp;</td>
											<td align="left" valign="middle" style="color:#FFFFFF; padding:2px;"><a href="javascript:openPopup('faq_edit.jsp?faq_id=<%= sVolumeID %>', 'PopUpEdit', '900', '450');" style="color:#FFFFFF;">Edit</a></td>
											<td align="left" valign="middle" style="color:#FFFFFF; padding:2px;"><a href="javascript:openPopup('faq_preview.jsp?faq_id=<%= sVolumeID %>', 'PopUpPreview', '900', '450');" style="color:#FFFFFF;">Preview</a></td>
										</tr>
										<tbody id="row<%= sVolumeID %>">
														<%
														oldVolumeID = newVolumeID;
													}
													if (sChapterHeading != null)
													{
														if (newChapterID.compareToIgnoreCase(oldChapterID) == 0)
														{
															//nothing here
															if (sPageHeading != null)
															{
																%>
										<tr>
											<td align="left" valign="middle" width="15"><img src="../../../images/blank.gif" width="15" height="1" border="0"></td>
											<td align="left" valign="middle" width="15"><img src="../../../images/blank.gif" width="15" height="1" border="0"></td>
											<td align="left" valign="middle" width="100%"><%= sPageHeading %>&nbsp;</td>
											<td align="left" valign="middle"><%= sPageOrder %>&nbsp;</td>
											<td align="left" valign="middle"><%= sPageApproved %>&nbsp;</td>
											<td align="left" valign="middle"><a href="javascript:openPopup('faq_edit.jsp?faq_id=<%= sPageID %>', 'PopUpEdit', '900', '450');">Edit</a></td>
											<td align="left" valign="middle"><a href="javascript:openPopup('faq_preview.jsp?faq_id=<%= sPageID %>', 'PopUpPreview', '900', '450');">Preview</a></td>
										</tr>
																<%
															}
														}
														else
														{
															%>
										<tr>
											<td align="left" valign="middle" width="15"><img src="../../../images/blank.gif" width="15" height="1" border="0"></td>
											<td align="left" valign="middle" width="100%" bgcolor="#DEDEDE" colspan="2"><%= sChapterHeading %>&nbsp;</td>
											<td align="left" valign="middle" bgcolor="#DEDEDE"><%= sChapterOrder %>&nbsp;</td>
											<td align="left" valign="middle" bgcolor="#DEDEDE"><%= sChapterApproved %>&nbsp;</td>
											<td align="left" valign="middle" bgcolor="#DEDEDE"><a href="javascript:openPopup('faq_edit.jsp?faq_id=<%= sChapterID %>', 'PopUpEdit', '900', '450');">Edit</a></td>
											<td align="left" valign="middle" bgcolor="#DEDEDE"><a href="javascript:openPopup('faq_preview.jsp?faq_id=<%= sChapterID %>', 'PopUpPreview', '900', '450');">Preview</a></td>
										</tr>
															<% if (sPageHeading != null) { %>
										<tr>
											<td align="left" valign="middle" width="15"><img src="../../../images/blank.gif" width="15" height="1" border="0"></td>
											<td align="left" valign="middle" width="15"><img src="../../../images/blank.gif" width="15" height="1" border="0"></td>
											<td align="left" valign="middle" width="100%"><%= sPageHeading %>&nbsp;</td>
											<td align="left" valign="middle"><%= sPageOrder %>&nbsp;</td>
											<td align="left" valign="middle"><%= sPageApproved %>&nbsp;</td>
											<td align="left" valign="middle"><a href="javascript:openPopup('faq_edit.jsp?faq_id=<%= sPageID %>', 'PopUpEdit', '900', '450');">Edit</a></td>
											<td align="left" valign="middle"><a href="javascript:openPopup('faq_preview.jsp?faq_id=<%= sPageID %>', 'PopUpPreview', '900', '450');">Preview</a></td>
										</tr>
															<%
															}
															oldChapterID = newChapterID;
														}
													}																
												}
												rs.close();
											}
											catch(Exception ex)
											{
												throw new Exception(sSql+"\r\n"+ex.getMessage());
											}
											finally
											{
												if(pstmt != null) pstmt.close();
											}
										}
										catch(Exception ex)
										{
											throw ex;
										}
										finally
										{
											if(conn != null) cp.free(conn);
										}
									%>
										</tbody>
									</table>
									</div>
								</td>
							</tr>
							<tr>
								<td align="left" valign="top" width="100%"><img src="../../../images/blank.gif" width="1" height="5" border="0"></td>
							</tr>
							<tr>
								<td align="left" valign="top" width="100%" bgColor="#31319C"><img src="../../../images/blank.gif" width="1" height="1" border="0"></td>
							</tr>
							<tr>
								<td align="left" valign="top" width="100%"><img src="../../../images/blank.gif" width="1" height="5" border="0"></td>
							</tr>
							<tr>
								<td align="left" valign="top" width="100%" height="50%">
									<iframe src="faq_edit.jsp?faq_id=<%= faq_id %>" frameborder="0" id="frameEdit" name="frameEdit" width="100%" height="950"></iframe>
								</td>
							</tr>
							<tr>
								<td align="left" valign="top"><img src="../../../images/blank.gif" width="1" height="5" border="0"></td>
							</tr>
						</table>
					</td>
					<td align="left" valign="top"><img src="../../../images/blank.gif" width="25" height="1" border="0"></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
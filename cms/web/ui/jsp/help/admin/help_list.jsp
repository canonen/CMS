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

String help_doc_id = null;
help_doc_id = request.getParameter("help_doc_id");
%>
<html>
<head>
	<title>Help Doc Admin</title>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" type="text/css" href="../../../css/style.css">
	<script language="javascript">
				
		var curPopupWindow = null;
		var helpWindow = null;
		
		function openPopup(url, name, pWidth, pHeight)
		{
			closePopup();
			curPopupWindow = window.open(url, name, "left=100,top=100,width='+pWidth+',height='+pHeight+',toolbar=no,status=no,directories=no,menubar=no,resizable=yes,scrollbars=yes", false);
			curPopupWindow.focus();
			//document.getElementById("frameEdit").src = url;
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
			if (document.getElementById("row" + rowID).style.display == "none")
			{
				document.getElementById("row" + rowID).style.display = "";
				document.getElementById("link_" + rowID).innerText = "-";
			}
			else
			{
				document.getElementById("row" + rowID).style.display = "none";
				document.getElementById("link_" + rowID).innerText = "+";
			}
		}
		
	</script>
</head>
<body>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left" nowrap>
			<a class="newbutton" href="javascript:openPopup('help_edit.jsp', 'PopUpEdit', '800', '600')">New Help Document Entry</a>&nbsp;&nbsp;&nbsp;
		</td>
	</tr>
</table>
<br>
<table width=95% class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Help Document:</b> Administration</td>
	</tr>
</table>
<br>								
<table width=95% cellspacing="0" cellpadding="0" border="0">
	<tr>
		<td class="listHeading" valign="center" nowrap align="left">
				<table class="listTable" width="100%" cellspacing="0" cellpadding="2" border="0">
					<tbody id="headerRow">
					<tr>
						<th nowrap>&nbsp;</th>
						<th nowrap>Help Item</th>
						<th nowrap>Order</th>
						<th nowrap>Approved</th>
						<th nowrap>Preview</th>
					</tr>
				<%
					String sSql = null;
					
					sSql =
						" select v.help_doc_id as 'VolumeID', v.display_heading as 'VolumeHeading', v.help_order as 'VolumeOrder', v.approved_flag as 'VolumeApproved'," +
						" c.help_doc_id as 'ChapterID', c.display_heading as 'ChapterHeading', c.help_order as 'ChapterOrder', c.approved_flag as 'ChapterApproved'," +
						" p.help_doc_id as 'PageID', p.display_heading as 'PageHeading', p.help_order as 'PageOrder', p.approved_flag as 'PageApproved'" +
						" from chlp_help_doc v with(nolock)" +
						" left outer join chlp_help_doc c with(nolock) on v.help_doc_id = c.parent_help_doc_id" +
						" left outer join chlp_help_doc p with(nolock) on c.help_doc_id = p.parent_help_doc_id" +
						" where v.type_id = 101 or c.type_id = 102 or p.type_id = 103" +
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
							
							int volCount = 0;
							int pageCount = 0;
							String sClassAppend = "";
				
							byte[] b = null;
							while (rs.next())
							{
								if (volCount % 2 != 0) sClassAppend = "_Alt";
								else sClassAppend = "";
								
								++volCount;
								
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
										<td class="listItem_Data<%= sClassAppend %>"><a href="javascript:showHideRow('<%= sVolumeID %>');" id="link_<%= sVolumeID %>" class="resourcebutton" style="width:15px;text-align:center;">-</a></td>
										<td class="listItem_Title<%= sClassAppend %>"><a href="javascript:openPopup('help_edit.jsp?help_doc_id=<%= sVolumeID %>', 'PopUpEdit', '800', '600');"><%= sVolumeHeading %></a>&nbsp;</td>
										<td class="listItem_Data<%= sClassAppend %>"><%= sVolumeOrder %>&nbsp;</td>
										<td class="listItem_Data<%= sClassAppend %>"><%= sVolumeApproved %>&nbsp;</td>
										<td class="listItem_Data<%= sClassAppend %>"><a class="resourcebutton" href="javascript:openPopup('help_preview.jsp?help_doc_id=<%= sVolumeID %>', 'PopUpPreview', '800', '600');">Preview</a></td>
									</tr>
									<tbody id="row<%= sVolumeID %>">
									<%
									oldVolumeID = newVolumeID;
									if (pageCount % 2 != 0) sClassAppend = "_Alt";
									else sClassAppend = "";
									
									++pageCount;
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
												<td class="listItem_Data<%= sClassAppend %>" width="15">&nbsp;</td>
												<td class="listItemChild_Title<%= sClassAppend %>"><a href="javascript:openPopup('help_edit.jsp?help_doc_id=<%= sPageID %>', 'PopUpEdit', '800', '600');"><%= sPageHeading %></a>&nbsp;</td>
												<td class="listItemChild_Data<%= sClassAppend %>"><%= sPageOrder %>&nbsp;</td>
												<td class="listItemChild_Data<%= sClassAppend %>"><%= sPageApproved %>&nbsp;</td>
												<td class="listItemChild_Data<%= sClassAppend %>"><a class="resourcebutton" href="javascript:openPopup('help_preview.jsp?help_doc_id=<%= sPageID %>', 'PopUpPreview', '800', '600');">Preview</a></td>
											</tr>
											<%
										}
									}
									else
									{
										%>
										<tr>
											<td class="listGroup_Data" width="15">&nbsp;</td>
											<td class="listGroupChild_Title"><a href="javascript:openPopup('help_edit.jsp?help_doc_id=<%= sChapterID %>', 'PopUpEdit', '800', '600');"><%= sChapterHeading %></a>&nbsp;</td>
											<td class="listGroupChild_Data"><%= sChapterOrder %>&nbsp;</td>
											<td class="listGroupChild_Data"><%= sChapterApproved %>&nbsp;</td>
											<td class="listGroupChild_Data"><a class="resourcebutton" href="javascript:openPopup('help_preview.jsp?help_doc_id=<%= sChapterID %>', 'PopUpPreview', '800', '600');">Preview</a></td>
										</tr>
										<%
										pageCount = 0;
										sClassAppend = "";
										if (sPageHeading != null)
										{
											%>
											<tr>
												<td class="listItem_Data<%= sClassAppend %>" width="15">&nbsp;</td>
												<td class="listItemChild_Title<%= sClassAppend %>"><a href="javascript:openPopup('help_edit.jsp?help_doc_id=<%= sPageID %>', 'PopUpEdit', '800', '600');"><%= sPageHeading %></a>&nbsp;</td>
												<td class="listItemChild_Data<%= sClassAppend %>"><%= sPageOrder %>&nbsp;</td>
												<td class="listItemChild_Data<%= sClassAppend %>"><%= sPageApproved %>&nbsp;</td>
												<td class="listItemChild_Data<%= sClassAppend %>"><a class="resourcebutton" href="javascript:openPopup('help_preview.jsp?help_doc_id=<%= sPageID %>', 'PopUpPreview', '800', '600');">Preview</a></td>
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
</table>
</body>
</html>
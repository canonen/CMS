<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.w3c.dom.*"
	import="org.apache.log4j.*"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp" %>
<%
String faq_id = null;
faq_id = request.getParameter("faq_id");
%>
<html>
<head>
	<title>faq Doc Admin</title>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" type="text/css" href="../../css/style.css">
	<script language="javascript">

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
<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
	<col>
	<tr height="35">
		<td valign="top">
			<table cellpadding="4" cellspacing="0" border="0">
				<tr>
					<td vAlign="middle" align="left" nowrap>
						<a class="newbutton" href="faq_edit.jsp" target="main_01">New FAQ Entry</a>&nbsp;&nbsp;&nbsp;
					</td>
				</tr>
			</table>
			<br>
		</td>
	</tr>
	<tr>
		<td>
			<div style="width:100%; height:100%; overflow:auto;">
			<table class="listTable" width="100%" cellspacing="0" cellpadding="2" border="0">
				<tbody id="headerRow">
				<tr>
					<th nowrap>&nbsp;</th>
					<th nowrap>FAQ Item</th>
					<th nowrap>Order</th>
				</tr>
			<%
				String sSql = null;
				
				sSql =
					" select v.faq_id as 'VolumeID', v.display_heading as 'VolumeHeading', v.faq_order as 'VolumeOrder', v.approved_flag as 'VolumeApproved'," +
					" c.faq_id as 'ChapterID', c.display_heading as 'ChapterHeading', c.faq_order as 'ChapterOrder', c.approved_flag as 'ChapterApproved'," +
					" p.faq_id as 'PageID', p.display_heading as 'PageHeading', p.faq_order as 'PageOrder', p.approved_flag as 'PageApproved'" +
					" from shlp_faq v with(nolock)" +
					" left outer join shlp_faq c with(nolock) on v.faq_id = c.parent_faq_id" +
					" left outer join shlp_faq p with(nolock) on c.faq_id = p.parent_faq_id" +
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
						
						int volCount = 0;
						int pageCount = 0;
						String svolClassAppend = "";
						String spageClassAppend = "";

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
								if (volCount % 2 != 0) svolClassAppend = "_Alt";
								else svolClassAppend = "";
								
								++volCount;
								%>
								</tbody>
								<tr>
									<td class="listItem_Data<%= svolClassAppend %>"><a href="javascript:showHideRow('<%= sVolumeID %>');" id="link_<%= sVolumeID %>" class="resourcebutton" style="width:15px;text-align:center;">+</a></td>
									<td class="listItem_Title<%= svolClassAppend %>"><a href="faq_edit.jsp?faq_id=<%= sVolumeID %>" target="main_01"><%= sVolumeHeading %></a>&nbsp;</td>
									<td class="listItem_Data<%= svolClassAppend %>"><%= sVolumeOrder %>&nbsp;</td>
								</tr>
								<tbody id="row<%= sVolumeID %>" style="display:none;">
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
										if (pageCount % 2 != 0) spageClassAppend = "_Alt";
										else spageClassAppend = "";
										
										++pageCount;
										%>
										<tr>
											<td class="listItem_Data<%= spageClassAppend %>" width="15">&nbsp;</td>
											<td class="listItemChild_Title<%= spageClassAppend %>"><a href="faq_edit.jsp?faq_id=<%= sPageID %>" target="main_01"><%= sPageHeading %></a>&nbsp;</td>
											<td class="listItemChild_Data<%= spageClassAppend %>"><%= sPageOrder %>&nbsp;</td>
										</tr>
										<%
									}
								}
								else
								{
									%>
									<tr>
										<td class="listGroup_Data" width="15">&nbsp;</td>
										<td class="listGroupChild_Title"><a href="faq_edit.jsp?faq_id=<%= sChapterID %>" target="main_01"><%= sChapterHeading %></a>&nbsp;</td>
										<td class="listGroupChild_Data"><%= sChapterOrder %>&nbsp;</td>
									</tr>
									<%
									pageCount = 0;
									spageClassAppend = "";
									
									if (sPageHeading != null)
									{
										if (pageCount % 2 != 0) spageClassAppend = "_Alt";
										else spageClassAppend = "";
										
										++pageCount;
										%>
										<tr>
											<td class="listItem_Data<%= spageClassAppend %>" width="15">&nbsp;</td>
											<td class="listItemChild_Title<%= spageClassAppend %>"><a href="faq_edit.jsp?faq_id=<%= sPageID %>" target="main_01"><%= sPageHeading %></a>&nbsp;</td>
											<td class="listItemChild_Data<%= spageClassAppend %>"><%= sPageOrder %>&nbsp;</td>
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
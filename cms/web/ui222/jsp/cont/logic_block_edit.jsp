<%@ page
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="java.sql.*"
	import="java.io.*"
	import="javax.xml.transform.*"
	import="javax.xml.transform.stream.*"
	import="org.xml.sax.*"		
	import="org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

	if(!can.bRead)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}
	String logicID = request.getParameter("logic_id");
	if (!can.bWrite && logicID == null)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}
	String parentContID = request.getParameter("parent_cont_id");

	AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);
	
	ui.setSessionProperty("dynamic_elements_section", "1");

	// === === ===
	
	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;

	String logicName="",creator="",creationDate="",editor="",modifyDate="";
	String contIDList="0";

	String htmlContBlocks = "";
	String htmlFilterList = "";
	String htmlLogicBlocks = "";
	String htmlCategories = "";
	int nMaxSeq = 0;
	boolean defaultExists = false;
        String sMaxElementsInLogicBlock = request.getParameter("MaxElementsInLogicBlock");
        String sChildContId="", sChildContName="";
        int nSeq = -1;
        String tmpFilterID="", tmpFilterName="", htmlImg="";
        String tmpDefaultFlag="";

	// === === ===
	
	ConnectionPool cp	= null;
	Connection conn		= null;
	Statement stmt		= null;
	ResultSet rs		= null;
	String sSql = null;	
	
	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();

		if (logicID != null)
		{
			sSql =
				" SELECT cont_name," +
					" u1.user_name, isnull(convert(varchar(255),ei.create_date,100),'')," +
					" u2.user_name, isnull(convert(varchar(255),ei.modify_date,100),'') " +
				" FROM ccnt_content c, ccnt_cont_edit_info ei, ccps_user u1, ccps_user u2 " +
				" WHERE u1.user_id = ei.creator_id"+
					" AND u2.user_id = ei.modifier_id" +
					" AND c.cont_id = ei.cont_id " +
					" AND c.cust_id = " + cust.s_cust_id +
					" AND c.cont_id = " + logicID;
				   
			rs = stmt.executeQuery(sSql);
			if (rs.next())
			{
				logicName = new String(rs.getBytes(1),"UTF-8");;
				creator = rs.getString(2);
				creationDate = rs.getString(3);
				editor = rs.getString(4);
				modifyDate = rs.getString(5);
			}
			rs.close();
			
			// === === ===
			
			sSql =
				" SELECT c.cont_id, c.cont_name, l.seq, l.filter_id, l.default_flag," +
					" l.max_elements_in_logic_block, f.filter_name " +
				" FROM ccnt_cont_part l " +
					" INNER JOIN ccnt_content c ON l.child_cont_id = c.cont_id " +
					" LEFT OUTER JOIN ctgt_filter f ON l.filter_id = f.filter_id " +
				" WHERE l.parent_cont_id = " + logicID +
				" ORDER BY l.seq";

			rs = stmt.executeQuery(sSql);
			
			String sClassAppend = "";
			
			int count = 0;
			boolean notDone = rs.next();
			while (notDone)
			{
                                sChildContId="";
                                sChildContName="";
                                nSeq = -1;
                                tmpFilterID="";
                                tmpFilterName="";
                                htmlImg="";
                                tmpDefaultFlag="";

				if (count % 2 != 0) sClassAppend = "_Alt";
				else sClassAppend = "";

				++count;
				sChildContId = rs.getString(1);
				sChildContName = new String(rs.getBytes(2),"UTF-8");
				nSeq = rs.getInt(3);
 				tmpFilterID = rs.getString(4);
				tmpDefaultFlag = rs.getString(5);
                                // only display sMaxElementsInLogicBlock for the first sequence number.
                                if (nSeq == 1) {   
                                    sMaxElementsInLogicBlock = rs.getString(6);
                                    if (sMaxElementsInLogicBlock == null || sMaxElementsInLogicBlock.length()== 0)  {
                                        sMaxElementsInLogicBlock = "0";
                                    } 
                                }
				
				if(nMaxSeq < nSeq) nMaxSeq = nSeq; 
				
				if (tmpDefaultFlag != null && tmpDefaultFlag.equals("1"))
				{
					tmpFilterID = "-1";
					tmpFilterName = "**** Used As Default ****";
					defaultExists = true;
				}
				else
				{
					byte [] b = rs.getBytes(7);
					tmpFilterName = (b!=null)?new String(b,"UTF-8"):"";
				}
				
				notDone = rs.next();
				if (count == 1 && !notDone)
				{
					htmlImg = "";
				}
				else if (count == 1)
				{
					htmlImg = "  <a class=\"subactionbutton\" href=\"javascript:SubmitPrepare('1','4','"+sChildContId+"','"+tmpFilterID+"','"+nSeq+"')\">down</a>&nbsp;&nbsp;\n";
				}
				else if (!notDone)
				{
 					htmlImg = "  <a class=\"subactionbutton\" href=\"javascript:SubmitPrepare('1','3','"+sChildContId+"','"+tmpFilterID+"','"+nSeq+"')\">up</a>&nbsp;&nbsp;\n";
				}
				else
				{
					htmlImg =
						"  <a class=\"subactionbutton\" href=\"javascript:SubmitPrepare('1','3','"+sChildContId+"','"+tmpFilterID+"','"+nSeq+"')\">up</a>&nbsp;&nbsp;|&nbsp;&nbsp;\n" +
						"  <a class=\"subactionbutton\" href=\"javascript:SubmitPrepare('1','4','"+sChildContId+"','"+tmpFilterID+"','"+nSeq+"')\">down</a>&nbsp;&nbsp;\n";
				}
                                
 				htmlLogicBlocks +=
					"<tr>\n" +
					"  <td align=\"center\" class=\"listItem_Data" + sClassAppend + "\" nowrap>\n&nbsp;&nbsp;" + htmlImg +
					"  &nbsp;&nbsp;</td>\n" +
					"  <td align=left class=\"listItem_Data" + sClassAppend + "\" width=\"50%\"><a href=\"javascript:SubmitBlock('3','0','0','0','0','"+sChildContId+"')\">"+sChildContName+"</a></td>"+
					"  <td align=left class=\"listItem_Data" + sClassAppend + "\" width=\"50%\">"+(!("-1".equals(tmpFilterID))?("<a href=\"javascript:SubmitFilter('4','0','0','0','0','"+tmpFilterID+"')\">"+tmpFilterName+"</a>"):tmpFilterName)+"</td>\n" +
					"  <td align=\"center\" class=\"listItem_Data" + sClassAppend + "\" nowrap>&nbsp;&nbsp;"+((can.bWrite)?"<a class=\"resourcebutton\" href=\"javascript:SubmitPrepare('1','2','"+sChildContId+"','"+tmpFilterID+"','"+nSeq+"');\">Delete</a>":"")+"&nbsp;&nbsp;</td>\n" +
					"</tr>\n";
					
				contIDList += ","+sChildContId;
			}
			rs.close();
		}
		else
		{
			logicName = "New Logic Block";
		}

		// === === ===
		
		String oldContBlockID = request.getParameter("cont_id");
		htmlContBlocks = getContBlockOptions(cust.s_cust_id, oldContBlockID, sSelectedCategoryId, stmt);
		
		String oldFilterID = request.getParameter("filter_id");
		htmlFilterList = getFilterOptions(cust.s_cust_id, oldFilterID, stmt);
		
		htmlCategories = getCategoryOptions(cust.s_cust_id, logicID, sSelectedCategoryId, stmt);
	}
	catch(Exception ex)
	{
		ErrLog.put(this,ex,"cont_edit.jsp",out,1);
		return;
	}
	finally
	{
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}
%>


<html>
<head>
<title>Logic Block</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>
<SCRIPT LANGUAGE="JAVASCRIPT">
<%@ include file="../../js/scripts.js" %>

function SubmitBlock(Act, method, contID, filterID, seq, blockID)
{
	FT.destContID.value = blockID;
 	SubmitPrepare(Act, method, contID, filterID, seq);
}

function SubmitFilter(Act, method, contID, filterID, seq, destFilterID)
{
	FT.destFilterID.value = destFilterID;
	SubmitPrepare(Act, method, contID, filterID, seq);
}

function SubmitPrepare(Act, method, contID, filterID, seq)
{
	if (FT.LogicName.value.length < 1)
	{
		alert("Please enter a name for your logic block.");
		return;
	}
	
	if (method == 1)
	{
		if (FT.contBlocks.value == 'null')
		{
			alert("You must select a Content Element.  Either choose a content element or create a new content element.");
			return;
		}
		if (FT.filter_id.value == 'null')
		{
			alert("You must select a Content Element.  Either choose a logic element or create a new logic element.");
			return;
		}
	}
        if (FT.MaxElementsInLogicBlock.value < 0)
        {
            alert("Maximum elements to be delivered for this content block must be zero or greater");
            return;
        }

	FT.ActionSave.value = Act;
	FT.method.value = method;
	FT.contID.value = contID;
	FT.filterID.value = filterID;
	FT.seq.value = seq;
        
	FT.submit();
}

</SCRIPT>
<script language="javascript" src="../../js/tab_script.js"></script>

<body<%= (!can.bWrite)?" onload='disable_forms()'":" " %>>
<form name="FT" method="post" action="logic_block_save.jsp">
<% if(sSelectedCategoryId!=null) { %>
	<INPUT type="hidden" name="category_id" value="<%=sSelectedCategoryId%>">
<% } %>

<!-- Logic ID -->
<input type="hidden" name="logicID" value=<%= logicID %>>

<input type="hidden" name="ActionSave" value="0"/>
<input type="hidden" name="method" value="0"/>
<input type="hidden" name="contID" value="0"/>
<input type="hidden" name="parentContID" value="<%=(parentContID!=null)?parentContID:""%>"/>
<input type="hidden" name="destContID" value=""/>
<input type="hidden" name="destFilterID" value=""/>
<input type="hidden" name="filterID" value="0"/>
<input type="hidden" name="seq" value="0"/>  
<input type="hidden" name="next_seq" value="<%=(nMaxSeq+1)%>"/>

<%
if (can.bWrite)
{
	%>
<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td vAlign="middle" align="left">
                        <a class="savebutton" href="#" onclick="SubmitPrepare('1','0','0','0','0');">Save</a>&nbsp;&nbsp;
		</td>
	<%
	if (logicID != null)
	{
		%>
		<td vAlign="middle" align="left">
			<a class="savebutton" href="#" onclick="SubmitPrepare('2','0','0','0','0');">Clone</a>&nbsp;&nbsp;
		</td>
		<%
	}
	
	if (can.bDelete && logicID != null)
	{
		%>
		<td vAlign="middle" align="left">
			<a class="deletebutton" href="#" onclick="location.href='logic_block_delete.jsp?logic_id=<%= logicID %>'">Delete</a>&nbsp;&nbsp;
		</td>
	<%
	}
	%>
	</tr>
</table>
<br>
<%
}
%>

<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 1:</b> Name Your Logic Block</td>
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
		<td class=fillTab valign=top align=center width=650 colspan=3>
			<table class=main cellspacing=1 cellpadding=2 width="100%">
				<tr>
					<td width="150">Logic Block Name</td>
					<td width="475">
						<input type="text" name="LogicName" width="100%" size="56" Value="<%= logicName %>">
					</td>
				</tr>
				<tr<%=!canCat.bRead?" style=\"display:'none'\"":""%>> 
					<td width="150"> Categories</td>
					<td width="475" align="left">
						<SELECT multiple name="categories"<%=!canCat.bExecute?" disabled":""%> size="6" width="50%">
							<%= htmlCategories %>
						</SELECT>
						<%=(!canCat.bExecute && (sSelectedCategoryId != null) && !(sSelectedCategoryId.equals("0")))
						?"<INPUT type=hidden name=\"categories\" value=\""+sSelectedCategoryId+"\">"
						:""%>
					</td>
				</tr>
                                <tr>
                                    <td width="150">
                                            Maximum content elements to be delivered for this logic block (zero means all)
                                    </td>
                                    <td width="475" align="left">
                                            <input type="text"   name="MaxElementsInLogicBlock" size=22 value="<%=sMaxElementsInLogicBlock%>">
                                    </td>
                               </tr>
			</table>
		</td>
	</tr>
        
<br><br>

<!--- Step 2 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 2:</b> Select Content Element / Logic Element Pairs</td>
	</tr>
</table>
<br>
<!---- Step 2 Info----->
<table id="Tabs_Table2" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block2_Step1>
	<tr>
		<td class=fillTab valign=top align=left width=650>
			<p><a class="newbutton" href="javascript:SubmitBlock('3','0','0','0','0','')">New Content Element</a>&nbsp;&nbsp;&nbsp;
			<a class="newbutton" href="javascript:SubmitFilter('4','0','0','0','0','')">New Logic Element</a>&nbsp;&nbsp;&nbsp;</p>
			<table class="listTable" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<th><b>Add a New Content Element / Logic Element Pair</b></th>
				</tr>
				<tr>
					<td align="left" valign="top">
						<table cellpadding="2" cellspacing="0" border="0">
							<tr>
								<td nowrap>Content Element: </td>
								<td>
									<select name=contBlocks size=1>
										<%= htmlContBlocks %>
									</select>
								</td>
								<td rowspan="2">
								<%
								if (can.bWrite)
								{
									%>
									<a class="subactionbutton" href="javascript:SubmitPrepare('1','1',FT.contBlocks.options[FT.contBlocks.selectedIndex].value,FT.filter_id.options[FT.filter_id.selectedIndex].value,'0');">Add Combination</a>
									<%
								}
								%>
								</td>
							</tr>
							<tr>
								<td nowrap>Logic Element: </td>
								<td>
									<select NAME="filter_id" SIZE="1">
										<OPTION SELECTED VALUE="null">-------Select Logic Element-------</OPTION>
										<%= (defaultExists)?"":"<OPTION VALUE=\"-1\">**** Selected Content Block As Default ****</OPTION>" %>
										<%= htmlFilterList %>
									</select>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			<br>
			<table class="listTable" width="100%" cellpadding="2" cellspacing="0">
				<tr>
					<th colspan="4"><b>Current Content Element / Logic Element Pairs</b></th>
				</tr>
				<tr>
					<td class="subsectionheader" nowrap>&nbsp;</td>
					<td class="subsectionheader" width="50%">Content Element</td>
					<td class="subsectionheader" width="50%">Logic Element</td>
					<td class="subsectionheader" nowrap>&nbsp;</td>
				</tr>
				<%= htmlLogicBlocks %>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br/><Br/>

<!-- History Info -->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>History</b></td>
	</tr>
</table>
<br>
<table class="main" cellspacing="1" cellpadding="3" width="650" border="0">
	<tr>
		<td class="CampHeader"><b>Created by</b></td>
		<td><%= creator %></td>
		<td class="CampHeader"><b>Last Modified by</b></td>
		<td><%= editor %></td>
	</tr>
	<tr>
		<td class="CampHeader"><b>Creation date</b></td>
		<td><%= creationDate %></td>
		<td class="CampHeader"><b>Last Modify date</b></td>
		<td><%= modifyDate %></td>
	</tr>
</table>
<br><br>
</body>
</html>

<%!
private String getFilterOptions(String sCustId, String oldFilterID, Statement stmt)
	throws Exception
{
	String sFilterOptions = "";
	String sSql = 
		" SELECT filter_id, filter_name " +
		" FROM ctgt_filter" +
		" WHERE cust_id = " + sCustId +
			" AND origin_filter_id IS NULL " +
			" AND filter_name IS NOT NULL " +
			" AND type_id = 0 " +
			" AND status_id < " + FilterStatus.DELETED +
			" AND usage_type_id = " + FilterUsageType.CONTENT +
		" ORDER BY filter_name";
	
	ResultSet rs = stmt.executeQuery(sSql);

	String sFilterID = null;
	String sFilterName = null;	
	while (rs.next())
	{
		sFilterID = rs.getString(1);
		sFilterName = new String(rs.getBytes(2),"UTF-8");
		if (sFilterID.equals(oldFilterID))
		{
			sFilterOptions += "<option selected value=" + sFilterID + ">" + sFilterName + "</option>\r\n";				
		}
		else
		{
			sFilterOptions += "<option value=" + sFilterID + ">" + sFilterName + "</option>\r\n";
		}
	}

	rs.close();
	
	return sFilterOptions;
}

private String getContBlockOptions(String sCustId, String oldContBlockID, String sSelectedCategoryId, Statement stmt)
	throws Exception
{
	String htmlContBlocks = "";
	
	if (oldContBlockID == null) oldContBlockID = "";
	
	String sSql = null;
	
	if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) )
	{
		sSql =			
			" SELECT cont_id, cont_name FROM ccnt_content" +
			" WHERE cust_id = " + sCustId +
				" AND type_id = 30 AND status_id = 20" +
				" AND origin_cont_id IS NULL" +
			" ORDER BY cont_name";
	}
	else
	{
		sSql =			
			" SELECT c.cont_id, c.cont_name" +
			" FROM ccnt_content c, ccps_object_category oc" +
			" WHERE c.cust_id = " + sCustId +
				" AND c.type_id = 30 AND c.status_id = 20" +
				" AND c.origin_cont_id IS NULL" +
				" AND c.cont_id = oc.object_id" +
				" AND oc.type_id = " + ObjectType.CONTENT +
				" AND oc.cust_id = " + sCustId +
				" AND oc.category_id = " + sSelectedCategoryId +
			" ORDER BY c.cont_name";
	}

	String contBlockID = null;
	String contBlockName = null;
	
	ResultSet rs = stmt.executeQuery(sSql);
	while (rs.next())
	{
		contBlockID = rs.getString(1);
		contBlockName = new String(rs.getBytes(2),"UTF-8");;
		
		htmlContBlocks +=
			"<option "+(oldContBlockID.equals(contBlockID)?"selected ":" ")+"value="+contBlockID+">"+contBlockName+"</option>\n";
	}
	
	if (htmlContBlocks.length() == 0)
		htmlContBlocks += "<option value=\"null\">***No Ready Content Blocks***</option>\n";
	
	return htmlContBlocks;
}

private String getCategoryOptions(String sCustId, String logicID, String sSelectedCategoryId, Statement stmt)
	throws Exception
{
	String htmlCategories = "";

	String sSql =
		" SELECT c.category_id, c.category_name, oc.object_id" +
		" FROM ccps_category c" +
			" LEFT OUTER JOIN ccps_object_category oc" +
			" ON (c.category_id = oc.category_id" +
				" AND c.cust_id = oc.cust_id" +
				" AND oc.object_id="+logicID+
				" AND oc.type_id="+ObjectType.CONTENT+")" +
		" WHERE c.cust_id="+sCustId;

	ResultSet rs = stmt.executeQuery(sSql);
	
	String sCategoryId = null;
	String sCategoryName = null;
	String sObjectId = null;
		
	while (rs.next())
	{
		sCategoryId = rs.getString(1);
		sCategoryName = new String(rs.getBytes(2), "UTF-8");
		sObjectId = rs.getString(3);
	
		htmlCategories +=
			"<OPTION value=\""+sCategoryId+"\" "+(((sObjectId!=null)||((sSelectedCategoryId!=null)&&(sSelectedCategoryId.equals(sCategoryId))))?"selected":"")+">" +
				sCategoryName+
			"</OPTION>";
	}
	rs.close();
	
	return htmlCategories;
}
%>
<%@ page
		language="java"
		import="com.britemoon.cps.*,
			com.britemoon.*,
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

	AccessPermission can = user.getAccessPermission(ObjectType.IMPORT);

	if(!can.bRead)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}

	AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;

	String sBatchID = request.getParameter("batch_id");

	int nBatchID = Integer.parseInt((sBatchID == null)?"0":sBatchID);

	boolean bCanExecute = can.bExecute;
	boolean bCanWrite = (can.bWrite || bCanExecute);

//UI Type
	boolean bStandardUI = (ui.n_ui_type_id == UIType.STANDARD);

// Connection
	ConnectionPool	cp = null;
	Connection		conn = null;
	Statement		stmt = null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();

		//Categories
		String sSql  =
				" select c.category_id, c.category_name" +
						" FROM ccps_category c" +
						" WHERE c.cust_id="+cust.s_cust_id;
		ResultSet rs = stmt.executeQuery(sSql);

		String sCategoryId = null;
		String sCategoryName = null;
		String htmlCategories = "";

		while (rs.next())
		{
			sCategoryId = rs.getString(1);
			sCategoryName = new String(rs.getBytes(2), "UTF-8");

			htmlCategories +=
					"<option value=\""+sCategoryId+"\""+(((sSelectedCategoryId!=null)&&(sSelectedCategoryId.equals(sCategoryId)))?" selectED":"")+">" +
							sCategoryName+
							"</option>";
		}
		rs.close();
%>
<HTML>
<HEAD>
	<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
	<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
	<%@ include file="../header.html" %>

	<c:set var="loc" value="en_US"/>
	<c:if test="${!(empty param.locale)}">
		<c:set var="loc" value="${param.locale}"/>
	</c:if>
	<fmt:setLocale value="${loc}" />

	<fmt:bundle basename="app">

	<link rel="stylesheet" href="<%=ui.s_css_filename%>" type="text/css">
	<script language="javascript" src="../../js/tab_script.js" type="text/javascript"></script>
</HEAD>
<BODY>
<FORM  METHOD="POST" name="FT" ENCtype="multipart/form-data" ACTION="import_mapping.jsp" TARGET="_self">
	<%=(sSelectedCategoryId!=null)?"<input type=\"hidden\" name=\"category_id\" value=\""+sSelectedCategoryId+"\">":""%>
	<input type="hidden" name="batch_id" value="null">
	<input type="hidden" name="batch_type" value="1">
	<input type="hidden" name="fields" value="">
	<input type="hidden" name="newsletters" value="">
	<input type="hidden" name="categorytemp" value="">
	<input type="hidden" name="row" value="2">
	<input type="hidden" name="delimiter" value="\t">
	<input type="hidden" name="multi_value_delimiter" value="">
	<input type="hidden" name="upd_rule_id" value="<%=UpdateRule.OVERWRITE_IGNORE_BLANKS%>">
	<input type="hidden" name="upd_hierarchy_id" value="100">

	<input type="hidden" name="email_type_flag" value="0">
	<input type="hidden" name="full_name_flag" value="1">

	<!--- Step 1 Header----->
	<table width=650 class=listTable cellspacing=0 cellpadding=0>
		<tr>
			<th colspan=3 class=sectionheader>&nbsp;<b class=sectionheader>Step 1:</b> <fmt:message key="header_im_step_1"/></th>
		</tr>

		<% if (!bStandardUI) { %>
		<tr>
			<td class=Tab_ON id=tab1_Step1 width=150 onclick="toggleTabs('tab1_Step','block1_Step',1,2,'Tab_ON','Tab_OFF');" valign=center nowrap align=middle><b><fmt:message key="header_im_step_1_gen_info"/></b></td>
			<td class=Tab_OFF id=tab1_Step2 width=150 onclick="toggleTabs('tab1_Step','block1_Step',2,2,'Tab_ON','Tab_OFF');" valign=center nowrap align=middle><b>Processing Details</b></td>
			<td valign=center nowrap align=middle width=350><img height=2 src="../../images/blank.gif" width=1></td>
		</tr>
		<% } else { %>

		<% } %>
		<tbody class=EditBlock id=block1_Step1>
		<tr>
			<td valign=top align=center width=650 colspan=3>
				<table cellspacing=0 cellpadding=2 width="100%">
					<tr>
						<td width="150"><fmt:message key="header_im_step_1_gen_inf_im_name"/></td>
						<td><input type="text" name="import_name" size="40" MAXLENGTH="40" <%=(!bCanWrite)?"disabled":""%>></td>
					</tr>
					<tr<%=!canCat.bRead?" style=\"display:'none'\"":""%>>

						<td width="150"><fmt:message key="header_im_step_1_gen_info_cat"/></td>

						<td><select multiple name="categories"<%=!canCat.bExecute?" disabled":""%> size="5" width="100">
							<%= htmlCategories %>
						</select>
							<%=(!canCat.bExecute && (sSelectedCategoryId != null) && !(sSelectedCategoryId.equals("0")))
									?"<input type=hidden name=\"categories\" value=\""+sSelectedCategoryId+"\">"
									:""%>
						</td>
					</tr>
					<tr>
						<td width="150"><input type="radio" name="r1" CHECKED onClick="r1.checked=true; r2.checked=false;"
								<%=(!bCanWrite)?"disabled":""%>><fmt:message key="header_im_step_1_gen_info_new_batch"/></td>
						<td><input type="text" name="batch_name" size="40" MAXLENGTH="40" value=""
								<%=(!bCanWrite)?"disabled":""%> onClick="r1.checked=true; r2.checked=false;">
						</td>
					</tr>
					<tr>
						<td width="150"><input type="radio" name="r2" onClick="r2.checked=true; r1.checked=false;"
								<%=(!bCanWrite)?"disabled":""%>><fmt:message key="header_im_step_1_gen_info_choose_batch"/></td>
						<td>
							<select name="id" size="1"  <%=(!bCanWrite)?"disabled":""%> onClick="r2.checked=true; r1.checked=false;" onchange="fillImportValues();">
								<option selected value="0">&lt; --- --- --- Choose batch --- --- ---&gt;</option>
								<%
									if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) ) {
										rs = stmt.executeQuery(
												"select b.batch_id, b.batch_name, i.first_row, i.field_separator," +
														" i.upd_rule_id, i.upd_hierarchy_id, i.import_id, ISNULL(i.full_name_flag,1), i.multi_value_field_separator " +
														" FROM cupd_batch b, cupd_import i" +
														" WHERE b.type_id = 1" +
														" AND b.batch_id IN" +
														" (select DISTINCT i.batch_id" +
														" FROM cupd_import i, cupd_batch b" +
														" WHERE i.status_id = " + UpdateStatus.COMMIT_COMPLETE +
														" AND i.batch_id = b.batch_id" +
														" AND b.cust_id = " + cust.s_cust_id + ")" +
														" AND i.batch_id = b.batch_id" +
														" AND i.import_date = (select MAX(import_date) FROM cupd_import WHERE batch_id = b.batch_id AND status_id = "+UpdateStatus.COMMIT_COMPLETE+")"+
														" AND b.cust_id = " + cust.s_cust_id +
														" ORDER BY b.batch_id DESC");
									} else {
										rs = stmt.executeQuery(
												"select b.batch_id, b.batch_name, i.first_row, i.field_separator," +
														" i.upd_rule_id, i.upd_hierarchy_id, i.import_id, ISNULL(i.full_name_flag,1), i.multi_value_field_separator " +
														" FROM cupd_batch b, cupd_import i" +
														" WHERE b.type_id = 1" +
														" AND b.batch_id IN" +
														" (select DISTINCT i.batch_id" +
														" FROM cupd_import i, cupd_batch b, ccps_object_category oc" +
														" WHERE i.status_id = "+UpdateStatus.COMMIT_COMPLETE+
														" AND i.batch_id = b.batch_id" +
														" AND b.cust_id = " + cust.s_cust_id +
														" AND oc.object_id = i.import_id" +
														" AND oc.type_id = " + ObjectType.IMPORT +
														" AND oc.cust_id = " + cust.s_cust_id +
														" AND oc.category_id = " + sSelectedCategoryId + ")" +
														" AND i.batch_id = b.batch_id" +
														" AND i.import_date = (select MAX(import_date) FROM cupd_import WHERE batch_id = b.batch_id AND status_id = "+UpdateStatus.COMMIT_COMPLETE+")"+
														" AND b.cust_id = " + cust.s_cust_id +
														" ORDER BY b.batch_id DESC");
									}

									String fillFuncText = "";
									int batchID, firstRow, priorityID, hierarchyID;
									String delimiter, fileType, multiValueDelimiter;
									int selectedimportID = 0;
									int fullNameFlag = 1;

									while( rs.next() )
									{
										batchID = rs.getInt(1);
								%>
								<option value="<%=batchID%>"> <%=rs.getString(2)%> </option>
								<%
										fillFuncText += "if (batchID == "+batchID+") {\n";

										firstRow = rs.getInt(3);
										fillFuncText += "FT.row.value = "+firstRow+";\n";
										if (firstRow == 1) {
											fillFuncText += "FT.db1.checked=true;\n" +
													"FT.db2.checked=false;\n";
										} else {
											fillFuncText += "FT.db1.checked=false;\n" +
													"FT.db2.checked=true;\n";
										}

										delimiter = rs.getString(4);
										if (delimiter.equals("\\t")) {
											fillFuncText += "checkDelimiter(FT.rr4, '\\"+delimiter+"');\n";
										} else if (delimiter.equals("|")) {
											fillFuncText += "checkDelimiter(FT.rr3, '"+delimiter+"');\n";
										} else if (delimiter.equals(",")) {
											fillFuncText += "checkDelimiter(FT.rr2, '"+delimiter+"');\n";
										} else if (delimiter.equals(";")) {
											fillFuncText += "checkDelimiter(FT.rr1, '"+delimiter+"');\n";
										}

										priorityID = rs.getInt(5);
										if (priorityID == UpdateRule.DISCARD_DUPLICATES) {
											fillFuncText += "checkPriority(FT.pr1, "+priorityID+");\n";
										} else if (priorityID == UpdateRule.INSERT_ONLY_NEW_FIELDS) {
											fillFuncText += "checkPriority(FT.pr2, "+priorityID+");\n";
										} else if (priorityID == UpdateRule.OVERWRITE_IGNORE_BLANKS) {
											fillFuncText += "checkPriority(FT.pr3, "+priorityID+");\n";
										} else if (priorityID == UpdateRule.OVERWRITE_WITH_BLANKS) {
											fillFuncText += "checkPriority(FT.pr4, "+priorityID+");\n";
										}

										hierarchyID = rs.getInt(6);
										if (cust.m_Customers != null) {
											if (hierarchyID == 100) { // SINGLE
												fillFuncText += "checkHierarchy(FT.hr1, "+hierarchyID+");\n";
											} else if (hierarchyID == 200) { // DOWN
												fillFuncText += "checkHierarchy(FT.hr2, "+hierarchyID+");\n";
											}
										}

										if (batchID == nBatchID)
											selectedimportID = rs.getInt(7);

										fullNameFlag = rs.getInt(8);
										if (fullNameFlag == 0) {
											fillFuncText += "FT.fn.checked=false;\n";
										} else {
											fillFuncText += "FT.fn.checked=true;\n";
										}

										multiValueDelimiter = rs.getString(9);
										multiValueDelimiter = (multiValueDelimiter!=null)?multiValueDelimiter:"";
										if (multiValueDelimiter.equals("\\t")) {
											fillFuncText += "checkMultiValueDelimiter(FT.mvr4, '\\"+multiValueDelimiter+"');\n";
										} else if (multiValueDelimiter.equals("|")) {
											fillFuncText += "checkMultiValueDelimiter(FT.mvr3, '"+multiValueDelimiter+"');\n";
										} else if (multiValueDelimiter.equals(",")) {
											fillFuncText += "checkMultiValueDelimiter(FT.mvr2, '"+multiValueDelimiter+"');\n";
										} else if (multiValueDelimiter.equals(";")) {
											fillFuncText += "checkMultiValueDelimiter(FT.mvr1, '"+multiValueDelimiter+"');\n";
										} else if (multiValueDelimiter.equals("")) {
											fillFuncText += "checkMultiValueDelimiter(FT.mvr0, '"+multiValueDelimiter+"');\n";
										}

										fillFuncText +=	"\n}\n\n";

									}
									rs.close();

									int i,j;
									String p1,p2,p3;

									if (selectedimportID != 0)
									{
										fillFuncText += "if (batchID == "+nBatchID+") {\n";
										fillFuncText += "for(var i=0; i < FT.source.options.length; ++i) FT.source.options[i] = null;\n" +
												"for(var k=0; k < FT.target.options.length; ++k) FT.target.options[k] = null;\n";

										i = 0;
										j = 0;

										rs = stmt.executeQuery(	" SELECT c.display_name, a.attr_id,"+
												" isnull(c.fingerprint_seq,0), f.attr_id " +
												" FROM ccps_cust_attr c" +
												" INNER JOIN (ccps_attribute a" +
												" LEFT OUTER JOIN cupd_fields_mapping f" +
												" ON a.attr_id = f.attr_id" +
												" AND f.import_id = "+selectedimportID+")" +
												" ON a.attr_id = c.attr_id" +
												" WHERE c.cust_id = " + cust.s_cust_id +
												" AND c.display_seq IS NOT NULL " +
												" ORDER BY f.seq, c.display_seq");

										while( rs.next() )
										{
											p1 = new String(rs.getBytes(1), "UTF-8");
											p2 = rs.getString(2);
											p3 = rs.getString(3);

											if( p3.equals("0") && rs.getString(4) == null)
											{
												fillFuncText += "FT.source.options["+i+"] = new Option(\""+p1+"\", "+p2+");\n";
//								"FT.source.options["+i+"].type = "+p3+";\n";		
												++i;
											}
											else
											{
												fillFuncText += "FT.target.options["+j+"] = new Option(\""+p1+"\", "+p2+");\n" +
														"FT.target.options["+j+"].type = "+p3+";\n";
												++j;
											}
										}
										rs.close();
										fillFuncText += "return;\n}\n\n";
									}
								%>
							</select>
						</td>
					</tr>
					<tr>
						<td width="150">Newsletters</td>
						<td>
							<table cellspacing="0" cellpadding="2" border="0">
								<tr>
									<%
										int iNL = 0;
										rs = stmt.executeQuery(
												"SELECT c.attr_id, ISNULL(c.display_name, a.attr_name)"+
														" FROM ccps_cust_attr c, ccps_attribute a"+
														" WHERE c.attr_id = a.attr_id"+
														" AND c.cust_id = "+cust.s_cust_id+
														" AND c.newsletter_flag IS NOT NULL"+
														" ORDER BY c.display_seq");

										while (rs.next())
										{
											if (iNL == 2)
											{
									%>
								</tr>
								<tr>
									<%
											iNL = 0;
										}

										String sNlAttrId = rs.getString(1);
										String sNlName = new String(rs.getBytes(2), "UTF-8");
									%>
									<td><input type="checkbox" name="nl" id="nl_<%=sNlAttrId%>" value="<%=sNlAttrId%>" onclick="checkNewsletters();"<%=(!bCanWrite)?" disabled":""%>><label for="nl_<%=sNlAttrId%>">&nbsp;<%=sNlName%></label></td>
									<%
											iNL++;
										}
										rs.close();
									%>
								</tr>
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		</tbody>
		<tbody class=EditBlock id=block1_Step2 style="display:none;">
		<tr>
			<td valign=top align=center width=650 colspan=3>
				<table cellspacing=0 cellpadding=2 width="100%">
					<tr>
						<td width="150" valign="middle" align="right" rowspan="4">
							<P align="left">Import Rules</td>
						<td width="425" valign="middle" align="right" height="25%">
							<P align="left">
								<input type="radio" name="pr1" onClick="checkPriority(this, <%=UpdateRule.DISCARD_DUPLICATES%>)">
								Insert only new recipients discarding duplicates from import.
						</td>
					</tr>
					<tr>
						<td width="425" valign="middle" align="right" height="25%">
							<P align="left"><input type="radio" name="pr2" onClick="checkPriority(this, <%=UpdateRule.INSERT_ONLY_NEW_FIELDS%>)">
								Insert only new fields not overwriting existing recipient data.
						</td>
					</tr>
					<tr>
						<td width="425" valign="middle" align="right" height="25%">
							<P align="left">
								<input type="radio" name="pr3" onClick="checkPriority(this, <%=UpdateRule.OVERWRITE_IGNORE_BLANKS%>)" checked>
								Update duplicates ignoring blank import fields.
						</td>
					</tr>
					<tr>
						<td width="425" valign="middle" align="right" height="25%">
							<P align="left">
								<input type="radio" name="pr4" onClick="checkPriority(this, <%=UpdateRule.OVERWRITE_WITH_BLANKS%>)">
								Update duplicates including blank import fields.
						</td>
					</tr>
				</table>
				<br>
				<table cellspacing=0 cellpadding=2 width="100%">
					<tr>
						<td width="150" valign="middle" align="right" rowspan="4">
							<P align="left">Full Name Processing
						</td>
						<td width="425" valign="middle" align="right" height="25%">
							<P align="left">
								<input type="checkbox" name="fn" value="1"<%=bStandardUI?"":" checked"%>>
								Calculate recipient full name. (Increases commit processing time)
						</td>
					</tr>
				</table>
				<%
					if (cust.m_Customers != null)
					{
				%>
				<br>
				<table cellspacing=0 cellpadding=2 width="100%">
					<tr>
						<td width="150" valign="middle" align="right" rowspan="2">
							<P align="left">Import Hierarchy</td>
						<td width="425" valign="middle" align="right" height="25%">
							<P align="left"><input type="radio" name="hr1" onClick="checkHierarchy(this, 100)" checked>
								Import recipients to this customer only.</td>
					</tr>
					<tr>
						<td width="425" valign="middle" align="right" height="25%">
							<P align="left">
								<input type="radio" name="hr2" onClick="checkHierarchy(this, 200)">
								Import recipients to this customer and all child customers.
						</td>
					</tr>
				</table>
				<%
					}
				%>
			</td>
		</tr>
		</tbody>

		<tr>
			<th colspan=3 class=sectionheader style="border-top:1px solid #D1D1D1">&nbsp;<b class=sectionheader>Step 2:</b>
				<fmt:message key="header_im_step_2_gen_info"/></th>
		</tr>

		<tbody class=EditBlock id=block2_Step1>
		<tr>
			<td colspan=3 valign=top align=center width=650>
				<table cellspacing=0 cellpadding=2 width=100%>
					<TR>
						<TD width="150"><fmt:message key="header_im_step_2_gen_info_select"/></TD>
						<TD width="425"><input type="file" name="recipient_file" size="30" <%=(!bCanWrite)?"disabled":""%>></TD>
					</TR>
					<tr>
						<td><fmt:message key="header_im_step_2_gen_info_dbw"/></td>
						<td>
							<input type="radio" name="db1" onClick="checkDelimiter2(this, 1)">
							<fmt:message key="header_im_step_2_gen_info_first_row"/>
							<input type="radio" name="db2" onClick="checkDelimiter2(this, 2)" CHECKED>
							<fmt:message key="header_im_step_2_gen_info_sec_row"/>
						</td>
					</tr>
					<tr>
						<td><fmt:message key="header_im_step_2_gen_info_file_delimiter"/></td>
						<td><input type="radio" name="rr1" onClick="checkDelimiter(this, ';')">
							<fmt:message key="header_im_step_2_gen_info_file_semicolon"/>(;)
							<input type="radio" name="rr2" onClick="checkDelimiter(this, ',')">
							<fmt:message key="header_im_step_2_gen_info_file_comma"/>(,)
							<input type="radio" name="rr3" onClick="checkDelimiter(this, '|')">
							<fmt:message key="header_im_step_2_gen_info_file_pipe"/>(|)
							<input type="radio" name="rr4" onClick="checkDelimiter(this, '\\t')" CHECKED>
							<fmt:message key="header_im_step_2_gen_info_file_tab"/>
							&nbsp;&nbsp;&nbsp;&nbsp;<a id="mvf_link" class="resourcebutton" href="javascript:toggleMVF();">Multi-Value Field Options</a>
						</td>
					</tr>
					<tr id="mvf_row" style="display:none;">
						<td>Multi-Value Field Delimiter</td>
						<td><input type="radio" name="mvr1" onClick="checkMultiValueDelimiter(this, ';')">Semicolon (;)
							<input type="radio" name="mvr2" onClick="checkMultiValueDelimiter(this, ',')">Comma (,)
							<input type="radio" name="mvr3" onClick="checkMultiValueDelimiter(this, '|')">Pipe (|)
							<input type="radio" name="mvr4" onClick="checkMultiValueDelimiter(this, '\\t')">Tab
							<input type="radio" name="mvr0" onClick="checkMultiValueDelimiter(this, '')" checked><i>None</i>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		</tbody>

		<tr>
			<th colspan=3 class=sectionheader style="border-top:1px solid #D1D1D1">&nbsp;<b class=sectionheader>Step 3:</b>
				<fmt:message key="header_im_step_3_gen_info"/></th>
		</tr>

		<tbody class=EditBlock id=block3_Step1>
		<tr>
			<td colspan=3 valign=top align=center width=650>
				<input type="hidden" name="mapping" value="0">
				<table  width="100%" cellspacing=0 cellpadding=2>
					<tr>
						<td width="150" valign="middle" align="left"><fmt:message key="header_im_step_3_gen_info_mapping1"/></td>
						<td width="425" valign="middle" align="left">
							<input type="radio" name="mp1" id="mp1" onClick="checkMapping(this, 0)" CHECKED><label for="mp1">
							<fmt:message key="header_im_step_3_gen_info_mapping_int"/></label>
							<input type="radio" name="mp2" id="mp2" onClick="checkMapping(this, 1)"><label for="mp2">
							<fmt:message key="header_im_step_3_gen_info_mapping2"/>
						</label>
						</td>
					</tr>
				</table>
				<div id="mappingBox" style="display:none;">
					<table width="100%" cellpadding=2 cellspacing=0>
						<tr>
							<td width="237" valign="middle" align="right" rowspan="7"><select name="target" size="15" style="width: 202; height: 285" onDblClick="removeField()"></select></td>
							<td width="101" valign="middle" align="CENTER" rowspan="7" nowrap>
								<p><a class="subactionbutton" href="javascript:void(0);" onclick="upField();">
									<fmt:message key="button_im_step3_gen_moveup"/></a></p>
								<p><a class="subactionbutton" href="javascript:void(0);" onclick="downField();">
									<fmt:message key="button_im_step3_gen_movedown"/></a></a></p>
								<br>
								<p><a class="subactionbutton" href="javascript:void(0);" onclick="addField();"><<
									<fmt:message key="button_im_step3_gen_moveleft"/></a></a></p>
								<p><a class="subactionbutton" href="javascript:void(0);" onclick="removeField();">
									<fmt:message key="button_im_step3_gen_moveright"/>>></a></p>
							</td>
							<td width="237" valign="middle" align="left" rowspan="7"><select name="source" size="15" style="width: 200; height: 285" onDblClick="addField()"></select></td>
						</tr>
					</table>
				</div>
			</td>
		</tr>
		</tbody>

		<tr>
			<th colspan=3 class=sectionheader style="border-top:1px solid #D1D1D1">&nbsp; <b class=sectionheader>Step 4:</b>
				<fmt:message key="header_im_step_4_gen"/>
			</th>
		</tr>
		<tbody class=EditBlock id=block4_Step1>
		<tr>
			<td colspan=3 valign=top align=center width=650>
				<table  width="100%" cellspacing=0 cellpadding=2>
					<tr>
						<td valign="middle" align="center" style="padding:10px;">
							<a class="newbutton" href="#" onclick="try_submit();" id="startButton">
								<fmt:message key="button_im_step_3_gen_next"/> >></a>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		</tbody>
	</table>
	<br><br>

</FORM>
</BODY>
<SCRIPT LANGUAGE="JavaScript">

	function toggleMVF()
	{
		var oRow = document.getElementById("mvf_row");
		var oLink = document.getElementById("mvf_link");

		if (oRow.style.display == "")
		{
			oRow.style.display = "none";
			oLink.innerText = "Multi-Value Field Options";
		}
		else
		{
			oRow.style.display = "";
			oLink.innerText = "Hide Multi-Value Field Options";
		}
	}

	var itemOpt = new Array();
	<%
        i = 0;
        j = 0;

        rs = stmt.executeQuery(	" select	c.display_name, a.attr_id, isnull(c.fingerprint_seq,0) " +
                                    " FROM ccps_attribute a, ccps_cust_attr c " +
                                    " WHERE	c.display_seq IS NOT NULL" +
                                    " AND	c.cust_id = " + cust.s_cust_id +
                                    " AND	c.attr_id = a.attr_id" +
                                    " ORDER BY c.display_seq");
        while( rs.next() )
        {
            p1 = new String(rs.getBytes(1), "UTF-8");
            p2 = rs.getString(2);
            p3 = rs.getString(3);

            if( p3.equals("0") ) {
    %>FT.source.options[<%=i%>] = new Option("<%=p1%>", <%=p2%>);
	FT.source.options[<%=i%>].type = <%=p3%>;<%
		++i;
		} else	{
%>FT.target.options[<%=j%>] = new Option("<%=p1%>", <%=p2%>);
	FT.target.options[<%=j%>].type = <%=p3%>;<%
		++j;
		}
	}  rs.close();
%>
	for(var i=0; i < FT.source.options.length; ++i) itemOpt[i] = FT.source.options[i];
	for(var j=i, k=0; j < FT.target.options.length; ++j, ++k) itemOpt[j] = FT.target.options[k];
	<%
    if (nBatchID != 0) {
    %>
	FT.id.value = <%= nBatchID %>;
	fillImportValues(<%= nBatchID %>);
	FT.r1.checked = false;
	FT.r2.checked = true;
	<%
    }
    %>

	function addField() {

		if( FT.source.selectedIndex == -1 ) return false;

		FT.target.options[FT.target.length] = new Option(FT.source.options[FT.source.selectedIndex].text, FT.source.options[FT.source.selectedIndex].value);
		//FT.target.options[FT.target.length].type = FT.source.options[FT.source.selectedIndex].type;
		FT.source.options[FT.source.selectedIndex] = null;

		checkNewsletters();
	}

	function removeField() {

		if( FT.target.selectedIndex == -1 ) return false;
		if(( FT.target.options[FT.target.selectedIndex].type != null )
				&& ( FT.target.options[FT.target.selectedIndex].type != 0 )) { alert("You can not remove the required field"); return false; }

		FT.target.options[FT.target.selectedIndex]	= null;

		for(var i=0; i < itemOpt.length; ++i) FT.source.options[i] = itemOpt[i];
		for(var i=0; i < FT.target.options.length; ++i)
			for(var j=0; j < FT.source.options.length; ++j)
				if( FT.target.options[i].value == FT.source.options[j].value ) {
					FT.source.options[j] = null;
					--j;
				}
		FT.source.selectedIndex	= 0;
	}

	function upField() {

		var id, name;

		if( FT.target.selectedIndex < 1 ) return false;

		id = FT.target.options[FT.target.selectedIndex - 1].value;
		name = FT.target.options[FT.target.selectedIndex - 1].text;

		FT.target.options[FT.target.selectedIndex - 1].value = FT.target.options[FT.target.selectedIndex].value;
		FT.target.options[FT.target.selectedIndex - 1].text  = FT.target.options[FT.target.selectedIndex].text;

		FT.target.options[FT.target.selectedIndex].value = id;
		FT.target.options[FT.target.selectedIndex].text  = name;

		FT.target.selectedIndex--;
	}

	function downField() {

		var id, name;

		if( FT.target.selectedIndex == FT.target.length - 1 ) return false;

		id = FT.target.options[FT.target.selectedIndex + 1].value;
		name = FT.target.options[FT.target.selectedIndex + 1].text;

		FT.target.options[FT.target.selectedIndex + 1].value = FT.target.options[FT.target.selectedIndex].value;
		FT.target.options[FT.target.selectedIndex + 1].text  = FT.target.options[FT.target.selectedIndex].text;

		FT.target.options[FT.target.selectedIndex].value = id;
		FT.target.options[FT.target.selectedIndex].text  = name;

		FT.target.selectedIndex++;
	}

	function checkNewsletters()
	{
		if (FT.nl != window.undefined)
		{
			var nlArr = new Array();
			var attrArr = new Array();
			var i = 0;
			var j = 0;
			var k = 0;
			var curNL;
			var match = false;

			if (FT.nl.length != window.undefined) {
				for(var i=0; i < FT.nl.length; i++)
				{
					nlArr[i] = FT.nl[i].value;
				}
			} else {
				nlArr[0] = FT.nl.value;
			}

			for(var i=0; i < FT.target.options.length; i++)
			{
				attrArr[i] = FT.target.options[i].value;
			}

			for (i = 0; i < nlArr.length; i++)
			{
				for (j = 0; j < attrArr.length; j++)
				{
					if (nlArr[i] == attrArr[j])
					{
						if (FT.nl.length != window.undefined) {
							curNL = FT.nl[i];
						} else {
							curNL = FT.nl;
						}

						if (curNL.checked == true)
						{
							match = true;
							curNL.checked = false;
							alert("You cannot map a Newlsetter field and check the box for that Newsletter");
							break;
						}
					}
				}

				if (match == true)
				{
					break;
				}
			}
		}
	}

	function checkDelimiter(obj, value) {
		FT.rr1.checked = false;
		FT.rr2.checked = false;
		FT.rr3.checked = false;
		FT.rr4.checked = false;
		obj.checked = true;
		FT.delimiter.value = value;
	}

	function checkMultiValueDelimiter(obj, value) {
		FT.mvr0.checked = false;
		FT.mvr1.checked = false;
		FT.mvr2.checked = false;
		FT.mvr3.checked = false;
		FT.mvr4.checked = false;
		obj.checked = true;
		FT.multi_value_delimiter.value = value;
	}

	function checkDelimiter2(obj, value) {
		FT.db1.checked = false;
		FT.db2.checked = false;
		obj.checked = true;
		FT.row.value = value;
	}

	function checkPriority(obj, value) {
		FT.pr1.checked = false;
		FT.pr2.checked = false;
		FT.pr3.checked = false;
		FT.pr4.checked = false;
		obj.checked = true;
		FT.upd_rule_id.value = value;
	}

	<%
        if (cust.m_Customers != null) {
    %>
	function checkHierarchy(obj, value) {
		FT.hr1.checked = false;
		FT.hr2.checked = false;
		obj.checked = true;
		FT.upd_hierarchy_id.value = value;
	}
	<%
        }
    %>

	function checkMapping(obj, value) {
		FT.mp1.checked = false;
		FT.mp2.checked = false;
		obj.checked = true;
		FT.mapping.value = value;

		if (FT.mapping.value == 0) {
			FT.target.disabled = true;
			FT.source.disabled = true;
			FT.action = "import_mapping.jsp";
			document.getElementById("mappingBox").style.display = "none";
			document.getElementById("startButton").innerText = "<fmt:message key="button_im_step_3_gen_next"/> >>";
		} else {
			FT.target.disabled = false;
			FT.source.disabled = false;
			FT.action = "import_download.jsp";
			document.getElementById("mappingBox").style.display = "";
			document.getElementById("startButton").innerText = "<fmt:message key="button_im_step_4_gen_start_im"/> >>";
		}
	}

	function fillImportValues() {
		var batchID = FT.id.value;
		if (batchID == "0") return;

		<%=fillFuncText%>
	}

	function try_submit ()
	{
		var i;

		if (FT.fn.checked == true) FT.full_name_flag.value = 1;
		else FT.full_name_flag.value = 0;

		FT.import_name.value = FT.import_name.value.replace(/(^\s*)|(\s*$)/g, '');
		FT.batch_name.value = FT.batch_name.value.replace(/(^\s*)|(\s*$)/g, '');


		try
		{
			FT.recipient_file.value = FT.recipient_file.value.replace(/(^\s*)|(\s*$)/g, '');
		}
		catch(e)
		{

		}

		if(FT.import_name.value == "" ) { alert("You have to type import name ...");	return false; }
		if(FT.r1.checked && FT.batch_name.value == "" ) { alert("You have to type Batch name ...");	return false; }
		if(FT.r2.checked && FT.id.value   == "0" ) { alert("You have to choose Batch ...");		return false; }
		if(FT.recipient_file.value == "" ) { alert("You have to choose File ...");		return false; }
		if(FT.delimiter.value == FT.multi_value_delimiter.value){ alert("Multi-value and File Delimiters should be different...");	return false; }

		//if(FT.file_type.value == "" )	{ alert("You have to designate a file type ...");		return false; }

		FT.batch_id.value = (FT.r1.checked) ? "null" : FT.id.value;

		if (FT.mapping.value != 0)
		{
			if((FT.target.length == 0) && (FT.mapping.value != 0)) 	{ alert("You have to map fields ...");	return false; }

//		COMMENTED OUT DUE TO NONEMAIL SUPPORT FEATURE
//
//		var email_exist = 0; 
//		for(i = 0, email_exist = 0; i < FT.target.length; ++i )
//		{
//			var tmptext = FT.target.options[i].text;
//			tmptext = tmptext.toLowerCase();
//			if (tmptext.search ("email") != -1 ) {	email_exist = 1;	break;		}
//		}
//
//		if (email_exist == 0) {	alert("One of selected fields must be email address...");	return false; }

			FT.fields.value = "";
			for(i = 0; i < FT.target.length; ++i )
				FT.fields.value += FT.target.options[i].value + ((i == FT.target.length - 1) ? "" : ",");
		}

		FT.newsletters.value = "";
		if (FT.nl != window.undefined)
		{
			if (FT.nl.length != window.undefined) {
				for(i = 0; i < FT.nl.length; ++i ) {
					if (FT.nl[i].checked == true) {
						FT.newsletters.value += ((FT.newsletters.value.length == 0) ? "" : ",") + FT.nl[i].value;
					}
				}
			} else {
				if (FT.nl.checked == true) {
					FT.newsletters.value = FT.nl.value;
				}
			}
		}
		<%
            if (!canCat.bExecute && (sSelectedCategoryId != null) && !(sSelectedCategoryId.equals("0")))
            {
        %>
		FT.categorytemp.value = <%=sSelectedCategoryId%>;
		<%
            }
            else
            {
        %>
		FT.categorytemp.value = "";
		for(i = 0; i < FT.categories.length; ++i ) {
			if (FT.categories.options[i].selected == true)
				FT.categorytemp.value += FT.categories.options[i].value + ((i == FT.categories.length - 1) ? "" : ",");
		}
		<%
        }
        %>
		FT.submit();
	}
</SCRIPT>

</fmt:bundle>

</HTML>
<%
	}
	catch(Exception ex)
	{
		ErrLog.put(this,ex, "Problem with Import.",out,1);
	}
	finally
	{
		if ( stmt != null ) stmt.close();
		if ( conn  != null ) cp.free(conn);
	}
%>

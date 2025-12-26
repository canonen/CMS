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
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<% if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
%>

<%!
private String getOptions(int iType, User user, String sCategoryId) throws Exception
{
	String sSql = null;

	switch(iType)
	{
		case FilterType.MULTIPART:
		{
			if (sCategoryId == null) {
				sSql  =
					" SELECT f.filter_id, f.filter_name" +
					" FROM ctgt_filter f WITH(NOLOCK), ctgt_filter_status fss WITH(NOLOCK)" +
					" WHERE f.status_id = fss.status_id" +
					" AND UPPER(fss.status_name) <> 'DELETED'" +
					" AND f.filter_name IS NOT NULL" +
					" AND f.origin_filter_id IS NULL" +
					" AND f.type_id = " + FilterType.MULTIPART +
					" AND ISNULL(f.usage_type_id,500) = 500" +
					" AND f.cust_id = " + user.s_cust_id +
					" ORDER BY f.filter_name";
			} else {
				sSql  =
					" SELECT f.filter_id, f.filter_name" +
					" FROM ctgt_filter f WITH(NOLOCK), ctgt_filter_status fss WITH(NOLOCK), ccps_object_category oc WITH(NOLOCK)" +
					" WHERE f.status_id = fss.status_id" +
					" AND UPPER(fss.status_name) <> 'DELETED'" +
					" AND f.filter_name IS NOT NULL" +
					" AND f.origin_filter_id IS NULL" +
					" AND f.type_id = " + FilterType.MULTIPART +
					" AND ISNULL(f.usage_type_id,500) = 500" +
					" AND f.cust_id = " + user.s_cust_id +
					" AND f.filter_id = oc.object_id" +
					" AND oc.type_id = " + ObjectType.FILTER +
					" AND oc.cust_id = " + user.s_cust_id +
					" AND oc.category_id = " + sCategoryId +
					" ORDER BY f.filter_name";
			}
			break;
		}
		case FilterType.CAMPAIGN:
		{
			if (sCategoryId == null) {
				sSql  =
					" SELECT camp_id, camp_name" +
					" FROM cque_campaign" +
					" WHERE origin_camp_id IS NULL" +
					" AND cust_id = " + user.s_cust_id +
					" ORDER BY camp_name";
			} else {
				sSql  =
					" SELECT c.camp_id, c.camp_name" +
					" FROM cque_campaign c, ccps_object_category oc" +
					" WHERE c.origin_camp_id IS NULL" +
					" AND c.cust_id = " + user.s_cust_id +
					" AND c.camp_id = oc.object_id" +
					" AND oc.type_id = " + ObjectType.CAMPAIGN +
					" AND oc.cust_id = " + user.s_cust_id +
					" AND oc.category_id = " + sCategoryId +
					" ORDER BY c.camp_name";
			}
			break;
		}
		case FilterType.BATCH:
		{
			if (sCategoryId == null) {
				sSql =
					" SELECT b.batch_id, b.batch_name" +
					" FROM cupd_batch b" + 
					" WHERE ( (b.type_id = 1" + 
					" AND b.batch_id IN" +
						" (SELECT DISTINCT i.batch_id" +
						" FROM cupd_import i, cupd_batch b" +
						" WHERE i.status_id = "+ UpdateStatus.COMMIT_COMPLETE +
						" AND i.batch_id = b.batch_id" +
						" AND b.cust_id = " + user.s_cust_id + "))" +
					" OR (b.type_id > 1) )" +
					" AND b.cust_id = " + user.s_cust_id +
					" ORDER BY type_id, batch_name";
			} else {
				sSql =
					" SELECT b.batch_id, b.batch_name" +
					" FROM cupd_batch b" + 
					" WHERE ( (b.type_id = 1" + 
					" AND b.batch_id IN" +
						" (SELECT DISTINCT i.batch_id" +
						" FROM cupd_import i, cupd_batch b, ccps_object_category oc" +
						" WHERE i.status_id = "+ UpdateStatus.COMMIT_COMPLETE +
						" AND i.batch_id = b.batch_id" +
						" AND b.cust_id = " + user.s_cust_id + 
						" AND oc.object_id = i.import_id" +
						" AND oc.type_id = " + ObjectType.IMPORT +
						" AND oc.cust_id = " + user.s_cust_id +
						" AND oc.category_id = "+sCategoryId + "))" +
					" OR (b.type_id > 1) )" +
					" AND b.cust_id = " + user.s_cust_id +
					" ORDER BY type_id, batch_name";
			}
			break;
		}
		case FilterType.LINK_CLICK:
		{
			if (sCategoryId == null) {
				sSql =
					" SELECT link_id, '[' + c.camp_name + '] ' + link_name" +
					" FROM cjtk_link l WITH(NOLOCK), cque_campaign c WITH(NOLOCK)" +
					" WHERE" +
					//" (l.origin_link_id IS NULL) AND" +
					" l.href IS NOT NULL AND" +
					" l.cust_id = " + user.s_cust_id + " AND" +
					" l.cont_id = c.cont_id AND" +
					" c.origin_camp_id IS NOT NULL AND" +
					" c.type_id != 1" +
					" ORDER BY '[' + c.camp_name + '] ' + link_name";
			} else {
				sSql =
					" SELECT link_id, '[' + c.camp_name + '] ' + link_name" +
					" FROM cjtk_link l WITH(NOLOCK), cque_campaign c WITH(NOLOCK), ccps_object_category oc WITH(NOLOCK)" +
					" WHERE" +
					//" l.parent_link_id IS NULL AND" +
					" l.href IS NOT NULL" +
					" AND l.cust_id = " + user.s_cust_id +
					" AND l.cont_id = c.cont_id" +
					" AND c.origin_camp_id IS NOT NULL" +
					" AND c.type_id != 1" +
					" AND c.camp_id = oc.object_id" +
					" AND oc.type_id = " + ObjectType.CAMPAIGN +
					" AND oc.cust_id = " + user.s_cust_id +
					" AND oc.category_id = " + sCategoryId +
					" ORDER BY '[' + c.camp_name + '] ' + link_name";
			}
			break;
		}
		case FilterType.UPLOAD:
		{
			if (sCategoryId == null) {
				sSql =
					" SELECT i.import_id, i.import_name" +
					" FROM cupd_import i, cupd_batch b" +
					" WHERE i.batch_id = b.batch_id" +
					" AND b.cust_id = " + user.s_cust_id +
					" AND i.status_id = " + ImportStatus.COMMIT_COMPLETE +
					" ORDER BY i.import_name";
			} else {
				sSql =
					" SELECT i.import_id, i.import_name" +
					" FROM cupd_import i, cupd_batch b, ccps_object_category oc" +
					" WHERE i.batch_id = b.batch_id" +
					" AND b.cust_id = " + user.s_cust_id +
					" AND i.status_id = " + ImportStatus.COMMIT_COMPLETE +
					" AND oc.object_id = i.import_id" +
					" AND oc.type_id = " + ObjectType.IMPORT +
					" AND oc.cust_id = " + user.s_cust_id +
					" AND oc.category_id = "+sCategoryId + 
					" ORDER BY i.import_name";
			}
			break;
		}
		case FilterType.FORM_SUBMIT:
		{
			sSql =
				" SELECT form_id, form_name" +
				" FROM csbs_form" +
				" WHERE cust_id = " + user.s_cust_id +
				" ORDER BY form_name";
			break;
		}
	}

	ConnectionPool cp = null;
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;

	StringWriter sw = new StringWriter();

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);

		try
		{
			pstmt = conn.prepareStatement(sSql);
			rs = pstmt.executeQuery();

			String sId = null;
			String sName = null;

			byte[] b = null;
			while (rs.next())
			{
				sId = rs.getString(1);
				b = rs.getBytes(2);
				sName = (b==null)?null:new String(b, "ISO-8859-1");
				sw.write("<OPTION value=\"" + sId + "\" cor_type_id=\"" + iType +"\" cor_name=\"" + sName + "\">" + sName + "</OPTION>");
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

	String sOptions = sw.toString();
	sw.close();

	return sOptions;
}
%>

<%

	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(user.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;

	String sCheckedTypeId = request.getParameter("type_id");
	int iCheckedTypeId = FilterType.CAMPAIGN;
	if(sCheckedTypeId != null) iCheckedTypeId = Integer.parseInt(sCheckedTypeId);
%>
<html>
<head>
	<title>Contact Technical Support</title>
	<%@ include file="../header.html" %>
	<link rel="stylesheet" href="<%= ui.s_css_filename %>" TYPE="text/css">
	<script>
		function add()
		{
			var n = filters.target.length;

			for(var i=0; i<n; i++)
			{
				var src_op = filters.target.options[i];

				var op_cor_id = new Option();
				var op_cor_type_id = new Option();				
				var op_cor_name = new Option();

				op_cor_id.value = src_op.value;
				op_cor_type_id.value = src_op.cor_type_id;
				op_cor_name.value = src_op.cor_name;

				filters.cor_id.options[i] = op_cor_id;
				filters.cor_type_id.options[i] = op_cor_type_id;
				filters.cor_name.options[i] = op_cor_name;

				filters.cor_id.options[i].selected = true;
				filters.cor_type_id.options[i].selected = true;				
				filters.cor_name.options[i].selected = true;
			}
			
			var l = filters.filter_type.length;
			for(var i=0; i<l; i++) filters.filter_type[i].disabled = true;

			filters.target.disabled = true;
			
			if (filters.txtProblem.value == "")
			{
				filters.txtProblem.value = " ";
			}
			
			filters.action = "support_success.jsp";
			filters.submit();
		}
	</script>

	<script>
		function add_filter_()
		{
			var l = filters.filter_type.length;
			for(var i=0; i<l; i++)
			{
				if(filters.filter_type[i].style.display != 'none')
				{
					add_filter(filters.filter_type[i])
					break;
				}
			}
		}
		
		function add_filter(obj)
		{
			if( obj.selectedIndex == -1 ) return false;

			var src_op = obj.options[obj.selectedIndex];

			var l = filters.target.options.length;
			for(var i=0; i<l; i++)
			{
				if((filters.target.options[i].value == src_op.value) &&
					(filters.target.options[i].cor_type_id == src_op.cor_type_id)) return;
			}
			
			var op = new Option();
			op.text = src_op.text;
			op.value = src_op.value;
			op.cor_type_id = src_op.cor_type_id;
			op.cor_name = src_op.cor_name;
			
			var type_name = null;
			switch(op.cor_type_id)
			{
				case '<%=FilterType.MULTIPART%>': type_name = 'TARGET_GROUP'; break;
				case '<%=FilterType.CAMPAIGN%>': type_name = 'CAMPAIGN'; break;
				case '<%=FilterType.CAMPAIGN_FORM%>': type_name = 'CAMPAIGN_FORM'; break;
				case '<%=FilterType.BATCH%>': type_name = 'BATCH'; break;
				case '<%=FilterType.LINK_CLICK%>': type_name = 'LINK_CLICK'; break;
				case '<%=FilterType.UPLOAD%>': type_name = 'IMPORT'; break;
				case '<%=FilterType.FORM_SUBMIT%>': type_name = 'FORM_SUBMIT'; break;
				default: type_name = 'UNKNOWN';
			}

			op.text = '[' + type_name + '] ' + op.text;
						
			filters.target.options[filters.target.length] = op;
		}

		function remove_filter()
		{
			if( filters.target.selectedIndex == -1 ) return false;
			filters.target.options[filters.target.selectedIndex] = null;
		}
	</script>

	<script>
		function change_select(obj)
		{
			var l = filters.filter_type.length;
			for(var i=0; i<l; i++)
			{
				filters.filter_type[i].style.display = 'none';				
				if(filters.filter_type[i].filter_type == obj.filter_type)
				{
					filters.filter_type[i].style.display = '';
				}
			}
		}
	</script>
</head>
<body>
<form method="post" action="" name="filters" onSubmit="add();">

<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 1:</b> Tell us about your problem</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=350><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class=main cellspacing=1 cellpadding=2 width="625">
				<tr>
					<td align="center" valign="middle">What area of the system are you having trouble with?</td>
				</tr>
				<tr>
					<td align="center" valign="middle">
						<select name="selAreas">
							<option value="Nothing Selected"> -- Choose a Section of the System -- </option>
							<option value="Campaigns">Campaigns</option>
							<option value="Testing Lists">Testing Lists</option>
							<option value="My Database">My Database</option>
							<option value="Target Groups">Target Groups</option>
							<option value="Content">Content</option>
							<option value="Content Blocks & Logic">Content Blocks & Logic</option>
							<option value="Templates">Templates</option>
							<option value="Reports">Reports</option>
							<option value="Set Up">Set Up</option>
							<option value="Other">Other</option>
						</select>
					</td>
				</tr>
			</table>
			<br>
			<table class=main cellspacing=1 cellpadding=2 width="625">
				<tr>
					<td align="center" valign="middle">Describe the problem you are encountering, or type your question.</td>
				</tr>
				<tr>
					<td align="center" valign="middle"><textarea name="txtProblem" cols="90" rows="12" style="width:100%;"></textarea></td>
				</tr>
			</table>
			<br>
			<table class=main cellspacing=1 cellpadding=2 width="625">
				<tr>
					<td align="center" valign="middle">If you are having problems with a particular item or items in the system, choose it here.</td>
				</tr>
				<tr>
					<td align="center" valign="middle">
						<TABLE border="0">
							<TR>
								<TD colspan="3" align="center" valign="middle">
									<select name="type_id" onChange="change_select(this[this.selectedIndex])">
										<option value="<%=FilterType.MULTIPART%>" filter_type="<%=FilterType.MULTIPART%>" <%=(iCheckedTypeId==FilterType.MULTIPART)?"selected":""%>>Target Group</option>
										<option value="<%=FilterType.CAMPAIGN%>" filter_type="<%=FilterType.CAMPAIGN%>" <%=(iCheckedTypeId==FilterType.CAMPAIGN)?"selected":""%>>Campaign</option>
										<option value="<%=FilterType.BATCH%>" filter_type="<%=FilterType.BATCH%>" <%=(iCheckedTypeId==FilterType.BATCH)?"selected":""%>>Batches</option>
										<option value="<%=FilterType.LINK_CLICK%>" filter_type="<%=FilterType.LINK_CLICK%>" <%=(iCheckedTypeId==FilterType.LINK_CLICK)?"selected":""%>>Links</option>
										<option value="<%=FilterType.UPLOAD%>" filter_type="<%=FilterType.UPLOAD%>" <%=(iCheckedTypeId==FilterType.UPLOAD)?"selected":""%>>Imports of batches</option>
										<option value="<%=FilterType.FORM_SUBMIT%>" filter_type="<%=FilterType.FORM_SUBMIT%>" <%=(iCheckedTypeId==FilterType.FORM_SUBMIT)?"selected":""%>>Subscription form</option>
									</select>
								</TD>
							</tr>
							<tr>
								<TD align="center">
									Having Trouble With:<BR>							
									<SELECT class="smallDDL" name="target" size="10" style="width: 250;" onDblClick="remove_filter()">
									</SELECT>
								</TD>
								<TD align="center">
									<a href="#" class="subactionbutton" onClick="remove_filter()">&gt;&gt;</a><BR>
									<BR>
									<a href="#" class="subactionbutton" onClick="add_filter_()">&lt;&lt;</a><BR>
								</TD>
								<TD align="center">
									Available Selections<BR>
									<SELECT class="smallDDL" name="filter_type" filter_type=<%=FilterType.MULTIPART%> size="10" style="width: 250; display: <%=(iCheckedTypeId==FilterType.MULTIPART)?"":"none"%>;" onDblClick="add_filter(this);">
										<%=getOptions(FilterType.MULTIPART, user, ((sSelectedCategoryId!=null)&&(!sSelectedCategoryId.equals("0"))?sSelectedCategoryId:null))%>
									</SELECT>
									<SELECT class="smallDDL" name="filter_type" filter_type=<%=FilterType.CAMPAIGN%> size="10" style="width: 250; display: <%=(iCheckedTypeId==FilterType.CAMPAIGN)?"":"none"%>;" onDblClick="add_filter(this);">
										<%=getOptions(FilterType.CAMPAIGN, user, ((sSelectedCategoryId!=null)&&(!sSelectedCategoryId.equals("0"))?sSelectedCategoryId:null))%>
									</SELECT>
									<SELECT class="smallDDL" name="filter_type" filter_type=<%=FilterType.BATCH%> size="10" style="width: 250; display: <%=(iCheckedTypeId==FilterType.BATCH)?"":"none"%>;" onDblClick="add_filter(this);">
										<%=getOptions(FilterType.BATCH, user, ((sSelectedCategoryId!=null)&&(!sSelectedCategoryId.equals("0"))?sSelectedCategoryId:null))%>
									</SELECT>
									<SELECT class="smallDDL" name="filter_type" filter_type=<%=FilterType.LINK_CLICK%> size="10" style="width: 250; display: <%=(iCheckedTypeId==FilterType.LINK_CLICK)?"":"none"%>;" onDblClick="add_filter(this);">
										<%=getOptions(FilterType.LINK_CLICK, user, ((sSelectedCategoryId!=null)&&(!sSelectedCategoryId.equals("0"))?sSelectedCategoryId:null))%>
									</SELECT>
									<SELECT class="smallDDL" name="filter_type" filter_type=<%=FilterType.UPLOAD%> size="10" style="width: 250; display: <%=(iCheckedTypeId==FilterType.UPLOAD)?"":"none"%>;" onDblClick="add_filter(this);">
										<%=getOptions(FilterType.UPLOAD, user, ((sSelectedCategoryId!=null)&&(!sSelectedCategoryId.equals("0"))?sSelectedCategoryId:null))%>
									</SELECT>
									<SELECT class="smallDDL" name="filter_type" filter_type=<%=FilterType.FORM_SUBMIT%> size="10" style="width: 250; display: <%=(iCheckedTypeId==FilterType.FORM_SUBMIT)?"":"none"%>;" onDblClick="add_filter(this);">
										<%=getOptions(FilterType.FORM_SUBMIT, user, ((sSelectedCategoryId!=null)&&(!sSelectedCategoryId.equals("0"))?sSelectedCategoryId:null))%>
									</SELECT>
								</TD>
							</TR>
						</TABLE>
						<SELECT class="smallDDL" multiple name="cor_type_id" style="width: 0; height: 0;"><option value="0"></option></SELECT>
						<SELECT class="smallDDL" multiple name="cor_id" style="width: 0; height: 0;"><option value="0"></option></SELECT>
						<SELECT class="smallDDL" multiple name="cor_name" style="width: 0; height: 0;"><option value="None Selected"></option></SELECT>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>

<!--- Step 2 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader>&nbsp;<b class=sectionheader>Step 2:</b> Send us your inquiry</td>
	</tr>
</table>
<br>
<!---- Step 2 Info----->
<table id="Tabs_Table2" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=350><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block2_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class=main cellspacing=1 cellpadding=2 width="625">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<a href="#" class="actionbutton" onClick="add();">Submit Question &gt;&gt;</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</form>
</body>
</html>
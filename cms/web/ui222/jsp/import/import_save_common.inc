<%
Import imp = new Import();

imp.s_import_id = null;
imp.s_import_name = sImportName;
imp.s_batch_id = sBatchId;

imp.s_status_id = String.valueOf(ImportStatus.DOWNLOADED);
imp.s_import_date = null;
imp.s_field_separator = sFieldSeparator;
imp.s_first_row = sFirstRow;
imp.s_import_file = sImportFile;
imp.s_upd_rule_id = sUpdRuleId;
imp.s_import_url = Registry.getKey("import_url_dir");
imp.s_full_name_flag = sFullNameFlag;
imp.s_email_type_flag = sEmailTypeFlag;
imp.s_type_id = null;
imp.s_upd_hierarchy_id = sUpdHierarchyId;
imp.s_auto_commit_flag = null;
imp.s_multi_value_field_separator = sMultiValueFieldSeparator;

// === === ===

if( imp.s_batch_id == null )
{
	Batch batch = new Batch();
	
	batch.s_batch_id = null;
	batch.s_batch_name = sBatchName;
	batch.s_cust_id = cust.s_cust_id;
	batch.s_type_id = sBatchTypeId;
	batch.s_descrip = null;
	
	imp.m_Batch = batch;
}

// === === ===

imp.m_FieldsMappings = fmFieldsMappings;

// === === ===

{
	String sFld = null;

	int nBegin = 0;
	int nEnd = 0;
	if (sNewsletters.length() > 0)
	{
		ImportNewsletters inls = new ImportNewsletters();
		for (int ind=0 ; ; ind ++ )
		{
			nEnd = sNewsletters.indexOf (",", nBegin);

			if (nEnd == -1) sFld = sNewsletters.substring (nBegin);
			else sFld = sNewsletters.substring(nBegin, nEnd);
			
			sFld = sFld.trim();
			if ("".equals(sFld)) break;

			ImportNewsletter inl = new ImportNewsletter();
			inl.s_attr_id = sFld;
			inls.add(inl);
			
			if (nEnd == -1) break;
			nBegin = nEnd + 1;
		}
		
		imp.m_ImportNewsletters = inls;
	}
}

// === === ===

try
{
	imp.save();
	ImportUtil.setupRCP(imp.s_import_id);
}
catch(Exception ex)
{
	if(imp.s_import_id != null)
	{
		String sSql =
			" UPDATE cupd_import" +
			" SET status_id = " + ImportStatus.ERROR +
			" WHERE import_id = " + imp.s_import_id;
				
		BriteUpdate.executeUpdate(sSql);
	}

	throw ex;
}

// === === ===

saveCategories(cust.s_cust_id, imp.s_import_id, sCategories);

%>
<HTML>

<HEAD>
	<BASE target="_self">
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>

<BODY>
<!--- Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
		<td class=sectionheader><b class=sectionheader>Import:</b> Downloaded</td>
	</tr>
</table>
<br>
<!---- Info----->
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
						<p align="center"><b>The file was transmitted and placed into the import queue.</b></p>
						<p align="center"><a href="import_list.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">Back to List</a></p>
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

<%!
private static void saveCategories(String sCustId, String sImportId, String sCategories)
{
	if(sCategories == null) return;
	if(sCategories.trim().equals("")) return;

	String[] sCatsArray = sCategories.split(",");
	if(sCatsArray == null) return;
	
	int l = sCatsArray.length;
	if(l <= 0) return;

	// === === ===
			
	ConnectionPool cp = null;
	Connection conn = null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("import_save.jsp");

		String sSql =
			" INSERT ccps_object_category (cust_id,  object_id, type_id, category_id)" +
			" VALUES (?, ?, ?, ?)";

		PreparedStatement pstmt = null;

		for(int i=0; i<l ;i++)
		{
			try
			{
				pstmt = conn.prepareStatement(sSql);
				pstmt.setString(1, sCustId);
				pstmt.setString(2, sImportId);
				pstmt.setString(3, String.valueOf(ObjectType.IMPORT));
				pstmt.setString(4, sCatsArray[i]);
				pstmt.executeUpdate();
			}
			catch(Exception exx) { throw exx; }
			finally { if(pstmt != null) pstmt.close(); }
		}
	}
	catch(Exception ex) { logger.error("Exception",ex); }
	finally { if(conn != null) cp.free(conn); }
}
%>

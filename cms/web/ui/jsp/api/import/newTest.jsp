<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.upd.*,
			java.io.*,java.util.*,
			java.sql.*,java.net.*,
			org.apache.log4j.*"
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

if(!can.bExecute)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

// === === ===

ServletInputStream in = request.getInputStream();
HashMap aImportParameters = ImportUtil.downloadImport(in, cust.s_cust_id);

%>
<!-- === === === -->
<%
String sImportName = aImportParameters.get("import_name").toString().trim();

String sBatchId = aImportParameters.get("batch_id").toString().trim();
if ("null".equals(sBatchId)) sBatchId = null;

String sFieldSeparator = aImportParameters.get("delimiter").toString().trim();

String sFirstRow = aImportParameters.get("row").toString().trim();
String sImportFile = aImportParameters.get("server_file_name").toString().trim();
String sUpdRuleId = aImportParameters.get("upd_rule_id").toString().trim ();
String sFullNameFlag = aImportParameters.get("full_name_flag").toString().trim();
String sEmailTypeFlag = aImportParameters.get("email_type_flag").toString().trim ();
String sUpdHierarchyId = aImportParameters.get("upd_hierarchy_id").toString().trim();
String sMultiValueFieldSeparator = aImportParameters.get("multi_value_delimiter").toString().trim();
if("null".equals(sMultiValueFieldSeparator)) sMultiValueFieldSeparator = null;
if("".equals(sMultiValueFieldSeparator)) sMultiValueFieldSeparator = null;

// === === ===

String sBatchName = aImportParameters.get("batch_name").toString().trim();
String sBatchTypeId = aImportParameters.get("batch_type").toString().trim();

// === === ===

String sNewsletters = aImportParameters.get("newsletters").toString();
sNewsletters = (((sNewsletters!=null) && !sNewsletters.equals("null"))?sNewsletters.trim():"");

// === === ===

String sCategories = aImportParameters.get("categorytemp").toString().trim();
String sSelectedCategoryId = null;
try
{
	sSelectedCategoryId = aImportParameters.get("category_id").toString().trim();
	if("null".equals(sSelectedCategoryId)) sSelectedCategoryId = null;
}
catch(Exception ex) {}
%>
<!-- === === === -->
<%
ConnectionPool cp = null;
Connection conn = null;
Statement stmt = null;
ResultSet rs = null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	stmt = conn.createStatement();

	String sDataDir = Registry.getKey("import_data_dir");
	
	BufferedReader inb = 
		new BufferedReader(
			new InputStreamReader(
				new FileInputStream(sDataDir + sImportFile),"UTF-8"));

	int nRowsMap = 26;
	int numRecips = 0;

	stmt.execute("CREATE TABLE #tr (row_id int, col_id int, attr_value varchar(255))");	
	while (inb.ready())
	{
		numRecips++;

		if (numRecips > nRowsMap) break;

		String oneRow = inb.readLine();
		String[] sElement = oneRow.split(sFieldSeparator.equals("|")?"\\|":sFieldSeparator);

		PreparedStatement pstmt = null;
		for (int i=0; i<sElement.length; i++)
		{
			try
			{
				pstmt = conn.prepareStatement("INSERT #tr (row_id, col_id, attr_value) VALUES (?,?,?)");
				pstmt.setInt(1, numRecips);
				pstmt.setInt(2, i+1);
				pstmt.setBytes(3, sElement[i].getBytes("UTF-8"));
				pstmt.executeUpdate();
			}
			catch(Exception ex) { throw ex; }
			finally { if ( pstmt != null ) pstmt.close (); }
		}			
	}
	inb.close();

	// === === ===

	int nCols = 0;
	rs = stmt.executeQuery("SELECT max(col_id) FROM #tr");
	if (rs.next()) nCols = rs.getInt(1);
	rs.close();

	if (sFirstRow.equals("2"))
	{
		//Try to match headers to attr_names
		stmt.executeUpdate("UPDATE #tr SET attr_value = a.attr_id FROM #tr, ccps_attribute a, ccps_cust_attr c"
				+ " WHERE #tr.row_id = 1 AND #tr.attr_value = a.attr_name"
				+ " AND c.attr_id = a.attr_id AND c.cust_id = "+cust.s_cust_id);
	}
%>

<HTML>

<HEAD>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>

<BODY>

<a class="actionbutton" href="#" onclick="try_submit();">START IMPORT >></a>
<br>
<FORM  METHOD="POST" NAME="FT" ACTION="import_mapping_save.jsp" TARGET="_self">

<table class="listTable" cellpadding="2" cellspacing="0">
	<tr>
	<%
	for (int j=0; j < nCols; j++)
	{
		%>
		<td align="left" valign="middle">
			<select name="attr<%=j+1%>">
			<%
			String sAttrID = null;
			String sID = null;
			String sName = null;

			if (sFirstRow.equals("2"))
			{
				rs = stmt.executeQuery("SELECT attr_value FROM #tr WHERE row_id = 1 AND col_id = "+(j+1));
				if (rs.next()) sAttrID = rs.getString(1);
				rs.close();
			}

			rs = stmt.executeQuery("SELECT a.attr_id, ISNULL(c.display_name, a.attr_name) "
									+ "FROM ccps_attribute a, ccps_cust_attr c "
									+ "WHERE a.attr_id = c.attr_id "
									+ " AND c.cust_id = "+cust.s_cust_id
									+ " AND c.display_seq IS NOT NULL"
									+ " ORDER BY c.display_seq");

			while (rs.next())
			{
				sID = rs.getString(1);
				sName = new String(rs.getBytes(2),"UTF-8");
%>
				<option value="<%=sID%>"<%=(sID.equals(sAttrID)?" SELECTED":"")%>><%=sName%></option>
<%
			}
%>
				<option value="-1">IGNORE</option>
			</select>
		</td>
		<%
	}
	%>
	</tr>
	<%
	int rowID = 0, lastRow = 0;
	int colID = 0, lastCol = 0;
	String val = null;

	rs = stmt.executeQuery("SELECT row_id, col_id, attr_value FROM #tr WHERE row_id >= "+sFirstRow+" ORDER BY row_id, col_id");

	while (rs.next())
	{					
		rowID = rs.getInt(1);
		colID = rs.getInt(2);
		val = new String(rs.getBytes(3),"UTF-8");

		if (rowID != lastRow)
		{
			for (int k=lastCol; k < nCols; k++)
			{
				%>
				<td align="left" valign="middle" class="listItem_Data">
				</td>
				<%
			}
			lastCol = 0;
			%>
	</tr>
	<tr>
			<%
		}
		
		for (int k=lastCol+1; k < colID; k ++)
		{
			%>
			<td align="left" valign="middle" class="listItem_Data">
			</td>
			<%
		}
		%>
		<td align="left" valign="middle" class="listItem_Data">
			<%=val%>&nbsp;
		</td>
		<%		
		lastRow = rowID;
		lastCol = colID;
	}
	%>
	</tr>
</table>
<br><br>

<INPUT type="hidden" name="category_id" value="<%=sSelectedCategoryId%>">
<INPUT type="hidden" name="import_name" value="<%=sImportName%>">
<INPUT type="hidden" name="batch_name" value="<%=sBatchName%>">
<INPUT type="hidden" name="batch_id" value="<%=sBatchId%>">
<INPUT type="hidden" name="categorytemp" value="<%=sCategories%>">
<INPUT type="hidden" name="delimiter" value="<%=sFieldSeparator%>">
<INPUT type="hidden" name="multi_value_delimiter" value="<%=sMultiValueFieldSeparator%>">
<INPUT type="hidden" name="row" value="<%=sFirstRow%>">
<INPUT type="hidden" name="batch_type" value="<%=sBatchTypeId%>">
<INPUT type="hidden" name="upd_rule_id" value="<%=sUpdRuleId%>">
<INPUT type="hidden" name="upd_hierarchy_id" value="<%=sUpdHierarchyId%>">
<INPUT type="hidden" name="full_name_flag" value="<%=sFullNameFlag%>">
<INPUT type="hidden" name="email_type_flag" value="<%=sEmailTypeFlag%>">
<INPUT type="hidden" name="num_fields" value="<%=nCols%>">
<INPUT type="hidden" name="server_file_name" value="<%=sImportFile%>">
<INPUT type="hidden" name="newsletters" value="<%=sNewsletters%>">

</FORM>

<SCRIPT LANGUAGE="JavaScript">
function try_submit ()
{
<%
	String sFingerAttrs = "fingerAttrArray = new Array(";
	int nAttr = 0;

	rs = stmt.executeQuery ("SELECT c.attr_id FROM ccps_cust_attr c"
			+ " WHERE c.fingerprint_seq IS NOT NULL AND c.cust_id = "+cust.s_cust_id);
	while (rs.next())
	{
		sFingerAttrs += ((nAttr>0)?", ":"") + "'" + rs.getString(1) + "'";
		nAttr++;
	}
	rs.close();
	sFingerAttrs += ");";
%>
	<%=sFingerAttrs%>
	for (var i = 0; i < <%=nAttr%>; i++)
	{
		var hasFinger = false;
		for (var j = 0; j < <%=nCols%>; j++)
		{
			if (fingerAttrArray[i] == eval("FT.attr"+(j+1)+".value"))
			{
				hasFinger = true;
				break;
			}
		}
		if (hasFinger == false)
		{
			alert("Your fingerprint fields are not mapped in this import!");
			return false;
		}
	}
<%
	String sMultiAttrs = "multiAttrArray = new Array('-1'";
	nAttr = 1;

	rs = stmt.executeQuery ("SELECT a.attr_id FROM ccps_cust_attr c, ccps_attribute a WHERE a.attr_id = c.attr_id"
			+ " AND ISNULL(a.value_qty,0) > 0 AND c.cust_id = "+cust.s_cust_id);
	while (rs.next()) {
		sMultiAttrs += ", " + "'" + rs.getString(1) + "'" ;
		nAttr++;
	}
	sMultiAttrs += ");";
%>
	<%=sMultiAttrs%>
	
	var selAttr = 0;
	for (var i = 0; i < <%=nCols%>; i++) {
		selAttr = eval("FT.attr"+(i+1)+".value");
		var isMulti = false;
		for (var j = 0; j < <%=nAttr%>; j++) {
			if (selAttr == multiAttrArray[j]) {
				isMulti = true;
				break;
			}
		}
			
		if (!isMulti) {
			for (var k = i+1; k < <%=nCols%>; k++) {
				if (eval("FT.attr"+(k+1)+".value") == selAttr) {
					alert ("You have more than one column mapped for \""
							+eval("FT.attr"+(k+1)+".options[FT.attr"+(k+1)+".selectedIndex].text")+"\".");
						return false;
				}
			}
		}	
	}

//	COMMENTED OUT DUE TO NONEMAIL SUPPORT FEATURE
//	
//	var emailExist = false;
//	for(var i = 0; i < <%=nCols%>; ++i ) {
//		var tmptext = eval("FT.attr"+(i+1)+".options[FT.attr"+(i+1)+".selectedIndex].text");
//		tmptext = tmptext.toLowerCase();
//		if (tmptext.search ("email") != -1 ) {
//			emailExist = true;
//			break;
//		}
//	}
//
//	if (!emailExist) {
//		alert("One of selected fields must be email address.");
//		return false;
//	}

	var nlArr = new Array();
	if (FT.newsletters.value.indexOf(",") < 0) {
		nlArr[0] = FT.newsletters.value;
	} else {
		nlArr = FT.newsletters.value.split(",");
	}
	var x = 0;
	var y = 0;
	var newNL = "";
	var match = false;
	
	for (x=0; x < nlArr.length; x++)
	{
		for (y=0; y < <%=nCols%>; y++)
		{
			if (eval("FT.attr"+(y+1)+".value") == nlArr[x])
			{
				match = true
				alert("The newsletter field \"" + eval("FT.attr"+(y+1)+"[FT.attr"+(y+1)+".selectedIndex].text") + "\" cannot be mapped as a field in the file, and checked as a Newsletter to be appended.\n\nThe value in the file will be used.");
				break;
			}
		}
		
		if (match == false)
		{
			newNL += "," + nlArr[x];
		}
		else
		{
			match = false;
		}
	}
	
	FT.newsletters.value = newNL.substring(1, newNL.length);

	FT.submit();
}
</SCRIPT>

</BODY>
</HTML>
<%
}
catch (Exception ex) { throw ex; }
finally
{
	if ( stmt != null )
	{
		try { stmt.execute("DROP TABLE #tr"); }
		catch (Exception ignore) {}

		try { stmt.close(); }
		catch (Exception ignore) {}
	}

	if ( conn != null ) cp.free(conn);
}
%>

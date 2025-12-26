<%@ page
		language="java"
		import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.exp.*,
		com.britemoon.cps.ctl.*,
		com.britemoon.cps.tgt.Filter,
		java.sql.*,java.util.*,
		java.io.*,
		java.net.*,org.w3c.dom.*,
		org.apache.log4j.*"
%>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>

<%@ include file="../header.jsp"%>
<%@ include file="../../utilities/validator.jsp"%>

<%!
	String sSql = null;
	static Logger logger = null;
	public class qParm
	{
		String  offset;
		String	id;
		String	name;

		public qParm(String a, String b) { id = a; name = b; offset = b; }
	}
%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	AccessPermission can = user.getAccessPermission(ObjectType.EXPORT);

	if(!can.bWrite)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}

	AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

	boolean canSupReq = ui.getFeatureAccess(Feature.SUPPORT_REQUEST);

	String sfile_id = request.getParameter("file_id");

	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;


	String expName = null;
	String expDelimiter = null;
	String sAttribList = null;
	String sParamId = null;
	String sLinkId = "";
	String sSelectedLinkId = null;
	String sAction = null;
	String sRecipOption = null;
	String sParams = null;
	String sExpParamId = "";
	String sFileUrl = null;
	int iStatusId = 0;
	String sTotalRecip = null;
	String ExpDescrip = "";

	boolean isCamp = false;
	boolean isClick = false;
	boolean isTgt = false;
	boolean isBatch = false;
	boolean isBounce = false;
	boolean isUnsub = false;
	JsonObject dataStep2 = new JsonObject();
	JsonArray arrayStep= new JsonArray();
	if(sfile_id != null)
	{
		Export exp = new Export(sfile_id);
		expName = exp.s_export_name;
		expDelimiter = exp.s_delimiter;
		sAttribList = exp.s_attr_list;
		sAction = exp.s_action;
		sParams = exp.s_params;
		sFileUrl = exp.s_file_url;
		iStatusId = Integer.parseInt(exp.s_status_id);

		ExportParam eps = new ExportParam(sfile_id);
		sRecipOption = eps.s_param_name;
		sParamId = eps.s_param_value;
		if ( (sRecipOption != null) && (sRecipOption.equals("camp_id")))
		{
			if (sParams.indexOf("link_id") > 0) {
				sExpParamId = "2";
				dataStep2.put("sExpParamId", sExpParamId);
			}
			else{
				sExpParamId = "1";
				dataStep2.put("sExpParamId", sExpParamId);
			}
		}
		else if ( (sAction != null) && (sAction.startsWith("Tgt")))
		{
			sExpParamId = "3";
			dataStep2.put("sExpParamId", sExpParamId);
			Filter filter = null;
			if(sParamId != null)
			{
				filter = new Filter(sParamId);
				ExpDescrip = "Export of " + filter.s_filter_name;
				dataStep2.put("ExpDescrip", ExpDescrip);
				arrayStep.put(dataStep2);
			}
			arrayStep.put(dataStep2);
		}
		else if ( (sAction != null) && ( (sAction.equals("ExpBBack")) || (sAction.equals("ExpUnsub"))  ) )
		{
			if(sParamId == null){
				sParamId = "";
				dataStep2.put("sParamId","");
				arrayStep.put(dataStep2);
			}

		}

		if (sAction == null)
		{
			String []arr = sParams.split(";");
			for (int k =0; k<= arr.length; k++)
			{
				dataStep2 = new JsonObject();
				if (arr[k].startsWith("Exp"))
				{
					sAction = arr[k];
					dataStep2.put("sAction",sAction);
				}
				else if (arr[k].indexOf("delimiter=") > 0)
				{
					expDelimiter = arr[k].substring(arr[k].indexOf("=") + 2, arr[k].length() - 1);
					dataStep2.put("expDelimiter",expDelimiter);
				}
				else if (arr[k].indexOf("attr_list=") > 0)
				{
					sAttribList = arr[k].substring(arr[k].indexOf("=") + 1, arr[k].length());
					dataStep2.put("sAttribList",sAttribList);
				}
				else if (arr[k].indexOf("camp_id=") > 0)
				{
					sRecipOption = "camp_id";
					sParamId = arr[k].substring(arr[k].indexOf("=")+1, arr[k].length());
					dataStep2.put("sRecipOption",sRecipOption);
					dataStep2.put("sParamId",sParamId);
				}
				arrayStep.put(dataStep2);
			}


		}
		else if (sAction.equalsIgnoreCase("ExpCampLinkClick"))
		{
			int linkIdIndex = sParams.indexOf("link_id=");
			if(linkIdIndex > -1)
			{
				sLinkId = sParams.substring(linkIdIndex+8, sParams.indexOf(";",linkIdIndex));
			}
		}


		if (sFileUrl != null)
		{
			try
			{
				InputStream is = null;
				DataInputStream dis;
				String str;

				URL url = new URL(sFileUrl);
				is = url.openStream();
				dis = new DataInputStream(new BufferedInputStream(is));
				while ((str = dis.readLine()) != null)
				{
					if (str.indexOf("Total Recipients") != -1)
					{
						sTotalRecip = str.substring(str.indexOf(":")+1, str.length());
						dataStep2.put("sTotalRecip",sTotalRecip);
						break;
					}
					arrayStep.put(dataStep2);
				}
				is.close();
			}
			catch (IOException ex)
			{
				logger.error("Exception in export_edit.jsp : ", ex);
			}
		}
		if(arrayStep.length()>0){
			out.println(arrayStep);
		}
	}

	String campId=null;
	String campName=null;
	String typeName=null;

	JsonArray arrayJson = new JsonArray();
	JsonArray campIDArray = new JsonArray();
	JsonArray CampAndTypeNameArray = new JsonArray();
	JsonArray chooseAreaArray = new JsonArray();
	JsonArray BatchIDArray = new JsonArray();
	JsonArray filterIDArray = new JsonArray();
	JsonArray categoryIDArray = new JsonArray();
	JsonObject data = new JsonObject();
	JsonObject dataObjectJson = new JsonObject();
	JsonObject dataJson = new JsonObject();
	Statement	stmt;
	ResultSet	rs;
	ConnectionPool 	connectionPool 	= null;
	Connection 	srvConnection 	= null;
	Connection 	srvConnection2 	= null;
	Statement	stmt2;
	ResultSet	rs_2;
	int		nStep		= 1;

	try {
		connectionPool = ConnectionPool.getInstance();
		srvConnection = connectionPool.getConnection("export_edit.jsp");
		stmt  = srvConnection.createStatement();
		srvConnection2 = connectionPool.getConnection("export_edit.jsp 2");
		stmt2  = srvConnection2.createStatement();
	} catch(Exception ex) {
		connectionPool.free(srvConnection);
		return;
	}

	String		CUSTOMER_ID	= cust.s_cust_id;
	String		QUERY_NAME	= "";
	String[]	tmp		= new String[8];
	Enumeration	e;
	qParm		sqlE;
	Vector		parm		= new Vector();
	int			FLAG = 0;

	boolean 	isDisable = false;
	boolean 	isInUse = false;

	try {

		tmp[0] = "null";
		tmp[1] = "New target group";
		tmp[2] = "";
		tmp[3] = "";
		tmp[4] = "";
		tmp[5] = "";
		tmp[6] = "";

		int		kCamp		= -1;
		int		kTarg		= -1;
		int		kBat		= -1;
		int		kClick		= -1;
		String		kCamp0 = "0", kClick0 = "0", kTarg0 = "0", kBat0 = "0";
		String		id		= "";
		String		id2		= "";

		boolean		isChangeable 	= true;
		String		isChecked;


		String	sSQLCampDet = null;
		if ((sExpParamId != null) && (sExpParamId.equals("1")))
		{
			if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) )
			{
				sSQLCampDet =
						"SELECT c.camp_id, c.camp_name, t.type_name" +
								" FROM cque_campaign c, cque_camp_type t" +
								" WHERE c.origin_camp_id IS NOT NULL" +
								" AND c.type_id != " + CampaignType.TEST+
								" AND (c.status_id = " + CampaignStatus.DONE +
								" OR (c.type_id IN ("+CampaignType.SEND_TO_FRIEND+","+CampaignType.AUTO_RESPOND+")" +
								" AND c.status_id > "+CampaignStatus.DRAFT+" AND c.status_id <= "+CampaignStatus.DONE+") )" +
								" AND c.cust_id = " + cust.s_cust_id +
								" AND c.camp_id = " + sParamId +
								" AND c.type_id = t.type_id" +
								" ORDER BY c.camp_id";
			}
			else
			{
				sSQLCampDet = "SELECT c.camp_id, c.camp_name, t.type_name" +
						" FROM cque_campaign c, cque_camp_type t, ccps_object_category oc" +
						" WHERE c.origin_camp_id IS NOT NULL" +
						" AND c.type_id != " + CampaignType.TEST+
						" AND (c.status_id = " + CampaignStatus.DONE +
						" OR (c.type_id IN ("+CampaignType.SEND_TO_FRIEND+","+CampaignType.AUTO_RESPOND+")" +
						" AND c.status_id > "+CampaignStatus.DRAFT+" AND c.status_id <= "+CampaignStatus.DONE+") )" +
						" AND c.cust_id = " + cust.s_cust_id +
						" AND c.type_id = t.type_id" +
						" AND c.origin_camp_id = oc.object_id" +
						" AND oc.type_id = " + ObjectType.CAMPAIGN +
						" AND oc.cust_id = " + cust.s_cust_id +
						" AND c.camp_id = " + sParamId +
						" AND oc.category_id = " + sSelectedCategoryId +
						" ORDER BY c.camp_id";
			}
			rs = stmt.executeQuery(sSQLCampDet);

			while(rs.next()) {
				dataObjectJson=new JsonObject();

				campId=rs.getString(1);
				campName = new String(rs.getBytes(2),"ISO-8859-1");
				typeName= rs.getString(3);

				dataObjectJson.put("campId",campId);
				dataObjectJson.put("campName",campName);
				dataObjectJson.put("typeName",typeName);

				arrayJson.put(dataObjectJson);

			}
			data.put("CampId",arrayJson);
			out.println(data);
		}
		if ((sExpParamId != null) && (sExpParamId.equals("3")) ) {
			if(sParamId!=null){
				dataObjectJson.put("sParamID",sParamId);
			}else {
				dataObjectJson.put("sParamID","");
			}
			dataObjectJson.put("sAction",sAction);
		}
		if(sSelectedCategoryId!=null){
			dataObjectJson.put("sSelectedCategoryId",sSelectedCategoryId);
		}
		else{
			dataObjectJson.put("sSelectedCategoryId","");
		}
		dataObjectJson.put("sAction",sAction);

		if(sfile_id!=null) {
			dataObjectJson.put("sFileID", sfile_id);
		}
		else{
			dataObjectJson.put("sFileID","");
		}
		if(expDelimiter != null) {
			if(expDelimiter.equals("\\t")){
				dataObjectJson.put("expDelimete","Tab");
				dataObjectJson.put("Checked","checked");
			}
			else{
				dataObjectJson.put("Checked","");
			}
			if(expDelimiter.equals(";")){
				dataObjectJson.put("expDelimete","Semicolon ;");
				dataObjectJson.put("Checked","checked");
			}
			else{
				dataObjectJson.put("Checked","");
			}
			if(expDelimiter.equals(",")){
				dataObjectJson.put("expDelimete","Comma ,");
				dataObjectJson.put("Checked","checked");
			}
			else{
				dataObjectJson.put("Checked","");
			}
			if(expDelimiter.equals("|")){
				dataObjectJson.put("expDelimete","Pipe |");
				dataObjectJson.put("Checked","checked");
			}
			else{
				dataObjectJson.put("Checked","");
			}
		}

		if(expName==null) dataObjectJson.put("exportName","");
		else dataObjectJson.put("exportName",expName);



		if(!sExpParamId.equals("3")){
			CategortiesControl.toHtmlOptions(cust.s_cust_id, ObjectType.EXPORT, sfile_id, sSelectedCategoryId);

			String sCategoryId = null;
			String sCategoryName = null;
			String sObjId = null;
			boolean isSelected = false;

			String sSql = "";
			if (sfile_id != null) {
				sSql = "SELECT c.category_id, c.category_name, oc.object_id" +
						" FROM ccps_category c" +
						" LEFT OUTER JOIN ccps_object_category oc" +
						" ON (c.category_id = oc.category_id" +
						" AND c.cust_id = oc.cust_id" +
						" AND oc.object_id =" + sfile_id +
						" AND oc.type_id="+ObjectType.EXPORT+")" +
						" WHERE c.cust_id="+CUSTOMER_ID;
			} else {
				sSql = "SELECT c.category_id, c.category_name, [object_id] = NULL" +
						" FROM ccps_category c" +
						" WHERE c.cust_id="+CUSTOMER_ID;
			}

			ResultSet rs3 = stmt.executeQuery(sSql);

			while (rs3.next())
			{
				dataJson= new JsonObject();
				sCategoryId = rs3.getString(1);
				sCategoryName = new String(rs3.getBytes(2), "UTF-8");
				sObjId = rs3.getString(3);

				isSelected =
						(sObjId!=null) || ((sSelectedCategoryId!=null)&&(sSelectedCategoryId.equals(sCategoryId)));

				dataJson.put("CategoryID",sCategoryId);
				if(isSelected) dataJson.put("isSelected","selected");
				else dataJson.put("isSelected","");

//			sw.write("<OPTION value=\""+sCategoryId+"\""+((isSelected)?" selected":"")+">");
//			sw.write(HtmlUtil.escape(sCategoryName));
//			sw.write("</OPTION>");
				categoryIDArray.put(dataJson);
			}
			data= new JsonObject();
			data.put("categoryArray",categoryIDArray);
			out.println(data);
			rs3.close();

		}
		if ( iStatusId == ExportStatus.COMPLETE ) {
			dataObjectJson.put("sTotalRecip",sTotalRecip);
			if(iStatusId == ExportStatus.COMPLETE) dataObjectJson.put("sFileUrl",sFileUrl);
		}

		if (sExpParamId.equals("3")) {
			dataObjectJson.put("ExpDescrip",ExpDescrip);
		}

		else {
			if ((sRecipOption != null) && sRecipOption.equals("camp_id")) {
				isCamp = true;
				dataObjectJson.put("isCamp", isCamp);
			}
			else dataObjectJson.put("isCamp", isCamp);
			if ((sExpParamId != null) && sExpParamId.equals("2")) {
				isClick = true;
				dataObjectJson.put("isClick", isClick);
			}
			else dataObjectJson.put("isClick", isClick);
			if ((sAction != null) && sAction.equals("ExpTgt")) {
				isTgt = true;
				dataObjectJson.put("isTgt", isTgt);
			}
			else dataObjectJson.put("isTgt", isTgt);
			if ((sAction != null) && sAction.equals("ExpBatch")) {
				isBatch = true;
				dataObjectJson.put("isBatch", isBatch);
			}
			else dataObjectJson.put("isBatch", isBatch);
			if ((sAction != null) && sAction.equals("ExpBBack")) {
				isBounce = true;
				dataObjectJson.put("isBounce",isBounce);
			}
			else dataObjectJson.put("isBounce",isBounce);
			if ((sAction != null) && sAction.equals("ExpUnsub")){
				isUnsub = true;
				dataObjectJson.put("isUnsub",isUnsub);
			}
			else dataObjectJson.put("isUnsub",isUnsub);

		}
		chooseAreaArray.put(dataObjectJson);
		data= new JsonObject();
		data.put("ChooseArea",chooseAreaArray);
		out.println(data);

		if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) ) {
			sSql  =
					"SELECT c.camp_id, c.camp_name, t.type_name" +
							" FROM cque_campaign c, cque_camp_type t" +
							" WHERE c.origin_camp_id IS NOT NULL" +
							" AND c.type_id != " + CampaignType.TEST+
							" AND (c.status_id = " + CampaignStatus.DONE +
							" OR (c.type_id IN ("+CampaignType.SEND_TO_FRIEND+","+CampaignType.AUTO_RESPOND+")" +
							" AND c.status_id > "+CampaignStatus.DRAFT+" AND c.status_id <= "+CampaignStatus.DONE+") )" +
							" AND c.cust_id = " + cust.s_cust_id +
							" AND c.type_id = t.type_id" +
							" ORDER BY c.camp_id";
		} else {
			sSql  =
					"SELECT c.camp_id, c.camp_name, t.type_name" +
							" FROM cque_campaign c, cque_camp_type t, ccps_object_category oc" +
							" WHERE c.origin_camp_id IS NOT NULL" +
							" AND c.type_id != " + CampaignType.TEST+
							" AND (c.status_id = " + CampaignStatus.DONE +
							" OR (c.type_id IN ("+CampaignType.SEND_TO_FRIEND+","+CampaignType.AUTO_RESPOND+")" +
							" AND c.status_id > "+CampaignStatus.DRAFT+" AND c.status_id <= "+CampaignStatus.DONE+") )" +
							" AND c.cust_id = " + cust.s_cust_id +
							" AND c.type_id = t.type_id" +
							" AND c.origin_camp_id = oc.object_id" +
							" AND oc.type_id = " + ObjectType.CAMPAIGN +
							" AND oc.cust_id = " + cust.s_cust_id +
							" AND oc.category_id = " + sSelectedCategoryId +
							" ORDER BY c.camp_id";
		}
		rs = stmt.executeQuery(sSql);
		while(rs.next()) {
			dataObjectJson = new JsonObject();
			id = rs.getString(1);
			campName = new String(rs.getBytes(2),"ISO-8859-1");
			typeName= rs.getString(3);

			dataObjectJson.put("id", id);
			dataObjectJson.put("campName",campName);
			dataObjectJson.put("typeName",typeName);
			kCamp ++;
			isChecked = "";
			dataObjectJson.put("isChecked","");
			if (kCamp == 0) {
				if (isCamp) {
					if (sParamId != null) kCamp0 = sParamId;
				} else {
					isChecked ="SELECTED";
					dataObjectJson.put("isChecked","SELECTED");
					kCamp0 = id;
				}
			}
			if(id.equals(campId)){
				dataObjectJson.put("campId",campId);
				dataObjectJson.put("campName",campName);
				dataObjectJson.put("typeName",typeName);


			}
			else{

				dataObjectJson.put("campName", campName);
				dataObjectJson.put("typeName", typeName);
			}
			CampAndTypeNameArray.put(dataObjectJson);
		}
			data= new JsonObject();
			data.put("CampAndTypeName",CampAndTypeNameArray);
			out.println(data);
			rs.close();

		if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) ) {
			sSql  =
					"SELECT c.camp_id, c.camp_name" +
							" FROM cque_campaign c" +
							" WHERE c.origin_camp_id IS NOT NULL" +
							" AND c.type_id != 1" +
							" AND c.status_id = " + CampaignStatus.DONE +
							" AND c.cust_id = " + cust.s_cust_id +
							" ORDER BY c.camp_id";
		} else {
			sSql  =
					"SELECT c.camp_id, c.camp_name" +
							" FROM cque_campaign c, ccps_object_category oc" +
							" WHERE c.origin_camp_id IS NOT NULL" +
							" AND c.type_id != 1" +
							" AND c.status_id = " + CampaignStatus.DONE +
							" AND c.cust_id = " + cust.s_cust_id +
							" AND c.origin_camp_id = oc.object_id" +
							" AND oc.type_id = " + ObjectType.CAMPAIGN +
							" AND oc.cust_id = " + cust.s_cust_id +
							" AND oc.category_id = " + sSelectedCategoryId +
							" ORDER BY c.camp_id";
		}

		rs = stmt.executeQuery(sSql);
		String	sName = null;
		JsonObject dataObjectJson2 = new JsonObject();
		sSelectedLinkId = sParamId.trim()+":"+sLinkId.trim();
		while (rs.next()) {
			dataObjectJson = new JsonObject();
			id = rs.getString(1);
			dataObjectJson.put("CampId", id);
			sName = new String(rs.getBytes(2),"ISO-8859-1");
			dataObjectJson.put("campName",sName);

			rs_2 = stmt2.executeQuery("SELECT DISTINCT link_id, link_name"
					+ " FROM cjtk_link l, cque_campaign c"
					+ " WHERE l.cont_id = c.cont_id AND c.camp_id = " + id);

			while(rs_2.next()) {
				dataObjectJson2=new JsonObject();
				id2 = id + ":" + rs_2.getString(1);
				dataObjectJson2.put("LinkId2", id2);
				++kClick;
				isChecked = "";
				dataObjectJson2.put("isChecked","");
				if (kClick == 0) {
					if (isClick) {
						if (sSelectedLinkId != null) kClick0 =  sSelectedLinkId;
					} else {
						isChecked ="SELECTED";
						dataObjectJson2.put("isChecked","SELECTED");
						kClick0 = id2;
					}
				}
				if(id2.equals(sSelectedLinkId)){

					sName = new String(rs.getBytes(2),"ISO-8859-1");

					dataObjectJson2.put("LinkName", sName);
				}
				else {
					sName = new String(rs.getBytes(2),"ISO-8859-1");

					dataObjectJson2.put("LinkName", sName);
				}

				campIDArray.put(dataObjectJson);
				campIDArray.put(dataObjectJson2);
			}
			rs_2.close();
		}
		data= new JsonObject();
		data.put("campIDArray",campIDArray);
		out.println(data);
		rs.close();


		if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) ) {
			sSql  =
					"SELECT filter_id, filter_name" +
							" FROM ctgt_filter" +
							" WHERE filter_name IS NOT NULL AND origin_filter_id IS NULL" +
							" AND type_id = " + FilterType.MULTIPART +
							" AND status_id != " + FilterStatus.DELETED +
							" AND cust_id = " + cust.s_cust_id +
							" ORDER BY filter_name";
		} else {
			sSql  =
					"SELECT f.filter_id, f.filter_name" +
							" FROM ctgt_filter f, ccps_object_category oc" +
							" WHERE f.filter_name IS NOT NULL AND f.origin_filter_id IS NULL" +
							" AND f.type_id = " + FilterType.MULTIPART +
							" AND f.status_id != " + FilterStatus.DELETED +
							" AND f.cust_id = " + cust.s_cust_id +
							" AND f.filter_id = oc.object_id" +
							" AND oc.type_id = " + ObjectType.FILTER +
							" AND oc.cust_id = " + cust.s_cust_id +
							" AND oc.category_id = " + sSelectedCategoryId +
							" ORDER BY f.filter_name";
		}

		rs = stmt.executeQuery(sSql);
		while(rs.next()) {
			dataObjectJson = new JsonObject();
			id = rs.getString(1);
			dataObjectJson.put("FilterId",id);
			++kTarg;
			isChecked = "";
			dataObjectJson.put("isChecked","");
			if (kTarg == 0) {
				if (isTgt) {
					if (sParamId != null) kTarg0 =  sParamId;
				} else {
					isChecked ="SELECTED";
					dataObjectJson.put("isChecked","SELECTED");
					kTarg0 = id;
				}
			}

			if (id.equals(sParamId)) {
				sName = new String(rs.getBytes(2),"ISO-8859-1");
				dataObjectJson.put("FilterName", sName);
			}
			else{
				sName = new String(rs.getBytes(2),"ISO-8859-1");
				dataObjectJson.put("FilterName", sName);
			}
			filterIDArray.put(dataObjectJson);
		}
		data= new JsonObject();
		data.put("filterIDArray",filterIDArray);
		out.println(data);
		rs.close();

		if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) ) {
			sSql =
					" SELECT b.batch_id, b.batch_name" +
							" FROM cupd_batch b" +
							" WHERE ( (b.type_id = 1" +
							" AND b.batch_id IN" +
							" (SELECT DISTINCT i.batch_id" +
							" FROM cupd_import i, cupd_batch b" +
							" WHERE i.status_id = "+ UpdateStatus.COMMIT_COMPLETE +
							" AND i.batch_id = b.batch_id" +
							" AND b.cust_id = " + cust.s_cust_id + "))" +
							" OR (b.type_id > 1) )" +
							" AND b.cust_id = " + cust.s_cust_id +
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
							" AND b.cust_id = " + cust.s_cust_id +
							" AND oc.object_id = i.import_id" +
							" AND oc.type_id = " + ObjectType.IMPORT +
							" AND oc.cust_id = " + cust.s_cust_id +
							" AND oc.category_id = " + sSelectedCategoryId + "))" +
							" OR (b.type_id > 1) )" +
							" AND b.cust_id = " + cust.s_cust_id +
							" ORDER BY type_id, batch_name";
		}

		rs = stmt.executeQuery(sSql);
		while(rs.next()) {
			dataObjectJson= new JsonObject();
			id = rs.getString(1);
			dataObjectJson.put("BatchId", id);
			++kBat;
			isChecked = "";
			dataObjectJson.put("isChecked","");
			if (kBat == 0) {
				if (isBatch) {
					if (sParamId != null) kBat0 = sParamId;
				} else {
					isChecked ="SELECTED";
					dataObjectJson.put("isChecked","SELECTED");
					kBat0 = id;
				}
			}
			if (id.equals(sParamId)){
				sName = new String(rs.getBytes(2),"ISO-8859-1");
				dataObjectJson.put("batchName", sName);
			}
			else {
				sName = new String(rs.getBytes(2),"ISO-8859-1");
				dataObjectJson.put("BatchName", sName);
			}
			BatchIDArray.put(dataObjectJson);

		}
		data= new JsonObject();
		data.put("BatchIDArray",BatchIDArray);
		out.println(data);
		rs.close();

		JsonObject dataCust=new JsonObject();
		JsonArray arrayPreview= new JsonArray();
		JsonArray arrayRetrieve= new JsonArray();

		CustAttrs preview_attrs = CustAttrsUtil.retrieve4Export_preview(cust.s_cust_id, sAttribList);
		CustAttrs cust_attrs = CustAttrsUtil.retrieve4Export(cust.s_cust_id);
		//CustAttrsUtil.toHtmlOptions(cust_attrs);
		//	dataCust.put("preview",CustAttrsUtil.toHtmlOptionsExport(preview_attrs));

		Enumeration elements = preview_attrs.elements();
		CustAttr ca = null;

		while(elements.hasMoreElements()){
			dataCust = new JsonObject();
			ca = (CustAttr) elements.nextElement();
			dataCust.put("previewName", ca.s_display_name);
			arrayPreview.put(dataCust);
		}
		data= new JsonObject();
		data.put("arrayPreview",arrayPreview);
		out.println(data);
		Enumeration enuma = cust_attrs.elements();

		CustAttr cas = null;
		while( enuma.hasMoreElements())
		{
			dataCust = new JsonObject();
			cas = (CustAttr) enuma.nextElement();
			dataCust.put("retrieveName",cas.s_display_name);
			arrayRetrieve.put(dataCust);
		}
		data= new JsonObject();
		data.put("arrayRetrieve",arrayRetrieve);




		out.println(data);
	}
	catch(Exception ex) {
		ErrLog.put(this,ex,"export_edit.jsp",out,1);
		return;
	} finally {
		if (stmt != null) stmt.close();
		if (stmt2 != null) stmt2.close();
		if (srvConnection != null) connectionPool.free(srvConnection);
		if (srvConnection2 != null) connectionPool.free(srvConnection2);
	}
%>

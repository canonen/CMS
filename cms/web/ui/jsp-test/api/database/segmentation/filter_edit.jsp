<%@ page
		language="java"
		import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.wfl.*,
			com.britemoon.cps.ctl.*,
			java.io.*,java.sql.*,java.util.*,
			org.w3c.dom.*,org.apache.log4j.*"
		errorPage="../error_page.jsp"
		contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.britemoon.cps.tgt.Filter" %>
<%@ include file="../header.jsp" %>
<%@ include file="../../../utilities/validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	AccessPermission can = user.getAccessPermission(ObjectType.FILTER);
	JsonObject data = new JsonObject();
	JsonArray array = new JsonArray();
	if(!can.bRead)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}

	AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);
	boolean canTGPreview = ui.getFeatureAccess(Feature.FILTER_PREVIEW);

	String sSelectedCategoryId = BriteRequest.getParameter(request, "category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id))) sSelectedCategoryId = ui.s_category_id;

	String sFilterId = BriteRequest.getParameter(request, "filter_id");
//int sOperator = Integer.decode(BriteRequest.getParameter(request, "compareOperator"));

// KO: Added for content filter support
	String sUsageTypeId = BriteRequest.getParameter(request, "usage_type_id");
	String sLogicId = BriteRequest.getParameter(request, "logic_id");
	String sParentContId = BriteRequest.getParameter(request, "parent_cont_id");

//KU: Added for content logic ui
	boolean bIsTargetGroup = true;
	String sTargetGroupDisplay = "Target Group";
	if(String.valueOf(FilterUsageType.CONTENT).equals(sUsageTypeId))
	{
		sTargetGroupDisplay = "Logic Element";
		bIsTargetGroup = false;
	}
	else if(String.valueOf(FilterUsageType.REPORT).equals(sUsageTypeId))
	{
		sTargetGroupDisplay = "Report Filter";
		bIsTargetGroup = false;
	}
	else
	{
		sUsageTypeId = String.valueOf(FilterUsageType.REGULAR);
	}

	boolean canSupReq = ui.getFeatureAccess(Feature.SUPPORT_REQUEST);

// === === ===

	com.britemoon.cps.tgt.Filter filter = new com.britemoon.cps.tgt.Filter();

	FilterEditInfo filter_edit_info = new FilterEditInfo();
	User creator = null;
	User modifier = null;

	boolean bIsNewFilter = false;
	String s_recip_qty = null;
	String s_last_update_date = null;

	if(sFilterId == null)
	{
		filter.s_filter_name = "New " + sTargetGroupDisplay;
		filter.s_type_id = String.valueOf(FilterType.MULTIPART);
		filter.s_cust_id = cust.s_cust_id;
		filter.s_status_id = String.valueOf(FilterStatus.NEW);
		filter.s_usage_type_id = String.valueOf(FilterUsageType.REGULAR);

		creator = user;
		modifier = user;

		bIsNewFilter = true;
		s_recip_qty = "";
		s_last_update_date = "";
	}
	else
	{
		filter.s_filter_id = sFilterId;
		if(filter.retrieve() < 1) return;

		filter_edit_info.s_filter_id = filter.s_filter_id;
		filter_edit_info.retrieve();

		creator = new User(filter_edit_info.s_creator_id);
		modifier = new User(filter_edit_info.s_modifier_id);

		FilterStatistic filter_stat = new FilterStatistic(filter.s_filter_id);
		s_recip_qty = (filter_stat.s_recip_qty == null) ?"Unknown": filter_stat.s_recip_qty;
		s_last_update_date = (filter_stat.s_finish_date == null) ?"Unknown": filter_stat.s_finish_date;
	}

	int iStatusId = Integer.parseInt(filter.s_status_id);

	boolean bWorkflow = WorkflowUtil.getWorkflow(cust.s_cust_id, ObjectType.FILTER);
	String sAprvlRequestId = request.getParameter("aprvl_request_id");
	boolean isApprover = false;
	String sAprvlStatusFlag = null;
	if (sFilterId != null) {
		if (sAprvlRequestId == null)
			sAprvlRequestId = "";
		ApprovalRequest arRequest = null;
		if (sAprvlRequestId != null && !sAprvlRequestId.equals("")) {
			arRequest = new ApprovalRequest(sAprvlRequestId);
		} else {
			arRequest = WorkflowUtil.getApprovalRequest(cust.s_cust_id, String.valueOf(ObjectType.FILTER),sFilterId);
		}
		if (arRequest != null && arRequest.s_approver_id != null && arRequest.s_approver_id.equals(user.s_user_id)) {
			sAprvlRequestId = arRequest.s_approval_request_id;
			isApprover = true;
		}
	}

	boolean bCanEditParts = true;
	if ((bWorkflow && iStatusId == FilterStatus.PENDING_APPROVAL) || "-1".equals(filter.s_aprvl_status_flag)) {
		bCanEditParts = false;
	}

	ConnectionPool cp = null;
	Connection conn = null;
	Statement	stmt = null;
	ResultSet	rs = null;
	String sSQL = null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();

		sSQL =
				" SELECT attr_id, filter_usage" +
						" FROM ccps_attr_calc_props" +
						" WHERE cust_id = '" + cust.s_cust_id + "'" +
						" AND calc_values_flag in (1,2) " +
						" AND filter_usage in (1,2)";

		rs = stmt.executeQuery(sSQL);

		String sAttrID = "";
		String sFilterUsage = "";
		String saveArr = "";

		JsonObject attrData = new JsonObject();
		for(int i = 0; rs.next(); i++)
		{
			data = new JsonObject();
			sAttrID = "";
			sFilterUsage = "";
			saveArr = "";

			sAttrID = rs.getString(1);
			sFilterUsage = rs.getString(2);

			saveArr = sAttrID + ";" + sFilterUsage;
			attrData.put("attrId",sAttrID);
			attrData.put("filterUsage",sFilterUsage);
			attrData.put("saveArr",saveArr);
			array.put(data);

		}

		if(array.length()!=0){
			data.put("attrData",array);
		}

		array = new JsonArray();
		data= new JsonObject();
		rs.close();
	}
	catch(Exception ex) { throw ex; }
	finally { if(conn!=null) cp.free(conn); }
	JsonObject filterJson = new JsonObject();
	JsonArray filterArray = new JsonArray();
	if (filter.s_filter_id !=null ) {
		filterJson.put("filterId",filter.s_filter_id);
	}
	if (filter.s_filter_name == null) filterJson.put("sTargetGroupDisplay",sTargetGroupDisplay);
	else filterJson.put("filterName",filter.s_filter_name);
	filterJson.put("createDate",filter_edit_info.s_create_date);
	filterJson.put("modifyDate",filter_edit_info.s_modify_date);
	filterArray.put(filterJson);
	data.put("filterInfo",filterJson);


	String sCategoryId = null;
	String sCategoryName = null;
	String sObjId = null;
	boolean isSelected = false;

	String sSql = "";
	if (sFilterId != null) {
		sSql = "SELECT c.category_id, c.category_name, oc.object_id" +
				" FROM ccps_category c" +
				" LEFT OUTER JOIN ccps_object_category oc" +
				" ON (c.category_id = oc.category_id" +
				" AND c.cust_id = oc.cust_id" +
				" AND oc.object_id =" + filter.s_filter_id +
				" AND oc.type_id="+ObjectType.EXPORT+")" +
				" WHERE c.cust_id="+cust.s_cust_id;
	} else {
		sSql = "SELECT c.category_id, c.category_name, [object_id] = NULL" +
				" FROM ccps_category c" +
				" WHERE c.cust_id="+cust.s_cust_id;
	}

	ResultSet rs3 = stmt.executeQuery(sSql);
	JsonObject dataJson = new JsonObject();
	JsonArray categoryIDArray = new JsonArray();
	while (rs3.next())
	{
		dataJson= new JsonObject();
		sCategoryId = rs3.getString(1);
		sCategoryName = new String(rs3.getBytes(2), "UTF-8");
		sObjId = rs3.getString(3);

		isSelected =
				(sObjId!=null) || ((sSelectedCategoryId!=null)&&(sSelectedCategoryId.equals(sCategoryId)));

		dataJson.put("categoryID",sCategoryId);
		dataJson.put("categoryName",sCategoryName);
		if(isSelected) dataJson.put("isSelected","selected");
		else dataJson.put("isSelected","");

		categoryIDArray.put(dataJson);
	}

	data.put("categoryArray",categoryIDArray);

	rs3.close();

	drawFilter(cust.s_cust_id, sFilterId, out);


	CustAttrs preview_attrs = CustAttrsUtil.retrieve4filter_preview(filter.s_cust_id, filter.s_filter_id);
	CustAttrs cust_attrs = CustAttrsUtil.retrieve4filter(cust.s_cust_id, filter.s_filter_id);
	CustAttrsUtil.toHtmlOptions(preview_attrs);
	JsonObject dataCust=new JsonObject();
	JsonArray arrayPreview= new JsonArray();
	JsonArray arrayRetrieve= new JsonArray();
	Enumeration elements = preview_attrs.elements();
	CustAttr ca = null;

	while(elements.hasMoreElements()){
		dataCust = new JsonObject();
		ca = (CustAttr) elements.nextElement();
		dataCust.put("previewName", ca.s_display_name);
		dataCust.put("previewID",ca.s_attr_id);
		arrayPreview.put(dataCust);
	}

	data.put("arrayPreview",arrayPreview);


	Enumeration enuma = cust_attrs.elements();

	CustAttr cas = null;
	while( enuma.hasMoreElements())
	{
		dataCust = new JsonObject();
		cas = (CustAttr) enuma.nextElement();
		dataCust.put("retrieveName",cas.s_display_name);
		dataCust.put("retrieveID",cas.s_attr_id);
		arrayRetrieve.put(dataCust);
	}

	data.put("arrayRetrieve",arrayRetrieve);
	JsonObject htmlJson	= new JsonObject();
	JsonArray htmlArray = new JsonArray();

	String creatorName= HtmlUtil.escape(creator.s_user_name + " " + creator.s_last_name);
	String modifierName= HtmlUtil.escape(modifier.s_user_name + " " + modifier.s_last_name);
	String createDate= HtmlUtil.escape(filter_edit_info.s_create_date);
	String modifyDate= HtmlUtil.escape(filter_edit_info.s_modify_date);
	htmlJson.put("creatorName",creatorName);
	htmlJson.put("modifierName",modifierName);
	htmlJson.put("createDate",createDate);
	htmlJson.put("modifyDate",modifyDate);
	htmlArray.put(htmlJson);
	data.put("asciiCode",htmlArray);

	//JsonObject asd = new JsonObject();
	//JsonObject asd2 = new JsonObject();
	JsonObject asd =drawMultipartFilterPrototype(cust.s_cust_id, out);
	JsonObject asd2 =drawFormulaPrototype(cust.s_cust_id, out);
//
	if(asd.length()!=0){
		data.put("asd",asd);
	}

	if(asd2.length()!=0){
		data.put("asd2",asd2);
	}


	out.println(data.toString());
%>

<%!
	private static JsonObject drawFilter(String sCustId, String sFilterId, JspWriter out) throws Exception
	{
		com.britemoon.cps.tgt.Filter fi = null;
		if(sFilterId != null)
		{
			fi = new com.britemoon.cps.tgt.Filter();
			fi.s_filter_id = sFilterId;
			if(fi.retrieve() < 1);
		}
		else
		{
			fi = getMultipartFilterPrototype(sCustId);
		}

		fi.s_usage_type_id = String.valueOf(FilterUsageType.HIDDEN);
		return drawFilterGeneric(fi, out);

	}

	private static JsonObject drawFilterParts(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
	{

		return drawFilterParts(null, filter, out);

	}

	private static JsonObject drawFilterParts(String sWrappingBooleanOperation, com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
	{
		JsonObject data = new JsonObject();
		data.put("empty","empty");
		FilterParts filter_parts = filter.m_FilterParts;

		if(filter_parts == null)
		{
			filter_parts = new FilterParts();
			if(filter.s_filter_id != null)
			{
				filter_parts.s_parent_filter_id = filter.s_filter_id;
				filter_parts.retrieve();
			}
			filter.m_FilterParts = filter_parts;
		}

		FilterPart filter_part = null;
		for (Enumeration e = filter_parts.elements() ; e.hasMoreElements() ;)
		{
			filter_part = (FilterPart) e.nextElement();
			return drawFilterPart(sWrappingBooleanOperation, filter_part, out);
		}
	return data;
	}

	private static JsonObject drawFilterPart(String sWrappingBooleanOperation, FilterPart filter_part, JspWriter out) throws Exception
	{

		com.britemoon.cps.tgt.Filter child_filter = filter_part.m_ChildFilter;
		if( child_filter == null )
		{
			child_filter = new com.britemoon.cps.tgt.Filter();
			if(filter_part.s_child_filter_id != null )
			{
				child_filter.s_filter_id = filter_part.s_child_filter_id;
				child_filter.retrieve();
			}
			filter_part.m_ChildFilter = child_filter;
		}

		if(sWrappingBooleanOperation != null)
		{

			return drawFilterPart(sWrappingBooleanOperation, child_filter, out);
		}

		String sBooleanOperation = getBooleanOperation(child_filter);
		if("NOT".equals(sBooleanOperation)) // ||  "NOP".equals(sBooleanOperation))
		{
			//drawFilterParts(sBooleanOperation, child_filter, out);
			return drawFilterParts(sBooleanOperation, child_filter, out);
		}

		return drawFilterPart("NOP", child_filter, out);
	}

	private static JsonObject drawFilterPart(String sWrappingBooleanOperation, com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
	{

		int nTypeId = Integer.parseInt(filter.s_type_id);

		if(filter.s_usage_type_id == null) filter.s_usage_type_id = String.valueOf(FilterUsageType.HIDDEN);
		int nUsageTypeId = Integer.parseInt(filter.s_usage_type_id);

		if((nTypeId == FilterType.MULTIPART)&&(nUsageTypeId == FilterUsageType.HIDDEN))
		{
			//drawMultipartFilterPart(filter, out);
			return drawMultipartFilterPart(filter, out);
		}
		else
		{
			//drawSimpleFilterPart(filter, out);
			return drawSimpleFilterPart(filter, out);
		}

	}

	private static JsonObject drawSimpleFilterPart(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
	{

		//		drawFilterGeneric(filter, out);
		return drawFilterGeneric(filter, out);
	}

	private static JsonObject drawMultipartFilterPart(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
	{

		String sPartName = null;
		if(filter.s_filter_name!=null) sPartName = filter.s_filter_name;
		else if(filter.s_filter_id!=null) sPartName = "(" + filter.s_filter_id + ")";
		JsonObject data = new JsonObject();
		data.put("sPartName",sPartName);
		drawFilterGeneric(filter, out);
		return data;

	}

// === === ===

	private static JsonObject drawFilterGeneric(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
	{
		JsonObject data = new JsonObject();
		JsonArray array = new JsonArray();
		JsonObject filterInfo = new JsonObject();
		int nTypeId = Integer.parseInt(filter.s_type_id);

		if(filter.s_usage_type_id == null) filter.s_usage_type_id = String.valueOf(FilterUsageType.HIDDEN);
		int nUsageTypeId = Integer.parseInt(filter.s_usage_type_id);

		if	(((nTypeId == FilterType.MULTIPART)&&(nUsageTypeId == FilterUsageType.HIDDEN))||(nTypeId == FilterType.FORMULA))
		{
			data.put("filterId",filter.s_filter_id);
			data.put("filterName",filter.s_filter_name);
			data.put("typeId",filter.s_type_id);
			data.put("custId",filter.s_filter_id);
			data.put("statusId",filter.s_status_id);
			data.put("originFilterId",filter.s_origin_filter_id);
			data.put("usageTypeId",filter.s_usage_type_id);
		}
			array.put(data);
		data = new JsonObject();
		data.put("filterInfo",array);


		if(nTypeId == FilterType.FORMULA)
			data.put("a",drawFormula(filter, out));
		else
		if((nTypeId == FilterType.MULTIPART)&&(nUsageTypeId == FilterUsageType.HIDDEN))
			data.put("c",drawMultipartFilter(filter, out));
		else
			  data.put("b",drawSimpleFilter(filter, out));

		return data;

	}


	private static JsonObject drawMultipartFilter(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
	{
		JsonObject data = new JsonObject();
		JsonArray array = new JsonArray();

		String sBooleanOperation = getBooleanOperation(filter);

		if("NOP".equals(sBooleanOperation)){
			data.put("isChechked","selected");
		}
		else data.put("isChechked","");

		if("OR".equals(sBooleanOperation)){
			data.put("isChechked","selected");
		}
		else data.put("isChechked","");

		if("AND".equals(sBooleanOperation)){
			data.put("isChechked","selected");
		}
		else data.put("isChechked","");

		return drawFilterParts(filter, out);
	}

	private static JsonObject drawFormula(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
	{
		JsonObject data = new JsonObject();
		JsonArray array = new JsonArray();
		Formula formula = filter.m_Formula;

		if( formula == null )
		{
			formula = new Formula();
			if(filter.s_filter_id != null)
			{
				formula.s_filter_id = filter.s_filter_id;
				formula.retrieve();
			}
			filter.m_Formula = formula;
		}

		String disableValues = "";
		String showSelVals = " style='display:none'";

		AttrCalcProps acp = null;
		acp = new AttrCalcProps(filter.s_cust_id, formula.s_attr_id);

		String sFilterUse = acp.s_filter_usage;
		String sCalcValsFlag = acp.s_calc_values_flag;

		if (("1".equals(sFilterUse) || "2".equals(sFilterUse)) && ("1".equals(sCalcValsFlag) || "2".equals(sCalcValsFlag)))
		{
			showSelVals = "";

			if ("1".equals(sFilterUse))
			{
				disableValues = " disabled";
			}
		}

		boolean bShowValue2 = (String.valueOf(CompareOperation.BETWEEN).equals(formula.s_operation_id));
		data.put("formulaId",formula.s_filter_id);

		JsonArray arrayPreview= new JsonArray();
		JsonArray arrayRetrieve= new JsonArray();
		JsonObject dataCust = new JsonObject();
		CustAttrs formula_attrs = CustAttrsUtil.retrieve4filter(filter.s_cust_id, filter.s_filter_id);
		Enumeration enuma = formula_attrs.elements();

		CustAttr cas = null;
		while( enuma.hasMoreElements())
		{
			dataCust = new JsonObject();
			cas = (CustAttr) enuma.nextElement();
			dataCust.put("retrieveName",cas.s_display_name);
			dataCust.put("retrieveID",formula.s_attr_id);
			arrayRetrieve.put(dataCust);
		}

		data.put("arrayRetrieve",arrayRetrieve);


		if("-1".equals(formula.s_positive_flag)){
			data.put("isChechked","selected");
		}
		//else data.put("isChechked","");

		//out.println(CompareOperation.toHtmlOptions(formula.s_operation_id));

		//out.println(HtmlUtil.escape(formula.s_value1) + disableValues );
		//data.put("htmlUtilescape2",HtmlUtil.escape(formula.s_value2));
		//data.put("htmlUtilescape1",HtmlUtil.escape(formula.s_value1));
		JsonArray generalArray = new JsonArray();
		//out.println("			<input type=text xml_tag=value2 value='" + HtmlUtil.escape(formula.s_value2) +"' size=30 maxlength=255" + disableValues + ""  + ((bShowValue2)?"":" style='display: none'") + ">");
		//data.put("valuesList",showSelVals);
		JsonArray arrays = new JsonArray();
		generalArray.put(data);

		JsonObject compareObj= new JsonObject();
		JsonObject compareData = new JsonObject();

		//data.put("CompareOperation",CompareOperation.toHtmlOptions(formula.s_operation_id));
		compareObj.put("key","=");
		compareObj.put("value","10");
		array.put(compareObj);
		compareObj = new JsonObject();
		compareObj.put("key",">");
		compareObj.put("value","20");
		array.put(compareObj);
		compareObj = new JsonObject();
		compareObj.put("key",">=");
		compareObj.put("value","30");
		array.put(compareObj);
		compareObj = new JsonObject();
		compareObj.put("key","<");
		compareObj.put("value","40");
		array.put(compareObj);
		compareObj = new JsonObject();
		compareObj.put("key","<=");
		compareObj.put("value","50");
		array.put(compareObj);
		compareObj = new JsonObject();
		compareObj.put("key","LIKE");
		compareObj.put("value","60");
		array.put(compareObj);
		compareObj = new JsonObject();
		compareObj.put("key","BETWEEN");
		compareObj.put("value","70");
		array.put(compareObj);
		compareObj = new JsonObject();
		compareObj.put("key","IN");
		compareObj.put("value","80");
		array.put(compareObj);
		data.put("compareData",array);
		return data;


	}

	private static JsonObject drawSimpleFilter(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
	{
		JsonObject data = new JsonObject();
		JsonArray array = new JsonArray();
		HtmlUtil.escape(filter.s_filter_name);
		data.put("filterSimpleName",filter.s_filter_name);
		int nTypeId = 0;
		if(filter.s_type_id != null) nTypeId = Integer.parseInt(filter.s_type_id);
		data.put("typeID",nTypeId);
		array.put(data);
	    data = new JsonObject();
		data.put("simpleFilter",array);

		return  data;

	}


	private static String getBooleanOperation(com.britemoon.cps.tgt.Filter filter) throws Exception
	{
		String sBooleanOperation = null;

		if(Integer.parseInt(filter.s_type_id) != FilterType.MULTIPART)
			return sBooleanOperation;

		FilterParams fps = filter.m_FilterParams;
		if( fps == null )
		{
			fps = new FilterParams();
			if(filter.s_filter_id != null)
			{
				fps.s_filter_id = filter.s_filter_id;
				fps.retrieve();
			}
			filter.m_FilterParams = fps;
		}

		sBooleanOperation = fps.getStringValue("BOOLEAN OPERATION");
		if(sBooleanOperation == null) sBooleanOperation = "NOP";
		return sBooleanOperation;
	}

// === === ===

	private static com.britemoon.cps.tgt.Filter getFormulaPrototype(String sCustId) throws Exception
	{
		Formula fo = new Formula();

		// === === ===

		com.britemoon.cps.tgt.Filter fi = new com.britemoon.cps.tgt.Filter();

		fi.s_filter_id = null;
		fi.s_filter_name = null;
		fi.s_type_id = String.valueOf(FilterType.FORMULA);
		fi.s_cust_id = sCustId;
		fi.s_status_id = String.valueOf(FilterStatus.NEW);
		fi.s_origin_filter_id = null;
		fi.s_usage_type_id = String.valueOf(FilterUsageType.HIDDEN);

		fi.m_Formula = fo;

		// === === ===

		return fi;
	}

	private static com.britemoon.cps.tgt.Filter getMultipartFilterPrototype(String sCustId) throws Exception
	{
		FilterParam fp = new FilterParam();

		fp.s_param_name = "BOOLEAN OPERATION";
		fp.s_string_value = "NOP";

		// === === ===

		FilterParams fps = new FilterParams();
		fps.add(fp);

		// === === ===

		com.britemoon.cps.tgt.Filter fi = new com.britemoon.cps.tgt.Filter();

		fi.s_filter_id = null;
		fi.s_filter_name = null;
		fi.s_type_id = String.valueOf(FilterType.MULTIPART);
		fi.s_cust_id = sCustId;
		fi.s_status_id = String.valueOf(FilterStatus.NEW);
		fi.s_origin_filter_id = null;
		fi.s_usage_type_id = String.valueOf(FilterUsageType.HIDDEN);

		fi.m_FilterParams = fps;

		// === === ===

		return fi;
	}

	private static JsonObject drawFormulaPrototype(String sCustId, JspWriter out) throws Exception
	{
		//drawFilterPart("NOP", getFormulaPrototype(sCustId), out);
		return drawFilterPart("NOP", getFormulaPrototype(sCustId), out);
	}

	private static JsonObject drawMultipartFilterPrototype(String sCustId, JspWriter out) throws Exception
	{
		//drawFilterPart("NOP", getMultipartFilterPrototype(sCustId), out);
		return drawFilterPart("NOP", getMultipartFilterPrototype(sCustId), out);
	}

%>

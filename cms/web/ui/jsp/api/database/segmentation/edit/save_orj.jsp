<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.tgt.*,
			java.io.*,java.sql.*,
			java.util.*,org.w3c.dom.*,
			org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="org.json.JSONObject" %>
<%@ include file="../../header.jsp" %>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

//KU: Added for content logic ui
String sUsageTypeId = BriteRequest.getParameter(request, "usage_type_id");

String sTargetGroupDisplay = "Target Group";
if(String.valueOf(FilterUsageType.CONTENT).equals(sUsageTypeId))
{
	sTargetGroupDisplay = "Logic Element";
}
else if(String.valueOf(FilterUsageType.REPORT).equals(sUsageTypeId))
{
	sTargetGroupDisplay = "Report Filter";
}
else
{
	sUsageTypeId = String.valueOf(FilterUsageType.REGULAR);
}
	

	String sFilterId = BriteRequest.getParameter(request, "filter_id");
	String sFilterName = BriteRequest.getParameter(request, "filter_name");
	String sTypeId = BriteRequest.getParameter(request, "type_id");

	String[] sParamNames = BriteRequest.getParameterValues(request, "param_name");
	String[] sIntegerValues = BriteRequest.getParameterValues(request, "integer_value");
	String[] sStringValues = BriteRequest.getParameterValues(request, "string_value");
	String[] sDateValues = BriteRequest.getParameterValues(request, "date_value");

//	com.britemoon.cps.tgt.Filter filter = new com.britemoon.cps.tgt.Filter(sFilterId);
	com.britemoon.cps.tgt.Filter filter = new com.britemoon.cps.tgt.Filter();
	filter.s_filter_name = sFilterName;
	filter.s_cust_id = cust.s_cust_id;
	filter.s_filter_name = sFilterName;
	if(filter.s_status_id == null) filter.s_status_id = "10";
	filter.s_type_id = sTypeId;

	FilterParams fps = new FilterParams();

	int l = (sParamNames==null)?0:sParamNames.length;

	for(int i = 0; i<l; i++)
	{
		FilterParam fp = new FilterParam();
		fp.s_param_id = String.valueOf(i);
		fp.s_param_name = sParamNames[i];
		fp.s_integer_value = sIntegerValues[i];
		fp.s_string_value = sStringValues[i];
		fp.s_date_value = sDateValues[i];
		fps.add(fp);
	}

	filter.m_FilterParams = fps;

	filter.s_filter_id = null;
	filter.save();
	System.out.println("Filter ID: " + filter.s_filter_id);
	
	JSONObject result = new JSONObject();
	
	result.put("resultFilterId", Long.parseLong(filter.s_filter_id) + 1);
	
	out.println(result);
%>
<%!

	private static void drawFilter(String sCustId, String sFilterId, JspWriter out) throws Exception
	{
		com.britemoon.cps.tgt.Filter fi = null;
		if(sFilterId != null)
		{
			fi = new com.britemoon.cps.tgt.Filter();
			fi.s_filter_id = sFilterId;
			if(fi.retrieve() < 1) return;
		}
		else
		{
			fi = getMultipartFilterPrototype(sCustId);
		}

		fi.s_usage_type_id = String.valueOf(FilterUsageType.HIDDEN);
		drawFilterGeneric(fi, out);
	}

	private static void drawFilterParts(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
	{

		drawFilterParts(null, filter, out);



	}

	private static void drawFilterParts(String sWrappingBooleanOperation, com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
	{

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
			drawFilterPart(sWrappingBooleanOperation, filter_part, out);
		}
	}

	private static void drawFilterPart(String sWrappingBooleanOperation, FilterPart filter_part, JspWriter out) throws Exception
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
			drawFilterPart(sWrappingBooleanOperation, child_filter, out);
			return;
		}

		String sBooleanOperation = getBooleanOperation(child_filter);
		if("NOT".equals(sBooleanOperation)) // ||  "NOP".equals(sBooleanOperation))
		{
			drawFilterParts(sBooleanOperation, child_filter, out);
			return;
		}

		drawFilterPart("NOP", child_filter, out);
	}

	private static void drawFilterPart(String sWrappingBooleanOperation, com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
	{

		out.println("<!-- FILTER PART START -->");


		out.println(filter.s_filter_id);

		out.println("NOT".equals(sWrappingBooleanOperation) );
		out.println("NOT".equals(sWrappingBooleanOperation));

// === === ===

		int nTypeId = Integer.parseInt(filter.s_type_id);

		if(filter.s_usage_type_id == null) filter.s_usage_type_id = String.valueOf(FilterUsageType.HIDDEN);
		int nUsageTypeId = Integer.parseInt(filter.s_usage_type_id);

		if((nTypeId == FilterType.MULTIPART)&&(nUsageTypeId == FilterUsageType.HIDDEN))
		{
			drawMultipartFilterPart(filter, out);
		}
		else
		{
			drawSimpleFilterPart(filter, out);
		}


	}

	private static void drawSimpleFilterPart(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
	{


		drawFilterGeneric(filter, out);

	}

	private static void drawMultipartFilterPart(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
	{
		String sPartName = null;
		if(filter.s_filter_name!=null) sPartName = filter.s_filter_name;
		else if(filter.s_filter_id!=null) sPartName = "(" + filter.s_filter_id + ")";


		drawFilterGeneric(filter, out);
	}

// === === ===

	private static void drawFilterGeneric(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
	{


		int nTypeId = Integer.parseInt(filter.s_type_id);

		if(filter.s_usage_type_id == null) filter.s_usage_type_id = String.valueOf(FilterUsageType.HIDDEN);
		int nUsageTypeId = Integer.parseInt(filter.s_usage_type_id);

		if	(
				((nTypeId == FilterType.MULTIPART)&&(nUsageTypeId == FilterUsageType.HIDDEN))
						||
						(nTypeId == FilterType.FORMULA)
						||
						(nTypeId == FilterType.CUSTOM_FORMULA)
		)
		{
			out.println("		<td xml_tag=filter>");
			out.println("<input type=hidden xml_tag=filter_id value='" + HtmlUtil.escape(filter.s_filter_id) + "'>");
			out.println("<input type=hidden xml_tag=filter_name value='" + HtmlUtil.escape(filter.s_filter_name) + "'>");
			out.println("<input type=hidden xml_tag=type_id value='" + HtmlUtil.escape(filter.s_type_id) + "'>");
			out.println("<input type=hidden xml_tag=cust_id value='" + HtmlUtil.escape(filter.s_cust_id) + "'>");
			out.println("<input type=hidden xml_tag=status_id value='" + HtmlUtil.escape(filter.s_status_id) + "'>");
			out.println("<input type=hidden xml_tag=origin_filter_id value='" + HtmlUtil.escape(filter.s_origin_filter_id) + "'>");
			out.println("<input type=hidden xml_tag=usage_type_id value='" + HtmlUtil.escape(filter.s_usage_type_id) + "'>");
		}

// === === ===

		if(nTypeId == FilterType.FORMULA || nTypeId == FilterType.CUSTOM_FORMULA)
			drawFormula(filter, out);
		else
		if((nTypeId == FilterType.MULTIPART)&&(nUsageTypeId == FilterUsageType.HIDDEN))
			drawMultipartFilter(filter, out);
		else
			drawSimpleFilter(filter, out);

	}


	private static void drawMultipartFilter(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
	{

		String sBooleanOperation = getBooleanOperation(filter);

		out.println("<!-- MULTIPART AND-OR FILTER START -->");


		drawFilterParts(filter, out);

	}

	private static void drawFormula(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
	{
		out.println("<!-- FORMULA START -->");

// === === ===

		Formula formula = filter.m_Formula;
		CustomFormula customFormula = filter.m_CustomFormula;

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

		if( customFormula == null )
		{
			customFormula = new CustomFormula();
			if(filter.s_filter_id != null)
			{
				customFormula.s_filter_id = filter.s_filter_id;
				customFormula.retrieve();
			}
			filter.m_CustomFormula = customFormula;
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




		CustAttrs formula_attrs = CustAttrsUtil.retrieve4filter(filter.s_cust_id, filter.s_filter_id);
		out.println(CustAttrsUtil.toHtmlOptions(formula_attrs, formula.s_attr_id, customFormula.s_attr_id, customFormula.s_type_id, true));

		int nTypeId = Integer.parseInt(filter.s_type_id);
		boolean isCustom = nTypeId == FilterType.CUSTOM_FORMULA;

		boolean bShowValue2 = false;
		if(isCustom) {
			bShowValue2 = (String.valueOf(CompareOperation.BETWEEN).equals(customFormula.s_operation_id));
		} else {
			bShowValue2 = (String.valueOf(CompareOperation.BETWEEN).equals(formula.s_operation_id));
		}

		String operationId = isCustom ? customFormula.s_operation_id : formula.s_operation_id;
		String positiveFlag = isCustom ? customFormula.s_positive_flag: formula.s_positive_flag;
		String webFormulaOperationId = isCustom ? customFormula.s_web_formula_operation_id : "";
		String webFormulaTimeOperationId = isCustom ? customFormula.s_web_formula_time_operation_id : "";
		String value1 = isCustom ? customFormula.s_value1 : formula.s_value1;
		String value2 = isCustom ? customFormula.s_value2 : formula.s_value2;
		String time_value1 = isCustom ? customFormula.s_time_value1 : "";
		String time_value2 = isCustom ? customFormula.s_time_value2 : "";


	}

	private static void drawSimpleFilter(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
	{
		int nTypeId = 0;
		if(filter.s_type_id != null) nTypeId = Integer.parseInt(filter.s_type_id);
//		if((nTypeId < 31) || (nTypeId > 59)) // 31-50 - filters from reports, not editable
//		{
//
//		} sonradan çıkartıldı


	}

// === === ===

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

	private static void drawFormulaPrototype(String sCustId, JspWriter out) throws Exception
	{
		drawFilterPart("NOP", getFormulaPrototype(sCustId), out);
	}

	private static void drawMultipartFilterPrototype(String sCustId, JspWriter out) throws Exception
	{
		drawFilterPart("NOP", getMultipartFilterPrototype(sCustId), out);
	}

%>




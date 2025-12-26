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

//boolean bSTANDARD_UI = (com.britemoon.cps.UIEnvironment.n_ui_type_id == com.britemoon.cps.UIType.STANDARD);


//com.britemoon.cps.tgt.Filter fi = new com.britemoon.cps.tgt.Filter();

//out.println("zzz" +bSTANDARD_UI);

//String sDebug =
//	" drawFilterParts():\t" + 
//	" filter_id = " + filter.s_filter_id;
//System.out.println(sDebug);
//System.out.flush();

out.println("<!-- FILTER PARTS START -->");

// === === ===

out.println("<table border=0 width='100%' cellspacing=0 cellpadding=0 class=filter_parts>");

out.println("	<tr>");
out.println("		<td>");
out.println("			<table cellspacing=0 cellpadding=4 border=0>");
out.println("				<tr>");
out.println("					<td align=left valign=middle>");
out.println("						<a class=subactionbutton href='javascript:void(0);' onclick='filter_part_add_formula(event);'>Add Field Filter</a>");
out.println("					</td>");


//if(com.britemoon.UIType.STANDARD == 200){

	out.println("					<td align=left valign=middle>");
	out.println("						<a class=subactionbutton href='javascript:void(0);' onclick='filter_part_select_filter(event);'>Select Advanced Filter</a>");
	out.println("					</td>");


	out.println("					<td align=left valign=middle>");
	out.println("						<a class=subactionbutton href='javascript:void(0);' onclick='filter_parts_group(this,event);'>Group Items</a>");
	out.println("					</td>");
	out.println("					<td align=left valign=middle>");
	out.println("						<a class=subactionbutton href='javascript:void(0);' onclick='filter_parts_ungroup(event);'>Ungroup Items</a>");
	out.println("					</td>");
	out.println("					<td align=left valign=middle>");
	out.println("						<a class=subactionbutton href='javascript:void(0);' onclick='filter_parts_inex(this,event);'>Include/Exclude</a>");
	out.println("					</td>");
//}
out.println("				</tr>");
out.println("			</table>");
out.println("		</td>");
out.println("	</tr>");

out.println("	<tr>");
out.println("		<td xml_tag=filter_parts>");

// === === ===

drawFilterParts(null, filter, out);

// === === ===

out.println("		</td>");
out.println("	</tr>");
out.println("</table>");

// === === ===

out.println("<!-- FILTER PARTS END -->");

}

private static void drawFilterParts(String sWrappingBooleanOperation, com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
{
//String sDebug =
//	" drawFilterParts():\t" + 
//	" sWrappingBooleanOperation = " + sWrappingBooleanOperation +
//	" filter_id = " + filter.s_filter_id;
//System.out.println(sDebug);
//System.out.flush();

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
//String sDebug =
//	" drawFilterPart():\t" + 
//	" sWrappingBooleanOperation = " + sWrappingBooleanOperation +
//	" child_filter_id = " + filter_part.s_child_filter_id;
//System.out.println(sDebug);
//System.out.flush();

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
//String sDebug =
//	" drawFilterPart():\t" + 
//	" sWrappingBooleanOperation = " + sWrappingBooleanOperation +
//	" filter_id = " + filter.s_filter_id;
//System.out.println(sDebug);
//System.out.flush();

out.println("<!-- FILTER PART START -->");

// === === ===

out.println("<table border=0 width='100%' cellspacing=0 cellpadding=2 class=filter_part xml_tag=filter_part>");
out.println("	<tr>");

// === === ===

out.println("		<td>");	
out.println("<table border=0 width='100%' cellspacing=0 cellpadding=1 class=filter_part_capsule>");
out.println("	<tr>");

// === === ===

out.println("		<td width=1>");
out.println("			<input onchange=\"if(this.checked){this.setAttribute('checked','checked');}else{this.removeAttribute('checked');}\" type=checkbox xml_tag=group_ungroup_checkbox>");
out.println("		</td>");
out.println("		<td width=1>");
out.println("			<INPUT type=hidden xml_tag=child_filter_id value='" + filter.s_filter_id + "'>");
out.println(" 			<select size=1 xml_tag=boolean_operation style='display:none;'>");
out.println("				<option value=NOP></option>");
out.println("				<option value=NOT" + ("NOT".equals(sWrappingBooleanOperation)?" selected":"") + ">NOT</option>");
out.println("			</select>");
out.println("			<span xml_tag=boolean_text>" + ("NOT".equals(sWrappingBooleanOperation)?"Exclude: ":"") + "</span>");
out.println("		</td>");

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

// === === ===

out.println("	</tr>");
out.println("</table>");
out.println("		</td>");

// === === ===

out.println("	</tr>");
out.println("</table>");

// === === ===

out.println("<!-- FILTER PART END -->");

}

private static void drawSimpleFilterPart(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
{
//String sDebug =
//	" drawSimpleFilterPart():\t" + 
//	" filter_id = " + filter.s_filter_id;
//System.out.println(sDebug);
//System.out.flush();

out.println("		<td>");	

drawFilterGeneric(filter, out);

out.println("		</td>");
out.println("		<td width=1 align=right>");
out.println("<table border=0 width=1 align=right>");
out.println("	<tr>");
out.println("		<td class=filter_part_control onclick='filter_part_delete(this,event);'>");
out.println("			&nbsp;X&nbsp;");
out.println("		</td>");
out.println("	</tr>");
out.println("</table>");
out.println("		</td>");
}

private static void drawMultipartFilterPart(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
{
//String sDebug =
//	" drawMultipartFilterPart():\t" + 
//	" filter_id = " + filter.s_filter_id;
//System.out.println(sDebug);
//System.out.flush();

String sPartName = null;
if(filter.s_filter_name!=null) sPartName = filter.s_filter_name;
else if(filter.s_filter_id!=null) sPartName = "(" + filter.s_filter_id + ")";

out.println("		<td align=left>");
//out.println("			&nbsp;Subgroup:&nbsp;<INPUT type=text size=75 value='" + HtmlUtil.escape(sPartName) + "' onchange='filter_name_set(this);'>");
out.println("			&nbsp;Subgroup:&nbsp;" + HtmlUtil.escape(sPartName));
out.println("		</td>");
out.println("		<td align=right>");
out.println("<table border=0 width=1 align=right>");
out.println("	<tr>");
out.println("		<td class=filter_part_control onclick='filter_part_min_max(this,event);'>");
out.println("			&nbsp;_&nbsp;");
out.println("		</td>");
out.println("		<td class=filter_part_control onclick='filter_part_delete(this,event);'>");
out.println("			&nbsp;X&nbsp;");
out.println("		</td>");
out.println("	</tr>");
out.println("</table>");
out.println("		</td>");

out.println("	</tr>");

out.println("	<tr>");
out.println("		<td>&nbsp;</td>");
out.println("		<td colspan=3>");
			drawFilterGeneric(filter, out);
out.println("		</td>");
}

// === === ===

private static void drawFilterGeneric(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
{
//String sDebug =
//	" drawFilterGeneric():\t" + 
//	" filter_id = " + filter.s_filter_id;
//System.out.println(sDebug);
//System.out.flush();

out.println("<!-- FILTER GENERIC START -->");

out.println("<table border=0 width='100%' cellspacing=0 cellpadding=0 class=filter_generic>");
out.println("	<tr>");

// === === ===

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
	else
	{
out.println("		<td>");
	}
	
// === === ===

	if(nTypeId == FilterType.FORMULA || nTypeId == FilterType.CUSTOM_FORMULA)
		drawFormula(filter, out);
	else
		if((nTypeId == FilterType.MULTIPART)&&(nUsageTypeId == FilterUsageType.HIDDEN))
			drawMultipartFilter(filter, out);
	else
		drawSimpleFilter(filter, out);

// === === ===
	
out.println("		</td>");
out.println("	</tr>");
out.println("</table>");

out.println("<!-- FILTER GENERIC END -->");
}


private static void drawMultipartFilter(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
{
//String sDebug =
//	" drawMultipartFilter():\t" + 
//	" filter_id = " + filter.s_filter_id;
//System.out.println(sDebug);
//System.out.flush();

	String sBooleanOperation = getBooleanOperation(filter);

out.println("<!-- MULTIPART AND-OR FILTER START -->");	

out.println("<table border=0 width='100%' cellspacing=0 cellpadding=0 class=filter_multipart>");

//out.println("	<tr>");
//out.println("		<td align=center width=1>");
//out.println("		</td>");
//out.println("		<td>");
//out.println("			<table cellspacing=0 cellpadding=4 border=0>");
//out.println("				<tr>");
//out.println("					<td align=left valign=middle>");
//out.println("						<a class=subactionbutton href='javascript:void(0);' onclick='filter_part_add_formula();'>Add Field Filter</a>");
//out.println("					</td>");
//out.println("					<td align=left valign=middle>");
//out.println("						<a class=subactionbutton href='javascript:void(0);' onclick='filter_part_select_filter();'>Select Advanced Filter</a>");
//out.println("					</td>");
//out.println("					<td align=left valign=middle>");
//out.println("						<a class=subactionbutton href='javascript:void(0);' onclick='filter_parts_group();'>Group Items</a>");
//out.println("					</td>");
//out.println("					<td align=left valign=middle>");
//out.println("						<a class=subactionbutton href='javascript:void(0);' onclick='filter_parts_ungroup();'>Ungroup Items</a>");
//out.println("					</td>");
//out.println("					<td align=left valign=middle>");
//out.println("						<a class=subactionbutton href='javascript:void(0);' onclick='filter_parts_inex();'>Include/Exclude</a>");
//out.println("					</td>");
//out.println("				</tr>");
//out.println("			</table>");
//out.println("		</td>");
//out.println("	</tr>");

out.println("	<tr>");
out.println("		<td align=center valign=middle height=100% width=60>");
out.println("			<table border=0 height=100% cellpadding=0 cellspacing=0>");
out.println("				<tr>");
out.println("					<td style='padding:0px;' width=60 valign=bottom><img src=\"../../images/tgroup-upperbend.gif\"></td>");
out.println("				</tr>");
out.println("				<tr>");
out.println("					<td style='padding:0px;' height=100% background=\"../../images/tgroup-vertical.gif\">");
out.println(" 			<select size=1 xml_tag=boolean_operation>");
out.println("				<option value=NOP" + ("NOP".equals(sBooleanOperation)?" selected":"") + "></option>");
out.println("				<option value=OR" + ("OR".equals(sBooleanOperation)?" selected":"") + ">OR</option>");
out.println("				<option value=AND" + ("AND".equals(sBooleanOperation)?" selected":"") + ">AND</option>");
out.println("			</select>");
out.println("					</td>");
out.println("				</tr>");
out.println("				<tr>");
out.println("					<td style='padding:0px;' width=60 valign=top><img src=\"../../images/tgroup-lowerbend.gif\"></td>");
out.println("				</tr>");
out.println("			</table>");
out.println("		</td>");
out.println("		<td valign=middle align=left>");

	drawFilterParts(filter, out);

out.println("		</td>");
out.println("	</tr>");

out.println("</table>");

// === === ===

out.println("<!-- MULTIPART AND-OR FILTER END -->");	
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



// === === ===

out.println("<table border=0 cellspacing=0 cellpadding=2 class=formula xml_tag=formula>");
out.println("	<tr>");
out.println("		<td width=1>");
out.println("			&nbsp;&nbsp;");
out.println("		</td>");
out.println("		<td width=1>");
out.println("			<input type=hidden value=" + formula.s_filter_id + " xml_tag=formula_id>");
out.println("			<select size=1 id=rmzn_select xml_tag=attr_id onchange='checkValues(this, false)'>");
out.println("				<option></option>");

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

out.println("			</select>");
out.println("		</td>");
out.println("		<td style='display:none;' width=1>");
out.println("			<input type=hidden size=1 xml_tag=type_id value='"+(isCustom ? customFormula.s_type_id : 0)+"'>");
out.println("		</td>");
out.println("		<td width=1 " + (!isCustom ? "style='display:none;'":"") + ">");
out.println("			<select size=1 xml_tag=web_formula_time_operation_id onchange='doTimeOperationChange(this)'>");
out.println("				<option value=10 " + ((isCustom && webFormulaTimeOperationId!=null && webFormulaTimeOperationId.equals("10")) ? "selected" : "") +">All Time</option>");
out.println("				<option value=20 " + (isCustom && webFormulaTimeOperationId!=null && webFormulaTimeOperationId.equals("20") ? "selected" : "") +">Last Days</option>");
out.println("				<option value=30 " + (isCustom && webFormulaTimeOperationId!=null && webFormulaTimeOperationId.equals("30") ? "selected" : "") +">Time Period</option>");
out.println("			</select>");
out.println("		</td>");
out.println("		<td width=1 " + ((isCustom && (webFormulaTimeOperationId!=null && !webFormulaTimeOperationId.equals("10"))) ? "":"style='display:none;'") + ">");
out.println("			<input type=text  onchange='input_rmzn(this,this.value)' xml_tag=time_value1 value='" + HtmlUtil.escape(time_value1) +"' size=15 maxlength=255>");
out.println("		</td>");
out.println("		<td width=1 " + ((isCustom && (webFormulaTimeOperationId!=null && webFormulaTimeOperationId.equals("30"))) ? "":"style='display:none;'") + ">");
out.println("			<input type=text onchange='input_rmzn(this,this.value)' xml_tag=time_value2 value='" + HtmlUtil.escape(time_value2) +"' size=15 maxlength=255>");
out.println("		</td>");
out.println("		<td width=1 " + (!isCustom ? "style='display:none;'":"") + ">");
out.println("			<select size=1 xml_tag=web_formula_operation_id>");
out.println("				<option value=10 " + (isCustom && webFormulaOperationId.equals("10") ? "selected" : "") +">Value</option>");
out.println("				<option value=20 " + (isCustom && webFormulaOperationId.equals("20") ? "selected" : "") +">Total</option>");
out.println("				<option value=30 " + (isCustom && webFormulaOperationId.equals("30") ? "selected" : "") +">Count</option>");
out.println("				<option value=40 " + (isCustom && webFormulaOperationId.equals("40") ? "selected" : "") +">Average</option>");
out.println("			</select>");
out.println("		</td>");
out.println("		<td width=1>");
out.println("			<select size=1 xml_tag=positive_flag onchange='doOperationChange2(this)'>");
out.println("				<option value=1>IS</option>");
out.println("				<option value=-1" + (("-1".equals(positiveFlag))?" selected":"") + ">IS NOT</option>");
out.println("			</select>");
out.println("		</td>");
out.println("		<td width=1>");
out.println("			<select size=1 xml_tag=operation_id onchange='doOperationChange(this)'>");
out.println("					" + CompareOperation.toHtmlOptions(operationId));
out.println("			</select>");
out.println("		</td>");
out.println("		<td width=1>");
out.println("			<input type=text  onchange='input_rmzn(this,this.value)' xml_tag=value1 value='" + HtmlUtil.escape(value1) +"' size=30 maxlength=255" + disableValues + ">");
out.println("		</td>");
out.println("		<td width=1>");
out.println("			<input type=text onchange='input_rmzn(this,this.value)' xml_tag=value2 value='" + HtmlUtil.escape(value2) +"' size=30 maxlength=255" + disableValues + ""  + ((bShowValue2)?"":" style='display: none'") + ">");
out.println("		</td>");
out.println("		<td width=1 xml_tag=values_list" + showSelVals + " nowrap>");
out.println("			<nobr>&nbsp;<a class=subactionbutton href=# onclick='selectValuesList();'>Select Values</a>&nbsp;</nobr>");
out.println("		</td>");
out.println("		<td width=1>");
out.println("			&nbsp;&nbsp;");
out.println("		</td>");
out.println("	</tr>");
out.println("</table>");

// === === ===

out.println("<!-- FORMULA END -->");
}

private static void drawSimpleFilter(com.britemoon.cps.tgt.Filter filter, JspWriter out) throws Exception
{
out.println("<!-- SIMPLE FILTER START -->");

// === === ===

out.println("<table border=0 width='100%' cellspacing=0 cellpadding=0 class=filter_simple>");
out.println("	<tr>");
out.println("		<td nowrap>");
out.println("			" + HtmlUtil.escape(filter.s_filter_name));
out.println("		</td>");
out.println("		<td width=1>");

	int nTypeId = 0;
	if(filter.s_type_id != null) nTypeId = Integer.parseInt(filter.s_type_id);
	if((nTypeId < 31) || (nTypeId > 59)) // 31-50 - filters from reports, not editable
	{
out.println("			<table border=0 cellspacing=0 cellpadding=0 class=menu>");
out.println("				<tr>");
out.println("					<td align=center nowrap>");
out.println("						&nbsp;<a class=savebutton href='javascript:void(0);' onclick='filter_part_edit(event);'>Edit</a>&nbsp;");
out.println("					</td>");
out.println("				</tr>");
out.println("			</table>");
	}

out.println("		</td>");
out.println("	</tr>");
out.println("</table>");

// === === ===

out.println("<!-- SIMPLE FILTER END -->");

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

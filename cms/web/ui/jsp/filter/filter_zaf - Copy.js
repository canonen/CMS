function is_filter_structure_valid(filter)
{
	if (filter == null) filter = getChildByXmlTag(root, 'filter');

	var filter_parts = getChildByXmlTag(filter, 'filter_parts');
	if (filter_parts == null)
	{
		// not a multipart filter
		return true;
	}
	
	var l = 0;
	filter_parts = getChildrenByXmlTag(filter_parts, 'filter_part');
	if (filter_parts != null) l = filter_parts.length;

	var boolean_operation = getChildByXmlTag(filter, 'boolean_operation');
	if (boolean_operation == null) return report_error();
	
	var bo = boolean_operation.value;
	if( bo == null ) return report_error(boolean_operation);

	if(((bo == 'NOP') || (bo == 'NOT')) && (l > 1 )) return report_error(boolean_operation);
	if(((bo == 'AND') || (bo == 'OR')) && (l < 2 )) return report_error(boolean_operation);

	for(var i=0; i<l; ++i)
	{
		filter = getChildByXmlTag(filter_parts[i], 'filter');
		if (filter==null) continue;
		if (!is_filter_structure_valid(filter)) return false;
	}

	return true;
}

function report_error(obj)
{
	alert("Invalid target group structure!");
	if(obj!=null) obj.focus();
	return false;
}

function filter_part_delete(obj,event)
{
	<% if (bCanEditParts) { %>
	

	
          element = event.srcElement? event.srcElement : event.target;

          if(!confirm('Are you sure?')) return;
          
          
          
          

          filter_part = getParentByXmlTag(element, 'filter_part');
          filter_part_parent = getParentByXmlTag(filter_part, 'filter_parts');
          
      	  filter_part_parent.removeChild(filter_part);
          
     <% } else { %>
          return
     <% } %>
}

//function filter_part_min_max()
//{
//	element = event.srcElement; 
//	filter_part = getParentByXmlTag(element, 'filter_part');
//	group_details = filter_part.rows(1);
//	var sd = group_details.style.display;
//	if( sd == 'none') sd = '';
//	else sd = 'none';
//	group_details.style.display = sd;
//}

function filter_part_min_max(obj,event)
{
	<% if (bCanEditParts) { %>
          element = event.srcElement? event.srcElement : event.target;
          filter_part = getParentByXmlTag(element, 'filter_part');
          group_details = filter_part.rows[0].cells[0];
          group_details = group_details.children[0];
          group_details = group_details.rows[1];
          var sd = group_details.style.display;
          if( sd == 'none') sd = '';
          else sd = 'none';
          group_details.style.display = sd;
     <% } else { %>
          return
     <% } %>
}

// === === ===

function filter_name_set()
{
	element = event.srcElement;
	filter_part = getParentByXmlTag(element, 'filter_part');	
	filter = getChildByXmlTag(filter_part, 'filter');
	filter_name = getChildByXmlTag(filter, 'filter_name');
	filter_name.value = element.value;
}

// === === ===

var lastSrcElement = null;

var windowName = "";
var windowFeatures = "dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, height=300, width=700";

function filter_part_edit(event)
{
	<% if (bCanEditParts) { %>
          element =event.srcElement? event.srcElement : event.target;
          lastSrcElement = element;

          filter_part = getParentByXmlTag(element, 'filter_part');
          filter_id = getChildByXmlTag(filter_part, 'child_filter_id');

          URL = "filter_part_edit.jsp?usage_type_id=<%= sUsageTypeId %>&filter_id=" + filter_id.value;

          SmallWin = window.open(URL, windowName, windowFeatures);
     <% } else { %>
          return
     <% } %>
}

function filter_part_select_filter(event)
{
	<% if (bCanEditParts) { %>
	
          lastSrcElement = event.srcElement? event.srcElement : event.target;
          URL = "select/select.jsp?usage_type_id=<%= sUsageTypeId %>";
          SmallWin = window.open(URL, windowName, windowFeatures);
     <% } else { %>
          return
     <% } %>
}

function filter_part_replace_filter(obj)
{  
	filter_part_new = getChildByXmlTag(obj, 'filter_part');
	filter_part_old = getParentByXmlTag(lastSrcElement, 'filter_part');
	filter_part_old.children[0].children[0].children[0].innerHTML=
		filter_part_new.children[0].children[0].children[0].innerHTML;
}

function filter_part_add_filter(obj)
{
	<% if (bCanEditParts) { %>
     	filter_part_add_part(obj);
     <% } else { %>
          return
     <% } %>
}

function filter_part_add_group()
{
	<% if (bCanEditParts) { %>
     	filter_part_add_part(group_prototype);
     <% } else { %>
          return
     <% } %>
}

function filter_part_add_formula(event)
{
	<% if (bCanEditParts) { %>
     	filter_part_add_part(document.getElementById('formula_prototype'),event);
     <% } else { %>
          return
     <% } %>
}

function filter_part_add_part(obj,event)
{
	filter_part_add(obj,event)
}

function filter_part_add(html,event)
{
	  

	<% if (bCanEditParts) { %>
          element = lastSrcElement;
          
          if(event!=null) element = event.srcElement? event.srcElement : event.target;

          filter = getParentByXmlTag(element, 'filter');
          
          filter_parts = getChildByXmlTag(filter, 'filter_parts');
          
          filter_parts.innerHTML += html.innerHTML;

/*
	var boolean_operation = getChildByXmlTag(filter, 'boolean_operation');
	if(
		(boolean_operation == null)||
		(
			(boolean_operation != 'AND')&&(boolean_operation == 'OR')
		)
	) do_auto_group(filter_parts);
*/
     <% } else { %>
          return
     <% } %>
}

function do_auto_group(filter_parts)
{
	parts_to_group = getChildrenByXmlTag(filter_parts, 'filter_part');
	var l = parts_to_group.length;
	if (l != 2) return;

	for(var i=0; i<l; ++i)
	{
		filter_part = parts_to_group[i];
		group_ungroup_checkbox = getChildByXmlTag(filter_part, 'group_ungroup_checkbox');
		group_ungroup_checkbox.checked = true;
	}
	
	filter_parts_group(filter_parts);
}

// === === ===

function filter_parts_inex(obj,event)
{
	<% if (bCanEditParts) { %>
          element = event.srcElement? event.srcElement : event.target;
          filter = getParentByXmlTag(element, 'filter');
          filter_parts = getChildByXmlTag(filter, 'filter_parts');

          filter_parts_to_inex = getChildrenByXmlTag(filter_parts, 'filter_part');

          var l = filter_parts_to_inex.length;

          for(var i=0; i<l; ++i)
          {
               filter_part = filter_parts_to_inex[i];

               group_ungroup_checkbox = getChildByXmlTag(filter_part, 'group_ungroup_checkbox');
               if(group_ungroup_checkbox==null) continue;

               boolean_operation = getChildByXmlTag(filter_part, 'boolean_operation');
               boolean_text = getChildByXmlTag(filter_part, 'boolean_text');

               if(group_ungroup_checkbox.checked == true)
               {
                    curVal = boolean_operation[boolean_operation.selectedIndex].value;
                    if (curVal == "NOP")
                    {
                         boolean_operation[1].selected = true;
			 boolean_text.innerText = "Exclude";
			 boolean_text.textContent = "Exclude";

                    }
                    else
                    {
                         boolean_operation[0].selected = true;
                         boolean_text.innerText = "";
			 boolean_text.textContent = "";
                    }
               }
               group_ungroup_checkbox.checked = false;
          }
     <% } else { %>
          return
     <% } %>
}


// === === ===

function filter_parts_group(obj,event)
{
	<% if (bCanEditParts) { %>
          element = obj;
          if(element==null) element = event.srcElement? event.srcElement : event.target;

          filter = getParentByXmlTag(element, 'filter');

          filter_parts_old = getChildByXmlTag(filter, 'filter_parts');
          
          
          
          filter_parts_old.innerHTML = group_prototype.innerHTML + filter_parts_old.innerHTML;
          
         
	
          filter_part_new = getChildByXmlTag(filter_parts_old, 'filter_part');
          
          
          
          
          filter_new = getChildByXmlTag(filter_part_new, 'filter');
          filter_parts_new = getChildByXmlTag(filter_new, 'filter_parts');

          filter_parts_move(filter_parts_old, filter_parts_new);
          
     <% } else { %>
          return
     <% } %>
}

function filter_parts_ungroup(event)
{
	<% if (bCanEditParts) { %>
          element = event.srcElement? event.srcElement : event.target; 
          filter = getParentByXmlTag(element, 'filter');

          parent_filter = getParentByXmlTag(filter, 'filter');
          if(parent_filter == null)
          {
               alert('Unable to ungroup top level group items.');
               return;
          }

          filter_parts_old = getChildByXmlTag(filter, 'filter_parts');
          filter_parts_new = getChildByXmlTag(parent_filter, 'filter_parts');

          filter_parts_move(filter_parts_old, filter_parts_new);
     <% } else { %>
          return
     <% } %>
}

function filter_parts_move(filter_parts_old, filter_parts_new)
{
	<% if (bCanEditParts) { %>
          filter_parts_to_move = getChildrenByXmlTag(filter_parts_old, 'filter_part');

          var l = filter_parts_to_move.length;
          
          //alert('NUMBER  '+l);
          
          var docContainer = '';

          for(var i=0; i<l; ++i)
          {
          
          	//alert('NUMBER  '+i);
          
               filter_part = filter_parts_to_move[i];
               
               //alert('NUMBER  '+i+' part 1 ');
               
               

               group_ungroup_checkbox = getChildByXmlTag(filter_part, 'group_ungroup_checkbox');
               
               //alert('NUMBER  '+i+' part 2 ');
               
               if(group_ungroup_checkbox==null) continue;
               
               //alert('NUMBER  '+i+' part 3 ');
               
               //alert('c  '+group_ungroup_checkbox.value+' part 3 ');

               if(group_ungroup_checkbox.checked)
               {
               	//alert('NUMBER  '+filter_part.innerHTML);
               
               		
               		filter_parts_new.appendChild(filter_part);
               		
               		
               		
                    
                    //alert('NUMBER  '+i+' part 5 ');
               }
               
               //alert('NUMBER  '+i+' part 6 ');
               
               
               //group_ungroup_checkbox.checked = false;
               //alert('NUMBER  '+i+' part 7 ');
          }
          
     <% } else { %>
          return
     <% } %>
}

// === === ===

function getParentByXmlTag(obj, parent_name)
{
	oResult = null;
	if(obj==null) return oResult;
	

	for(oParent=obj.parentNode; oParent!=null; oParent=oParent.parentNode)
	{
	
		if(oParent.getAttribute('xml_tag') == parent_name)
		{
			oResult = oParent;
			break;
		}
		
		
		
		
		
		
		
	}
	return oResult;
}

function getChildByXmlTag(obj, child_xml_tag)
{
	var oResult = null;

	if(obj==null) return oResult;

	var children = obj.children;
	
	

	if(children == null) return oResult;

	var l = children.length;
	
	

	for(var i=0; i<l; ++i)
	{
		
		
		
		
		var oChild = children[i];
		
		

		if(oChild.getAttribute('xml_tag') == null) {
			oChild = getChildByXmlTag(oChild, child_xml_tag);
			
		}
		if((oChild!=null)&&(oChild.getAttribute('xml_tag') == child_xml_tag))
		{
			return oChild;
		}
	}

	return oResult;
}

function getChildrenByXmlTag(obj, child_xml_tag)
{
	var oResults = new Array();

	if(obj==null) return oResults;

	var children = obj.children;

	if(children == null) return oResults;

	var l = children.length;

	for(var i=0; i<l; ++i)
	{
		var oChild = children[i];

		if(oChild.getAttribute('xml_tag') == null) 
			oResults = oResults.concat(getChildrenByXmlTag(oChild, child_xml_tag));

		if((oChild!=null)&&(oChild.getAttribute('xml_tag') == child_xml_tag))
			oResults[oResults.length] = oChild;
	}
	return oResults;
}

// === === ===

function build_xml()
{
	var xml = '';

	var filter = getChildByXmlTag(root, 'filter');
	if (filter!=null) xml = build_filter_xml(filter, true);

	filter_form.filter_xml.value = xml;
}

function build_filter_xml(filter, is_top)
{
	var xml = '<filter>';

	var filter_id = getChildByXmlTag(filter, 'filter_id');
	if(filter_id != null) xml += buildTextElement('filter_id', filter_id.value);

	var filter_name = getChildByXmlTag(filter, 'filter_name');
	if(filter_name != null) xml += buildCDataElement('filter_name', filter_name.value);

	var type_id = getChildByXmlTag(filter, 'type_id');
	if(type_id != null) xml += buildTextElement('type_id', type_id.value);

	var cust_id = getChildByXmlTag(filter, 'cust_id');
	if(cust_id != null) xml += buildTextElement('cust_id', cust_id.value);

	var status_id = getChildByXmlTag(filter, 'status_id');
	if(status_id != null) xml += buildTextElement('status_id', status_id.value);

	var origin_filter_id = getChildByXmlTag(filter, 'origin_filter_id');
	if(origin_filter_id != null) xml += buildTextElement('origin_filter_id', origin_filter_id.value);

	var usage_type_id = getChildByXmlTag(filter, 'usage_type_id');
	if(usage_type_id != null) xml += buildTextElement('usage_type_id', usage_type_id.value);

	// === === ===

	if(type_id.value == '0')
	{
		var filter_parts = getChildByXmlTag(filter, 'filter_parts');
		if(filter_parts!=null) xml += build_filter_parts_xml(filter_parts);

		var boolean_operation = getChildByXmlTag(filter, 'boolean_operation');
		if(boolean_operation!=null)
		{
			boolean_operation_xml = buildCDataElement('string_value', boolean_operation.value);
			var filter_params_xml =
				'<filter_params><filter_param>'+
				'<param_id>1</param_id>'+
				'<param_name><![CDATA[BOOLEAN OPERATION]]></param_name>'+
				boolean_operation_xml +
				'</filter_param></filter_params>';
			xml += filter_params_xml;
		}

	}
	if(type_id.value == '100' || type_id.value == '101')
	{
		var formula = getChildByXmlTag(filter, 'formula');
		if(formula!=null) xml += build_formula_xml(formula);
	}
	else
	{
		//var filter_params = getChildByXmlTag(filter, 'filter_params');
		//if(filter_params!=null) xml += build_filter_params_xml(filter_params);
	}

	// === === ===

	if(is_top) xml += build_preview_attrs_xml();

	xml += '</filter>';
	return xml;
}

function build_preview_attrs_xml()
{
	xml='<preview_attrs>';

	var ops = filter_form.target.options;
	for(var i=0; i < ops.length; ++i)
	{
		xml += '<preview_attr>'
		xml += '<attr_id>' + ops[i].value + '</attr_id>';
		xml += '<display_seq>' + i + '</display_seq>';
		xml += '</preview_attr>';
	}

	xml +='</preview_attrs>'
	return xml;
}

function build_formula_xml(formula)
{
	var xml = '<formula>';

	var filter_id = getChildByXmlTag(formula, 'filter_id');
	if(filter_id != null) xml += buildTextElement('filter_id', filter_id.value);

	var attr_id = getChildByXmlTag(formula, 'attr_id');
	if(attr_id != null) xml += buildTextElement('attr_id', attr_id.value);
	
	var typeId = getChildByXmlTag(formula, 'type_id');
	if(typeId != null) xml += buildTextElement('type_id', typeId.value);

	var operation_id = getChildByXmlTag(formula, 'operation_id');
	if(operation_id != null) xml += buildTextElement('operation_id', operation_id.value);
	
	var web_formula_operation_id = getChildByXmlTag(formula, 'web_formula_operation_id');
	if(web_formula_operation_id != null) xml += buildTextElement('web_formula_operation_id', web_formula_operation_id.value);
	
	var web_formula_time_operation_id = getChildByXmlTag(formula, 'web_formula_time_operation_id');
	if(web_formula_time_operation_id != null) xml += buildTextElement('web_formula_time_operation_id', web_formula_time_operation_id.value);

	var positive_flag = getChildByXmlTag(formula, 'positive_flag');
	if(positive_flag != null) xml += buildTextElement('positive_flag', positive_flag.value);
	
	if(web_formula_time_operation_id.value>10) {
		var time_value1 = getChildByXmlTag(formula, 'time_value1');
		if(time_value1 != null) xml += buildCDataElement('time_value1', time_value1.value);
	}
	
	if(web_formula_time_operation_id.value==30) {
		var time_value2 = getChildByXmlTag(formula, 'time_value2');
		if(time_value2 != null) xml += buildCDataElement('time_value2', time_value2.value);
	}

	var value1 = getChildByXmlTag(formula, 'value1');
	if(value1 != null) xml += buildCDataElement('value1', value1.value);

	var value2 = getChildByXmlTag(formula, 'value2');
	if(value2 != null) xml += buildCDataElement('value2', value2.value);

	xml += '</formula>';

	return xml;
}

function build_filter_params_xml(filter_params)
{
	//var xml = '<filter_params></filter_params>';
	//return xml;
	return '';
}

var display_seq = 1;

function build_filter_parts_xml(filter_parts_element)
{
	var xml = '<filter_parts>';

	var filter_parts = getChildrenByXmlTag(filter_parts_element, 'filter_part');

	var l = filter_parts.length;

	//display_seq = 1;

	for(var i=0; i<l; ++i)
	{
		xml += build_filter_part_xml(filter_parts[i])
	}

	xml += '</filter_parts>';

	return xml;
}


function build_filter_part_xml(filter_part_element)
{
	var xml = build_filter_part_xml_old(filter_part_element)
	
	var boolean_operation = getChildByXmlTag(filter_part_element, 'boolean_operation');
	if (boolean_operation.value != 'NOT') return xml;

	var xml =
		'<filter_part>' +
			buildTextElement('display_seq', display_seq) +
			'<filter>'+
				'<type_id>0</type_id>' +
				'<cust_id><%=cust.s_cust_id%></cust_id>' +
				'<status_id><%=FilterStatus.NEW%></status_id>' +
				'<usage_type_id><%=FilterUsageType.HIDDEN%></usage_type_id>' +
				'<filter_params>' +
					'<filter_param>'+
						'<param_id>1</param_id>'+
						'<param_name><![CDATA[BOOLEAN OPERATION]]></param_name>'+
						buildCDataElement('string_value', 'NOT') +
					'</filter_param>'+
				'</filter_params>'+
				'<filter_parts>' +
				xml +
				'</filter_parts>' +
			'</filter>'+
		'</filter_part>';

	display_seq++;

	return xml;
}

function build_filter_part_xml_old(filter_part_element)
{
	var xml = '<filter_part>';

	var parent_filter_id = getChildByXmlTag(filter_part_element, 'parent_filter_id');
	if(parent_filter_id != null) xml += buildTextElement('parent_filter_id', parent_filter_id.value);

	var child_filter_id = getChildByXmlTag(filter_part_element, 'child_filter_id');
	if(child_filter_id != null) xml += buildTextElement('child_filter_id', child_filter_id.value);

	xml += buildTextElement('display_seq', display_seq);
	display_seq++;

	var filter = getChildByXmlTag(filter_part_element, 'filter');
	if(filter!=null) xml += build_filter_xml(filter, false);

	xml += '</filter_part>';

	return xml;
}

// === === ===

function buildCDataElement(tag, val)
{
	return buildXmlElement(tag, val, 'CData');
}

function buildTextElement(tag, val)
{
	return buildXmlElement(tag, val, 'Text');
}

function buildXmlElement(tag, val, type)
{
	var xml = '';

	if(val==null) return xml;
	if(val=='null') return xml;

	val += '';

	if(val.length==null) return xml;
	if(val.length==0) return xml;

	xml = '<' + tag + '>';

//	if(type=='CData') xml += '<![CDATA[' + escape(val) + ']]>';
	if(type=='CData') xml += '<![CDATA[' + val + ']]>';
	else if(type=='Text') xml += val;

	xml += '</' + tag + '>';

	return xml;
}

// === === ===

function doTimeOperationChange(obj)
{
	element = event.srcElement; 
	obj[obj.selectedIndex].setAttribute("selected", "selected");
	formula = getParentByXmlTag(element, 'formula');
	var time_val1 = getChildByXmlTag(formula, 'time_value1');
	var time_val2 = getChildByXmlTag(formula, 'time_value2');
	attrID = getChildByXmlTag(formula, 'attr_id');

	time_val1.parentElement.style.display='none';
	time_val2.parentElement.style.display='none';
	if(element.value>10)
	{
		time_val1.parentElement.style.display='';
	}
	if(element.value==30)
	{
		time_val2.parentElement.style.display='';
	}
	
	checkValues(attrID, true);
}

function doOperationChange(obj)
{
	element = event.srcElement; 
	obj[obj.selectedIndex].setAttribute("selected", "selected");
	formula = getParentByXmlTag(element, 'formula');
	val2 = getChildByXmlTag(formula, 'value2');
	attrID = getChildByXmlTag(formula, 'attr_id');

	if(element.value == 70)
	{
		val2.style.display=''; // 70 = CompareOperation.BETWEEN
	}
	else
	{
		val2.value = '';
		val2.style.display='none';
	}
	
	checkValues(attrID, true);
}
function doOperationChange2(obj)
{
	element = event.srcElement; 
	obj[obj.selectedIndex].setAttribute("selected", "selected");
	formula = getParentByXmlTag(element, 'formula');
	val2 = getChildByXmlTag(formula, 'value2');
	attrID = getChildByXmlTag(formula, 'attr_id');

	if(element.value == 70)
	{
		val2.style.display=''; // 70 = CompareOperation.BETWEEN
	}
	else
	{
		val2.value = '';
		val2.style.display='none';
	}
	
	checkValues(attrID, true);
	
}
function input_rmzn(ish,val){
	ish.setAttribute('value',val);
  
}


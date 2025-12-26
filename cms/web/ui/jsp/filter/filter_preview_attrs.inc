<!-- PREVIEW ATTRS BEGIN -->
<TABLE cellpadding="0" cellspacing="0" border="0" class="main" width="100%"> 
	<TR> 
		<TD width="40%" valign="middle" align="center">
			<SELECT name="target" size="10" style="width: 100%" onDblClick="removeField()">
			<%CustAttrs preview_attrs = CustAttrsUtil.retrieve4filter_preview(filter.s_cust_id, filter.s_filter_id);%>
			<%=CustAttrsUtil.toHtmlOptions(preview_attrs)%>
			</SELECT>
		</TD>
		<TD valign="middle" align="center" nowrap>
			<p><a class="subactionbutton" href="javascript:void(0);" onclick="upField();">Move Up</a></p>
			<br>
			<p><a class="subactionbutton" href="javascript:void(0);" onclick="downField();">Move Down</a></p>
			<br>
			<p><a class="subactionbutton" href="javascript:void(0);" onclick="addField();"><< Move Left</a></p>
			<br>
			<p><a class="subactionbutton" href="javascript:void(0);" onclick="removeField();">Move Right >></a></p>
		</TD>
		<TD width="40%" valign="middle" align="center">
			<SELECT name="source" size="10" style="width: 100%" onDblClick="addField()">
			<%CustAttrs cust_attrs = CustAttrsUtil.retrieve4filter(cust.s_cust_id, filter.s_filter_id);%>
			<%=CustAttrsUtil.toHtmlOptions(cust_attrs)%>
			</SELECT>
		</TD>
	</TR>
</TABLE>
<!-- PREVIEW ATTRS END -->
<SELECT multiple name="preview_attrs" style="width: 0; height: 0;"></SELECT>
<SCRIPT>
	function upField()
	{
		var id, name;

		var ops = filter_form.target.options;
		var si = filter_form.target.selectedIndex;
		
		if( si < 1 ) return false;

		id = ops[si-1].value;
		name = ops[si-1].text;
		
		ops[si-1].value = ops[si].value;
		ops[si-1].text  = ops[si].text;

		ops[si].value = id;
		ops[si].text  = name;

		filter_form.target.selectedIndex--;
	}

	function downField()
	{
		var id, name;

		var ops = filter_form.target.options;
		var si = filter_form.target.selectedIndex;

		if( si < 0 ) return;
		if( si >= filter_form.target.length - 1 ) return false;

		id = ops[si+1].value;
		name = ops[si+1].text;
		
		ops[si+1].value = ops[si].value;
		ops[si+1].text  = ops[si].text;

		ops[si].value = id;
		ops[si].text  = name;
		
		filter_form.target.selectedIndex++;
	}

	function addField()
	{
		var ops = filter_form.source.options;
		var si = filter_form.source.selectedIndex;

		if( si == -1 ) return false;

		filter_form.target.options[filter_form.target.length] = new Option(ops[si].text, ops[si].value);
		ops[si] = null;
	}

	function removeField()
	{
		if( filter_form.target.selectedIndex == -1 ) return false;

		filter_form.target.options[filter_form.target.selectedIndex] = null;
		filter_form.source.selectedIndex = 0;

		for(var i=0; i < itemOpt.length; ++i) filter_form.source.options[i] = itemOpt[i]; 

		removeTargetFromSource()			
	}

	function removeTargetFromSource()
	{
		for(var i=0; i < filter_form.target.options.length; ++i)
		{
			for(var j=0; j < filter_form.source.options.length; ++j)
			{
				if( filter_form.target.options[i].value == filter_form.source.options[j].value )
				{
					filter_form.source.options[j] = null;
					--j;
				}
			}
		}
	}
	
	var itemOpt = new Array();
	function Init()
	{
		for(var i=0; i < filter_form.source.options.length; ++i) itemOpt[i] = filter_form.source.options[i];
		removeTargetFromSource();
	}

</SCRIPT>

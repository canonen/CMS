<!-- PREVIEW ATTRS BEGIN -->
<TABLE cellpadding="0" cellspacing="0" border="0" class="" width="100%"> 
	<TR> 
		<TD width="40%" align="center" valign="middle">
			<SELECT name="target" SIZE="15" STYLE="width: 275; height: 250" onDblClick="removeField()">
			<%CustAttrs preview_attrs = CustAttrsUtil.retrieve4Export_preview(cust.s_cust_id, sAttribList);%>
			<%=CustAttrsUtil.toHtmlOptionsExport(preview_attrs)%>			
			</SELECT>
		</TD>
		<TD valign="middle" align="center" nowrap>
			<p><a class="subactionbutton" href="javascript:void(0);" onclick="upField();">Move Up</a></p>
			<p><a class="subactionbutton" href="javascript:void(0);" onclick="downField();">Move Down</a></p>
			<br>
			<p><a class="subactionbutton" href="javascript:void(0);" onclick="addField();"><< Move Left</a></p>
			<p><a class="subactionbutton" href="javascript:void(0);" onclick="removeField();">Move Right >></a></p>
		</TD>
		<TD width="40%" valign="middle" align="center">
			<SELECT name="source" SIZE="15" STYLE="width: 275; height: 250" onDblClick="addField()">
			<%CustAttrs cust_attrs = CustAttrsUtil.retrieve4Export(cust.s_cust_id);%>
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

		var ops = FT.target.options;
		var si = FT.target.selectedIndex;
		
		if( si < 1 ) return false;

		id = ops[si-1].value;
		name = ops[si-1].text;
		
		ops[si-1].value = ops[si].value;
		ops[si-1].text  = ops[si].text;

		ops[si].value = id;
		ops[si].text  = name;

		FT.target.selectedIndex--;
	}

	function downField()
	{
		var id, name;

		var ops = FT.target.options;
		var si = FT.target.selectedIndex;

		if( si < 0 ) return;
		if( si >= FT.target.length - 1 ) return false;

		id = ops[si+1].value;
		name = ops[si+1].text;
		
		ops[si+1].value = ops[si].value;
		ops[si+1].text  = ops[si].text;

		ops[si].value = id;
		ops[si].text  = name;
		
		FT.target.selectedIndex++;
	}

	function addField()
	{
		var ops = FT.source.options;
		var si = FT.source.selectedIndex;
		
		if( si == -1 ) return false;

		FT.target.options[FT.target.length] = new Option(ops[si].text, ops[si].value);
		ops[si] = null;
	}

	function removeField()
	{
		if( FT.target.selectedIndex == -1 ) return false;

		FT.target.options[FT.target.selectedIndex] = null;
		FT.source.selectedIndex = 0;

		for(var i=0; i < itemOpt.length; ++i) FT.source.options[i] = itemOpt[i]; 

		removeTargetFromSource()			
	}

	function removeTargetFromSource()
	{
		for(var i=0; i < FT.target.options.length; ++i)
		{
			for(var j=0; j < FT.source.options.length; ++j)
			{
				if( FT.target.options[i].value == FT.source.options[j].value )
				{
					FT.source.options[j] = null;
					--j;
				}
			}
		}
	}
	
	var itemOpt = new Array();
	function Init()
	{
		for(var i=0; i < FT.source.options.length; ++i) itemOpt[i] = FT.source.options[i];
		removeTargetFromSource();
	}

</SCRIPT>

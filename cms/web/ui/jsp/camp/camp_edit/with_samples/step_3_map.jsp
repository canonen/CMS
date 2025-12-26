<% 
	String sExportName = null;
	String sFileUrl = null;
	String sDelimiter = null;
	rs = stmt.executeQuery(	"select export_name, delimiter, file_url FROM cque_camp_export WHERE camp_id = " + camp.s_camp_id);
	if  (rs.next()) {
		sExportName = rs.getString(1); 
		sDelimiter = rs.getString(2);
		sFileUrl = rs.getString(3);
	}
	if (sDelimiter == null || sDelimiter.equals("")) {
		sDelimiter = "\\t";
	}
	rs.close();
%>
<table class="listTable" cellspacing="1" cellpadding="2" width="100%">
	<tr>
		<td width="150" height="25">
			Export Name
		</td>
		<td width="400" height="25" nowrap>
	        <% if (sFileUrl != null && sFileUrl.length() > 0) { %>
			    <input type="hidden" name="export_name" size="50" value="<%=((sExportName!=null)?sExportName:"")%>" readonly>
                <%
                   rs = stmt.executeQuery("SELECT export_name, file_url " +
										  "  FROM cque_camp_export " +
										  " WHERE camp_id in (SELECT camp_id " +
										  "                     FROM cque_campaign " +
										  "                    WHERE origin_camp_id = " + camp.s_camp_id +
										  "                  )");
				   while (rs.next()) { 
                       String sampleName = rs.getString(1);
                       String sampleUrl = rs.getString(2);
                %>
					<a href="<%=sampleUrl%>" title="Right click and select [Save Target As...] to download the export onto your local computer"><%=sampleName%></a><br>
                <%
				   }
				   rs.close();
                %>
 		    <% }else { %>
			<input type="text" name="export_name" size="50" value="<%=((sExportName!=null)?sExportName:"")%>" readonly>
 		    <% } %>
		</td>
	</tr>
    <input type="hidden" name="delimiter" value="<%=sDelimiter%>">	 
    <input type="hidden" name="view" value="">
	<tr> 
		<td width="150" valign="middle" align="left">Attribute Mapper</td> 
		<td width="425" valign="middle" align="left">
        <% if (isPrintCampaign) { %>
			<a id=mapperPop class="resourcebutton" href="javascript:mapper_popup();">Popup Mapper</a>
            <a id=mapperOn  class="subactionbutton" href="javascript:void(0);" onclick="showMapper();" style="display:none">Show Mapper</a>
            <a id=mapperOff class="subactionbutton" href="javascript:void(0);" onclick="hideMapper();" style="display:none">Hide Mapper</a>
        <% } else { %>
            <a id=mapperOn  class="subactionbutton" href="javascript:void(0);" onclick="showMapper();" style="display:inline">Show Mapper</a>
            <a id=mapperOff class="subactionbutton" href="javascript:void(0);" onclick="hideMapper();" style="display:none">Hide Mapper</a>
        <% } %>
        </td>
	</tr>
	<tr>
		<table id=mapper class=main width="100%" cellpadding=2 cellspacing=1 style="display:none"> 
			<tr> 
				<td width="237" valign="middle" align="right" rowspan="7"><select name="target" size="15" style="width: 202; height: 285" onDblClick="removeField()"></select></td> 
				<td width="101" valign="middle" align="CENTER" rowspan="7" nowrap>
					<p><a class="subactionbutton" href="javascript:void(0);" onclick="upField();">Move Up</a></p>
					<p><a class="subactionbutton" href="javascript:void(0);" onclick="downField();">Move Down</a></p>
					<br>
					<p><a class="subactionbutton" href="javascript:void(0);" onclick="addField();"><< Move Left</a></p>
					<p><a class="subactionbutton" href="javascript:void(0);" onclick="removeField();">Move Right >></a></p>
				</td> 
				<td width="237" valign="middle" align="left" rowspan="7">
					<select name="source" size="15" style="width: 200; height: 285" onDblClick="addField()"></select>
				</td> 
			</tr> 
		</table>
	</tr> 
</table>

<SCRIPT LANGUAGE="JavaScript">
function showMapper() {
    document.getElementById('mapper').style.display = "inline";
    document.getElementById('mapperOff').style.display = "inline";
    document.getElementById('mapperOn').style.display = "none";
}
function hideMapper() {
    document.getElementById('mapper').style.display = "none";
    document.getElementById('mapperOff').style.display = "none";
    document.getElementById('mapperOn').style.display = "inline";
}
</SCRIPT>

<SCRIPT LANGUAGE="JavaScript">
var itemOpt = new Array();
<%
	int i,j;
	String p1,p2,p3, pp;
	i = 0;
	j = 0;

    String selectedAttrList = new String(":");
	rs = stmt.executeQuery("SELECT attr_id " +
		                   "  FROM cque_camp_export_attr a" +
						   " WHERE a.camp_id = " + camp.s_camp_id);
	while( rs.next() ) { 
		selectedAttrList += rs.getString(1) + ":";
    }
    rs.close();
	String fingerprint = "isnull(c.fingerprint_seq,0)";
	if (isPrintCampaign) {
		fingerprint = "0"; // the fingerprint is not required for print campaigns
	}
	rs = stmt.executeQuery("SELECT c.display_name, c.attr_id, " + fingerprint +
						   "  FROM ccps_cust_attr c " +
						   " WHERE c.cust_id = " + cust.s_cust_id +
						   " ORDER BY ISNULL(c.display_seq,9999)");
	while( rs.next() ) { 
		p1 = new String(rs.getBytes(1), "ISO-8859-1");
		p2 = rs.getString(2);
		p3 = rs.getString(3);
        pp = new String(":" + p2 + ":");
		if( p3.equals("0") && (selectedAttrList.indexOf(pp) < 0) ) {
%>FT.source.options[<%=i%>] = new Option("<%=p1%>", <%=p2%>);
FT.source.options[<%=i%>].type = <%=p3%>;<%
		++i;
		} else	{
%>FT.target.options[<%=j%>] = new Option("<%=p1%>", <%=p2%>);
FT.target.options[<%=j%>].type = <%=p3%>;<%
		++j;
		}
	}  rs.close();
%>
for(var i=0; i < FT.source.options.length; ++i) itemOpt[i] = FT.source.options[i];
for(var j=i, k=0; j < FT.target.options.length; ++j, ++k) itemOpt[j] = FT.target.options[k];

function addField() {

	if( FT.source.selectedIndex == -1 ) return false;

	FT.target.options[FT.target.length] = new Option(FT.source.options[FT.source.selectedIndex].text, FT.source.options[FT.source.selectedIndex].value);
	FT.source.options[FT.source.selectedIndex] = null;
}

function removeField() {

	if( FT.target.selectedIndex == -1 ) return false;
	if(( FT.target.options[FT.target.selectedIndex].type != null ) 
		&& ( FT.target.options[FT.target.selectedIndex].type != 0 )) { alert("You can not remove the required field"); return false; }

	FT.target.options[FT.target.selectedIndex]	= null;
	
	for(var i=0; i < itemOpt.length; ++i) FT.source.options[i] = itemOpt[i]; 
	for(var i=0; i < FT.target.options.length; ++i) 
		for(var j=0; j < FT.source.options.length; ++j) 
			if( FT.target.options[i].value == FT.source.options[j].value ) {
				FT.source.options[j] = null;
				--j;
			}
	FT.source.selectedIndex	= 0;
}

function upField() {

    var id, name;

	if( FT.target.selectedIndex < 1 ) return false;

	id = FT.target.options[FT.target.selectedIndex - 1].value;
	name = FT.target.options[FT.target.selectedIndex - 1].text;
	
	FT.target.options[FT.target.selectedIndex - 1].value = FT.target.options[FT.target.selectedIndex].value;
	FT.target.options[FT.target.selectedIndex - 1].text  = FT.target.options[FT.target.selectedIndex].text;

	FT.target.options[FT.target.selectedIndex].value = id;
	FT.target.options[FT.target.selectedIndex].text  = name;
	
	FT.target.selectedIndex--;
}

function downField() {

    var id, name;

	if( FT.target.selectedIndex == FT.target.length - 1 ) return false;

	id = FT.target.options[FT.target.selectedIndex + 1].value;
	name = FT.target.options[FT.target.selectedIndex + 1].text;
	
	FT.target.options[FT.target.selectedIndex + 1].value = FT.target.options[FT.target.selectedIndex].value;
	FT.target.options[FT.target.selectedIndex + 1].text  = FT.target.options[FT.target.selectedIndex].text;

	FT.target.options[FT.target.selectedIndex].value = id;
	FT.target.options[FT.target.selectedIndex].text  = name;
	
	FT.target.selectedIndex++;
}

function checkDelimiter(obj, value) {
	FT.rr1.checked = false;
	FT.rr2.checked = false;
	FT.rr3.checked = false;
	FT.rr4.checked = false;	
	obj.checked = true;
	FT.delimiter.value = value;
}

</SCRIPT>


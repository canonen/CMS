<%
if( camp.s_type_id.equals("3") )
{
%>
FT.fr1.checked = <%=(((camp.s_filter_id == null) || camp.s_filter_id.equals("")) ? "true" : "false")%>;
FT.fr2.checked = <%=(((camp.s_filter_id == null) || camp.s_filter_id.equals("")) ? "false" : "true")%>;
<%
}
if( camp.s_type_id.equals("4") )
{
	if (camp_list.s_auto_respond_attr_id != null)
	{
%>
FT.ar_send_type[3].checked=true;
<%
	}
	else if (camp_list.s_auto_respond_list_id == null)
	{
%>
FT.ar_send_type[0].checked=true;
<%
	}
	else
	{
%>
FT.ar_send_type[1].checked=true;
<%
	}
}
if( !camp.s_type_id.equals("2") )
{
%>
FT.day_delay.value=Math.floor((FT.delay.value)/24);
FT.hour_delay.value=(FT.delay.value)%24;
<%
}
%>

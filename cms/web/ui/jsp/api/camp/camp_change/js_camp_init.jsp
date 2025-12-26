<% if( !camp.s_type_id.equals("2") ) { %>
FT.day_delay.value=Math.floor((FT.delay.value)/24);
FT.hour_delay.value=(FT.delay.value)%24;
<% } %>

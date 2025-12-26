<HTML>

<HEAD>
	<TITLE></TITLE>
	<%@ include file="header.html" %>
</HEAD>

<FRAMESET rows="35,*" framespacing="0" border="0" frameborder="0">
	<FRAME name="top_00" src="w_top.jsp" scrolling="no" noresize target="main_00" marginwidth="5" marginheight="1">
	<FRAMESET cols="10,*" framespacing="0" border="0" frameborder="0">
		<FRAME name="left_00" src="w_left.jsp" scrolling="no" noresize target="main_00" marginwidth="5" marginheight="1">
		<FRAME name="main_00" src="customer/cust_list.jsp" scrolling="auto" noresize  marginwidth="5" marginheight="1">
	</FRAMESET>
	<NOFRAMES>
	<BODY>
		<P>This page uses frames, but your browser doesn't support them.</P>
		</BODY>
	</NOFRAMES>
</FRAMESET>

</HTML>

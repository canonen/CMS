<%@ page import="java.util.*" 
	 	 import="java.sql.*" 
	 	 import="com.britemoon.*"
 		 import="com.britemoon.cps.*"
	 	 import="com.britemoon.cps.ctm.*" 
	 	 import="org.apache.log4j.*"
%>
<%! static Logger logger = null; %>
<%  if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<jsp:useBean id="newtbean" class="com.britemoon.cps.ctm.TemplateBean" scope="session" />


<%-- Insert it into the db --%>
<%

boolean isParent = false;
if (request.getParameter("parent") != null) {
	isParent = true;
}

Hashtable tbeans = (Hashtable)application.getAttribute("tbeans");

if (newtbean.getTemplateID() != 0) {
	//Updating an existing template
	//Make sure sections and inputs match
	TemplateBean oldtbean = (TemplateBean)tbeans.get(new Integer(newtbean.getTemplateID()));
	
	if (newtbean.getNumSections() != oldtbean.getNumSections()) {
		%>
		Bad Number of Sections in updated master template - must be <%= oldtbean.getNumSections() %> is <%= newtbean.getNumSections() %>
		<%
		return;
	}
	for (int x=0;x<oldtbean.getNumSections();++x) {
		if (newtbean.getNumOrders(x) != oldtbean.getNumOrders(x)) {
			%>
			Bad Number of Inputs in updated master template section <%= x %> - must be <%= oldtbean.getNumOrders(x) %> is <%= newtbean.getNumOrders(x) %>
			<%
			return;			
		}
	}
	//ok! Num of Sections and Inputs match up
}


try {
	newtbean.save();
} catch (SQLException e) {

%>	Error saving master template:  <%= e.getMessage() %> 	<%

    return;
}

//Add it to the hashtable of Template Beans, tbeans
if (tbeans == null) {
	tbeans = new Hashtable(10);
	application.setAttribute("tbeans",tbeans);
}

tbeans.put(new Integer(newtbean.getTemplateID()),newtbean);
if (!isParent) {
	response.sendRedirect("index.jsp");
}
else {
%>
<HTML>
<head>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</head>
<BODY>
<!--- Step 1 Header----->
<table width=650 class=main cellspacing=0 cellpadding=0>
	<tr>
	    <td class=sectionheader>&nbsp;<b class=sectionheader>New Master Template Created</td>
	</tr>
</table>
<br>
<!---- Step 1 Info----->
<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=650 border=0>
	<tr>
		<td class=EmptyTab valign=center nowrap align=middle width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tr>
		<td class=fillTabbuffer valign=top align=left width=650><img height=2 src="../../images/blank.gif" width=1></td>
	</tr>
	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td class=fillTab valign=top align=center width=650>
			<table class=main cellspacing=1 cellpadding=2 width="625">
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<p align="center"><a href="index.jsp<%=(isParent?"?parent=true":"")%>">Back to List</a></p>
						<p align="center"><a href="templatenew.jsp?<%=(isParent?"parent=true&":"")%>templateID=<%= newtbean.getTemplateID() %>">Back to Edit</a></p>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<br><br>
</BODY>
</HTML>
<% }%>


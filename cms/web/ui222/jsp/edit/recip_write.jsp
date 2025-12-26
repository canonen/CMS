<%@ page

	language="java"
	import="com.britemoon.cps.imc.*,
		com.britemoon.cps.*,
		com.britemoon.*,
		java.io.*,java.util.*,
		java.sql.*,java.net.*,
		org.w3c.dom.*,org.apache.log4j.*"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
AccessPermission can = user.getAccessPermission(ObjectType.RECIPIENT);

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

// Connection
Statement			stmt			= null;
ResultSet			rs				= null; 
ConnectionPool	connectionPool= null;
Connection			srvConnection = null;

String sRecipID = null;
String sEmail821 = null;
String sNumRecips = request.getParameter("num_recips");
String sBatchID = request.getParameter("batch_id");
String sPriorityID = request.getParameter("priority_id");

StringWriter swXML = new StringWriter();

try	{
	int numRecips = ((sNumRecips != null)?numRecips = Integer.parseInt(sNumRecips):1);

	connectionPool = ConnectionPool.getInstance();
	srvConnection = connectionPool.getConnection("recip_write.jsp");
	stmt = srvConnection.createStatement();

	swXML.write("<manual_import>\r\n");
	swXML.write("<cust_id>"+cust.s_cust_id+"</cust_id>\r\n");
	if (sBatchID != null)
		swXML.write("<batch_id>"+sBatchID+"</batch_id>\r\n");
	if (sPriorityID != null)
		swXML.write("<priority_id>"+sPriorityID+"</priority_id>\r\n");

	String sEmailAttrID = "";
	rs = stmt.executeQuery ("SELECT c.attr_id FROM ccps_attribute a, ccps_cust_attr c"
		+ " WHERE a.attr_id = c.attr_id AND c.cust_id = " + cust.s_cust_id
		+ "  AND a.attr_name = 'emailgeneric'");
	if (rs.next()) sEmailAttrID = rs.getString(1);

	for (int j=0; j<numRecips ; j++) {
		String sAttrID = null;
		String sAttrName	= null;
		String sAttrValue	= null;
		int nValueQty = 0;

		sEmail821 = request.getParameter("email_821"+((sNumRecips!=null)?"_"+j:""));
		if ((sEmail821 != null) && (!sEmail821.trim().equals(""))) {
			swXML.write("<recip>\r\n");

			sRecipID = request.getParameter("recip_id"+((sNumRecips!=null)?"_"+j:""));
			if (sRecipID != null)
				swXML.write("  <recip_id>"+sRecipID+"</recip_id>\r\n");

			swXML.write("  <field>\r\n");
			swXML.write("    <attr_id>"+sEmailAttrID+"</attr_id>\r\n");
			swXML.write("    <attr_value><![CDATA["+sEmail821+"]]></attr_value>\r\n");
			swXML.write("  </field>\r\n");
		} else
			continue;

		String sEmailTypeID = request.getParameter("email_type_id"+((sNumRecips!=null)?"_"+j:""));
		if ((sEmailTypeID != null) && (sEmailTypeID.trim().length() > 0)) {
//			if (sEmailTypeID.trim().equals("0"))	sEmailTypeID = "3"; //Multipart
			String sEmailTypeAttrID = null;
			rs = stmt.executeQuery ("SELECT c.attr_id FROM ccps_attribute a, ccps_cust_attr c"
				+ " WHERE a.attr_id = c.attr_id AND c.cust_id = " + cust.s_cust_id
				+ "  AND a.attr_name = 'email_type_id'");
			if (rs.next()) sEmailTypeAttrID = rs.getString(1);
			swXML.write("  <field>\r\n");
			swXML.write("    <attr_id>"+sEmailTypeAttrID+"</attr_id>\r\n");
			swXML.write("    <attr_value><![CDATA["+sEmailTypeID+"]]></attr_value>\r\n");
			swXML.write("  </field>\r\n");

			String sEmailConfidence = request.getParameter("email_type_confidence"+((sNumRecips!=null)?"_"+j:""));
			String sEmailConfidenceAttrID = null;
			rs = stmt.executeQuery ("SELECT c.attr_id FROM ccps_attribute a, ccps_cust_attr c"
				+ " WHERE a.attr_id = c.attr_id AND c.cust_id = " + cust.s_cust_id
				+ "  AND a.attr_name = 'email_type_confidence'");
			if (rs.next()) sEmailConfidenceAttrID = rs.getString(1);
			swXML.write("  <field>\r\n");
			swXML.write("    <attr_id>"+sEmailConfidenceAttrID+"</attr_id>\r\n");
			swXML.write("    <attr_value><![CDATA["+((sEmailConfidence!=null)?sEmailConfidence:"")+"]]></attr_value>\r\n");
			swXML.write("  </field>\r\n");
		}
		rs = stmt.executeQuery ("SELECT c.attr_id, a.attr_name, a.value_qty FROM ccps_attribute a, ccps_cust_attr c"
			+ " WHERE a.attr_id = c.attr_id AND c.cust_id = " + cust.s_cust_id
			+ "  AND a.attr_name NOT IN ('recip_id', 'email_821', 'emailgeneric', 'email_type_id', 'email_type_confidence')");

		while ( rs.next() ) { 
			sAttrID = rs.getString(1);
			sAttrName = rs.getString(2);
			nValueQty = rs.getInt(3);

			if (nValueQty == 0) {
				sAttrValue = request.getParameter (sAttrName+((sNumRecips!=null)?"_"+j:""));
				if (sAttrValue != null) {
					swXML.write("  <field>\r\n");
					swXML.write("    <attr_id>"+sAttrID+"</attr_id>\r\n");
					swXML.write("    <attr_value><![CDATA["+sAttrValue+"]]></attr_value>\r\n");
					swXML.write("  </field>\r\n");
				}
			} else { /* Multi-Value */
				String [] sAttrValues = new String [50];
				sAttrValues = request.getParameterValues(sAttrName+((sNumRecips!=null)?"_"+j:""));
				if (sAttrValues != null) {
					for (int i=0; i<sAttrValues.length; i++) {
						swXML.write("  <field>\r\n");
						swXML.write("    <attr_id>"+sAttrID+"</attr_id>\r\n");
						swXML.write("    <attr_value><![CDATA["+sAttrValues[i]+"]]></attr_value>\r\n");
						swXML.write("  </field>\r\n");
					}
				}
			}
		}
		rs.close();
		swXML.write("</recip>\r\n");
	}
	swXML.write("</manual_import>\r\n");
	
//System.out.print(swXML.toString());
	String sMsg = Service.communicate(ServiceType.RUPD_MANUAL_IMPORT_SETUP, cust.s_cust_id, swXML.toString());
//System.out.print(sMsg);

%>
<SCRIPT>

function Init () {
	if (window.opener == null)
		location.replace("edit_confirm.jsp");
	else {
		//window.opener.history.go (0);
		window.opener.location.replace("edit_confirm.jsp");
		window.close ();
	}
}


Init ();

</SCRIPT>
<%


} catch (Exception ex) { 
	
	ErrLog.put(this, ex, "Problem sending Info to Recipient database.\r\n"+swXML.toString(),out,1);

} finally {
	try {
		if ( stmt != null ) stmt.close();
	} catch (Exception ex2) { }
	if ( srvConnection  != null ) connectionPool.free(srvConnection); 
}
%>

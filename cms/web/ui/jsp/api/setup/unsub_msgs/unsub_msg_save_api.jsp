<%@ page
		language="java"
		import="com.britemoon.*"
		import="com.britemoon.cps.*"
		import="com.britemoon.cps.adm.*"
		import="com.britemoon.cps.imc.*"
		import="java.sql.*,java.io.*"
		import="javax.servlet.*"
		import="javax.servlet.http.*"
		import="org.w3c.dom.*"
		import="org.xml.sax.*"
		import="javax.xml.transform.*"
		import="javax.xml.transform.stream.*"
		import="org.apache.log4j.*"
		contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../header.jsp"%>
<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}

	PreparedStatement	pstmt = null;
	ResultSet			rs;
	ConnectionPool 		cp = null;
	Connection 			conn  = null;

	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection("unsub_msg_save_api.jsp");
	} catch(Exception ex)
	{
		out.println("<BR>Connection error ... !<BR><BR>");
		return;
	}

	String customer_id = cust.s_cust_id;
	String msgID = request.getParameter("UnsubmsgID");
	String msgText = request.getParameter("UnSubMessageText");
	String msgHTML = request.getParameter("UnSubMessageHTML");
	String msgName = request.getParameter("MessageName");

	if (msgID == null || msgID.equals("null"))
		msgID = null;

	String outXml="";

	try
	{
		outXml = "<unsub_msg>\n" +"<cust_id>" + customer_id + "</cust_id>\n";
		if (msgID != null)
			outXml += "<msg_id>" + msgID + "</msg_id>\n";

		outXml += "<msg_name><![CDATA[" + msgName + "]]></msg_name>\n";
		outXml += "<text_msg><![CDATA[" + msgText + "]]></text_msg>\n";
		outXml += "<html_msg><![CDATA[" + msgHTML + "]]></html_msg>\n";
		outXml += "</unsub_msg>\n";

		//Send request to SADM	
		String sMsg = Service.communicate(ServiceType.SADM_UNSUB_MESSAGE_UPDATE, customer_id, outXml);

		//Receive response and save unsubscribe message
		String retID = "";
		try
		{
			Element eDetails = XmlUtil.getRootElement(sMsg);

			retID = XmlUtil.getChildTextValue(eDetails, "msg_id");
			if (retID == null)
			{
				//Probably an error
				String error = XmlUtil.getChildCDataValue(eDetails,"error");
				if (error == null)
					throw new Exception("");
				else
					throw new Exception(error);
			}
		} catch (Exception e) {
			throw new Exception("SADM could not setup the unsubscribe message.  Please check the SADM system: "+e.getMessage());
		}

		outXml = outXml.substring(0,outXml.indexOf("</unsub_msg>"));
		if (retID != null)
			outXml += "<msg_id>" + retID + "</msg_id>\n";
		outXml += "</unsub_msg>\n";

		try
		{
			UnsubMsg unsubObj = new UnsubMsg(XmlUtil.getRootElement(outXml));
			unsubObj.save();

			//Send back the name of the unsubscribe message
			String returnXml =
					"<unsub_msg><msg_name><![CDATA["+unsubObj.s_msg_name+"]]></msg_name></unsub_msg>";
			out.print(returnXml);
		}
		catch (Exception e)
		{
			logger.error("Exception: ", e);
			String returnXml =
					"<unsub_msg><error><![CDATA["+e.getMessage()+"]]></error></unsub_msg>";
			out.print(returnXml);
		}

	} catch(Exception ex) {
		ErrLog.put(this,ex,"unsub_msg_save_api.jsp",out,1);
		return;
	} finally {
		if (pstmt != null) pstmt.close();
		if (conn != null) cp.free(conn);
	}

%>
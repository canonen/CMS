<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.adm.*, 
			java.io.*,
			java.sql.*,
			java.util.*, 
			org.w3c.dom.*,org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
Attribute a = null;
CustAttr ca = null;
String sCustId = null;
String sAttrId = "";
String sAttrTypeId = "20";
String sAttrName = null;
String sAttrDisplay = null;

Element eNote = XmlUtil.getRootElement(request);  
	
if (eNote == null)
{
	out.println("<ERROR level=\"1\">Error retrieving XML in CPS->mscrm_attr_setup.jsp.  XML sent to CPS did not parse correctly.</ERROR>");
}
else
{
	sCustId = XmlUtil.getChildTextValue(eNote,"cust_id");
	sAttrId = XmlUtil.getChildTextValue(eNote,"attr_id");
	sAttrTypeId = XmlUtil.getChildTextValue(eNote,"attr_type_id");
	sAttrName = XmlUtil.getChildCDataValue(eNote,"attr_name");
	sAttrDisplay = XmlUtil.getChildCDataValue(eNote,"attr_display");

	logger.info("Setting up attribute for customer:" + sCustId + "; attr:" + sAttrId + "; Name:" + sAttrName + "; Display:" + sAttrDisplay);
	
	if (sCustId == null || sCustId.equals(""))
	{
		out.println("<ERROR level=\"2\">BriteConnect Attribute Setup ERROR:  Customer ID parameter is NULL.  Cannot create attribute.</ERROR>");
	}
	else if ((sAttrId == null) || (sAttrId.trim().equals("")))
	{
		out.println("<ERROR level=\"3\">BriteConnect Attribute Setup ERROR:  Attribute ID parameter is NULL.  Cannot create attribute.</ERROR>");
	}
	else if ((sAttrTypeId == null) || (sAttrTypeId.trim().equals("")))
	{
		out.println("<ERROR level=\"4\">BriteConnect Attribute Setup ERROR:  Attribute Type ID parameter is NULL.  Cannot create attribute.</ERROR>");
	}
	else if ((sAttrName == null) || (sAttrName.trim().equals("")))
	{
		out.println("<ERROR level=\"5\">BriteConnect Attribute Setup ERROR:  Attribute Name parameter is NULL.  Cannot create attribute.</ERROR>");
	}
	else if ((sAttrDisplay == null) || (sAttrDisplay.trim().equals("")))
	{
		out.println("<ERROR level=\"6\">BriteConnect Attribute Setup ERROR:  Attribute Display parameter is NULL.  Cannot create attribute.</ERROR>");
	}
	else
	{
		// === Set up Attribute object ===

		// === Set up Customer Attribute object ===
		
		if (sAttrId.equals("0"))
		{
			a = new Attribute();
			a.s_cust_id = sCustId;
			a.s_attr_name = sAttrName;
			
			if(a.s_type_id==null) a.s_type_id = sAttrTypeId;
			if(a.s_scope_id==null) a.s_scope_id = String.valueOf(AttrScope.PUBLIC);
			if(a.s_value_qty!=null) a.s_value_qty = "2";
		
			ca = new CustAttr();
			ca.s_attr_id = sAttrId;
			ca.s_cust_id = sCustId;
			
			if((sAttrId.equals("0"))||(ca.retrieve()<1))
			{
				ca.s_display_seq = "1";
				ca.s_fingerprint_seq = null;
			}
			
			ca.s_sync_flag = "1";
			ca.s_hist_flag = "0";
			ca.s_newsletter_flag = null;
			ca.s_display_seq = "1";
			ca.s_fingerprint_seq = null;
		}
		else
		{
			a = new Attribute(sAttrId);
		
			ca = new CustAttr();
			ca.s_attr_id = sAttrId;
			ca.s_cust_id = sCustId;
			
			if((sAttrId.equals("0"))||(ca.retrieve()<1))
			{
				ca.s_display_seq = "1";
				ca.s_fingerprint_seq = null;
			}
		}
		
		ca.s_display_name = sAttrDisplay;

		// === Assign the Attribute to the Customer Attribute and save the Customer Attribute in both CPS and RCP ===

		ca.m_Attribute = a;
		ca.saveWithSync();
		
		sAttrId = ca.s_attr_id;
	}
}
%>
<response><attr_id><%= sAttrId %></attr_id></response>
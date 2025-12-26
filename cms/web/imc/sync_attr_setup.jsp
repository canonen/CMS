<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.adm.*, 
			java.io.*,
			java.sql.*,
			java.util.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
Attribute a = null;
String sAttrId = null;
String sCustId = null;
String sAttrName = null;

sCustId = BriteRequest.getParameter(request,"cust_id");
sAttrName = BriteRequest.getParameter(request,"attr_name");
logger.info("Setting up new attribute for customer:" + sCustId + "; Attribute:" + sAttrName);
if (sCustId == null)
     throw new Exception("BriteConnect Attribute Setup ERROR:  Customer ID parameter is NULL.  Cannot create attribute.");
if (sAttrName == null)
     throw new Exception("BriteConnect Attribute Setup ERROR:  Attribute Name parameter is NULL.  Cannot create attribute.");

// === Set up Attribute object ===
a = new Attribute();
a.s_cust_id = sCustId;
a.s_attr_name = sAttrName;
a.s_type_id =  String.valueOf(DataType.VARCHAR_255);
a.s_scope_id = String.valueOf(AttrScope.PUBLIC);
a.s_value_qty = null;
a.s_descrip = "";

// === Set up Customer Attribute object ===

CustAttr ca = new CustAttr();
ca.s_attr_id = sAttrId;    // new attribute, so this is NULL
ca.s_cust_id = a.s_cust_id;
ca.s_display_seq = "1";
ca.s_fingerprint_seq = null;
ca.s_display_name = sAttrName;
ca.s_sync_flag = "1";
ca.s_hist_flag = null;

// === Assign the Attribute to the Customer Attribute and save the Customer Attribute in both CPS and RCP ===

ca.m_Attribute = a;
ca.saveWithSync();

%> 
done



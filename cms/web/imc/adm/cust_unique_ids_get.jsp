<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.adm.*, 
			com.britemoon.cps.imc.*, 
			org.w3c.dom.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
try
{
	response.setHeader("Expires", "0");
	response.setHeader("Pragma", "no-cache");
	response.setHeader("Cache-Control", "no-cache");
	response.setHeader("Cache-Control", "max-age=0");
	response.setContentType("text/html;charset=UTF-8");

	Element e = XmlUtil.getRootElement(request);

	String sCustID = XmlUtil.getChildTextValue(e, "cust_id");
	
	if(sCustID != null) sCustID = sCustID.trim();
	if("".equals(sCustID)) sCustID = null;
	
	CustUniqueIds cuis = new CustUniqueIds ();
	if(sCustID != null) cuis.s_cust_id = sCustID;
	else cuis.m_bUseParamsForRetrieve = false;

	cuis.retrieve();	

	out.println(cuis.toXml());
}
catch(Exception ex)
{ 
	ErrLog.put(this, ex, "Error in " + this.getClass().getName(), out, 1);
}
%>

<%@ page
	language="java"
	import="com.britemoon.*, 
			com.britemoon.cps.*, 
			com.britemoon.cps.adm.*, 
			com.britemoon.cps.imc.*, 
			org.w3c.dom.*, 
			java.io.*,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp" %>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
try
{
	Element eAttrCalcProps = XmlUtil.getRootElement(request);
	AttrCalcProps acp = new AttrCalcProps(eAttrCalcProps);
	acp.save();
}
catch(Exception ex)
{ 
	logger.error("Exception: ", ex);
	ex.printStackTrace(new PrintWriter(out));
}
finally
{
	out.flush();
}
%>
<OK>OK</OK>

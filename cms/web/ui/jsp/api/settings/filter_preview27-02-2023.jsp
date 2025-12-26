<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.adm.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.imc.*,
			java.io.*,java.sql.*,
			java.util.*,org.w3c.dom.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.FILTER);



String sFilterId = request.getParameter("filter_id");
JsonObject obj = new JsonObject();
JsonArray arr = new JsonArray();
if( sFilterId == null) return;

PreviewAttrs pas = new PreviewAttrs();
pas.s_filter_id = sFilterId;

PreviewAttr pa = null;
String sAttrList = "";

for (Enumeration e = pas.elements() ; e.hasMoreElements() ;)
{
	pa = (PreviewAttr)e.nextElement();
	if(!"".equals(sAttrList)) sAttrList +=",";
	sAttrList += pa.s_attr_id;
}

RecipList rl = new RecipList();
rl.sAction = "TgtPreview";
rl.s_cust_id = cust.s_cust_id;
rl.s_filter_id = sFilterId;
rl.s_num_recips = "200";
rl.s_attr_list = sAttrList;
System.out.println("1");
String sRequestXml = rl.toRecipRequestXml();
System.out.println("2");
String sResponse = Service.communicate(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id, sRequestXml);
System.out.println("3");
	CustAttr ca = null;
	Attribute a = null;
	for (Enumeration e = pas.elements() ; e.hasMoreElements() ;)
	{

		pa = (PreviewAttr)e.nextElement();
		ca = new CustAttr(cust.s_cust_id, pa.s_attr_id);
		obj.put("displayName",ca.s_display_name);
		arr.put(obj);
		System.out.println("4");
	}

    System.out.println("5");
	Element eRecipList = XmlUtil.getRootElement(sResponse);
	Element eRecipient = null;
	NodeList nl = XmlUtil.getChildrenByName(eRecipList, "recipient");
	int iLength = nl.getLength();

	String sClassAppend = "";
    System.out.println("6");
	for(int i = 0; i < iLength; i++)
	{
	    System.out.println("7");
		if (i % 2 != 0)
		{
		    obj.put("dataAlt1",XmlUtil.getChildCDataValue(eRecipient, a.s_attr_name));
			arr.put(obj);
		}
		else
		{
		    obj.put("dataAlt2",XmlUtil.getChildCDataValue(eRecipient, a.s_attr_name));
			arr.put(obj);
		}

		eRecipient = (Element)nl.item(i);
		System.out.println("8");
		for (Enumeration e = pas.elements() ; e.hasMoreElements() ;)
		{
		    System.out.println("9");
			pa = (PreviewAttr)e.nextElement();
			a = new Attribute(pa.s_attr_id);
			obj.put("data",XmlUtil.getChildCDataValue(eRecipient, a.s_attr_name));
            arr.put(obj);
            System.out.println("10");
		}

		out.print(arr);
		System.out.println("11");
	}

%>


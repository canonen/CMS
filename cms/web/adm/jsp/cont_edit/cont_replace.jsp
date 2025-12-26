<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.imc.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.jtk.*,
			org.w3c.dom.*,
			java.util.*,
			java.sql.*,
			java.net.*,
			java.io.*,
			java.text.DateFormat,
			org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%@ include file="../header.jsp"%>

<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>
<BODY>

<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
String sDCampId = BriteRequest.getParameter(request,"d_camp_id");
String sSContId = BriteRequest.getParameter(request,"s_cont_id");
String[] sContMap = BriteRequest.getParameterValues(request,"sd_cont_ids");
int nNewLinkCount = 0;


if((sDCampId==null)||(sSContId==null)||(sContMap == null)||(sContMap.length < 1))
{
%>
<H3>Nothing to change!</H3>
<%
	return;
}
ConnectionPool cp = null;
Connection conn = null;
boolean bAutoCommit = true;
try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection(this);
	try
	{
		bAutoCommit = conn.getAutoCommit();
		conn.setAutoCommit(false);

		String[] sParagraphIds = null;
		String sSParagraphId = null;
		String sDParagraphId = null;
		for(int i=0; i < sContMap.length; i++)
		{
			sParagraphIds = sContMap[i].split(";");
			sSParagraphId = sParagraphIds[0];
			sDParagraphId = sParagraphIds[1];

			logger.info(this + " UPDATING: sSParagraphId = " + sSParagraphId + " >> sDParagraphId = " + sDParagraphId);

			String sSql =
				" UPDATE ccnt_cont_body" +
				" SET" +
				" ccnt_cont_body.text_part = cb.text_part," +
				" ccnt_cont_body.html_part = cb.html_part," +
				" ccnt_cont_body.aol_part = cb.aol_part" +				
				" FROM ccnt_cont_body, ccnt_cont_body cb" +
				" WHERE cb.cont_id = " + sSParagraphId +
				" AND ccnt_cont_body.cont_id = " + sDParagraphId;
			BriteUpdate.executeUpdate(sSql, conn);
		}

		conn.commit();
	}
	catch(Exception ex)
	{
		if (conn != null) conn.rollback();
		throw ex;
	}
	finally { if (conn != null) conn.setAutoCommit(bAutoCommit); }
	
	// === === ===

	Statement stmt = null;
	try
	{
		stmt = conn.createStatement();
		
		String sSql =
			"EXEC usp_cque_camp_links_add_from_cont " + sDCampId + "," + sSContId;
			
		ResultSet rs = stmt.executeQuery(sSql);
		if(rs.next()) nNewLinkCount = rs.getInt(1);
		rs.close();
	}
	catch(Exception ex) { throw ex; }
	finally { if (stmt != null) stmt.close(); }
}
finally { if (conn != null) cp.free(conn); }

// === rcp & jtk setup ===

Campaign camp = new Campaign(sDCampId);



if(nNewLinkCount > 0)
{
	Links links = new Links();
	links.s_camp_id = camp.s_camp_id;
	if(links.retrieve() > 0)
	{
		Content cont = new Content();
		cont.m_Links = links;
		camp.m_Content = cont;

		camp.s_status_id =
			"THIS_IS_MAGIC_STATUS_TO_RECOGNIZE_CAMP_UPDATE_ON_RCP_AND_PREVENT_IT_FROM_SAVING_AS_IT_IS";

		String sRcpSetupXml = camp.toXml();
		String sResponse = Service.communicate(ServiceType.RQUE_CAMPAIGN_SETUP, camp.s_cust_id, sRcpSetupXml);
		XmlUtil.getRootElement(sResponse);

		CampSetupUtil.doJtkSetup(camp.s_camp_id);
	}
}

// === mailer setup === 

String sXml = CampSetupUtil.buildCampXml4Mailer(camp.s_camp_id);
XmlUtil.getRootElement("<some_wrapping_tag>" + sXml + "</some_wrapping_tag>");

CampXml camp_xml = new CampXml(camp.s_camp_id);

if(!sXml.equals(camp_xml.s_camp_xml))
{
	CampXmlHist camp_xml_hist = new CampXmlHist();
	camp_xml_hist.s_camp_id = camp_xml.s_camp_id;
	camp_xml_hist.s_camp_xml = camp_xml.s_camp_xml;
	camp_xml_hist.save();

	camp_xml.s_camp_xml = sXml;
	camp_xml.save();
}

// === === === 

%>



<H3>

Paragraphs updated: <%=sContMap.length%>

<BR>

New links: <%=nNewLinkCount%>

</H3>



</BODY>

</HTML>



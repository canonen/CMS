<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			java.sql.*,java.io.*,
			java.util.*,org.xml.sax.*,
			javax.xml.transform.*,
			javax.xml.transform.stream.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null;%>
<%
	response.setHeader("Expires", "0");
	response.setHeader("Pragma", "no-cache");
	response.setHeader("Cache-Control", "no-cache");
	response.setHeader("Cache-Control", "max-age=0");
	response.setContentType("text/html; charset=UTF-8");
%>
<%@ include file="../validator.jsp"%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN_REPORT);

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}

// Connection
Statement		stmt	= null;
ResultSet		rs		= null; 
ConnectionPool	cp		= null;
Connection		conn	= null;
Statement		stmt2	= null;
ResultSet		rs2		= null; 
Connection		conn2	= null;

try
{
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("report_list.jsp");
	stmt = conn.createStatement();

	conn2 = cp.getConnection("report_list.jsp 2");
	stmt2 = conn2.createStatement();

	String sSQL=null;
	
	String		scurPage	= request.getParameter("curPage");
	String		samount		= request.getParameter("amount");
	
	int			curPage			= 1;
	int			amount			= 0;
	
	curPage		= (scurPage		== null) ? 1 : Integer.parseInt(scurPage);

	if (samount == null) samount = ui.getSessionProperty("global_report_page_size");
	if ((samount == null)||("".equals(samount))) samount = "25";
	try { amount = Integer.parseInt(samount); }
	catch (Exception ex) { samount = "25"; amount = 25; }
	ui.setSessionProperty("global_report_page_size", samount);
	
	String XSLDir = Registry.getKey("report_xsl_dir");
	String XSLFile = XSLDir+"CustReportList.xsl";

	// ********* KU
	int iCount = 0;
	int iRowCount = 0;
	String sClassAppend = "_Alt";

	byte[] bVal = new byte[255];
	
	sSQL = "Exec usp_crpt_cust_report_list_get @cust_id="+cust.s_cust_id;

	String val = null;
	String sXML="<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
	sXML+="<ReportList>\n";

	if (!can.bExecute) sXML+="<Viewer>Yes</Viewer>\n";
	
	sXML+="<StyleSheet>" + ui.s_css_filename + "</StyleSheet>\n";
	sXML+="<PageAmount>" + samount + "</PageAmount>\n";
	sXML+="<CurrentPage>" + String.valueOf(curPage) + "</CurrentPage>\n";
	sXML+="<PrevPage>" + String.valueOf(curPage - 1) + "</PrevPage>\n";
	sXML+="<NextPage>" + String.valueOf(curPage + 1) + "</NextPage>\n";

	{
		rs = stmt.executeQuery(sSQL);
		
		sXML+="<Reports>\n";	
		StringWriter swRow=new StringWriter();
		
		while (rs.next())
		{
			iRowCount++;
			
			//Page logic
			if ((iRowCount <= (curPage-1)*amount) || (iRowCount > curPage*amount)) continue;
			
			String sReportId = rs.getString(1);
			swRow.write("<Row>\n");
			swRow.write("<report_id>"+sReportId+"</report_id>\n");
			val = rs.getString(2);
			swRow.write("<start_date_display>"+((val!=null)?val:"-- No Start Date --")+"</start_date_display>\n");
			swRow.write("<start_date>"+((val!=null)?val:"")+"</start_date>\n");
			val = rs.getString(3);
			swRow.write("<end_date_display>"+((val!=null)?val:"-- No End Date --")+"</end_date_display>\n");
			swRow.write("<end_date>"+((val!=null)?val:"")+"</end_date>\n");
			swRow.write("<user_id>"+rs.getString(4)+"</user_id>\n");
			swRow.write("<update_date>"+rs.getString(5)+"</update_date>\n");
			swRow.write("<active>"+rs.getString(6)+"</active>\n");
			swRow.write("<have_bback>"+rs.getString(7)+"</have_bback>\n");
			swRow.write("<are_bback>"+rs.getString(8)+"</are_bback>\n");
			swRow.write("<unsub>"+rs.getString(9)+"</unsub>\n");
			swRow.write("<click>"+rs.getString(10)+"</click>\n");
			swRow.write("<multi_click>"+rs.getString(11)+"</multi_click>\n");
			swRow.write("<camp_qty>"+rs.getString(12)+"</camp_qty>\n");
			swRow.write("<sent>"+rs.getString(13)+"</sent>\n");
			swRow.write("<not_sent>"+rs.getString(14)+"</not_sent>\n");
			swRow.write("<detect_html>"+rs.getString(15)+"</detect_html>\n");
			swRow.write("<detect_text>"+rs.getString(16)+"</detect_text>\n");
			swRow.write("<detect_aol>"+rs.getString(17)+"</detect_aol>\n");
			swRow.write("<unconfirmed>"+rs.getString(18)+"</unconfirmed>\n");
			swRow.write("<status>"+rs.getString(19)+"</status>\n");
			swRow.write("<user_name><![CDATA["+new String(rs.getBytes(20), "UTF-8")+"]]></user_name>\n");

			// ********* KU
			iCount = 0;

			rs2=stmt2.executeQuery("Exec usp_crpt_cust_report_bbacks @cust_id="+cust.s_cust_id+", @report_id="+sReportId);
			while( rs2.next() )
			{
				// ********* KU
				if (iCount % 2 != 0) sClassAppend = "_Alt";
				else sClassAppend = "";
				
				iCount++;
				
				swRow.write("<BounceBacks>\n");
				swRow.write("<CategoryID>"+rs2.getString("CategoryID")+"</CategoryID>\n");
				bVal = rs2.getBytes("CategoryName");
				swRow.write("<CategoryName><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></CategoryName>\n");
				swRow.write("<BBacks>"+rs2.getString("BBacks")+"</BBacks>\n");
				swRow.write("<BBackPrc>"+rs2.getString("BBackPrc")+"</BBackPrc>\n");
				swRow.write("<StyleClass>"+sClassAppend+"</StyleClass>\n");
				swRow.write("</BounceBacks>\n");
			}
			rs2.close();
			
			// ********* KU
			iCount = 0;

			rs2=stmt2.executeQuery("Exec usp_crpt_cust_report_domains @cust_id="+cust.s_cust_id+", @report_id="+sReportId);
			while( rs2.next() )
			{
				// ********* KU
				if (iCount % 2 != 0) sClassAppend = "_Alt";
				else sClassAppend = "";
				
				iCount++;
				
				swRow.write("<Domains>\n");
				bVal = rs2.getBytes("Domain");
				swRow.write("<Domain><![CDATA["+(bVal!=null?new String(bVal,"UTF-8"):"")+"]]></Domain>\n");
				swRow.write("<Sent>"+rs2.getString("Sent")+"</Sent>\n");
				swRow.write("<BBacks>"+rs2.getString("BBacks")+"</BBacks>\n");
				swRow.write("<BBackPrc>"+rs2.getString("BBackPrc")+"</BBackPrc>\n");
				swRow.write("<StyleClass>"+sClassAppend+"</StyleClass>\n");
				swRow.write("</Domains>\n");
			}
			rs2.close();

			swRow.write("</Row>\n");
		}
		rs.close();
		
		sXML+=swRow.toString()+"</Reports>\n";
	}

	sXML+="<CampRowCount>" + iRowCount + "</CampRowCount>\n";

	sXML+="</ReportList>\n";

	//System.out.println(sXML);

	File fxsl=new File(XSLFile);		

	TransformerFactory tfactory = TransformerFactory.newInstance();
	Templates templates = tfactory.newTemplates(new StreamSource(fxsl));
	Transformer transformer = templates.newTransformer();
	StringReader srXML = new StringReader(sXML);
	transformer.transform(new StreamSource(srXML), new StreamResult(out));

	srXML.close();
	srXML = null;
}
catch(java.lang.Exception ex)
{		
	logger.error("Exception: ",ex);
}
finally
{
	if (stmt!=null) stmt.close();
	if (conn!=null) cp.free(conn);
	
	if (stmt2!=null) stmt2.close();
	if (conn2!=null) cp.free(conn2);
	out.flush();

}

%>
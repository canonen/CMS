<%@ page
	language="java"
	import="com.britemoon.cps.imc.*,
			com.britemoon.cps.*,
			com.britemoon.*,
			org.w3c.dom.*,
			java.util.*,java.sql.*,
			java.util.Date,java.io.*,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%@ include file="functions.jsp"%>

<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
%>

<html>
	<head>
		<title>Auto Login to pvIQ</title>
		<% 
		// Connection
		Statement		stmt	= null;
		ResultSet		rs		= null; 
		ConnectionPool	cp		= null;
		Connection		conn	= null;
	
		Statement		stmtForPVId		= null;
		Connection		connForPVId		= null;
		Connection		connForparseXML	= null;
		ResultSet rsList = null;
		String sSeedListTypes = "10,11,12,13,14";
		String sCustID = cust.s_cust_id;
		String sPVRequest = null;	
		String xpviqID = null;
			
		try
		{
			String sCampID = request.getParameter("CampID");
			String sListId = request.getParameter("ListID");
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("viewer_iframe.jsp");
			stmt = conn.createStatement();
		
			String pvCustId = null;
			xpviqID = getPVId(stmt,cust.s_cust_id,sCampID,sListId);
			String pvClientId = getPV_ClientId(cust.s_cust_id,stmt);


			Vector services = Services.getByCust(ServiceType.CXCS_PV_DELIVERY_REPORT, cust.s_cust_id);		
			Service service = (Service) services.get(0);
		
			String frmAction = service.getURL().toString() + "?action=Run+Report";
			//frmAction = frmAction + "&username=" + user.s_pv_login + 
			//			"&clientid=" + pvClientId + "&password=" + user.s_pv_password + "&submitbutton=LOGIN";
			System.out.println("frmAction: " + frmAction);
			logger.info("xpviqID = " + xpviqID);
	%>
	<%
			// get the XML from PV , parse and store in DB
			cp = ConnectionPool.getInstance();
			conn = cp.getConnection("viewer_iframe.jsp");
			connForPVId = cp.getConnection("viewer_iframe.jsp");
			connForparseXML = cp.getConnection("viewer_iframe.jsp");
			
			stmtForPVId = connForPVId.createStatement();
					
			String sSql = "SELECT  l.list_id, cc.origin_camp_id , ccl.camp_id " +
				 "FROM cque_email_list l, cque_list_type t, cque_camp_list ccl, " +
				 "cque_campaign cc " + 
				 "WHERE l.cust_id = '" + sCustID +"' " +
				 "AND l.type_id = t.type_id AND l.type_id in (" + sSeedListTypes + ") " +
				 "AND l.list_id = ccl.test_list_id " +
				 "AND ccl.test_list_id = '" + sListId + "' " +
				 "AND ccl.camp_id = cc.camp_id " + 
				 "AND ccl.camp_id <> '" + sCampID +"' " +
				 "AND cc.origin_camp_id = (select origin_camp_id from cque_campaign where camp_id = '" + sCampID +"') " +
				 "AND cc.mode_id = 40";	
			
			int sTestId = 0;
			int iListID = 0;
			int sOriginalCampId = 0;
			
			XmlElementList xel = null;
			Element e2 = null;
			Element e3 = null;
			Element e4 = null;
			Element e5 = null;
			Element e6 = null;
			PreparedStatement pstmt	= null;
			String sSQL = null;
			boolean recordExist = false;
			sOriginalCampId = Integer.parseInt(sCampID);
			
			rsList = stmt.executeQuery(sSql);
			while(rsList.next())
			{
				iListID = rsList.getInt(1);
				sTestId = rsList.getInt(3);
				
				// check if record already exist in the crpt_camp_pv_summary table
				recordExist = checkPVRecord(stmtForPVId, sCampID, Integer.toString(sTestId));
				if(recordExist)
				{
					break;
				}
				sPVRequest = "?action=Run+Report&X-PVIQ=" + xpviqID + "&username=" + user.s_pv_login + 
							"&clientid=" + pvClientId + "&password=" + user.s_pv_password + "&submitbutton=LOGIN";
				
				String pvReportXml = Service.communicatePV(ServiceType.CXCS_PV_DELIVERY_REPORT_XML, sCustID, sPVRequest);
				logger.info("XML from PVIQ = " + pvReportXml);
				
				// Parse XMl and Store into Database tables
				connForparseXML.setAutoCommit(false);
				Element e = XmlUtil.getRootElement(pvReportXml);
				if(e == null) throw new Exception("Malformed Campaign Report xml.");
	
				e2 = XmlUtil.getChildByName(e, "timestamps");
				if (e2 != null) 
				{	
				// insert into crpt_camp_pv_summary table
				sSQL = "INSERT crpt_camp_pv_summary "
					+ " (test_id,"
					+ " camp_id,"
					+ " pv_id,"
					+ " client_id,"
					+ " pv_report_group_id,"
					+ " list_id,"
					+ " create_date,"
					+ " first_sent,"
					+ " first_received,"
					+ " last_sent,"
					+ " last_received,"
					+ " qty_expected,"
					+ " qty_received,"
					+ " qty_inbox,"
					+ " qty_bulkbox,"
					+ " percent_missing,"
					+ " percent_received,"
					+ " percent_inbox,"
					+ " percent_bulkbox)"
					+ " VALUES (?,?,?,?,?,?,GetDate(),?,?,?,?,?,?,?,?,?,?,?,?)";
					
				try
				{
					pstmt = connForparseXML.prepareStatement(sSQL);
					pstmt.setInt(1,sTestId);
					pstmt.setInt(2,sOriginalCampId);
					pstmt.setString(3,xpviqID);
					pstmt.setString(4,XmlUtil.getChildTextValue(e, "client_id"));
					pstmt.setString(5,XmlUtil.getChildTextValue(e, "reportgroup_id"));
					pstmt.setInt(6,iListID);
					if (e2 != null)
					{
						pstmt.setString(7,XmlUtil.getChildTextValue(e2, "first_sent"));
						pstmt.setString(8,XmlUtil.getChildTextValue(e2, "first_received"));
						pstmt.setString(9,XmlUtil.getChildTextValue(e2, "last_sent"));
						pstmt.setString(10,XmlUtil.getChildTextValue(e2, "last_received"));
					}
					e3 = XmlUtil.getChildByName(e, "delivery");
					if (e3 != null)
					{
						xel = XmlUtil.getChildrenByName(e3, "quantity");
						e2 = (Element)xel.item(0);
						xel = XmlUtil.getChildrenByName(e3, "percent");
						e4 = (Element)xel.item(0);	
						pstmt.setString(11,XmlUtil.getChildTextValue(e2, "expected"));
						pstmt.setString(12,XmlUtil.getChildTextValue(e2, "received"));
						pstmt.setString(13,XmlUtil.getChildTextValue(e2, "inbox"));
						pstmt.setString(14,XmlUtil.getChildTextValue(e2, "bulkbox"));
						pstmt.setString(15,XmlUtil.getChildTextValue(e4, "missing"));
						pstmt.setString(16,XmlUtil.getChildTextValue(e4, "received"));
						pstmt.setString(17,XmlUtil.getChildTextValue(e4, "inbox"));
						pstmt.setString(18,XmlUtil.getChildTextValue(e4, "bulkbox"));
					}
					pstmt.executeUpdate();
				}
				catch (Exception ex) { throw ex; }
				finally { if( pstmt != null ) pstmt.close(); }
				
				// insert into crpt_camp_pv_isp table
				e2 = XmlUtil.getChildByName(e, "isps");
				if (e2 != null)
				{
					xel = XmlUtil.getChildrenByName(e2, "isp");
					if (xel.getLength() > 0)
					{
						for (int j=0; j < xel.getLength(); j++)
						{
							e3 = (Element)xel.item(j);			
							e2 = XmlUtil.getChildByName(e3, "timestamps");				
							e4 = XmlUtil.getChildByName(e3, "delivery");
							if (e4 != null)
							{
								XmlElementList xel3 = XmlUtil.getChildrenByName(e4, "quantity");
								e5 = (Element)xel3.item(0);
								xel3 = XmlUtil.getChildrenByName(e4, "percent");
								e6 = (Element)xel3.item(0);				
					
								sSQL = "INSERT crpt_camp_pv_isp "
									+ " (test_id ,"
							        + " camp_id,"
							        + " isp_id,"
									+ " isp_name,"
									+ " first_sent,"
									+ " first_received,"
									+ " last_sent,"
									+ " last_received,"
									+ " qty_expected,"
									+ " qty_received,"
									+ " qty_inbox,"
									+ " qty_bulkbox,"
									+ " percent_missing,"
									+ " percent_received,"
									+ " percent_inbox,"
									+ " percent_bulkbox)"
									+ " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
								try
								{
									pstmt = connForparseXML.prepareStatement(sSQL);
									pstmt.setInt(1,sTestId);
									pstmt.setInt(2,sOriginalCampId);
									pstmt.setString(3,XmlUtil.getAttrTextValue(e3, "id"));
									pstmt.setString(4,XmlUtil.getChildTextValue(e3, "name"));
									pstmt.setString(5,XmlUtil.getChildTextValue(e2, "first_sent"));
									pstmt.setString(6,XmlUtil.getChildTextValue(e2, "first_received"));
									pstmt.setString(7,XmlUtil.getChildTextValue(e2, "last_sent"));
									pstmt.setString(8,XmlUtil.getChildTextValue(e2, "last_received"));
									pstmt.setString(9,XmlUtil.getChildTextValue(e5, "expected"));
									pstmt.setString(10,XmlUtil.getChildTextValue(e5, "received"));
									pstmt.setString(11,XmlUtil.getChildTextValue(e5, "inbox"));
									pstmt.setString(12,XmlUtil.getChildTextValue(e5, "bulkbox"));	
									pstmt.setString(13,XmlUtil.getChildTextValue(e6, "missing"));
									pstmt.setString(14,XmlUtil.getChildTextValue(e6, "received"));
									pstmt.setString(15,XmlUtil.getChildTextValue(e6, "inbox"));
									pstmt.setString(16,XmlUtil.getChildTextValue(e6, "bulkbox"));
									pstmt.executeUpdate();
								}
								catch (Exception ex) { throw ex; }
								finally { if( pstmt != null ) pstmt.close(); }
							}
						}
					}
				}
				connForparseXML.commit();			
				}//close if
			}
			rsList.close();
			
%>


	</head>
	<body>
	
	<form name='frmUserCode' id='frmUserCode' method='post' action='<%=frmAction%>'>
            <input type='hidden' name='iframe' value='1'> <!-- must have for security (so user cannot browse PV site)  -->
            <input type='hidden' name='session' value='1'> <!-- must have for security (so user cannot retrieve username and password from report urls) -->
            <input type='hidden' name='cached' value='1'>
            <input type='hidden' name='action' value='Run+Report'>
            <input type='hidden' value='<%=xpviqID%>' name=X-PVIQ>
			<input type='hidden' value='<%=user.s_pv_login%>' name=username>
			<input type='hidden' value='<%=pvClientId%>' name=clientid>
			<input type='hidden' value='<%=user.s_pv_password%>' name=password>  
            <input type=hidden value='LOGIN' name=submitbutton> <!-- must have or login page is displayed instead of report -->

</form>	<script language="javascript">
		<!--
		document.frmUserCode.submit();
		-->
		</script>

	</body>
</html>


<%
		}
		catch(Exception ex)	{ 
			ErrLog.put(this, ex, "PV error: ",out,1);
		}
		finally	{
			if( stmt != null ) stmt.close();
			if( stmtForPVId != null ) stmtForPVId.close();
			if( conn != null ){ cp.free(conn); }
			if( connForPVId != null){ cp.free(connForPVId);}
			if( connForparseXML != null ) { cp.free(connForparseXML); }
		}
%>

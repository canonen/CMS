<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.sas.*"
	import="java.io.*"
	import="java.sql.*"
	import="java.util.*"
	import="org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="/adm/jsp/header.jsp" %>
<%
String sCustId = BriteRequest.getParameter(request, "cust_id");
Customer cust = new Customer(sCustId);
%>
<HTML>

<HEAD>
	<%@ include file="/adm/jsp/header.html" %>
	<link rel="stylesheet" href="../../../../css/style.css" TYPE="text/css">
	<BASE target="main_03">
</HEAD>

<BODY>
<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
	<col>
	<tr>
		<td>
			<table id="Tabs_Table1" cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
				<col width="200">
				<col>
				<tr height="20">
					<td class="EditTabOn" id="tab1_Step1" valign="center" nowrap align="middle">Attributes To Inherit</td>
					<td class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr height="2">
					<td class="fillTabbuffer" valign="top" align="left" colspan="2"><img height="2" src="../../../images/blank.gif" width="1"></td>
				</tr>
				<tr>
					<td class="fillTab" valign="top" align="center" colspan="2">
						<div style="width:100%; height:100%; overflow:auto;">
						<table class="listTable layout" style="width:100%;" border="0" cellspacing="0" cellpadding="3">
							<col>
							<col width="30">
							<col width="30">
							<col width="30">
							<col width="50">
							<tr height="22">
								<th>Display Name</th>
								<th>MV</th>
								<th>F</th>
								<th>I</th>
								<th>Order</th>
							</tr>
					<%
					ConnectionPool cp = null;
					Connection conn = null;
					Statement	stmt = null;
					ResultSet	rs = null; 
					String sSQL = null;
					try
					{
						cp = ConnectionPool.getInstance();
						conn = cp.getConnection(this);
						stmt = conn.createStatement();

						sSQL =
							" SELECT" +
							"	a.attr_id," +
							"	ca.display_name," +
							"	ca.display_seq," +
							"	ca.fingerprint_seq," +
							"	a.value_qty," +
							"	a.attr_name," +
							"	a.internal_flag" +
							" FROM" +
							"	sadm_attribute a," +
							"	sadm_cust_attr ca" +			
							" WHERE" +
							"	a.attr_id=ca.attr_id AND" +
							"	ca.cust_id=" + cust.s_parent_cust_id + " AND" +
							"	ca.attr_id NOT IN" +
							"		(SELECT attr_id FROM sadm_cust_attr" +
							"			WHERE cust_id = " + cust.s_cust_id + ")" +
							" ORDER BY ISNULL(display_seq, 1000000), display_name";

 						rs = stmt.executeQuery(sSQL);

						String sAttrId = null;
						String sDisplayName = null;
						String sDisplaySeq = null;
						String sFingerprintSeq = null;
						String sValueQty = null;
						String sAttrName = null;
						String sInternalFlag = null;

						String sDescrip = null;
					
						int iCount = 0;
						String sClassAppend = "";

						byte[] b = null;
						while(rs.next())
						{
							if (iCount % 2 != 0) sClassAppend = "_Alt";
							else sClassAppend = "";
							
							++iCount;
						
							sAttrId = rs.getString(1);

							b = rs.getBytes(2);
							sDisplayName = (b==null)?null:new String(b, "UTF-8");
							sDisplaySeq = rs.getString(3);
							sFingerprintSeq = rs.getString(4);
							sValueQty = rs.getString(5);
							sAttrName = rs.getString(6);
							sInternalFlag = rs.getString(7);
							%>
							<tr height="26">
								<td class="listItem_Title<%= sClassAppend %>"><A href="cust_attr_edit.jsp?cust_id=<%=cust.s_cust_id%>&attr_id=<%=sAttrId%>"><%=sDisplayName%></td>
								<!--<td class="listItem_Data<%= sClassAppend %>"><A href="cust_attr_edit.jsp?cust_id=<%=cust.s_cust_id%>&attr_id=<%=sAttrId%>"><%=sAttrName%></td>//-->
								<td class="listItem_Data<%= sClassAppend %>"><input type="checkbox" <%=(sValueQty==null)?"":"checked"%> disabled></td>
								<td class="listItem_Data<%= sClassAppend %>"><input type="checkbox" <%=(sFingerprintSeq==null)?"":"checked"%> disabled></td>
								<td class="listItem_Data<%= sClassAppend %>"><input type="checkbox" <%=(sInternalFlag==null)?"":"checked"%> disabled></td>
								<td class="listItem_Data<%= sClassAppend %>" align="center"><%=(sDisplaySeq==null)?"&nbsp":sDisplaySeq%></td>
							</tr>
							<%
						}
						rs.close();
					}
					catch(Exception ex) { ex.printStackTrace(new PrintWriter(out)); }
					finally
					{
						try{if(stmt!=null) stmt.close();}
						catch(Exception e) {}
						
						if(conn!=null) cp.free(conn);
					}
					%>
						</table>
						</div>
					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
</table>
</BODY>
</HTML>

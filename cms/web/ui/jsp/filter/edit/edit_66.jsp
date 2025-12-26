<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.tgt.*,
			java.io.*,java.sql.*,
			java.util.*,org.w3c.dom.*,
			org.apache.log4j.*"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../../validator.jsp"%>
<%! static Logger logger = null; %>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

//KU: Added for content logic ui
String sUsageTypeId = BriteRequest.getParameter(request, "usage_type_id");

String sTargetGroupDisplay = "Target Group";
if(String.valueOf(FilterUsageType.CONTENT).equals(sUsageTypeId))
{
	sTargetGroupDisplay = "Logic Element";
}
else
{
	sUsageTypeId = String.valueOf(FilterUsageType.REGULAR);
}
	
%>

<HTML>

<HEAD>
	<TITLE><%= sTargetGroupDisplay %>: Two Actions Performed</TITLE>
	<%@ include file="../../header.html" %>
	<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
	<SCRIPT>
		function do_submit()
		{
			filter_name = filter_form.filter_name.value;
			if((filter_name==null)||(filter_name.length==0))
			{
				alert('Invalid name.')
				filter_form.filter_name.focus();
				return false;
			}
			
			action_type = filter_form.action_type.value;
			if((action_type == null) || (action_type == 0))
			{
				alert("Please select an Action");
				filter_form.action_type.focus();
				return false;
			}
			
			action_param = filter_form.action_param.value;
			if((action_param == null) || (action_param == 0))
			{
				alert("Please select a Parameter");
				filter_form.action_param.focus();
				return false;
			}
			
			action_param_compare_value = filter_form.action_param_compare_value.value;
			if ((action_param_compare_value == null) || (action_param_compare_value.length == 0))
			{
				alert("Specify a comparison value for the Parameter")
				filter_form.action_param_compare_value.focus();
				return false;
			}
			
			action_type_2 = filter_form.action_type_2.value;
			if((action_type_2 == null) || (action_type_2 == 0))
			{
				alert("Please select an Action");
				filter_form.action_type_2.focus();
				return false;
			}
			
			action_param_2 = filter_form.action_param_2.value;
			if((action_param_2 == null) || (action_param_2 == 0))
			{
				alert("Please select a Parameter");
				filter_form.action_param_2.focus();
				return false;
			}
			
			action_param_compare_value_2 = filter_form.action_param_compare_value_2.value;
			if ((action_param_compare_value_2 == null) || (action_param_compare_value_2.length == 0))
			{
				alert("Specify a comparison value for the Parameter")
				filter_form.action_param_compare_value_2.focus();
				return false;
			}
			
			filter_form.action = "save_britetrack_calc.jsp?usage_type_id=<%= sUsageTypeId %>";
			filter_form.submit();
			return true;
		}
		
		function setCalcInfo()
		{
			var countLinks;
			var countSpan;
			
			countSpan = document.all.item("link_count");
			countLinks = filter_form.main_count.value;
			
			countSpan.innerText = countLinks;
		}
		
		function resizeWin()
		{
			top.window.resizeTo(700,690);
		}

		function resetWin()
		{
			top.window.resizeTo(700,300);
		}
	</SCRIPT>
</HEAD>

<BODY onload="resizeWin();" onunload="resetWin();">
<FORM name=filter_form method="POST">
<%
	try
	{
	String sSql = null;					
	ConnectionPool cp = null;
	Connection conn = null;
	cp = ConnectionPool.getInstance();
	
	String sFilterId = request.getParameter("filter_id");	
	String sFilterName = null;
	
	String sActionType = null;
	String sActionParam = null;
	String sActionParamCompareOperation = null;
	String sActionParamCompareValue = null;
	
	String sActionType2 = null;
	String sActionParam2 = null;
	String sActionParamCompareOperation2 = null;
	String sActionParamCompareValue2 = null;
	
	String sMode = null;	
	
	String sStartDate = null;
	String sFinishDate = null;
	
	String sDiffDate = null;
		
	String sDayCountCompareOperation = null;	
	String sDayCount = null;
	
	if(sFilterId != null)
	{
		com.britemoon.cps.tgt.Filter f = new com.britemoon.cps.tgt.Filter(sFilterId);
		sFilterName = f.s_filter_name;
		FilterParams fps = new FilterParams();
		fps.s_filter_id = sFilterId;
		fps.retrieve();

		sActionType = fps.getStringValue("action_type");
		sActionParam = fps.getStringValue("action_param");
		sActionParamCompareOperation = fps.getStringValue("action_param_compare_operation");
		sActionParamCompareValue = fps.getStringValue("action_param_compare_value");
		
		sActionType2 = fps.getStringValue("action_type_2");
		sActionParam2 = fps.getStringValue("action_param_2");
		sActionParamCompareOperation2 = fps.getStringValue("action_param_compare_operation_2");
		sActionParamCompareValue2 = fps.getStringValue("action_param_compare_value_2");

		sMode = fps.getStringValue("mode");

		sStartDate = fps.getStringValue("start_date");
		sFinishDate = fps.getStringValue("finish_date");
		sDiffDate = fps.getStringValue("diff_date");

		sDayCountCompareOperation = fps.getStringValue("day_count_compare_operation");
		sDayCount = fps.getIntegerValue("day_count");
%>
<INPUT type=hidden name=filter_id value=<%=sFilterId%>>
<%
	}
	if(sActionParamCompareOperation == null) sActionParamCompareOperation = "=";
	if(sActionParamCompareValue==null) sActionParamCompareValue = "";
	
	if(sActionParamCompareOperation2 == null) sActionParamCompareOperation2 = "=";
	if(sActionParamCompareValue2==null) sActionParamCompareValue2 = "";

	if(sMode == null) sMode = "date_diff";
		
	if(sStartDate==null) sStartDate = "MM/DD/YYYY";
	if(sFinishDate==null) sFinishDate = "TODAY";
	
	if(sDiffDate==null) sDiffDate = "TODAY";	

	if(sDayCountCompareOperation==null) sDayCountCompareOperation = "<";
	if(sDayCount==null) sDayCount = "30";
%>
<INPUT type=hidden name=type_id value="<%=FilterType.BRITETRACK_DID_TWO_ACTIONS%>">

<table id="Tabs_Table1" cellspacing=0 cellpadding=0 width=100% border=0>

	<tbody class=EditBlock id=block1_Step1>
	<tr>
		<td valign=top align=center width=100%>
			<table class=listTable cellspacing=0 cellpadding=0 width="100%">
				<tr>
					<th align="center" valign="middle">
						<b>Recipient Action Calculation</b>
						
					</th>
				</tr>
				<tr>
					<td align="center" valign="middle">
						
						Select recipients who performed two Actions during the same transaction.<br>
						The variable <font color="red">TODAY</font> can be used to create calculations based on the current date.<br>
					</td>
				</tr>
			</table>
			<br>
			<table class=listTable cellspacing=0 cellpadding=0 width="100%">
				<tr>
					<th align="center" valign="middle">
						Start by selecting an Action the recipient performed
					</th>
							<%
							sSql  = " SELECT actiontype, actionname FROM cjtk_action_type WHERE cust_id = " + cust.s_cust_id + " ORDER BY actionname";
						
							try
							{
								conn = cp.getConnection(this);
						
								PreparedStatement pstmt = null;
								try
								{
									pstmt = conn.prepareStatement(sSql);
									ResultSet rs = pstmt.executeQuery();
						
									String sId = null;
									String sName = null;
						
									byte[] b = null;
								%>
								<tr>
									<td align="center" valign="middle">
										Recipients performed Action:&nbsp;
										<select size=1 name=action_type>
											<option>---- Select an Action ----</option>
											<%
												while (rs.next())
												{
													sId = rs.getString(1);
													b = rs.getBytes(2);
													sName = (b==null)?null:new String(b, "UTF-8");
													%>
														<option value="<%=sId%>"<%=((sId.equals(sActionType))?" selected":"")%>><%= HtmlUtil.escape(sName) %></option>
													<%
												}
												rs.close();
											%>
										</select>
									</td>
								</tr>
								<%
							}
							catch(Exception ex) { throw ex; }
							finally { if(pstmt != null) pstmt.close(); }
						}
						catch(Exception ex) { throw new Exception(sSql+"\r\n"+ex.getMessage()); }
						finally { 
							if(conn != null)
							{
							 	cp.free(conn); 
							 	conn = null; 
							}
						}
						%>
					
				
				
				<tr>
					<td align="center" valign="middle">
						The selected Action was performed with Parameter...
						<tr>
							<td align="center" valign="middle" style="padding:10px;">
						<%
						sSql  = " SELECT parametertype, parametername FROM cjtk_action_parameter_type WHERE cust_id = " + cust.s_cust_id + " ORDER BY parametername";
						
						try
						{
							conn = cp.getConnection(this);
						
							PreparedStatement pstmt = null;
							try
							{
								pstmt = conn.prepareStatement(sSql);
								ResultSet rs = pstmt.executeQuery();
						
								String sId = null;
								String sName = null;
						
								byte[] b = null;
								%>
										

									Parameter:&nbsp;
									<select size=1 name=action_param>
									<option>---- Select a Parameter ----</option>
									<%
									while (rs.next())
									{
										sId = rs.getString(1);
										b = rs.getBytes(2);
										sName = (b==null)?null:new String(b, "UTF-8");
										%>
											<option value="<%=sId%>"<%=((sId.equals(sActionParam))?" selected":"")%>><%= HtmlUtil.escape(sName) %></option>
										<%
									}
									rs.close();
									%>
									</select>
								<%
							}
							catch(Exception ex) { throw ex; }
							finally { if(pstmt != null) pstmt.close(); }
						}
						catch(Exception ex) { throw new Exception(sSql+"\r\n"+ex.getMessage()); }
						finally {
							if(conn != null)
							{
								cp.free(conn); 
								conn = null;
							}
						}
						%>
						&nbsp;<select name="action_param_compare_operation">
							<option value="=" <%=("=".equals(sActionParamCompareOperation)?" selected":"")%>>Exactly (=)</option>
							<option value="&gt;" <%=(">".equals(sActionParamCompareOperation)?" selected":"")%>>More Than (&gt;)</option>
							<option value="&gt;=" <%=(">=".equals(sActionParamCompareOperation)?" selected":"")%>>More Than Or Exactly (&gt;=)</option>
							<option value="&lt;" <%=("<".equals(sActionParamCompareOperation)?" selected":"")%>>Fewer Than (&lt;)</option>
							<option value="&lt;" <%=("<=".equals(sActionParamCompareOperation)?" selected":"")%>>Fewer Than Or Exactly (&lt;=)</option>
						</select>
						&nbsp;<input type="text" name="action_param_compare_value" value="<%= HtmlUtil.escape(sActionParamCompareValue) %>" size="25">
						</td></tr>
					</td>
				</tr>
			</table>
			<br>
	<!-- =============================================================================== -->
			<table class=listTable cellspacing=0 cellpadding=0 width="100%">
			
			<th align="center" valign="middle">
						<b>Next, select a second Action the recipient performed during the same transaction</b>
						
					</th>
				<tr>
					<td align="center" valign="middle">
					
							<%
							sSql  = " SELECT actiontype, actionname FROM cjtk_action_type WHERE cust_id = " + cust.s_cust_id + " ORDER BY actionname";
						
							try
							{
								conn = cp.getConnection(this);
						
								PreparedStatement pstmt = null;
								try
								{
									pstmt = conn.prepareStatement(sSql);
									ResultSet rs = pstmt.executeQuery();
						
									String sId = null;
									String sName = null;
						
									byte[] b = null;
								%>
								<tr>
									<td align="center" valign="middle" style="padding:10px;">
										Recipients performed Action:&nbsp;
										<select size=1 name=action_type_2>
											<option>---- Select an Action ----</option>
											<%
												while (rs.next())
												{
													sId = rs.getString(1);
													b = rs.getBytes(2);
													sName = (b==null)?null:new String(b, "UTF-8");
													%>
														<option value="<%=sId%>"<%=((sId.equals(sActionType2))?" selected":"")%>><%= HtmlUtil.escape(sName) %></option>
													<%
												}
												rs.close();
											%>
										</select>
									</td>
								</tr>
								<%
							}
							catch(Exception ex) { throw ex; }
							finally { if(pstmt != null) pstmt.close(); }
						}
						catch(Exception ex) { throw new Exception(sSql+"\r\n"+ex.getMessage()); }
						finally { 
							if(conn != null)
							{
							 	cp.free(conn); 
							 	conn = null; 
							}
						}
						%>
					</td>
				</tr>
				<tr>
					<td align="center" valign="middle">
						The selected Action was performed with Parameter...
						<tr>
							<td align="center" valign="middle" style="padding:10px;">
						<%
						sSql  = " SELECT parametertype, parametername FROM cjtk_action_parameter_type WHERE cust_id = " + cust.s_cust_id + " ORDER BY parametername";
						
						try
						{
							conn = cp.getConnection(this);
						
							PreparedStatement pstmt = null;
							try
							{
								pstmt = conn.prepareStatement(sSql);
								ResultSet rs = pstmt.executeQuery();
						
								String sId = null;
								String sName = null;
						
								byte[] b = null;
								%>
										

									Parameter:&nbsp;
									<select size=1 name="action_param_2">
									<option>---- Select a Parameter ----</option>
									<%
									while (rs.next())
									{
										sId = rs.getString(1);
										b = rs.getBytes(2);
										sName = (b==null)?null:new String(b, "UTF-8");
										%>
											<option value="<%=sId%>"<%=((sId.equals(sActionParam2))?" selected":"")%>><%= HtmlUtil.escape(sName) %></option>
										<%
									}
									rs.close();
									%>
									</select>
								<%
							}
							catch(Exception ex) { throw ex; }
							finally { if(pstmt != null) pstmt.close(); }
						}
						catch(Exception ex) { throw new Exception(sSql+"\r\n"+ex.getMessage()); }
						finally {
							if(conn != null)
							{
								cp.free(conn); 
								conn = null;
							}
						}
						%>
						&nbsp;<select name="action_param_compare_operation_2">
							<option value="=" <%=("=".equals(sActionParamCompareOperation)?" selected":"")%>>Exactly (=)</option>
							<option value="&gt;" <%=(">".equals(sActionParamCompareOperation)?" selected":"")%>>More Than (&gt;)</option>
							<option value="&gt;=" <%=(">=".equals(sActionParamCompareOperation)?" selected":"")%>>More Than Or Exactly (&gt;=)</option>
							<option value="&lt;" <%=("<".equals(sActionParamCompareOperation)?" selected":"")%>>Fewer Than (&lt;)</option>
							<option value="&lt;" <%=("<=".equals(sActionParamCompareOperation)?" selected":"")%>>Fewer Than Or Exactly (&lt;=)</option>
						</select>
						&nbsp;<input type="text" name="action_param_compare_value_2" value="<%= HtmlUtil.escape(sActionParamCompareValue2) %>" size="25">
						</td></tr>
					</td>
				</tr>
			</table>
			<br>
			<table class=listTable cellspacing=0 cellpadding=0 width="100%">
				<tr>
					<th align="center" valign="middle" width="100%" colspan="2">Next, calculate the dates in which the recipient performed the Actions</th>
				</tr>
				<tr>
					<td align="center" valign="top" width="50%">
						<table cellspacing="0" cellpadding="2" border="0">
							<tr>
								<td align="center" valign="middle">
									<input type="radio" name="mode" value="date_diff"<%=(("date_diff".equals(sMode))?" checked":"")%>>
								</td>
							</tr>
							<tr>
								<td align="center" valign="middle">
									All recipients who opened HTML Emails where the <b>difference</b> between the 
								</td>
							</tr>
							<tr>
								<td align="center" valign="middle">
									Email open date and &nbsp;<input type="text" name="diff_date" value="<%= HtmlUtil.escape(sDiffDate) %>" onfocus="this.select();">&nbsp;is
								</td>
							</tr>
							<tr>
								<td align="center" valign="middle">
									<select name="day_count_compare_operation">
										<option value="=" <%=("=".equals(sDayCountCompareOperation)?" selected":"")%>>Equal To (=)</option>
										<option value="&gt;" <%=(">".equals(sDayCountCompareOperation)?" selected":"")%>>Greater Than (&gt;)</option>
										<option value="&gt;=" <%=(">=".equals(sDayCountCompareOperation)?" selected":"")%>>Greater Than Or Equal To (&gt;=)</option>
										<option value="&lt;" <%=("<".equals(sDayCountCompareOperation)?" selected":"")%>>Less Than (&lt;)</option>
										<option value="&lt;=" <%=("<=".equals(sDayCountCompareOperation)?" selected":"")%>>Less Than Or Equal To (&lt;=)</option>
									</select>
									&nbsp;
									<input type="text" name="day_count" value="<%=HtmlUtil.escape(sDayCount)%>" size="3">
									&nbsp;days
								</td>
							</tr>
						</table>
					</td>
					<td align="center" valign="top" width="50%">
						<table cellspacing="0" cellpadding="2" border="0" width="100%">
							<tr>
								<td align="center" valign="middle" colspan="2">
									<input type="radio" name="mode" value="start_finish"<%=(("start_finish".equals(sMode))?" checked":"")%>>
								</td>
							</tr>
							<tr>
								<td align="center" valign="middle" colspan="2">
									The HTML Emails were opened on dates 
								</td>
							</tr>
							<tr>
								<td align="right" valign="middle" width="50%">
									between:&nbsp;&nbsp;
								</td>
								<td align="left" valign="middle" width="50%">
									<input type="text" name="start_date" value="<%= HtmlUtil.escape(sStartDate) %>" onfocus="this.select();">
								</td>
							</tr>
							<tr>
								<td align="right" valign="middle" width="50%">
									and:&nbsp;&nbsp;
								</td>
								<td align="left" valign="middle" width="50%">
									<input type="text" name="finish_date" value="<%=HtmlUtil.escape(sFinishDate)%>" onfocus="this.select();">
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			<br>
			<table class=listTable cellspacing=0 cellpadding=0 width="100%">
				<tr>
					<th align="center" valign="middle">
						Finally, enter a name for this calculation: 
					</th>
				</tr>
				<tr>
					<td align="center" valign="middle"><input type="text" name="filter_name" size="80" value="<%= HtmlUtil.escape(sFilterName) %>">
				</tr>
				<tr>
					<td align="center" valign="middle" style="padding:10px;">
						<input type="button" class="subactionbutton" onclick="history.back();" value="<< Back">&nbsp;&nbsp;
						<input type="button" class="subactionbutton" onclick="window.close();" value="Cancel">&nbsp;&nbsp;
						<input type="button" class="subactionbutton" name="save" onclick="do_submit();" value="Save >>">&nbsp;&nbsp;
					</td>
				</tr>
			</table>
		</td>
	</tr>
	</tbody>
</table>
<%
 
}
finally
{/*
	if(conn != null)
	{
		cp.free(conn);
	}*/
}
%>
</FORM>
</BODY>
</HTML>

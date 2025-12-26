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
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../../../../utilities/validator.jsp"%>
<%! static Logger logger = null; %>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

//KU: Added for content logic ui
JsonObject jsonObject = new JsonObject();
JsonArray jsonArray = new JsonArray();
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
	
 try {
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

		jsonObject.put("filter_id", sFilterId);

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

	jsonObject.put("type_id", FilterType.BRITETRACK_DID_TWO_ACTIONS);
    sSql  = " SELECT actiontype, actionname FROM cjtk_action_type WHERE cust_id = " + cust.s_cust_id + " ORDER BY actionname";
	try {
		conn = cp.getConnection(this);
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement(sSql);
			ResultSet rs = pstmt.executeQuery();			
			String sId = null;
			String sName = null;
			byte[] b = null;
			while (rs.next()) {
				sId = rs.getString(1);
				b = rs.getBytes(2);
				sName = (b==null)?null:new String(b, "UTF-8");						
				}
				jsonObject.put("sId",sId);
				jsonObject.put("sName",sName);
				jsonObject.put("b",b);
				jsonArray.put(jsonObject);
				out.print(jsonArray);
				rs.close();
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
		sSql  = " SELECT parametertype, parametername FROM cjtk_action_parameter_type WHERE cust_id = " + cust.s_cust_id + " ORDER BY parametername";
		  try  {
				conn = cp.getConnection(this);
				PreparedStatement pstmt = null;
				try {
					 pstmt = conn.prepareStatement(sSql);
					 ResultSet rs = pstmt.executeQuery();
					 String sId = null;
					 String sName = null;
					 byte[] b = null;
						while (rs.next()) {
										sId = rs.getString(1);
										b = rs.getBytes(2);
										sName = (b==null)?null:new String(b, "UTF-8");
									}
										jsonObject.put("sId",sId);
										jsonObject.put("sName",sName);
										jsonObject.put("b",b);
										jsonArray.put(jsonObject);
									rs.close();
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

			if("=".equals(sActionParamCompareOperation)){
				jsonObject.put("action_param_compare_operation","=");
			}
			if(">".equals(sActionParamCompareOperation)){
				jsonObject.put("action_param_compare_operation",">");
			}
			if(">=".equals(sActionParamCompareOperation)){
				jsonObject.put("action_param_compare_operation",">=");
			}
			if("<".equals(sActionParamCompareOperation)){
				jsonObject.put("action_param_compare_operation","<");
			}
			if("<=".equals(sActionParamCompareOperation)){
				jsonObject.put("action_param_compare_operation","<=");
			}
			jsonObject.put("action_param_compare_value",sActionParamCompareValue);
			
			sSql  = " SELECT actiontype, actionname FROM cjtk_action_type WHERE cust_id = " + cust.s_cust_id + " ORDER BY actionname";
				try{
				    conn = cp.getConnection(this);
	                PreparedStatement pstmt = null;
					try{
						pstmt = conn.prepareStatement(sSql);
						ResultSet rs = pstmt.executeQuery();
						String sId = null;
						String sName = null;
						byte[] b = null;
						while (rs.next()){
							sId = rs.getString(1);
							b = rs.getBytes(2);
							sName = (b==null)?null:new String(b, "UTF-8");
							}
							jsonObject.put("sId",sId);
							jsonObject.put("sName",sName);
							jsonObject.put("b",b);
                            rs.close();
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
			sSql  = " SELECT parametertype, parametername FROM cjtk_action_parameter_type WHERE cust_id = " + cust.s_cust_id + " ORDER BY parametername";
						try {
						    conn = cp.getConnection(this);
							PreparedStatement pstmt = null;
							try{
								pstmt = conn.prepareStatement(sSql);
								ResultSet rs = pstmt.executeQuery();
								String sId = null;
								String sName = null;
								byte[] b = null;
								while (rs.next()){
										sId = rs.getString(1);
										b = rs.getBytes(2);
										sName = (b==null)?null:new String(b, "UTF-8");
									}
									jsonObject.put("sId",sId);
									jsonObject.put("sName",sName);
									jsonObject.put("b",b);
									rs.close();
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
		    if("=".equals(sActionParamCompareOperation)){
				jsonObject.put("action_param_compare_operation_2","=");
			}
			if(">".equals(sActionParamCompareOperation)){
				jsonObject.put("action_param_compare_operation_2",">");
			}
			if(">=".equals(sActionParamCompareOperation)){
				jsonObject.put("action_param_compare_operation_2",">=");
			}
			if("<".equals(sActionParamCompareOperation)){
				jsonObject.put("action_param_compare_operation_2","<");
			}
			if("<=".equals(sActionParamCompareOperation)){
				jsonObject.put("action_param_compare_operation_2","<=");
			}
			jsonObject.put("action_param_compare_value_2",sActionParamCompareValue);
			jsonObject.put("date_diff",("date_diff".equals(sMode)?" checked":""));
			jsonObject.put("diff_date",sDiffDate);

			if("=".equals(sDayCountCompareOperation)){
				jsonObject.put("day_count_compare_operation","=");
			}
			if(">".equals(sDayCountCompareOperation)){
				jsonObject.put("day_count_compare_operation",">");
			}
			if(">=".equals(sDayCountCompareOperation)){
				jsonObject.put("day_count_compare_operation",">=");
			}
			if("<".equals(sDayCountCompareOperation)){
				jsonObject.put("day_count_compare_operation","<");
			}
			if("<=".equals(sDayCountCompareOperation)){
				jsonObject.put("day_count_compare_operation","<=");
			}
			jsonObject.put("day_count",sDayCount);
			jsonObject.put("start_finish",("start_finish".equals(sMode)?" checked":""));
			jsonObject.put("start_date",sStartDate);
			jsonObject.put("finish_date",sFinishDate);

			jsonArray.put(jsonObject);
			out.print(jsonArray);
}
finally{
	
}
%>


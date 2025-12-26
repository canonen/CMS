<%@ page language="java"
		 import="java.net.*,
	   		java.util.ArrayList,
	   		java.text.SimpleDateFormat,
	   		com.britemoon.cps.rpt.*,
			com.britemoon.cps.tgt.*,
			com.britemoon.cps.que.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.*,
            com.britemoon.*,
			com.britemoon.rcp.*,
			com.britemoon.rcp.imc.*,
			com.britemoon.rcp.que.*,
			java.sql.*,
			java.util.Calendar,
			java.util.Date,java.io.*,
			java.math.BigDecimal,
			java.text.NumberFormat,
			java.util.Locale,
			java.io.*,
			org.apache.log4j.Logger,
			org.w3c.dom.*"
		 contentType="text/html;charset=UTF-8"%>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
%>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%
boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

	String custid=cust.s_cust_id;

	if(custid==null)
		return;

// Get Connection
	Statement		stmt	= null;
	ResultSet resulSet = null;
	ResultSet		sr	= null;

	ResultSet		dr	= null;
	ResultSet       rd  = null;
	ResultSet 		rcp = null;
	ConnectionPool  cp	= null;
	Connection		connm	= null;

	String taskName = "";
	String startDate = "";
	String finishDate = "";
	String recordCount = "";
	String status = "";



	JsonArray  reportXmlParseHistoryData = new JsonArray();
	JsonObject  data = new JsonObject();
	try
	{
		cp = ConnectionPool.getInstance();
		connm = cp.getConnection(this);
		stmt = connm.createStatement();

		String query="SELECT task_name, start_date, finish_date, record_count, status FROM ccps_attribute_xml_summary where cust_id = "+ custid +" order by finish_date desc";

		resulSet =stmt.executeQuery(query);

		while (resulSet.next()){

		taskName = resulSet.getString(1);
		startDate = resulSet.getString(2);
		finishDate = resulSet.getString(3);
		recordCount = resulSet.getString(4);
		status = resulSet.getString(5);

			data.put("taskName",taskName);
			data.put("startDate",startDate);
			data.put("finishDate",finishDate);
			data.put("recordCount",recordCount);
			data.put("status",status);

			reportXmlParseHistoryData.put(data);
			
			data = new JsonObject();

		}
		resulSet.close();

	out.print(reportXmlParseHistoryData.toString());
		//out.print(data.toString());
	} catch (Exception e) {
		e.printStackTrace();
	}
	finally{
		try {

			if (resulSet != null)
				resulSet.close();
			if (sr != null)
				sr.close();
			if (stmt != null)
				stmt.close();
			if (connm != null) {

				connm.close();
				cp.free(connm);
			}
		}catch (SQLException e) { /* ignored */}
	}


%>

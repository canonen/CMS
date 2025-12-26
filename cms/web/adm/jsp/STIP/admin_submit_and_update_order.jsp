<%@ page
	language="java"
	import="com.britemoon.*,com.britemoon.cps.*,com.britemoon.cps.xcs.cti.*, java.util.*,java.sql.*,java.net.*"
	contentType="text/html;charset=UTF-8"
%>

<%@ include file="../header.jsp"%>

<HTML>
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="../../css/style.css" TYPE="text/css">
</HEAD>

<BODY>
<%

String sCustId = request.getParameter("cust_id");
String sCampId = request.getParameter("camp_id");
String sChunkId = request.getParameter("chunk_id");
String sFileName = request.getParameter("file_name");

if (sCustId == null || sCampId == null || sChunkId == null || sFileName == null) {
     out.println("One or more parameters missing.  Need cust, camp, chunk, filename");
} else {
     try {
		  String sSql =
				" UPDATE cxcs_delivery " +
				"    SET status = 1 " +
				"  WHERE camp_id = " + sCampId +
				"    AND chunk_id = " + sChunkId;
		  BriteUpdate.executeUpdate(sSql);
			
          CTIDelivery cti = new CTIDelivery();
          String sOrderId = cti.submitOrder(sCustId, sCampId, sChunkId, sFileName);
          if (sOrderId ==  null || sOrderId.equals("") || sOrderId.length() <= 1) {
			String sSql2 =
				" UPDATE cxcs_delivery " +
				"    SET submit_date = null " +
				"  WHERE camp_id = " + sCampId +
				"    AND chunk_id = " + sChunkId;
			BriteUpdate.executeUpdate(sSql2);
               
			out.println("Failed to re-submit Order. Order is put back into the Order Delivery Timer queue to be delivered at a later time.");
          } else {
               boolean rc = cti.updateOrder(sCustId, sCampId, sChunkId, sOrderId, sFileName);
               if (rc) {

                    String sSql3 =
                         " UPDATE cxcs_delivery " +
                         "    SET submit_date = getDate(), status = null " +
                         "  WHERE camp_id = " + sCampId +
                         "    AND chunk_id = " + sChunkId;
                    BriteUpdate.executeUpdate(sSql3);
                    
                    out.println("Order successfully re-submitted!");
               } else {
                    out.println("Order successfully re-submitted, but updateOrder failed, Please call for support.");
               }
          }

     } catch (Exception e) {
          out.println("Exception thrown.");
          throw e;
     }



}


%>


</BODY>
</HTML>


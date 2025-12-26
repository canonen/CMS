<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.cnt.*,
		com.britemoon.cps.ctl.*,
		com.britemoon.cps.wfl.*,
		java.sql.*,java.io.*,java.util.*,
		org.apache.log4j.*"
	contentType="text/html;charset=UTF-8"
	errorPage="../error_page.jsp"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="../../utilities/validator.jsp"%>
<%@ include file="../header.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

	if(!can.bRead)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}

	AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

	//Is it the standard ui?
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
	boolean canDynCont = ui.getFeatureAccess(Feature.DYNAMIC_CONTENT);

	String contID = request.getParameter("cont_id");
	if (!can.bWrite && contID == null)
	{
		response.sendRedirect("../access_denied.jsp");
		return;
	}
	
     String sAprvlRequestId = request.getParameter("aprvl_request_id");
     boolean isApprover = false;
     if (contID != null) {
          if (sAprvlRequestId == null)
               sAprvlRequestId = "";
          ApprovalRequest arRequest = null;
          if (sAprvlRequestId != null && !sAprvlRequestId.equals("")) {
               arRequest = new ApprovalRequest(sAprvlRequestId);
          } else {
               logger.info("sAprvlRequestId was null or '', getting Approval Request for contID:" + contID);
               arRequest = WorkflowUtil.getApprovalRequest(cust.s_cust_id, String.valueOf(ObjectType.CONTENT),contID);
			   System.out.println(arRequest);
          }
          if (arRequest != null && arRequest.s_approver_id != null && arRequest.s_approver_id.equals(user.s_user_id)) {
               sAprvlRequestId = arRequest.s_approval_request_id;
               isApprover = true;
          }
     }

     boolean bWorkflow = WorkflowUtil.getWorkflow(cust.s_cust_id, ObjectType.CONTENT);
     boolean bContentDraft = false, bContentPending = false, bCampPending = false, bContentReady = false, bContentNew = false;
     if (contID != null) {
          Content cont = new Content(contID);
          bContentDraft = (ContStatus.DRAFT == Integer.parseInt(cont.s_status_id));
          bContentPending = (ContStatus.PENDING_APPROVAL == Integer.parseInt(cont.s_status_id));
          bCampPending = (ContStatus.PENDING_CAMP == Integer.parseInt(cont.s_status_id));
          bContentReady = (ContStatus.READY == Integer.parseInt(cont.s_status_id));
          logger.info("statuses for contID:" + contID + " are draft/pending/ready:" + bContentDraft + "/" + bContentPending + "/" + bContentReady);
     } else if (contID == null) {
          bContentNew = true;
     }

	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;

	String contName="New Content",contStatus="",sendType="",contHTML="",contText="",contAOL="";
	String creator="",creationDate="",editor="",modifyDate="",firstPers="",firstBlock="";
	String unsubID="",unsubPosition="",textFlag="",htmlFlag="",aolFlag="";
	
	int contTypeID = ContType.CONTENT;
	String ctiDocID = "";
	boolean isPrint = false;

	String htmlTracking = "";
	String htmlPersonals = "";
	String htmlStatuses = "";
	String htmlCharsets = "";
	String htmlCurPers = "";
	String jsPersonals = "";
	String jsSubmitPers = "";
	String htmlLogicBlocks = "";
	String htmlUnsubs = "";
	String htmlCategories = "";
	String htmlUnsubContent = "";
	String textUnsubContent = "";
	String aolUnsubContent = "";
	String jsUnsubs = "";
	String tmpUnsubName ="";

	String htmlCurBlocks = getLogicBlockListHtml(contID);

	// === === ===

	ConnectionPool cp	= null;
	Connection conn		= null;
	Statement stmt		= null;
	ResultSet rs		= null;

	JsonObject dataObject = new JsonObject();
	JsonArray arrayObject = new JsonArray();
	JsonObject allDataObject = new JsonObject();

	String sSql = null;
	byte[] b = null;
	try
	{
		cp = ConnectionPool.getInstance();
		conn = cp.getConnection(this);
		stmt = conn.createStatement();

		if (contID!=null)
		{
			rs = stmt.executeQuery("Exec dbo.usp_ccnt_info_get "+contID);
			if (rs.next())
			{
				dataObject = new JsonObject();

				b = rs.getBytes("Name");
				contName = (b==null)?"":new String(b,"UTF-8");
				contStatus = rs.getString("Status");
				sendType = rs.getString("SendType");
				contTypeID = rs.getInt("TypeID");
				ctiDocID = rs.getString("ctiDocID");
				
				b = rs.getBytes("HTML");				
				contHTML = (b==null)?"":new String(b,"UTF-8");
				b = rs.getBytes("Text");
				contText = (b==null)?"":new String(b,"UTF-8");
				b = rs.getBytes("AOL");
				contAOL = (b==null)?"":new String(b,"UTF-8");
				
				unsubID = rs.getString("unsub_msg_id");
				unsubPosition = rs.getString("unsub_msg_position");
				textFlag = rs.getString("send_text_flag");
				htmlFlag = rs.getString("send_html_flag");
				aolFlag = rs.getString("send_aol_flag");
				creator = rs.getString("creator");
				creationDate = rs.getString("create_date");
				editor = rs.getString("modifier");
				modifyDate = rs.getString("modify_date");

				if(b==null) dataObject.put("contName","");
				else dataObject.put("contName",contName);

				dataObject.put("contName",contName);
				dataObject.put("contStatus",contStatus);
				dataObject.put("sendType",sendType);
				dataObject.put("contTypeID",contTypeID);
				dataObject.put("ctiDocID",ctiDocID);
				dataObject.put("contHTML",contHTML);
				dataObject.put("contAOL",contAOL);
				dataObject.put("unsubID",unsubID);
				dataObject.put("unsubPosition",unsubPosition);
				dataObject.put("textFlag",textFlag);
				dataObject.put("htmlFlag",htmlFlag);
				dataObject.put("aolFlag",aolFlag);
				dataObject.put("creator",creator);
				dataObject.put("creationDate",creationDate);
				dataObject.put("editor",editor);
				dataObject.put("modifyDate",modifyDate);

				arrayObject.put(dataObject);
			}
			allDataObject.put("saveToContent",arrayObject);
			rs.close();

			sSql =
				" SELECT link_name, href" +
				" From cjtk_link" +
				" WHERE cont_id=" + contID;

			rs = stmt.executeQuery(sSql);
			

			boolean bShowButton = (can.bWrite && !(bWorkflow && bContentPending) && !bCampPending);

			arrayObject= new JsonArray();
			while (rs.next())
			{
				dataObject = new JsonObject();
				b = rs.getBytes(1);
				String href =(rs.getString(2));

				dataObject.put("linkName",b);
				dataObject.put("href",href);
				arrayObject.put(dataObject);

			}
			allDataObject.put("link",arrayObject);
			rs.close();
		}
		arrayObject = new JsonArray();

		//Unsubscribes
		if (unsubID == null) unsubID = "-1";
		if (unsubPosition == null) unsubPosition = "-1";
		String tmpUnsubID = "";
		
		sSql = 
			" SELECT msg_id, ISNULL(msg_name,''), ISNULL(html_msg,''), ISNULL(text_msg,''), ISNULL(aol_msg,'') " +
			" FROM ccps_unsub_msg WHERE cust_id = "+cust.s_cust_id;
							   
		rs = stmt.executeQuery(sSql);
		while (rs.next())
		{
			dataObject = new JsonObject();
			tmpUnsubID = rs.getString(1);
			tmpUnsubName= new String(rs.getBytes(2),"UTF-8");
			if (unsubID.equals(tmpUnsubID))
			{
				dataObject.put("messageID",tmpUnsubID);
				dataObject.put("isSelected","Selected");
				dataObject.put("messageName",tmpUnsubName);
			}
			else
			{
				dataObject.put("messageID",tmpUnsubID);
				dataObject.put("isSelected","");
				dataObject.put("messageName",tmpUnsubName);
			}
				dataObject.put("messageID",tmpUnsubID);
				dataObject.put("htmlMessage",new String(rs.getBytes(3),"UTF-8"));
				dataObject.put("textMessage",new String(rs.getBytes(4),"UTF-8"));
				dataObject.put("textMessage",new String(rs.getBytes(5),"UTF-8"));

				arrayObject.put(dataObject);

		}
		allDataObject.put("unsubMessage",arrayObject);
		rs.close();

		arrayObject= new JsonArray();
		//Personalization
		String attrName,attrDisplayName,tmp,defaultValue,attrID;
		int i,j;
		sSql = 
			" SELECT c.attr_id, attr_name, display_name " +
			" FROM ccps_attribute a, ccps_cust_attr c " +
			" WHERE c.cust_id = "+cust.s_cust_id+" AND a.attr_id = c.attr_id " +
			" AND display_seq IS NOT NULL " +
			" ORDER BY display_seq";

		rs = stmt.executeQuery(sSql);
		while (rs.next())
		{

			dataObject = new JsonObject();
			attrID = rs.getString(1);
			attrName = rs.getString(2);
			b = rs.getBytes(3);
			attrDisplayName = (b==null)?"":new String(b,"UTF-8");
			if (firstPers.length() == 0) firstPers = attrName;
			dataObject.put("attrName",attrName);
			dataObject.put("attrDisplayName",attrDisplayName);
			//Scan the contents for Personalization
			String allConts = contText + contHTML + contAOL;
			if (allConts != null && allConts.length() != 0)
			{
				i = allConts.indexOf("!*"+attrName+";");
				if (i != -1) {
					tmp = allConts.substring(i);
					j = tmp.indexOf("*!");
					if (j != -1) {
						defaultValue = tmp.substring(3+attrName.length(),j);
						dataObject.put("attrDisplayName",attrDisplayName);
						dataObject.put("attrID",attrID);
						dataObject.put("defaultValue",defaultValue);
						if (attrID == attrID) {
								dataObject.put("attrID",attrID);
								dataObject.put("attrName",attrName);
						}
					}
				}
			}
			arrayObject.put(dataObject);
		}
		allDataObject.put("personalizationFields",arrayObject);
		rs.close();

		arrayObject = new JsonArray();
		//Logic Blocks
		String logicBlockID, logicBlockName;
		if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) )
		{
			sSql = 
				" SELECT cont_id, cont_name" +
				" FROM ccnt_content " +
				" WHERE cust_id = " + cust.s_cust_id +
				" AND type_id = 25 " +
				" AND status_id = 20 " +
				" AND origin_cont_id IS NULL " +
				" ORDER BY cont_name";
			
		}
		else
		{
			sSql =
				" SELECT cont_id, cont_name" +
				" FROM ccnt_content b, ccps_object_category oc " +
				" WHERE b.cust_id = " + cust.s_cust_id +
				" AND b.type_id = 25 " +
				" AND b.status_id = 20 " +
				" AND b.cont_id = oc.object_id" +
				" AND origin_cont_id IS NULL " +
				" AND oc.type_id = " + ObjectType.CONTENT +
				" AND oc.cust_id = " + cust.s_cust_id +
				" AND oc.category_id = " + sSelectedCategoryId +
				" ORDER BY cont_name";
		}
		
		rs = stmt.executeQuery(sSql);		
		while (rs.next())
		{
			dataObject= new JsonObject();
			logicBlockID = rs.getString(1);
			b = rs.getBytes(2);
			logicBlockName = (b==null)?"":new String(b,"UTF-8");
			
			if (firstBlock.length() == 0) firstBlock = logicBlockName+";"+logicBlockID;
			dataObject.put("isSelected","Selected");
			dataObject.put("logicBlockID",logicBlockID);
			dataObject.put("logicBlockName",logicBlockName);
			arrayObject.put(dataObject);
		}
		rs.close();
		allDataObject.put("logicBlockSelect",arrayObject);

		arrayObject	= new JsonArray();
		//Statuses
		String tmpStatusID = "";
		sSql =
			" SELECT status_id, status_name" +
			" FROM ccnt_cont_status" +
			" WHERE UPPER(status_name) <> 'DELETED' " +
               " AND UPPER(status_name) NOT LIKE '%PENDING%' ";
		rs = stmt.executeQuery(sSql);
		while (rs.next())
		{
			dataObject = new JsonObject();
			tmpStatusID = rs.getString(1);
			if (contStatus.equals(tmpStatusID)) {
				dataObject.put("tmpStatusID", tmpStatusID);
				dataObject.put("isSelected","Selected");
				dataObject.put("statusName", rs.getString(2));
			}
			else{
			dataObject.put("tmpStatusID",tmpStatusID);
			dataObject.put("isSelected","");
			dataObject.put("statusName",rs.getString(2));
			}
			arrayObject.put(dataObject);
		}
		rs.close();
		allDataObject.put("statusSelect",arrayObject);

		arrayObject = new JsonArray();
		//Charsets
		String tmpCharsetID = "";
		rs = stmt.executeQuery("SELECT charset_id, display_name FROM ccnt_charset");
		while (rs.next())
		{
			dataObject = new JsonObject();
			tmpCharsetID = rs.getString(1);			
			if (sendType.equals(tmpCharsetID)){
				dataObject.put("tmpCharsetID",tmpCharsetID);
				dataObject.put("isSelected","Selected");
				dataObject.put("displayName",rs.getString(2));
			}
			else{
			dataObject.put("tmpCharsetID",tmpCharsetID);
			dataObject.put("isSelected","");
			dataObject.put("displayName",rs.getString(2));
			}
			arrayObject.put(dataObject);
		}
		allDataObject.put("charsetSelect",arrayObject);
		rs.close();
		arrayObject = new JsonArray();

//		htmlCategories =
//			CategortiesControl.toHtmlOptions(cust.s_cust_id, ObjectType.CONTENT, contID, sSelectedCategoryId);
		sSql = "";

		String sCategoryId = null;
		String sCategoryName = null;
		String sObjId = null;
		boolean isSelected = false;
		if (contID!= null) {
			sSql = "SELECT c.category_id, c.category_name, oc.object_id" +
					" FROM ccps_category c" +
					" LEFT OUTER JOIN ccps_object_category oc" +
					" ON (c.category_id = oc.category_id" +
					" AND c.cust_id = oc.cust_id" +
					" AND oc.object_id =" + contID +
					" AND oc.type_id="+ObjectType.EXPORT+")" +
					" WHERE c.cust_id="+cust.s_cust_id;
		} else {
			sSql = "SELECT c.category_id, c.category_name, [object_id] = NULL" +
					" FROM ccps_category c" +
					" WHERE c.cust_id="+cust.s_cust_id;
		}

		ResultSet rs3 = stmt.executeQuery(sSql);

		while (rs3.next())
		{
			dataObject= new JsonObject();
			sCategoryId = rs3.getString(1);
			sCategoryName = new String(rs3.getBytes(2), "UTF-8");
			sObjId = rs3.getString(3);

			isSelected =
					(sObjId!=null) || ((sSelectedCategoryId!=null)&&(sSelectedCategoryId.equals(sCategoryId)));

			dataObject.put("CategoryID",sCategoryId);
			dataObject.put("CategoryName",sCategoryName);
			if(isSelected) dataObject.put("isSelected","selected");
			else dataObject.put("isSelected","");

			arrayObject.put(dataObject);
		}
		allDataObject.put("categorySelect",arrayObject);
	}
	catch(Exception ex) { throw ex; }
	finally
	{
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}
	
	if (contTypeID == ContType.PRINT) isPrint = true;

	JsonObject contSaveData = new JsonObject();
	JsonArray contSaveArray = new JsonArray();
	 if (can.bWrite) {
		 contSaveData.put("sSelectedCategoryId",sSelectedCategoryId);
	 }
	 else contSaveData.put("sSelectedCategoryId",sSelectedCategoryId);

	if(contID!=null) contSaveData.put("contID",contID);
	else contSaveData.put("contID","");

	if(ctiDocID!=null) contSaveData.put("ctiDocID",ctiDocID);
	else contSaveData.put("ctiDocID","");

		contSaveData.put("objectType",String.valueOf(ObjectType.CONTENT));
		contSaveData.put("sAprvlRequestId",sAprvlRequestId);
		contSaveData.put("contTypeID",String.valueOf(contTypeID));
		contSaveData.put("htmlUnsubContent",htmlUnsubContent);
		contSaveData.put("textUnsubContent",textUnsubContent);
		contSaveData.put("aolUnsubContent",aolUnsubContent);


//				if (contID != null)
//				{
//					if (can.bDelete && (!bWorkflow || (bWorkflow && !bContentPending)) && !bCampPending)
//					{
//						if(sSelectedCategoryId!=null){
//						response.sendRedirect("cont_delete.jsp?cont_id"+contID+"&category_id="+sSelectedCategoryId);
//						}
//						else response.sendRedirect("cont_delete.jsp?cont_id"+contID+"&category_id="+"");
//						return;
//					}
//				}

				if(bWorkflow && !can.bApprove){
					contSaveData.put("isDisabled","disabled");
				}
				else contSaveData.put("isDisabled","");

				contSaveData.put("htmlStatuses",htmlStatuses);

				if(!canCat.bExecute){
					contSaveData.put("isDisabled","disabled");
				}
				else contSaveData.put("isDisabled","");

				contSaveData.put("htmlCategories",htmlCategories);

				if(!canCat.bExecute && (sSelectedCategoryId != null) && !(sSelectedCategoryId.equals("0"))){
				contSaveData.put("sSelectedCategoryId",sSelectedCategoryId);
				}
				else contSaveData.put("sSelectedCategoryId","");

				contSaveData.put("htmlCharsets",htmlCharsets);
				contSaveData.put("htmlUnsubs",htmlUnsubs);

				if(unsubPosition.equals("1")) contSaveData.put("isSelected","selected");
				else  contSaveData.put("isSelected","");
				if(unsubPosition.equals("0")) contSaveData.put("isSelected","selected");
				else  contSaveData.put("isSelected","");
				if(unsubPosition.equals("-1")) contSaveData.put("isSelected","selected");
				else  contSaveData.put("isSelected","");
				contSaveArray.put(contSaveData);
				allDataObject.put("contInfo",contSaveArray);

				contSaveArray = new JsonArray();

				if (isPrint) {
				contSaveData.put("contID",contID);
			 	}
				else {
				contSaveData.put("htmlPersonals",htmlPersonals);
				contSaveData.put("firstPers",firstPers);

					 if (canDynCont) {
						contSaveData.put("htmlLogicBlocks",htmlLogicBlocks);
						contSaveData.put("firstBlock",firstBlock);
					 }

					contSaveData.put("htmlCurPers",htmlCurPers);
					contSaveData.put("contText",HtmlUtil.escape(contText));
					contSaveData.put("contAOL",HtmlUtil.escape(contAOL));
					contSaveData.put("contHTML",HtmlUtil.escape(contHTML));
					contSaveData.put("htmlTracking",htmlTracking);
				}

				contSaveData.put("creator",creator);
				contSaveData.put("editor",editor);
				contSaveData.put("creationDate",creationDate);
				contSaveData.put("modifyDate",modifyDate);
				contSaveArray.put(contSaveData);
				allDataObject.put("contSaveData",contSaveArray);
				out.println(allDataObject);
%>
<%!
private String getLogicBlockListHtml(String sContId) throws Exception
{
	JsonObject data = new JsonObject();
	JsonArray array	= new JsonArray();
	ContBody cb = new ContBody(sContId);
	String sText = cb.s_text_part + cb.s_html_part + cb.s_aol_part;
	Vector vLogicBlockIds = ContUtil.getLogicBlockIds(sText);
	
	String htmlCurBlocks = "";
	
	String sLogicBlockId = null;
	Content cont = new Content();
	for (Enumeration e = vLogicBlockIds.elements() ; e.hasMoreElements() ;)
	{
		data = new JsonObject();
		sLogicBlockId = (String) e.nextElement();
		cont.s_cont_id = sLogicBlockId;
		if(cont.retrieve()< 1) continue;
		data.put("contID",cont.s_cont_id);
		data.put("contName",cont.s_cont_name);

		array.put(data);
	}
	
	return data.toString();
}
%>

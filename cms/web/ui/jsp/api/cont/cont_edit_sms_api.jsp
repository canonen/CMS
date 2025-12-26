<%@ page
        language="java"
        import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.cnt.*,
		com.britemoon.cps.ctl.*,
		com.britemoon.cps.wfl.*,
		java.sql.*,java.io.*,java.util.*,
		org.apache.log4j.*"
        contentType="application/json;charset=UTF-8"
%>

<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ include file="../validator.jsp"%>
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


    JsonObject resultObj = new JsonObject();
    JsonArray contObjArray = new JsonArray();
    JsonArray trackingLinksObjArray = new JsonArray();
    JsonArray attrObjArray = new JsonArray();
    JsonArray statusesObjArray = new JsonArray();
    JsonArray charsetsObjArray = new JsonArray();




    AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

//    //Is it the standard ui?
//    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
//    boolean canDynCont = ui.getFeatureAccess(Feature.DYNAMIC_CONTENT);

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

    //CY 09.21.2017
    int contTypeID = ContType.CONTENT;
    //int contTypeID ="";
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

    String htmlCurBlocks = getLogicBlockListHtml(contID);

    // === === ===

    ConnectionPool cp	= null;
    Connection conn		= null;
    Statement stmt		= null;
    ResultSet rs		= null;

    String sSql = null;
    byte[] b = null;
    try
    {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();

        if (contID!=null) {
            rs = stmt.executeQuery("Exec dbo.usp_ccnt_info_get "+contID);
            if (rs.next()) {
                JsonObject json = new JsonObject();
                b = rs.getBytes("Name");
                contName = (b==null)?"":new String(b,"UTF-8");
                contStatus = rs.getString("Status");
                sendType = rs.getString("SendType");
                contTypeID = rs.getInt("TypeID");
                ctiDocID = rs.getString("ctiDocID");

//                b = rs.getBytes("HTML");
//                contHTML = (b==null)?"":new String(b,"UTF-8");
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

                json.put("contName" , contName);
                json.put("contStatus" , contStatus);
                json.put("sendType" , sendType);
                json.put("contTypeID" , contTypeID);
                json.put("ctiDocID" , ctiDocID);
//                json.put("contHTML" , contHTML);
                json.put("contText" , contText);
                json.put("contAOL" , contAOL);
                json.put("unsubID" , unsubID);
                json.put("unsubPosition" , unsubPosition);
                json.put("textFlag" , textFlag);
                json.put("htmlFlag" , htmlFlag);
                json.put("aolFlag" , aolFlag);
                json.put("creator" , creator);
                json.put("creationDate" , creationDate);
                json.put("editor" , editor);
                json.put("modifyDate" , modifyDate);

                contObjArray.put(json);
            }
            resultObj.put("content", contObjArray);

            rs.close();

            sSql =
                    " SELECT link_name, href" +
                            " From cjtk_link" +
                            " WHERE cont_id=" + contID;

            rs = stmt.executeQuery(sSql);


            boolean bShowButton = (can.bWrite && !(bWorkflow && bContentPending) && !bCampPending);
            while (rs.next()) {
                JsonObject json = new JsonObject();
                htmlTracking += "<tr>\n";
                htmlTracking += (bShowButton?"<td align=\"right\" valign=\"middle\" nowrap><a class=\"subactionbutton\" href=\"#EditLink\" onclick=\"EditLinkTable(event)\">edit</a></td>\n":"");
                b = rs.getBytes(1);

                htmlTracking += "<td align=\"left\" valign=\"middle\">"+((b==null)?"":new String(b,"UTF-8"))+"</td>\n";
                htmlTracking += "<td align=\"left\" valign=\"middle\"><div style=\"overflow:hidden; text-overflow:ellipsis;\"><a title=\"Click here to verify that your link is valid.\" href=\"javascript:void(0);\" onclick=\"launchURL();\">"+HtmlUtil.escape(rs.getString(2))+"</a></div></td>\n";
                htmlTracking += (bShowButton?"<td align=\"right\" valign=\"middle\" nowrap><a class=\"resourcebutton\" href=\"#EditLink\" onclick=\"CloneLinkTable(event)\">clone</a></td>\n":"");
                htmlTracking += (bShowButton?"<td align=\"right\" valign=\"middle\" nowrap><a class=\"resourcebutton\" href=\"javascript:void(0);\" onclick=\"DeleteLinkTable(event)\">delete</a></td>\n":"");
                htmlTracking += "</tr>\n";

                json.put("htmlTracking" , htmlTracking);
                json.put("linkName" , b);
                trackingLinksObjArray.put(json);
            }
            resultObj.put("trackingLinks" , trackingLinksObjArray);
            rs.close();
        }

        //Unsubscribes
        if (unsubID == null) unsubID = "-1";
        if (unsubPosition == null) unsubPosition = "-1";
        String tmpUnsubID = "";

//        sSql =
//                " SELECT msg_id, ISNULL(msg_name,''), ISNULL(html_msg,''), ISNULL(text_msg,''), ISNULL(aol_msg,'') " +
//                        " FROM ccps_unsub_msg WHERE cust_id = "+cust.s_cust_id;
//
//        rs = stmt.executeQuery(sSql);
//        while (rs.next()) {
//            JsonObject json = new JsonObject();
//            tmpUnsubID = rs.getString(1);
//            if (unsubID.equals(tmpUnsubID)) {
//                htmlUnsubs += "<option selected value="+tmpUnsubID+">"+new String(rs.getBytes(2),"UTF-8")+"</option>\n";
//            }
//            else {
//                htmlUnsubs += "<option value="+tmpUnsubID+">"+new String(rs.getBytes(2),"UTF-8")+"</option>\n";
//            }
//
//            htmlUnsubContent +=
//                    "<textarea style=display:none name=UnsubContentHTML"+tmpUnsubID+">"+
//                            new String(rs.getBytes(3),"UTF-8")+"</textarea>\n";
//
//            textUnsubContent +=
//                    "<textarea style=display:none name=UnsubContentText"+tmpUnsubID+">"+
//                            new String(rs.getBytes(4),"UTF-8")+"</textarea>\n";
//
//            aolUnsubContent +=
//                    "<textarea style=display:none name=UnsubContentAOL"+tmpUnsubID+">"+
//                            new String(rs.getBytes(5),"UTF-8")+"</textarea>\n";
//
//            jsUnsubs += "if (document.all.unsubID.value == "+tmpUnsubID+") {\n" +
//                    "	if (act=='1') unTxt = FT.UnsubContentText"+tmpUnsubID+".value;\n" +
//                    "	if (act=='2') unTxt = FT.UnsubContentHTML"+tmpUnsubID+".value;\n" +
//                    "	if (act=='3') unTxt = FT.UnsubContentAOL"+tmpUnsubID+".value;\n" +
//                    "}\n";
//
//            json.put("tmpUnsubID" , tmpUnsubID);
//            json.put("htmlUnsubs" , htmlUnsubs);
//            json.put("htmlUnsubContent" , htmlUnsubContent);
//            json.put("textUnsubContent" , textUnsubContent);
//            json.put("aolUnsubContent" , aolUnsubContent);
//            json.put("jsUnsubs" , jsUnsubs);
//
//            unsubscribeMessagesObjArray.put(json);
//            unsubscribeMessagesObj.put("unsubscribeResult" , unsubscribeMessagesObjArray);
//        }
//        resultArray.put(unsubscribeMessagesObj);
//        rs.close();

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
        while (rs.next()) {
            JsonObject json = new JsonObject();

            attrID = rs.getString(1);
            attrName = rs.getString(2);
            b = rs.getBytes(3);
            attrDisplayName = (b==null)?"":new String(b,"UTF-8");
            if (firstPers.length() == 0) firstPers = attrName;
            htmlPersonals += "<option value=\""+attrName+"\">"+attrDisplayName+"</option>\n";

            //Scan the contents for Personalization
            String allConts = contText + contHTML + contAOL;
            if (allConts != null && allConts.length() != 0) {
                i = allConts.indexOf("!*"+attrName+";");
                if (i != -1) {
                    tmp = allConts.substring(i);
                    j = tmp.indexOf("*!");
                    if (j != -1) {
                        defaultValue = tmp.substring(3+attrName.length(),j);
                        htmlCurPers += "<tr><td>"+attrDisplayName+"</td>\n" +
                                "<td><input type=text name=curDefault"+attrID+" value=\""+defaultValue+"\">\n";
//									   "<img src=\"../../images/updateandscan.gif\" style=\"cursor:hand\" onclick=\"scanContentForPers("+attrID+")\"></td></tr>\n";
                        jsPersonals += "if (attrID == "+attrID+") {\n" +
                                "	newDefault = FT.curDefault"+attrID+".value;\n" +
                                "	attrName = '"+attrName+"';\n}\n";
                        jsSubmitPers += "scanContentForPers("+attrID+");\n";
                    }
                }
            }

            json.put("attrID" , attrID);
            json.put("attrName" , attrName);
            json.put("attrDisplayName" , attrDisplayName);
            json.put("htmlPersonals" , htmlPersonals);
            json.put("htmlCurPers" , htmlCurPers);
            json.put("jsPersonals" , jsPersonals);
            json.put("jsSubmitPers" , jsSubmitPers);

            attrObjArray.put(json);
        }
       resultObj.put("attr" , attrObjArray);
        rs.close();

        if (htmlCurPers.length() == 0) htmlCurPers = "<tr><td colspan=2>None</td></tr>\n";

//        //Logic Blocks
//        String logicBlockID, logicBlockName;
//        if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) ) {
//            sSql =
//                    " SELECT cont_id, cont_name" +
//                            " FROM ccnt_content " +
//                            " WHERE cust_id = " + cust.s_cust_id +
//                            " AND type_id = 25 " +
//                            " AND status_id = 20 " +
//                            " AND origin_cont_id IS NULL " +
//                            " ORDER BY cont_name";
//
//        }
//        else {
//            sSql =
//                    " SELECT cont_id, cont_name" +
//                            " FROM ccnt_content b, ccps_object_category oc " +
//                            " WHERE b.cust_id = " + cust.s_cust_id +
//                            " AND b.type_id = 25 " +
//                            " AND b.status_id = 20 " +
//                            " AND b.cont_id = oc.object_id" +
//                            " AND origin_cont_id IS NULL " +
//                            " AND oc.type_id = " + ObjectType.CONTENT +
//                            " AND oc.cust_id = " + cust.s_cust_id +
//                            " AND oc.category_id = " + sSelectedCategoryId +
//                            " ORDER BY cont_name";
//        }
//
//        rs = stmt.executeQuery(sSql);
//        while (rs.next()) {
//            JsonObject json = new JsonObject();
//            logicBlockID = rs.getString(1);
//            b = rs.getBytes(2);
//            logicBlockName = (b==null)?"":new String(b,"UTF-8");
//
//            if (firstBlock.length() == 0) firstBlock = logicBlockName+";"+logicBlockID;
//            htmlLogicBlocks += "<option value="+logicBlockID+">"+logicBlockName+"</option>\n";
//
//            json.put("logicBlockID" , logicBlockID);
//            json.put("logicBlockName" , logicBlockName);
//            json.put("htmlLogicBlocks" , htmlLogicBlocks);
//
//            logicBlocksObjArray.put(json);
//            logicBlocksObj.put("logicBlocksResult" , logicBlocksObjArray);
//        }
//
//        resultArray.put(logicBlocksObj);
        rs.close();

        //Statuses
        String tmpStatusID = "";
        sSql =
                " SELECT status_id, status_name" +
                        " FROM ccnt_cont_status" +
                        " WHERE UPPER(status_name) <> 'DELETED' " +
                        " AND UPPER(status_name) NOT LIKE '%PENDING%' ";
        rs = stmt.executeQuery(sSql);
        while (rs.next()) {
            JsonObject json = new JsonObject();
            tmpStatusID = rs.getString(1);
            if (contStatus.equals(tmpStatusID))
                htmlStatuses += "<option selected value="+tmpStatusID+">"+rs.getString(2)+"</option>\n";
            else
                htmlStatuses += "<option value="+tmpStatusID+">"+rs.getString(2)+"</option>\n";

            json.put("tmpStatusID" , tmpStatusID);
            json.put("htmlStatuses" , htmlStatuses);
            statusesObjArray.put(json);
        }
        resultObj.put("statuses" ,statusesObjArray);
        rs.close();

        //Charsets
        String tmpCharsetID = "";
        rs = stmt.executeQuery("SELECT charset_id, display_name FROM ccnt_charset");
        while (rs.next()) {
            JsonObject json = new JsonObject();
            tmpCharsetID = rs.getString(1);
            if (sendType.equals(tmpCharsetID))
                htmlCharsets += "<option selected value="+tmpCharsetID+">"+rs.getString(2)+"</option>\n";
            else
                htmlCharsets += "<option value="+tmpCharsetID+">"+rs.getString(2)+"</option>\n";

            json.put("tmpCharsetID" , tmpCharsetID);
            json.put("htmlCharsets" , htmlCharsets);

            charsetsObjArray.put(json);
        }
        
        resultObj.put("charset" , charsetsObjArray);
        rs.close();

//        htmlCategories =
//                CategortiesControl.toHtmlOptions(cust.s_cust_id, ObjectType.CONTENT, contID, sSelectedCategoryId);
//
//        resultObj.put("htmlCategories" , htmlCategories);

    }
    catch(Exception ex) {
        resultObj.put("Error -> " ,ex);
        throw ex;
    }
    finally {
        out.println(resultObj.toString());
        if (stmt != null) stmt.close();
        if (conn != null) cp.free(conn);
    }

%>



<%!

    private String getLogicBlockListHtml(String sContId) throws Exception
    {
        ContBody cb = new ContBody(sContId);
        String sText = cb.s_text_part + cb.s_html_part + cb.s_aol_part;
        Vector vLogicBlockIds = ContUtil.getLogicBlockIds(sText);

        String htmlCurBlocks = "";

        String sLogicBlockId = null;
        Content cont = new Content();
        for (Enumeration e = vLogicBlockIds.elements() ; e.hasMoreElements() ;)
        {
            sLogicBlockId = (String) e.nextElement();
            cont.s_cont_id = sLogicBlockId;
            if(cont.retrieve()< 1) continue;

            htmlCurBlocks +=
                    "<tr><td colspan=4>" +
                            "<a href=\"#\" onClick=\"SubmitLogic('6','" + cont.s_cont_id + "')\">" + cont.s_cont_name + "</a>" +
                            "</td></tr>\n";
        }
        if (htmlCurBlocks.equals("")) htmlCurBlocks = "<tr><td colspan=4>None</td></tr>\n";

        return htmlCurBlocks;
    }
%>

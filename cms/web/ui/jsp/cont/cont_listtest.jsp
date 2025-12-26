<%@ page
        language="java"
        import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.cnt.*,
			com.britemoon.cps.ctl.*,
			java.net.*,java.sql.*,
			java.util.*,java.io.*,
			org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<script>window.contHTMLList = {};</script>
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

    String custId=user.s_cust_id;

    AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);
    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    boolean canDynCont = ui.getFeatureAccess(Feature.DYNAMIC_CONTENT);
    boolean isPrintEnabled = ui.getFeatureAccess(Feature.PRINT_ENABLED);

    String sSelectedCategoryId = request.getParameter("category_id");
    if ((sSelectedCategoryId == null) && ((custId).equals(custId)))
        sSelectedCategoryId = ui.s_category_id;

    // === === ===

    String scurPage = request.getParameter("curPage");

    int	curPage	= 1;
    int contCount = 0;

    curPage	= (scurPage	== null) ? 1 : Integer.parseInt(scurPage);

    // ********** KU

    String samount = request.getParameter("amount");
    int amount = 0;

    if (samount == null) samount = ui.getSessionProperty("cont_list_page_size");
    if ((samount == null)||("".equals(samount))) samount = "25";
    try { amount = Integer.parseInt(samount); }
    catch (Exception ex) { samount = "25"; amount = 25; }
    ui.setSessionProperty("cont_list_page_size", samount);


    JsonObject  data = new JsonObject();
    JsonArray dataArray = new JsonArray();
    JsonArray allData = new JsonArray();

    // ********** KU

    String strStatusId = null;
    String htmlFirstBox = "";
    String htmlContentRow = "";
    String htmlContentChild = "";
    String htmlContent = "";
    String htmlContentDT = "";

    // === === ===

    ConnectionPool cp	= null;
    Connection 	conn	= null;
    Statement 	stmt	= null;
    ResultSet 	rs		= null;
    Connection 	conn2	= null;
    Statement 	stmt2	= null;
    ResultSet 	rs2		= null;
    Connection 	conn3	= null;
    Statement 	stmt3	= null;
    ResultSet 	rs3		= null;

    try
    {

        cp = ConnectionPool.getInstance();
        conn = cp.getConnection("cont_list");
        stmt = conn.createStatement();
        conn2 = cp.getConnection("cont_list 2");
        stmt2 = conn2.createStatement();
        conn3 = cp.getConnection("cont_list 3");
        stmt3 = conn3.createStatement();

        // === === ===

        String sClassAppend = "";

        String sOldContID = "0";
        String sNewContID = "0";

        String sOldLogicID = "0";
        String sNewLogicID = "0";

        String sOldBlockID = "0";
        String sNewBlockID = "0";

        int blockCount = 0;

        String contID = null;
        String wizardString = null;
        String contName = null;
        String wizardID = null;
        int typeID;
        String typeName = null;
        String modifyDateTxt = null;
        int statusID;
        String statusName = null;
        String userName = null;
        String modifyDate = null;

        // === === ===

        String sSql =
                " Exec dbo.usp_ccnt_list_get" +
                        " @type_id=" + ContType.CONTENT +
                        ", @CustomerId="+custId;

        strStatusId = request.getParameter("status_id");
        if(strStatusId==null) strStatusId = "0"; /* Status default */
        if(!strStatusId.equals("0")) sSql += ",@StatusId=" + strStatusId;
        if (sSelectedCategoryId != null) sSql += ",@category_id="+sSelectedCategoryId;

        rs = stmt.executeQuery(sSql);
        while (rs.next())
        {

            if (contCount % 2 != 0) sClassAppend = "_other";
            else sClassAppend = "";

            ++contCount;

            htmlContentChild = "";

            //Page logic
            if (contCount <= (curPage-1)*amount) continue;
            else if (contCount > curPage*amount) continue;

            data = new JsonObject();
            allData = new JsonArray();

            contID = rs.getString(1);
            contName = new String(rs.getBytes(2),"UTF-8");
            wizardID = rs.getString(3);
            typeID = rs.getInt(4);
            typeName = rs.getString(5);
            modifyDateTxt = rs.getString(6);
            statusID = rs.getInt(7);
            statusName = rs.getString(8);
            userName = rs.getString(9);
            modifyDate = rs.getString(10);

            data.put("contID",contID);
            data.put("contName",contName);
            data.put("wizardID",wizardID);
            data.put("typeID",typeID);
            data.put("typeName",typeName);
            data.put("modifyDateTxt",modifyDateTxt);
            data.put("statusID",statusID);
            data.put("statusName",statusName);
            data.put("userName",userName);
            data.put("modifyDate",modifyDate);


            dataArray.put(data);

            // === === ===

            ContBody cb = new ContBody(contID);

            String sText = cb.s_text_part + cb.s_html_part + cb.s_aol_part;

            sText = ContUtil.replaceScrapeBlockIds(sText);

            Vector vLogicBlockIds = ContUtil.getLogicBlockIds(sText);
            String sLogicBlockId = null;

            for (Enumeration e = vLogicBlockIds.elements() ; e.hasMoreElements() ;)
            {
                 data = new JsonObject();

                sLogicBlockId = (String) e.nextElement();

                sSql =
                        " SELECT c.cont_id, c.cont_name," +
                                " Convert(Varchar, ce.modify_date,100) as 'ModifyDate', cs.status_name " +
                                " FROM ccnt_content c, ccnt_cont_edit_info ce, ccnt_cont_status cs " +
                                " WHERE c.cont_id = " + sLogicBlockId +
                                " AND c.type_id = " + ContType.LOGIC_BLOCK +
                                " AND c.cont_id = ce.cont_id " +
                                " AND c.status_id = cs.status_id ";
                rs2 = stmt2.executeQuery(sSql);

                if (!rs2.next())
                {
                    rs2.close();
                    continue;
                }


                String logicID = rs2.getString(1);
                data.put("logicID",logicID);

                if (!canDynCont)
                {
                    htmlContentChild +=
                            "<td class=\"listGroupChild_Title\">"+
                                    new String(rs2.getBytes(2),"UTF-8")+
                                    "</td>\n";
                    data.put("contName",new String(rs2.getBytes(2),"UTF-8"));

                }
                else
                {
                    String sUrl =
                            "cont/logic_block_edit.jsp?logic_id=" + logicID +
                                    ((sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:"");
                    sUrl = URLEncoder.encode(sUrl, "UTF-8");
                    data.put("sUrl",sUrl );
                    data.put("sClassAppend",sClassAppend);
                    data.put("contName",  new String(rs2.getBytes(2),"UTF-8"));



                }

                data.put("modifyDate",rs2.getString(3));
                data.put("statusName", rs2.getString(4));

                dataArray.put(data);
                rs2.close();

                // === === ===

                sSql =
                        " SELECT c.cont_id, c.cont_name," +
                                " Convert(Varchar, ce.modify_date,100) as 'ModifyDate', cs.status_name " +
                                " FROM ccnt_cont_part p, ccnt_content c, " +
                                " ccnt_cont_edit_info ce, ccnt_cont_status cs " +
                                " WHERE p.parent_cont_id = " + logicID +
                                " AND p.child_cont_id = c.cont_id " +
                                " AND c.type_id = " + ContType.PARAGRAPH +
                                " AND c.cont_id = ce.cont_id " +
                                " AND c.status_id = cs.status_id " +
                                " ORDER BY p.seq";

                rs3 = stmt3.executeQuery(sSql);
                blockCount = 0;

                while (rs3.next())
                {
                     data = new JsonObject();
                    if (blockCount % 2 != 0) sClassAppend = "other";
                    else sClassAppend = "";

                    ++blockCount;

                    String blockID = rs3.getString(1);
                    data.put("blockID",blockID);


                   data.put("sClassAppend",sClassAppend);

                    if (!canDynCont)
                    {
                        data.put("contName",new String(rs3.getBytes(2),"UTF-8"));

                    }
                    else
                    {
                        data.put("sClassAppend",sClassAppend);
                        data.put("sSelectedCategoryId",sSelectedCategoryId);
                        data.put("contName",new String(rs3.getBytes(2)));


                    }


                    data.put("modifyDate",rs3.getString(3));
                    data.put("statusName",rs3.getString(4));

                    dataArray.put(data);
                }
            }

            if ((contCount - 1) % 2 != 0) sClassAppend = "_other";
            else sClassAppend = "";

            boolean isTemplate = false;

            if (wizardID == null)
            {
                isTemplate = false;
            }
            else
            {
                isTemplate = true;
            }

            if (htmlContentChild.equals(""))
            {
                if (isTemplate) typeName = "Email Template";
                htmlContentRow += "<td class=\"list_row" + sClassAppend + "\">&nbsp;</td>\n";
            }
            else
            {

            }


            dataArray.put(data);

            allData.put(dataArray);
        }

    }
    catch(Exception ex) { throw ex; }
    finally
    {
        try
        {
            if (stmt3!=null) stmt3.close();
            if (stmt2!=null) stmt2.close();
            if (stmt!=null) stmt.close();
        }
        catch (SQLException ignore) { }

        if (conn3!=null) cp.free(conn3);
        if (conn2!=null) cp.free(conn2);
        if (conn!=null) cp.free(conn);
    }

    out.print(allData.toString());

    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.setHeader("Access-Control-Allow-Origin", "*");
%>

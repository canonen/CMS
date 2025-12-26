<%@ page
        language="java"
        import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.cnt.*,
		java.sql.*,java.io.*,
		org.xml.sax.*,
		javax.xml.transform.*,
		javax.xml.transform.stream.*,
		org.apache.log4j.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
    if(logger == null)
    {
        logger = Logger.getLogger(this.getClass().getName());
    }
    AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);

    if(!can.bWrite)
    {
        response.sendRedirect("../access_denied.jsp");
        return;
    }

    final int SAVE_NEXT=0, SAVE=1, SAVE_AS_NEW=2, SAVE_RETURN=3, SAVE_TO_DEST=4;

    String userID = user.s_user_id;
    String custID = cust.s_cust_id;

    ConnectionPool cp	= null;
    Connection conn		= null;
    Statement stmt		= null;
    ResultSet rs		= null;
    PreparedStatement pstmt = null;

    int iActionSave=-1;
    String contentID = BriteRequest.getParameter(request, "contentID");
//KO - can't use BriteRequest here, should not trim content.
    String sTmp = request.getParameter("ContentHTML");
    String strHTML = ((sTmp!=null) && (sTmp.trim().length()>0))?new String(sTmp.getBytes("ISO-8859-1"), "UTF-8"):null;
    sTmp = request.getParameter("ContentText");
    String strText = ((sTmp!=null) && (sTmp.trim().length()>0))?new String(sTmp.getBytes("ISO-8859-1"), "UTF-8"):null;
    sTmp = request.getParameter("ContentAOL");
    String strAOL = ((sTmp!=null) && (sTmp.trim().length()>0))?new String(sTmp.getBytes("ISO-8859-1"), "UTF-8"):null;

    String logicID = BriteRequest.getParameter(request, "logicID");
    String parentContID = BriteRequest.getParameter(request, "parentContID");

    String sUIName = BriteRequest.getParameter(request, "ui_name");
    sUIName = ((sUIName != null)?sUIName:"");

    String sSelectedCategoryId = BriteRequest.getParameter(request, "category_id");

    try
    {
        if (BriteRequest.getParameter(request, "ActionSave")!=null)
            iActionSave=new Integer(BriteRequest.getParameter(request, "ActionSave")).intValue();

        if ((iActionSave!=SAVE_TO_DEST)&&(iActionSave!=SAVE_NEXT)&&(iActionSave!=SAVE)&&(iActionSave!=SAVE_AS_NEW)&&(iActionSave!=SAVE_RETURN))
            throw new Exception ("Incorrect Action Code:"+BriteRequest.getParameter(request, "ActionSave"));

        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        conn.setAutoCommit(false);
        stmt = conn.createStatement();

        String strContentName = BriteRequest.getParameter(request, "ContentName");
        String strStatus = BriteRequest.getParameter(request, "Statuses");
        String strSendType = BriteRequest.getParameter(request, "SendTypes");

        String cloneContentID = null;

        if (iActionSave==SAVE_AS_NEW || iActionSave==SAVE_TO_DEST) {
            strStatus = "10";  //Set content to Draft during Cloning
            cloneContentID = contentID;
            contentID = null;
        }

        if (iActionSave==SAVE_TO_DEST)
            custID = ui.getDestinationCustomer().s_cust_id;


        try
        {
            boolean newContent = (contentID == null || contentID.equals("null"));

            String strSQL = "Exec usp_ccnt_modify";
            strSQL += "  @cont_id=" + contentID;
            if (newContent) strSQL += ", @new_cont=1";
            strSQL += ", @type_id=30";
            strSQL += ", @cust_id=" + custID;
            strSQL += ", @status_id=" + strStatus;
            strSQL += ", @cont_name=?";
            strSQL += ", @charset_id=" + strSendType;
            strSQL += ", @unsub_msg_id=null";
            strSQL += ", @unsub_msg_position=null";
            strSQL += ", @send_text_flag="+(strText==null?"0":"1");
            strSQL += ", @send_html_flag="+(strHTML==null?"0":"1");
            strSQL += ", @send_aol_flag="+(strAOL==null?"0":"1");
            strSQL += ", @user_id=" + userID;

            pstmt = conn.prepareStatement(strSQL);
            pstmt.setBytes(1, strContentName.getBytes("ISO-8859-1"));
            rs = pstmt.executeQuery();

            if (!rs.next()) {
                rs.close();
                throw new Exception ("Could not save general content information!");
            }

            contentID = rs.getString(1);
            rs.close();

            // === === ===

            ContBody cb = new ContBody();

            cb.s_cont_id = contentID;
            cb.s_html_part = strHTML;
            cb.s_text_part = strText;
            cb.s_aol_part = strAOL;

            cb.save(conn);

            // --- Categories ---

            if (iActionSave != SAVE_TO_DEST) {
                String sSql = "";
                if (!newContent) {
                    sSql = " DELETE FROM ccps_object_category" +
                            " WHERE cust_id=?" +
                            " AND object_id=?" +
                            " AND type_id=?";

                    pstmt = conn.prepareStatement(sSql);
                    pstmt.setString(1, custID);
                    pstmt.setString(2, contentID);
                    pstmt.setString(3, String.valueOf(ObjectType.CONTENT));
                    pstmt.executeUpdate();
                }

                String[] sCategories = request.getParameterValues("categories");
                int l = ( sCategories == null )?0:sCategories.length;

                if ( l > 0) {
                    sSql =
                            " INSERT ccps_object_category (cust_id,  object_id, type_id, category_id)" +
                                    " VALUES (?, ?, ?, ?)";

                    for(int i=0; i<l ;i++)
                    {
                        pstmt = conn.prepareStatement(sSql);
                        pstmt.setString(1, custID);
                        pstmt.setString(2, contentID);
                        pstmt.setString(3, String.valueOf(ObjectType.CONTENT));
                        pstmt.setString(4, sCategories[i]);
                        pstmt.executeUpdate();
                    }
                }
            }
            conn.commit();
        }
        catch (Exception e) {
            conn.rollback();
            throw e;
        }

        JsonObject resp = new JsonObject();
        String sendRedirectUrl = "";


        if (iActionSave == SAVE_RETURN) {
            sendRedirectUrl = "cont_block_edit.jsp?cont_id="+contentID;
        } else if (iActionSave == SAVE_NEXT) {
            sendRedirectUrl = "cont_block_edit.jsp";
        } else {

            String actionLabel = (iActionSave==SAVE_AS_NEW) ? "cloned" : "saved";

            String backToList = "cont_block_list.jsp" + (sSelectedCategoryId!=null ? ("?category_id=" + sSelectedCategoryId) : "");

            String backToEdit = null;
            if (iActionSave != SAVE_TO_DEST) {
                StringBuilder sb = new StringBuilder("cont_block_edit.jsp?cont_id=").append(contentID);
                if (sSelectedCategoryId != null) sb.append("&category_id=").append(sSelectedCategoryId);
                backToEdit = sb.toString();
            }

            String backToLogicBlockEdit = null;
            if ((iActionSave != SAVE_TO_DEST) && (logicID != null)) {
                StringBuilder sb = new StringBuilder("logic_block_edit.jsp?logic_id=").append(logicID);
                if (parentContID != null) sb.append("&parent_cont_id=").append(parentContID);
                if (sSelectedCategoryId != null) sb.append("&category_id=").append(sSelectedCategoryId);
                backToLogicBlockEdit = sb.toString();
            }

            String backToContent = null;
            if ((iActionSave != SAVE_TO_DEST) && (parentContID != null)) {
                StringBuilder sb = new StringBuilder("cont_edit.jsp?cont_id=").append(parentContID);
                if (sSelectedCategoryId != null) sb.append("&category_id=").append(sSelectedCategoryId);
                backToContent = sb.toString();
            }

            sendRedirectUrl = backToList;

            resp.put("message", "The content element was " + actionLabel + ".");
            resp.put("backToList", backToList);
            if (backToEdit != null) resp.put("backToEdit", backToEdit);
            if (backToLogicBlockEdit != null) resp.put("backToLogicBlockEdit", backToLogicBlockEdit);
            if (backToContent != null) resp.put("backToContent", backToContent);
            resp.put("contentId", contentID == null ? "" : contentID);
        }

        resp.put("sendRedirectUrl", sendRedirectUrl);
        resp.put("statusCode", "200");
        response.setContentType("application/json;charset=UTF-8");
        out.print(resp.toString());

    }
    catch(Exception ex) {
        ErrLog.put(this,ex,"cont_block_save_api.jsp",out,1);
    }
    finally {
        if (stmt!=null) stmt.close();
        if (conn!=null) {
            conn.setAutoCommit(true);
            cp.free(conn);
        }
    }
%>

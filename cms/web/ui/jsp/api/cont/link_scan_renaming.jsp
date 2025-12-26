<%@ page
        language="java"
        import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.cnt.*,
		java.util.*,
		java.sql.*,java.io.*,
		org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
        errorPage="../error_page.jsp"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%! static Logger logger = null;%>
<%
        if(logger == null)
        {
            logger = Logger.getLogger(this.getClass().getName());
        }
        AccessPermission can = user.getAccessPermission(ObjectType.CONTENT);
        JsonObject data = new JsonObject();
        JsonArray array = new JsonArray();

        if(!can.bWrite)
        {
            response.sendRedirect("../access_denied.jsp");
            return;
        }

        String contID = request.getParameter("cont_id");
        if (contID == null)
        {
            response.sendRedirect("cont_list.jsp");
            return;
        }

        String sUseAnchorName = request.getParameter("use_anchor_name");
        String sUseLinkRenaming = request.getParameter("use_link_renaming");
        String sReplaceScannedLinks = request.getParameter("replace_scanned_links");
        boolean useAnchorName = false;
        boolean useLinkRenaming = false;
        boolean replaceScannedLinks = false;
        if (sUseAnchorName != null && sUseAnchorName.equals("1")) {
            logger.info("Using anchor name");
            useAnchorName = true;
        }
        if (sUseLinkRenaming != null && sUseLinkRenaming.equals("1")) {
            logger.info("Using link renaming");
            useLinkRenaming = true;
        }
        if (sReplaceScannedLinks != null && sReplaceScannedLinks.equals("1")) {
            logger.info("Replace scanned links");
            replaceScannedLinks = true;
        }

    Content cont = new Content();
    cont.s_cont_id = contID;
    if(cont.retrieve() < 1)
        throw new Exception("Invalid content. Content does not exist.");

    ContBody cont_body = new ContBody(contID);

    // === === ===

    String contName = cont.s_cont_name;

    String tmpTextPart = cont_body.s_text_part;
    String tmpHtmlPart = cont_body.s_html_part;
    String tmpAolPart = cont_body.s_aol_part;

    if(tmpTextPart == null) tmpTextPart = "";
    if(tmpHtmlPart == null) tmpHtmlPart = "";
    if(tmpAolPart == null) tmpAolPart = "";

    String htmlLinks = "", jsLinks = "";
    String missingImages = "";
    int linkCount = 0;

    ConnectionPool cp	= null;
    Connection conn		= null;
    Statement stmt		= null;

    try {
        cp = ConnectionPool.getInstance();
        conn = cp.getConnection(this);
        stmt = conn.createStatement();
        Hashtable hExactLinks = new Hashtable();
        String sSql=" SELECT lower(link_definition), link_name " +
                "   FROM ccnt_link_renaming " +
                "  WHERE link_type_id = 1"+
                "    AND cust_id = "+cust.s_cust_id;
        rs = stmt.executeQuery(sSql);
        //Need to create a hashtable of all current links in order to prefill with names
        while (rs.next()) {
            data.put("contID",contID);
            data.put("sUseAnchorName",sUseAnchorName);
            data.put("sUseLinkRenaming",sUseLinkRenaming);
            data.put("sReplaceScannedLinks",sReplaceScannedLinks);
            data.put("linkCount",linkCount);
            data.put("contName",contName);
            hExactLinks.put(rs.getString(1), new String (rs.getBytes(2),"UTF-8")? "":"");
            array.put(data);

            //array.put(data);
        }
        //out.print(array);
        rs.close();
        LinkedHashMap hPartialLinks = new LinkedHashMap();

        sSql =
                " SELECT lower(link_definition), link_name " + 
                        "   FROM ccnt_link_renaming " +
                        "  WHERE link_type_id = 2"+
                        "    AND cust_id = "+cust.s_cust_id+
                        "  ORDER BY len(link_definition) DESC";

        rs = stmt.executeQuery(sSql);
        while (rs.next()){
            data.put("contID",contID);
            data.put("sUseAnchorName",sUseAnchorName);
            data.put("sUseLinkRenaming",sUseLinkRenaming);
            data.put("sReplaceScannedLinks",sReplaceScannedLinks);
            data.put("sReplaceScannedLinks",sReplaceScannedLinks);
            data.put("linkCount",linkCount);
            data.put("contName",contName);

            hPartialLinks.put(rs.getString(1), new String (rs.getBytes(2),"UTF-8")? "":"");

            array.put(data);
        }
        rs.close();

    }
    catch (Exception ex) {
        throw ex;
    }
    finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) cp.freeConnection(this, conn);
    }
%>

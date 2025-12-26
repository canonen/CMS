<%@ page
        language="java"
        import="org.apache.log4j.*"
        import="com.britemoon.cps.*"
        import="com.britemoon.cps.ctm.*"
        import="java.util.*"
        errorPage="../error_page.jsp"
        contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<% if (logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ include file="../header.jsp" %>
<%@ include file="../validator.jsp" %>
<jsp:useBean id="tbeans" class="java.util.Hashtable" scope="application"/>
<%
	JsonObject jsonObject = new JsonObject();
	JsonArray jsonArray = new JsonArray();
    session.removeAttribute("pbean");
    session.removeAttribute("tbean");
    StringBuilder TABLE_TR = new StringBuilder();

    String isHyatt = (String) session.getAttribute("isHyatt");
    if (isHyatt == null || isHyatt.length() == 0) isHyatt = "0";

    int numPerPage = 6;
    String sNumPerPage = application.getInitParameter("NumTemplatesPerPage");
    if (sNumPerPage != null) numPerPage = Integer.parseInt(sNumPerPage);

    String isWizard = (String) session.getAttribute("isWizard");
    if ("1".equals(isWizard)) {
        numPerPage = 100;
    }

    String sCurPage = request.getParameter("page");
    int curPage, nextPage, prevPage;
    if (sCurPage == null) {
        curPage = 1;
        nextPage = 2;
        prevPage = 0;
    } else {
        curPage = Integer.parseInt(sCurPage);
        nextPage = curPage + 1;
        prevPage = curPage - 1;
    }

    int custID = Integer.parseInt(cust.s_cust_id);

    TemplateBean tbean;

//No next page if there aren't any more to show
    int actualNumTemplates = 0;
    for (Enumeration tb = tbeans.elements(); tb.hasMoreElements(); ) {
        tbean = (TemplateBean) tb.nextElement();
        if (!tbean.isActive()) continue;
        boolean ok = false;
        if (isHyatt.equals("1")) {
            // this is fine because hyatt is in its own CPS otherwise make sure cust's parent cust id = template's cust id
            ok = (tbean.isGlobal() && (tbean.getCustID() != 0));
        } else {
            ok = (tbean.getCustID() == 0);
        }
        if (ok || tbean.getCustID() == custID || tbean.inChildCustList(custID + "")) ++actualNumTemplates;
    }

    if (curPage * numPerPage >= actualNumTemplates) nextPage = 0;

    Vector vKeys = new Vector();
    Enumeration keys = tbeans.keys();

    while (keys.hasMoreElements()) vKeys.add(keys.nextElement());

    Collections.sort(vKeys);
    Iterator sortedKeys = vKeys.iterator();

    int rowCount = 0, count = 0;
    boolean hasOneRow = false;

    int iCount = 0;
    String sClassAppend = "_Alt";

// skip the ones displayed in previous pages
    int numToSkip = curPage * numPerPage - numPerPage;
    while (numToSkip > 0) {
        if (!sortedKeys.hasNext()) break;
        Integer key = (Integer) sortedKeys.next();
        tbean = (TemplateBean) tbeans.get(key);

        if (!tbean.isActive()) continue;
        boolean ok = false;
        if (isHyatt.equals("1")) {
            ok = (tbean.isGlobal() && (tbean.getCustID() != 0)); // this is fine because hyatt is in its own CPS otherwise make sure cust's parent cust id = template's cust id
        } else {
            ok = (tbean.getCustID() == 0);
        }

        if (tbean.isActive() && (ok || tbean.getCustID() == custID || tbean.inChildCustList(custID + ""))) {
            numToSkip--;
        }
    }

// display the next page
    while (sortedKeys.hasNext() && count < numPerPage) {
        Integer key = (Integer) sortedKeys.next();
        tbean = (TemplateBean) tbeans.get(key);
        boolean ok = false;
        if (isHyatt.equals("1")) {
            ok = (tbean.isGlobal() && (tbean.getCustID() != 0)); // this is fine because hyatt is in its own CPS otherwise make sure cust's parent cust id = template's cust id
        } else {
            ok = (tbean.getCustID() == 0);
        }
        if (tbean.isActive() && (ok || tbean.getCustID() == custID || tbean.inChildCustList(custID + ""))) {
            hasOneRow = true;
            ++rowCount;
            ++count;
            if (rowCount == 4) {
                rowCount = 1;
                TABLE_TR.append("</tr><tr>");

                if (iCount % 2 != 0) sClassAppend = "_Alt";
                else sClassAppend = "";

                ++iCount;
            }


            TABLE_TR.append("<td width='33%' valign='top' align='center'>");

            TABLE_TR.append("<table class='table text-center'> ");

            TABLE_TR.append("<tr>");
            TABLE_TR.append("<td valign='top'>");
            TABLE_TR.append("<a href='pageedit.jsp?templateID=" + tbean.getTemplateID() + "'>");
            TABLE_TR.append("<h4 class='temp_title'  href='pageedit.jsp?templateID=" + tbean.getTemplateID() + "'>");
            TABLE_TR.append(tbean.getTemplateName());
            TABLE_TR.append("</h4> ");
            TABLE_TR.append("</a> ");

            TABLE_TR.append("</td>");
            TABLE_TR.append("</tr> ");

            TABLE_TR.append("<tr>");
            TABLE_TR.append("<td valign='top' height='200' >");
            TABLE_TR.append("<a href='pageedit.jsp?templateID=" + tbean.getTemplateID() + "'>");
            TABLE_TR.append("<img height='190' border='0' src='/cctm/ui/images/templates/" + tbean.getImageURL(0) + "'>");
            TABLE_TR.append("</a> ");
            TABLE_TR.append("</td>");
            TABLE_TR.append("</tr> ");


            TABLE_TR.append("<tr>");
            TABLE_TR.append("<td valign='top'>");
            TABLE_TR.append("<a class='btn btn-warning' target='_blank' href='/cctm/ui/images/templates/" + tbean.getImageURL(1) + "'>Preview</a>");
            TABLE_TR.append("</td>");
            TABLE_TR.append("</tr> ");
            TABLE_TR.append("</table> ");

            TABLE_TR.append("</td>");

        }
    }

    for (int x = rowCount + 1; x < 4; ++x) {
        TABLE_TR.append("<td width='33%'></td>");

    }
        jsonObject.put("templates", TABLE_TR.toString());
    if (!hasOneRow) {
        TABLE_TR.append("<td colspan='3' >There are currently no templates to choose from.</td>");
		jsonObject.put("templates",TABLE_TR.toString());
    }
	jsonArray.put(jsonObject);
	out.println(jsonArray);
%>

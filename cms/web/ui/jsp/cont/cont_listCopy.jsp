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

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
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
    boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);
    boolean canDynCont = ui.getFeatureAccess(Feature.DYNAMIC_CONTENT);
    boolean isPrintEnabled = ui.getFeatureAccess(Feature.PRINT_ENABLED);

    String sSelectedCategoryId = request.getParameter("category_id");
    if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
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
                        ", @CustomerId="+cust.s_cust_id;

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

            htmlFirstBox = "<td class=\"list_row" + sClassAppend + "\"><a href=\"javascript:goToEdit('" + contID + "', '" + typeID + "')\">" + contName + "</a></td>\n";

            // === === ===

            ContBody cb = new ContBody(contID);
            String sText = cb.s_text_part + cb.s_html_part + cb.s_aol_part;
            sText = ContUtil.replaceScrapeBlockIds(sText);
            Vector vLogicBlockIds = ContUtil.getLogicBlockIds(sText);
            String sLogicBlockId = null;

            for (Enumeration e = vLogicBlockIds.elements() ; e.hasMoreElements() ;)
            {
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

                htmlContentChild += "<tr>\n";
                htmlContentChild += "<td class=\"listGroup_Data\">&nbsp;</td>\n";

                if (!canDynCont)
                {
                    htmlContentChild +=
                            "<td class=\"listGroupChild_Title\">"+
                                    new String(rs2.getBytes(2),"UTF-8")+
                                    "</td>\n";
                }
                else
                {
                    String sUrl =
                            "cont/logic_block_edit.jsp?logic_id=" + logicID +
                                    ((sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:"");
                    sUrl = URLEncoder.encode(sUrl, "UTF-8");

                    htmlContentChild += "<td class=\"listGroupChild_Data" + sClassAppend + "\"></td>\n";
                    htmlContentChild +=
                            "<td class=\"listGroupChild_Title\">" +
                                    "<a target=\"_top\" href=\"../index.jsp?tab=Cont&sec=2&url=" + sUrl +"\">"+
                                    new String(rs2.getBytes(2),"UTF-8")+
                                    "</a></td>\n";
                }

                htmlContentChild += "<td class=\"listGroupChild_Data\">Logic Block</td>\n";
                htmlContentChild += "<td class=\"listGroupChild_Data\" nowrap>"+rs2.getString(3)+"</td>\n";
                htmlContentChild += "<td class=\"listGroupChild_Data\" nowrap>"+rs2.getString(4)+"</td>\n";
                htmlContentChild += "</tr>\n";

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
                    if (blockCount % 2 != 0) sClassAppend = "other";
                    else sClassAppend = "";

                    ++blockCount;

                    String blockID = rs3.getString(1);

                    htmlContentChild += "<tr>\n";
                    htmlContentChild += "<td class=\"list_row" + sClassAppend + "\">&nbsp;</td>\n";

                    if (!canDynCont)
                    {
                        htmlContentChild += "<td class=\"list_row" + sClassAppend + "\">"+new String(rs3.getBytes(2),"UTF-8")+"</td>\n";
                    }
                    else
                    {
                        htmlContentChild += "<td class=\"list_row" + sClassAppend + "\"></td>\n";
                        htmlContentChild +=
                                "<td class=\"list_row" + sClassAppend + "\">" +
                                        "<a target=\"_top\" href=\"../index.jsp?tab=Cont&sec=2&url=" +
                                        URLEncoder.encode("cont/cont_block_edit.jsp?cont_id=" + blockID +
                                                ((sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""),"UTF-8")+
                                        "\">" + new String(rs3.getBytes(2),"UTF-8")+"</a></td>\n";
                    }
                    htmlContentChild += "<td class=\"list_row" + sClassAppend + "\">Content Element</td>\n";
                    htmlContentChild += "<td class=\"list_row" + sClassAppend + "\" nowrap>"+rs3.getString(3)+"</td>\n";
                    htmlContentChild += "<td class=\"list_row" + sClassAppend + "\" nowrap>"+rs3.getString(4)+"</td>\n";
                    htmlContentChild += "</tr>\n";
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
                typeName = typeName + " (Dynamic)";
                if (isTemplate) typeName = "Email Template (Dynamic)";
                htmlContentRow += "<td class=\"list_row" + sClassAppend + "\"><a id=\"link_" + contID + "\" class=\"resourcebutton\" style=\"width:15px;text-align:center;\" href=\"javascript:showHide('" + contID + "');\">+</a></td>\n";
                htmlContentChild = "<tbody id=\"cont_" + contID + "\" style=\"display:none;\">\n" + htmlContentChild + "</tbody>\n";
            }

            htmlContentRow += htmlFirstBox;

            htmlContentRow += "<td class=\"list_row" + sClassAppend + "\">"+typeName+"</td>\n";

            htmlContentRow += "<td class=\"list_row" + sClassAppend + "\" nowrap>"+modifyDateTxt+"</td>\n";
            htmlContentRow += "<td class=\"list_row" + sClassAppend + "\" nowrap>"+statusName+"</td>\n";

            htmlContentRow += "</tr>\n";

            htmlContentRow += htmlContentChild;
            htmlContentDT += "<tr>\n";
            htmlContentDT += "<td class=\"list_row" + sClassAppend + "\"><input type=\"checkbox\" class=\"check_me\" name=\"check1\"></td>";
            htmlContentRow = htmlContentDT + htmlContentRow;
            htmlContent += htmlContentRow;
            htmlContentRow = "";
            htmlContentDT = "";
        }

        if (htmlContent.length() == 0){
            htmlContent += "<tr><td colspan=\"5\" class=\"list_row\">There is currently no Content</td></tr>\n";
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
%>

<!-----CY 12/28/2015 Language Options START ----->

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<html>

<c:set var="loc" value="en_US"/>
<c:if test="${!(empty param.locale)}">
    <c:set var="loc" value="${param.locale}"/>
</c:if>

<fmt:setLocale value="${loc}" />
<fmt:bundle basename="app">

    <!-----CY 12/28/2015 Language Options END ----->


    <head>
        <title>Content List</title>
        <%@ include file="../header.html" %>
        <link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
        <link rel="stylesheet" href="/cms/ui/css/demo_table_jui.css" TYPE="text/css">
        <link rel="stylesheet" href="/cms/ui/css/jquery-ui-1.7.2.custom.css" TYPE="text/css">
        <SCRIPT LANGUAGE="JAVASCRIPT">
            <%@ include file="../../js/scripts.js" %>
        </SCRIPT>
        <script language="JavaScript" src="/cms/ui/ooo/script.js"></script>
        <SCRIPT src="../../js/jquery.js"></SCRIPT>
        <SCRIPT src="/cms/ui/js/jquery.dataTables.min_new.js"></SCRIPT>
        <script type="text/javascript">
            $(document).ready(function() {


                $("#checkboxall").click(function()
                {
                    var checked_status = this.checked;
                    $(".check_me").each(function(){
                        this.checked = checked_status;
                    });
                });

                $('#example tbody td').hover( function() {
                    $(this).siblings().addClass('highlighted');
                    $(this).addClass('highlighted');
                }, function() {
                    $(this).siblings().removeClass('highlighted');
                    $(this).removeClass('highlighted');
                } );
                $('#example2 tbody td').hover( function() {
                    $(this).siblings().addClass('highlighted');
                    $(this).addClass('highlighted');
                }, function() {
                    $(this).siblings().removeClass('highlighted');
                    $(this).removeClass('highlighted');
                } );
               /* oTable = $('#example').dataTable( {
                    "bJQueryUI": true,
                    "sPaginationType": "full_numbers"
                } );*/
                oTable2 = $('#example2').dataTable({
                    "sDom": "tlrip",
                    "aoColumns": [null,null,null,null,null,null,null],
                    "aaSorting": [[ 0, "desc" ]]
                });

                $('#filter').change( function(){
                    filter_string = $('#filter').val();
                    oTable.fnFilter( filter_string , 4);
                    filter_string = $('#filter').val();
                    oTable2.fnFilter( filter_string , 3);
                });

            } );

        </script>
        <script language="javascript">

            function showHide(id)
            {
                if (document.getElementById("cont_" + id).style.display == "none")
                {
                    document.getElementById("cont_" + id).style.display = "";
                    document.getElementById("link_" + id).innerText = "-";
                }
                else
                {
                    document.getElementById("cont_" + id).style.display = "none";
                    document.getElementById("link_" + id).innerText = "+";
                }
            }

            function goToEdit(cont_id, type_id)
            {
                var sURL = "";

                if (type_id == <%= ContType.PRINT %>) sURL = "cont_edit_sms.jsp?<%= ((sSelectedCategoryId!=null)?"category_id="+sSelectedCategoryId+"&":"") %>cont_id=" + cont_id;
                else sURL = "cont_edit.jsp?<%= ((sSelectedCategoryId!=null)?"category_id="+sSelectedCategoryId+"&":"") %>cont_id=" + cont_id;
                //sURL = "cont_edit.jsp?<%= ((sSelectedCategoryId!=null)?"category_id="+sSelectedCategoryId+"&":"") %>cont_id=" + cont_id;

                location.href = sURL;
            }

        </script>
        <script language="JavaScript" src="/cms/ui/ooo/script.js"></script>
    </head>
    <BODY class="paging_body">

    <div class="page_header"><fmt:message key="header_content"/></div>
    <div class="page_desc"><fmt:message key="header_content_desc"/></div>
    <div id="info">
        <div id="xsnazzy">

            <div class="xboxcontent">
                <table cellpadding="3" cellspacing="0" border="0" width="95%">
                    <tr>
                        <% if (can.bWrite) { %>
                        <td noWrap align=left style="padding-left:10px; width:5%;">
                            <a class="newbutton" href="cont_edit.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>"><%= (isPrintEnabled)?"Email ":"" %><fmt:message key="button_content"/></a>&nbsp;&nbsp;&nbsp;
                        </td>
                        <% if (isPrintEnabled) { %>
                        <td noWrap align=left style="padding-left:10px; width:5%;">
                            <a class="newbutton" href="cont_edit_sms.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>">New SMS Content</a>&nbsp;&nbsp;&nbsp;
                        </td>
                        <% } %>
                        <% if (!STANDARD_UI) { %>
                        <td noWrap align=left style="padding-left:10px; width:5%;">
                            <a class="newbutton" href="cont_load_manual.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>"><fmt:message key="button_upload_content"/></a>&nbsp;&nbsp;&nbsp;
                        </td>
                        <td noWrap align=left style="padding-left:10px; width:5%;">
                            <a class="newbutton" href="cont_load_zip.jsp<%=(sSelectedCategoryId!=null)?"?category_id="+sSelectedCategoryId:""%>"><fmt:message key="button_upload_content_zip"/></a>&nbsp;&nbsp;&nbsp;
                        </td>
                        <% } %>
                        <% } %>
                        <TD noWrap align=right style="padding-right:10px;">
                            <A class="newbutton" href="cont_list.jsp"><fmt:message key="button_refresh"/></A>
                        </TD>
                    </tr>
                </table>
                <table class="listTable" id="example" width="100%" cellpadding="2" cellspacing="0">
                    <thead>
                    <tr>
                        <TH><input type="checkbox" id="checkboxall"></TH>
                        <th align="left" valign="middle" nowrap>&nbsp;</th>
                        <th align="left" valign="middle" width="40%" nowrap>&#x20;<fmt:message key="cnt_column_name"/></th>
                        <th align="left" valign="middle" width="20%" nowrap>&#x20;<fmt:message key="cnt_column_type"/></th>
                        <th align="left" valign="middle" width="20%" nowrap>&#x20;<fmt:message key="cnt_column_update"/></th>
                        <th align="left" valign="middle" width="20%" nowrap>&#x20;<fmt:message key="cnt_column_status"/></th>
                        <!--<th align="left" valign="middle" nowrap>&#x20;Action</th>//-->
                        <!--<th align="left" valign="middle" nowrap>&#x20;Modified By</th>//-->
                    </tr>
                    </thead>
                    <tbody>
                    <!-- List of the contents -->
                    <%= htmlContent %>
                    </tbody>
                </table>
            </div>

        </div>
        </td>
        </tr>
        </table>
        <br><br>
        <script language="javascript">

            <%@ include file="../../js/scripts.js" %>

            function innerFramOnLoad()
            {


                var prevPage = document.getElementById("prev_page");
                var firstPage = document.getElementById("first_page");
                var nextPage = document.getElementById("next_page");
                var lastPage = document.getElementById("last_page");

                FT.curPage.value = <%= curPage %>;
                FT.amount.value = <%= amount %>;

                <% if( curPage > 1) { %>
                prevPage.style.display = "";
                firstPage.style.display = "";
                <% } %>

                <% if( contCount > (curPage*amount) ) { %>
                nextPage.style.display = "";
                lastPage.style.display = "";
                <% } %>

                var recCount = new Number("<%= contCount %>");
                var perPage = new Number(FT.amount.value);
                var thisPage = new Number(FT.curPage.value);
                var catName = FT.category_id[FT.category_id.selectedIndex].text;

                var pageCount = new Number(Math.ceil(recCount / perPage));

                if (pageCount == 0)
                {
                    pageCount = 1;
                }
                FT.pageCount.value = pageCount;

                var startRec;
                var endRec;

                startRec = ((thisPage - 1) * perPage) + 1;
                endRec = ((thisPage - 1) * perPage) + perPage;

                if (endRec >= recCount)
                {
                    endRec = recCount;
                }

                if (perPage == 1000)
                {
                    perPage = "ALL";
                }

                if (thisPage == 1)
                {
                    firstPage.style.display = "none";
                    prevPage.style.display = "none";
                }

                if (thisPage >= pageCount)
                {
                    lastPage.style.display = "none";
                    nextPage.style.display = "none";
                }

                var finalMessage = "";

                if (recCount == 0)
                {
                    finalMessage = "0 records";
                }
                else
                {
                    finalMessage = "Page " + thisPage + " of " + pageCount + " (records " + startRec + " to " + endRec + " of " + recCount + " records)";
                }

                document.getElementById("cat_1").innerHTML = catName;
                document.getElementById("rec_1").innerHTML = perPage;
                document.getElementById("page_1").innerHTML = finalMessage;
            }

            function GO(parm)
            {

                switch( parm )
                {
                    case 0:
                        FT.curPage.value=1;
                        break;
                    case 1:
                        FT.curPage.value = <%= curPage + 1 %>;
                        break;
                    case 2:
                        break;
                    case -1:
                        FT.curPage.value = <%= curPage - 1 %>;
                        break;
                    case 99:
                        FT.curPage.value = FT.pageCount.value;
                        break;
                }

                FT.submit();
            }

        </script>
    </body>
</fmt:bundle>

</html>


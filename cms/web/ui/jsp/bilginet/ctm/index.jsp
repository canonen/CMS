<%@ page
	language="java"
	import="com.britemoon.*"
	import="com.britemoon.cps.*"
	import="com.britemoon.cps.ctm.*"
	import="org.apache.log4j.*"
	import="java.util.*"
	import="java.sql.*"
	import="java.net.*"
	import="java.text.DateFormat"
	errorPage="../../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%! static Logger logger = null; %>
<%  if(logger == null) logger = Logger.getLogger(this.getClass().getName()); %>
<%@ include file="../../header.jsp"%>
<%@ include file="../../wvalidator.jsp"%>
<jsp:useBean id="tbeans" class="java.util.Hashtable" scope="application" />
<%
//Make sure these are gone
session.removeAttribute("pbean");
session.removeAttribute("tbean");

String		scurPage	= request.getParameter("curPage");
String		samount		= request.getParameter("amount");
String		sOrderBy	= request.getParameter("sort_by");
int			curPage			= 1;
int			amount			= 0;


// date stuff start
Map<String, String> strDate = new LinkedHashMap<String, String>();
strDate.put("Jan","Ocak	");
strDate.put("Feb","Şubat");
strDate.put("Mar","Mart");
strDate.put("Apr","Nisan");
strDate.put("May","Mayıs");
strDate.put("Jun","Haziran");
strDate.put("Jul","Temmuz");
strDate.put("Aug","Ağustos");
strDate.put("Sep","Eylül");
strDate.put("Oct","Ekim");
strDate.put("Nov","Kasım");
strDate.put("Dec","Aralık");
// date stuff end

curPage		= (scurPage		== null) ? 1 : Integer.parseInt(scurPage);

if ((samount == null)||("".equals(samount))) samount = "25";
try { amount = Integer.parseInt(samount); }
catch (Exception ex) 
{ 
	samount = "25"; 
	amount = 25;
}

if ((sOrderBy == null)||("".equals(sOrderBy))) sOrderBy = "mod_date desc";

//Grab this customer's pages from the db
ConnectionPool connPool = null;
Connection conn         = null;
Statement stmt          = null;
ResultSet rs            = null;

connPool = ConnectionPool.getInstance();
conn = connPool.getConnection("index.jsp");
stmt = conn.createStatement();

rs = stmt.executeQuery("" +
	"select distinct content_id, category, p.template_id, p.name, mod_date, t.name as template_name, " +
	"status, mod_by, creation_date, user_name " +
	"from ctm_pages p with(nolock), ctm_templates t with(nolock) " +
	"where p.template_id = t.template_id " +
	"and p.customer_id = " + cust.s_cust_id + " " +
	"and status <> 'deleted' " +
	"order by " + sOrderBy);
	
String isAdmin = (String)session.getAttribute("isAdmin");
if (isAdmin == null || isAdmin.length() == 0) {
    isAdmin = "0";
}

String isHyatt = (String)session.getAttribute("isHyatt");
if (isHyatt == null || isHyatt.length() == 0) {
    isHyatt = "0";
}

String isWizard = (String)session.getAttribute("isWizard");
if (isWizard == null || isWizard.length() == 0) {
    isWizard = "0";
}

String isParent = "0";
if (isAdmin.equals("1") && isHyatt.equals("1")) {
    isParent = "1";
}

%>
<html>
<head>
	<META HTTP-EQUIV="Content-Type" CONTENT="text/html;charset=UTF-8">
	<link rel="stylesheet" href="../default.css" TYPE="text/css">
	<SCRIPT src="../jquery.js"></SCRIPT>
	<SCRIPT src="../jquery.dataTables.min.js"></SCRIPT>
</head>
<body style="margin:0;background-color:#FFFFFF">
		
		<a href="selecttemplate.jsp" class="zbuttons zbuttons-normal zbuttons-green mta5">
			<span class="zicon zicon-white zicon-new"></span>
			<span class="zlabel">Yeni İçerik Yarat</span>
		</a>
<br>
<table class="list-table dtables" width="100%" cellspacing="0" cellpadding="0">
	<thead>
	<tr>
		<th align="left" nowrap>İçerik Adı</th>
		<th align="left" nowrap>Kullanılan Şablon</th>
		<th align="left" nowrap>Güncellenme Tarihi</th>
		<% if ("0".equals(isWizard)) { %>
		<th align="left" nowrap colspan="4">Seçenekler</th>
		<% } %>
	</tr>
	</thead>
	<tbody>
<%
int templateID, contentID;
String pageName, templateName, status;
Timestamp modDate;

int iCount = 0;
String sClassAppend = null;

while (rs.next())
{
contentID = rs.getInt(1);
if (iCount % 2 != 0) {
	sClassAppend = "_Alt";
} else {
	sClassAppend = "";
}

++iCount;

templateID = rs.getInt(3);
pageName = new String(rs.getBytes(4), "UTF-8");
pageName = pageName.replace("�?","ş");
modDate = rs.getTimestamp(5);
templateName = rs.getString(6);
status = rs.getString(7);

//Page logic
if ((iCount <= (curPage-1)*amount) || (iCount > curPage*amount)) continue;

String sModifyDate = DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT).format(modDate);
String[] md = sModifyDate.split("-");
String newmd = "";
for (Map.Entry<String, String> entry : strDate.entrySet()) {
	if(md[1].equals(entry.getKey()))
		newmd = entry.getValue();
}
newmd = md[0] + " " +newmd+ " " + md[2];
String[] mdreformat = newmd.split(" ");
newmd = mdreformat[0] + " " +mdreformat[1]+ " " + mdreformat[2];
%>
<tr>
	<td class="listItem_Data<%=sClassAppend%>"><a href="pageedit.jsp?isEdit=true&contentID=<%= contentID %>&templateID=<%= templateID %>"><%= pageName %></a></td>
	<td class="listItem_Data<%=sClassAppend%>" align=left><%= templateName %></td>
	<td class="listItem_Data<%=sClassAppend%>" align=left><%=newmd%></td>
	<% if ("0".equals(isWizard)) { %>
	<td class="listItem_Data<%=sClassAppend%>" align=center><a class="resourcebutton" href="pageedit.jsp?isEdit=false&contentID=<%= contentID %>&templateID=<%= templateID %>">Preview</a></td>
	<td class="listItem_Data<%=sClassAppend%>" align=center>
	<%=(!status.equals("locked"))?("<a class=\"btn btn-danger\" href=\"\" onClick=\"if( confirm('Silmek istediğinize emin misiniz ?') ) href='pagedelete.jsp?contentID="+contentID+"'\">Sil</a>"):("")%>
	</td>
	<% if ("0".equals(isHyatt)) { %>
	<td class="listItem_Data<%=sClassAppend%>" align=center>
	<%	if (!status.equals("locked")) {
		if (status.equals("draft")) { %>
		<a class="subactionbutton" href="commit.jsp?contentID=<%= contentID %>&templateID=<%= templateID %>">Onayla</a>
	<% 	} else { %>
		<a class="subactionbutton" href="uncommit.jsp?contentID=<%= contentID %>&templateID=<%= templateID %>">Onayı Kaldır</a>
	<% 	}
		} else { %>
	&nbsp;
	<%	} %>
	</td>
	<% } %>
	<td class="listItem_Data<%=sClassAppend%>" align=center><a class="subactionbutton" href="pageedit.jsp?clone=true&contentID=<%= contentID %>&templateID=<%= templateID %>">Kopyala</a></td>
	<% } %>
</tr>
<%
}
//Free the db connection
rs.close();
stmt.close();
if (conn != null) connPool.free(conn);

if (iCount == 0)
{
%>
<tr>
	<td>Hiç bir içerik bulunmuyor.</td>
	<td></td>
	<td></td>
</tr>
<%
}
%>
</tbody>
</table>

<script type="text/javascript" charset="utf-8">
	$(document).ready(function() {
		$('.dtables').dataTable( {
			"iDisplayLength": 5,
			"sPaginationType": "two_button",
				"oLanguage": {
				"oPaginate": {
					"sPrevious": "Önceki",
					"sNext": "Sonraki"
				}
			},
			"bPaginate": true,
			"bLengthChange": false,
			"bFilter": false,
			"bSort": false,
			"bInfo": false,
			"bAutoWidth": false
		} );
	} );
</script>		

<SCRIPT>

<%@ include file="../../../js/scripts.js" %>

</SCRIPT>
</body>
</html>


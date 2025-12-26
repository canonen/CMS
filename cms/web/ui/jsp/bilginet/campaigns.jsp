<%@ page
	language="java"
	import="com.britemoon.*,
			com.britemoon.cps.*,
			com.britemoon.cps.ctl.*,
			java.util.*,java.sql.*,
			java.net.*,java.text.DateFormat,
			org.apache.log4j.*"
	errorPage="../error_page.jsp"
	contentType="text/html;charset=UTF-8"
%>
<%@ include file="../header.jsp"%>
<%@ include file="../wvalidator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}

AccessPermission can = user.getAccessPermission(ObjectType.CAMPAIGN);

if(!can.bRead) {
	response.sendRedirect("../access_denied.jsp");
	return;
}

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

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


ConnectionPool	cp			= null;
Connection		conn		= null;
Statement		stmt		= null;
ResultSet		rs			= null; 

boolean isDisable = false;

try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("bilginet/campaigns.jsp");
	stmt = conn.createStatement();
	
	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id))) {
		sSelectedCategoryId = ui.s_category_id;
	}
	if (sSelectedCategoryId == null) sSelectedCategoryId = "0";

	String		scurPage	= request.getParameter("curPage");
	String		samount		= request.getParameter("amount");

	int		curPage		= 1;
	int		amount		= 0;

	curPage		= (scurPage	== null) ? 1 : Integer.parseInt(scurPage);
	
	// ********** KU
	
	if (samount == null) samount = ui.getSessionProperty("wizard_list_page_size");
	if ((samount == null)||("".equals(samount))) samount = "25";
	try { amount = Integer.parseInt(samount); }
	catch (Exception ex) { samount = "25"; amount = 25; }
	ui.setSessionProperty("wizard_list_page_size", samount);
		
	// ********** KU

%>
<%@ include file="header.jsp"%>


<%
if (can.bWrite)
{
	%>
	<a href="wizard.jsp?<%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>&a=campaigns" class="zbuttons zbuttons-medium zbuttons-red">
		<span class="zicon zicon-white zicon-plus"></span>
		<span class="zlabel">Yeni Kampanya</span>
	</a>
	
	<a href="campaigns.jsp?a=campaigns" class="zbuttons zbuttons-normal zbuttons-light-gray" style="float:right">
		<span class="zicon zicon-black zicon-refresh"></span>
		<span class="zlabel">Yenile</span>
	</a>
	<div style="clear:both"></div>
	<%
}
%>
<table class="list-table dtables" width="100%" cellspacing="0" cellpadding="0">
	<thead>
	<tr>
		<th>Kampanya Adı</th>
		<th>Kampanya Durumu</th>
		<th>Güncellenme Tarihi</th>
	</tr>
	</thead>
	<tbody>
<%
String sSql = "usp_cque_wizard_camp_list_get " + cust.s_cust_id + "," + sSelectedCategoryId;
rs = stmt.executeQuery(sSql);

String sCampId = null;
String sCampName = null;
String sDisplayName = null;
String sModifyDate = null;
int campCount = 0;
String s_status_id;

String sClassAppend = "";

while( rs.next() )
{
	if (campCount % 2 != 0) sClassAppend = "_Alt";
	else sClassAppend = "";
	
	sCampId = rs.getString(1);
	sCampName = new String(rs.getBytes(2), "UTF-8");
	sDisplayName = rs.getString(3);
	sModifyDate = rs.getString(4);
	s_status_id = rs.getString(5);

	//Page logic
	campCount++;
	if ((campCount <= (curPage-1)*amount) || (campCount > curPage*amount)) continue;
	
	%>
	<%
	String[] md = sModifyDate.split(" ");
	String newmd = "";
	for (Map.Entry<String, String> entry : strDate.entrySet()) {
		if(md[0].equals(entry.getKey()))
			newmd = entry.getValue();
	}
	newmd = md[1] + " " +newmd+ " " + md[2] + " " + md[3];
	
	int statusm = Integer.parseInt(s_status_id);
	
	if (statusm == 0) 
		sDisplayName = "Taslak";
	else if (statusm >= 5 && statusm < 55) 
		sDisplayName = "<span style='color:#296116'>Hazırlanıyor</span>";
	else if(statusm == 55) 
		sDisplayName = "<span style='color:#296116'>Gönderiliyor</span>";
	else if(statusm == 60)
		sDisplayName = "Gönderilmiş";
	else if(statusm == 70)
		sDisplayName = "<span style='color:#DC3912'>Hata Oluşmuş</span>";
	else if(statusm == 72)
		sDisplayName = "<span style='color:#DC3912'>Hata Oluşmuş</span>";
	else if(statusm == 76)
		sDisplayName = "<span style='color:#DC3912'>Hata Oluşmuş</span>";
	else if(statusm == 80)
		sDisplayName = "<span style='color:#DC3912'>İptal Edilmiş</span>";
	else if(statusm == 90)
		sDisplayName = "<span style='color:#DC3912'>Silinmiş</span>";
	else 
		sDisplayName = "?";

	%>
	<tr>
		<td class="listItem_Data<%= sClassAppend %>"><a href="wizard.jsp?camp_id=<%=sCampId%><%=(sSelectedCategoryId!=null)?"&category_id="+sSelectedCategoryId:""%>"><%=sCampName%></a></td>
		<td class="listItem_Data<%= sClassAppend %>"><%=sDisplayName%></td>
		<td class="listItem_Data<%= sClassAppend %>"><%=newmd%></td>
		<% 	//if ((Integer.parseInt(s_status_id) == 60)) { %>
		
	</tr>
	<%
}
rs.close();
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
				},
				"sSearch": "Kampanya Ara : ",
				"sEmptyTable": "Henüz hiç bir kampanya oluşturulmamış."
			},
			"bPaginate": true,
			"bLengthChange": false,
			"bFilter": true,
			"bSort": false,
			"bInfo": false,
			"bAutoWidth": false
		} );
	} );
</script>		

<%@ include file="footer.jsp"%>

<%
	if (stmt != null) stmt.close();
}
catch(Exception ex)
{ 
	ErrLog.put(this,ex,"wizard_list.jsp",out,1);	
}
finally
{
	if (conn != null) cp.free(conn);
}
%>

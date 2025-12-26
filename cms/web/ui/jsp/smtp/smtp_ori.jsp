<%@ page
	language="java"
	import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.ctl.*,
		java.sql.*,java.util.Vector,
		org.w3c.dom.*,org.apache.log4j.*"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>

<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
//AccessPermission can = user.getAccessPermission(ObjectType.EXPORT);

//if(!can.bRead)
//{
//	response.sendRedirect("../access_denied.jsp");
//	return;
//}

AccessPermission canCat = user.getAccessPermission(ObjectType.CATEGORY);

// ********** KU
String		scurPage	= request.getParameter("curPage");
String		samount		= request.getParameter("amount");

int			curPage			= 1;
int			amount			= 0;

curPage		= (scurPage		== null) ? 1 : Integer.parseInt(scurPage);
amount		= (samount==null)? 25 : Integer.parseInt(samount);

boolean isCustom = false;

Statement 		stmt	= null;
ResultSet 		rs		= null; 
ConnectionPool 	cp		= null;
Connection 		conn	= null;

try {
	cp = ConnectionPool.getInstance();
	conn = cp.getConnection("smtp.jsp");
	stmt = conn.createStatement();

	boolean isDisable = false;
	String		CUSTOMER_ID	= cust.s_cust_id;

	String	sFilename	= "";
	String	sFileUrl	= "";
	String	sFileId		= "";
	String	sStatus		= "";
	int nStatusID = 0;
	int nTypeID = 0;

	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;


%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<HTML>
<c:set var="loc" value="en_US"/>
<c:if test="${!(empty param.locale)}">
  <c:set var="loc" value="${param.locale}"/>
</c:if>

<fmt:setLocale value="${loc}" />

<fmt:bundle basename="app">
<HEAD>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<link rel="stylesheet" href="/cms/ui/css/demo_table_jui.css" TYPE="text/css">
<link rel="stylesheet" href="/cms/ui/css/jquery-ui-1.7.2.custom.css" TYPE="text/css">
	<SCRIPT src="../../js/scripts.js"></SCRIPT>
	<script language="javascript">

	function ExportWin(freshurl)
	{
		var window_features = 'scrollbars=yes,resizable=yes,menubar=yes,toolbar=yes,location=no,status=yes,height=600,width=500';
		SmallWin = window.open(freshurl,'ExportWin',window_features);
	}
	
	</script>
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
			oTable = $('#example').dataTable( {
							"bJQueryUI": true,
							"sPaginationType": "full_numbers"
				} );
			
			$('#filter').change( function(){
				filter_string = $('#filter').val();
				oTable.fnFilter( filter_string , 4);
				filter_string = $('#filter').val();
				oTable2.fnFilter( filter_string , 3);
			});
		} );
	</script>	

<script type="text/javascript">

function checkForm ()
{
	var nDels=0;
	var elLength = document.FT.elements.length;

    for (i=0; i<elLength; i++)
    {
        var type = FT.elements[i].type;
        if (type=="checkbox" && FT.elements[i].checked){
            nDels ++;
        }
    }
	
	if (nDels == 0) {
		alert ("Nothing to erase");
		return false;
	}
	FT.NDELS.value = nDels;
	return true;
}

</script>	
</HEAD>
<BODY class="paging_body">

<div class="page_header">SMTP</div>
<div class="page_desc">Monthly General Statistics</div>

<%
java.sql.Connection con;
java.sql.Statement s;
java.sql.ResultSet rss;
java.sql.PreparedStatement pst;

con	=null;
s	=null;
pst	=null;
rss	=null;

// Revotas Inb Sql Connection
String url= "jdbc:jtds:sqlserver://inb.revotas.com";
String id= "revotasadm";
String pass = "l3br0nj4m3s";

try{

Class.forName("net.sourceforge.jtds.jdbc.Driver");
con = java.sql.DriverManager.getConnection(url, id, pass);

}catch(ClassNotFoundException cnfex){
cnfex.printStackTrace();

}

if(CUSTOMER_ID.equals("540")) CUSTOMER_ID="448";

String sql = "use mail_pmta_accounting " + "select emailFrom as id,count(*) as sayi from mail_pmta_acct with (nolock) " + "where campId=1 and custId="+ CUSTOMER_ID + "group by emailfrom order by sayi desc ";

try{
s = con.createStatement();
rss = s.executeQuery(sql);
%>


<table class="tg">
		<th width="14%">Email From </th>
		<th width="14%">Count</th>
	
<%


int campCount = 0;
String sClassAppend = "";

while( rss.next() )

{

if (campCount % 2 != 0) sClassAppend = "_other";
else sClassAppend = "";
campCount++;

%>
	<tr>
		<td class="list_row<%= sClassAppend %>" center width="19%"><%= rss.getString("id") %></td>
		<td class="list_row<%= sClassAppend %>" center width="19%"><%= rss.getString("sayi") %></td>
	</tr>		
</tr>	
<%
}
%>	

<%

}
catch(Exception e){e.printStackTrace();}
finally{
if(rss!=null) rss.close();
if(s!=null) s.close();
if(con!=null) con.close();
}

%>
</table>

<br><br>
</FORM>
</BODY>
</fmt:bundle>
<%

	} catch(Exception ex) {
		ErrLog.put(this,ex,"export_list.jsp",out,1);
		return;
	} finally {
		if (stmt != null) stmt.close();
		if (conn != null) cp.free(conn);
	}
%>
</HTML>

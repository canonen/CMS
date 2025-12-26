<%@ page

	language="java"
	import="com.britemoon.cps.imc.*,
		com.britemoon.cps.*,
		com.britemoon.*, 
		java.util.*,java.sql.*,
		java.net.*,org.w3c.dom.*,
		org.apache.log4j.*"
%>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
if(logger == null)
{
	logger = Logger.getLogger(this.getClass().getName());
}
AccessPermission can = user.getAccessPermission(ObjectType.RECIPIENT);

if(!can.bWrite)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>

<HTML>
<HEAD>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
</HEAD>
<BODY>

<%
// Connection
Statement			stmt			= null;
ResultSet			rs				= null; 
ConnectionPool	connectionPool= null;
Connection			srvConnection = null;


String sRequestXML = "";
String sListXML = "";

int		i		= 0;
int		numRecips = 10;

String sEnableFlag = Registry.getKey("recip_edit_enable_flag");


try	{
	String sSelectedCategoryId = request.getParameter("category_id");
	if ((sSelectedCategoryId == null) && ((user.s_cust_id).equals(cust.s_cust_id)))
		sSelectedCategoryId = ui.s_category_id;

	if (!sEnableFlag.equals("0")) {
		connectionPool = ConnectionPool.getInstance();
		srvConnection = connectionPool.getConnection("manual_import.jsp");
		stmt = srvConnection.createStatement();

		boolean nonEmailFinger = false;	
		rs = stmt.executeQuery("SELECT attr_name FROM ccps_attribute a, ccps_cust_attr c " +
							   "WHERE c.cust_id = "+cust.s_cust_id+" AND a.attr_id = c.attr_id " +
							   "AND fingerprint_seq IS NOT NULL");
		while (rs.next()) {
			if (!rs.getString(1).equals("email_821")) {
				nonEmailFinger = true;
				break;
			}
		}
		rs.close();

		if (!nonEmailFinger) {
			String [] sEmailType	 = new String [50];
			int [] 	  iEmailTypeId	 = new int [50];
			int 	  nEmailType 	 = 0;

			rs = stmt.executeQuery ( "SELECT email_type_id, email_type_name FROM ccps_email_type WHERE email_type_id > 0" );
			while ( rs.next() ) { 
				iEmailTypeId [nEmailType] = rs.getInt(1);
				sEmailType   [nEmailType] = rs.getString(2);
				nEmailType ++;
			}
			rs.close();


%>
<FORM METHOD="POST" NAME="FT" ACTION="recip_write.jsp">
<%=(sSelectedCategoryId!=null)?"<INPUT type=\"hidden\" name=\"category_id\" value=\""+sSelectedCategoryId+"\">":""%>
<INPUT TYPE="hidden" NAME= "tot_recips" VALUE=0>
<INPUT TYPE="hidden" NAME= "num_recips" VALUE=<%=numRecips%>>
<INPUT TYPE="hidden" NAME= "priority_id" VALUE=<%=UpdateRule.OVERWRITE_IGNORE_BLANKS%>>
<a class="savebutton" href="#" onclick="SubmitPrepare();">Save</a>
<br><br>
Choose Batch: <SELECT NAME="batch_id" SIZE="1">
<%
			if ( (sSelectedCategoryId == null) || (sSelectedCategoryId.equals("0")) ) {
				rs = stmt.executeQuery("SELECT DISTINCT b.batch_id, b.batch_name, b.type_id" +
									" FROM cupd_batch b, cupd_import i " + 
									" WHERE  ((b.type_id = 1" + 
									" AND b.batch_id IN (SELECT DISTINCT i.batch_id FROM cupd_import i, cupd_batch b" +
											" WHERE i.status_id = "+UpdateStatus.COMMIT_COMPLETE+
											" AND i.batch_id = b.batch_id AND b.cust_id = " + cust.s_cust_id + "))" +
									" OR b.type_id = 2)" +
									" AND b.cust_id = " + cust.s_cust_id +
									" ORDER BY b.type_id DESC, b.batch_id DESC");
			} else {
				rs = stmt.executeQuery("SELECT DISTINCT b.batch_id, b.batch_name, b.type_id" +
									" FROM cupd_batch b, cupd_import i " + 
									" WHERE  ((b.type_id = 1" + 
									" AND b.batch_id IN (SELECT DISTINCT i.batch_id" +
										" FROM cupd_import i, cupd_batch b, ccps_object_category oc" +
										" WHERE i.status_id = "+ UpdateStatus.COMMIT_COMPLETE +
										" AND i.batch_id = b.batch_id" +
										" AND b.cust_id = " + cust.s_cust_id + 
										" AND oc.object_id = i.import_id" +
										" AND oc.type_id = " + ObjectType.IMPORT +
										" AND oc.cust_id = " + cust.s_cust_id +
										" AND oc.category_id = " + sSelectedCategoryId + "))" +
									" OR b.type_id = 2)" +
									" AND b.cust_id = " + cust.s_cust_id +
									" ORDER BY b.type_id DESC, b.batch_id DESC");
			}
			int batchID;
			while( rs.next() ) {
%>
<OPTION VALUE="<%=rs.getInt(1)%>"> <%=rs.getString(2)%> </OPTION> 
<%
			}
%>
</SELECT><br><br>

<TABLE class="listTable" cellpadding="2" cellspacing="0" WIDTH="750">
<TR><TH>&nbsp;</TH><TH>E-mail</TH><TH>First name</TH><TH>Last name</TH><TH>Company</TH><TH>E-mail Type</TH></TR>
<%
			String sClassAppend = "_Alt";
			
			for ( int j=0 ; j < numRecips ; j++)
			{ 
				if (j % 2 != 0)
				{
					sClassAppend = "_Alt";
				}
				else
				{
					sClassAppend = "";
				}
%>
<TR>
<TD align="center" valign="middle" class="listItem_Data<%= sClassAppend %>"><%=(j+1)%></TD>
<TD align="left" valign="middle" class="listItem_Data<%= sClassAppend %>"><INPUT TYPE="text" NAME= "email_821_<%=j%>" VALUE="" size="40"></TD>
<TD align="left" valign="middle" class="listItem_Data<%= sClassAppend %>"><INPUT TYPE="text" NAME= "pnmgiven_<%=j%>" VALUE="" size="25"></TD>
<TD align="left" valign="middle" class="listItem_Data<%= sClassAppend %>"><INPUT TYPE="text" NAME= "pnmfamily_<%=j%>" VALUE="" size="25"></TD>
<TD align="left" valign="middle" class="listItem_Data<%= sClassAppend %>"><INPUT TYPE="text" NAME= "orgnm_<%=j%>" VALUE="" size="25"></TD>
<TD align="center" valign="middle" class="listItem_Data<%= sClassAppend %>"><SELECT NAME="email_type_id_<%=j%>" SIZE="1">
<OPTION VALUE=""> Unknown </OPTION>
<%
				for (i=0 ; i < nEmailType ; i ++)
				{
					%><OPTION VALUE="<%=iEmailTypeId [i]%>"> <%=sEmailType [i]%> </OPTION><%
				}
%>
</SELECT></TD>
<INPUT TYPE="hidden" NAME= "email_type_confidence_<%=j%>" VALUE="30">
</TR>
<%	
			}
%>
</TABLE>

</FORM>


<SCRIPT>
var numRecips = <%=numRecips%>;

function SubmitPrepare(){
	var nAmount = 0;
	for (var i=0; i<numRecips; i++) {
		if ( (eval("FT.email_821_"+i).value != "") ) { 
			nAmount++;
		} else if ( (eval("FT.pnmgiven_"+i).value != "") 
			|| (eval("FT.pnmfamily_"+i).value != "") 
			|| (eval("FT.orgnm_"+i).value != "")) { 
			if (eval("FT.email_821_"+i).value == "") {alert("You have to supply an email for Recipient "+(i+1));	return false;}
		}
	}
	FT.tot_recips.value = nAmount;
// check for double click
	FT.submit();
}

</SCRIPT>
<%
		} else { // nonEmailFinger true
%>
	This feature only works for customers whose fingerprint is email address.
<%
		}
	} else { // EnableFlag = 0
%>
	This feature is temporarily disabled.
<%
	}
%>
</BODY></HTML>
<%
} catch(Exception ex) { 
	
	ErrLog.put(this,ex,"Problem with Manual Import list.",out,1);

} finally {
	if ( stmt != null ) stmt.close();
	if ( srvConnection  != null ) connectionPool.free(srvConnection); 
}
%>






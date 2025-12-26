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

if(!can.bRead)
{
	response.sendRedirect("../access_denied.jsp");
	return;
}
%>

<%
boolean bCanWrite = can.bWrite;

String sEnableFlag = Registry.getKey("recip_edit_enable_flag");
if (sEnableFlag.equals("0")) 	bCanWrite = false;

// Connection
Statement			stmt			= null;
ResultSet			rs				= null; 
ConnectionPool	connectionPool= null;
Connection			srvConnection = null;


String sRequestXML = "";
String sListXML = "";

try	{
	connectionPool = ConnectionPool.getInstance();
	srvConnection = connectionPool.getConnection("recip_edit_list.jsp");
	stmt = srvConnection.createStatement();

String		NUM_RECIPS	= request.getParameter ("num_recips");
String		EMAIL		= request.getParameter ("email");
String		LASTNAME	= request.getParameter ("lastname");
int		i		= 0;
String	sSelected	= "";
int		isByEmail	= 0;

	String [] sEmailType	 = new String [10];
	String [] iEmailTypeId	 = new String [10];
	int 	  nEmailType 	 = 0;
	String [] sRecipStatus	 = new String [100];
	int []    iRecipStatusId = new int [100];
	int 	  nRecipStatus	 = 0;

	rs = stmt.executeQuery ( "SELECT email_type_id, email_type_name FROM ccps_email_type WHERE email_type_id > 0" );
	while ( rs.next() ) { 
		iEmailTypeId [nEmailType] = rs.getString(1);
		sEmailType   [nEmailType] = rs.getString(2);
		nEmailType ++;
	}
	rs.close();

	rs = stmt.executeQuery ( "SELECT status_id, display_name FROM ccps_recip_status WHERE status_id < 300");
	while ( rs.next() ) { 
		iRecipStatusId [nRecipStatus] = rs.getInt(1);
		sRecipStatus   [nRecipStatus] = rs.getString(2);
		nRecipStatus ++;
	}
	rs.close();
	
	sRequestXML += "<RecipRequest>\r\n";
	sRequestXML += "<action>EdtList</action>\r\n";
	sRequestXML += "<cust_id>"+cust.s_cust_id+"</cust_id>\r\n";
	if ((EMAIL != null) && (!EMAIL.trim().equals("")))
		sRequestXML += "<email_821><![CDATA["+EMAIL+"]]></email_821>\r\n";
	else
		sRequestXML += "<pnmfamily><![CDATA["+LASTNAME+"]]></pnmfamily>\r\n";
	sRequestXML += "<num_recips>"+NUM_RECIPS+"</num_recips>\r\n";
	rs = stmt.executeQuery("SELECT DISTINCT c.attr_id FROM ccps_cust_attr c, ccps_attribute a WHERE c.cust_id = "+cust.s_cust_id
					+ " AND c.attr_id = a.attr_id "
					+ " AND a.attr_name IN ('recip_id','email_821','pnmgiven','pnmfamily','email_type_id','status_id','orgnm','email_type_confidence')"
					+ " OR c.fingerprint_seq IS NOT NULL");
	String sAttrList = "";
	while (rs.next())
		sAttrList += ((sAttrList.length()>0)?",":"")+rs.getString(1);
	sRequestXML += "<attr_list>"+sAttrList+"</attr_list>\r\n";
	sRequestXML += "</RecipRequest>\r\n";

	Service service = null;
	Vector services = Services.getByCust(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id);

	service = (Service) services.get(0);
	service.connect();

	service.send(sRequestXML);
	sListXML = service.receive();

	service.disconnect();
%>

<HTML>
<HEAD>
	<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" TYPE="text/css">
<script language="javascript">
	
	function pop_up_win(url)
	{
		windowName = 'recip_edit_window';
		windowFeatures = 'dependent=yes, scrollbars=yes, resizable=yes, toolbar=no, location=no, height=600, width=700';
		ReportWin = window.open(url, windowName, windowFeatures);
	}
	
</script>
</HEAD>
<BODY>
<%=(sEnableFlag.equals("0")?"<FONT color=red>* Editting of recipient data is temporarily disabled.</FONT>":"")%>

<%
	Element eRecipList = XmlUtil.getRootElement(sListXML);
	int nTotRecips = Integer.parseInt(XmlUtil.getChildTextValue(eRecipList, "total_recips"));
	int nTotReturned = Integer.parseInt(XmlUtil.getChildTextValue(eRecipList, "total_returned"));

	if ( nTotReturned < nTotRecips ) {
%>
<%=nTotReturned%> Recipients have been returned out of <%=nTotRecips%> which match your search criteria.<BR>
<%
	}

	XmlElementList xelRecips = XmlUtil.getChildrenByName(eRecipList, "recipient");

%>

<table class="listTable" cellpadding="0" cellspacing="0" WIDTH="100%" BORDER="0">
	<tr>
		<th>First name</th>
		<th>Last name</th>
		<th>E-mail</th>
		<th>E-mail Type</th>
		<th>Company</th>
		<th>Client status</th>
		<th>Action</th>
	</tr>
<%
Element eRecip = null;
String 	sRecipID = "";
String 	sEmail821 = "";
String 	sPNmGiven = "";
String 	sPNmFamily = "";
String 	sOrgNm = "";
String	sEmailTypeID = "";
String	sEmailTypeName = "";
int		nEmailConfidence = 0;
int 	nStatusID = 0;
int		nStatusCanChangeTo = 0;
boolean	isUnsub = false;
String sVal = null;

int nFingerAttr = 0;
rs = stmt.executeQuery("SELECT DISTINCT count(attr_id) FROM ccps_cust_attr WHERE cust_id = "+cust.s_cust_id
				+ " AND fingerprint_seq IS NOT NULL");
if (rs.next()) nFingerAttr = rs.getInt(1);
String [] sExtraAttrName = new String [nFingerAttr+1];
String [] sExtraAttrValue = new String [nFingerAttr+1];

String sClassAppend = "";

for (int j=0; j < xelRecips.getLength() ; j++)
{
	if (j % 2 != 0)
	{
		sClassAppend = "_Alt";
	}
	else
	{
		sClassAppend = "";
	}
	
	eRecip = (Element)xelRecips.item(j);
	sRecipID = XmlUtil.getChildCDataValue(eRecip,"recip_id");
	sEmail821 = XmlUtil.getChildCDataValue(eRecip,"email_821");
	sPNmGiven = XmlUtil.getChildCDataValue(eRecip,"pnmgiven");
	if (sPNmGiven == null)	sPNmGiven = "";
	sPNmFamily = XmlUtil.getChildCDataValue(eRecip,"pnmfamily");
	if (sPNmFamily == null)	sPNmFamily = "";
	sEmailTypeID = XmlUtil.getChildCDataValue(eRecip,"email_type_id");
	rs = stmt.executeQuery("SELECT email_type_name FROM ccps_email_type WHERE email_type_id = "+sEmailTypeID);
	if (rs.next()) sEmailTypeName = rs.getString(1);
	if (sEmailTypeID == null)	sEmailTypeID = "";
	if (sEmailTypeName == null)	sEmailTypeName = "";
	sVal = XmlUtil.getChildCDataValue(eRecip,"email_type_confidence");
	nEmailConfidence = Integer.parseInt((sVal!=null)?sVal:"5");
	sVal = XmlUtil.getChildCDataValue(eRecip,"status_id");
	nStatusID = Integer.parseInt((sVal!=null)?sVal:"0");
	sOrgNm = XmlUtil.getChildCDataValue(eRecip,"orgnm");
	if (sOrgNm == null)	sOrgNm = "";

	rs = stmt.executeQuery("SELECT DISTINCT attr_name FROM ccps_cust_attr c, ccps_attribute a WHERE c.cust_id = "+cust.s_cust_id
				+ " AND c.attr_id = a.attr_id" 
				+ " AND attr_name NOT IN ('recip_id','email_821','pnmgiven','pnmfamily','email_type_id','status_id','orgnm','email_type_confidence')"
				+ " AND fingerprint_seq IS NOT NULL");
	int jj=0;
	while (rs.next())
	{
		sExtraAttrName[jj] = rs.getString(1);
		sExtraAttrValue[jj] = XmlUtil.getChildCDataValue(eRecip,sExtraAttrName[jj]);
		jj++;
	}

//  Each status can be changed to only one other status:
//  draft -> active, active -> unsub, unsub -> unsub, bback -> active, global exclusion -> active

	// added as a part of Release 6.0
	// unsub -> active if RECIP_RESUBSCRIBE permission exists
	AccessPermission canReSubscribe = user.getAccessPermission(ObjectType.RECIP_RESUBSCRIBE);
	// end

	if (nStatusID < RecipStatus.ACTIVE) 
		nStatusCanChangeTo = RecipStatus.NEW_ACTIVE;
	else if ( (nStatusID >= RecipStatus.ACTIVE) && (nStatusID < RecipStatus.EXCLUDED) ) 
		nStatusCanChangeTo = RecipStatus.UNSUBSCRIBED;
	else if ( (nStatusID >= RecipStatus.EXCLUDED) && (nStatusID < RecipStatus.UNSUBSCRIBED) ) 
		nStatusCanChangeTo = RecipStatus.OLD_ACTIVE;
	else if ( (nStatusID == RecipStatus.TEST_UNSUBSCRIBED) ) 
		nStatusCanChangeTo = RecipStatus.OLD_ACTIVE;
		
// changed the code as a part of Release 6.0
// unsub -> active if RECIP_RESUBSCRIBE permission exists
	else if ( (nStatusID >= RecipStatus.UNSUBSCRIBED) && (nStatusID < RecipStatus.GLOBAL_EXCLUSION) ) 
	{
		if(!canReSubscribe.bExecute)
		{
			nStatusCanChangeTo = RecipStatus.UNSUBSCRIBED;
		}
		else
		{
			nStatusCanChangeTo = RecipStatus.OLD_ACTIVE;
		}
	}
	// end release 6.0
	
		
//		else if ( (nStatusID >= RecipStatus.GLOBAL_EXCLUSION) && (nStatusID < RecipStatus.FRIEND) ) 
//			nStatusCanChangeTo = RecipStatus.OLD_ACTIVE;

//		isUnsub  = ( (nStatusID >= RecipStatus.UNSUBSCRIBED) && (nStatusID < RecipStatus.GLOBAL_EXCLUSION) );
//ZW - 4/21/03 - changed this for test unsubs
	isUnsub  = ( (nStatusID == RecipStatus.UNSUBSCRIBED) );

// added as a part of Release 6.0
// unsub -> active if RECIP_RESUBSCRIBE permission exists
		if(canReSubscribe.bExecute)
		{
			isUnsub = false;
		}
	

	%>
	<form method="POST" name="FT<%=sRecipID%>" action="recip_write.jsp" target="result">
	<input type="hidden" name="recip_id" value="<%=sRecipID%>">
	<input type="hidden" name="priority_id" value=<%=UpdateRule.OVERWRITE_WITH_BLANKS%>>
	<%
	for (int ii=0 ; ii<jj ; ii++)
	{
		%>
		<input type="hidden" name="<%=sExtraAttrName[ii]%>" value="<%=sExtraAttrValue[ii]%>">
		<%
	}
	%>
	<tr>
		<td class="listItem_Data<%= sClassAppend %>"><input type="text" name="pnmgiven" value="<%=sPNmGiven%>"<%=(isUnsub || !bCanWrite)?" disabled":""%>></td>
		<td class="listItem_Data<%= sClassAppend %>"><input type="text" name="pnmfamily" value="<%=sPNmFamily%>"<%=(isUnsub || !bCanWrite)?" disabled":""%>></td>
		<td class="listItem_Data<%= sClassAppend %>"><input type="text" name="email_821" value="<%=sEmail821%>"<%=(isUnsub || !bCanWrite)?" disabled":""%>></td>
		<td class="listItem_Data<%= sClassAppend %>">
			<select name="email_type_id" size="1" OnChange="SetConfidence(FT<%=sRecipID%>)"<%=(isUnsub || !bCanWrite)?" disabled":""%>>
				<option value=""<%=(( sEmailTypeID.equals("") || ( nEmailConfidence < 30 ) ) ? " selected" : "")%>>Default<%=(sEmailTypeName.length()>0)?" ("+sEmailTypeName+")":""%></option>
			<%
			for (i=0 ; i < nEmailType ; i ++)
			{
				sSelected = ( sEmailTypeID.equals(iEmailTypeId [i]) && ( nEmailConfidence >= 30 ) ) ? " selected" : "";
				%>
				<option value="<%=iEmailTypeId [i]%>"<%=sSelected%>> <%=sEmailType [i]%> </option>
				<%
			}
			%>
			</select>
			<input type="hidden" name="email_type_confidence" value="<%=nEmailConfidence%>">
		</td>
		<td class="listItem_Data<%= sClassAppend %>"><input type="text" name= "orgnm" value="<%=sOrgNm%>"<%=(isUnsub || !bCanWrite)?" disabled":""%>></td>		
		<td class="listItem_Data<%= sClassAppend %>">
			<select name="status_id" size="1"<%=(isUnsub || !bCanWrite)?" disabled":""%>>
			<%
			for (i=0 ; i < nRecipStatus ; i ++) {
				sSelected = ( iRecipStatusId [i] == nStatusID )  ?   " selected" : "";
				if (iRecipStatusId[i] == nStatusID || iRecipStatusId[i] == nStatusCanChangeTo)
				{
					%>
					<option value="<%=iRecipStatusId [i]%>"<%=sSelected%>> <%=sRecipStatus [i]%> </option>
					<%
				}
			}
			%>
			</select>
		</td>
		<td class="listItem_Data<%= sClassAppend %>">
		<% if (!isUnsub && bCanWrite) { %>
			<a class="savebutton" href="javascript:SubmitPrepare(FT<%=sRecipID%>)">Update</a>&nbsp;
		<% } %>	
			<a class="resourcebutton" href="#" onclick="pop_up_win('recip_edit.jsp?recip_id=<%=sRecipID%>');">Profile</a>&nbsp;
			<!--<a class="resourcebutton" href="#" onclick="pop_up_win('recip_edit.jsp?recip_id=<%=sRecipID%>');">Edit</a>&nbsp;
			<a class="resourcebutton" href="#" onclick="pop_up_win('../report/recip_camp_history.jsp?recip_id=<%=sRecipID%>');">History</a>&nbsp;//-->
		</td>
	</tr>
	</form>
	<%
}
%>
</table>

<SCRIPT>
function SetConfidence(pForm){
	pForm.email_type_confidence.value = 100;
}

function SubmitPrepare(pForm){
	pForm.submit();
}
</SCRIPT>

</BODY></HTML>
<%
} catch(Exception ex) { 

	ErrLog.put(this,ex,"Problem finding Recipients.\r\n Request XML: "+sRequestXML+"\r\n List XML: "+sListXML,out,1);

} finally {
	if ( stmt != null ) stmt.close();
	if ( srvConnection != null ) connectionPool.free(srvConnection); 
}
%>






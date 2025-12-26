<%@ page
	language="java"
	import="com.britemoon.cps.imc.*,
		com.britemoon.cps.*,
		com.britemoon.*,
		java.util.*,java.sql.*,
		java.net.*,org.w3c.dom.*,
		org.apache.log4j.*"
%>
<%@ include file="../header.jsp" %>
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
Statement		stmt			= null;
ResultSet		rs				= null; 
ConnectionPool	connectionPool	= null;
Connection		srvConnection	= null;

String sRequestXML = "";
String sListXML = "";

try
{
	connectionPool = ConnectionPool.getInstance();
	srvConnection = connectionPool.getConnection("recip_edit.jsp");
	stmt = srvConnection.createStatement();

	String	sRecipID	= request.getParameter ("recip_id");
	String	sSelected	= "";
	int 	iCol		= 0;
	int		i			= 0;

	String [] sEmailType	 = new String [10];
	String [] iEmailTypeId	 = new String [10];
	int 	  nEmailType 	 = 0;
	String [] sRecipStatus	 = new String [100];
	int []    iRecipStatusId = new int [100];
	int 	  nRecipStatus	 = 0;

	rs = stmt.executeQuery ( "select email_type_id, email_type_name FROM ccps_email_type WHERE email_type_id > 0" );
	while ( rs.next() )
	{ 
		iEmailTypeId [nEmailType] = rs.getString(1);
		sEmailType   [nEmailType] = rs.getString(2);
		nEmailType ++;
	}
	rs.close();

	rs = stmt.executeQuery ( "select status_id, display_name FROM ccps_recip_status WHERE status_id < 300");
	while ( rs.next() )
	{ 
		iRecipStatusId [nRecipStatus] = rs.getInt(1);
		sRecipStatus   [nRecipStatus] = rs.getString(2);
		nRecipStatus ++;
	}
	rs.close();

	sRequestXML += "<RecipRequest>\r\n";
	sRequestXML += "<action>EdtDetail</action>\r\n";
	sRequestXML += "<cust_id>" + cust.s_cust_id + "</cust_id>\r\n";
	sRequestXML += "<recip_id>" + sRecipID + "</recip_id>\r\n";	
	sRequestXML += "<num_recips>1</num_recips>\r\n";
	sRequestXML += "<attr_list>all</attr_list>\r\n";
	sRequestXML += "</RecipRequest>\r\n";
	
	sListXML = Service.communicate(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id, sRequestXML);
	//System.out.println(sListXML);
	
	%>
<HTML>
<HEAD>
<title>Recipient Edit</title>
<%@ include file="../header.html" %>
<link rel="stylesheet" href="<%=ui.s_css_filename%>" type="text/css">
</HEAD>
<BODY onload="self.focus();">
<%
	Element eRecipList = XmlUtil.getRootElement(sListXML);
	int nTotRecips = Integer.parseInt(XmlUtil.getChildTextValue(eRecipList, "total_recips"));
	int nTotReturned = Integer.parseInt(XmlUtil.getChildTextValue(eRecipList, "total_returned"));

	boolean	isUnsub = false;
	
	if (nTotReturned > 0)
	{
		XmlElementList xelRecips = XmlUtil.getChildrenByName(eRecipList, "recipient");

		Element eRecip = null;
		String 	sEmail821 = "";
		String 	spnmfull = "";
		String 	sRecipLogin = "";
		String 	sRecipPassword = "";
		String	sEmailTypeID = "";
		String	sEmailTypeName = "";
		int		nEmailConfidence = 0;
		int 	nStatusID = 0;
		int		nStatusCanChangeTo = 0;
		String sVal = null;

		eRecip			= (Element)xelRecips.item(0);
		sRecipID		= XmlUtil.getChildCDataValue(eRecip,"recip_id");
		sEmail821		= XmlUtil.getChildCDataValue(eRecip,"email_821");
		spnmfull		= XmlUtil.getChildCDataValue(eRecip,"pnmfull");
		
		sRecipLogin		= XmlUtil.getChildCDataValue(eRecip,"recip_login");
		if (sRecipLogin == null) sRecipLogin = "";
		
		sRecipPassword = XmlUtil.getChildCDataValue(eRecip,"recip_password");
		if (sRecipPassword == null) sRecipPassword = "";
		
		sEmailTypeID = XmlUtil.getChildCDataValue(eRecip,"email_type_id");

		rs = stmt.executeQuery("select email_type_name FROM ccps_email_type WHERE email_type_id = " + sEmailTypeID);
		if (rs.next()) sEmailTypeName = rs.getString(1);

		if (sEmailTypeID == null)	sEmailTypeID = "";
		if (sEmailTypeName == null)	sEmailTypeName = "";
		
		sVal = XmlUtil.getChildCDataValue(eRecip,"email_type_confidence");
		nEmailConfidence = Integer.parseInt((sVal!=null)?sVal:"5");

		nStatusID = Integer.parseInt(XmlUtil.getChildCDataValue(eRecip,"status_id"));

		//  Each status can be changed to only one other status:
		//  draft -> active, active -> unsub, unsub -> unsub, bback -> active, global exclusion -> active
		
			// added as a part of Release 6.0
			// unsub -> active if RECIP_RESUBSCRIBE permission exists
			AccessPermission canReSubscribe = user.getAccessPermission(ObjectType.RECIP_RESUBSCRIBE);
			// end
				
			if (nStatusID < RecipStatus.ACTIVE)
			{
				nStatusCanChangeTo = RecipStatus.NEW_ACTIVE;
			}
			else if ( (nStatusID >= RecipStatus.ACTIVE) && (nStatusID < RecipStatus.EXCLUDED) ) 
			{
				nStatusCanChangeTo = RecipStatus.UNSUBSCRIBED;
			}
			else if ( (nStatusID >= RecipStatus.EXCLUDED) && (nStatusID < RecipStatus.UNSUBSCRIBED) )
			{
				nStatusCanChangeTo = RecipStatus.OLD_ACTIVE;
			}
			else if ( (nStatusID == RecipStatus.TEST_UNSUBSCRIBED) )
			{
				nStatusCanChangeTo = RecipStatus.OLD_ACTIVE;
			}
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
			//else if ( (nStatusID >= RecipStatus.GLOBAL_EXCLUSION) && (nStatusID < RecipStatus.FRIEND) )
			//{
			//	nStatusCanChangeTo = RecipStatus.OLD_ACTIVE;
			//}

		//ZW - 4/21/03 - changed this for test unsubs
			isUnsub  = ( (nStatusID == RecipStatus.UNSUBSCRIBED) );
			//isUnsub  = ( (nStatusID >= RecipStatus.UNSUBSCRIBED) && (nStatusID < RecipStatus.GLOBAL_EXCLUSION) );
			
		// added as a part of Release 6.0
		// unsub -> active if RECIP_RESUBSCRIBE permission exists
		if(canReSubscribe.bExecute)
		{
			isUnsub = false;
		}
		%>
<table cellspacing="0" cellpadding="0" border="0" class="layout" style="width:100%; height:100%;">
	<col>
	<tr height="30">
		<td>
			<table cellpadding="4" cellspacing="0" border="0">
				<tr>
				<%
				if ((bCanWrite) && (!isUnsub))
				{
					%>
					<td vAlign="middle" align="left">
						<a class="savebutton" href="#" onclick="SubmitPrepare()">Update</a>&nbsp;&nbsp;&nbsp;
					</td>
					<td vAlign="middle" align="left">
						<a class="deletebutton" href="#" onclick="if( confirm('Are you sure you want to delete this Recipient?') ) SubmitDelete()">Delete</a>&nbsp;&nbsp;&nbsp;
					</td>
					<%
				}
				%>
					<td vAlign="middle" align="left">
						<a class="subactionbutton" href="#" onclick="window.close()">Cancel</a>&nbsp;&nbsp;&nbsp;
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table id="Tabs_Table1" cellspacing="0" cellpadding="0" border="0" class="listTable" style="width:100%;">
				<col width="150">
				<col width="150">
				<col>
				<tr height="20">
					<th class="Tab_ON" id="tab1_Step1" valign="center" nowrap align="middle">Recipient Edit</th>
					<th class="Tab_OFF" id="tab1_Step2" onclick="location.href='../report/recip_camp_history.jsp?recip_id=<%= sRecipID %>';" valign="center" nowrap align="middle">Campaign History</th>
					<th class="EmptyTab" valign="center" nowrap align="middle"><img height="2" src="../../images/blank.gif" width="1"></th>
				</tr>
				<tr height="50">
					<td class="" valign="top" align="center" colspan="3" style="padding:8px;">
						<table class="" cellspacing="1" cellpadding="2" width="100%">
							<tr>
								<td align="center" valign="middle" style="padding:10px;">
									<%=(sEnableFlag.equals("0")?"<FONT color=red>* Editing of recipient data is temporarily disabled.</FONT>"
									:"You are not allowed to change the unique identifier of this record to match any other existing record's unique identifier.")%>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td class="" valign="top" align="center" colspan="3">
						<div style="width:100%; height:100%; overflow:auto;">
						<FORM METHOD="POST" name="FT" ACTION="recip_write.jsp" TARGET="_self">
							<input type="hidden" name= "recip_id" value="<%=sRecipID%>">
							<input type="hidden" name= "priority_id" value=<%=UpdateRule.OVERWRITE_WITH_BLANKS%>>
							<table cellpadding="0" cellspacing="0" BORDER="0" class="" style="width:100%;">
								<col width="100">
								<col>
								<col width="100">
								<col>
								<tr>
									<td>E-mail:</td>
									<td><input type="text" name= "email_821" value="<%=sEmail821%>" size="5" style="width:100%;"<%=(isUnsub || !bCanWrite)?" disabled":""%>></td>
									<td>Full Name:</td>
									<td><input type="text" name= "email_821" value="<%=spnmfull%>" size="5" style="width:100%;"<%=(isUnsub || !bCanWrite)?" disabled":""%>></td>
								</tr>
								<tr>
									<td>E-mail Type:</td>
									<td>
										<select name="email_type_id" size="1" OnChange="SetConfidence(FT<%=sRecipID%>)"<%=(isUnsub || !bCanWrite)?" disabled":""%> style="width:100%;">
											<option value=""<%=(( sEmailTypeID.equals("") || ( nEmailConfidence < 30 ) ) ? " selectED" : "")%>>Default<%=(sEmailTypeName.length()>0)?" ("+sEmailTypeName+")":""%></option>
										<%
										for (i=0 ; i < nEmailType ; i ++)
										{
											sSelected = ( sEmailTypeID.equals(iEmailTypeId [i]) && ( nEmailConfidence >= 30 ) ) ? " selectED" : "";
											%>
											<option value="<%=iEmailTypeId [i]%>"<%=sSelected%>> <%=sEmailType [i]%> </option>
											<%
										}
										%>
										</select>
										<input type="hidden" name="email_type_confidence" value="<%=nEmailConfidence%>">
									</td>
									<td>Client status: </td>
									<td>
										<select name="status_id" size="1"<%=(isUnsub || !bCanWrite)?" disabled":""%> style="width:100%;">
									<%
									for (i=0 ; i < nRecipStatus ; i ++)
									{
										sSelected = ( iRecipStatusId [i] == nStatusID )  ?   "selectED" : "";
										if (iRecipStatusId [i] == nStatusID || iRecipStatusId [i] == nStatusCanChangeTo)
										{
											%>
											<option value="<%=iRecipStatusId [i]%>" <%=sSelected%>> <%=sRecipStatus [i]%> </option>
											<%
										}
									}
									%>
										</select>
									</td>
								</tr>
							</table>
							<br>
							<table cellpadding="0" cellspacing="0" BORDER="0" class="listTable" style="width:100%;">
								<col width="100">
								<col>
								<col width="100">
								<col>
								<tr>
									<th colspan="4">Custom Fields</th>
								</tr>
					<%

					iCol = 0;

					int			nFields 		= 0;
					int			mvalFields 		= 0;
					int			newsFields 		= 0;
					
					String []	sFieldName		= new String [1000];
					String []	sFieldLabel 	= new String [1000];
					int []		nValueQty		= new int [1000];
					String []	sNewsletter		= new String [1000];

					rs = stmt.executeQuery ("select a.attr_name, c.display_name, value_qty, c.newsletter_flag FROM ccps_attribute a, ccps_cust_attr c"
						+ " WHERE c.cust_id = " + cust.s_cust_id 
						+ "  AND a.attr_id = c.attr_id"
						+ "  AND attr_name NOT IN ('recip_id','email_821','pnmfull','email_type_id','status_id')"
						+ "  AND display_seq IS NOT NULL" 
						+ " ORDER BY value_qty, c.newsletter_flag, display_seq");

					/*  field value  */
						String sTmp = null;
						
					String sNLType = "";

					while ( rs.next() )
					{ 
						sFieldName [nFields]	= rs.getString(1);
						sFieldLabel [nFields]	= new String(rs.getBytes(2), "ISO-8859-1");
						nValueQty [nFields]		= rs.getInt(3);
						
						sNLType = "";
						sNLType = rs.getString(4);
						
						if (sNLType == null) sNLType = "";

						if (nValueQty [nFields] == 0)
						{  
							if ("".equals(sNLType))
							{
								sTmp = XmlUtil.getChildCDataValue(eRecip,sFieldName [nFields]);

								if (sTmp == null)	sTmp = "";

								if (iCol % 2 == 0)
								{
									%>
									</tr>
									<tr>
									<%
								}
								%>
										<td><%= sFieldLabel[nFields] %>: </td>
										<td><input type="text" name="<%= sFieldName[nFields] %>" value="<%= sTmp %>" size="5" style="width:100%;"<%= (isUnsub || !bCanWrite)?" disabled":"" %>></td>
								<%
								iCol ++;
							}
							else
							{
								/* Newsletter Field */
								
								if (newsFields == 0)
								{
									if (iCol % 2 != 0)
									{
										%>
										<td colspan="2">&nbsp;</td>
										<%
									}
									%>
									</tr>
								</table>
								<br>
								<table cellpadding="2" cellspacing="1" BORDER="0" class="layout main" style="width:100%;">
									<col width="150">
									<col>
									<col width="150">
									<col>
									<tr>
										<th colspan="4">Newsletter Fields</th>
									</tr>
									<%
								}
								
								sTmp = XmlUtil.getChildCDataValue(eRecip,sFieldName [nFields]);

								if (sTmp == null)	sTmp = "";

								if (newsFields % 2 == 0)
								{
									%>
									</tr>
									<tr>
									<%
								}
								
								if ("Y".equals(sNLType))
								{
									%>
										<td><%= sFieldLabel[nFields] %>: </td>
										<td>
										<input type="radio" name="<%= sFieldName[nFields] %>" id="<%= sFieldName[nFields] %>_Y" value="Y"<%= ("Y".equals(sTmp))?" checked":"" %><%= (isUnsub || !bCanWrite)?" disabled":"" %>><label for="<%= sFieldName[nFields] %>_Y">&nbsp;Y</label>
										<input type="radio" name="<%= sFieldName[nFields] %>" id="<%= sFieldName[nFields] %>_N" value="N"<%= ("N".equals(sTmp))?" checked":"" %><%= (isUnsub || !bCanWrite)?" disabled":"" %>><label for="<%= sFieldName[nFields] %>_N">&nbsp;N</label>
										</td>
									<%
								}
								else
								{
									%>
										<td><%= sFieldLabel[nFields] %>: </td>
										<td>
										<input type="radio" name="<%= sFieldName[nFields] %>" id="<%= sFieldName[nFields] %>_1" value="1"<%= ("1".equals(sTmp))?" checked":"" %><%= (isUnsub || !bCanWrite)?" disabled":"" %>><label for="<%= sFieldName[nFields] %>_1">&nbsp;1</label>
										<input type="radio" name="<%= sFieldName[nFields] %>" id="<%= sFieldName[nFields] %>_0" value="0"<%= ("0".equals(sTmp))?" checked":"" %><%= (isUnsub || !bCanWrite)?" disabled":"" %>><label for="<%= sFieldName[nFields] %>_0">&nbsp;0</label>
										</td>
									<%
								}
								iCol ++;
								
								newsFields++;
							}
						}
						else
						{
							/* Multi-value Field */
							
							if (mvalFields == 0)
							{
								if (newsFields % 2 != 0)
								{
									%>
									<td colspan="2">&nbsp;</td>
									<%
								}
								%>
								</tr>
							</table>
							<br>
							<table cellpadding="0" cellspacing="0" BORDER="0" class="listTable" style="width:100%;">
								<col width="150">
								<col>
								<tr>
									<th colspan="2">Multi-Value Fields</th>
								</tr>
								<%
							}
							
							XmlElementList xelMultiField = XmlUtil.getChildrenByName (eRecip, sFieldName [nFields]);
							%>
								<tr>
									<td>
										<%= sFieldLabel[nFields] %>:
										<br><br>
										<a href="javascript:addNew('<%= sFieldName[nFields] %>');" class="resourcebutton">Add New Value</a>
										<br>
									</td>
									<td>
										<!-- rowspan="<%= String.valueOf(xelMultiField.getLength() + 1) %>"//-->
										<table cellspacing="0" cellpadding="2" border="0" class="layout" style="width:100%;" id="mvals_<%= sFieldName[nFields] %>">
											<col width="100">
											<col>
							<%
							
							int j = 0;

							for (j=0; j < xelMultiField.getLength() ; j++)
							{
								Element eField = (Element) xelMultiField.item(j);
								sTmp = XmlUtil.getCDataValue(eField);

								if (sTmp == null)	sTmp = "";
								
								//if (j != 0)
								//{
									%>
								<!--<tr>//-->
									<%
								//}
								%>
											<tr>
												<td colspan="2"><input type="text" name="<%= sFieldName[nFields] %>" value="<%= sTmp %>" size="5" style="width:100%;"<%= (isUnsub || !bCanWrite)?" disabled":"" %>></td>
											</tr>
								<%
								iCol ++;
							}
							
							if (j == 0)
							{
								%>
								<!--<tr>//-->
								<%
							}
							%>
											<tr>
												<td>Enter new value: </td>
												<td><input type="text" name="<%= sFieldName[nFields] %>" value="" size="5" style="width:100%;"<%= (isUnsub || !bCanWrite)?" disabled":"" %>></td>
											</tr>
										</table>
									</td>
								</tr>
							<%
							iCol ++;
							mvalFields++;
						}
						nFields ++;
					}
					rs.close();
					%>
								</tr>
							</table>
						</FORM>
						</div>
					</td>
				</tr>
				</tbody>
			</table>
		</td>
	</tr>
</table>
	<%
}
else
{
	throw new Exception ("No Recipient Found");
}	
%>
<SCRIPT>
function SubmitDelete()
{
// add a Delete Option to the status_id Select field and set it to Selected
// new Option(text,value,defaultSelected,Selected)
FT.status_id.options[FT.status_id.options.length] = new Option("Deleted",900,true,true);
SubmitPrepare();
}

function SubmitPrepare()
{
FT.submit();
}

function addNew(attr_name)
{
	var oTable = document.getElementById("mvals_" + attr_name);
	var oRow;
	var oCell;
	var oInput;
	
	oRow = oTable.insertRow();
	oCell = oRow.insertCell();
	oCell.align = "left";
	oCell.vAlign = "middle";
	oCell.innerText = "Enter new value:";
	
	oCell = oRow.insertCell();
	oCell.align = "left";
	oCell.vAlign = "middle";
	oCell.innerHTML = "<input type=\"text\" name=\"" + attr_name + "\" size=\"5\" value=\"\" style=\"width:100%;\"<%= (isUnsub || !bCanWrite)?" disabled":"" %>>";	
}

</SCRIPT>


</BODY></HTML>
<%
}
catch(Exception ex)
{ 

	ErrLog.put(this,ex,"Problem with Recipient Edit\r\n Request XML: "+sRequestXML+"\r\n List XML: "+sListXML,out,1);

}
finally
{
	if ( stmt != null ) stmt.close();
	if ( srvConnection != null ) connectionPool.free(srvConnection); 
}
%>

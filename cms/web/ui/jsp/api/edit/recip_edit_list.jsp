<%@ page

		language="java"
		import="com.britemoon.cps.imc.*,
		com.britemoon.cps.*,
		com.britemoon.*,
		java.util.*,java.sql.*,
		java.net.*,org.w3c.dom.*,
		org.apache.log4j.*"
		contentType="text/html;charset=UTF-8"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>

<%@ include file="../header.jsp"%>
<%@ include file="../validator.jsp"%>
<%! static Logger logger = null;%>
<%
	if(logger == null)
	{
		logger = Logger.getLogger(this.getClass().getName());
	}
	AccessPermission can = user.getAccessPermission(ObjectType.RECIPIENT);
	boolean STANDARD_UI = (ui.n_ui_type_id == UIType.STANDARD);

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
	JsonObject data = new JsonObject();
	JsonArray array = new JsonArray();
	JsonObject dataJson = new JsonObject();


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

<%=(sEnableFlag.equals("0")?"<FONT color=red>* Editting of recipient data is temporarily disabled.</FONT>":"")%>

<%
	Element eRecipList = XmlUtil.getRootElement(sListXML);
	int nTotRecips = Integer.parseInt(XmlUtil.getChildTextValue(eRecipList, "total_recips"));
	int nTotReturned = Integer.parseInt(XmlUtil.getChildTextValue(eRecipList, "total_returned"));

	if ( nTotReturned < nTotRecips ) {
		dataJson.put("searchCount",nTotRecips);
%>
<%--<%=nTotReturned%> Recipients have been returned out of <%=nTotRecips%> which match your search criteria.<BR>--%>
<%
	}

	XmlElementList xelRecips = XmlUtil.getChildrenByName(eRecipList, "recipient");

%>

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
			data = new JsonObject();
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
			data.put("recipId", sRecipID);
			sEmail821 = XmlUtil.getChildCDataValue(eRecip,"email_821");
			data.put("email821", sEmail821);
			sPNmGiven = XmlUtil.getChildCDataValue(eRecip,"pnmgiven");
			data.put("firstName",sPNmGiven);
			if (sPNmGiven == null){
				sPNmGiven = "";
				data.put("firstName","");
			}
			sPNmFamily = XmlUtil.getChildCDataValue(eRecip,"pnmfamily");
			data.put("lastName", sPNmFamily);
			if (sPNmFamily == null){
				sPNmFamily = "";
				data.put("lastName","");
			}
			sEmailTypeID = XmlUtil.getChildCDataValue(eRecip,"email_type_id");
			data.put("emailTypeId",sEmailTypeID);



			rs = stmt.executeQuery("SELECT email_type_name FROM ccps_email_type WHERE email_type_id = "+sEmailTypeID);

			if (rs.next()){
				sEmailTypeName = rs.getString(1);
				data.put("sEmailTypeName",sEmailTypeName);
			}
			if (sEmailTypeID == null) {
				sEmailTypeID = "";
				data.put("sEmailTypeID","");
			}
			if (sEmailTypeName == null) {
				sEmailTypeName = "";
				data.put("sEmailTypeName","");
			}
			sVal = XmlUtil.getChildCDataValue(eRecip,"email_type_confidence");
			data.put("emailTypeConfidence",nEmailConfidence);
			nEmailConfidence = Integer.parseInt((sVal!=null)?sVal:"5");
			sVal = XmlUtil.getChildCDataValue(eRecip,"status_id");
			nStatusID = Integer.parseInt((sVal!=null)?sVal:"0");
			data.put("statusId",nStatusID);
			sOrgNm = XmlUtil.getChildCDataValue(eRecip,"orgnm");
			data.put("orgnm",sOrgNm);


			if (sOrgNm == null){
				sOrgNm = "";
				data.put("sOrgNm",sOrgNm);
			}
			array.put(data);
			rs = stmt.executeQuery("SELECT DISTINCT attr_name FROM ccps_cust_attr c, ccps_attribute a WHERE c.cust_id = "+cust.s_cust_id
					+ " AND c.attr_id = a.attr_id"
					+ " AND attr_name NOT IN ('recip_id','email_821','pnmgiven','pnmfamily','email_type_id','status_id','orgnm','email_type_confidence')"
					+ " AND fingerprint_seq IS NOT NULL");
			int jj=0;

			while (rs.next())
			{
				sExtraAttrName[jj] = rs.getString(1);
				sExtraAttrValue[jj] = XmlUtil.getChildCDataValue(eRecip,sExtraAttrName[jj]);
				data.put("sExtraAttrName",sExtraAttrName[jj]);
				data.put("sExtraAttrValue",sExtraAttrValue[jj]);


				jj++;
			}
			AccessPermission canReSubscribe = user.getAccessPermission(ObjectType.RECIP_RESUBSCRIBE);
			
			if(nStatusID==RecipStatus.DRAFT){
				data.put("recipStatus","DRAFT");
			}else if(nStatusID==RecipStatus.ACTIVE){
				data.put("recipStatus","ACTIVE");
			}else if(nStatusID==RecipStatus.NEW_ACTIVE){
				data.put("recipStatus","NEW_ACTIVE");
			}
			else if(nStatusID==RecipStatus.OLD_ACTIVE){
				data.put("recipStatus","OLD_ACTIVE");
			}
			else if(nStatusID==RecipStatus.EXCLUDED){
				data.put("recipStatus","EXCLUDED");
			}
			else if(nStatusID==RecipStatus.BOUNCEDBACK){
				data.put("recipStatus","BOUNCEDBACK");
			}
			else if(nStatusID==RecipStatus.UNSUBSCRIBED){
				data.put("recipStatus","UNSUBSCRIBED");
			}
			else if(nStatusID==RecipStatus.GLOBAL_EXCLUSION){
				data.put("recipStatus","GLOBAL_EXCLUSION");
			}
			else if(nStatusID==RecipStatus.TEST_UNSUBSCRIBED){
				data.put("recipStatus","TEST_UNSUBSCRIBED");
			}
			else if(nStatusID==RecipStatus.DELETED){
				data.put("recipStatus","DELETED");
			}

			if (nStatusID < RecipStatus.ACTIVE){
			nStatusCanChangeTo = RecipStatus.NEW_ACTIVE;
			}
			else if ( (nStatusID >= RecipStatus.ACTIVE) && (nStatusID < RecipStatus.EXCLUDED) )
				nStatusCanChangeTo = RecipStatus.UNSUBSCRIBED;
			else if ( (nStatusID >= RecipStatus.EXCLUDED) && (nStatusID < RecipStatus.UNSUBSCRIBED) )
				nStatusCanChangeTo = RecipStatus.OLD_ACTIVE;
			else if ( (nStatusID == RecipStatus.TEST_UNSUBSCRIBED) )
				nStatusCanChangeTo = RecipStatus.OLD_ACTIVE;
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
			isUnsub  = ( (nStatusID == RecipStatus.UNSUBSCRIBED) );
			if(canReSubscribe.bExecute)
			{
				isUnsub = false;
			}

			for (i=0 ; i < nRecipStatus ; i ++) {
				sSelected = ( iRecipStatusId [i] == nStatusID )  ?   " selected" : "";
				if (iRecipStatusId[i] == nStatusID || iRecipStatusId[i] == nStatusCanChangeTo)
				{

				}
			}


		}

		if(dataJson.length()>0) array.put(dataJson);

		out.println(array.toString());


	} catch(Exception ex) {

		ErrLog.put(this,ex,"Problem finding Recipients.\r\n Request XML: "+sRequestXML+"\r\n List XML: "+sListXML,out,1);

	} finally {
		if ( rs!= null ) rs.close();	
		if ( stmt != null ) stmt.close();
		if ( srvConnection != null ) connectionPool.free(srvConnection);
	}
%>






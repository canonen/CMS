<%@ page
		language="java"
		import="com.britemoon.cps.imc.*,
		com.britemoon.cps.*,
		com.britemoon.*,
		java.util.*,java.sql.*,
		java.net.*,org.w3c.dom.*,
		org.apache.log4j.*"
%>
<%@ page import="com.restfb.json.JsonObject" %>
<%@ page import="com.restfb.json.JsonArray" %>
<%@ page import="org.json.XML" %>
<%@ include file="../header.jsp" %>
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


	JsonObject data=new JsonObject();
	JsonObject data2=new JsonObject();
	JsonObject data3=new JsonObject();
	JsonObject data4=new JsonObject();
	JsonArray array =new JsonArray();
	JsonArray array2 = new JsonArray();
	JsonArray array3 = new JsonArray();
	JsonArray array4 = new JsonArray();
	JsonArray array5 = new JsonArray();

	Statement		stmt			= null;
	ResultSet		rs				= null;
	ConnectionPool	connectionPool	= null;
	Connection		srvConnection	= null;

	String sRequestXML = "";
	String sListXML = "";

	try
	{
		connectionPool = ConnectionPool.getInstance();
		srvConnection = connectionPool.getConnection(this);
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
			data2 = new JsonObject();
			iEmailTypeId [nEmailType] = rs.getString(1);
			sEmailType   [nEmailType] = rs.getString(2);
			data2.put("iEmailTypeId",iEmailTypeId [nEmailType]);
			data2.put("sEmailType", sEmailType [nEmailType]);
			nEmailType ++;

		}
		//array2.put(data2);
		rs.close();

		rs = stmt.executeQuery ( "select status_id, display_name FROM ccps_recip_status WHERE status_id < 300");
		while ( rs.next() )
		{
			data3=new JsonObject();

			iRecipStatusId [nRecipStatus] = rs.getInt(1);
			sRecipStatus   [nRecipStatus] = rs.getString(2);
			data3.put("iRecipStatusId",iRecipStatusId [nRecipStatus]);
			data3.put("sRecipStatus", sRecipStatus [nRecipStatus]);
			nRecipStatus ++;

		}
		array3.put(data3);
		rs.close();


		sRequestXML += "<RecipRequest>\r\n";
		sRequestXML += "<action>EdtDetail</action>\r\n";
		sRequestXML += "<cust_id>" + cust.s_cust_id + "</cust_id>\r\n";
		sRequestXML += "<recip_id>" + sRecipID + "</recip_id>\r\n";
		sRequestXML += "<num_recips>1</num_recips>\r\n";
		sRequestXML += "<attr_list>all</attr_list>\r\n";
		sRequestXML += "</RecipRequest>\r\n";

//	data.put("RecipRequest","RecipRequest");
//	data.put("action","EdtDetail");
//	data.put("cust_id",cust.s_cust_id );
//	data.put("recip_id",sRecipID);
//	data.put("num_recips","1");
//	data.put("attr_list","all");

		sListXML = Service.communicate(ServiceType.RRCP_RECIP_VIEW, cust.s_cust_id, sRequestXML);
//		JSONObject json= XML.toJSONObject(sListXML);

//	array.put(data);
//	out.println(data.toString());

		//System.out.println(sListXML);


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
			data.put("eRecip", sRecipID);
			sEmail821		= XmlUtil.getChildCDataValue(eRecip,"email_821");
			data.put("eMail821",sEmail821);
			spnmfull		= XmlUtil.getChildCDataValue(eRecip,"pnmfull");
			data.put("pnmFull",spnmfull);
			sRecipLogin		= XmlUtil.getChildCDataValue(eRecip,"recip_login");
			data.put("recipLogin",sRecipLogin);

			if (sRecipLogin == null){
				sRecipLogin = "";
				data.put("sRecipLogin",sRecipLogin);
			}
			sRecipPassword = XmlUtil.getChildCDataValue(eRecip,"recip_password");
			data.put("sRecipPassword",sRecipPassword);

			if (sRecipPassword == null){
				sRecipPassword = "";
				data.put("sRecipPassword",sRecipPassword);
			}

			sEmailTypeID = XmlUtil.getChildCDataValue(eRecip,"email_type_id");
			data.put("eMailTypeId",sEmailTypeID);

			rs = stmt.executeQuery("select email_type_name FROM ccps_email_type WHERE email_type_id = " + sEmailTypeID);

			if (rs.next()){
				sEmailTypeName = rs.getString(1);
				data.put("sEmailTypeName",sEmailTypeName);
			}
			if (sEmailTypeID == null){
				sEmailTypeID = "";
				data.put("sEmailTypeID",sEmailTypeID);
			}
			if (sEmailTypeName == null){
				sEmailTypeName = "";
				data.put("sEmailTypeName",sEmailTypeName);
			}

			sVal = XmlUtil.getChildCDataValue(eRecip,"email_type_confidence");
			nEmailConfidence = Integer.parseInt((sVal!=null)?sVal:"5");
			data.put("eMailTypeConfidence",nEmailConfidence);
			nStatusID = Integer.parseInt(XmlUtil.getChildCDataValue(eRecip,"status_id"));
			data.put("nStatusId",nStatusID);

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

			data.put("sRecipID",sRecipID);

			if(isUnsub || !bCanWrite)
			{
				data.put("disabled","");
			}
			data.put("sEmail821",sEmail821);

			if(isUnsub || !bCanWrite)
			{
				data.put("disabled","");
			}
			data.put("spnmfull",spnmfull);
			data.put("sEmailTypeID",sEmailTypeID);

			array4.put(data);
			JsonObject data1 = new JsonObject();
			for (i=0 ; i < nEmailType ; i ++)
			{
				data4 = new JsonObject();
				sSelected = ( sEmailTypeID.equals(iEmailTypeId [i]) && ( nEmailConfidence >= 30 ) ) ? "selected" : "";
				data4.put("iEmailTypeId",iEmailTypeId [i]);
				data4.put("sEmailType",sEmailType [i]);

				array2.put(data4);
			}
			data.put("nEmailConfidence",nEmailConfidence);

			if(isUnsub || !bCanWrite)
			{
				data.put("disabled","");
			}

			for (i=0 ; i < nRecipStatus ; i ++)
			{
				data1 = new JsonObject();
				sSelected = ( iRecipStatusId [i] == nStatusID )  ?   "selectED" : "";
				if (iRecipStatusId [i] == nStatusID || iRecipStatusId [i] == nStatusCanChangeTo)
				{
					data1.put("sSelected",sSelected);
					data1.put("iRecipStatusId",iRecipStatusId [i]);
					data1.put("sRecipStatus",sRecipStatus [i]);
					array3.put(data1);

				}

			}
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
				data= new JsonObject();
				sFieldName [nFields]	= rs.getString(1);
				sFieldLabel [nFields]	= new String(rs.getBytes(2), "ISO-8859-1");
				nValueQty [nFields]		= rs.getInt(3);

				sNLType = "";
				sNLType = rs.getString(4);
				data.put("sFieldName",sFieldName [nFields]);
				data.put("sFieldLabel",sFieldLabel [nFields]);
				data.put("nValueQty",nValueQty [nFields]);
				data.put("sNLType",sNLType);

				if (sNLType == null){
					sNLType = "";
					data.put("sNLType","");
				}

				if (nValueQty [nFields] == 0)
				{
					if ("".equals(sNLType))
					{
						sTmp = XmlUtil.getChildCDataValue(eRecip,sFieldName [nFields]);

						if (sTmp == null){
							sTmp = "";
							data.put("sTmp","");
						}

						data.put("sTmp",sTmp);

						if(isUnsub || !bCanWrite){
							data.put("disabled","");
						}
						data.put("sNLType",sNLType);
						iCol ++;
					}
					else
					{
						/* Newsletter Field */

						sTmp = XmlUtil.getChildCDataValue(eRecip,sFieldName [nFields]);

						if (sTmp == null){
							sTmp = "";
							data.put("sTmp","");
						}

						data.put("sTmp",sTmp);


						if ("Y".equals(sNLType))
						{
							data.put("sFieldLabel",sFieldLabel[nFields]);
							data.put("sFieldName",sFieldName[nFields]);
							data.put("sTmp",sTmp);
							data.put("sNLType",sNLType);
						}
						else
						{
							data.put("sFieldLabel",sFieldLabel[nFields]);
							data.put("sFieldName",sFieldName[nFields]);
							data.put("sTmp",sTmp);
							data.put("sNLType",sNLType);
						}
						iCol ++;

						newsFields++;
					}
				}
				else
				{
					/* Multi-value Field */

					XmlElementList xelMultiField = XmlUtil.getChildrenByName (eRecip, sFieldName [nFields]);





					String.valueOf(xelMultiField.getLength() + 1);
					data.put("sFieldName[nFields]",sFieldName[nFields]);


					int j = 0;

					for (j=0; j < xelMultiField.getLength() ; j++)
					{
						data= new JsonObject();
						Element eField = (Element) xelMultiField.item(j);
						sTmp = XmlUtil.getCDataValue(eField);

						if (sTmp == null)	sTmp = "";




						data.put("sFieldName",sFieldName[nFields]);
						data.put("sTmp",sTmp);
						if(isUnsub || !bCanWrite) data.put("disabled","");

						iCol ++;
						array5.put(data);
					}

					if(isUnsub || !bCanWrite) data.put("disabled","");


					iCol ++;
					mvalFields++;
				}
				nFields ++;
				array5.put(data);
			}
			rs.close();



		}
		else
		{
			throw new Exception ("No Recipient Found");
		}


		array.put(array4);
		array.put(array3);
		array.put(array2);
		array.put(array5);
		out.println(array.toString());

	}
	catch(Exception ex)
	{

		ErrLog.put(this,ex,"Problem with Recipient Edit\r\n Request XML: "+sRequestXML+"\r\n List XML: "+sListXML,out,1);

	}
	finally
	{
		if ( rs != null ) rs.close();
		if ( stmt != null ) stmt.close();
		if ( srvConnection != null ) connectionPool.free(srvConnection);
	}
%>

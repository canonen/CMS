<%
int nTypeId = -1;
int nStatusId = -1;
int nAprovalFlag = -1;
int nIsSample = -1;
int nCampCount = -1;
int nModeId = -1;
String sSampleCampName = "";
String sTypeName = "";

boolean bAllSamplesDone = true;
boolean bShowRow = true;
boolean bHasSendingCamps = false;

String sClassAppend = "";
int sampleCount = 0;
//Find out what state this campaign is in based on camps with origin_camp_id
sSql =
	" SELECT" +
	" camp_name," +
	" type_id," +
	" status_id," +
	" ISNULL(approval_flag,0)," +
	" SIGN(ISNULL(sample_id,0)) " +
	" FROM cque_campaign" +
	" WHERE origin_camp_id = " + camp.s_camp_id +
     " AND ISNULL(mode_id,0) <> " + CampaignMode.CALC_ONLY +                                                            // Don't display any calc_only test campaigns
	" ORDER BY type_id, status_id, ISNULL(approval_flag,0), SIGN(ISNULL(sample_id,0))";

rs = stmt.executeQuery(sSql);

if (rs.next())
{
	bWasAnythingSent = true;

	do
	{
		bShowRow = true;
		
		sSampleCampName = rs.getString(1);
		nTypeId = rs.getInt(2);
		nStatusId = rs.getInt(3);
		nAprovalFlag = rs.getInt(4);
		nIsSample = rs.getInt(5);
			
		if((nIsSample == 0) && (nTypeId != CampaignType.TEST))
		{
			bWasFinalCampSent = true;
               if ( (nStatusId == CampaignStatus.PENDING_APPROVAL))
			{
				finalIsPending = true;
			}

		}
		else
		{
			if (nTypeId != CampaignType.TEST)
			{
				bWasSamplesetSent = true;
                    if ( (nStatusId == CampaignStatus.PENDING_APPROVAL))
                    {
                         samplesArePending = true;
                    }
			}
		}

		if (nIsSample != 0 && nStatusId < CampaignStatus.DONE)
		{
			bAllSamplesDone = false;
		}

		if (!bHasUnapprovedCamps && (nAprovalFlag == 0))
		{
			bHasUnapprovedCamps = true;
		}

		if (!bHasSendingCamps && (nStatusId == CampaignStatus.BEING_PROCESSED))
		{
			bHasSendingCamps = true;
		}
		
		if (nTypeId == CampaignType.TEST)
		{
			//Test, see if it is in the middle of testing
			if (nStatusId < CampaignStatus.DONE)
			{
				isTesting = true;
			}
			if ((nStatusId >= CampaignStatus.DONE) && (nStatusId != CampaignStatus.ERROR))
			{
				bShowRow = false;
			}

			sTypeName = "Test";
		}
		else
		{
			//Normal campaign
			if ((nIsSample == 0) && (nStatusId < CampaignStatus.DONE) && (nStatusId != CampaignStatus.PENDING_APPROVAL))
			{
				isSending = true;
			}

			
			if (nIsSample == 0)
			{
				sTypeName = "Final";
			}
			else
			{
				if (isDynamicCampaign) {
					sTypeName = "Campaign";
				}
				else {
					sTypeName = "Sample";
				}
			}
		}
//          System.out.println(sSampleCampName + "Type/status/appflag/isSample/isPending:  " + nTypeId + "/" +  nStatusId + "/" + nAprovalFlag + "/" + nIsSample + "/" + isPending);
		
		if (bShowRow == true)
		{
			if (sampleCount == 0)
			{
				sShowSampleStatus = "<table class=listTable cellspacing=0 cellpadding=2 width=100% border=0>\n";
				sShowSampleStatus += "	<tr>\n";
				sShowSampleStatus += "		<th>Campaign</th>\n";
				sShowSampleStatus += "		<th>Type</th>\n";
				sShowSampleStatus += "		<th>Status</th>\n";
				sShowSampleStatus += "		<th>Approved</th>\n";
				sShowSampleStatus += "	</tr>\n";
			}
			
			if (sampleCount % 2 != 0)
			{
				sClassAppend = "_Alt";
			}
			else
			{
				sClassAppend = "";
			}
			
			sampleCount++;
			
			sShowSampleStatus += "	<tr>";
			sShowSampleStatus += "		<td class='listItem_Title" + sClassAppend + "'>" + sSampleCampName + "</td>\n";
			sShowSampleStatus += "		<td class='listItem_Title" + sClassAppend + "'>" + sTypeName + "</td>\n";
			sShowSampleStatus += "		<td class='listItem_Title" + sClassAppend + "'>" + CampaignStatus.getDisplayName(nStatusId) + "</td>\n";
			sShowSampleStatus += "		<td class='listItem_Title" + sClassAppend + "'>" + ((nAprovalFlag == 0)?"no":"yes") + "</td>\n";
			sShowSampleStatus += "	</tr>\n";
		}

	} while (rs.next());
	
	if (sampleCount != 0)
	{
		sShowSampleStatus += "</table>\n";
	}
	else
	{
		sShowSampleStatus += "<table class=listTable cellspacing=1 cellpadding=2 width=100% border=0>\n";
		sShowSampleStatus += "	<tr>\n";
		sShowSampleStatus += "		<td style=padding:10px; width=100% valign=top align=center>\n";
		sShowSampleStatus += "			Once you click Start Campaign or Send A Test, \n";
		sShowSampleStatus += "			relevant information about the status of your campaign will appear here.\n";
		sShowSampleStatus += "		</td>\n";
		sShowSampleStatus += "	</tr>\n";
		sShowSampleStatus += "</table>\n";
	}

	if( bHasUnapprovedCamps)
	{
		String sNotApproved = "Unapproved campaign will not be sent out on the specified time until it is approved.";

		sShowSampleStatus += "<br>\n";
		sShowSampleStatus += "<table class=listTable cellspacing=1 cellpadding=2 width=100% border=0>\n";
		sShowSampleStatus += "	<tr>\n";
		sShowSampleStatus += "		<td valign=middle align=center style='padding:10px;' width='100%'>\n";
		sShowSampleStatus += "			<font color=red><b>" + sNotApproved + "</b></font>\n";
		sShowSampleStatus += "		</td>\n";
		sShowSampleStatus += "	</tr>\n";
		sShowSampleStatus += "</table>\n";

	}

	if (canApprove.bExecute && bWasSamplesetSent && !bAllSamplesDone && (nStatusId != CampaignStatus.PENDING_APPROVAL))
	{ 
		if (!(isPrintCampaign && bHasSendingCamps))
		{

			sShowSampleStatus += "<br>\n";
			sShowSampleStatus += "<table class=listTable cellspacing=1 cellpadding=2 width=100% border=0>\n";
			sShowSampleStatus += "	<tr>\n";
			sShowSampleStatus += "		<td valign=middle align=center style='padding:10px;' width='100%'>\n";
			if( bHasUnapprovedCamps)
			{
				sShowSampleStatus += "			<a class=actionbutton href='camp_approve.jsp?camp_id=" + camp.s_camp_id + "&action=approvesamples'>Approve All Samples</a>\n";
			} else {
				sShowSampleStatus += "			<a class=deletebutton href='camp_approve.jsp?camp_id=" + camp.s_camp_id + "&action=suspendsamples'>Suspend All Samples</a>\n";
			}
			sShowSampleStatus += "		</td>\n";
			sShowSampleStatus += "	</tr>\n";
			sShowSampleStatus += "</table>\n";

		}
	} else {
          if (finalIsPending) {
               if (can.bApprove && isFinalApprover)
               {
                    sShowSampleStatus += "<br>\n";
                    sShowSampleStatus += "<table class=listTable cellspacing=1 cellpadding=2 width=100% border=0>\n";
                    sShowSampleStatus += "	<tr>\n";
                    sShowSampleStatus += "		<td valign=middle align=center style='padding:10px;' width='100%'>\n";
                    sShowSampleStatus += "         <a href='#' class='savebutton' onClick='workflow_approve(" + arRequest.s_approval_request_id + ")'>Approve Final Campaign</a>";
                    sShowSampleStatus += "     </td>\n";
                    sShowSampleStatus += "  </tr>\n";
                    sShowSampleStatus += "  <tr> <td align='center' valign='middle' style='padding:10px;'>";
                    sShowSampleStatus += "            <a href='#' class='savebutton' onClick='workflow_approve_w_comments(" + arRequest.s_approval_request_id + ")'>Approve Final Campaign w/ comments</a>";
                    sShowSampleStatus += "     </td>\n";
                    sShowSampleStatus += "  </tr>\n";
                    sShowSampleStatus += "  <tr> <td align='center' valign='middle' style='padding:10px;'>";
                    sShowSampleStatus += "            <a href='#' class='deletebutton' onClick='workflow_reject(" + arRequest.s_approval_request_id + ")'>Reject Final Campaign</a>";
                    sShowSampleStatus += "     </td>\n";
                    sShowSampleStatus += "  </tr>\n";
                    sShowSampleStatus += "</table>\n";
               }
               else
               {
                    sShowSampleStatus += "Final campaign is currently pending approval.\n";
               }
          }
          if (samplesArePending) {
               if (can.bApprove && isSamplesApprover)
               {
                    sShowSampleStatus += "<br>\n";
                    sShowSampleStatus += "<table class=listTable cellspacing=1 cellpadding=2 width=100% border=0>\n";
                    sShowSampleStatus += "	<tr>\n";
                    sShowSampleStatus += "		<td valign=middle align=center style='padding:10px;' width='100%'>\n";
                    sShowSampleStatus += "         <a href='#' class='savebutton' onClick='workflow_approve(" + arRequestSamples.s_approval_request_id + ")'>Approve All Samples</a>";
                    sShowSampleStatus += "     </td>\n";
                    sShowSampleStatus += "  </tr>\n";
                    sShowSampleStatus += "  <tr> <td align='center' valign='middle' style='padding:10px;'>";
                    sShowSampleStatus += "            <a href='#' class='savebutton' onClick='workflow_approve_w_comments(" + arRequestSamples.s_approval_request_id + ")'>Approve All Samples w/ comments</a>";
                    sShowSampleStatus += "     </td>\n";
                    sShowSampleStatus += "  </tr>\n";
                    sShowSampleStatus += "  <tr> <td align='center' valign='middle' style='padding:10px;'>";
                    sShowSampleStatus += "            <a href='#' class='deletebutton' onClick='workflow_reject(" + arRequestSamples.s_approval_request_id + ")'>Reject All Samples</a>";
                    sShowSampleStatus += "     </td>\n";
                    sShowSampleStatus += "  </tr>\n";
                    sShowSampleStatus += "</table>\n";
               }
               else
               {
                    sShowSampleStatus += "All Samples are currently pending approval.\n";
               }
          }
     }
}
else
{
	sShowSampleStatus = "<table class=listTable cellspacing=1 cellpadding=2 width='100%'>\n";
	sShowSampleStatus += "	<tr>\n";
	sShowSampleStatus += "		<td valign=top align=center style='padding:10px;' width='100%'>\n";
	sShowSampleStatus += "			Once you click Start Campaign or Send A Test, \n";
	sShowSampleStatus += "			relevant information about the status of your campaigns will appear here.\n";
	sShowSampleStatus += "		</td>\n";
	sShowSampleStatus += "	</tr>\n";
	sShowSampleStatus += "</table>\n";
}
rs.close();
%>
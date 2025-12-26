<%@ page
        language="java"
        import="com.britemoon.*,
		com.britemoon.cps.*,
		com.britemoon.cps.adm.*,
		com.britemoon.cps.que.*,
		com.britemoon.cps.wfl.*,
		java.io.*,java.util.*,
		java.sql.*,java.net.*,
		java.text.*,org.apache.log4j.*"
        contentType="text/html;charset=UTF-8"
%>
<%
    boolean step4_tab1_show = true;
    boolean step4_tab2_show = false;

    String step4_tab_width = "350";
    String step4_colspan = " colspan=\"3\"";

    if (!step4_tab2_show)
    {
        step4_tab_width = "500";
        step4_colspan = " colspan=\"2\"";
    }
%>

<table id="Tabs_Table5" cellspacing="0" cellpadding="2" width="660" border="0" class="listTable">
</table>
<tr>
    <th class="Tab_ON" id="tab5_Step1" width="150" onclick="toggleTabs('tab5_Step','block5_Step',1,2,'Tab_ON','Tab_OFF');" valign="center" nowrap align="middle">Send Out</th>
    <%
        if (step4_tab2_show)
        {
    %>
    <th class="Tab_OFF campaign_header" id="tab5_Step2" width="150" onclick="toggleTabs('tab5_Step','block5_Step',2,2,'Tab_ON','Tab_OFF');" valign="center" nowrap align="middle">Advanced Options</th>
    <%
        }
    %>
</tr>

</thead>
<tbody class="EditBlock" id="block5_Step1">
<tr>
    <td class="" valign="top" align="center" width="650"<%= step4_colspan %>>

        <table class="" cellspacing="0" cellpadding="2" width="100%">
            <%
                boolean bNowChecked = true;
                boolean bSpecificChecked = false;




                        bNowChecked = false;
                        bSpecificChecked = true;

                String sDeliverabilityInTypes = "10,11,12,13,14";
            %>
            <tr>
                <td width="150" class="campaign_header" valign="middle">Send Start Date </td>
                <td width="400">
                    <table cellspacing="0" cellpadding="2" border="0">
                        <tr>
                            <td width="25%" class="campaign_header">
                                <input name="start_date_switch" id="start_date_switch_now" value="now" type="radio"<%=((bNowChecked)?" checked":"")%>><label for="start_date_switch_now">&nbsp;Now</label>&nbsp;&nbsp;&nbsp;
                            </td>
                            <td class="campaign_header" nowrap>
                                <input name="start_date_switch" id="start_date_switch_specified" value="" type="radio"<%=((bSpecificChecked)?" checked":"")%>><label for="start_date_switch_specified">&nbsp;Specific date:</label>&nbsp;
                                <select name="start_date_year" onchange="FT.start_date_switch_specified.checked=true;FT.start_date_switch_now.checked=false;">

                                </select>
                                <select name="start_date_month" onchange="FT.start_date_switch_specified.checked=true;FT.start_date_switch_now.checked=false;">

                                </select>
                                <select name="start_date_day" onchange="FT.start_date_switch_specified.checked=true;FT.start_date_switch_now.checked=false;">

                                </select>
                                <select name="start_date_hour" onchange="FT.start_date_switch_specified.checked=true;FT.start_date_switch_now.checked=false;">

                                </select>
                                <!--(EST)-->
                                <input name="start_date" type="hidden" value="">
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>

            <tr id="nowAlert">
                <td colspan="2" style="padding:5px;" align="center">
                    Please select a start date <b><font color="red">no less than 3-5 business days</font></b> from today. Do not select Now.
                </td>
            </tr>


            <tr>
                <td width="150">End Date </td>
                <td width="400">
                    <table>
                        <tr>
                            <td width="25%">
                                <input name="end_date_switch" id="end_date_switch_now" value="never" type="radio"><label for="end_date_switch_now">&nbsp;Never</label>&nbsp;
                            </td>
                            <td class="campaign_header" nowrap>
                                <input name="end_date_switch" id="end_date_switch_specified" value="" type="radio"><label for="end_date_switch_specified">&nbsp;Specific date:</label>&nbsp;
                                <%

                                %>
                                <select name="end_date_year">
                                </select>
                                <select name="end_date_month">
                                </select>
                                <select name="end_date_day">
                                </select>
                                <select name="end_date_hour">
                                </select>
                                <!--(EST)-->
                                <input name="end_date" type="hidden" value="">
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <%

            %>
            <%

            %>
            <tr>
                <td width="150" valign="middle">Delivery Tracker Test</td>
                <td width="400">
                    <table cellspacing="0" cellpadding="2" border="0">
                        <tr>
                            <td width="60">
                                <input name="pv_sendout_switch" id="pv_sendout_switch" type="checkbox"
                                       onClick="if (FT.pv_sendout_switch.checked == false) {
						                  for (var i=0; i < FT.pv_sendout_list_ids.options.length; i++)
						                    FT.pv_sendout_list_ids.options[i].selected = false;
						                }
						                else {
						                  if (FT.pv_sendout_list_ids.options.length == 1)
						                    FT.pv_sendout_list_ids.options[0].selected = true;
						                }">Send to
                            </td>
                            <td nowrap>
                                <select name="pv_sendout_list_ids" multiple size=""
                                        onChange="FT.pv_sendout_switch.checked = false;
						                  for (var i=0; i < FT.pv_sendout_list_ids.options.length; i++)
						                    if (FT.pv_sendout_list_ids.options[i].selected == true)
						                       FT.pv_sendout_switch.checked = true;">

                                </select>
                            </td>
                            <td nowrap>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>

        </table>


    </td>
</tr>
</tbody>
<tbody class="EditBlock" id="block5_Step2" style="display:none;">
<tr>
    <td class="" valign="top" align="center" width="650"<%= step4_colspan %>>


        <script language="javascript">

            function toggleSection(obj, sec)
            {
                var tItem = document.getElementById(sec);
                if (tItem.style.display == "none")
                {
                    tItem.style.display = "";
                    obj.innerText = "Hide Additional Options";
                }
                else
                {
                    tItem.style.display = "none";
                    obj.innerText = "Additional Options";
                }
            }

        </script>

            <%

%>
        <input type="hidden" name="queue_daily_flag" value="">
        <table class="" cellspacing="0" cellpadding="2" width="100%">
                <td width="150" class="campaign_header" valign="middle">Queue Start Date </td>
                <td width="500">
                    <table>
                        <tr>
                            <td class="campaign_header">
                                <input name="queue_date_switch" value="now" id="queue_date_switch_now" type="radio"><label for="queue_date_switch_now">&nbsp;Now</label>&nbsp;
                            </td>
                            <td class="campaign_header" nowrap align="left">
                                <input name="queue_date_switch" value="" id="queue_date_switch_specified" type="radio"><label for="queue_date_switch_specified">&nbsp;Specific date:</label>&nbsp;
                                <select name="queue_date_year" onchange="FT.queue_date_switch_specified.checked=true;FT.queue_date_switch_now.checked=false;">
                                </select>
                                <select name="queue_date_month" onchange="FT.queue_date_switch_specified.checked=true;FT.queue_date_switch_now.checked=false;">
                                </select>
                                <select name="queue_date_day" onchange="FT.queue_date_switch_specified.checked=true;FT.queue_date_switch_now.checked=false;">
                                </select>
                                <select name="queue_date_hour" onchange="FT.queue_date_switch_specified.checked=true;FT.queue_date_switch_now.checked=false;">
                                </select>
                                <!--(EST)-->
                                <input name="queue_date" type="hidden" value="">
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td align="left" valign="middle">
                    When queuing:
                </td>
                <td>
                    <table cellspacing="0" cellpadding="1" border="0">
                        <tr>
                            <td class="campaign_header">
                                start at:
                                <select name=queue_daily_hour>
                                </select>
                                <input name="queue_daily_time" type="hidden" value="">&nbsp;
                                <a href="javascript:void(0);" onclick="toggleSection(this, 'queue_adv');" class="button_res">Additional Options</a>
                            </td>
                        </tr>
                        <tr id="queue_adv" style="display:none;">
                            <td>
                                <table cellspacing="0" cellpadding="1" border="0">
                                    <tr>
                                        <td align="left" valign="middle" rowspan="2">queue only on:</td>
                                        <td align="center" valign="bottom" width="30"><label for="q_wk_mon">Mon</label></td>
                                        <td align="center" valign="bottom" width="30"><label for="q_wk_tue">Tue</label></td>
                                        <td align="center" valign="bottom" width="30"><label for="q_wk_wed">Wed</label></td>
                                        <td align="center" valign="bottom" width="30"><label for="q_wk_thu">Thu</label></td>
                                        <td align="center" valign="bottom" width="30"><label for="q_wk_fri">Fri</label></td>
                                        <td align="center" valign="bottom" width="30"><label for="q_wk_sat">Sat</label></td>
                                        <td align="center" valign="bottom" width="30"><label for="q_wk_sun">Sun</label></td>
                                    </tr>
                                    <tr>
                                        <td align="center" valign="top" width="30"><input name="queue_daily_weekday_mask" id="q_wk_mon" type="checkbox" value="2"></td>
                                        <td align="center" valign="top" width="30"><input name="queue_daily_weekday_mask" id="q_wk_tue" type="checkbox" value="4"></td>
                                        <td align="center" valign="top" width="30"><input name="queue_daily_weekday_mask" id="q_wk_wed" type="checkbox" value="8"></td>
                                        <td align="center" valign="top" width="30"><input name="queue_daily_weekday_mask" id="q_wk_thu" type="checkbox" value="16"></td>
                                        <td align="center" valign="top" width="30"><input name="queue_daily_weekday_mask" id="q_wk_fri" type="checkbox" value="32"></td>
                                        <td align="center" valign="top" width="30"><input name="queue_daily_weekday_mask" id="q_wk_sat" type="checkbox" value="64"></td>
                                        <td align="center" valign="top" width="30"><input name="queue_daily_weekday_mask" id="q_wk_sun" type="checkbox" value="1"></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <%

            %>
            <table class="" cellspacing="0" cellpadding="2" width="100%">
                <tr>
                    <td width="150" class="campaign_header">Queue Start Date </td>
                    <td width="500">
                        <table>
                            <tr>
                                <td class="campaign_header">
                                    <input name="queue_date_switch" value="now" id="queue_date_switch_now" type="radio"><label for="queue_date_switch_now">&nbsp;Now</label>&nbsp;
                                </td>
                                <td nowrap align="left" class="campaign_header">
                                    <input name="queue_date_switch" value="" id="queue_date_switch_specified" type="radio"><label for="queue_date_switch_specified">&nbsp;Specific date:</label>&nbsp;
                                    <select name="queue_date_year" onchange="FT.queue_date_switch_specified.checked=true;FT.queue_date_switch_now.checked=false;">
                                    </select>
                                    <select name="queue_date_month" onchange="FT.queue_date_switch_specified.checked=true;FT.queue_date_switch_now.checked=false;">
                                    </select>
                                    <select name="queue_date_day" onchange="FT.queue_date_switch_specified.checked=true;FT.queue_date_switch_now.checked=false;">
                                    </select>
                                    <select name="queue_date_hour" onchange="FT.queue_date_switch_specified.checked=true;FT.queue_date_switch_now.checked=false;">
                                    </select>
                                    <!--(EST)-->
                                    <input name="queue_date" type="hidden" value="">
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <input type="hidden" name="delay" value="0">
                <input type="hidden" name="day_delay" size=4 value="0">
                <input type="hidden" name="hour_delay" size=4 value="0">

                <tr>
                    <td width="150">Send delay (optional)</td>
                    <td width="500">
                        <input type="hidden" name="delay" value="">
                        <input type="text" name="day_delay" size=4 value="0">
                        Days
                        &nbsp;
                        <input type="text" name="hour_delay" size=4 value="0">
                        Hours
                        &nbsp;&nbsp;&nbsp;
                        (0 means ASAP)
                    </td>
                </tr>
                <%

                %>
                <tr>
                    <td width="150" align="left" valign="middle" class="campaign_header" nowrap>
                        When sending:
                        <input name="start_daily_weekday_mask" type="hidden" value="0">
                    </td>
                    <td width="500">
                        <table cellspacing="0" cellpadding="1" border="0">
                            <tr>
                                <td class="campaign_header">
                                    start at:
                                    <select name=start_daily_hour>
                                        <option>any time</option>
                                    </select>&nbsp;
                                    <a href="javascript:void(0);" onclick="toggleSection(this, 'start_adv');" class="button_res">Additional Options</a>
                                </td>
                            </tr>
                            <tr id="start_adv" style="display:none;">
                                <td>
                                    <table cellspacing="0" cellpadding="1" border="0" width="400">
                                        <tr>
                                            <td align="left" valign="middle" nowrap rowspan="2">send only on:</td>
                                            <td align="center" valign="bottom" width="30"><label for="wk_mon">Mon</label></td>
                                            <td align="center" valign="bottom" width="30"><label for="wk_tue">Tue</label></td>
                                            <td align="center" valign="bottom" width="30"><label for="wk_wed">Wed</label></td>
                                            <td align="center" valign="bottom" width="30"><label for="wk_thu">Thu</label></td>
                                            <td align="center" valign="bottom" width="30"><label for="wk_fri">Fri</label></td>
                                            <td align="center" valign="bottom" width="30"><label for="wk_sat">Sat</label></td>
                                            <td align="center" valign="bottom" width="30"><label for="wk_sun">Sun</label></td>
                                        </tr>
                                        <tr>
                                            <td align="center" valign="top" width="30"><input name="start_daily_weekday_mask" id="wk_mon" type="checkbox" value="2"></td>
                                            <td align="center" valign="top" width="30"><input name="start_daily_weekday_mask" id="wk_tue" type="checkbox" value="4"></td>
                                            <td align="center" valign="top" width="30"><input name="start_daily_weekday_mask" id="wk_wed" type="checkbox" value="8"></td>
                                            <td align="center" valign="top" width="30"><input name="start_daily_weekday_mask" id="wk_thu" type="checkbox" value="16"></td>
                                            <td align="center" valign="top" width="30"><input name="start_daily_weekday_mask" id="wk_fri" type="checkbox" value="32"></td>
                                            <td align="center" valign="top" width="30"><input name="start_daily_weekday_mask" id="wk_sat" type="checkbox" value="64"></td>
                                            <td align="center" valign="top" width="30"><input name="start_daily_weekday_mask" id="wk_sun" type="checkbox" value="1"></td>
                                        </tr>
                                        <tr>
                                            <td align="left" valign="middle" nowrap>and only send until: </td>
                                            <td colspan="7" width="100%">
                                                <select name=end_daily_hour>
                                                    <option>end of the day</option>
                                                </select>
                                                <input name="start_daily_time" type="hidden" value="">
                                                <input name="end_daily_time" type="hidden" value="">
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>

                <tr>
                    <td align="left" class="campaign_header" valign="middle">
                        Stop sending:
                    </td>
                    <td align="left" valign="middle">
                        <table cellspacing="0" cellpadding="1" border="0">
                            <tr>
                                <td class="campaign_header">
                                    <input name="end_date_switch" value="never" id="end_date_switch_never" type="radio">
                                    <label for="end_date_switch_never">When All Messages Are Sent</label>
                                </td>
                            </tr>
                            <tr>
                                <td class="campaign_header">
                                    <input name="end_date_switch" value="" id="end_date_switch_specified" type="radio">
                                    <label for="end_date_switch_specified">End on a Specific Date:</label>
                                    <select name=end_date_year onchange="FT.end_date_switch_specified.checked=true;FT.end_date_switch_never.checked=false;">
                                    </select>
                                    <select name=end_date_month onchange="FT.end_date_switch_specified.checked=true;FT.end_date_switch_never.checked=false;">
                                    </select>
                                    <select name=end_date_day onchange="FT.end_date_switch_specified.checked=true;FT.end_date_switch_never.checked=false;">
                                    </select>
                                    <select name=end_date_hour onchange="FT.end_date_switch_specified.checked=true;FT.end_date_switch_never.checked=false;">
                                    </select>
                                    (EST)
                                    <input name="end_date" type="hidden" value="">
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>&nbsp;</td>
                    <td align="left" valign="middle">
                        <input type="checkbox" id="msg_per_recip_limit" name="msg_per_recip_limit">
                        <label for="msg_per_recip_limit">Allow recipients to participate many times in the campaign</label>
                    </td>
                </tr>

                <input type="hidden" size="8" name="limit_per_hour" value="0">

                <tr>
                    <td>&nbsp;</td>
                    <td class="campaign_header">
                        Maximum Sent Out Per Hour
                        &nbsp;&nbsp;
                        <input type="text" size="8" name="limit_per_hour" value="">
                        (0 for no limit)
                    </td>
                </tr>

            </table>

            </td>
            </tr>


            </tbody>
            <tbody>
            <tr>
                <td align=center colspan="2" style="padding:10px;">
                    <%

                    %>
                    <a class="buttons-action" href="javascript:send();">Start Campaign</a>
                    <%

                    %>
                </td>
            </tr>
            <tbody>
        </table>


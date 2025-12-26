function save() { doit(0); }

function clone() { doit(1); }
function clone2destination() { doit(5); }

function send_test(sample_id) { doit(2); }
function send_calc(sample_id) { doit(6); }
function send_pv_test(pv_test_list_ids) {  FT.pv_test_list_ids.value = pv_test_list_ids; doit(7); }
function send_pv_receipt(pv_test_type_id, pviq) 
{
	FT.pvhist_pv_test_type_id.value = pv_test_type_id;
	FT.pvhist_pviq.value = pviq;
 	doit(8); 
}
function send() { doit(3); }

function create_sampleset() { doit(4); }

function create_dynamic() {
	FT.filter_flag.value = "1";
 	doit(4); 
}

function isEmailOrPers(str) {
	return (isEmail(str) || isPers(str));
}

function isEmail(str)
{
	var supported = 0;
	if (window.RegExp)
	{
		var tempStr = "a";
		var tempReg = new RegExp(tempStr);
		if (tempReg.test(tempStr)) supported = 1;
	}
	
	if (!supported) 
	  return (str.indexOf(".") > 2) && (str.indexOf("@") > 0);
	var r1 = new RegExp("(@.*@)|(\\.\\.)|(@\\.)|(^\\.)");
	var r2 = new RegExp("^.+\\@(\\[?)[a-zA-Z0-9\\-\\.]+\\.([a-zA-Z]{2,3}|[0-9]{1,3})(\\]?)$");
	return ((!r1.test(str) && r2.test(str))); 
}

function isPers(str)
{
	return ((str.indexOf("!*") > -1) 
		&& (str.indexOf(";") > -1) 
		&& (str.indexOf("*!") > -1) 
		&& (str.indexOf(";") > str.indexOf("!*")+2) 
		&& (str.indexOf("*!") > str.indexOf(";")));
}

function doit(flag)
{
	fix_all_dates();

	switch( flag )
	{
		case 0: FT.mode.value="save"; break;
		case 1: FT.mode.value="clone"; break;
		case 2: FT.mode.value="send_test"; break;
		case 3: FT.mode.value="send_camp"; break;
		case 4: FT.mode.value="create_sampleset"; break;
		case 5:
		{
			FT.mode.value="clone2destination";
			flag = 1; //simulate "clone" for validation
			break;
		}
		case 6: FT.mode.value="send_calc"; break;
		case 7: FT.mode.value="send_pv_test"; break;
		case 8: FT.mode.value="send_pv_receipt"; break;
	}


	if( ! are_settings_valid(flag) ) return false;
	if(( flag == 2 ) || (flag == 6))
	{
		if( ! confirm('Are you sure?') ) return false;
	}

	FT.submit();
}

function are_settings_valid(flag)
{
	FT.camp_name.value = FT.camp_name.value.replace(/(^\s*)|(\s*$)/g, '');
	FT.response_frwd_addr.value = FT.response_frwd_addr.value.replace(/(^\s*)|(\s*$)/g, '');

	FT.subj_html.value = FT.subj_html.value.replace(/(^\s*)|(\s*$)/g, '');
	
	FT.from_name.value = FT.from_name.value.replace(/(^\s*)|(\s*$)/g, '');

	FT.from_address.value = FT.from_address.value.replace(/(^\s*)|(\s*$)/g, '');
	if (FT.fa1.checked != true) FT.from_address_id.value = "";
	if (FT.fa2.checked != true) FT.from_address.value = "";
	
	if( FT.camp_name.value == "" )
	{
		alert("Please specify a <Campaign Name> ...");
		return false;
	}

	if ( FT.subj_html.value.length == 0)
	{
		alert("Please include a campaign subject ...");
		return false;
	}
<% if (!canQueueStep) { %>
	FT.queue_date.value = FT.start_date.value;
<% } %>

	var dateStr = new Date();
	if  (FT.start_date.value != "") {
		dateStr = new Date(FT.start_date_year.value, FT.start_date_month.value - 1, FT.start_date_day.value, FT.start_date_hour.value);
		if (isNaN(dateStr) || (dateStr.getMonth()+1 != FT.start_date_month.value)) {
			alert("The <Start Date> is not a valid date ...");
			return false;
		}
	}
	var dateQue = new Date();
	if (FT.queue_date.value == FT.start_date.value) {
		dateQue = dateStr;
	} else if (FT.queue_date.value != "") {
		dateQue = new Date(FT.queue_date_year.value, FT.queue_date_month.value - 1, FT.queue_date_day.value, FT.queue_date_hour.value);
		if (isNaN(dateQue) || (dateQue.getMonth()+1 != FT.queue_date_month.value)) {
			alert("The <Queue Date> is not a valid date ...");
			return false;
		}
	}
	if ((FT.queue_daily_flag == null) || (FT.queue_daily_flag.value != '1')) {
		if (dateQue > dateStr) { 
			if (flag != 1) {
			    alert("The <Queue Date> specified is after the <Start Date> ..."); return false; 
            }
            else {
	            FT.queue_date.value = "";
	            FT.start_date.value = "";
            }
		}
	}

<% 
if( camp.s_type_id.equals("4") )
{
%>
	var sendType = document.getElementById("ar_send_type_1");
	if (sendType.checked == true)
	{
		var obj = FT.auto_respond_list_id;
		if (obj[obj.selectedIndex].value == "")
		{
			alert("Please choose a Notification List, or change the <Send Email To> option ...");
			return false;
		}
	}
<%
}

	if( camp.s_type_id.equals("2") )
	{
		if (canQueueStep)
		{
		%>
	FT.limit_per_hour.value = FT.limit_per_hour.value.replace(/(^\s*)|(\s*$)/g, '');
	if( isNaN(FT.limit_per_hour.value) )
	{
		alert("The field <Maximum Sent Out Per Hour> must be numeric ...");
		return false;
	}
		<%
		}
		if (canStep3)
		{
		%>
	FT.recip_qty_limit.value = FT.recip_qty_limit.value.replace(/(^\s*)|(\s*$)/g, '');
	if( isNaN(FT.recip_qty_limit.value) )
	{
		alert("The field <Subset Sendout> must be numeric ...");
		return false;
	}
		<%
		}
	}
	else
	{
	
%>

<% if( !camp.s_type_id.equals("5") ) { %>
	var dateEnd = new Date();
	if  (FT.end_date.value != "") {
		dateEnd = new Date(FT.end_date_year.value, FT.end_date_month.value - 1, FT.end_date_day.value, FT.end_date_hour.value);
		if (isNaN(dateEnd) || (dateEnd.getMonth()+1 != FT.end_date_month.value)) {
			alert("The <End Date> is not a valid date ...");
			return false;
		}
	}
	var dateDay = new Date();

	if (dateEnd < dateStr)
	{
		alert("The <End Date> specified is before the <Start Date> ...");
		return false;
	}
	if (dateEnd < dateDay)
	{
		alert("The <End Date> specified is before Today ...");
		return false;
	}

	FT.day_delay.value = FT.day_delay.value.replace(/(^\s*)|(\s*$)/g, '');
	if( isNaN(FT.day_delay.value) )
	{
		alert("The field <Send delay Days> must be numeric ...");
		return false;
	}
	FT.hour_delay.value = FT.hour_delay.value.replace(/(^\s*)|(\s*$)/g, '');
	if( isNaN(FT.hour_delay.value) )
	{
		alert("The field <Send delay Hours> must be numeric ...");
		return false;
	}
	FT.delay.value = (FT.day_delay.value)*24 + (FT.hour_delay.value)*1;
<% } %>
<%
	}
	if( !camp.s_type_id.equals("3") )
	{
		if (canStep3)
		{
%>
	FT.camp_frequency.value = FT.camp_frequency.value.replace(/(^\s*)|(\s*$)/g, '');
	if( isNaN(FT.camp_frequency.value) )
	{
		alert("The field <Exclude previous campaign recipients> must be numeric ...");
		return false;
	}
	
	var selText;
	var exc = FT.exclusion_list_id;
	selText = exc[exc.selectedIndex].text;
	if( selText.substring(1, 8) == "Deleted" )
	{
		alert("Please choose a valid <Exclusion list> or select no Exclusion list ...");
		return false;
	}
<%
		}
	}
%>
<% if ( isPrintCampaign || camp.s_type_id.equals("5") ) { %>
	/* saving export info */
	FT.export_name.value = FT.export_name.value.replace(/(^\s*)|(\s*$)/g, '');
	FT.view.value = ""; 
	for (var j=0; j < FT.target.options.length; ++j)  {
		if (j > 0)
			FT.view.value += ","; 
		FT.view.value += FT.target.options[j].value; 
	}
<% } %>

	if (flag > 1)
	{
		if ( (FT.form_flag.value == "0") && ( FT.filter_id.value == "" ) )
		{
			alert("Please choose a <Target group> ...");
			return false;
		}
		if ( (FT.form_flag.value == "1") && ( FT.form_id.value == "" ) )
		{
			alert("Please choose a <Form> ...");
			return false;
		}
<% if ( !camp.s_type_id.equals("5") ) { %>
		if ( FT.cont_id.value == "" )
		{
			alert("Please choose <Content> ...");
			return false;
		}
        <% if (!isPrintCampaign) { %>
		if( FT.from_name.value == "" )
		{
			alert("Please enter a <From Name> ...");
			return false;
		}
		if(( FT.from_address_id.value == "" ) && ( FT.from_address.value == "" ))
		{
			alert("Please choose a <From Address> ...");
			return false;
		}
		if(( FT.from_address.value != "" ) && (!isEmailOrPers(FT.from_address.value)))
		{
			alert("Please enter a valid <From Address> ...");
			return false;
		}
        if((FT.reply_to != null) && (FT.reply_to.value != ""))
        {
            if(!isPers(FT.reply_to.value))
            {
                if (!isEmail(FT.reply_to.value))
                {
                    var reply_to_val = FT.reply_to.value;
                    var addressList = reply_to_val.split(",");
                    if (addressList.length <= 0) 
                    {
                        alert("Please enter a valid <Reply to> ...");
                        return false;
                    }
                    else 
                    {
                        for (var i=0; i < addressList.length; i++) 
                        {
                            if (!isEmail(addressList[i])) 
                            {
                                alert("Please enter a valid <Reply to>, use a comma to separate multiple addresses ...");
                                return false;
                            }
                        }
                    }
                }
            }
        }
		if(( FT.response_frwd_addr.value != "" ) && (!isEmailOrPers(FT.response_frwd_addr.value)))
		{
			alert("Please enter a valid <Response forwarding> ...");
			return false;
		}
		if( FT.response_frwd_addr.value	== "" )
		{
			alert("Please specify <Response forwarding> ...");
			return false;
		}
		if( flag == 2 )
		{
			if( FT.test_list_id.value == "" )
			{
				alert("Please choose a <Test list> ...");
			return false;
		    }
			
			if( FT.test_recip_qty_limit.value != "" )
			{
				var iQty = parseInt(FT.test_recip_qty_limit.value);
				if (iQty >= 500 )
				{
					if (!confirm("The number entered for <Number recipients to include in dynamic test> is larger than the recommended amount, and could result in a very large number of emails being sent to one inbox.\n\nPlease click OK to confirm that is the correct number, or click Cancel to return and reduce the amount."))
		             {
			              return false;
		              }
				}
			}
		}
		if (flag == 3)
		{
			if (FT.pv_sendout_switch != null && FT.pv_sendout_switch.checked == true) {
				for (var i=0; i < FT.pv_sendout_list_ids.options.length; i++) {
					if (document.FT.pv_sendout_list_ids.options[i].selected == true) {
						if (document.FT.pv_test_list_ids.value == "") {
							document.FT.pv_test_list_ids.value = document.FT.pv_sendout_list_ids.options[i].value;
						}
						else {
							document.FT.pv_test_list_ids.value += "," + document.FT.pv_sendout_list_ids.options[i].value;
						}
					}
				}
			}
		}
        <% } %>
<% } else { %>
        /* validating export */
		var i;
		var email_exist = 0; 

		if(FT.export_name.value == "" ){ alert("Please type export name ...");	return false; }
		if(FT.target.length == 0) { alert("Please map fields ...");	return false; }

		for(i = 0, email_exist = 0; i < FT.target.length; ++i ) {
			var tmptext = FT.target.options[i].text;
			tmptext = tmptext.toLowerCase();
			if (tmptext.search ("email") != -1 ) {	email_exist = 1;	break;		}
		}
		
		if (email_exist == 0) {	alert("One of selected fields must be email address...");	return false; }
<% } %>
	}

	return true;
}

function saveCategories()
{
    FT.action = "camp_save_category.jsp";
    FT.submit();
}



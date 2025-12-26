function isEmailOrPers(str)
{
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

function update()
{
	fix_all_dates();
	if( ! are_settings_valid() ) return false;
	FT.submit();
}

function are_settings_valid()
{
	FT.response_frwd_addr.value = FT.response_frwd_addr.value.replace(/(^\s*)|(\s*$)/g, '');

	FT.subj_html.value = FT.subj_html.value.replace(/(^\s*)|(\s*$)/g, '');

	FT.from_address.value = FT.from_address.value.replace(/(^\s*)|(\s*$)/g, '');
	if (FT.fa1.checked != true) FT.from_address_id.value = "";
	if (FT.fa2.checked != true) FT.from_address.value = "";
	
	if ( FT.subj_html.value.length == 0)
	{
		alert("You must include a campaign subject ...");
		return false;
	}

	var dateStr = new Date();
	var dateQue = dateStr;
	if  (FT.start_date.value != "")
	{
		dateStr = new Date(FT.start_date_year.value, FT.start_date_month.value - 1, FT.start_date_day.value, FT.start_date_hour.value);
		if (isNaN(dateStr) || (dateStr.getMonth()+1 != FT.start_date_month.value))
		{
			alert("The <Start Date> is not a valid date ...");
			return false;
		}
	}

	if (FT.queue_date.value != "")
	{
		dateQue = new Date(FT.queue_date_year.value, FT.queue_date_month.value - 1, FT.queue_date_day.value, FT.queue_date_hour.value);
		if (isNaN(dateQue) || (dateQue.getMonth()+1 != FT.queue_date_month.value))
		{
			alert("The <Queue Date> is not a valid date ...");
			return false;
		}
	}

	if ((FT.queue_daily_flag == null) || (FT.queue_daily_flag.value != '1'))
	{
		if (dateQue > dateStr)
		{
		    alert("The <Queue Date> specified is after the <Start Date> ..."); return false; 
		}
	}
<%
	if( camp.s_type_id.equals("2") )
	{
		if (canStep2)
		{
%>
	FT.limit_per_hour.value = FT.limit_per_hour.value.replace(/(^\s*)|(\s*$)/g, '');
	if( isNaN(FT.limit_per_hour.value) )
	{
		alert("The field <Max send per hour> must be numeric ...");
		return false;
	}
<%
		}
	}
	else
	{
%>

<%
		if( !camp.s_type_id.equals("5") )
		{
%>
	var dateDay = new Date();
	var dateEnd = new Date();
	
	if  (FT.end_date.value != "")
	{
		dateEnd = new Date(FT.end_date_year.value, FT.end_date_month.value - 1, FT.end_date_day.value, FT.end_date_hour.value);
		if (isNaN(dateEnd) || (dateEnd.getMonth()+1 != FT.end_date_month.value))
		{
			alert("The <End Date> is not a valid date ...");
			return false;
		}
	}

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
<%
		}
	}
%>
	if (( FT.cont_id != null ) && ( FT.cont_id.value == "" ))
	{
		alert("You should choose <Content> ...");
		return false;
	}
	if(( FT.from_address_id.value == "" ) && ( FT.from_address.value == "" ))
	{
		alert("You should choose <From address> ...");
		return false;
	}
	if(( FT.from_address.value != "" ) && (!isEmailOrPers(FT.from_address.value)))
	{
		alert("Please enter a valid <From address> ...");
		return false;
	}
	if((FT.reply_to != null) && ( FT.reply_to.value != "" ) && (!isEmailOrPers(FT.reply_to.value)))
	{
		alert("Please enter a valid <Reply to> ...");
		return false;
	}
	if(( FT.response_frwd_addr.value != "" ) && (!isEmailOrPers(FT.response_frwd_addr.value)))
	{
		alert("Please enter a valid <Response forwarding> ...");
		return false;
	}
	if( FT.response_frwd_addr.value	== "" )
	{
		alert("You should specify <Response forwarding> ...");
		return false;
	}

	return true;
}
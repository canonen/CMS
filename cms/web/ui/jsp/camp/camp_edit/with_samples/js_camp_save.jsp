function save() { doit(0,''); }

function clone() { doit(1,''); }

function send_test(sample_id) { doit(2, sample_id); }
function send_calc() { doit(6,''); }
function send() { doit(3,''); }

function create_sampleset() { doit(4,''); }

function send_sampleset() { doit(3, 'all_samples'); }
function send_final_campaign() { send(); }

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
	return (!r1.test(str) && r2.test(str)); 
}

function isPers(str)
{
	return ((str.indexOf("!*") > -1) 
		&& (str.indexOf(";") > -1) 
		&& (str.indexOf("*!") > -1) 
		&& (str.indexOf(";") > str.indexOf("!*")+2) 
		&& (str.indexOf("*!") > str.indexOf(";")));
}

// === === ===

function doit(flag, sample_id)
{
	fix_all_dates();

	fix_all_from_address();

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
	}


	if(!are_settings_valid_to_save(sample_id)) return false;
	if(( flag == 2 ) || (flag == 3) || (flag == 6))
	{
		if( ! are_settings_valid_to_send(sample_id, flag) ) return false;
		if( ! confirm('Are you sure?') ) return false;
		FT.sample_id.value = sample_id;
	}

	FT.submit();
}

// === === ===

function are_settings_valid_to_save(sample_id)
{
	FT.camp_name.value = FT.camp_name.value.replace(/(^\s*)|(\s*$)/g, '');
	if( FT.camp_name.value == "" )
	{
		alert("You must specify a <Campaign Name> ...");
		return false;
	}
    <% if (!isPrintCampaign) { %>
	FT.response_frwd_addr.value = FT.response_frwd_addr.value.replace(/(^\s*)|(\s*$)/g, '');

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
                            alert("Please enter a valid <Reply to>, use a comma to separate multiple addresses  ...");
                            return false;
                        }
                    }
                }
            }
        }
    }
    <% } %>
<% if (!isPrintCampaign && canQueueStep) { %>
	FT.limit_per_hour.value = FT.limit_per_hour.value.replace(/(^\s*)|(\s*$)/g, '');
	if( isNaN(FT.limit_per_hour.value) )
	{
		alert("The field <Maximum Sent Out Per Hour> must be numeric ...");
		return false;
	}
<% } %>
<% if (canStep3) { %>
	FT.recip_qty_limit.value = FT.recip_qty_limit.value.replace(/(^\s*)|(\s*$)/g, '');
	if( isNaN(FT.recip_qty_limit.value) )
	{
		alert("The field <Subset Sendout> must be numeric ...");
		return false;
	}
		
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
<% } %>

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

	// validating priority
<% if ( isDynamicCampaign) { %>
	var n = FT.camp_qty.value;
	for (x=1; x <= n; x++)
	{
		var px = eval('FT.priority' + x);
		for (y=1; y <= n; y++) {
			if (x != y) {
				var py = eval('FT.priority' + y);
				if (px.value == py.value) {
					alert("You assigned same priority to campaign " + x + " and campaign " + y);
					return false;
				}
			}
		}
	}
<% } %>
	
	if(!are_settings_valid_to_save_sample('')) return false;

	if(sample_id == 'all_samples')
	{
		var cq = FT.camp_qty.value;
		for(i=1;i<=cq;i++)
		{
			if(!are_settings_valid_to_save_sample(i)) return false;
		}
		return true;
	}
	else
	{
		return are_settings_valid_to_save_sample(sample_id);
	}
	
}

function are_settings_valid_to_save_sample(sample_id)
{
	s = '';
	if(sample_id != '') s =' (Sample ' + sample_id + ')';

	var sh = eval('FT.subj_html' + sample_id);
	if(sh!=null) sh.value = sh.value.replace(/(^\s*)|(\s*$)/g, '');

	if ((sh!=null) && ( sh.value.length == 0))
	{
		alert("You must include a campaign subject" + s);
		return false;
	}


<% if (!canQueueStep) { %>

	var sd = eval('FT.start_date' + sample_id);
	if(sd!=null) FT.queue_date.value = sd.value;
	
<% } %>

	return true;
}

function are_settings_valid_to_send(sample_id, flag)
{
	if ( FT.filter_id.value == "")
	{
		alert("You should choose a <Target group> ...");
		return false;
	}

	if(sample_id == 'all_samples')
	{
		var cq = FT.camp_qty.value;
		for(i=1;i<=cq;i++)
		{
			if(!are_settings_valid_to_send_sample(i, flag)) return false;
		}
		return true;
	}
	else
	{
		return are_settings_valid_to_send_sample(sample_id, flag);
	}
}

function are_settings_valid_to_send_sample(sample_id, flag)
{
	s = '';
	if(sample_id != '') s =' (Sample ' + sample_id + ')';
	
	// === === ===

	var fa = eval('FT.from_address' + sample_id);
	var fai = eval('FT.from_address_id' + sample_id);

	if( (fai!=null)&&(fai.value=="")&&(fa!=null)&&(fa.value=="") )
	{
		alert("You should choose <From address>" + s);
		return false;
	}
	if((fa!=null) && (fa.value != "" ) && (!isEmailOrPers(fa.value)))
	{
		alert("Please enter a valid <From address>" + s);
		return false;
	}
	
	// === === ===

	var fn = eval('FT.from_name' + sample_id);
	if(fn!=null) fn.value = fn.value.replace(/(^\s*)|(\s*$)/g, '');
	if ( (fn!=null)&&(fn.value=="") )
	{
		alert("You should enter a <From Name>" + s);
		return false;
	}

	// === === ===

	var c = eval('FT.cont_id' + sample_id);
	if ( (c!=null)&&(c.value=="") )
	{
		alert("You should choose <Content>" + s);
		return false;
	}

	// === === ===

	var sd = eval('FT.start_date' + sample_id);
	if(sd != null )
	{
		var dateStr = new Date();
		if  (sd.value != "") {
			var sdy = eval('FT.start_date_year' + sample_id);
			var sdm = eval('FT.start_date_month' + sample_id);
			var sdd = eval('FT.start_date_day' + sample_id);
			var sdh = eval('FT.start_date_hour' + sample_id);
			dateStr = new Date(sdy.value, sdm.value - 1, sdd.value, sdh.value);
			if (isNaN(dateStr) || (dateStr.getMonth()+1 != sdm.value)) {
				alert("The <Start Date> is not a valid date" + s);
				return false;
			}
		}


		var dateQue = new Date ();
		if (FT.queue_date.value == sd.value) {
			dateQue = dateStr;
		} else if (FT.queue_date.value != "") {
			dateQue = new Date(FT.queue_date_year.value, FT.queue_date_month.value - 1, FT.queue_date_day.value, FT.queue_date_hour.value);
			if (isNaN(dateQue) || (dateQue.getMonth()+1 != FT.queue_date_month.value)) {
				alert("The <Queue Date> is not a valid date ...");
				return false;
			}
		}
		
		if (dateQue > dateStr)
		{
			alert("The <Queue Date> specified is after the <Start Date>" + s);
			return false;
		}
	}

	// === === ===

	var tli = eval('FT.test_list_id' + sample_id);
	var trq = document.getElementsByName("test_recip_qty_limit");
	var sampNum = sample_id;
	if (sampNum == "") sampNum = 0;
	trq = trq[sampNum];

	if( flag == 2 )
	{
		if( (tli!= null) && (tli.value=="") )
		{
			alert("Please choose a <Test list> ...");
			return false;
		}
		
		if( (trq!= null) && (trq.value!="") )
		{
			var iQty = parseInt(trq.value);
			if (iQty >= 500 )
			{
				if (!confirm("The number entered for <Number recipients to include in dynamic test> is larger than the recommended amount, and could result in a very large number of emails being sent to one inbox.\n\nPlease click OK to confirm that is the correct number, or click Cancel to return and reduce the amount."))
				{
					return false;
				}
			}
		}
	}

	return true;
}


function fix_all_from_address()
{
	fix_sample_from_address('');
	var cq = FT.camp_qty.value;
	for(i=1;i<=cq;i++)
	{
		fix_sample_from_address(i);
	}
}

function fix_sample_from_address(sample_id)
{
	var fa1 = eval('FT.fa1' + sample_id); 
	var fa2 = eval('FT.fa2' + sample_id); 
	var fai = eval('FT.from_address_id' + sample_id);
	var fa = eval('FT.from_address' + sample_id);
	if(fa!=null) fa.value = fa.value.replace(/(^\s*)|(\s*$)/g, '');

	if ((fa1 != null) && (fai != null) && (fa1.checked != true)) fai.value = "";
	if ((fa2 != null) && (fa != null) && (fa2.checked != true)) fa.value = "";
}

function saveCategories()
{
    FT.action = "camp_save_category.jsp";
    FT.submit();
}




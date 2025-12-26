<%@ page 
          contentType="text/html;charset=UTF-8"
%>

// taken from camp/camp_edit/single/js_camp_save.jsp

function savenexit() { doit(-1); }

function save() { doit(0); }

function clone() { doit(1); }
function clone2destination() { doit(5); }

function send_test(sample_id) { doit(2); }
function send() { doit(3); }

function doit(flag)
{
	switch( flag )
	{
		case -1: FT.mode.value="save_n_exit"; break;
		case 0: FT.mode.value="save"; break;
		case 1: FT.mode.value="clone"; break;
		case 2: FT.mode.value="send_test"; break;
		case 3: FT.mode.value="send_camp"; break;
        case 5: {
			FT.mode.value="clone2destination"; break;
			flag = 1; //simulate "clone" for validation
		}
	}


	if( ! are_settings_valid(flag) ) return false;

    if (( flag == 2 )) {
		if( ! confirm('Emin misiniz?') ) return false;
	}

	FT.submit();
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

function are_settings_valid(flag)
{
	FT.camp_name.value = FT.camp_name.value.replace(/(^\s*)|(\s*$)/g, '');
	FT.response_frwd_addr.value = FT.response_frwd_addr.value.replace(/(^\s*)|(\s*$)/g, '');

	FT.subj_html.value = FT.subj_html.value.replace(/(^\s*)|(\s*$)/g, '');

    if ( FT.camp_name.value == "" ) {
		alert("Lütfen bir kampanya adı giriniz");
		document.getElementById("upbtn").style.display = '';
		document.getElementById("downbtn").style.display = 'none';
		switchSteps('1');
		return false;
	}

	FT.queue_date.value = FT.start_date.value;

	var dateQue = new Date(Date.parse(FT.queue_date.value));
	var dateStr = new Date(Date.parse(FT.start_date.value));

	if (dateQue > dateStr) { alert("The <Queue Date> specified is after the <Start Date> ..."); return false; }

    if (flag > 1) {
        if ( (FT.form_flag.value == "0") && ( FT.filter_id.value == "" ) ) {
			alert("Lütfen bir hedef grup seçiniz");
			switchSteps('2');
			return false;
		}
        if ( FT.cont_id.value == "" ) {
			alert("Lütfen bir içerik seçiniz");
			switchSteps('3');
			return false;
		}
        if ( FT.from_address_id.value == "" ) {
			alert("You should choose <From address> ...");
			return false;
		}
        if ( FT.from_name.value == "" ) {
			alert("You should choose <From name> ...");
			return false;
		}
		if(( FT.response_frwd_addr.value != "" ) && (!isEmailOrPers(FT.response_frwd_addr.value)))
		{
			alert("Please enter a valid <Response forwarding> ...");
			return false;
		}
        if( FT.response_frwd_addr.value == "" ) {
			alert("You should specify <Response forwarding> ...");
			return false;
		}
        if( flag == 2 && FT.test_list_id.value == "" ) {
			alert("You should choose a <Test list> ...");
			return false;
		}
	}
	
	if (flag > 0) {		
        if ( FT.subj_html.value.length == 0) {
		    alert("Lütfen kampanya başlığı giriniz");
		    return false;
	    }
		
		if(document.forms['FT'].personalize.checked == true)
		{
			document.forms['FT'].subj_html.value =  document.forms['FT'].persfieldvalue.value + ' ' +  document.forms['FT'].subj_html.value;
		}
		
		
    }
	
	return true;
}
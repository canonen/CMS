function fix_all_dates()
{
	fix_start_date();
	fix_end_date();
	fix_queue_date();
	fix_queue_daily_time();
	fix_start_daily_time()	
	fix_end_daily_time()	
}

function fix_start_date()
{
	var ds = FT.start_date_switch;
	if(ds==null) return;

	var dd = FT.start_date;
	if(dd==null) return;

	if(ds[0].checked) dd.value = '';
	else
	{
		var y = FT.start_date_year;
		var m = FT.start_date_month;
		var d = FT.start_date_day;
		var h = FT.start_date_hour;
		dd.value = y.value + '-' + m.value + '-' + d.value + ' ' + h.value + ':00';
	}
}

function fix_end_date()
{
	var ds = FT.end_date_switch;
	if(ds==null) return;

	var dd = FT.end_date;
	if(dd==null) return;

	if(ds[0].checked) dd.value = '';
	else
	{
		var y = FT.end_date_year;
		var m = FT.end_date_month;
		var d = FT.end_date_day;
		var h = FT.end_date_hour;
		dd.value = y.value + '-' + m.value + '-' + d.value + ' ' + h.value + ':00';
	}
}

function fix_queue_date()
{
	var ds = FT.queue_date_switch;
	if(ds==null) return;

	var dd = FT.queue_date;
	if(dd==null) return;

	if(ds[0].checked) dd.value = '';
	else
	{
		var y = FT.queue_date_year;
		var m = FT.queue_date_month;
		var d = FT.queue_date_day;
		var h = FT.queue_date_hour;
		dd.value = y.value + '-' + m.value + '-' + d.value + ' ' + h.value + ':00';
	}

}

function fix_queue_daily_time()
{
	var df = FT.queue_daily_flag;
	if(df==null) return;

	var dt = FT.queue_daily_time;
	if(dt==null) return;

	if(df.value == '1')
	{
		var h = FT.queue_daily_hour;
		dt.value = '2000-01-01 ' + h.value + ':00';
	}
	else dt.value = '';
}

function fix_start_daily_time()
{
	var dt = FT.start_daily_time;
	if(dt==null)return;
	var h = FT.start_daily_hour;
	if((h==null)||(h.value==''))return;
	dt.value = '2000-01-01 ' + h.value + ':00';
}

function fix_end_daily_time()
{
	var dt = FT.end_daily_time;
	if(dt==null) return;
	var h = FT.end_daily_hour;
	if((h==null)||(h.value==''))return;	
	dt.value = '2000-01-01 ' + h.value + ':00';
}
